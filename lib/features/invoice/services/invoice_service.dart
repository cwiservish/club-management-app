import '../models/invoice.dart';

class InvoiceService {
  List<Invoice> getInvoices() {
    return const [
      Invoice(id: 'INV-2026-042', recipient: 'Kinsley Weston',  amount: '\$150.00', date: 'Mar 15, 2026', status: InvoiceStatus.paid),
      Invoice(id: 'INV-2026-043', recipient: 'Kinley Kirkes',   amount: '\$150.00', date: 'Mar 15, 2026', status: InvoiceStatus.pending),
      Invoice(id: 'INV-2026-044', recipient: 'Mila Chaisson',   amount: '\$150.00', date: 'Mar 12, 2026', status: InvoiceStatus.overdue),
      Invoice(id: 'INV-2026-045', recipient: 'Scarlett Garling', amount: '\$75.00',  date: 'Mar 10, 2026', status: InvoiceStatus.paid),
      Invoice(id: 'INV-2026-046', recipient: 'Nene Randolph',   amount: '\$150.00', date: 'Mar 01, 2026', status: InvoiceStatus.paid),
    ];
  }
}
