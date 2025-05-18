// lib/core/views/order_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart'; //
import '../constants/app_colors.dart'; //
import '../constants/app_constants.dart'; //
import '../widgets/loading_indicator.dart'; //
import '../models/order_detail_item_model.dart'; // Import the details model

class OrderDetailsScreen extends StatelessWidget {
  OrderDetailsScreen({super.key});

  final OrderController _orderController = Get.find<OrderController>(); //

  @override
  Widget build(BuildContext context) {
    // Get the order ID passed as argument
    final String? orderDbId = Get.arguments as String?;

    // Fetch details when the screen is built if ID is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (orderDbId != null) {
        _orderController.fetchOrderDetails(orderDbId); //
      } else {
        Get.back(); // Go back if no ID provided
        Get.snackbar('Error', 'Order ID missing.', snackPosition: SnackPosition.BOTTOM);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.background, //
        foregroundColor: AppColors.textPrimary, //
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _orderController.clearOrderDetails(); // Clear state before going back
            Get.back();
          },
        ),
      ),
      body: Obx(() { //
        if (_orderController.isLoadingDetails.value) { //
          return const LoadingIndicator(); //
        }
        if (_orderController.errorMessage.value.isNotEmpty && _orderController.orderDetails.value == null) { //
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${_orderController.errorMessage.value}', textAlign: TextAlign.center), //
            ),
          );
        }

        final OrderDetailItemModel? details = _orderController.orderDetails.value; //

        if (details == null) {
          return const Center(child: Text('Order details not available.'));
        }

        // --- Display Order Item Details ---
        // Adapts display based on the OrderDetailItemModel
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Item Specific Details ---
              Text('Product: ${details.productName}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (details.options.isNotEmpty)
                Text('Options: ${details.options.entries.map((e) => "${e.key}: ${e.value}").join(', ')}'),
              const SizedBox(height: 8),
              Text('Quantity: ${details.quantity}'),
              Text('Price per item: ${AppConstants.currencySymbol}${details.price.toStringAsFixed(2)}'), //
              if(details.printedPrice > details.price)
                Text('Original Price: ${AppConstants.currencySymbol}${details.printedPrice.toStringAsFixed(2)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)), //
              const Divider(height: 24, thickness: 1),
              Text('Order Status: ${details.orderStatus}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Payment Mode: ${details.paymentMode}'),
              if(details.deliveredDate != null) Text('Delivered On: ${details.deliveredDate}'),
              if(details.canceledDate != null) Text('Canceled On: ${details.canceledDate}'),
              if(details.returnedDate != null) Text('Returned On: ${details.returnedDate}'),
              if(details.rejectNote != null) Text('Rejection Note: ${details.rejectNote}'),

              // Add image display if mainImage is added to OrderDetailItemModel
              // if(details.mainImage != null) ...[
              //   SizedBox(height: 16),
              //   CachedNetworkImage(...) // Display image here
              // ]
            ],
          ),
        );
      }),
    );
  }
}