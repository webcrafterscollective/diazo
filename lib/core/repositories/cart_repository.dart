// // // lib/core/repositories/cart_repository.dart
// // import 'package:get/get.dart';
// //
// // import '../constants/app_constants.dart';
// // import '../models/cart_item_model.dart'; // Ensure this is used if getCartItems is fully implemented
// // import '../network/api_provider.dart';
// // import '../utils/app_exceptions.dart';
// //
// // class CartRepository {
// //   final ApiProvider _apiProvider = Get.find<ApiProvider>();
// //
// //   // Fetch items currently in the cart
// //   Future<List<CartItemModel>> getCartItems() async {
// //     try {
// //       // Assumes POST request based on Postman, change if needed
// //       final response = await _apiProvider.post(AppConstants.cartEndpoint);
// //       // *** IMPORTANT: Adapt the key ('data', 'cart', 'items', etc.) based on your actual /cart API response ***
// //       final List<dynamic> data = response['data'] ?? []; // Example key 'data'
// //
// //       List<CartItemModel> cartItems = [];
// //       for (var item in data) {
// //         if (item is Map<String, dynamic>) {
// //           // Assuming CartItemModel.fromJson exists and is correctly implemented
// //           // Example: cartItems.add(CartItemModel.fromJson(item));
// //         }
// //       }
// //       return cartItems;
// //     } on AppException catch (e) {
// //       print("Error fetching cart items: ${e.message}");
// //       rethrow;
// //     } catch (e) {
// //       print("Unexpected error fetching cart items: $e");
// //       throw FetchDataException("Could not fetch cart. Please try again.");
// //     }
// //   }
// //
// //   // MODIFIED: Changed return type to Map<String, dynamic>? to pass API response
// //   Future<Map<String, dynamic>?> addToCart({
// //     required int productId,
// //     required int variantId,
// //     required int quantity,
// //   }) async {
// //     final fields = {
// //       'product_id': productId.toString(),
// //       'variant_id': variantId.toString(),
// //       'quantity': quantity.toString(),
// //     };
// //     try {
// //       final response = await _apiProvider.post(
// //         AppConstants.addToCartEndpoint,
// //         fields: fields,
// //       );
// //       // ApiProvider._processResponse should return a Map<String, dynamic> on success
// //       // or throw an AppException on failure.
// //       return response as Map<String, dynamic>?;
// //     } on AppException catch (e) {
// //       print("Error adding to cart (AppException in CartRepository): ${e.message}");
// //       rethrow; // Controller will catch this
// //     } catch (e) {
// //       print("Unexpected error adding to cart (CartRepository): $e");
// //       // Convert to a known exception type or handle as a generic failure
// //       throw FetchDataException("An unexpected error occurred while adding item to cart.");
// //     }
// //   }
// //
// // // --- OPTIONAL: Add Update/Remove Functions (if endpoints exist) ---
// // // Future<bool> updateCartItem(int cartId, int quantity) async { ... }
// // // Future<bool> removeCartItem(int cartId) async { ... }
// // }
//
// // lib/core/repositories/cart_repository.dart
// import 'package:get/get.dart';
//
// import '../constants/app_constants.dart';
// import '../models/cart_item_model.dart';
// import '../network/api_provider.dart';
// import '../utils/app_exceptions.dart';
//
// class CartRepository {
//   final ApiProvider _apiProvider = Get.find<ApiProvider>();
//
//   Future<List<CartItemModel>> getCartItems() async {
//     try {
//       final response = await _apiProvider.post(AppConstants.cartEndpoint); // Assuming POST
//
//       // --- MODIFICATION ---
//       // Try to get items from 'cart_items', 'cart', or assume response is the list itself
//       List<dynamic>? cartData;
//       if (response['cart_items'] != null && response['cart_items'] is List) {
//         cartData = response['cart_items'] as List<dynamic>;
//       } else if (response['cart'] != null && response['cart'] is List) {
//         cartData = response['cart'] as List<dynamic>;
//       } else if (response['data'] != null && response['data'] is List) { // Keep existing 'data' as a fallback
//         cartData = response['data'] as List<dynamic>;
//       } else if (response is List) { // If the whole response is the list of cart items
//         cartData = response;
//       } else {
//         // If the structure is different, log it and return empty
//         print("CartRepository: Unexpected cart items response structure. Response: $response");
//         cartData = [];
//       }
//       // --- END MODIFICATION ---
//
//       List<CartItemModel> cartItems = [];
//       if (cartData != null) {
//         for (var itemJson in cartData) {
//           if (itemJson is Map<String, dynamic>) {
//             cartItems.add(CartItemModel.fromJson(itemJson));
//           }
//         }
//       }
//       print("CartRepository: Parsed ${cartItems.length} cart items.");
//       return cartItems;
//     } on AppException catch (e) {
//       print("Error fetching cart items (AppException): ${e.message}");
//       rethrow;
//     } catch (e) {
//       print("Unexpected error fetching cart items: $e");
//       throw FetchDataException("Could not fetch your cart. Please try again.");
//     }
//   }
//
//   Future<Map<String, dynamic>?> addToCart({
//     required int productId,
//     required int variantId,
//     required int quantity,
//   }) async {
//     final fields = {
//       'product_id': productId.toString(),
//       'variant_id': variantId.toString(),
//       'quantity': quantity.toString(),
//     };
//     try {
//       final response = await _apiProvider.post(
//         AppConstants.addToCartEndpoint,
//         fields: fields,
//       );
//       return response as Map<String, dynamic>?;
//     } on AppException catch (e) {
//       print("Error adding to cart (AppException in CartRepository): ${e.message}");
//       rethrow;
//     } catch (e) {
//       print("Unexpected error adding to cart (CartRepository): $e");
//       throw FetchDataException("An unexpected error occurred while adding item to cart.");
//     }
//   }
//
// // --- OPTIONAL: Add Update/Remove Functions (if endpoints exist and are implemented) ---
// // Future<bool> updateCartItemQuantity(int cartId, int quantity) async { ... }
// // Future<bool> removeCartItem(int cartId) async { ... }
// }

// lib/core/repositories/cart_repository.dart
import 'package:get/get.dart';
// import 'dart:convert'; // Not strictly needed here if CartItemModel handles its own JSON string parsing

import '../constants/app_constants.dart';
import '../models/cart_item_model.dart';
import '../network/api_provider.dart';
import '../utils/app_exceptions.dart';

class CartRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<List<CartItemModel>> getCartItems() async {
    try {
      // Ensure you are using the correct HTTP method (e.g., POST or GET) as per your API design for fetching cart.
      // Your Postman collection shows POST for /api/cart.
      final response = await _apiProvider.post(AppConstants.cartEndpoint);

      List<dynamic>? cartData;

      // Check for the "carts" key based on your latest API response log
      if (response != null && response['carts'] != null && response['carts'] is List) {
        cartData = response['carts'] as List<dynamic>;
        print("CartRepository: Found 'carts' key with ${cartData.length} items.");
      } else {
        // Log if 'carts' key is not found or the structure is unexpected
        print("CartRepository: 'carts' key not found or is not a list in the response. Actual response: $response");
        cartData = []; // Default to empty list to prevent null errors
      }

      List<CartItemModel> cartItems = [];
      if (cartData.isNotEmpty) {
        for (var itemJson in cartData) {
          if (itemJson is Map<String, dynamic>) {
            try {
              cartItems.add(CartItemModel.fromJson(itemJson));
            } catch (e) {
              print("CartRepository: Error parsing cart item JSON: $e. Item JSON: $itemJson");
              // Optionally, you could add a placeholder for unparseable items or skip them
            }
          } else {
            print("CartRepository: Encountered non-map item in cart data: $itemJson");
          }
        }
      }
      print("CartRepository: Parsed ${cartItems.length} cart items successfully.");
      return cartItems;
    } on AppException catch (e) {
      print("CartRepository: Error fetching cart items (AppException): ${e.message}");
      rethrow; // Rethrow to be handled by the controller, which can update UI
    } catch (e) {
      print("CartRepository: Unexpected error fetching cart items: $e");
      // Throw a more specific or user-friendly exception if desired
      throw FetchDataException("Could not fetch your cart at the moment. Please try again.");
    }
  }

  Future<Map<String, dynamic>?> addToCart({
    required int productId,
    required int variantId,
    required int quantity,
  }) async {
    final fields = {
      'product_id': productId.toString(),
      'variant_id': variantId.toString(),
      'quantity': quantity.toString(),
    };
    try {
      final response = await _apiProvider.post(
        AppConstants.addToCartEndpoint,
        fields: fields,
      );
      // Assuming ApiProvider._processResponse returns a Map<String, dynamic> on success
      // or throws an AppException on failure.
      return response as Map<String, dynamic>?;
    } on AppException catch (e) {
      print("CartRepository: Error adding to cart (AppException): ${e.message}");
      rethrow; // Let the controller handle UI feedback for AppExceptions
    } catch (e) {
      print("CartRepository: Unexpected error adding to cart: $e");
      // For unexpected errors, throw a generic FetchDataException or a custom one
      throw FetchDataException("An unexpected error occurred while adding the item to your cart.");
    }
  }

  // --- Placeholder for Update Cart Item Quantity ---
  // You would need a corresponding API endpoint (e.g., /update-cart-item)
  Future<Map<String, dynamic>?> updateCartItemQuantity({
    required int cartId, // This is likely the 'id' of the cart item itself
    required int quantity,
  }) async {
    // final String updateCartEndpoint = AppConstants.updateCartEndpoint; // Define in AppConstants
    // if (updateCartEndpoint == null || updateCartEndpoint.isEmpty) {
    //   print("Update Cart endpoint not defined.");
    //   throw FetchDataException("Update cart functionality is not configured.");
    // }
    print("API Call Needed: Update cart item $cartId to quantity $quantity");
    final fields = {
      'cart_id': cartId.toString(), // Or whatever your API expects (e.g., 'id')
      'quantity': quantity.toString(),
    };
    try {
      // final response = await _apiProvider.post(updateCartEndpoint, fields: fields);
      // return response as Map<String, dynamic>?;
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
      // Simulate a success response structure that your CartController might expect
      return {'type': 'success', 'text': 'Quantity updated successfully in repository (simulated)'};
    } on AppException catch (e) {
      print("CartRepository: Error updating cart item quantity (AppException): ${e.message}");
      rethrow;
    } catch (e) {
      print("CartRepository: Unexpected error updating cart item quantity: $e");
      throw FetchDataException("Could not update item quantity.");
    }
  }

  // --- Placeholder for Remove Cart Item ---
  // You would need a corresponding API endpoint (e.g., /remove-cart-item)
  Future<Map<String, dynamic>?> removeCartItem({
    required int cartId, // This is likely the 'id' of the cart item itself
  }) async {
    // final String removeCartEndpoint = AppConstants.removeCartEndpoint; // Define in AppConstants
    // if (removeCartEndpoint == null || removeCartEndpoint.isEmpty) {
    //   print("Remove Cart Item endpoint not defined.");
    //   throw FetchDataException("Remove cart item functionality is not configured.");
    // }
    print("API Call Needed: Remove cart item $cartId");
    final fields = {
      'cart_id': cartId.toString(), // Or whatever your API expects (e.g., 'id')
    };
    try {
      // final response = await _apiProvider.post(removeCartEndpoint, fields: fields);
      // return response as Map<String, dynamic>?;
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
      // Simulate a success response structure
      return {'type': 'success', 'text': 'Item removed successfully from repository (simulated)'};
    } on AppException catch (e) {
      print("CartRepository: Error removing cart item (AppException): ${e.message}");
      rethrow;
    } catch (e) {
      print("CartRepository: Unexpected error removing cart item: $e");
      throw FetchDataException("Could not remove item from cart.");
    }
  }
}