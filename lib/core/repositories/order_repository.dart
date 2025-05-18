// lib/core/repositories/order_repository.dart
import 'package:get/get.dart';

import '../constants/app_constants.dart'; //
import '../models/order_model.dart';         // Updated model
import '../models/order_item_model.dart';    // Needed for addOrder
import '../models/order_detail_item_model.dart'; // Updated model for details
import '../network/api_provider.dart'; //
import '../utils/app_exceptions.dart'; //

class OrderRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>(); //

  // Get List of Orders
  Future<List<OrderModel>> getOrders() async { //
    try {
      final response = await _apiProvider.post(AppConstants.orderEndpoint); //
      // Use the correct key 'orders' from the API response
      final List<dynamic> data = response['orders'] ?? []; // <-- Updated key
      List<OrderModel> orders = []; //
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          orders.add(OrderModel.fromJson(item)); // Use updated model
        }
      }
      return orders;
    } on AppException catch (e) { //
      print("Error fetching orders: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error fetching orders: $e");
      throw FetchDataException("Could not fetch orders."); //
    }
  }

  // Get Details for a SINGLE Order Item (based on API response)
  Future<OrderDetailItemModel?> getOrderDetails(String orderDbId) async { //
    // Takes the database ID from the OrderModel
    final fields = {'order_id': orderDbId}; // Pass the DB ID
    try {
      final response = await _apiProvider.post( //
        AppConstants.orderDetailsEndpoint, //
        fields: fields,
      );
      // Use the correct key 'orderDetail' from the API response
      final Map<String, dynamic>? detailData = response['orderDetail'] as Map<String, dynamic>?; // <-- Updated key

      if (detailData != null) {
        return OrderDetailItemModel.fromJson(detailData); // Use updated model
      } else {
        print("Order detail data not found in response for ID: $orderDbId");
        return null; // Return null if 'orderDetail' is missing or not a map
      }
    } on AppException catch (e) { //
      print("Error fetching order details: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error fetching order details: $e");
      throw FetchDataException("Could not fetch order details."); //
    }
  }


  // Add New Order (Kept here for completeness, used by CartController)
  Future<Map<String, dynamic>?> addOrder({ //
    required String userName,
    required String userMobile,
    required String shippingPin,
    required String shippingAddress,
    required String paymentMode,
    required List<OrderItemModel> orderItems, // Uses OrderItemModel
  }) async {
    final fields = <String, String>{
      'user_name': userName,
      'user_mobile': userMobile,
      'shipping_pin': shippingPin,
      'shipping_address': shippingAddress,
      'payment_mode': paymentMode,
    };

    for (int i = 0; i < orderItems.length; i++) {
      fields.addAll(orderItems[i].toApiMap(i));
    }

    try {
      final response = await _apiProvider.post( //
        AppConstants.addOrderEndpoint, //
        fields: fields,
      );
      // Return the full response map on success
      return response as Map<String, dynamic>?;
    } on AppException catch (e) { //
      print("Error placing order: ${e.message}");
      return null; // Indicate failure
    } catch (e) {
      print("Unexpected error placing order: $e");
      return null; // Indicate failure
    }
  }
}