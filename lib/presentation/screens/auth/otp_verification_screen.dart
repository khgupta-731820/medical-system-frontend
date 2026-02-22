import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/layouts/auth_layout.dart';

enum OtpVerificationType { email, phone }

class OtpVerificationScreen extends StatefulWidget {
  final OtpVerificationType type;
  final String identifier;
  final String? sessionToken;
  final String purpose;
  final Function(String otp, String? sessionToken)? onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.type,
    required this.identifier,
    this.sessionToken,
    this.purpose = 'registration',
    this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _countdown = AppConstants.otpResendTimeout;
  bool _canResend = false;
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    _sessionToken = widget.sessionToken;
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = AppConstants.otpResendTimeout;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _maskedIdentifier {
    if (widget.type == OtpVerificationType.email) {
      final parts = widget.identifier.split('@');
      if (parts.length != 2) return widget.identifier;
      final name = parts[0];
      final domain = parts[1];
      if (name.length <= 2) return widget.identifier;
      return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
    } else {
      final phone = widget.identifier;
      if (phone.length <= 4) return phone;
      return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;
    if (otp.length != AppConstants.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter ${AppConstants.otpLength}-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    Map<String, dynamic>? result;

    if (widget.type == OtpVerificationType.email) {
      result = await authProvider.verifyEmailOtp(
        email: widget.identifier,
        otp: otp,
        sessionToken: _sessionToken,
      );
    } else {
      result = await authProvider.verifyPhoneOtp(
        phone: widget.identifier,
        otp: otp,
        sessionToken: _sessionToken,
      );
    }

    if (!mounted) return;

    if (result != null) {
      final newSessionToken = result['session_token'] ?? result['sessionToken'];

      if (widget.onVerified != null) {
        widget.onVerified!(otp, newSessionToken);
      } else {
        Navigator.pop(context, {
          'otp': otp,
          'session_token': newSessionToken,
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Invalid OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    final authProvider = context.read<AuthProvider>();
    Map<String, dynamic>? result;

    if (widget.type == OtpVerificationType.email) {
      result = await authProvider.sendEmailOtp(
        email: widget.identifier,
        purpose: widget.purpose,
      );
    } else {
      result = await authProvider.sendPhoneOtp(
        phone: widget.identifier,
        purpose: widget.purpose,
        sessionToken: _sessionToken,
      );
    }

    if (!mounted) return;

    if (result != null) {
      _sessionToken = result['session_token'] ?? result['sessionToken'];
      _startCountdown();
      _otpController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StringConstants.otpSent),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to resend OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
    );

    return AuthLayout(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Icon(
                widget.type == OtpVerificationType.email
                    ? Icons.email_outlined
                    : Icons.phone_android,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              StringConstants.otpVerification,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              '${StringConstants.enterOtp}\n$_maskedIdentifier',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // OTP Input
            Pinput(
              controller: _otpController,
              focusNode: _focusNode,
              length: AppConstants.otpLength,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (_) => _verifyOtp(),
            ),
            const SizedBox(height: 32),

            // Verify Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return CustomButton(
                  onPressed: authProvider.isLoading ? null : _verifyOtp,
                  isLoading: authProvider.isLoading,
                  child: const Text('Verify OTP'),
                );
              },
            ),
            const SizedBox(height: 24),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  StringConstants.didntReceiveOtp,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 4),
                _canResend
                    ? Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return TextButton(
                      onPressed: authProvider.isLoading ? null : _resendOtp,
                      child: const Text(
                        StringConstants.resendOtp,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                )
                    : Text(
                  'Resend in ${_countdown}s',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}