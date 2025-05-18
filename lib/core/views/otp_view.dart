import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_input_box.dart';
import '../constants/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final List<TextEditingController> _otpControllers = List.generate(
      4,
          (index) => TextEditingController()
  );
  final List<FocusNode> _focusNodes = List.generate(
      4,
          (index) => FocusNode()
  );

  late Timer _timer;
  int _remainingTime = 120; // 2 minutes in seconds
  String _email = '';

  @override
  void initState() {
    super.initState();
    // Get email from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    _email = args['email'] ?? '';

    // Start countdown timer
    startTimer();

    // Setup focus listeners for OTP input
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _otpControllers[i].text.isNotEmpty) {
          _otpControllers[i].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _otpControllers[i].text.length
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_remainingTime == 0) {
          timer.cancel();
        } else {
          setState(() {
            _remainingTime--;
          });
        }
      },
    );
  }

  void resendOtp() {
    // Reset timer
    setState(() {
      _remainingTime = 120;
    });
    startTimer();

    // Request new OTP
    _authController.getOtp(email: _email);

    // Show message
    Get.snackbar(
      'OTP Sent',
      'A new OTP has been sent to your email',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  String formatTime(int seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  void verifyOtp() {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      Get.snackbar(
        'Error',
        'Please enter the complete 4-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _authController.verifyOtp(email: _email, otp: otp).then((_) {
      if (_authController.isOtpVerified.value) {
        // OTP verified successfully
        Get.offAllNamed('/home');
      } else {
        // OTP verification failed
        Get.snackbar(
          'Error',
          _authController.errorMessage.value.isNotEmpty
              ? _authController.errorMessage.value
              : 'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'Enter OTP Code',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'A 4 Digit OTP Code has been Sent',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input Field Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                        (index) => OtpInputBox(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      nextFocusNode: index < 3 ? _focusNodes[index + 1] : null,
                      previousFocusNode: index > 0 ? _focusNodes[index - 1] : null,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Verify Button
                Obx(() => CustomButton(
                  text: 'Next',
                  isLoading: _authController.isLoading.value,
                  onPressed: verifyOtp,
                )),

                const SizedBox(height: 24),

                // Timer text
                Text(
                  'This code will expire in ${formatTime(_remainingTime)}s',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 16),

                // Resend Code Button
                TextButton(
                  onPressed: _remainingTime > 0 ? null : resendOtp,
                  child: Text(
                    'Resend Code',
                    style: TextStyle(
                      color: _remainingTime > 0 ? Colors.grey : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}