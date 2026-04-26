import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/invoice_provider.dart';
import '../widgets/invoice_tab_bar.dart';
import '../widgets/invoice_widgets.dart';

class InvoicePage extends ConsumerWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final activeTab = ref.watch(activeInvoiceTabProvider);
    final invoices = ref.watch(filteredInvoicesProvider);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: 'Invoicing',
              rightWidget: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(Icons.add,
                      size: 26, color: AppColors.current.primary),
                  onPressed: () => {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
            InvoiceTabBar(
              activeTab: activeTab,
              onTabChanged: (tab) =>
                  ref.read(activeInvoiceTabProvider.notifier).state = tab,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(19),
                child: Column(
                  children: [
                    const InvoiceSearchField(),
                    const SizedBox(height: 16),
                    InvoiceList(invoices: invoices),
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
