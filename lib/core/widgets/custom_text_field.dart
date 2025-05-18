import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool isPasswordField;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction textInputAction;
  final IconData? prefixIcon; // <-- Add prefixIcon parameter

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.isPasswordField = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.contentPadding,
    this.prefixIcon, // <-- Add to constructor
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define focused border color for reuse
    final focusedBorderColor = AppColors.primary;
    final defaultBorderColor = AppColors.border;
    final errorBorderColor = AppColors.error;
    final iconColor = AppColors.textSecondary.withOpacity(0.7); // Color for icons

    return TextFormField(
      textInputAction: widget.textInputAction,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      focusNode: widget.focusNode,
      onChanged: (value) {
        // No need for setState here unless reacting directly to changes visually
        if (widget.onChanged != null) widget.onChanged!(value);
      },
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16, // Keep consistent font size
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        // --- Add Prefix Icon ---
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: iconColor, size: 20) // Adjust size if needed
            : null,
        // --- End Add ---
        // --- Suffix Icons --- (Keep password toggle logic)
        suffixIcon: widget.isPasswordField
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: iconColor,
            size: 20, // Adjust size
          ),
          onPressed: _toggleVisibility,
        )
            : null, // No suffix icon if not a password field
        // --- End Suffix Icons ---
        filled: true,
        fillColor: AppColors.inputBackground, // Use consistent background
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Standard padding
        // --- Border Styles ---
        border: OutlineInputBorder( // Default border
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: defaultBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder( // Border when enabled but not focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: defaultBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder( // Border when focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5), // Highlight focus
        ),
        errorBorder: OutlineInputBorder( // Border when error exists
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorBorderColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder( // Border when error exists and focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorBorderColor, width: 1.5),
        ),
      ),
    );
  }
}