import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/shared_widgets/textfield/app_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(forgotPasswordProvider.notifier).forgotPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final authState = ref.watch(forgotPasswordProvider);

    ref.listen<AsyncValue<void>>(forgotPasswordProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password reset email sent. Please check your inbox.'),
              backgroundColor: colors.success,
            ),
          );
          context.pop();
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: colors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Forgot Password?',
                style: AppTextStyles.heading22.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your email address and we will send you instructions to reset your password.',
                style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 40),
              Text(
                'Email Address',
                style: AppTextStyles.heading14,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                autofocus: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: authState.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.white),
                        ),
                      )
                    : Text(
                        'Send Reset Link',
                        style: AppTextStyles.heading16.copyWith(color: colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
