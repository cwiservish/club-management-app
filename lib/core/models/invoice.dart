import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../enums/invoice_status.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String description;
  final String playerName;
  final double amount;
  final InvoiceStatus status;
  final DateTime dueDate;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.description,
    required this.playerName,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  Color get statusColor {
    switch (status) {
      case InvoiceStatus.paid: return AppColors.success;
      case InvoiceStatus.pending: return AppColors.warning;
      case InvoiceStatus.overdue: return AppColors.error;
    }
  }

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.paid: return 'Paid';
      case InvoiceStatus.pending: return 'Pending';
      case InvoiceStatus.overdue: return 'Overdue';
    }
  }
}
