import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';
import '../providers/invoicing_provider.dart';

class InvoicingScreen extends ConsumerWidget {
  const InvoicingScreen({super.key});

  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF1A56DB);

  Color _statusColor(String s) =>
      s == 'Paid' ? _green : s == 'Pending' ? _amber : _red;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(invoicingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Invoicing'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (invoices) => _buildBody(invoices),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildBody(List<Invoice> invoices) {
    final total = invoices.fold(0.0, (sum, i) => sum + i.amount);
    final collected = invoices
        .where((i) => i.status == 'Paid')
        .fold(0.0, (sum, i) => sum + i.amount);
    final pending = invoices
        .where((i) => i.status == 'Pending')
        .fold(0.0, (sum, i) => sum + i.amount);
    final overdue = invoices
        .where((i) => i.status == 'Overdue')
        .fold(0.0, (sum, i) => sum + i.amount);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _invoiceStat('Total', '\$${total.toStringAsFixed(0)}', _blue),
              _vDivider(),
              _invoiceStat('Collected', '\$${collected.toStringAsFixed(0)}', _green),
              _vDivider(),
              _invoiceStat('Pending', '\$${pending.toStringAsFixed(0)}', _amber),
              _vDivider(),
              _invoiceStat('Overdue', '\$${overdue.toStringAsFixed(0)}', _red),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: invoices.map((inv) => _buildInvoiceCard(inv)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice inv) {
    return Container(
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
                Text(inv.description,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text('${inv.id} · ${inv.playerName}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${inv.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(inv.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(inv.status,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(inv.status))),
              ),
            ],
          ),
        ],
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
