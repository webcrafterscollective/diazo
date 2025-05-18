// lib/core/models/order_item_model.dart

// Helper function to safely parse doubles
double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  return double.tryParse(value.toString()) ?? defaultValue;
}

// Helper function to safely parse integers
int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  return int.tryParse(value.toString()) ?? defaultValue;
}


class OrderItemModel {
  final int variantId;
  final int productId;
  final String productName;
  final int quantity;
  final String? optionName; // e.g., "Color||Size"
  final String? optionValue; // e.g., "Red||L"
  final double price;
  final double printedPrice;
  // Add main_image if it's part of the order item details needed for display
  // final String? mainImage;

  OrderItemModel({
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.optionName,
    this.optionValue,
    required this.price,
    required this.printedPrice,
    // this.mainImage,
  });

  // Convert OrderItemModel to the format expected by the /add-order API
  Map<String, String> toApiMap(int index) {
    return {
      'orders[$index][variant_id]': variantId.toString(),
      'orders[$index][product_id]': productId.toString(),
      'orders[$index][product_name]': productName,
      'orders[$index][quantity]': quantity.toString(),
      'orders[$index][option_name]': optionName ?? '',
      'orders[$index][option_value]': optionValue ?? '',
      'orders[$index][price]': price.toStringAsFixed(2),
      'orders[$index][printed_price]': printedPrice.toStringAsFixed(2),
      // Add image if needed by API
    };
  }

// Factory constructor if needed to parse from order details later
// factory OrderItemModel.fromJson(Map<String, dynamic> json) {
//   return OrderItemModel(
//     variantId: _parseInt(json['variant_id']),
//     productId: _parseInt(json['product_id']),
//     productName: json['product_name'] ?? 'Unknown',
//     quantity: _parseInt(json['quantity']),
//     optionName: json['option_name'],
//     optionValue: json['option_value'],
//     price: _parseDouble(json['price']),
//     printedPrice: _parseDouble(json['printed_price']),
//     // mainImage: json['main_image'],
//   );
// }
}