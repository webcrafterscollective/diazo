// lib/main.dart
import 'dart:async'; // Import async for TimeoutException
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import 'core/constants/app_colors.dart';
import 'core/dependencies/main_di.dart';
import 'core/routes/routes.dart';
import 'core/controllers/auth_controller.dart';

// Optional: Create a Splash Screen Widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure build context is available and controllers are likely ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  // Future<void> _checkAuthStatus() async {
  //   print("Splash Screen: Starting auth check...");
  //   try {
  //     // Ensure AuthController is ready using Get.isRegistered and Get.find
  //     if (!Get.isRegistered<AuthController>()) {
  //       print("Splash Error: AuthController not registered yet.");
  //       // Fallback: Navigate to login or show error
  //       Get.offAllNamed(AppRoutes.login);
  //       return;
  //     }
  //     final authController = Get.find<AuthController>();
  //
  //     // --- Safer Waiting Logic ---
  //     const maxWaitDuration = Duration(seconds: 10); // Max time to wait
  //     final stopwatch = Stopwatch()..start();
  //
  //     // Wait while loading is true, but with a timeout
  //     while (authController.isLoading.value) {
  //       if (stopwatch.elapsed > maxWaitDuration) {
  //         print("Splash Warning: Timeout waiting for AuthController loading state.");
  //         break; // Exit loop after timeout
  //       }
  //       // Wait a short duration before checking again
  //       await Future.delayed(const Duration(milliseconds: 100));
  //     }
  //     stopwatch.stop();
  //     // --- End Safer Waiting Logic ---
  //
  //
  //     // Regardless of timeout or loading state finishing, navigate to Home
  //     print("Splash: Checks complete (or timed out). Navigating to home.");
  //     Get.offAllNamed(AppRoutes.home);
  //
  //   } catch (e) {
  //     print("Splash Error during auth check: $e");
  //     // Fallback in case of unexpected errors
  //     Get.offAllNamed(AppRoutes.login); // Navigate to login on error
  //   }
// Corrected method to await the auth check
  Future<void> _checkAuthStatus() async {
    // // <-- Renamed from _navigateAfterAuthCheck for consistency
    // print("Splash Screen: Starting auth check...");
    // String nextRoute = AppRoutes.login; // Default to login
    //
    // try {
    //   if (!Get.isRegistered<AuthController>()) {
    //     print("Splash Error: AuthController not registered yet.");
    //     Get.offAllNamed(AppRoutes.login);
    //     return;
    //   }
    //   final authController = Get.find<AuthController>();
    //
    //   // ***** Directly await the tryAutoLogin Future *****
    //   // This ensures the entire login check, including async parts, finishes
    //   await authController.tryAutoLogin();
    //   // ****************************************************
    //
    //   // Now check the login status AFTER tryAutoLogin has fully completed
    //   if (authController.isLoggedIn.value) {
    //     print("Splash: Auth check complete. User is logged in.");
    //     nextRoute = AppRoutes.home; // Navigate to home if logged in
    //   } else {
    //     print("Splash: Auth check complete. User is NOT logged in.");
    //     nextRoute = AppRoutes.login; // Navigate to login if not logged in
    //   }
    // } catch (e) {
    //   print("Splash Error during auth check: $e");
    //   nextRoute = AppRoutes.login; // Fallback to login on error
    // } finally {
    //   // Navigate to the determined route
    //   print("Splash: Navigating to $nextRoute");
    //   Get.offAllNamed(nextRoute);
    // }
    print("Splash Screen: Bypassing auth check and navigating directly to home.");
    String nextRoute = AppRoutes.home;
    print("Splash: Navigating to $nextRoute");
    Get.offAllNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text("Loading..."),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('AuthData');
  DependencyInjection.init(); // Initialize dependencies FIRST

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- REMOVED Get.put(AuthController()) here ---
    // DependencyInjection.init() should handle controller registration.
    // Putting it here again might cause issues if DI uses lazyPut.

    return GetMaterialApp(
      title: 'Diazoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ... your theme data ...
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      initialRoute: AppRoutes.splash, // Start with splash
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
        ...AppRoutes.routes
      ],
    );
  }
}
