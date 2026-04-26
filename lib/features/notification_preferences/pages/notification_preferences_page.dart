import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
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
    final settings = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(title: 'Notification preferences'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Email Notifications ──────────────────────────────────
                    const NotificationSectionLabel(title: 'Email notifications'),
                    const SizedBox(height: 12),
                    NotificationCard(
                      children: [
                        const NotificationEmailRow(
                          label: 'Schedule reminders',
                          value: 'Games and Events',
                          showDivider: true,
                        ),
                        const NotificationEmailRow(
                          label: 'Player availability',
                          value: 'Games and Events',
                          showDivider: false,
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
                          onChanged: notifier.setMobileAlerts,
                          showDivider: true,
                        ),
                        NotificationToggleRow(
                          label: 'Live! score updates',
                          value: settings.liveScore,
                          onChanged: notifier.setLiveScore,
                          showDivider: true,
                        ),
                        NotificationToggleRow(
                          label: 'Live! game/event messages',
                          value: settings.liveMessages,
                          onChanged: notifier.setLiveMessages,
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
          ],
        ),
      ),
    );
  }
}
