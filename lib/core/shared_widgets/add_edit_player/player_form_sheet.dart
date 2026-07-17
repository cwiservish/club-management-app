import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/player_form_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../features/roster/models/player_positions_models.dart';
import 'player_form_provider.dart';

class PlayerFormSheet extends ConsumerStatefulWidget {
  final PlayerFormConfig config;

  const PlayerFormSheet({super.key, required this.config});

  @override
  ConsumerState<PlayerFormSheet> createState() => _PlayerFormSheetState();
}

class _PlayerFormSheetState extends ConsumerState<PlayerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _jerseyController;
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _jerseyFocus = FocusNode();

  void _onFocusChange() {
    if (_firstNameFocus.hasFocus || _lastNameFocus.hasFocus || _jerseyFocus.hasFocus) {
      ref.read(playerFormProvider.notifier).closeDropdown();
    }
  }

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    _firstNameController = TextEditingController(text: config.initialFirstName);
    _lastNameController = TextEditingController(text: config.initialLastName);
    _jerseyController = TextEditingController(text: config.initialJersey);
    _firstNameFocus.addListener(_onFocusChange);
    _lastNameFocus.addListener(_onFocusChange);
    _jerseyFocus.addListener(_onFocusChange);
    // init after first frame so provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerFormProvider.notifier).init(config);
    });
  }

  @override
  void dispose() {
    _firstNameFocus.removeListener(_onFocusChange);
    _lastNameFocus.removeListener(_onFocusChange);
    _jerseyFocus.removeListener(_onFocusChange);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jerseyController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _jerseyFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(playerFormProvider.notifier);
    final formState = ref.read(playerFormProvider);

    if (formState.selectedPosition == null) {
      _showError('Please select a player position');
      return;
    }

    try {
      final message = await notifier.save(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        jersey: _jerseyController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.current.success,
          ),
        );
        Navigator.pop(context);
      }
    } on PlayerFormSaveException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.current.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Error', style: AppTextStyles.heading16.copyWith(color: AppColors.current.textPrimary)),
        content: Text(message, style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: AppTextStyles.body14.copyWith(
                color: AppColors.current.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final colors = AppColors.current;
    final formState = ref.watch(playerFormProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ──
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
                  child: Text(
                    config.isEditMode ? 'Edit Player' : 'New Player',
                    style: AppTextStyles.heading16.copyWith(color: colors.textPrimary),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: formState.isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                        )
                      : GestureDetector(
                          onTap: config.isEditable ? _save : null,
                          child: Text(
                            'Save',
                            style: AppTextStyles.body15.copyWith(
                              color: config.isEditable ? colors.primary : colors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── Body ──
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
                  // Avatar
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(playerFormProvider.notifier).closeDropdown();
                        ref.read(playerFormProvider.notifier).pickImage();
                      },
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
                        child: _buildAvatarContent(colors, formState),
                      ),
                    ),
                  ),

                  // Form fields
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
                          focusNode: _firstNameFocus,
                          enabled: config.isEditable,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'First name is required';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(val.trim())) {
                              return 'First name must contain only letters, numbers, and spaces';
                            }
                            return null;
                          },
                        ),
                        Divider(height: 1, color: colors.border),
                        _buildFormField(
                          label: 'LAST NAME',
                          placeholder: 'e.g. Cole',
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          enabled: config.isEditable,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(val.trim())) {
                              return 'Last name must contain only letters, numbers, and spaces';
                            }
                            return null;
                          },
                        ),
                        Divider(height: 1, color: colors.border),
                        _buildFormField(
                          label: 'JERSEY NUMBER',
                          placeholder: 'e.g. 8',
                          controller: _jerseyController,
                          focusNode: _jerseyFocus,
                          enabled: config.isEditable,
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Jersey number is required' : null,
                        ),
                        Divider(height: 1, color: colors.border),
                        _buildDropdownField(colors, formState, config.isEditable),
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

  Widget _buildAvatarContent(AppColors colors, PlayerFormState formState) {
    if (formState.pickedImageBytes != null) {
      return Image.memory(formState.pickedImageBytes!, fit: BoxFit.cover);
    }
    final photoUrl = widget.config.existingPhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsOrIcon(colors),
      );
    }
    return _buildInitialsOrIcon(colors);
  }

  Widget _buildInitialsOrIcon(AppColors colors) {
    final initials = widget.config.initials;
    if (initials.isNotEmpty) {
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: colors.primary,
          ),
        ),
      );
    }
    return Icon(Icons.camera_alt, color: colors.textSecondary, size: 32);
  }

  Widget _buildFormField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    bool enabled = true,
  }) {
    final colors = AppColors.current;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => focusNode?.requestFocus(),
      child: Padding(
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
              focusNode: focusNode,
              keyboardType: keyboardType,
              enabled: enabled,
              validator: validator,
              inputFormatters: inputFormatters,
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
                errorStyle: TextStyle(color: colors.error, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(AppColors colors, PlayerFormState formState, bool isEditable) {
    return FormField<PlayerPositionModel>(
      initialValue: formState.selectedPosition,
      validator: (_) => formState.selectedPosition == null ? 'Position is required' : null,
      builder: (FormFieldState<PlayerPositionModel> fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: formState.isLoadingPositions || !isEditable
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      ref.read(playerFormProvider.notifier).toggleDropdown();
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
                            'POSITION',
                            style: AppTextStyles.label11.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formState.selectedPosition?.label ?? 'Select position...',
                            style: AppTextStyles.body16.copyWith(
                              color: formState.selectedPosition == null
                                  ? colors.textSecondary.withValues(alpha: 0.5)
                                  : colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (formState.isLoadingPositions)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                      )
                    else if (isEditable)
                      AnimatedRotation(
                        turns: formState.isDropdownOpen ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ),
            if (formState.positionsError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formState.positionsError!,
                        style: TextStyle(color: colors.error, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(playerFormProvider.notifier).retryFetchPositions(),
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
            if (formState.isDropdownOpen && formState.positions.isNotEmpty && isEditable) ...[
              Divider(height: 1, color: colors.border),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                color: colors.background.withValues(alpha: 0.03),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: formState.positions.length,
                    itemBuilder: (context, index) {
                      final pos = formState.positions[index];
                      final isSelected = formState.selectedPosition == pos;
                      return InkWell(
                        onTap: () {
                          ref.read(playerFormProvider.notifier).selectPosition(pos);
                          fieldState.didChange(pos);
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
                                Icon(Icons.check, color: colors.primary, size: 20),
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
