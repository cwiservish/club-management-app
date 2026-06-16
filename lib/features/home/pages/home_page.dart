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
import '../widgets/sponsor_banner.dart';

// ─── Home Screen ──────────────────────────────────────────────────────────────
// Pure display — all data and business logic come from homeProvider.

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final homeState = ref.watch(homeProvider);
    final viewModels = homeState.viewModels;
    final isLoading = homeState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                child: isLoading && viewModels.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.current.primary,
                        ),
                      )
                    : viewModels.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                SponsorBanner(imageUrl: homeState.bannerImageUrl),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  child: const Center(
                                    child: HomeEmptyState(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            // Index 0 is always the sponsor banner
                            itemCount: viewModels.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                return SponsorBanner(imageUrl: homeState.bannerImageUrl);
                              }
                              final vm = viewModels[i - 1];
                              return HomeCard(
                                viewModel: vm,
                                onEventDetails: () {
                                  final event = homeState.events.firstWhere((e) => e.id == vm.id);
                                  context.push('${AppRoutes.eventDetails(vm.id)}?from=home', extra: event);
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
