import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.current.card,
      appBar: AppBar(
        backgroundColor: AppColors.current.headerBg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.current.textPrimary),
        title: Text(
          'Invoice',
          style: AppTextStyles.heading18.copyWith(color: AppColors.current.textPrimary),
        ),
      ),
      body: Center(
        child: Text(
          'Invoice Feature Coming Soon',
          style: AppTextStyles.body16.copyWith(color: AppColors.current.textSecondary),
        ),
      ),
    );
  }
}
