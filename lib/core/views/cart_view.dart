// // // lib/core/views/cart_view.dart
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:cached_network_image/cached_network_image.dart'; // For images
// // import 'package:shimmer/shimmer.dart'; // For loading shimmer
// //
// // import '../controllers/cart_controller.dart';
// // import '../models/cart_item_model.dart';
// // import '../constants/app_colors.dart';
// // import '../constants/app_constants.dart';
// // import '../widgets/custom_button.dart';
// // import '../widgets/loading_indicator.dart';
// // import '../routes/routes.dart'; // For navigation to checkout
// //
// // class CartScreen extends StatelessWidget {
// //   CartScreen({super.key});
// //
// //   final CartController _cartController = Get.find<CartController>();
// //
// //   // Helper to build image URL (ensure consistent with AppConstants)
// //   String _buildImageUrl(String? path) {
// //     return AppConstants.buildImageUrl(path);
// //   }
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Fetch cart items when the screen is initialized
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _cartController.fetchCartItems();
// //     });
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('My Cart'),
// //         backgroundColor: AppColors.background,
// //         foregroundColor: AppColors.textPrimary,
// //         elevation: 1,
// //       ),
// //       body: Obx(() {
// //         if (_cartController.isLoading.value && _cartController.cartItems.isEmpty) {
// //           return const LoadingIndicator(); // Show loading indicator initially
// //         }
// //         if (_cartController.errorMessage.value.isNotEmpty && _cartController.cartItems.isEmpty) {
// //           return Center(child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Text('Error: ${_cartController.errorMessage.value}', textAlign: TextAlign.center),
// //           ));
// //         }
// //         if (_cartController.cartItems.isEmpty) {
// //           return const Center(child: Text('Your cart is empty.'));
// //         }
// //
// //         // --- Cart Items List ---
// //         return ListView.builder(
// //           itemCount: _cartController.cartItems.length,
// //           padding: const EdgeInsets.symmetric(vertical: 8.0),
// //           itemBuilder: (context, index) {
// //             final item = _cartController.cartItems[index];
// //             return _buildCartItemCard(context, item);
// //           },
// //         );
// //       }),
// //       // --- Bottom Totals and Checkout Button ---
// //       bottomNavigationBar: _buildBottomBar(context),
// //     );
// //   }
// //
// //   // Widget to build each cart item card
// //   Widget _buildCartItemCard(BuildContext context, CartItemModel item) {
// //     final imageUrl = _buildImageUrl(item.mainImage);
// //
// //     return Card(
// //       margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
// //       elevation: 1.5,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // --- Image ---
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(6),
// //               child: CachedNetworkImage(
// //                 imageUrl: imageUrl,
// //                 width: 80, height: 80, fit: BoxFit.cover,
// //                 placeholder: (context, url) => Shimmer.fromColors(
// //                   baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
// //                   child: Container(color: Colors.white, width: 80, height: 80),
// //                 ),
// //                 errorWidget: (context, url, error) => Container(
// //                     width: 80, height: 80, color: Colors.grey[200],
// //                     child: const Icon(Icons.image_not_supported, color: Colors.grey)
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             // --- Details and Quantity ---
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
// //                   const SizedBox(height: 4),
// //                   if(item.options.isNotEmpty)
// //                     Text(item.options.entries.map((e) => e.value).join(', '), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
// //                   const SizedBox(height: 6),
// //                   Text('${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             // --- Quantity Selector & Remove ---
// //             Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: [
// //                 // Quantity Controls
// //                 Row(
// //                   children: [
// //                     IconButton(
// //                       icon: Icon(Icons.remove_circle_outline, size: 22, color: item.quantity > 1 ? AppColors.textPrimary : Colors.grey),
// //                       padding: EdgeInsets.zero, constraints: const BoxConstraints(), // Remove padding
// //                       onPressed: item.quantity > 1 ? () => _cartController.updateQuantity(item.cartId, item.quantity - 1) : null,
// //                     ),
// //                     const SizedBox(width: 4),
// //                     Text(item.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// //                     const SizedBox(width: 4),
// //                     IconButton(
// //                       icon: Icon(Icons.add_circle_outline, size: 22, color: AppColors.textPrimary),
// //                       padding: EdgeInsets.zero, constraints: const BoxConstraints(), // Remove padding
// //                       onPressed: () => _cartController.updateQuantity(item.cartId, item.quantity + 1), // TODO: Add stock check?
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 15), // Spacer
// //                 // Remove Button
// //                 IconButton(
// //                   icon: Icon(Icons.delete_outline, color: AppColors.error, size: 22),
// //                   padding: EdgeInsets.zero, constraints: const BoxConstraints(), // Remove padding
// //                   onPressed: () {
// //                     // Optional: Show confirmation dialog
// //                     _cartController.removeCartItem(item.cartId);
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Widget for the bottom bar showing totals and checkout button
// //   Widget _buildBottomBar(BuildContext context) {
// //     return Obx(() {
// //       // Return empty container if cart is empty to avoid layout issues
// //       if (_cartController.cartItems.isEmpty) {
// //         return const SizedBox.shrink();
// //       }
// //       return Container(
// //         height: 70, // Fixed height for the bottom bar
// //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //         decoration: BoxDecoration(
// //           color: AppColors.background,
// //           boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 0, blurRadius: 5, offset: const Offset(0, -2)) ],
// //           border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text('Subtotal:', style: Theme.of(context).textTheme.bodyMedium),
// //                 Text(
// //                   '${AppConstants.currencySymbol}${_cartController.cartSubtotal.value.toStringAsFixed(2)}',
// //                   style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(
// //               width: MediaQuery.of(context).size.width * 0.45, // Adjust width as needed
// //               child: CustomButton(
// //                 text: 'Checkout',
// //                 height: 45, // Slightly smaller button height
// //                 onPressed: () {
// //                   if (_cartController.cartItems.isNotEmpty) {
// //                     Get.toNamed(AppRoutes.checkout);
// //                   } else {
// //                     Get.snackbar('Empty Cart', 'Please add items to your cart before checking out.', snackPosition: SnackPosition.BOTTOM);
// //                   }
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     });
// //   }
// // }
//
// // lib/core/views/cart_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../controllers/cart_controller.dart';
// import '../models/cart_item_model.dart';
// import '../constants/app_colors.dart';
// import '../constants/app_constants.dart';
// import '../widgets/custom_button.dart';
// // import '../widgets/loading_indicator.dart'; // Make sure you have this or use CircularProgressIndicator
// import '../routes/routes.dart';
//
// class CartScreen extends StatelessWidget {
//   CartScreen({super.key});
//
//   final CartController _cartController = Get.find<CartController>();
//
//   // _buildImageUrl can be removed if CartItemModel.fullImageUrl is used directly
//   // String _buildImageUrl(String? path) {
//   //   return AppConstants.buildImageUrl(path);
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Fetch or re-fetch cart items when the screen is shown
//       // This is important if the user navigates back and forth
//       _cartController.fetchCartItems();
//     });
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Cart'),
//         backgroundColor: AppColors.background,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 1,
//       ),
//       body: Obx(() {
//         if (_cartController.isLoading.value && _cartController.cartItems.isEmpty) {
//           return const Center(child: CircularProgressIndicator()); // Or your custom LoadingIndicator
//         }
//         if (_cartController.errorMessage.value.isNotEmpty && _cartController.cartItems.isEmpty && !_cartController.isLoading.value) {
//           return Center(child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Error: ${_cartController.errorMessage.value}', textAlign: TextAlign.center, style: TextStyle(color: AppColors.error)),
//                 const SizedBox(height: 10),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.refresh),
//                   label: const Text("Retry"),
//                   onPressed: () => _cartController.fetchCartItems(),
//                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
//                 )
//               ],
//             ),
//           ));
//         }
//         if (_cartController.cartItems.isEmpty && !_cartController.isLoading.value) { // Check isLoading false here too
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
//                 const SizedBox(height: 16),
//                 Text('Your cart is empty.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
//                 const SizedBox(height: 20),
//                 CustomButton(text: "Start Shopping", onPressed: ()=> Get.offAllNamed(AppRoutes.home), width: 220)
//               ],
//             ),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: _cartController.cartItems.length,
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
//           itemBuilder: (context, index) {
//             final item = _cartController.cartItems[index];
//             return _buildCartItemCard(context, item);
//           },
//         );
//       }),
//       bottomNavigationBar: _buildBottomBar(context),
//     );
//   }
//
//   Widget _buildCartItemCard(BuildContext context, CartItemModel item) {
//     // Use item.fullImageUrl which internally uses AppConstants.buildImageUrl
//     final imageUrl = item.fullImageUrl;
//
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6.0),
//       elevation: 1.5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: CachedNetworkImage(
//                 imageUrl: imageUrl,
//                 width: 85, height: 85, fit: BoxFit.cover,
//                 placeholder: (context, url) => Shimmer.fromColors(
//                   baseColor: Colors.grey[200]!, highlightColor: Colors.grey[100]!,
//                   child: Container(color: Colors.white, width: 85, height: 85),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                     width: 85, height: 85, color: Colors.grey[100],
//                     child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 30)
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.productName,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
//                   ),
//                   const SizedBox(height: 4),
//                   if(item.options.isNotEmpty)
//                     Text(
//                       item.options.entries.map((e) => "${e.key}: ${e.value}").join(', '), // Nicer display for options
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 12),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
//                   ),
//                   if (item.printedPrice > item.price)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Text(
//                         '${AppConstants.currencySymbol}${item.printedPrice.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: AppColors.textSecondary.withOpacity(0.8),
//                           decoration: TextDecoration.lineThrough,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisSize: MainAxisSize.max, // Ensure Column takes full height available in Row
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.remove_circle_outline_rounded, size: 24, color: item.quantity > 1 ? AppColors.textPrimary : Colors.grey[400]),
//                       padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
//                       tooltip: 'Decrease quantity',
//                       onPressed: item.quantity > 1
//                           ? () => _cartController.updateQuantity(item.cartId, item.quantity - 1)
//                           : null,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                       child: Text(
//                         item.quantity.toString(),
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.add_circle_rounded, size: 24, color: AppColors.primary),
//                       padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
//                       tooltip: 'Increase quantity',
//                       onPressed: () => _cartController.updateQuantity(item.cartId, item.quantity + 1),
//                     ),
//                   ],
//                 ),
//                 const Spacer(), // Pushes delete button to the bottom
//                 IconButton(
//                   icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
//                   padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
//                   tooltip: 'Remove item',
//                   onPressed: () {
//                     Get.defaultDialog(
//                         title: "Remove Item",
//                         middleText: "Are you sure you want to remove '${item.productName}' from your cart?",
//                         textConfirm: "Remove",
//                         textCancel: "Cancel",
//                         confirmTextColor: Colors.white,
//                         buttonColor: AppColors.error,
//                         onConfirm: () {
//                           _cartController.removeCartItem(item.cartId);
//                           Get.back();
//                         }
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomBar(BuildContext context) {
//     return Obx(() {
//       if (_cartController.cartItems.isEmpty && !_cartController.isLoading.value) { // Also check isLoading
//         return const SizedBox.shrink();
//       }
//       return Container(
//         padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0), // Adjusted padding
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -3)) ],
//           border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Subtotal:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
//                 const SizedBox(height: 2),
//                 Obx(() => Text( // Ensure this text also reacts to cartSubtotal changes
//                   '${AppConstants.currencySymbol}${_cartController.cartSubtotal.value.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
//                 )),
//               ],
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.48, // Adjusted width
//               child: CustomButton(
//                 text: 'Proceed to Checkout',
//                 isLoading: _cartController.isLoading.value, // Button loading state
//                 height: 48, // Adjusted height
//                 onPressed: (_cartController.cartItems.isEmpty || _cartController.isLoading.value)
//                     ? null // Disable if cart is empty or loading
//                     : () {
//                   if (_cartController.cartItems.isNotEmpty) {
//                     Get.toNamed(AppRoutes.checkout);
//                   } else {
//                     Get.snackbar('Empty Cart', 'Please add items to your cart before checking out.', snackPosition: SnackPosition.BOTTOM);
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// lib/core/views/cart_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_item_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart'; // Assuming you have this
// import '../widgets/loading_indicator.dart'; // Uncomment if you have a custom one
import '../routes/routes.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController _cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch or re-fetch cart items when the screen is shown
      _cartController.fetchCartItems();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      backgroundColor: AppColors.background, // Added for consistency
      body: Obx(() {
        if (_cartController.isLoading.value && _cartController.cartItems.isEmpty) {
          return const Center(child: CircularProgressIndicator()); // Standard loading indicator
        }
        if (_cartController.errorMessage.value.isNotEmpty && _cartController.cartItems.isEmpty && !_cartController.isLoading.value) {
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${_cartController.errorMessage.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      onPressed: () => _cartController.fetchCartItems(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    )
                  ],
                ),
              )
          );
        }
        if (_cartController.cartItems.isEmpty && !_cartController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_shopping_cart_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.4)),
                const SizedBox(height: 20),
                Text('Your cart is empty.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text("Looks like you haven't added anything yet.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withOpacity(0.8))),
                const SizedBox(height: 25),
                CustomButton(
                  text: "Start Shopping",
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  width: 220,
                  height: 45,
                )
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _cartController.cartItems.length,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          itemBuilder: (context, index) {
            final item = _cartController.cartItems[index];
            return _buildCartItemCard(context, item);
          },
        );
      }),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemModel item) {
    final imageUrl = item.fullImageUrl; // Uses CartItemModel's getter
    const double imageHeight = 85.0; // Define consistent height for image and actions column

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Overall padding for the card content
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: imageHeight,
                height: imageHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(color: Colors.white, width: imageHeight, height: imageHeight),
                ),
                errorWidget: (context, url, error) => Container(
                  width: imageHeight,
                  height: imageHeight,
                  color: AppColors.inputBackground,
                  child: Icon(Icons.broken_image_outlined, color: AppColors.textSecondary.withOpacity(0.5), size: 30),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox( // Constrain height of the details section
                height: imageHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute content vertically
                  children: [
                    Column( // Group for name and options
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.25, fontSize: 14.5),
                        ),
                        const SizedBox(height: 3),
                        if (item.options.isNotEmpty)
                          Text(
                            item.options.entries.map((e) => e.value).join(' • '), // Show only values for brevity
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    Row( // Price and original price
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (item.printedPrice > item.price)
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              '${AppConstants.currencySymbol}${item.printedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary.withOpacity(0.7),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // This Column now has a fixed height due to the SizedBox wrapper
            SizedBox(
              height: imageHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quantity Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: item.quantity > 1
                            ? () => _cartController.updateQuantity(item.cartId, item.quantity - 1)
                            : null,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0), // Small padding for effective tap area
                          child: Icon(Icons.remove_circle_outline_rounded, size: 22, color: item.quantity > 1 ? AppColors.textPrimary : Colors.grey[400]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Text(
                          (item.quantity > 0 ? item.quantity : 1).toString(),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      InkWell(
                        onTap: () => _cartController.updateQuantity(item.cartId, (item.quantity > 0 ? item.quantity : 1) + 1),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.add_circle_rounded, size: 22, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  // Delete Button
                  InkWell(
                    onTap: () {
                      Get.defaultDialog(
                        title: "Remove Item",
                        titleStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        middleText: "Are you sure you want to remove '${item.productName}' from your cart?",
                        middleTextStyle: TextStyle(color: AppColors.textSecondary),
                        textConfirm: "Remove",
                        textCancel: "Cancel",
                        confirmTextColor: Colors.white,
                        buttonColor: AppColors.error,
                        cancelTextColor: AppColors.textSecondary,
                        radius: 10,
                        onConfirm: () {
                          _cartController.removeCartItem(item.cartId);
                          Get.back(); // Close dialog
                        },
                        onCancel: () {},
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0), // Small padding for effective tap area
                      child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      // Also check isLoading to prevent showing bottom bar briefly if cart becomes empty after loading
      if (_cartController.cartItems.isEmpty && !_cartController.isLoading.value) {
        return const SizedBox.shrink();
      }
      return Container(
        // Added padding for safe area (especially for iOS bottom notch)
        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0 + MediaQuery.of(context).padding.bottom * 0.5),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2)) // Softer shadow
          ],
          border: Border(top: BorderSide(color: AppColors.divider.withOpacity(0.7), width: 0.8)), // Softer border
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Subtotal:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Obx(() => Text( // Ensure this also reacts to changes
                    '${AppConstants.currencySymbol}${_cartController.cartSubtotal.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                  )),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Ensure button text fits
              child: CustomButton(
                text: 'Proceed to Checkout',
                isLoading: _cartController.isLoading.value, // Use general loading for the button
                height: 48,
                onPressed: (_cartController.cartItems.isEmpty || _cartController.isLoading.value)
                    ? null // Disable if cart is empty or controller is loading
                    : () {
                  if (_cartController.cartItems.isNotEmpty) {
                    Get.toNamed(AppRoutes.checkout);
                  } else {
                    // This case should ideally be prevented by the disabled state
                    Get.snackbar('Empty Cart', 'Your cart is empty.', snackPosition: SnackPosition.BOTTOM);
                  }
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}