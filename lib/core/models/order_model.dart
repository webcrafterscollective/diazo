// lib/core/models/order_model.dart

// Helper function to safely parse integers
int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  return int.tryParse(value.toString()) ?? defaultValue;
}

class OrderModel {
  final int id; // Internal DB ID
  final String orderId; // The user-facing order ID (e.g., "M-6808D71F87C47")
  final String userName;
  final String userMobile;
  final String shippingPin;
  final String shippingAddress;
  final String orderDate; // Keep as String, parse if needed in UI
  final String paymentMode;
  final String paymentStatus; // New field

  OrderModel({
    required this.id,
    required this.orderId,
    required this.userName,
    required this.userMobile,
    required this.shippingPin,
    required this.shippingAddress,
    required this.orderDate,
    required this.paymentMode,
    required this.paymentStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _parseInt(json['id']), // Use internal ID
      orderId: json['order_id'] as String? ?? 'N/A', // User facing ID
      userName: json['user_name'] as String? ?? 'N/A',
      userMobile: json['user_mobile'] as String? ?? 'N/A',
      shippingPin: json['shipping_pin'] as String? ?? 'N/A',
      shippingAddress: json['shipping_address'] as String? ?? 'N/A',
      orderDate:
          json['order_date'] as String? ?? 'N/A', // Assuming YYYY-MM-DD format
      paymentMode: json['payment_mode'] as String? ?? 'N/A',
      paymentStatus: json['payment_status'] as String? ?? 'N/A',
    );
  }

//Optional: Add getters for formatted date if needed
  DateTime? get parsedOrderDate {
    try {
      return DateTime.parse(orderDate);
    } catch (e) {
      return null;
    }
  }
}
