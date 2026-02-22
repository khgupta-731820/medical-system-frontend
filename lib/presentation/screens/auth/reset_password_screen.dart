import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/layouts/auth_layout.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.resetPassword(
      token: widget.token,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _resetSuccess = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to reset password'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBackButton: !_resetSuccess,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _resetSuccess ? _buildSuccessView() : _buildFormView(),
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
              Icons.lock_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            StringConstants.resetPassword,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Create a new strong password for your account.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            label: 'New Password',
            hint: 'Enter new password',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            validator: Validators.password,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter new password',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(),
            validator: (value) => Validators.confirmPassword(
              value,
              _passwordController.text,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Password Requirements
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password must contain:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRequirement('At least 8 characters'),
                _buildRequirement('One uppercase letter'),
                _buildRequirement('One lowercase letter'),
                _buildRequirement('One number'),
                _buildRequirement('One special character'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return CustomButton(
                onPressed: authProvider.isLoading ? null : _handleSubmit,
                isLoading: authProvider.isLoading,
                child: const Text('Reset Password'),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
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
          'Password Reset!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Message
        Text(
          'Your password has been successfully reset.\nYou can now login with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),

        // Login Button
        CustomButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.login,
                  (route) => false,
            );
          },
          child: const Text('Login Now'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}