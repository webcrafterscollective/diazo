// lib/core/controllers/wishlist_controller.dart
import 'package:get/get.dart';
import '../repositories/wishlist_repository.dart'; //
import '../models/product_model.dart';
import 'auth_controller.dart'; //

class WishlistController extends GetxController { //
  final WishlistRepository _wishlistRepository = Get.find<WishlistRepository>();
  final AuthController _authController = Get.find<AuthController>(); // Get AuthController instance

  final RxList<ProductModel> wishlistItems = <ProductModel>[].obs; //
  final RxBool isLoading = false.obs; // General loading for fetch
  final RxBool isUpdating = false.obs; // Specific loading for add/remove
  final RxString errorMessage = ''.obs; //

  @override
  void onInit() {
    super.onInit();
    // Fetch wishlist only if the user is logged in
    if (_authController.isLoggedIn.value) { // <--- ADD THIS CHECK
      fetchWishlist();
    } else {
      print("WishlistController: User not logged in. Skipping initial wishlist fetch.");
      wishlistItems.clear(); // Ensure wishlist is empty for guest users
    }
  }

  // Fetch the full wishlist
  Future<void> fetchWishlist() async { //
    try {
      isLoading.value = true; //
      errorMessage.value = ''; //

      final items = await _wishlistRepository.getWishlist(); //
      wishlistItems.assignAll(items); //

    } catch (e) {
      errorMessage.value = e.toString(); //
      // Avoid showing snackbar automatically on fetch error
    } finally {
      isLoading.value = false; //
    }
  }

  // Check if a product (by ID) is currently in the wishlist
  bool isProductInWishlist(int productId) { //
    return wishlistItems.any((product) => product.id == productId); //
  }

  // Add an item to the wishlist
  Future<void> addToWishlist(int productId, int variantId) async { //
    if (isUpdating.value) return; // Prevent concurrent updates

    isUpdating.value = true; //
    errorMessage.value = ''; //
    try {
      final success = await _wishlistRepository.addWishlist(productId, variantId); //
      if (success) {
        // OPTION 1: Refresh the whole list (simpler)
        await fetchWishlist(); //
        Get.snackbar('Success', 'Added to Wishlist!', snackPosition: SnackPosition.BOTTOM); //
        // OPTION 2: Add locally (faster UI, but needs ProductModel instance)
        // Requires fetching ProductModel data first if not available
        // final productToAdd = await fetchProductDetailsIfNeeded(productId);
        // if (productToAdd != null && !isProductInWishlist(productId)) {
        //    wishlistItems.add(productToAdd);
        // }
      } else {
        Get.snackbar('Error', 'Failed to add item to wishlist.', snackPosition: SnackPosition.BOTTOM); //
      }
    } catch (e) {
      errorMessage.value = e.toString(); //
      Get.snackbar('Error', 'Could not add to wishlist: ${e.toString()}', snackPosition: SnackPosition.BOTTOM); //
    } finally {
      isUpdating.value = false; //
    }
  }

  // --- OPTIONAL: Remove item from wishlist ---
  Future<void> removeFromWishlist(int productId, int variantId) async { //
    // *** IMPORTANT: Requires implementation in WishlistRepository and a backend endpoint ***
    if (isUpdating.value) return;

    isUpdating.value = true; //
    errorMessage.value = ''; //
    try {
      final success = await _wishlistRepository.removeWishlist(productId, variantId); //
      if (success) {
        // OPTION 1: Refresh the whole list
        await fetchWishlist(); //
        Get.snackbar('Success', 'Removed from Wishlist!', snackPosition: SnackPosition.BOTTOM); //
        // OPTION 2: Remove locally
        // wishlistItems.removeWhere((p) => p.id == productId);
      } else {
        Get.snackbar('Error', 'Failed to remove item from wishlist.', snackPosition: SnackPosition.BOTTOM); //
      }
    } catch (e) {
      errorMessage.value = e.toString(); //
      Get.snackbar('Error', 'Could not remove from wishlist: ${e.toString()}', snackPosition: SnackPosition.BOTTOM); //
    } finally {
      isUpdating.value = false; //
    }
  }
// --- End Optional Remove ---

}