import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/home_provider.dart';
import '../widgets/home_card.dart';

// ─── Home Screen ──────────────────────────────────────────────────────────────
// Pure display — all data and business logic come from homeProvider.

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModels  = ref.watch(homeProvider).viewModels;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: viewModels.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding:          const EdgeInsets.symmetric(vertical: 10),
                      itemCount:        viewModels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => HomeCard(
                        viewModel: viewModels[i],
                        onEventDetails: () {},
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size:  48,
            color: colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
