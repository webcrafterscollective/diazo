// lib/core/middlewares/auth_middleware.dart
import 'package:flutter/material.dart'; // Needed for RouteSettings
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/storage_service.dart'; // Import StorageService
import '../routes/routes.dart'; // Import routes

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1; // Higher priority means it runs earlier

  @override
  RouteSettings? redirect(String? route) {
    // Ensure AuthController and StorageService are registered
    if (!Get.isRegistered<AuthController>() || !Get.isRegistered<StorageService>()) {
      print("AuthMiddleware Error: AuthController or StorageService not registered yet. Redirecting to login.");
      // Avoid redirect loops during initial loading if possible,
      // but redirecting to login is safer if controllers aren't ready.
      // Check if already trying to access login to prevent loop
      if (route == AppRoutes.login) {
        return null;
      }
      return const RouteSettings(name: AppRoutes.login);
    }

    final AuthController authController = Get.find<AuthController>();
    final StorageService storageService = Get.find<StorageService>(); // Get instance

    // --- Add Debug Prints Here ---
    print("--- AuthMiddleware Check for route: $route ---");
    // Use try-catch for safety, though Get.find should work if registered check passed
    try {
      print("Middleware Check: isLoading.value = ${authController.isLoading.value}"); // Check loading state too
      print("Middleware Check: isLoggedIn.value = ${authController.isLoggedIn.value}");
      // Safely access user data and token
      final userJson = authController.user.value?.toJson() ?? 'null';
      final token = storageService.getTokenSync() ?? 'null';
      print("Middleware Check: user.value = $userJson");
      print("Middleware Check: getTokenSync() = $token");
    } catch (e) {
      print("AuthMiddleware Error getting state: $e");
      // Decide fallback behavior, e.g., redirect to login
      if (route != AppRoutes.login) {
        return const RouteSettings(name: AppRoutes.login);
      }
      return null;
    }
    // --- End Debug Prints ---

    // Redirect to login if the user is not logged in
    // Use the reactive getter isLoggedIn.value
    if (!authController.isLoggedIn.value) {
      print("AuthMiddleware: User not logged in (isLoggedIn=false). Redirecting to ${AppRoutes.login} from $route"); // Log redirection
      // Prevent redirecting to login if already trying to access login/signup/otp
      if (route == AppRoutes.login || route == AppRoutes.signup || route == AppRoutes.otp) {
        print("AuthMiddleware: Already on auth page ($route), allowing.");
        return null; // Allow access to auth pages
      }
      return const RouteSettings(name: AppRoutes.login);
    }

    // If user is logged in but trying to access login/signup/otp, redirect to home
    if (authController.isLoggedIn.value && (route == AppRoutes.login || route == AppRoutes.signup || route == AppRoutes.otp)) {
      print("AuthMiddleware: User is logged in. Redirecting to ${AppRoutes.home} from $route");
      return const RouteSettings(name: AppRoutes.home);
    }


    // User is authenticated and accessing an allowed route, proceed.
    print("AuthMiddleware: User logged in. Allowing access to $route");
    return null; // Returning null means allow the navigation
  }

// --- Other middleware methods (optional) ---
// You can uncomment these if needed for more detailed lifecycle logging

// @override
// GetPage? onPageCalled(GetPage? page) {
//   // Called before bindings and controller creation
//   print("AuthMiddleware: onPageCalled for ${page?.name}");
//   return page;
// }

// @override
// List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
//   // Called before bindings are created
//   print("AuthMiddleware: onBindingsStart");
//   return bindings;
// }

// @override
// GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
//    // Called before GetPage.page function is called
//   print("AuthMiddleware: onPageBuildStart for page: ${page.toString()}"); // Example: print page info
//   return page;
// }

// @override
// Widget onPageBuilt(Widget page) {
//   // Called after page is built but before rendering
//   print("AuthMiddleware: onPageBuilt");
//   return page;
// }

// @override
// void onPageDispose() {
//   // Called when page bindings and controllers are disposed
//   print("AuthMiddleware: onPageDispose");
// }
}