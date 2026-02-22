import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const AuthLayout({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showBackButton
          ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      )
          : null,
      body: SafeArea(child: child),
    );
  }
}