import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../models/chat_channel.dart';
import '../models/chat_member.dart';
import '../providers/chat_state_provider.dart';

class EditChannelPage extends ConsumerStatefulWidget {
  final ChatChannel channel;

  const EditChannelPage({
    super.key,
    required this.channel,
  });

  @override
  ConsumerState<EditChannelPage> createState() => _EditChannelPageState();
}

class _EditChannelPageState extends ConsumerState<EditChannelPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _searchController = TextEditingController();

  final List<ChatMember> _selectedMembers = [];
  bool _isInitialized = false;
  String _searchQuery = '';
  String _debouncedQuery = '';
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.channel.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });

    _debounceTimer?.cancel();
    if (_searchQuery.length >= 3) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _debouncedQuery = _searchQuery;
          });
        }
      });
    } else {
      setState(() {
        _debouncedQuery = '';
      });
    }
  }

  void _toggleMemberSelection(ChatMember member) {
    setState(() {
      final exists = _selectedMembers.any((m) => m.memberId == member.memberId && m.memberType == member.memberType);
      if (exists) {
        _selectedMembers.removeWhere((m) => m.memberId == member.memberId && m.memberType == member.memberType);
      } else {
        _selectedMembers.add(member);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final selectedTeam = ref.read(selectedTeamProvider);
    if (selectedTeam == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final service = ref.read(chatApiServiceProvider);
      final usersPayload = _selectedMembers.map((member) => {
        'member_id': member.memberId,
        'member_type': member.memberType,
      }).toList();

      final success = await service.saveChannel(
        teamUuid: selectedTeam.uuid,
        chatChannelId: widget.channel.chatChannelId,
        name: _nameController.text.trim(),
        users: usersPayload,
      );

      if (success) {
        // Refresh channel state
        ref.invalidate(chatChannelsProvider(selectedTeam.uuid));
        ref.invalidate(chatChannelMembersProvider((teamUuid: selectedTeam.uuid, chatChannelId: widget.channel.chatChannelId)));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Channel updated successfully!'),
              backgroundColor: AppColors.current.success,
            ),
          );
          // Pop twice to get back to the messages list
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('API returned failure response');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update channel: ${e.toString()}'),
            backgroundColor: AppColors.current.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteChannel() async {
    final selectedTeam = ref.read(selectedTeamProvider);
    if (selectedTeam == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.current.surface,
        title: Text(
          'Delete Channel',
          style: AppTextStyles.heading18.copyWith(color: AppColors.current.error, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you absolutely sure you want to permanently delete #${widget.channel.name}? This action cannot be undone and will delete all conversation history.',
          style: AppTextStyles.body14.copyWith(color: AppColors.current.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.current.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final service = ref.read(chatApiServiceProvider);
      final success = await service.removeChannel(selectedTeam.uuid, widget.channel.chatChannelId);

      if (success) {
        ref.invalidate(chatChannelsProvider(selectedTeam.uuid));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Channel deleted successfully.'),
              backgroundColor: AppColors.current.success,
            ),
          );
          // Pop twice to get back to the messages list
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('API returned failure response');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete channel: ${e.toString()}'),
            backgroundColor: AppColors.current.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeam = ref.watch(selectedTeamProvider);
    if (selectedTeam == null) {
      return Scaffold(
        backgroundColor: AppColors.current.background,
        body: const SafeArea(child: Center(child: Text('No team selected.'))),
      );
    }

    final membersAsync = ref.watch(chatChannelMembersProvider((
      teamUuid: selectedTeam.uuid,
      chatChannelId: widget.channel.chatChannelId,
    )));

    return Scaffold(
      backgroundColor: AppColors.current.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  membersAsync.when(
                    data: (initialMembers) {
                      if (!_isInitialized) {
                        _selectedMembers.addAll(initialMembers);
                        _isInitialized = true;
                      }

                      return Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionHeader('CHANNEL DETAILS'),
                              const SizedBox(height: 12),
                              _buildNameInputField(),
                              const SizedBox(height: 24),
                              _buildSectionHeader('CHANNEL PARTICIPANTS (${_selectedMembers.length})'),
                              const SizedBox(height: 12),
                              _buildParticipantsList(),
                              const SizedBox(height: 24),
                              _buildSectionHeader('ADD NEW MEMBERS'),
                              const SizedBox(height: 12),
                              _buildSearchField(),
                              const SizedBox(height: 16),
                              _buildSearchResults(selectedTeam.uuid),
                              const SizedBox(height: 40),
                              _buildDangerZone(),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppColors.current.error),
                          const SizedBox(height: 12),
                          Text('Failed to load channel members.', style: AppTextStyles.body16),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => ref.refresh(chatChannelMembersProvider((
                              teamUuid: selectedTeam.uuid,
                              chatChannelId: widget.channel.chatChannelId,
                            ))),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSaving || _isDeleting) _buildLoadingOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final isValid = _nameController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.current.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.current.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Channel',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: isValid && !_isSaving ? _submit : null,
            child: Text(
              'Save',
              style: AppTextStyles.body16.copyWith(
                color: isValid && !_isSaving 
                    ? AppColors.current.primary 
                    : AppColors.current.textSecondary.withOpacity(0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.heading13.copyWith(
        color: AppColors.current.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildNameInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.border),
      ),
      child: TextFormField(
        controller: _nameController,
        style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary),
        onChanged: (_) => setState(() {}),
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            String newText = newValue.text
                .toLowerCase()
                .replaceAll(' ', '-')
                .replaceAll(RegExp(r'[^a-z0-9-_]'), '');
            
            if (newText.length > 80) {
              newText = newText.substring(0, 80);
            }

            return TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: newText.length),
            );
          }),
        ],
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
            child: Text(
              '#',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: 'channel-name',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) return 'Channel name is required';
          if (trimmed.length < 2) return 'Channel name must be at least 2 characters';
          return null;
        },
      ),
    );
  }

  Widget _buildParticipantsList() {
    if (_selectedMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.current.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.current.border),
        ),
        child: Text(
          'No participants in this channel. Add members below.',
          style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _selectedMembers.length,
        separatorBuilder: (context, index) => Divider(color: AppColors.current.border, height: 1),
        itemBuilder: (context, index) {
          final member = _selectedMembers[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.current.indigo.withOpacity(0.1),
              child: Text(
                member.initials,
                style: TextStyle(
                  color: AppColors.current.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              member.email,
              style: AppTextStyles.label12.copyWith(color: AppColors.current.textSecondary),
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: AppColors.current.error),
              onPressed: () => _toggleMemberSelection(member),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.border),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.body14.copyWith(color: AppColors.current.textPrimary),
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.current.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.current.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          hintText: 'Search team members to add...',
          hintStyle: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSearchResults(String teamUuid) {
    if (_searchQuery.isEmpty) return const SizedBox.shrink();

    if (_searchQuery.length < 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.keyboard_outlined, size: 40, color: AppColors.current.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'Type at least 3 characters to search',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
            ),
          ],
        ),
      );
    }

    final searchAsync = ref.watch(chatSearchMembersProvider((teamUuid: teamUuid, query: _debouncedQuery)));

    return searchAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No members match "$_searchQuery"',
                style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.current.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.current.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (context, index) => Divider(color: AppColors.current.border, height: 1),
            itemBuilder: (context, index) {
              final member = members[index];
              final isSelected = _selectedMembers.any((m) => m.memberId == member.memberId && m.memberType == member.memberType);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.current.indigo.withOpacity(0.1),
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: AppColors.current.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  member.name,
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  member.email,
                  style: AppTextStyles.label12.copyWith(color: AppColors.current.textSecondary),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppColors.current.success)
                    : Icon(Icons.add_circle_outline, color: AppColors.current.primary),
                onTap: () => _toggleMemberSelection(member),
              );
            },
          ),
        );
      },
      loading: () => _buildSkeletonResults(),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Failed to search members.',
            style: AppTextStyles.body14.copyWith(color: AppColors.current.error),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonResults() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => Divider(color: AppColors.current.border, height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.current.textSecondary.withOpacity(0.1),
                  radius: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.current.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.current.textSecondary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.current.error.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.error.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.current.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Danger Zone',
                style: AppTextStyles.heading16.copyWith(
                  color: AppColors.current.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Deleting this channel will permanently remove all of its conversations and chat history from TalkJS. This operation is absolute and cannot be undone.',
            style: AppTextStyles.body14.copyWith(
              color: AppColors.current.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.current.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _deleteChannel,
            icon: const Icon(Icons.delete_forever, size: 20),
            label: Text(
              'Delete Channel',
              style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final message = _isDeleting ? 'Deleting channel...' : 'Saving updates...';
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.current.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.current.primary),
              const SizedBox(height: 20),
              Text(
                message,
                style: AppTextStyles.body15.copyWith(
                  color: AppColors.current.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
