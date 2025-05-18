// // lib/core/controllers/cart_controller.dart
// import 'package:flutter/material.dart'; // For Colors in Snackbar
// import 'package:get/get.dart';
// import '../repositories/cart_repository.dart';
// import '../models/cart_item_model.dart';
// import '../models/order_item_model.dart';
// import '../repositories/order_repository.dart';
// import '../models/address_model.dart';
// import '../constants/app_colors.dart'; // For snackbar styling
// import '../utils/app_exceptions.dart';
//
// class CartController extends GetxController {
//   final CartRepository _cartRepository = Get.find<CartRepository>();
//   final OrderRepository _orderRepository = Get.find<OrderRepository>();
//
//   final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
//   final RxBool isLoading = false.obs; // General loading for fetch/checkout
//   final RxBool isAddingToCart = false.obs; // <-- Specific loading for addToCart action
//   final RxString errorMessage = ''.obs;
//   final RxDouble cartSubtotal = 0.0.obs;
//   final RxDouble cartTotal = 0.0.obs;
//   final Rx<AddressModel?> selectedShippingAddress = Rx<AddressModel?>(null);
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Optionally fetch cart items when controller is initialized,
//     // e.g., if user was logged in and cart needs to be ready.
//     // fetchCartItems();
//   }
//
//   Future<void> fetchCartItems() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       final items = await _cartRepository.getCartItems();
//       cartItems.assignAll(items);
//       _calculateTotals();
//     } catch (e) {
//       errorMessage.value = e.toString();
//       cartItems.clear();
//       _calculateTotals();
//       // Get.snackbar('Error', 'Could not fetch cart: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // MODIFIED: To handle new response type and display specific API message
//   Future<void> addToCart({
//     required int productId,
//     required int variantId,
//     int quantity = 1,
//   }) async {
//     if (isAddingToCart.value) return; // Prevent concurrent additions
//
//     try {
//       isAddingToCart.value = true;
//       errorMessage.value = ''; // Clear previous error message for this action
//
//       final Map<String, dynamic>? response = await _cartRepository.addToCart(
//         productId: productId,
//         variantId: variantId,
//         quantity: quantity,
//       );
//
//       // ApiProvider should have already ensured 'type':'success' for non-exception path
//       // and response is a Map.
//       if (response != null && response['type'] == 'success') {
//         final String message = response['text'] as String? ?? 'Action completed successfully.';
//
//         Get.snackbar(
//           message.contains("Successfully") ? 'Success' : 'Info', // Dynamic title
//           message,        // Message from API
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: message.contains("Successfully") ? AppColors.success : AppColors.primary, // Different color for info
//           colorText: Colors.white,
//           margin: const EdgeInsets.all(10),
//           borderRadius: 8,
//         );
//
//         // Refresh cart items if the item was newly added or quantity might have been updated.
//         // The API response "The Product Already Exits in the Cart" might imply no change,
//         // or it might imply quantity was updated if your API handles it as add-or-update.
//         // If it strictly adds and doesn't update existing quantity, only fetch on "Successfully".
//         if (message == "Add To Cart Successfully") { // Exact match for new add
//           await fetchCartItems();
//         }
//       } else {
//         // This block might be hit if CartRepository changes to not rethrow AppExceptions
//         // and instead returns a non-null response that isn't type:success.
//         // However, with current CartRepository rethrowing, this is less likely.
//         errorMessage.value = response?['text'] as String? ?? 'Failed to add item to cart.';
//         Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//       }
//     } on AppException catch (e) { // Catch AppExceptions from ApiProvider/Repository
//       errorMessage.value = e.message ?? e.toString();
//       Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//     } catch (e) { // Catch other unexpected errors
//       errorMessage.value = e.toString();
//       Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//     } finally {
//       isAddingToCart.value = false;
//     }
//   }
//
//   void _calculateTotals() {
//     double sub = 0.0;
//     for (var item in cartItems) {
//       sub += item.price * item.quantity;
//     }
//     cartSubtotal.value = sub;
//     cartTotal.value = sub; // Add shipping/taxes later if needed
//   }
//
//   // Placeholder for updateQuantity - ensure API call is implemented if used
//   Future<void> updateQuantity(int cartId, int newQuantity) async {
//     if (newQuantity <= 0) {
//       await removeCartItem(cartId);
//       return;
//     }
//     // TODO: Implement API call to update cart item quantity
//     print("API Call Needed: Update cart item $cartId to quantity $newQuantity");
//     // Simulate local update for UI responsiveness
//     final index = cartItems.indexWhere((item) => item.cartId == cartId);
//     if (index != -1) {
//       cartItems[index] = CartItemModel( // Create new instance
//         cartId: cartItems[index].cartId,
//         productId: cartItems[index].productId,
//         variantId: cartItems[index].variantId,
//         productName: cartItems[index].productName,
//         mainImage: cartItems[index].mainImage,
//         optionName: cartItems[index].optionName,
//         optionValue: cartItems[index].optionValue,
//         price: cartItems[index].price,
//         printedPrice: cartItems[index].printedPrice,
//         quantity: newQuantity, // Updated quantity
//       );
//       cartItems.refresh(); // Trigger UI update for the list
//       _calculateTotals();
//     }
//   }
//
//   // Placeholder for removeCartItem - ensure API call is implemented if used
//   Future<void> removeCartItem(int cartId) async {
//     // TODO: Implement API call to remove cart item
//     print("API Call Needed: Remove cart item $cartId");
//     // Simulate local removal for UI responsiveness
//     cartItems.removeWhere((item) => item.cartId == cartId);
//     cartItems.refresh(); // Trigger UI update
//     _calculateTotals();
//   }
//
//   Future<Map<String, dynamic>?> placeOrder({
//     required String userName,
//     required String userMobile,
//     required String paymentMode,
//     // Address details will come from selectedShippingAddress
//   }) async {
//     if (selectedShippingAddress.value == null) {
//       errorMessage.value = "Please select a shipping address.";
//       Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//       return null;
//     }
//     if (cartItems.isEmpty) {
//       errorMessage.value = "Your cart is empty.";
//       Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//       return null;
//     }
//
//     final address = selectedShippingAddress.value!;
//     final orderItems = cartItems.map((cartItem) => OrderItemModel(
//       variantId: cartItem.variantId,
//       productId: cartItem.productId,
//       productName: cartItem.productName,
//       quantity: cartItem.quantity,
//       optionName: cartItem.optionName,
//       optionValue: cartItem.optionValue,
//       price: cartItem.price,
//       printedPrice: cartItem.printedPrice,
//     )).toList();
//
//     Map<String, dynamic>? orderResponse;
//
//     try {
//       isLoading.value = true; // General loading state for placing order
//       errorMessage.value = '';
//
//       orderResponse = await _orderRepository.addOrder(
//         userName: userName, // Or from authController.user.value?.name
//         userMobile: userMobile, // Or from authController.user.value?.phone
//         shippingPin: address.pincode,
//         shippingAddress: "${address.addressLine1}, ${address.addressLine2}, ${address.city}, ${address.state}, ${address.country}",
//         paymentMode: paymentMode,
//         orderItems: orderItems,
//       );
//
//       if (orderResponse != null && orderResponse['type'] == 'success') {
//         Get.snackbar('Success', 'Order placed successfully! Order ID: ${orderResponse['order_id']}', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success, colorText: Colors.white);
//         await fetchCartItems(); // Refresh cart (it should be empty)
//         // clearLocalCart(); // Alternative if fetchCartItems is too slow/not needed
//         selectedShippingAddress.value = null; // Reset selected address
//         return orderResponse;
//       } else {
//         errorMessage.value = orderResponse?['text'] as String? ?? 'Failed to place order. Please try again.';
//         Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//         return null;
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       Get.snackbar('Error', 'Order placement failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
//       return null;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearLocalCart() {
//     cartItems.clear();
//     _calculateTotals();
//     selectedShippingAddress.value = null;
//     errorMessage.value = '';
//   }
// }

// lib/core/controllers/cart_controller.dart
import 'package:flutter/material.dart'; // For Colors in Snackbar
import 'package:get/get.dart';
import '../repositories/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../models/order_item_model.dart'; // Used for placing an order
import '../repositories/order_repository.dart';
import '../models/address_model.dart';
import '../constants/app_colors.dart'; // For snackbar styling
import '../utils/app_exceptions.dart';
import '../controllers/auth_controller.dart'; // To potentially get user details

class CartController extends GetxController {
  final CartRepository _cartRepository = Get.find<CartRepository>();
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  // Optional: final AuthController _authController = Get.find<AuthController>();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs; // General loading for fetch/checkout
  final RxBool isAddingToCart = false.obs; // Specific loading for addToCart action
  final RxBool isUpdatingCart = false.obs; // Loading for update/remove actions

  final RxString errorMessage = ''.obs;
  final RxDouble cartSubtotal = 0.0.obs;
  final RxDouble cartTotal = 0.0.obs; // Could include shipping, taxes later
  final Rx<AddressModel?> selectedShippingAddress = Rx<AddressModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Fetch cart items when the controller is initialized,
    // especially if the user might already be logged in.
    // Consider scenarios: app start, after login.
    // fetchCartItems(); // You might call this from onReady in view or after login.
  }

  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final items = await _cartRepository.getCartItems();
      cartItems.assignAll(items);
      print("CartController: fetchCartItems received ${items.length} items.");
      if (items.isNotEmpty) {
        items.forEach((item) {
          print("CartController: Item ${item.productName}, Qty: ${item.quantity}, Price: ${item.price}");
        });
      }
      _calculateTotals();
    } on AppException catch(e) {
      errorMessage.value = e.message ?? "Could not load cart items.";
      cartItems.clear(); // Clear items on error
      _calculateTotals();
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = "An unexpected error occurred while fetching your cart.";
      cartItems.clear();
      _calculateTotals();
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      print("CartController fetchCartItems error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart({
    required int productId,
    required int variantId, // This is the specific variant ID
    int quantity = 1,
  }) async {
    if (isAddingToCart.value) return;

    try {
      isAddingToCart.value = true;
      errorMessage.value = '';

      final Map<String, dynamic>? response = await _cartRepository.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );

      if (response != null && response['type'] == 'success') {
        final String message = response['text'] as String? ?? 'Item action completed.';
        Get.snackbar(
          message.toLowerCase().contains("successfully") ? 'Success' : 'Info',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: message.toLowerCase().contains("successfully") ? AppColors.success : AppColors.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
        // Refresh cart after adding, especially if API confirms "Add To Cart Successfully"
        // or if quantity might have been updated for an existing item.
        await fetchCartItems();
      } else {
        errorMessage.value = response?['text'] as String? ?? 'Failed to add item to cart.';
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } on AppException catch (e) {
      errorMessage.value = e.message ?? 'Could not add item.';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      print("CartController addToCart error: $e");
    } finally {
      isAddingToCart.value = false;
    }
  }

  void _calculateTotals() {
    double sub = 0.0;
    for (var item in cartItems) {
      // Ensure quantity is at least 1 for calculation if API issue exists
      sub += item.price * (item.quantity > 0 ? item.quantity : 1);
    }
    cartSubtotal.value = sub;
    cartTotal.value = sub; // For now, total is same as subtotal. Add shipping/taxes later.
    print("CartController: Totals calculated. Subtotal: $cartSubtotal, Total: $cartTotal");
  }

  Future<void> updateQuantity(int cartId, int newQuantity) async {
    if (isUpdatingCart.value) return;
    if (newQuantity <= 0) {
      await removeCartItem(cartId);
      return;
    }

    final originalItemIndex = cartItems.indexWhere((item) => item.cartId == cartId);
    if (originalItemIndex == -1) return;
    final originalQuantity = cartItems[originalItemIndex].quantity;

    // Optimistic UI update
    _updateLocalItemQuantity(cartId, newQuantity);

    try {
      isUpdatingCart.value = true;
      final response = await _cartRepository.updateCartItemQuantity(cartId: cartId, quantity: newQuantity);
      if (response == null || response['type'] != 'success') {
        // Revert optimistic update on failure
        _updateLocalItemQuantity(cartId, originalQuantity);
        Get.snackbar('Error', response?['text'] ?? 'Failed to update quantity.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      }
      // On success, UI is already updated. Optionally, re-fetch to ensure consistency.
      // await fetchCartItems(); // Uncomment if you prefer to rely on API truth after update
    } on AppException catch (e) {
      _updateLocalItemQuantity(cartId, originalQuantity); // Revert
      Get.snackbar('Error', e.message ?? 'Could not update quantity.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      _updateLocalItemQuantity(cartId, originalQuantity); // Revert
      Get.snackbar('Error', 'An error occurred while updating quantity.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      print("CartController updateQuantity error: $e");
    } finally {
      isUpdatingCart.value = false;
    }
  }

  // Helper for local UI update
  void _updateLocalItemQuantity(int cartId, int quantity) {
    final index = cartItems.indexWhere((item) => item.cartId == cartId);
    if (index != -1) {
      // Create a new CartItemModel instance to ensure reactivity
      final oldItem = cartItems[index];
      cartItems[index] = CartItemModel(
        cartId: oldItem.cartId,
        productId: oldItem.productId,
        uid: oldItem.uid,
        productName: oldItem.productName,
        title: oldItem.title,
        printedPrice: oldItem.printedPrice,
        price: oldItem.price,
        stock: oldItem.stock, // Stock info might be useful here
        mainImage: oldItem.mainImage,
        otherImages: oldItem.otherImages,
        optionName: oldItem.optionName,
        optionValue: oldItem.optionValue,
        quantity: quantity, // Updated quantity
        // Ensure all other fields from CartItemModel are copied
        groupId: oldItem.groupId,
        sku: oldItem.sku,
        barCode: oldItem.barCode,
        tags: oldItem.tags,
      );
      cartItems.refresh();
      _calculateTotals();
    }
  }


  Future<void> removeCartItem(int cartId) async {
    if (isUpdatingCart.value) return;

    // Store the item in case we need to revert
    final itemToRemoveIndex = cartItems.indexWhere((item) => item.cartId == cartId);
    if (itemToRemoveIndex == -1) return;
    final itemToRemove = cartItems[itemToRemoveIndex];

    // Optimistic UI update
    cartItems.removeAt(itemToRemoveIndex);
    cartItems.refresh();
    _calculateTotals();

    try {
      isUpdatingCart.value = true;
      final response = await _cartRepository.removeCartItem(cartId: cartId);
      if (response == null || response['type'] != 'success') {
        // Revert optimistic update
        cartItems.insert(itemToRemoveIndex, itemToRemove);
        cartItems.refresh();
        _calculateTotals();
        Get.snackbar('Error', response?['text'] ?? 'Failed to remove item.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      }
      // On success, UI is already updated. Optionally, re-fetch.
      // await fetchCartItems();
    } on AppException catch (e) {
      cartItems.insert(itemToRemoveIndex, itemToRemove); // Revert
      cartItems.refresh();
      _calculateTotals();
      Get.snackbar('Error', e.message ?? 'Could not remove item.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      cartItems.insert(itemToRemoveIndex, itemToRemove); // Revert
      cartItems.refresh();
      _calculateTotals();
      Get.snackbar('Error', 'An error occurred while removing item.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      print("CartController removeCartItem error: $e");
    } finally {
      isUpdatingCart.value = false;
    }
  }

  Future<Map<String, dynamic>?> placeOrder({
    required String userName,
    required String userMobile,
    required String paymentMode,
  }) async {
    if (selectedShippingAddress.value == null) {
      errorMessage.value = "Please select a shipping address.";
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      return null;
    }
    if (cartItems.isEmpty) {
      errorMessage.value = "Your cart is empty. Please add items to proceed.";
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      return null;
    }

    isLoading.value = true; // General loading for placing order
    errorMessage.value = '';

    try {
      final address = selectedShippingAddress.value!;
      final List<OrderItemModel> orderItemsList = cartItems.map((cartItem) {
        // CRITICAL: Determine the correct variantId for OrderItemModel
        // The /api/cart response gives 'product_id' and cart 'id'. 'addToCart' used 'variantId'.
        // Assuming cartItem.productId IS the variantId for the purpose of placing the order.
        // If your system has distinct product_id and variant_id, and variant_id is needed for order,
        // then /api/cart needs to provide this variant_id.
        // For now, we use cartItem.productId as the best available identifier for the specific item/variant.
        int variantIdForOrder = cartItem.productId; // Placeholder: This needs to be the actual variant ID

        // If the cart item ID itself (`cartItem.cartId`) is meant to be the variant ID for some reason:
        // int variantIdForOrder = cartItem.cartId;

        // If there's a specific `variant_id` stored in `CartItemModel` (if you added it), use that.
        // e.g., if CartItemModel had `final int variantIdFromApi;`
        // int variantIdForOrder = cartItem.variantIdFromApi;


        // This is a fallback logic. You need to confirm how to get the correct variantId for each cart item.
        // The most robust solution is for the /api/cart endpoint to return the variant_id for each item.
        // Let's assume for now, for demonstration, product_id serves as variant_id for the order.
        // You *must* verify this for your system.

        return OrderItemModel(
          // variantId: cartItem.variantId, // If CartItemModel had a variantId field from API
          variantId: variantIdForOrder, // Using productId as a stand-in for variantId
          productId: cartItem.productId,
          productName: cartItem.productName,
          quantity: cartItem.quantity > 0 ? cartItem.quantity : 1, // Ensure quantity is at least 1
          optionName: cartItem.optionName,
          optionValue: cartItem.optionValue,
          price: cartItem.price,
          printedPrice: cartItem.printedPrice,
        );
      }).toList();

      final Map<String, dynamic>? orderResponse = await _orderRepository.addOrder(
        userName: userName,
        userMobile: userMobile,
        shippingPin: address.pincode,
        shippingAddress: "${address.addressLine1}, ${address.addressLine2}, ${address.city}, ${address.state}, ${address.country}",
        paymentMode: paymentMode,
        orderItems: orderItemsList,
      );

      if (orderResponse != null && orderResponse['type'] == 'success') {
        Get.snackbar(
            'Order Placed!',
            'Your order (ID: ${orderResponse['order_id']}) has been placed successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: const Duration(seconds: 4)
        );
        await fetchCartItems(); // Refresh cart (should be empty now)
        selectedShippingAddress.value = null; // Reset selected address
        return orderResponse;
      } else {
        errorMessage.value = orderResponse?['text'] as String? ?? 'Failed to place order. Please try again.';
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
        return null;
      }
    } on AppException catch (e) {
      errorMessage.value = e.message ?? 'Order placement failed.';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      return null;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred while placing your order.';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      print("CartController placeOrder error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void clearLocalCart() { // Call this on logout or if needed
    cartItems.clear();
    _calculateTotals();
    selectedShippingAddress.value = null;
    errorMessage.value = '';
  }
}