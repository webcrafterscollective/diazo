// lib/core/controllers/order_controller.dart
import 'package:get/get.dart';
import '../repositories/order_repository.dart'; //
import '../models/order_model.dart'; // Updated model
import '../models/order_detail_item_model.dart'; // Updated model

class OrderController extends GetxController { //
  final OrderRepository _orderRepository = Get.find<OrderRepository>(); //

  final RxList<OrderModel> orders = <OrderModel>[].obs; // Holds the list of orders
  // Holds the details of the currently selected order item(s)
  final Rx<OrderDetailItemModel?> orderDetails = Rx<OrderDetailItemModel?>(null); //

  final RxBool isLoadingOrders = false.obs; // Separate loading state for list
  final RxBool isLoadingDetails = false.obs; // Separate loading state for details
  final RxString errorMessage = ''.obs; //

  @override
  void onInit() { //
    super.onInit();
  }

  // Fetch the list of orders
  Future<void> fetchOrders() async { //
    try {
      isLoadingOrders.value = true; //
      errorMessage.value = ''; //
      orders.clear(); // Clear previous orders

      final orderList = await _orderRepository.getOrders(); //
      orders.assignAll(orderList); //

    } catch (e) {
      errorMessage.value = e.toString(); //
      orders.clear(); // Clear on error too
      Get.snackbar('Error', 'Could not fetch orders: ${e.toString()}', snackPosition: SnackPosition.BOTTOM); //
    } finally {
      isLoadingOrders.value = false; //
    }
  }

  // Fetch details for a specific order item
  Future<void> fetchOrderDetails(String orderDbId) async { //
    // Takes the database ID from the OrderModel
    try {
      isLoadingDetails.value = true; //
      errorMessage.value = ''; //
      orderDetails.value = null; // Clear previous details

      final details = await _orderRepository.getOrderDetails(orderDbId); //
      orderDetails.value = details; // Assign the fetched details (or null)

      if (details == null && errorMessage.isEmpty) { //
        // Handle case where repository returned null without throwing specific error
      }

    } catch (e) {
      errorMessage.value = e.toString(); //
      orderDetails.value = null; // Clear on error
      Get.snackbar('Error', 'Could not fetch order details: ${e.toString()}', snackPosition: SnackPosition.BOTTOM); //
    } finally {
      isLoadingDetails.value = false; //
    }
  }

  // Clear details when leaving the details screen or selecting a new order
  void clearOrderDetails() { //
    orderDetails.value = null; //
    errorMessage.value = ''; // Also clear error message related to details
  }
}