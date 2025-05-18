import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart'; // Needed for more user details if separate
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../routes/routes.dart'; // For navigation and logout

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>(); // Use this if needed

  // Helper to build image URL
  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return ''; // Handle null or empty path
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = AppConstants.baseUrl.endsWith('/') ? AppConstants.baseUrl : '${AppConstants.baseUrl}/';
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl$path';
  }


  @override
  Widget build(BuildContext context) {
    // Use Obx for reactive updates based on AuthController's user state
    return Obx(() {
      final user = _authController.user.value; // Get user data reactively

      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 1.0,
        ),
        backgroundColor: AppColors.background,
        body: user == null
            ? const Center(child: Text("Not logged in")) // Show message if somehow accessed while logged out
            : ListView( // Use ListView for scrollable options
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          children: [
            // --- User Info Header ---
            _buildUserInfoSection(user, context),
            const SizedBox(height: 20),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 10),

            // --- Menu Options ---
            _buildProfileOption(
              context: context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Get.snackbar('Info', 'Edit Profile screen not implemented.', snackPosition: SnackPosition.BOTTOM);
                // TODO: Navigate to Edit Profile Screen
                // Get.toNamed(AppRoutes.editProfile);
              },
            ),
            _buildProfileOption(
              context: context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Get.snackbar('Info', 'Change Password screen not implemented.', snackPosition: SnackPosition.BOTTOM);
                // TODO: Navigate to Change Password Screen
                // Get.toNamed(AppRoutes.changePassword);
              },
            ),
            _buildProfileOption(
              context: context,
              icon: Icons.location_on_outlined,
              title: 'Manage Addresses',
              onTap: () {
                Get.snackbar('Info', 'Manage Addresses screen not implemented.', snackPosition: SnackPosition.BOTTOM);
                // TODO: Navigate to Addresses Screen
                // Get.toNamed(AppRoutes.addresses);
              },
            ),
            _buildProfileOption(
              context: context,
              icon: Icons.list_alt_outlined,
              title: 'Order History',
              onTap: () {
                // Assuming you have an orders route defined
                if (AppRoutes.routes.any((r) => r.name == AppRoutes.orders)) {
                  Get.toNamed(AppRoutes.orders);
                } else {
                  Get.snackbar('Info', 'Orders screen not implemented yet.', snackPosition: SnackPosition.BOTTOM);
                }
              },
            ),
            _buildProfileOption(
              context: context,
              icon: Icons.favorite_border,
              title: 'My Wishlist',
              onTap: () {
                // Assuming you have a wishlist route defined
                if (AppRoutes.routes.any((r) => r.name == AppRoutes.wishlist)) {
                  Get.toNamed(AppRoutes.wishlist);
                } else {
                  Get.snackbar('Info', 'Wishlist screen not implemented yet.', snackPosition: SnackPosition.BOTTOM);
                }
              },
            ),
            _buildProfileOption(
              context: context,
              icon: Icons.list_alt_outlined,
              title: 'Order History',
              onTap: () {
                Get.toNamed(AppRoutes.orders); // Navigate to orders list
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildProfileOption(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              isLogout: true, // Indicate special styling/action
              onTap: () {
                // Show confirmation dialog before logging out
                Get.defaultDialog(
                  title: "Logout",
                  middleText: "Are you sure you want to logout?",
                  textConfirm: "Logout",
                  textCancel: "Cancel",
                  confirmTextColor: Colors.white,
                  buttonColor: AppColors.error, // Use error color for logout button
                  cancelTextColor: AppColors.textSecondary,
                  onConfirm: () {
                    _authController.logout(); // Call the logout method
                  },
                  radius: 8, // Dialog border radius
                );
              },
            ),
          ],
        ),
      );
    }
    );
  }

  // Helper widget for the user info section
  Widget _buildUserInfoSection(UserModel user, BuildContext context) {
    final imageUrl = _buildImageUrl(user.image);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1), // Placeholder background
            backgroundImage: imageUrl.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null, // Use CachedNetworkImageProvider
            child: imageUrl.isEmpty ? Icon(Icons.person, size: 40, color: AppColors.primary) : null, // Placeholder Icon
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'User Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (user.email != null)
                  Text(user.email!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                if (user.phone != null)
                  Text(user.phone!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Optional: Edit Icon Button
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            onPressed: () {
              Get.snackbar('Info', 'Edit Profile screen not implemented.', snackPosition: SnackPosition.BOTTOM);
              // TODO: Navigate to Edit Profile Screen
            },
          )
        ],
      ),
    );
  }

  // Helper widget for profile menu options
  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isLogout ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0), // Adjust padding
    );
  }
}