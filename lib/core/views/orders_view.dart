// lib/core/views/orders_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart'; //
import '../constants/app_colors.dart'; //
import '../widgets/loading_indicator.dart'; //
import '../routes/routes.dart'; // For navigation

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  final OrderController _orderController = Get.find<OrderController>(); //

  @override
  Widget build(BuildContext context) {
    // Fetch orders when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderController.fetchOrders(); //
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.background, //
        foregroundColor: AppColors.textPrimary, //
        elevation: 1,
      ),
      body: Obx(() { //
        if (_orderController.isLoadingOrders.value) { //
          return const LoadingIndicator(); //
        }
        if (_orderController.errorMessage.value.isNotEmpty && _orderController.orders.isEmpty) { //
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${_orderController.errorMessage.value}', textAlign: TextAlign.center), //
            ),
          );
        }
        if (_orderController.orders.isEmpty) { //
          return const Center(child: Text('You have no orders yet.'));
        }

        // Display list of orders
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: _orderController.orders.length, //
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = _orderController.orders[index]; //
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text('Order ID: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)), //
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Date: ${order.orderDate}'), // Add formatting if needed
                    Text('Status: ${order.paymentStatus}'), //
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to Order Details Screen
                  // Pass the database ID (order.id) needed by fetchOrderDetails
                  Get.toNamed(AppRoutes.orderDetails, arguments: order.id.toString()); //
                },
              ),
            );
          },
        );
      }),
    );
  }
}