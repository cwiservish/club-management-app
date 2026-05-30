import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../models/chat_member.dart';
import '../providers/chat_state_provider.dart';
import '../providers/create_channel_view_model.dart';

class CreateChannelPage extends ConsumerStatefulWidget {
  const CreateChannelPage({super.key});

  @override
  ConsumerState<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends ConsumerState<CreateChannelPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _debouncedQuery = '';
  Timer? _debounceTimer;

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

  Future<void> _handleRefresh(String teamUuid, String query) async {
    ref.invalidate(chatSearchMembersProvider((teamUuid: teamUuid, query: query)));
    try {
      await ref.read(chatSearchMembersProvider((teamUuid: teamUuid, query: query)).future);
    } catch (_) {
      // Ignored: Riverpod handles the error state which is rendered in the UI
    }
  }

  Future<void> _submit(String teamUuid) async {
    final notifier = ref.read(createChannelViewModelProvider.notifier);
    final response = await notifier.saveChannel(teamUuid);

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Channel created successfully!'),
            backgroundColor: AppColors.current.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Failed to create channel.'),
            backgroundColor: AppColors.current.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeam = ref.watch(selectedTeamProvider);
    final state = ref.watch(createChannelViewModelProvider);
    final notifier = ref.read(createChannelViewModelProvider.notifier);

    // Sync controller with name if edited externally, but typically name is only set in step 0
    if (_nameController.text != state.channelName && state.currentStep == 0) {
      _nameController.text = state.channelName;
    }

    return Scaffold(
      backgroundColor: AppColors.current.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            _buildAppBar(state, notifier, selectedTeam?.uuid),
            if (selectedTeam == null)
              const Expanded(
                child: Center(child: Text('No team selected.')),
              )
            else
              Expanded(
                child: Stack(
                  children: [
                    if (state.currentStep == 0)
                      _buildStepChannelName(state, notifier)
                    else
                      _buildStepAddMembers(state, notifier, selectedTeam.uuid),
                    if (state.isSaving) _buildLoadingOverlay(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(CreateChannelState state, CreateChannelNotifier notifier, String? teamUuid) {
    final isStep0 = state.currentStep == 0;
    final isNameValid = state.channelName.trim().length >= 2;

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
            onPressed: () {
              if (isStep0) {
                Navigator.of(context).pop();
              } else {
                notifier.prevStep();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isStep0 ? 'New Channel' : 'Add Members',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: isStep0
                ? (isNameValid ? () => notifier.nextStep() : null)
                : (teamUuid != null && !state.isSaving ? () => _submit(teamUuid) : null),
            child: Text(
              isStep0 ? 'Next' : 'Create',
              style: AppTextStyles.body16.copyWith(
                color: (isStep0 ? isNameValid : (teamUuid != null && !state.isSaving))
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

  // ─── STEP 1: CHANNEL DETAILS ───────────────────────────────────────────────

  Widget _buildStepChannelName(CreateChannelState state, CreateChannelNotifier notifier) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _buildSectionHeader('CHANNEL DETAILS'),
          const SizedBox(height: 12),
          _buildNameInputField(notifier),
          const SizedBox(height: 8),
          Text(
            'Channels are a great way to communicate with everyone on your team.',
            style: AppTextStyles.label12.copyWith(
              color: AppColors.current.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.current.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: state.channelName.trim().length >= 2
                ? () => notifier.nextStep()
                : null,
            child: Text(
              'Next',
              style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputField(CreateChannelNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.border),
      ),
      child: TextFormField(
        controller: _nameController,
        style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary),
        onChanged: (val) => notifier.setChannelName(val),
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
          hintText: 'e.g. general-chat',
          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.current.textSecondary.withOpacity(0.5)),
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

  // ─── STEP 2: SEARCH AND SELECT MEMBERS ─────────────────────────────────────

  Widget _buildStepAddMembers(CreateChannelState state, CreateChannelNotifier notifier, String teamUuid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('SELECTED MEMBERS (${state.selectedMembers.length})'),
              const SizedBox(height: 12),
              _buildSelectedMembersChips(state, notifier),
              const SizedBox(height: 20),
              _buildSectionHeader('ADD TEAM MEMBERS'),
              const SizedBox(height: 12),
              _buildSearchField(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: _buildSearchResults(state, notifier, teamUuid),
        ),
      ],
    );
  }

  Widget _buildSelectedMembersChips(CreateChannelState state, CreateChannelNotifier notifier) {
    if (state.selectedMembers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.current.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.current.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.current.textSecondary.withOpacity(0.7), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add members to invite them to this channel.',
                style: AppTextStyles.body13.copyWith(
                  color: AppColors.current.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.selectedMembers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final member = state.selectedMembers[index];
          return InputChip(
            label: Text(
              member.name,
              style: AppTextStyles.label12.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            avatar: CircleAvatar(
              backgroundColor: AppColors.current.primary,
              child: Text(
                member.initials,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
            onDeleted: () => notifier.toggleMemberSelection(member),
            deleteIconColor: AppColors.current.textSecondary,
            backgroundColor: AppColors.current.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.current.border),
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
          hintText: 'Search members...',
          hintStyle: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSearchResults(CreateChannelState state, CreateChannelNotifier notifier, String teamUuid) {
    if (_searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_searchQuery.length < 3) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
      );
    }

    final searchAsync = ref.watch(chatSearchMembersProvider((teamUuid: teamUuid, query: _debouncedQuery)));

    return searchAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(teamUuid, _debouncedQuery),
            color: AppColors.current.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: Text(
                  'No members match "$_searchQuery"',
                  style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _handleRefresh(teamUuid, _debouncedQuery),
          color: AppColors.current.primary,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (context, index) => Divider(color: AppColors.current.border, height: 1),
            itemBuilder: (context, index) {
              final member = members[index];
              final isSelected = state.selectedMembers.any((m) => m.memberId == member.memberId && m.memberType == member.memberType);

              return ListTile(
                contentPadding: EdgeInsets.zero,
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
                onTap: () => notifier.toggleMemberSelection(member),
              );
            },
          ),
        );
      },
      loading: () => _buildSkeletonResults(),
      error: (err, _) => RefreshIndicator(
        onRefresh: () => _handleRefresh(teamUuid, _debouncedQuery),
        color: AppColors.current.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 200,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to search members.',
                  style: AppTextStyles.body14.copyWith(color: AppColors.current.error),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to retry',
                  style: AppTextStyles.label12.copyWith(color: AppColors.current.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonResults() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => Divider(color: AppColors.current.border, height: 1),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _buildLoadingOverlay() {
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
                'Creating channel...',
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
}
