// // // lib/core/models/cart_item_model.dart
// //
// // // Helper function to safely parse doubles
// // import '../constants/app_constants.dart';
// //
// // double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
// //   if (value == null) return defaultValue;
// //   return double.tryParse(value.toString()) ?? defaultValue;
// // }
// //
// // // Helper function to safely parse integers
// // int _parseInt(dynamic value, [int defaultValue = 0]) {
// //   if (value == null) return defaultValue;
// //   return int.tryParse(value.toString()) ?? defaultValue;
// // }
// //
// //
// // class CartItemModel {
// //   final int cartId; // Assuming API provides a cart item ID
// //   final int productId;
// //   final int variantId;
// //   final String productName;
// //   final String? mainImage; // Made nullable
// //   final String? optionName; // e.g., "Color||Size" - Made nullable
// //   final String? optionValue; // e.g., "Red||XL" - Made nullable
// //   final double price;
// //   final double printedPrice;
// //   final int quantity;
// //
// //   CartItemModel({
// //     required this.cartId,
// //     required this.productId,
// //     required this.variantId,
// //     required this.productName,
// //     this.mainImage,
// //     this.optionName,
// //     this.optionValue,
// //     required this.price,
// //     required this.printedPrice,
// //     required this.quantity,
// //   });
// //
// //   // Helper to get formatted options
// //   Map<String, String> get options {
// //     if (optionName == null || optionValue == null || optionName!.isEmpty || optionValue!.isEmpty) {
// //       return {};
// //     }
// //     final names = optionName!.split('||');
// //     final values = optionValue!.split('||');
// //     if (names.length != values.length) return {}; // Basic check
// //     return Map.fromIterables(names, values);
// //   }
// //
// //   // Helper to get full image URL
// //   // Use the AppConstants helper directly if preferred
// //   String get fullImageUrl => AppConstants.buildImageUrl(mainImage);
// //
// //
// //   factory CartItemModel.fromJson(Map<String, dynamic> json) {
// //     // Assuming the /cart endpoint returns a list of items with this structure
// //     return CartItemModel(
// //       cartId: _parseInt(json['cart_id'] ?? json['id']), // Look for cart_id or id (adapt based on actual API response for /cart)
// //       productId: _parseInt(json['product_id']),
// //       variantId: _parseInt(json['variant_id']),
// //       productName: json['product_name'] as String? ?? 'Unknown Product',
// //       mainImage: json['main_img'] as String?, // Use main_img if available
// //       optionName: json['option_name'] as String?,
// //       optionValue: json['option_value'] as String?,
// //       price: _parseDouble(json['price']),
// //       printedPrice: _parseDouble(json['printed_price']),
// //       quantity: _parseInt(json['quantity']),
// //     );
// //   }
// //
// //   // toJson might be needed if updating cart items
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'cart_id': cartId,
// //       'product_id': productId,
// //       'variant_id': variantId,
// //       'product_name': productName,
// //       'main_img': mainImage,
// //       'option_name': optionName,
// //       'option_value': optionValue,
// //       'price': price,
// //       'printed_price': printedPrice,
// //       'quantity': quantity,
// //     };
// //   }
// // }
//
// // lib/core/models/cart_item_model.dart
// import 'dart:convert'; // For jsonDecode
// import '../constants/app_constants.dart'; // For AppConstants.buildImageUrl
//
// // Helper functions (if not already globally available)
// double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
//   if (value == null) return defaultValue;
//   return double.tryParse(value.toString()) ?? defaultValue;
// }
//
// int _parseInt(dynamic value, [int defaultValue = 0]) {
//   if (value == null) return defaultValue;
//   return int.tryParse(value.toString()) ?? defaultValue;
// }
//
// class CartItemModel {
//   final int cartId;       // from "id" in API cart item
//   final int productId;    // from "product_id"
//   final String? uid;
//   final String productName;  // from "name"
//   final String? title;      // from "title"
//   final double printedPrice;
//   final double price;
//   final int stock;
//   final String? mainImage;  // from "main_img"
//   final List<String> otherImages; // from "other_img" (parsed JSON string)
//   final String? optionName;
//   final String? optionValue;
//   final int quantity;       // IMPORTANT: This field is MISSING in your API log for cart items.
//   // Assuming it should be there, or defaults to 1.
//
//   // Assuming 'variant_id' is implicitly the 'product_id' or 'id' in the context of the cart list API response,
//   // or perhaps not needed directly by CartItemModel if CartController manages it elsewhere.
//   // For now, let's assume the 'id' of the product in the cart is significant.
//   // The 'addToCart' API call uses 'variant_id'. The 'carts' API response items have 'product_id'.
//   // This needs clarification on how variants are identified in the fetched cart.
//   // Let's add a placeholder for variant_id if it's different from product_id.
//   // For simplicity, if your backend treats each product in cart as a specific variant already,
//   // then product_id might be sufficient. Let's assume the main 'id' from cart item IS the variant_id for now
//   // or that `product_id` is used to represent the variant in the cart.
//   // Let's use `productId` as the reference and potentially add `variantId` if distinct.
//   // The API shows "product_id", not a separate "variant_id" in the cart items list.
//
//   CartItemModel({
//     required this.cartId,
//     required this.productId,
//     this.uid,
//     required this.productName,
//     this.title,
//     required this.printedPrice,
//     required this.price,
//     required this.stock,
//     this.mainImage,
//     this.otherImages = const [],
//     this.optionName,
//     this.optionValue,
//     required this.quantity, // Make required, default to 1 if API doesn't send
//   });
//
//   Map<String, String> get options {
//     if (optionName == null || optionValue == null || optionName!.isEmpty || optionValue!.isEmpty) {
//       return {};
//     }
//     final names = optionName!.split('||');
//     final values = optionValue!.split('||');
//     if (names.length != values.length) return {};
//     return Map.fromIterables(names, values);
//   }
//
//   String get fullImageUrl => AppConstants.buildImageUrl(mainImage);
//
//   factory CartItemModel.fromJson(Map<String, dynamic> json) {
//     List<String> parsedOtherImages = [];
//     if (json['other_img'] != null && json['other_img'] is String) {
//       String otherImgJsonString = json['other_img'] as String;
//       if (otherImgJsonString.isNotEmpty && otherImgJsonString.startsWith('[') && otherImgJsonString.endsWith(']')) {
//         try {
//           var decodedList = jsonDecode(otherImgJsonString);
//           if (decodedList is List) {
//             parsedOtherImages = decodedList.map((e) => e.toString()).toList();
//           }
//         } catch (e) {
//           print("Error decoding other_img JSON string in CartItemModel: $e");
//         }
//       } else if (otherImgJsonString.isNotEmpty) {
//         // If other_img is a single string path, not a JSON array string
//         // This case is not shown in your log, but as a fallback
//         // parsedOtherImages.add(otherImgJsonString);
//       }
//     }
//
//
//     // CRITICAL: 'quantity' is missing in your API log for cart items.
//     // Defaulting to 1 if not found. This needs to be fixed in the API ideally.
//     final int itemQuantity = _parseInt(json['quantity'], 1);
//     if (json['quantity'] == null) {
//       print("WARNING: 'quantity' field missing for cart item ID ${json['id']}. Defaulting to 1.");
//     }
//
//
//     return CartItemModel(
//       cartId: _parseInt(json['id']), // 'id' in cart item is the cart_item_id
//       productId: _parseInt(json['product_id']),
//       uid: json['uid'] as String?,
//       productName: json['name'] as String? ?? 'Unnamed Product',
//       title: json['title'] as String?,
//       printedPrice: _parseDouble(json['printed_price']),
//       price: _parseDouble(json['price']),
//       stock: _parseInt(json['stock']),
//       mainImage: json['main_img'] as String?,
//       otherImages: parsedOtherImages,
//       optionName: json['option_name'] as String?,
//       optionValue: json['option_value'] as String?,
//       quantity: itemQuantity, // Use parsed quantity or default
//     );
//   }
//
//   Map<String, dynamic> toJson() { // For potential updates, though not used for fetching
//     return {
//       'id': cartId, // Corresponds to 'cart_id' for this model
//       'product_id': productId,
//       'uid': uid,
//       'name': productName,
//       'title': title,
//       'printed_price': printedPrice,
//       'price': price,
//       'stock': stock,
//       'main_img': mainImage,
//       'other_img': jsonEncode(otherImages), // Re-encode if needed for sending
//       'option_name': optionName,
//       'option_value': optionValue,
//       'quantity': quantity,
//     };
//   }
// }

// lib/core/models/cart_item_model.dart
import 'dart:convert'; // For jsonDecode
import '../constants/app_constants.dart'; // For AppConstants.buildImageUrl

// Helper functions (can be moved to a utility file if used in multiple models)
double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null || value.toString().isEmpty) return defaultValue;
  return double.tryParse(value.toString()) ?? defaultValue;
}

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null || value.toString().isEmpty) return defaultValue;
  return int.tryParse(value.toString()) ?? defaultValue;
}

class CartItemModel {
  final int cartId;       // from "id" in API cart item
  final int productId;    // from "product_id"
  final String? uid;
  final int? groupId;     // from "group_id"
  final String? sku;
  final String? barCode;    // from "bar_code"
  final String? title;      // from "title"
  final String productName;  // from "name"
  final double printedPrice;
  final double price;
  final int stock;
  final String? tags;
  final String? mainImage;  // from "main_img"
  final List<String> otherImages; // from "other_img" (parsed JSON string)
  final String? optionName;
  final String? optionValue;

  // CRITICAL: 'quantity' is MISSING from your provided /api/cart sample response.
  // This is essential for cart functionality.
  // Defaulting to 1 as a temporary workaround, but this needs to be fixed in the API.
  final int quantity;

  // The API response for /api/cart does not explicitly provide a 'variant_id' for each item.
  // It gives 'product_id'. If 'id' (cartId) or 'product_id' uniquely identifies the variant in the cart context,
  // we might not need a separate variantId here unless other operations specifically require it
  // and it can't be inferred. For now, we don't have a distinct variant_id from this API response.

  CartItemModel({
    required this.cartId,
    required this.productId,
    this.uid,
    this.groupId,
    this.sku,
    this.barCode,
    this.title,
    required this.productName,
    required this.printedPrice,
    required this.price,
    required this.stock,
    this.tags,
    this.mainImage,
    this.otherImages = const [],
    this.optionName,
    this.optionValue,
    this.quantity = 1, // Defaulting quantity to 1 due to API missing this field
  });

  Map<String, String> get options {
    if (optionName == null || optionValue == null || optionName!.isEmpty || optionValue!.isEmpty) {
      return {};
    }
    final names = optionName!.split('||');
    final values = optionValue!.split('||');
    if (names.length != values.length) {
      print("Warning: Mismatch in option names and values for cart item $cartId");
      return {};
    }
    return Map.fromIterables(names, values);
  }

  String get fullImageUrl => AppConstants.buildImageUrl(mainImage);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedOtherImages = [];
    if (json['other_img'] != null && json['other_img'] is String) {
      String otherImgJsonString = json['other_img'] as String;
      if (otherImgJsonString.isNotEmpty && otherImgJsonString.startsWith('[') && otherImgJsonString.endsWith(']')) {
        try {
          var decodedList = jsonDecode(otherImgJsonString);
          if (decodedList is List) {
            parsedOtherImages = decodedList.map((e) => e.toString()).toList();
          }
        } catch (e) {
          print("Error decoding other_img JSON string in CartItemModel (ID: ${json['id']}): $e. String was: $otherImgJsonString");
        }
      } else if (otherImgJsonString.isNotEmpty) {
        // Fallback if other_img is a single non-JSON string (though your log shows JSON string or null)
        // parsedOtherImages.add(otherImgJsonString);
      }
    }

    // --- CRITICAL HANDLING FOR MISSING QUANTITY ---
    int itemQuantity = 1; // Default to 1
    if (json.containsKey('quantity') && json['quantity'] != null) {
      itemQuantity = _parseInt(json['quantity'], 1);
    } else {
      // This log will appear for every item if 'quantity' is consistently missing.
      print("WARNING: 'quantity' field is missing for cart item ID ${json['id']}. Defaulting to 1. API should provide this.");
    }
    // --- END CRITICAL HANDLING ---

    return CartItemModel(
      cartId: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      uid: json['uid'] as String?,
      groupId: _parseInt(json['group_id']),
      sku: json['sku'] as String?,
      barCode: json['bar_code'] as String?,
      title: json['title'] as String?,
      productName: json['name'] as String? ?? 'Unnamed Product',
      printedPrice: _parseDouble(json['printed_price']),
      price: _parseDouble(json['price']),
      stock: _parseInt(json['stock']),
      tags: json['tags'] as String?,
      mainImage: json['main_img'] as String?,
      otherImages: parsedOtherImages,
      optionName: json['option_name'] as String?,
      optionValue: json['option_value'] as String?,
      quantity: itemQuantity, // Use the parsed or default quantity
    );
  }

  // toJson might be needed if updating cart items locally before an API call,
  // or if you were to send the whole CartItemModel back to an API (less common for updates).
  Map<String, dynamic> toJson() {
    return {
      'id': cartId,
      'product_id': productId,
      'uid': uid,
      'group_id': groupId,
      'sku': sku,
      'bar_code': barCode,
      'title': title,
      'name': productName,
      'printed_price': printedPrice,
      'price': price,
      'stock': stock,
      'tags': tags,
      'main_img': mainImage,
      'other_img': otherImages.isNotEmpty ? jsonEncode(otherImages) : null, // Re-encode if sending back
      'option_name': optionName,
      'option_value': optionValue,
      'quantity': quantity,
    };
  }
}