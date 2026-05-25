import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/home_provider.dart';
import '../widgets/home_card.dart';
import '../widgets/home_empty_state.dart';

// ─── Home Screen ──────────────────────────────────────────────────────────────
// Pure display — all data and business logic come from homeProvider.

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final viewModels = ref.watch(homeProvider).viewModels;

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                child: viewModels.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: HomeEmptyState(),
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:          const EdgeInsets.symmetric(vertical: 10),
                        itemCount:        viewModels.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => HomeCard(
                          viewModel: viewModels[i],
                          onEventDetails: () =>
                              context.push(AppRoutes.eventDetails(viewModels[i].id)),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
