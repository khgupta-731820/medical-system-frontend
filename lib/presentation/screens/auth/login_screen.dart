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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate based on user role
      final role = authProvider.user?.role ?? '';
      String route;

      switch (role.toLowerCase()) {
        case 'patient':
          route = Routes.patientDashboard;
          break;
        case 'doctor':
        case 'lab_tech':
        case 'pharmacist':
          route = Routes.staffDashboard;
          break;
        case 'admin':
          route = Routes.adminDashboard;
          break;
        default:
          route = Routes.login;
      }

      Navigator.pushReplacementNamed(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                StringConstants.login,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Welcome back! Please login to continue.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                label: StringConstants.password,
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscurePassword,
                validator: Validators.required,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
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
              const SizedBox(height: 8),

              // Remember Me & Forgot Password Row
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Text(StringConstants.rememberMe),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.forgotPassword);
                    },
                    child: const Text(
                      StringConstants.forgotPassword,
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    isLoading: authProvider.isLoading,
                    child: const Text(StringConstants.login),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Register Button
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.registerChoice);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create New Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}