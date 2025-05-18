import 'package:diazoo_ecom/core/views/signup_view.dart';
import 'package:get/get.dart';
import '../middlewares/auth_middleware.dart';
import '../views/cart_view.dart';
import '../views/categories_view.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/order_details_view.dart';
import '../views/orders_view.dart';
import '../views/otp_view.dart';
import '../views/product_details_view.dart';
import '../views/profile_view.dart';
import '../views/wishlist_view.dart';


class AppRoutes {
  // Route names as constants
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders'; //
  static const String orderDetails = '/order-details';
  static const String wishlist = '/wishlist';
  static const String categories = '/categories';

  // Route list
  static final routes = [
    // GetPage(
    //   name: splash,
    //   page: () => const SplashScreen(),
    // ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
    ),

    GetPage(
      name: signup,
      page: () => SignUpScreen(),
    ),
    GetPage(
      name: otp,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: productDetails,
      page: () => const ProductDetailsScreen(),
      // Add binding if needed for screen-specific dependencies
      // binding: ProductDetailsBinding(),
      transition: Transition.rightToLeft, // Example transition
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: categories, // Add route entry
      page: () => CategoriesScreen(),
      // Add bindings if needed
    ),

    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(), // Ensure CartScreen view exists
      middlewares: [AuthMiddleware()], // Protected route
      transition: Transition.downToUp, // Example transition
    ),

    GetPage(
      name: orders,
      page: () => OrdersScreen(), // Create OrdersScreen view
      middlewares: [AuthMiddleware()], // Protected
    ),
    GetPage(
      name: orderDetails, // Define route for order details
      page: () => OrderDetailsScreen(), // Create OrderDetailsScreen view
      middlewares: [AuthMiddleware()], // Protected
      transition: Transition.rightToLeft, //
    ),
    GetPage(
      name: wishlist,
      page: () => WishlistScreen(), // Create WishlistScreen view
      middlewares: [AuthMiddleware()], // Protected route
    ),
    // GetPage(
    //   name: productDetails,
    //   page: () => const ProductDetailsScreen(),
    // ),
    // GetPage(
    //   name: cart,
    //   page: () => const CartScreen(),
    //   middlewares: [AuthMiddleware()],
    // ),
    // GetPage(
    //   name: checkout,
    //   page: () => const CheckoutScreen(),
    //   middlewares: [AuthMiddleware()],
    // ),
    // GetPage(
    //   name: orders,
    //   page: () => const OrdersScreen(),
    //   middlewares: [AuthMiddleware()],
    // ),
    // GetPage(
    //   name: wishlist,
    //   page: () => const WishlistScreen(),
    //   middlewares: [AuthMiddleware()],
    // ),
  ];
}