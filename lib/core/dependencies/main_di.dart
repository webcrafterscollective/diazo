import 'package:diazoo_ecom/core/services/storage_service.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../network/api_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wishlist_controller.dart';

class DependencyInjection {
  static void init() {
    // Register API Provider
    Get.lazyPut(() => ApiProvider(), fenix: true);

    // Register Services
    Get.lazyPut(() => StorageService(), fenix: true);

    // Register Repositories
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => OrderRepository(), fenix: true);
    Get.lazyPut(() => ProductRepository(), fenix: true);
    Get.lazyPut(() => UserRepository(), fenix: true);
    Get.lazyPut(() => WishlistRepository(), fenix: true);

    // Register Controllers
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);
    Get.lazyPut(() => ProductController(), fenix: true);
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => WishlistController(), fenix: true);

    // Cart
    Get.lazyPut(() => CartRepository(), fenix: true); // Register CartRepository
    Get.lazyPut(() => CartController(), fenix: true);   // Register CartController
  }
}