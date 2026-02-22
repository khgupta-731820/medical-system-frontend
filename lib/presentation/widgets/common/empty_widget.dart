import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import 'custom_button.dart';

class EmptyWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRefresh;
  final VoidCallback? onButtonPressed;

  const EmptyWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.buttonText,
    this.onRefresh,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (onRefresh != null)
              CustomButton(
                onPressed: onRefresh,
                outlined: true,
                width: 150,
                height: 44,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 12),
              CustomButton(
                onPressed: onButtonPressed,
                width: 200,
                height: 44,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}