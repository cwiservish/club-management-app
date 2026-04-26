import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';

final _invoiceServiceProvider = Provider<InvoiceService>(
      (_) => InvoiceService(),
);

final invoicesProvider = Provider.autoDispose<List<Invoice>>((ref) {
  return ref.watch(_invoiceServiceProvider).getInvoices();
});

// ✅ Extend Notifier<String>, NOT AutoDisposeNotifier
class ActiveInvoiceTabNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setTab(String tab) => state = tab;
}

final activeInvoiceTabProvider =
NotifierProvider.autoDispose<ActiveInvoiceTabNotifier, String>(
  ActiveInvoiceTabNotifier.new,
);

final filteredInvoicesProvider = Provider.autoDispose<List<Invoice>>((ref) {
  final all = ref.watch(invoicesProvider);
  final tab = ref.watch(activeInvoiceTabProvider);
  if (tab == 'All') return all;
  return all.where((inv) => inv.status.name == tab.toLowerCase()).toList();
});