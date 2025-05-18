// // lib/core/repositories/wishlist_repository.dart
// import 'package:get/get.dart';
//
// import '../constants/app_constants.dart'; //
// import '../models/product_model.dart'; //
// import '../network/api_provider.dart'; //
// import '../utils/app_exceptions.dart'; //
//
// class WishlistRepository {
//   final ApiProvider _apiProvider = Get.find<ApiProvider>(); //
//
//   // Fetch wishlist items
//   Future<List<ProductModel>> getWishlist() async {
//     try {
//       // Assuming POST based on Postman collection structure, change if GET
//       final response = await _apiProvider.post(AppConstants.wishlistEndpoint); //
//
//       // *** IMPORTANT: Adapt the key ('data', 'wishlist', 'items') based on your actual /wishlist API response ***
//       final List<dynamic> data = response['data'] ?? []; // Example key 'data'
//
//       List<ProductModel> wishlist = []; //
//       for (var item in data) {
//         if (item is Map<String, dynamic>) {
//           // This assumes the API returns full ProductModel data for each wishlist item.
//           // If it only returns IDs, you'd need to fetch product details separately.
//           wishlist.add(ProductModel.fromJson(item)); //
//         }
//       }
//       return wishlist;
//     } on AppException catch (e) { //
//       print("Error fetching wishlist: ${e.message}");
//       rethrow; // Rethrow to be handled by the controller
//     } catch (e) {
//       print("Unexpected error fetching wishlist: $e");
//       throw FetchDataException("Could not fetch wishlist. Please try again."); //
//     }
//   }
//
//   // Add item to wishlist
//   Future<bool> addWishlist(int productId, int variantId) async { //
//     final fields = {
//       'product_id': productId.toString(),
//       'variant_id': variantId.toString(),
//     };
//     try {
//       // Assuming POST based on Postman example
//       final response = await _apiProvider.post( //
//         AppConstants.addWishlistEndpoint, //
//         fields: fields,
//       );
//       // Check response based on your API's success indicator
//       return response['type'] == 'success'; // Example check
//     } on AppException catch (e) { //
//       print("Error adding to wishlist: ${e.message}");
//       return false;
//     } catch (e) {
//       print("Unexpected error adding to wishlist: $e");
//       return false;
//     }
//   }
//
//   // --- OPTIONAL: Remove item from wishlist ---
//   Future<bool> removeWishlist(int productId, int variantId) async {
//     // *** IMPORTANT: Requires a '/remove-wishlist' endpoint in your API ***
//     // if (AppConstants.removeWishlistEndpoint == null) {
//     //   print("Remove Wishlist endpoint not defined in AppConstants.");
//     //   return false;
//     // }
//     final fields = {
//       'product_id': productId.toString(),
//       'variant_id': variantId.toString(), // Or wishlist_item_id if your API uses that
//     };
//     try {
//       // final response = await _apiProvider.post(AppConstants.removeWishlistEndpoint, fields: fields);
//       // return response['type'] == 'success';
//       print("API Call Needed: Remove wishlist item $productId (variant $variantId)");
//       await Future.delayed(Duration(seconds: 1)); // Simulate API call
//       return true; // Simulate success
//     } on AppException catch (e) { //
//       print("Error removing from wishlist: ${e.message}");
//       return false;
//     } catch (e) {
//       print("Unexpected error removing from wishlist: $e");
//       return false;
//     }
//   }
// // --- End Optional Remove ---
// }

// lib/core/repositories/wishlist_repository.dart
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../models/product_model.dart'; // Your ProductModel
import '../network/api_provider.dart';
import '../utils/app_exceptions.dart';

class WishlistRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<List<ProductModel>> getWishlist() async {
    try {
      // Assuming POST based on your Postman collection, change to .get if your API uses GET
      final response = await _apiProvider.post(AppConstants.wishlistEndpoint);

      // *** THIS IS THE KEY CHANGE ***
      // The API response has the items under the "wishlists" key.
      final List<dynamic>? data = response['wishlists'] as List<dynamic>?;

      List<ProductModel> wishlist = [];
      if (data != null) {
        for (var itemJson in data) {
          if (itemJson is Map<String, dynamic>) {
            // Ensure your ProductModel.fromJson can correctly parse the structure of items in the "wishlists" array
            // The structure includes fields like id, uid, name, price, main_img, etc.
            wishlist.add(ProductModel.fromJson(itemJson));
          }
        }
      } else {
        // Handle cases where 'wishlists' key might be missing or not a list, though API says "success"
        print("WishlistRepository: 'wishlists' key not found or is not a list in the response, even though type is success.");
      }
      print("WishlistRepository: Parsed ${wishlist.length} items from wishlist.");
      return wishlist;
    } on AppException catch (e) {
      print("Error fetching wishlist (AppException): ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error fetching wishlist: $e");
      throw FetchDataException("Could not fetch wishlist. Please try again.");
    }
  }

  Future<bool> addWishlist(int productId, int variantId) async {
    final fields = {
      'product_id': productId.toString(),
      'variant_id': variantId.toString(),
    };
    try {
      final response = await _apiProvider.post(
        AppConstants.addWishlistEndpoint,
        fields: fields,
      );
      return response['type'] == 'success';
    } on AppException catch (e) {
      print("Error adding to wishlist: ${e.message}");
      return false; // Or rethrow to let controller handle UI feedback
    } catch (e) {
      print("Unexpected error adding to wishlist: $e");
      return false; // Or rethrow
    }
  }

  Future<bool> removeWishlist(int productId, int variantId) async {
    // final String removeWishlistEndpoint = AppConstants.removeWishlistEndpoint; // Define this in your constants
    // if (removeWishlistEndpoint == null || removeWishlistEndpoint.isEmpty) {
    //   print("Remove Wishlist endpoint not defined.");
    //   return false;
    // }
    final fields = {
      'product_id': productId.toString(),
      'variant_id': variantId.toString(), // Or wishlist_item_id if your API uses that
    };
    try {
      // final response = await _apiProvider.post(removeWishlistEndpoint, fields: fields);
      // return response['type'] == 'success';
      print("Simulating API Call: Remove wishlist item $productId (variant $variantId)");
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      return true; // Simulate success
    } on AppException catch (e) {
      print("Error removing from wishlist: ${e.message}");
      return false;
    } catch (e) {
      print("Unexpected error removing from wishlist: $e");
      return false;
    }
  }
}