enum InvoiceStatus { paid, pending, overdue }

class Invoice {
  final String id;
  final String recipient;
  final String amount;
  final String date;
  final InvoiceStatus status;

  const Invoice({
    required this.id,
    required this.recipient,
    required this.amount,
    required this.date,
    required this.status,
  });
}
