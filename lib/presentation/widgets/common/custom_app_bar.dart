import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}