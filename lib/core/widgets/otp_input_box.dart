import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class OtpInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final FocusNode? previousFocusNode;

  const OtpInputBox({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.previousFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counter: const SizedBox.shrink(),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1 && nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          } else if (value.isEmpty && previousFocusNode != null) {
            FocusScope.of(context).requestFocus(previousFocusNode);
          }
        },
      ),
    );
  }
}