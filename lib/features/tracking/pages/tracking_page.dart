import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/tracking_provider.dart';
import '../widgets/tracking_widgets.dart';

class TrackingPage extends ConsumerWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final assignments = ref.watch(trackingAssignmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(title: 'Tracking'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(19),
                child: TrackingAssignmentList(assignments: assignments),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
