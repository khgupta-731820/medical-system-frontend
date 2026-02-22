import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/layouts/auth_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset link'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            StringConstants.forgotPassword,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: StringConstants.email,
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 24),

          // Submit Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return CustomButton(
                onPressed: authProvider.isLoading ? null : _handleSubmit,
                isLoading: authProvider.isLoading,
                child: const Text('Send Reset Link'),
              );
            },
          ),
          const SizedBox(height: 24),

          // Back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Remember your password? ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 50,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'We\'ve sent a password reset link to\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Instructions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Check your email and click the reset link to create a new password.',
                      style: TextStyle(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Back to login
        CustomButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
        const SizedBox(height: 16),

        // Resend
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text(
            'Didn\'t receive the email? Resend',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}