// lib/core/views/wishlist_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; //
import 'package:shimmer/shimmer.dart'; //

import '../controllers/wishlist_controller.dart'; //
import '../controllers/product_controller.dart'; // To navigate to product details
import '../controllers/auth_controller.dart';   // For auth check if needed for remove actions
import '../models/product_model.dart';        // Model for wishlist items
import '../constants/app_colors.dart'; //
import '../constants/app_constants.dart'; //
import '../widgets/loading_indicator.dart'; //
import '../routes/routes.dart'; //

class WishlistScreen extends StatelessWidget { //
  WishlistScreen({super.key});

  final WishlistController _wishlistController = Get.find<WishlistController>(); //
  final ProductController _productController = Get.find<ProductController>(); //
  final AuthController _authController = Get.find<AuthController>(); //

  // Helper to build image URL
  String _buildImageUrl(String? path) {
    return AppConstants.buildImageUrl(path); //
  }

  @override
  Widget build(BuildContext context) {
    // Fetch/Refresh wishlist items when the screen is initialized or becomes visible
    // WishlistController already fetches in onInit, but you might want to refresh
    // E.g., using WidgetsBinding.instance.addPostFrameCallback or GetView's onReady
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wishlistController.fetchWishlist(); // Refresh when view loads
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: AppColors.background, //
        foregroundColor: AppColors.textPrimary, //
        elevation: 1,
      ),
      body: Obx(() { //
        if (_wishlistController.isLoading.value && _wishlistController.wishlistItems.isEmpty) { //
          return const LoadingIndicator(); //
        }
        if (_wishlistController.errorMessage.value.isNotEmpty && _wishlistController.wishlistItems.isEmpty) { //
          return Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${_wishlistController.errorMessage.value}', textAlign: TextAlign.center), //
          ));
        }
        if (_wishlistController.wishlistItems.isEmpty) { //
          return const Center(child: Text('Your wishlist is empty.'));
        }

        // Display Wishlist Items
        return ListView.builder(
          itemCount: _wishlistController.wishlistItems.length, //
          padding: const EdgeInsets.all(8.0), // Add padding around the list
          itemBuilder: (context, index) {
            final product = _wishlistController.wishlistItems[index]; //
            return _buildWishlistItemCard(context, product);
          },
        );
      }),
    );
  }

  // Widget to build each wishlist item card
  Widget _buildWishlistItemCard(BuildContext context, ProductModel product) { //
    final imageUrl = _buildImageUrl(product.mainImage); //

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          // Navigate to product details
          _productController.selectProduct(product); // Select the product first
          Get.toNamed(AppRoutes.productDetails, arguments: product); // Pass product data
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage( //
                  imageUrl: imageUrl,
                  width: 70, height: 70, fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors( //
                    baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white, width: 70, height: 70),
                  ),
                  errorWidget: (context, url, error) => Container(
                      width: 70, height: 70, color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey)
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), //
                    const SizedBox(height: 6),
                    Text('${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), //
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Remove Button (Uses filled heart as it's already in wishlist)
              // Obx(() => IconButton( // Wrap IconButton with Obx to react to loading state
              //   icon: _wishlistController.isUpdating.value
              //       ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) // Show spinner when updating
              //       : Icon(Icons.favorite, color: AppColors.primary), // Show filled heart
              //   tooltip: 'Remove from Wishlist',
              //   onPressed: _wishlistController.isUpdating.value ? null : () { // Disable button when updating
              //     // Requires removeWishlist implementation in controller/repo
              //     // TODO: Determine correct variantId if needed by remove API
              //     int variantId = product.variantId ?? product.id; // <<--- Placeholder: NEEDS CORRECT LOGIC
              //     _wishlistController.removeFromWishlist(product.id, variantId); //
              //   },
              // )),
            ],
          ),
        ),
      ),
    );
  }
}