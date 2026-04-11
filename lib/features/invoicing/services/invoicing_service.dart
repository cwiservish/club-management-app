import '../models/invoice.dart';

class InvoicingService {
  List<Invoice> getInvoices() => const [
        Invoice(id: 'INV-001', description: 'Spring Registration', playerName: 'Oliver Davis', amount: 150.00, status: 'Paid'),
        Invoice(id: 'INV-002', description: 'Spring Registration', playerName: 'James Miller', amount: 150.00, status: 'Paid'),
        Invoice(id: 'INV-003', description: 'Kit Fee', playerName: 'Noah Williams', amount: 65.00, status: 'Pending'),
        Invoice(id: 'INV-004', description: 'Tournament Fee', playerName: 'Henry Thomas', amount: 45.00, status: 'Overdue'),
        Invoice(id: 'INV-005', description: 'Spring Registration', playerName: 'Lucas Wilson', amount: 150.00, status: 'Paid'),
        Invoice(id: 'INV-006', description: 'Kit Fee', playerName: 'Aiden Taylor', amount: 65.00, status: 'Pending'),
      ];
}
