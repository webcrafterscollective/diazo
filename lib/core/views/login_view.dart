import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../constants/app_colors.dart'; // Import AppColors

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _phoneController = TextEditingController(); // Removed as not used in login

  // Use GlobalKey for Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  void _handleLogin() {
    // Validate the form first
    if (_formKey.currentState?.validate() ?? false) {
      _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigation to home is handled within AuthController upon successful login
      // Get.toNamed(AppRoutes.home); // Remove this direct navigation
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
      backgroundColor: AppColors.background, // Use background color
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0), // Increased padding
            child: Form( // Wrap content in a Form
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  // Logo
                  Image.asset( 'assets/logo.png', height: 80 ), // Ensure asset exists
                  const SizedBox(height: 40),

                  // Welcome Text
                  Text( 'Welcome Back!', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary) ),
                  const SizedBox(height: 8),
                  Text( 'Login to continue', style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary) ),
                  const SizedBox(height: 32),

                  // Email Input
                  CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined, // Add prefix icon
                      validator: (value) { // Add validation
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                        return null;
                      }
                  ),
                  const SizedBox(height: 16), // Increased spacing

                  // Password Input
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    textInputAction: TextInputAction.done,
                    isPasswordField: true,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline, // Add prefix icon
                    validator: (value) { // Add validation
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    onSubmitted: (_) => _handleLogin(), // Allow submitting from keyboard
                  ),
                  const SizedBox(height: 12), // Space before forgot password

                  // Forgot Password (Optional)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () { /* TODO: Implement Forgot Password */ Get.snackbar('Info', 'Forgot Password Tapped', snackPosition: SnackPosition.BOTTOM); },
                      child: Text('Forgot Password?', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 24), // Space before button

                  // Login Button
                  Obx(() => CustomButton(
                    text: 'Log In',
                    isLoading: _authController.isLoading.value,
                    onPressed: _handleLogin, // Use the handler with validation
                    height: 48, // Standard button height
                  )),
                  const SizedBox(height: 16),

                  // Error message
                  Obx(() {
                    if (_authController.errorMessage.value.isNotEmpty) {
                      return Text(
                        _authController.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle( color: Colors.red, fontSize: 13 ),
                      );
                    }
                    return const SizedBox.shrink(); // Return empty space if no error
                  }),
                  const SizedBox(height: 24), // Space before Sign Up link

                  // Sign Up link
                  Row( // Use Row for better alignment
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.signup), // Use offAllNamed to clear stack potentially
                        child: Text("Sign Up", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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