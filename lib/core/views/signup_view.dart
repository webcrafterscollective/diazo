import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../constants/app_colors.dart';

class SignUpScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Form Key for Validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SignUpScreen({super.key});

  void _handleSignUp() {
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      _authController.register(
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      ).then((_) {
        // Check if registration was successful (e.g., no error message)
        // Navigate only if successful (or let controller handle it)
        if (_authController.errorMessage.value.isEmpty) {
          Get.snackbar('Success', 'Registration successful! Please log in.', snackPosition: SnackPosition.BOTTOM);
          Get.offAllNamed(AppRoutes.login); // Navigate to login after registration
        }
      });
    } else {
      Get.snackbar(
        'Error',
        'Please fix the errors in the form.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form( // Wrap in Form
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset( 'assets/logo.png', height: 80 ),
                  const SizedBox(height: 40),

                  Text( 'Create Account', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary) ),
                  const SizedBox(height: 8),
                  Text( 'Fill in the details to sign up', textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary) ),
                  const SizedBox(height: 32),

                  // Email
                  CustomTextField(
                      controller: _emailController, hintText: 'Email Address', keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next, prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                        return null;
                      }
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CustomTextField(
                      controller: _phoneController, hintText: 'Phone Number', keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next, prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Phone number is required';
                        // Add more specific phone validation if needed
                        return null;
                      }
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                      controller: _passwordController, hintText: 'Password', isPasswordField: true, obscureText: true,
                      textInputAction: TextInputAction.next, prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      }
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController, hintText: 'Confirm Password', isPasswordField: true, obscureText: true,
                    textInputAction: TextInputAction.done, prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    onSubmitted: (_) => _handleSignUp(),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up button
                  Obx(() => CustomButton(
                    text: 'Sign Up',
                    isLoading: _authController.isLoading.value,
                    onPressed: _handleSignUp,
                    height: 48,
                  )),
                  const SizedBox(height: 16),

                  // Error message
                  Obx(() {
                    if (_authController.errorMessage.value.isNotEmpty) {
                      return Text( _authController.errorMessage.value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13));
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 24),

                  // Go to login
                  Row( // Use Row for better alignment
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: Text("Log In", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}