// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart'; // Ensure this path is correct

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed to VoidCallback? to allow null
  final bool isLoading;
  final bool isOutlined;
  final double height;
  final double? width; // Optional width parameter
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loaderColor; // Optional color for the loader
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final BorderSide? outlineBorderSide; // For customizing outlined button's border

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.height = 48.0, // Standard height
    this.width, // Default is null, button will expand or be sized by parent
    this.backgroundColor,
    this.textColor,
    this.loaderColor,
    this.borderRadius = 8.0, // Standard border radius
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.outlineBorderSide,
  });

  @override
  Widget build(BuildContext context) {
    // Determine effective colors and styles
    final ThemeData theme = Theme.of(context);
    final bool isDisabled = isLoading || onPressed == null;

    // Default text style if not provided
    final TextStyle effectiveTextStyle = textStyle ??
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    // Button content: either text or loader
    Widget buttonChild = isLoading
        ? SizedBox(
      height: effectiveTextStyle.fontSize! * 1.5, // Scale loader size with text
      width: effectiveTextStyle.fontSize! * 1.5,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          loaderColor ??
              (isOutlined
                  ? (textColor ?? AppColors.primary)
                  : (textColor ?? Colors.white)),
        ),
      ),
    )
        : Text(
      text,
      style: effectiveTextStyle.copyWith(
        color: isDisabled
            ? (isOutlined
            ? AppColors.textSecondary.withOpacity(0.5)
            : Colors.white.withOpacity(0.7))
            : (isOutlined
            ? (textColor ?? AppColors.primary)
            : (textColor ?? Colors.white)),
      ),
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            side: outlineBorderSide ??
                BorderSide(
                  color: isDisabled
                      ? AppColors.border.withOpacity(0.5)
                      : (backgroundColor ?? AppColors.primary),
                  width: 1.5,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            backgroundColor: Colors.transparent, // Outlined buttons are typically transparent
            disabledForegroundColor: AppColors.textSecondary.withOpacity(0.38),
            disabledBackgroundColor: Colors.transparent,
          ),
          child: buttonChild,
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: isDisabled
                ? (backgroundColor ?? AppColors.primary).withOpacity(0.5)
                : (backgroundColor ?? AppColors.primary),
            foregroundColor: isDisabled
                ? (textColor ?? Colors.white).withOpacity(0.7)
                : (textColor ?? Colors.white),
            disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withOpacity(0.38),
            disabledForegroundColor: (textColor ?? Colors.white).withOpacity(0.38),
            elevation: isLoading ? 0 : 2, // No elevation when loading or flat style
            shadowColor: AppColors.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonChild,
        ),
      );
    }
  }
}