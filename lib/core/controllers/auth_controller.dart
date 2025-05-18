// lib/core/controllers/auth_controller.dart
import 'package:flutter/material.dart'; // Import material for Get.defaultDialog
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../utils/app_exceptions.dart';
import '../services/storage_service.dart';
import '../routes/routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs; // Start as true for the initial check
  final RxString errorMessage = ''.obs;
  final RxBool isOtpVerified = false.obs; // Keep for OTP flow if needed

  // --- Flag to prevent multiple auto-login attempts ---
  final RxBool _autoLoginAttempted = false.obs;
  // -----------------------------------------------------

  // isLoggedIn is computed based on user state and token presence
  RxBool get isLoggedIn => RxBool(user.value != null && _storageService.getTokenSync() != null);

  @override
  void onInit() {
    super.onInit();
    // Automatically try to log in when the controller is initialized
    tryAutoLogin();
  }

  /// Tries to load user data and token from storage on app start.
  /// Uses a flag (_autoLoginAttempted) to ensure it only runs once.
  Future<void> tryAutoLogin() async {
    // --- Check if already attempted ---
    if (_autoLoginAttempted.value) {
      print("AuthController.tryAutoLogin(): Already attempted, skipping.");
      // Ensure isLoading is false if we skip, otherwise UI might hang
      if (isLoading.value) isLoading.value = false;
      return; // Don't run again if already attempted
    }
    _autoLoginAttempted.value = true; // Mark as attempted immediately
    // ----------------------------------

    // Ensure isLoading is true at the start of the first attempt
    if (!isLoading.value) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    print("AuthController.tryAutoLogin(): Starting first attempt..."); // Log start

    try {
      final storedToken = _storageService.getTokenSync();
      print("AuthController.tryAutoLogin(): Token found = ${storedToken != null}"); // Log token status

      print("AuthController.tryAutoLogin(): Calling _storageService.getUser()...");
      final storedUser = await _storageService.getUser().catchError((e) {
        // This catchError is specifically for errors within getUser()
        print("AuthController.tryAutoLogin(): Error caught from _storageService.getUser(): $e");
        // Consider if clearing all storage is correct here, might hide token issues
        _storageService.clearAll();
        return null; // Return null if getUser fails
      });
      // Log the result AFTER await completes
      print("AuthController.tryAutoLogin(): _storageService.getUser() returned: ${storedUser?.email ?? 'null'}");

      // Check token and user data validity
      if (storedToken != null && storedUser != null) {
        print("AuthController.tryAutoLogin(): Token and User valid. Setting user.value.");
        user.value = storedUser; // Set user state
        print("AuthController.tryAutoLogin(): user.value set to: ${user.value?.email}");
      } else {
        print("AuthController.tryAutoLogin(): Token or User invalid/null. Setting user.value = null.");
        user.value = null; // Explicitly set user to null if login check fails
        // Don't clear storage just because token/user is missing, only on specific errors or logout
      }
    } catch (e) {
      // Catch any other unexpected errors during the process
      print("AuthController.tryAutoLogin(): Generic catch block error: $e");
      user.value = null; // Ensure logout state on generic error
      await _storageService.clearAll(); // Clear storage on generic error
    } finally {
      // This runs regardless of success or failure
      isLoading.value = false; // Ensure loading is false
      print("AuthController.tryAutoLogin(): Finished. isLoading: ${isLoading.value}, user.value: ${user.value?.email ?? 'null'}"); // Log final state
    }
  }


  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Attempting manual login for $email...");

      final userData = await _authRepository.login(
        email: email,
        password: password,
      );

      if (userData.token != null) {
        print("Manual login API call successful for ${userData.email}, token received.");
        user.value = userData; // Set user state
        await _storageService.saveToken(userData.token!); // Save token
        await _storageService.saveUser(userData); // Save user data
        print("Manual login: Token and user data saved.");
        _autoLoginAttempted.value = true; // Mark auto-login as done after manual login too
        Get.offAllNamed(AppRoutes.home); // Navigate to home after successful login
      } else {
        // This case might be redundant if API provider throws exception on failure
        print("Login failed: Token was null in response.");
        errorMessage.value = 'Login failed: Could not retrieve token.';
      }
    } on AppException catch (e) {
      print('Login Error: ${e.message}');
      errorMessage.value = e.message ?? 'An unknown error occurred.';
      user.value = null; // Ensure user state is null on login failure
      await _storageService.clearAll(); // Clear storage on login failure
    } catch (e) {
      print('Login Error: $e');
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      user.value = null; // Ensure user state is null on login failure
      await _storageService.clearAll(); // Clear storage on login failure
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Attempting registration for $email...");

      // API call
      await _authRepository.register( // Assuming it returns void or we don't need the user data immediately
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      print("Registration request successful for $email.");
      Get.snackbar('Success', 'Registration successful! Please log in.', snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(AppRoutes.login); // Navigate to login

    } on AppException catch (e) {
      print('Registration Error: ${e.message}');
      errorMessage.value = e.message ?? 'An unknown error occurred.';
    } catch (e) {
      print('Registration Error: $e');
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> logout() async {
    print("Logging out user: ${user.value?.email}");
    user.value = null; // Clear user state immediately
    await _storageService.clearAll(); // Clear token and user data from storage
    _autoLoginAttempted.value = false; // Reset flag for next login
    isLoading.value = false; // Ensure loading is false after logout
    print("Storage cleared, state reset after logout.");
    // Navigate to login screen after logout
    Get.offAllNamed(AppRoutes.login);
  }

  // --- OTP Methods ---
  Future<void> getOtp({required String email, String? phone}) async {
    // ... (implementation as before) ...
    try {
      isLoading.value = true; // Set loading true
      errorMessage.value = '';

      await _authRepository.getOtp(
        email: email,
        phone: phone,
      );
      // Show success message maybe?
      Get.snackbar('OTP Sent', 'OTP requested successfully for $email.', snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to request OTP: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Ensure loading is false
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    // ... (implementation as before) ...
    try {
      isLoading.value = true; // Set loading true
      errorMessage.value = '';
      isOtpVerified.value = false; // Reset verification state

      final result = await _authRepository.verifyOtp(
        email: email,
        otp: otp,
      );

      isOtpVerified.value = result; // Used for OTP screen logic

      if (isOtpVerified.value) {
        print("OTP Verified for $email. Proceed to login or next step.");
        // Decide next step after OTP verification - usually login
        Get.snackbar('Success', 'OTP Verified! Please log in.', snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed(AppRoutes.login); // Example: Go to login after OTP
      } else {
        errorMessage.value = 'Invalid OTP'; // Provide feedback
        Get.snackbar('Error', 'Invalid OTP entered.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isOtpVerified.value = false;
      Get.snackbar('Error', 'OTP verification failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Ensure loading is false
    }
  }

  // --- Account Deletion ---
  Future<void> deleteAccount({
    required String userId,
    required String password,
    String? description,
  }) async {
    // ... (implementation as before) ...
    try {
      isLoading.value = true; // Set loading true
      errorMessage.value = '';

      await _authRepository.deleteAccount(
        userId: userId,
        password: password,
        description: description,
      );

      // Clear user data after account deletion
      await logout(); // Perform full logout after deletion

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Account deletion failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Ensure loading is false
    }
  }

  /// Checks if the user is logged in. If not, shows a popup and navigates to login on confirm.
  /// Returns true if logged in, false otherwise.
  bool requireLogin({String actionName = 'perform this action'}) {
    // Ensure check is done only if controller is initialized
    if (!Get.isRegistered<AuthController>() || !Get.isRegistered<StorageService>()) {
      print("Warning: requireLogin called before AuthController/StorageService ready.");
      // Optionally show a generic error or attempt safe navigation
      Get.snackbar('Error', 'Please wait a moment and try again.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Check the reactive getter directly
    if (!isLoggedIn.value) {
      print("requireLogin: isLoggedIn is false. Showing dialog.");
      Get.defaultDialog(
        title: "Login Required",
        middleText: "You need to log in to $actionName.",
        textConfirm: "Login",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary, // Use consistent color
        cancelTextColor: AppColors.textSecondary,
        onConfirm: () {
          Get.back(); // Close the dialog
          Get.toNamed(AppRoutes.login); // Navigate to Login
        },
        radius: 8,
      );
      return false; // Not logged in
    }
    print("requireLogin: isLoggedIn is true. Proceeding.");
    return true; // Logged in
  }
}