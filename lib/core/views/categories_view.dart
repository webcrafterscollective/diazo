// lib/core/views/categories_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/product_controller.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart'; // Ensure AppConstants is imported
import '../widgets/loading_indicator.dart';
import '../widgets/sub_category_card.dart'; // Re-use the card

// Define or import the helper function (ensure only one definition)
String buildImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.trim().isEmpty) { return ''; }
  if (imagePath.trim().startsWith('http')) { return imagePath.trim(); }
  final baseUrl = AppConstants.baseUrl.endsWith('/') ? AppConstants.baseUrl : '${AppConstants.baseUrl}/';
  final pathSegment = "manual_storage/"; // Adjust if needed
  final path = imagePath.trim().startsWith('/') ? imagePath.substring(1) : imagePath.trim();
  final fullUrl = '$baseUrl$pathSegment$path';
  return fullUrl;
}


class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({super.key});

  final ProductController _productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    // Ensure categories are fetched if needed (controller now does this on init)
    // _productController.fetchCategoriesAndInitialSelection();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.white, // Clean background
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5, // Subtle elevation
      ),
      backgroundColor: AppColors.background, // Main background
      body: Obx(() {
        // --- Initial Loading Shimmer ---
        if (_productController.isLoading.value && _productController.categories.isEmpty) {
          return _buildInitialShimmer();
        }
        // --- Error State ---
        if (_productController.errorMessage.value.isNotEmpty && _productController.categories.isEmpty) {
          return Center(child: Text('Error: ${_productController.errorMessage.value}'));
        }
        // --- Empty State ---
        if (_productController.categories.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        // --- Main Two-Panel Layout ---
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeftCategoryListPanel(), // Left panel for main categories
            _buildRightSubCategoryGridPanel(), // Right panel for sub-categories
          ],
        );
      }
      ),
    );
  }

  // --- Left Panel: Main Category List ---
  Widget _buildLeftCategoryListPanel() {
    return Container(
      width: 110, // Adjust width as needed
      decoration: BoxDecoration(
        color: Colors.grey[100], // Slightly different background for the list
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView.builder(
        itemCount: _productController.categories.length,
        itemBuilder: (context, index) {
          final category = _productController.categories[index];
          final bool isSelected = _productController.currentViewCategoryId.value == category.id;
          final imageUrl = buildImageUrl(category.img);

          return Material( // Provides ink splash effect
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            child: InkWell(
              onTap: () {
                _productController.selectCategoryForView(category.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3.0
                      ),
                      // Optional bottom border
                      // bottom: BorderSide(color: AppColors.divider, width: 0.5)
                    )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28, // Adjust size
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 56, height: 56, fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Icon(Icons.error_outline, size: 20, color: Colors.grey[600]),
                        )
                            : Icon(Icons.category_outlined, size: 24, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Right Panel: Sub-Category Grid ---
  Widget _buildRightSubCategoryGridPanel() {
    return Expanded( // Takes remaining space
      child: Obx(() {
        // --- Loading State for Sub-Categories ---
        if (_productController.isLoadingSubCategories.value) {
          // Show loading indicator specifically for this panel
          return const Center(child: LoadingIndicator(size: 30));
        }

        // --- Empty or "Select Category" State ---
        if (_productController.currentViewCategoryId.value == -1) {
          return const Center(child: Text("Select a category", style: TextStyle(color: Colors.grey)));
        }
        if (_productController.subCategories.isEmpty) {
          return const Center(child: Text("No sub-categories found.", style: TextStyle(color: Colors.grey)));
        }

        // --- Display Sub-Category Grid ---
        return GridView.builder(
          padding: const EdgeInsets.all(12.0), // Padding around the grid
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.85, // Adjust aspect ratio for SubCategoryCard
          ),
          itemCount: _productController.subCategories.length,
          itemBuilder: (context, index) {
            final subCategory = _productController.subCategories[index];
            return SubCategoryCard( // Use the existing card widget
              subCategory: subCategory,
              onTap: () {
                if (kDebugMode) { print('Tapped Sub-Category: ${subCategory.name}'); }
                // TODO: Navigate to product list screen, passing category and sub-category IDs
                // Get.toNamed('/product-list', arguments: {
                //   'categoryId': _productController.currentViewCategoryId.value,
                //   'subCategoryId': subCategory.id
                // });
              },
            );
          },
        );
      }
      ),
    );
  }

  // --- Initial Loading Shimmer ---
  Widget _buildInitialShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer for Left Panel
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
          child: Container(
            width: 110, color: Colors.white, // Simulate background
          ),
        ),
        // Shimmer for Right Panel (Placeholder)
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
            child: GridView.builder( // Simulate grid shimmer
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0, childAspectRatio: 0.85,
              ),
              itemCount: 9, // Show 9 shimmer cards
              itemBuilder: (_, __) => Card(
                elevation: 0, // No elevation for shimmer
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                color: Colors.white, // Shimmer element color
              ),
            ),
          ),
        ),
      ],
    );
  }
}