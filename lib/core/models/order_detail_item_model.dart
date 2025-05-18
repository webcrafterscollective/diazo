// lib/core/models/order_detail_item_model.dart

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

class OrderDetailItemModel {
  final int id; // This seems to be the order item ID, not the main order ID
  final String productName;
  final String? optionName;
  final String? optionValue;
  final int quantity;
  final double price;
  final double printedPrice;
  final String? deliveredDate;
  final String? canceledDate;
  final String? returnedDate;
  final String paymentMode;
  final String? rejectNote;
  final String orderStatus;
  // Add main_image if needed for display
  // final String? mainImage;

  OrderDetailItemModel({
    required this.id,
    required this.productName,
    this.optionName,
    this.optionValue,
    required this.quantity,
    required this.price,
    required this.printedPrice,
    this.deliveredDate,
    this.canceledDate,
    this.returnedDate,
    required this.paymentMode,
    this.rejectNote,
    required this.orderStatus,
    // this.mainImage,
  });

  // Helper to get formatted options
  Map<String, String> get options {
    if (optionName == null || optionValue == null || optionName!.isEmpty || optionValue!.isEmpty) {
      return {};
    }
    final names = optionName!.split('||');
    final values = optionValue!.split('||');
    if (names.length != values.length) return {}; // Basic check
    return Map.fromIterables(names, values);
  }


  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemModel(
      id: _parseInt(json['id']),
      productName: json['product_name'] as String? ?? 'N/A',
      optionName: json['option_name'] as String?,
      optionValue: json['option_value'] as String?,
      quantity: _parseInt(json['quantity']),
      price: _parseDouble(json['price']),
      printedPrice: _parseDouble(json['printed_price']),
      deliveredDate: json['delivered_date'] as String?,
      canceledDate: json['canceled_date'] as String?,
      returnedDate: json['returned_date'] as String?,
      paymentMode: json['payment_mode'] as String? ?? 'N/A',
      rejectNote: json['reject_note'] as String?,
      orderStatus: json['order_status'] as String? ?? 'Unknown',
      // mainImage: json['main_image'] as String?, // Add if needed
    );
  }
}