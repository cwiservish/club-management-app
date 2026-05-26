import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/notification_preferences_provider.dart';
import '../widgets/notification_preferences_widgets.dart';

class NotificationPreferencesPage extends ConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final state = ref.watch(notificationPreferencesProvider);
    final settings = state.settings;
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            const SubHeader(title: 'Notification preferences'),
            Expanded(
              child: state.isLoading && settings.notificationSettingId == 0
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.current.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: notifier.refresh,
                      color: AppColors.current.primary,
                      backgroundColor: AppColors.current.card,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(19),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.errorMessage != null) ...[
                              _buildErrorCard(state.errorMessage!),
                              const SizedBox(height: 16),
                            ],

                            // ── Email Notifications ──────────────────────────────────
                            const NotificationSectionLabel(title: 'Email notifications'),
                            const SizedBox(height: 12),
                            NotificationCard(
                              children: [
                                NotificationEmailRow(
                                  label: 'Schedule reminders',
                                  value: settings.emailScheduleRemindersLabel,
                                  showDivider: true,
                                  onTap: () => _showEmailPreferencePicker(
                                    context,
                                    title: 'Schedule reminders',
                                    currentValue: settings.emailScheduleReminders,
                                    onChanged: (val) => _handleSaveAction(
                                      context,
                                      () => notifier.setEmailScheduleReminders(val),
                                    ),
                                  ),
                                ),
                                NotificationEmailRow(
                                  label: 'Player availability',
                                  value: settings.emailPlayerAvailabilityLabel,
                                  showDivider: false,
                                  onTap: () => _showEmailPreferencePicker(
                                    context,
                                    title: 'Player availability',
                                    currentValue: settings.emailPlayerAvailability,
                                    onChanged: (val) => _handleSaveAction(
                                      context,
                                      () => notifier.setEmailPlayerAvailability(val),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── Mobile Notifications ─────────────────────────────────
                            const NotificationSectionLabel(title: 'Mobile notifications'),
                            const SizedBox(height: 12),
                            NotificationCard(
                              children: [
                                NotificationToggleRow(
                                  label: 'Alerts and schedule updates',
                                  value: settings.mobileAlerts,
                                  onChanged: (val) => _handleSaveAction(
                                    context,
                                    () => notifier.setMobileAlerts(val),
                                  ),
                                  showDivider: true,
                                ),
                                NotificationToggleRow(
                                  label: 'Live! score updates',
                                  value: settings.liveScore,
                                  onChanged: (val) => _handleSaveAction(
                                    context,
                                    () => notifier.setLiveScore(val),
                                  ),
                                  showDivider: true,
                                ),
                                NotificationToggleRow(
                                  label: 'Live! game/event messages',
                                  value: settings.liveMessages,
                                  onChanged: (val) => _handleSaveAction(
                                    context,
                                    () => notifier.setLiveMessages(val),
                                  ),
                                  showDivider: false,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── Info Box ─────────────────────────────────────────────
                            const NotificationInfoBox(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveAction(
    BuildContext context,
    Future<dynamic> Function() action,
  ) async {
    try {
      final response = await action();
      if (!context.mounted) return;

      final success = response.success == true;
      final message = response.message?.toString() ?? 'Notification settings saved successfully.';

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: success ? Colors.green.shade600 : AppColors.current.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.current.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.current.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.current.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailPreferencePicker(
    BuildContext context, {
    required String title,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.current.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  title,
                  style: AppTextStyles.heading16.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(
                color: AppColors.current.border.withValues(alpha: 0.3),
                height: 1,
              ),
              _buildPickerOption(
                ctx,
                label: 'Games and events',
                value: 3,
                isSelected: currentValue == 3,
                onTap: onChanged,
              ),
              _buildPickerOption(
                ctx,
                label: 'Games',
                value: 1,
                isSelected: currentValue == 1,
                onTap: onChanged,
              ),
              _buildPickerOption(
                ctx,
                label: 'Events',
                value: 2,
                isSelected: currentValue == 2,
                onTap: onChanged,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerOption(
    BuildContext context, {
    required String label,
    required int value,
    required bool isSelected,
    required ValueChanged<int> onTap,
  }) {
    return ListTile(
      title: Text(
        label,
        style: AppTextStyles.body15.copyWith(
          color: isSelected ? AppColors.current.primary : AppColors.current.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.current.primary, size: 20)
          : null,
      onTap: () {
        Navigator.of(context).pop();
        onTap(value);
      },
    );
  }
}
