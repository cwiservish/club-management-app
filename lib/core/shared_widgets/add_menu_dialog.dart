import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../models/team_model.dart';
import '../../features/roster/providers/roster_provider.dart';
import '../../features/roster/models/player_positions_models.dart';
import '../../features/messages/models/chat_member.dart';
import '../../features/messages/providers/chat_state_provider.dart';
import '../../features/messages/pages/talkjs_chat_page.dart';
import '../common_providers/selected_team_provider.dart';

// ─── AddMenuViewModel (MVVM) ──────────────────────────────────────────────────
class AddMenuViewModel {
  final Team? activeTeam;

  const AddMenuViewModel(this.activeTeam);

  /// If is_coach is true then show event, player, and chat.
  /// Else show player, chat option only (hide event).
  bool get showEvent => activeTeam == null ? true : activeTeam!.isCoach;
  bool get showPlayer => activeTeam == null ? true : activeTeam!.isCoach;
  bool get showChat => true;
}

void showAddMenu(BuildContext context, {Team? activeTeam}) {
  final viewModel = AddMenuViewModel(activeTeam);
  
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent, // As per figma, popover doesn't darken
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final topPadding = MediaQuery.of(context).padding.top;
      final colors = AppColors.current;
      
      return Stack(
        children: [
          Positioned(
            top: 53 + topPadding + 8, // Just below the header
            right: 16,
            width: 295,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.7), // bg-white/70
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (viewModel.showEvent)
                          _MenuOption(
                            icon: '+',
                            label: 'Event',
                            onTap: () {
                              Navigator.of(context).pop();
                              // Commented out old redirection:
                              // context.push(AppRoutes.eventEdit('new'));
                              context.push(AppRoutes.newEvent);
                            },
                          ),
                        if (viewModel.showPlayer)
                          _MenuOption(
                            icon: '+',
                            label: 'Player',
                            onTap: () {
                              Navigator.of(context).pop();
                              _showNewPlayerModal(context, activeTeam: activeTeam);
                            },
                          ),
                        if (viewModel.showChat)
                          _MenuOption(
                            icon: '+',
                            label: 'Chat',
                            borderBottom: false,
                            onTap: () {
                              Navigator.of(context).pop();
                              _showNewChatModal(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  );
}

class _MenuOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool borderBottom;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.borderBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: AppColors.current.border))
              : null,
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.current.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body16.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modal Implementations ──────────────────────────────────────────────────

/*
void _showNewTeamModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewTeamModal(),
  );
}

class _NewTeamModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('New Team', style: AppTextStyles.heading16.copyWith(color: colors.textPrimary)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Save', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('TEAM NAME', 'e.g. 12 Girls ECNL RL'),
                      Divider(height: 1, color: colors.border),
                      _buildTextField('DIVISION', 'e.g. U12'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label11.copyWith(color: AppColors.current.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          TextField(
            style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body16.copyWith(color: AppColors.current.textSecondary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
*/

void _showNewPlayerModal(BuildContext context, {Team? activeTeam}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewPlayerModal(activeTeam: activeTeam),
  );
}

class _NewPlayerModal extends ConsumerStatefulWidget {
  final Team? activeTeam;

  const _NewPlayerModal({super.key, this.activeTeam});

  @override
  ConsumerState<_NewPlayerModal> createState() => _NewPlayerModalState();
}

class _NewPlayerModalState extends ConsumerState<_NewPlayerModal> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jerseyController = TextEditingController();

  List<PlayerPositionModel> _positions = [];
  PlayerPositionModel? _selectedPosition;
  bool _isLoadingPositions = false;
  String? _positionsError;

  bool _isSaving = false;
  bool _isDropdownOpen = false;

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchPositions();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  Future<void> _fetchPositions() async {
    final teamUuid = widget.activeTeam?.uuid;
    if (teamUuid == null || teamUuid.isEmpty) {
      setState(() {
        _positionsError = 'No active team selected';
      });
      return;
    }

    setState(() {
      _isLoadingPositions = true;
      _positionsError = null;
    });

    try {
      final rosterService = ref.read(rosterServiceProvider);
      final response = await rosterService.fetchPlayerPositions(teamUuid);
      if (response.success) {
        setState(() {
          _positions = response.positions;
          _isLoadingPositions = false;
        });
      } else {
        setState(() {
          _positionsError = response.message.isNotEmpty ? response.message : 'Failed to fetch positions';
          _isLoadingPositions = false;
        });
      }
    } catch (e) {
      setState(() {
        _positionsError = e.toString();
        _isLoadingPositions = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImage = image;
          _pickedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.current.error,
        ),
      );
    }
  }

  Future<void> _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile image is required'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a player position'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    final teamUuid = widget.activeTeam?.uuid;
    if (teamUuid == null || teamUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No active team selected'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? imageBase64;
    if (_pickedImageBytes != null) {
      final mimeType = _pickedImage!.path.endsWith('.jpg') || _pickedImage!.path.endsWith('.jpeg')
          ? 'image/jpeg'
          : 'image/png';
      imageBase64 = 'data:$mimeType;base64,${base64Encode(_pickedImageBytes!)}';
    }

    try {
      final rosterService = ref.read(rosterServiceProvider);
      final response = await rosterService.savePlayer(
        teamUuid: teamUuid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        jersey: _jerseyController.text.trim(),
        primaryPosition: _selectedPosition!.key,
        imageBase64: imageBase64,
      );

      final message = response.message;
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message != null && message.isNotEmpty ? message : 'Player saved successfully'),
              backgroundColor: AppColors.current.success,
            ),
          );
          // Refresh the roster list automatically
          ref.read(rosterProvider.notifier).refresh();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message != null && message.isNotEmpty ? message : 'Failed to save player'),
              backgroundColor: AppColors.current.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('New Player', style: AppTextStyles.heading16.copyWith(color: colors.textPrimary)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : GestureDetector(
                          onTap: _savePlayer,
                          child: Text(
                            'Save',
                            style: AppTextStyles.body15.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20 + viewInsets.bottom,
                ),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: colors.border,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _pickedImageBytes != null
                            ? Image.memory(
                                _pickedImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.camera_alt, color: colors.textSecondary, size: 32),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        _buildFormField(
                          label: 'FIRST NAME',
                          placeholder: 'e.g. Preston',
                          controller: _firstNameController,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'First name is required' : null,
                        ),
                        Divider(height: 1, color: colors.border),
                        _buildFormField(
                          label: 'LAST NAME',
                          placeholder: 'e.g. Cole',
                          controller: _lastNameController,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Last name is required' : null,
                        ),
                        Divider(height: 1, color: colors.border),
                        _buildFormField(
                          label: 'JERSEY NUMBER',
                          placeholder: 'e.g. 8',
                          controller: _jerseyController,
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Jersey number is required' : null,
                        ),
                        Divider(height: 1, color: colors.border),
                        _buildDropdownField(label: 'POSITION'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final colors = AppColors.current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label11.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: AppTextStyles.body16.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body16.copyWith(
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              errorStyle: TextStyle(
                color: colors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
  }) {
    final colors = AppColors.current;
    return FormField<PlayerPositionModel>(
      initialValue: _selectedPosition,
      validator: (val) => val == null ? 'Position is required' : null,
      builder: (FormFieldState<PlayerPositionModel> fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tap target row
            InkWell(
              onTap: _isLoadingPositions
                  ? null
                  : () {
                      setState(() {
                        _isDropdownOpen = !_isDropdownOpen;
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTextStyles.label11.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedPosition?.label ?? 'Select position...',
                            style: AppTextStyles.body16.copyWith(
                              color: _selectedPosition == null
                                  ? colors.textSecondary.withValues(alpha: 0.5)
                                  : colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoadingPositions)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      )
                    else
                      AnimatedRotation(
                        turns: _isDropdownOpen ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Error Text (if any)
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 12,
                  ),
                ),
              ),

            // Positions fetching error
            if (_positionsError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _positionsError!,
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _fetchPositions,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Scrollable list directly below
            if (_isDropdownOpen && _positions.isNotEmpty) ...[
              Divider(height: 1, color: colors.border),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                color: colors.background.withValues(alpha: 0.03),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _positions.length,
                    itemBuilder: (context, index) {
                      final pos = _positions[index];
                      final isSelected = _selectedPosition == pos;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPosition = pos;
                            _isDropdownOpen = false;
                            fieldState.didChange(pos);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colors.border.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pos.label,
                                style: AppTextStyles.body16.copyWith(
                                  color: isSelected ? colors.primary : colors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: colors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

void _showNewChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NewChatModal(),
  );
}

class _NewChatModal extends ConsumerStatefulWidget {
  const _NewChatModal({super.key});

  @override
  ConsumerState<_NewChatModal> createState() => _NewChatModalState();
}

class _NewChatModalState extends ConsumerState<_NewChatModal> {
  String type = 'select';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (type != 'select') {
                        setState(() {
                          type = 'select';
                          _searchController.clear();
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    type == 'select' ? 'New Chat' : (type == 'channel' ? 'New Channel' : 'New Direct Message'),
                    style: AppTextStyles.heading16.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (type == 'channel') Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/messages/1');
                    },
                    child: Text('Create', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (type == 'select') Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('New Channel', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('${AppRoutes.messages}/${AppRoutes.createChannel}');
                        },
                      ),
                      Divider(height: 1, color: colors.border),
                      ListTile(
                        title: Text('New Direct Message', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                        onTap: () => setState(() => type = 'dm'),
                      ),
                    ],
                  ),
                ),
                if (type == 'channel') Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHANNEL NAME', style: AppTextStyles.label11.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'e.g. general',
                            prefixIcon: Icon(Icons.tag, size: 18, color: colors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Channels are a great way to communicate with everyone on your team.', style: AppTextStyles.label12.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                ),
                if (type == 'dm') ...[
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (val) {
                        setState(() {});
                      },
                      style: AppTextStyles.body15.copyWith(color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: AppTextStyles.body15.copyWith(color: colors.textSecondary.withValues(alpha: 0.5)),
                        prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: colors.textSecondary,
                                  size: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMemberList(colors),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(AppColors colors) {
    final selectedTeam = ref.watch(selectedTeamProvider);
    if (selectedTeam == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No active team selected',
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    final query = _searchController.text.trim();
    final isSearchingRemote = query.length >= 3;

    final membersAsync = ref.watch(chatMembersProvider(selectedTeam.uuid));
    final searchAsync = isSearchingRemote
        ? ref.watch(chatSearchDmsProvider((teamUuid: selectedTeam.uuid, query: query)))
        : null;

    if (isSearchingRemote && searchAsync != null) {
      return searchAsync.when(
        data: (searchResults) => _buildMembersListView(searchResults, colors),
        loading: () => _buildLoader(colors),
        error: (err, _) => _buildError(colors, () => ref.refresh(chatSearchDmsProvider((teamUuid: selectedTeam.uuid, query: query)))),
      );
    } else {
      return membersAsync.when(
        data: (members) {
          final filtered = members.where((m) {
            return query.isEmpty || m.name.toLowerCase().contains(query.toLowerCase());
          }).toList();
          return _buildMembersListView(filtered, colors);
        },
        loading: () => _buildLoader(colors),
        error: (err, _) => _buildError(colors, () => ref.refresh(chatMembersProvider(selectedTeam.uuid))),
      );
    }
  }

  Widget _buildMembersListView(List<ChatMember> members, AppColors colors) {
    if (members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No team members found.',
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: members.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: colors.border),
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              radius: 18,
              child: Text(
                _getInitials(member.name),
                style: AppTextStyles.body14.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: AppTextStyles.body16.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet
              
              await context.push(
                '${AppRoutes.messages}/${AppRoutes.messagesChatDetail}',
                extra: TalkJSChatArgs(
                  conversationId: member.uuid,
                  topic: member.name,
                  isGroup: false,
                  otherUserId: member.uuid,
                  otherUserName: member.name,
                  otherUserEmail: member.email,
                ),
              );

              final activeTeam = ref.read(selectedTeamProvider);
              if (activeTeam != null) {
                ref.invalidate(chatChannelsProvider(activeTeam.uuid));
                ref.invalidate(chatMembersProvider(activeTeam.uuid));
              }
            },
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildLoader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppColors colors, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 18),
          const SizedBox(width: 8),
          Text(
            'Failed to load members.',
            style: AppTextStyles.body14.copyWith(color: colors.error),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: onRetry,
            color: colors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
