import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';
import '../services/invoicing_service.dart';

final invoicingServiceProvider = Provider<InvoicingService>((ref) => InvoicingService());

final invoicingProvider = FutureProvider<List<Invoice>>((ref) async {
  return ref.read(invoicingServiceProvider).getInvoices();
});
