import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../widgets/invoice_widgets.dart';

class InvoiceFormPage extends StatelessWidget {
  const InvoiceFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: 'New Invoice',
              leftLabel: 'Cancel',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Form card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.current.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.current.border.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          InvoiceFormField(
                            label: 'Recipient Name',
                            placeholder: 'e.g. John Doe',
                            required: true,
                          ),
                          SizedBox(height: 16),
                          InvoiceFormField(
                            label: 'Email Address',
                            placeholder: 'john@example.com',
                            required: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),
                          InvoiceFormField(
                            label: 'Phone Number',
                            placeholder: '(555) 123-4567',
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 16),
                          InvoiceFormField(
                            label: 'Amount',
                            placeholder: '0.00',
                            required: true,
                            keyboardType: TextInputType.number,
                            prefix: '\$',
                          ),
                          SizedBox(height: 16),
                          InvoiceFormField(
                            label: 'Description',
                            placeholder: 'What is this invoice for?',
                            required: true,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Send button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.current.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Send Invoice',
                          style: AppTextStyles.heading16.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
