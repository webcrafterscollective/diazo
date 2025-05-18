// lib/core/constants/app_constants.dart
class AppConstants {
  static const String baseUrl = 'https://diazoo.com'; // Or your actual base URL like 'http://127.0.0.1:8000'
  static const String apiUrl = '$baseUrl/api'; //

  static const String currencySymbol = '₹'; //

  // Existing API Endpoints
  static const String loginEndpoint = '/login'; //
  static const String registerEndpoint = '/register'; //
  static const String categoryEndpoint = '/category'; //
  static const String subCategoryEndpoint = '/sub-category'; //
  static const String itemEndpoint = '/item'; //
  static const String brandEndpoint = '/brand'; //
  static const String productEndpoint = '/product'; //
  static const String productDetailsEndpoint = '/product-details'; //
  static const String profileEndpoint = '/profile'; //
  static const String passwordEndpoint = '/password'; //
  static const String addAddressEndpoint = '/add-address'; //
  static const String getAddressEndpoint = '/get-address'; //
  static const String getOtpEndpoint = '/get-otp'; //
  static const String verifyOtpEndpoint = '/verify-otp'; //
  static const String accountDeleteEndpoint = '/account-delete'; //
  static const String orderEndpoint = '/order'; //
  static const String orderDetailsEndpoint = '/order-details'; //
  // static const String wishlistEndpoint = '/wishlist'; // Get wishlist
  static const String filterEndpoint = '/filter'; //
  static const String filterProductEndpoint = '/filter-product'; //

  // --- Added Endpoints ---
  // static const String addWishlistEndpoint = '/add-wishlist';     // POST: Add to wishlist
  static const String addToCartEndpoint = '/add-to-cart';       // POST: Add to cart
  static const String cartEndpoint = '/cart';                 // POST: Get cart items
  static const String addOrderEndpoint = '/add-order';          // POST: Place new order
  // Add remove wishlist/cart item endpoints if they exist in your API
  static const String wishlistEndpoint = '/wishlist';           // GET: Get wishlist items
  static const String addWishlistEndpoint = '/add-wishlist';
  // static const String removeWishlistEndpoint = '/remove-wishlist';
  // static const String updateCartEndpoint = '/update-cart';
  // static const String removeCartEndpoint = '/remove-cart';
  // --- End Added Endpoints ---


  // Helper to build image URLs (ensure this logic matches your server setup)
  static String buildImageUrl(String? imagePath) { //
    if (imagePath == null || imagePath.trim().isEmpty) { //
      return ''; // Return empty string for null or empty path
    }
    final trimmedPath = imagePath.trim(); //
    // If it's already a full URL, return it directly
    if (trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://')) { //
      return trimmedPath; //
    }
    // Construct the full URL using the base URL
    final baseUrl = AppConstants.baseUrl.endsWith('/') //
        ? AppConstants.baseUrl //
        : '${AppConstants.baseUrl}/'; //
    // Decide if 'manual_storage/' prefix is needed based on API response structure
    // If API returns '/manual_storage/image.jpg', you might not need the prefix here.
    // If API returns just 'image.jpg', you likely need the prefix.
    const pathSegment = "manual_storage/"; // Adjust or remove if needed
    final path = trimmedPath.startsWith('/') ? trimmedPath.substring(1) : trimmedPath; //

    // Check if the path already contains the segment to avoid duplication
    if (path.startsWith(pathSegment)) { //
      return '$baseUrl$path'; //
    } else { //
      return '$baseUrl$pathSegment$path'; //
    }
  }
}