import 'package:flutter/material.dart';

class InvoicingScreen extends StatelessWidget {
  const InvoicingScreen({super.key});

  static const _invoices = [
    ('INV-001', 'Spring Registration', 'Oliver Davis', 150.00, 'Paid'),
    ('INV-002', 'Spring Registration', 'James Miller', 150.00, 'Paid'),
    ('INV-003', 'Kit Fee', 'Noah Williams', 65.00, 'Pending'),
    ('INV-004', 'Tournament Fee', 'Henry Thomas', 45.00, 'Overdue'),
    ('INV-005', 'Spring Registration', 'Lucas Wilson', 150.00, 'Paid'),
    ('INV-006', 'Kit Fee', 'Aiden Taylor', 65.00, 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF10B981);
    const amber = Color(0xFFF59E0B);
    const red = Color(0xFFEF4444);

    Color statusColor(String s) =>
        s == 'Paid' ? green : s == 'Pending' ? amber : red;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Invoicing'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _invoiceStat('Total', '\$625', const Color(0xFF1A56DB)),
                _vDivider(),
                _invoiceStat('Collected', '\$450', green),
                _vDivider(),
                _invoiceStat('Pending', '\$130', amber),
                _vDivider(),
                _invoiceStat('Overdue', '\$45', red),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _invoices
                  .map((inv) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inv.$2,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827))),
                                  const SizedBox(height: 3),
                                  Text('${inv.$1} · ${inv.$3}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${inv.$4.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor(inv.$5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(inv.$5,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor(inv.$5))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _invoiceStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: const Color(0xFFF3F4F6));
}
