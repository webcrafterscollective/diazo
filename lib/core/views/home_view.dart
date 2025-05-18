// // lib/core/views/home_view.dart
// import 'package:diazoo_ecom/core/views/categories_view.dart'; // Contains buildImageUrl
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// import '../constants/app_colors.dart';
// import '../constants/app_constants.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/product_controller.dart';
// import '../controllers/cart_controller.dart'; // Needed for bottom nav
// import '../controllers/wishlist_controller.dart'; // Needed for bottom nav
// import '../routes/routes.dart';
// import '../services/storage_service.dart';
// import '../widgets/category_card.dart';
// import '../widgets/product_card.dart';
// import '../models/category_model.dart';
// import '../models/product_model.dart';
// import '../widgets/loading_indicator.dart';
// import '../widgets/custom_button.dart'; // Needed for filter sheet
//
//
// class HomeScreen extends StatelessWidget {
//   // Find necessary controllers
//   final ProductController _productController = Get.find<ProductController>();
//   final AuthController _authController = Get.find<AuthController>();
//   final CartController _cartController = Get.find<CartController>();
//   final WishlistController _wishlistController = Get.find<WishlistController>();
//   final TextEditingController _searchController = TextEditingController();
//
//   HomeScreen({super.key});
//
//   // --- Method to show the filter bottom sheet ---
//   // (Keeping the previous implementation with dummy data for filter options)
//   void _showFilterBottomSheet(BuildContext context) {
//     // --- Dummy Data based on your sample /filter response ---
//     // In a real implementation, this would come from _productController.filterOptions
//     final Map<String, List<String>> dynamicFilters = {
//       "Trending": ["Rr", "Red"], "Abc": ["Www", "Xl"], "Color": ["Red", "Green"],
//       "Size": ["Xxl", "Xs"], "Hh": ["Regular"], "Test1": ["Test Value1"],
//       "Test2": ["Test Value2", "4"], "Test3": ["Test Value3", "74"]
//     };
//     final List<String> brands = ["Laptop"]; // Example Brand
//     // --- End Dummy Data ---
//
//     // Temporary state holders for the bottom sheet
//     String? selectedSortBy;
//     RangeValues currentPriceRange = const RangeValues(0, 10000); // Example initial range
//     // Use a Map to hold selected dynamic filter values: Map<FilterName, List<SelectedValues>>
//     Map<String, List<String>> selectedDynamicFilters = {};
//     // Initialize map keys to avoid null checks later
//     for (var key in dynamicFilters.keys) {
//       selectedDynamicFilters[key] = [];
//     }
//     List<String> selectedBrands = [];
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Allows sheet to take more height
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
//       ),
//       builder: (ctx) {
//         // Use StatefulBuilder to manage state within the bottom sheet
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Container(
//               // Allow height up to 85% of screen
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.85,
//               ),
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min, // Take needed height
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // --- Header ---
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text("Filters",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () => Navigator.pop(ctx),
//                       )
//                     ],
//                   ),
//                   const Divider(),
//                   // --- Scrollable Filter Content ---
//                   Expanded(
//                     child: ListView(
//                       // Use ListView for potentially long filter lists
//                       shrinkWrap: true,
//                       children: [
//                         // --- Sort By ---
//                         _buildSortByFilter(selectedSortBy, (newValue) {
//                           setModalState(() => selectedSortBy = newValue);
//                         }),
//                         const SizedBox(height: 16),
//
//                         // --- Price Range ---
//                         _buildPriceRangeFilter(currentPriceRange, (newRange) {
//                           setModalState(() => currentPriceRange = newRange);
//                         }),
//                         const SizedBox(height: 16),
//
//                         // --- Brands Filter ---
//                         if (brands.isNotEmpty) ...[
//                           const Text("Brands",
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.w600)),
//                           _buildCheckboxGroupFilter(brands, selectedBrands,
//                                   (brand, isSelected) {
//                                 setModalState(() {
//                                   if (isSelected) {
//                                     selectedBrands.add(brand);
//                                   } else {
//                                     selectedBrands.remove(brand);
//                                   }
//                                 });
//                               }),
//                           const SizedBox(height: 16),
//                         ],
//
//                         // --- Dynamic Filters ---
//                         ...dynamicFilters.entries.map((entry) {
//                           final filterName = entry.key;
//                           final filterValues = entry.value;
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(filterName,
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600)),
//                               _buildCheckboxGroupFilter(filterValues,
//                                   selectedDynamicFilters[filterName] ?? [],
//                                       (value, isSelected) {
//                                     setModalState(() {
//                                       if (isSelected) {
//                                         selectedDynamicFilters[filterName]
//                                             ?.add(value);
//                                       } else {
//                                         selectedDynamicFilters[filterName]
//                                             ?.remove(value);
//                                       }
//                                     });
//                                   }),
//                               const SizedBox(height: 16),
//                             ],
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//                   // --- Action Buttons ---
//                   const Divider(),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 10.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         OutlinedButton(
//                           onPressed: () {
//                             // Clear selections within the modal
//                             setModalState(() {
//                               selectedSortBy = null;
//                               currentPriceRange = const RangeValues(0, 10000);
//                               selectedDynamicFilters.keys.forEach((key) {
//                                 selectedDynamicFilters[key] = [];
//                               });
//                               selectedBrands.clear();
//                             });
//                             _productController.fetchProducts(); // Fetch default products after clearing UI
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: AppColors.primary),
//                             foregroundColor: AppColors.primary,
//                           ),
//                           child: const Text("Clear All"),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             // Apply filters using the ProductController
//                             _productController.applyFilters(
//                               sortBy: selectedSortBy,
//                               minPrice: currentPriceRange.start,
//                               maxPrice: currentPriceRange.end,
//                               dynamicFilters: selectedDynamicFilters,
//                               // Pass selected brand ID(s) if structure allows
//                               // brandId: selectedBrands.isNotEmpty ? findBrandId(selectedBrands.first) : null, // Needs brand ID lookup
//                             );
//                             Navigator.pop(ctx); // Close bottom sheet
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: const Text("Apply Filters"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // Handle arguments passed from CategoriesScreen or other sources
//     // This runs after the first frame is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Read arguments passed via Get.toNamed(..., arguments: ...)
//       final arguments = Get.arguments as Map<String, dynamic>?;
//       if (arguments != null) {
//         // Extract arguments if they exist
//         final categoryId = arguments['categoryId'] as int?;
//         final subCategoryId = arguments['subCategoryId'] as int?;
//         print("HomeScreen received arguments: cat=$categoryId, subCat=$subCategoryId"); // Debug log
//         // Fetch products based on arguments
//         // Check if these are different from current filters before fetching? (Optional optimization)
//         _productController.fetchProducts(
//             categoryId: categoryId,
//             subCategoryId: subCategoryId
//         );
//         // Arguments are read only once per navigation event, no need to clear manually.
//       } else if (_productController.products.isEmpty && !_productController.isLoading.value) {
//         // Initial fetch only if products are empty and not already loading
//         print("HomeScreen: No arguments, fetching initial categories and products."); // Debug log
//         _productController.fetchCategories();
//         _productController.fetchProducts();
//       }
//     });
//
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             _searchController.clear();
//             // When refreshing, fetch default lists
//             await _productController.fetchCategories();
//             await _productController.fetchProducts(); // Fetches without specific filters
//           },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _buildTopBar(context)),
//                 const SizedBox(height: 16),
//                 Padding( // Search Bar and Filter Button
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     children: [
//                       Expanded(child: _buildSearchBar(context)),
//                       const SizedBox(width: 8),
//                       IconButton( // Filter Button
//                         icon: Icon(Icons.filter_list, color: AppColors.primary),
//                         onPressed: () => _showFilterBottomSheet(context),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildFeaturedBanner(context),
//                 const SizedBox(height: 20),
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _buildSectionHeader(context, 'All Categories', () {
//                       Get.toNamed(AppRoutes.categories); // Navigate to categories screen
//                     })),
//                 const SizedBox(height: 12),
//                 _buildCategoryList(context),
//                 const SizedBox(height: 20),
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _buildSectionHeader(context, 'Popular Products', () {
//                       // TODO: Navigate to a 'Popular Products' screen or apply filter
//                     })),
//                 const SizedBox(height: 12),
//                 _buildHorizontalProductList(context), // Shows subset of products horizontally
//                 const SizedBox(height: 20),
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _buildSectionHeader(context, 'All Products', () {
//                       // TODO: Navigate to an 'All Products' screen or clear filters
//                       _productController.fetchProducts(); // Example: fetch all
//                     })),
//                 const SizedBox(height: 12),
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _buildVerticalProductGrid(context)), // Shows products vertically in a grid
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(context),
//     );
//   }
//
//   // --- Shimmer Placeholders ---
//   Widget _buildShimmerFeaturedBanner() {
//     return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
//         child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16.0), height: 150,
//             decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(12))));
//   }
//
//   Widget _buildShimmerCategoryCard() {
//     return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
//         child: SizedBox( width: 75,
//             child: Column(children: [
//               AspectRatio( aspectRatio: 1.0, child: Container( decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(12)))),
//               const SizedBox(height: 6),
//               Container(height: 10, width: 50, color: Colors.white)
//             ])));
//   }
//
//   Widget _buildShimmerProductCard() {
//     return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
//         child: Card(
//             elevation: 1.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), clipBehavior: Clip.antiAlias,
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               AspectRatio( aspectRatio: 1.2, child: Container(color: Colors.white)), // Match ProductCard aspect ratio
//               Padding( padding: const EdgeInsets.all(8.0),
//                   child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Container( height: 14, width: double.infinity, color: Colors.white),
//                     const SizedBox(height: 4),
//                     Container(height: 14, width: 100, color: Colors.white),
//                     const SizedBox(height: 8),
//                     Container(height: 16, width: 50, color: Colors.white)
//                   ])) ])));
//   }
//
//   // --- Builder Methods ---
//
//   Widget _buildTopBar(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Image.asset('assets/logo.png', height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40)), // Ensure logo exists
//         Row(
//           children: [
//             IconButton( icon: Icon(Icons.call_outlined, color: AppColors.primary), onPressed: () { /* TODO: Implement Call */ print('Call Tapped'); }),
//             IconButton( icon: Icon(Icons.notifications_none_outlined, color: AppColors.primary), onPressed: () { /* TODO: Implement Notifications */ print('Notifications Tapped'); }),
//             IconButton( // Settings Icon Navigation
//               icon: Icon(Icons.settings_outlined, color: AppColors.primary),
//               onPressed: () {
//                 if (_authController.requireLogin(actionName: 'view your profile')) {
//                   Get.toNamed(AppRoutes.profile); // Navigate only if logged in
//                 }
//               },
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   Widget _buildSearchBar(BuildContext context) {
//     return TextField(
//       controller: _searchController,
//       readOnly: true, // Make search bar read-only for now
//       onTap: () {
//         // TODO: Implement search functionality - Navigate to a search screen or show overlay
//         Get.snackbar('Info', 'Search not implemented yet.', snackPosition: SnackPosition.BOTTOM);
//       },
//       decoration: InputDecoration(
//         hintText: "Search products...",
//         prefixIcon: const Icon(Icons.search, color: Colors.grey),
//         filled: true, fillColor: AppColors.inputBackground,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//         border: OutlineInputBorder( borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
//         focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
//       ),
//     );
//   }
//
//   Widget _buildFeaturedBanner(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return Obx(() {
//       final product = _productController.featuredProduct.value;
//       final isLoading = _productController.isLoading.value;
//       if (isLoading && product == null) { return _buildShimmerFeaturedBanner(); }
//       if (product == null) { return const SizedBox.shrink(); } // Hide if no featured product
//
//       final imageUrl = buildImageUrl(product.mainImage); // Use helper defined above
//       return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16.0), height: 150,
//           decoration: BoxDecoration( color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//           child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Row(children: [
//                 Expanded( flex: 2,
//                     child: CachedNetworkImage( // Use CachedNetworkImage
//                         imageUrl: imageUrl,
//                         placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(color: Colors.white)),
//                         errorWidget: (c, u, e) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
//                         fit: BoxFit.cover, height: double.infinity)),
//                 Expanded( flex: 3,
//                     child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text("Featured", style: textTheme.labelSmall?.copyWith(color: AppColors.primary)),
//                               const SizedBox(height: 4),
//                               Text(product.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
//                               const SizedBox(height: 4),
//                               Text('${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}', style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
//                               const SizedBox(height: 8),
//                               ElevatedButton( // Use ElevatedButton
//                                   onPressed: () {
//                                     _productController.selectProduct(product);
//                                     Get.toNamed(AppRoutes.productDetails, arguments: product); // Pass product data
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.primary, foregroundColor: Colors.white,
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), textStyle: textTheme.labelMedium,
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//                                   child: const Text('View Details')) ]))) ]))); });
//   }
//
//   Widget _buildCategoryList(BuildContext context) {
//     return SizedBox(
//       height: 110, // Adjust height as needed
//       child: Obx(() {
//         final isLoading = _productController.isLoading.value;
//         final categories = _productController.categories;
//
//         if (isLoading && categories.isEmpty) { // Loading state
//           return ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0), scrollDirection: Axis.horizontal, itemCount: 6,
//               separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, __) => _buildShimmerCategoryCard());
//         }
//         if (_productController.errorMessage.value.isNotEmpty && categories.isEmpty) { // Error state
//           return Center(child: Text('Error: ${_productController.errorMessage.value}'));
//         }
//         if (categories.isEmpty) { // Empty state
//           return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('No categories found.')));
//         }
//
//         // Display categories
//         final displayedCategories = categories.take(8).toList(); // Limit displayed categories if needed
//         return ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0), scrollDirection: Axis.horizontal,
//           itemCount: displayedCategories.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
//           itemBuilder: (context, index) {
//             final category = displayedCategories[index];
//             return GestureDetector(
//                 onTap: () {
//                   // Fetch products for this category when tapped
//                   _productController.fetchProducts(categoryId: category.id);
//                   // Optionally navigate to a dedicated category/product list screen
//                   // Get.toNamed(AppRoutes.productList, arguments: {'categoryId': category.id});
//                 },
//                 child: CategoryCard(imageUrl: category.img, title: category.name));
//           },
//         );
//       }),
//     );
//   }
//
//   Widget _buildHorizontalProductList(BuildContext context) {
//     return SizedBox(
//       height: 250, // Adjust height as needed for ProductCard size
//       child: Obx(() {
//         final isLoading = _productController.isLoading.value;
//         final products = _productController.products;
//         final featuredId = _productController.featuredProduct.value?.id;
//
//         // Example: filter out the featured product if needed, or show a specific subset
//         final popularProducts = products.where((p) => p.id != featuredId).take(6).toList(); // Example: Show first 6 non-featured
//
//         if (isLoading && popularProducts.isEmpty) { // Loading state (only show if list would be empty)
//           return ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0), scrollDirection: Axis.horizontal, itemCount: 4,
//               separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, __) => SizedBox(width: 150, child: _buildShimmerProductCard()));
//         }
//         if (_productController.errorMessage.value.isNotEmpty && popularProducts.isEmpty) { // Error state
//           return Center(child: Text('Error: ${_productController.errorMessage.value}'));
//         }
//         if (popularProducts.isEmpty) { // Empty state
//           return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('No popular products found.')));
//         }
//
//         // Display products
//         return ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0), scrollDirection: Axis.horizontal,
//           itemCount: popularProducts.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
//           itemBuilder: (context, index) {
//             final product = popularProducts[index];
//             return SizedBox(
//                 width: 150, // Fixed width for horizontal cards
//                 child: GestureDetector(
//                     onTap: () {
//                       _productController.selectProduct(product);
//                       Get.toNamed(AppRoutes.productDetails, arguments: product);
//                     },
//                     child: ProductCard(product: product)));
//           },
//         );
//       }),
//     );
//   }
//
//   Widget _buildVerticalProductGrid(BuildContext context) {
//     return Obx(() {
//       final isLoading = _productController.isLoading.value;
//       final products = _productController.products;
//       final errorMessage = _productController.errorMessage.value;
//
//       if (isLoading && products.isEmpty) { // Loading state
//         return GridView.builder(
//             itemCount: 6, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.65),
//             itemBuilder: (context, index) => _buildShimmerProductCard());
//       }
//       if (errorMessage.isNotEmpty && products.isEmpty) { // Error state
//         return Center(child: Text('Error: $errorMessage'));
//       }
//       if (products.isEmpty) { // Empty state
//         // Show message if filters might be applied
//         if (_productController.selectedCategoryId.value != -1 ||
//             _productController.selectedSubCategoryId.value != -1 ||
//             _productController.selectedItemId.value != -1 /* add other filter checks */ ) {
//           return const Center(child: Text('No products found matching your filters.'));
//         }
//         return const Center(child: Text('No products found.'));
//       }
//
//       // Display products in a grid
//       return GridView.builder(
//           itemCount: products.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.65), // Adjust aspect ratio as needed
//           itemBuilder: (context, index) {
//             final product = products[index];
//             return GestureDetector(
//                 onTap: () {
//                   _productController.selectProduct(product);
//                   Get.toNamed(AppRoutes.productDetails, arguments: product);
//                 },
//                 child: ProductCard(product: product));
//           });
//     });
//   }
//
//   Widget _buildSectionHeader( BuildContext context, String title, VoidCallback onSeeAll) {
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
//       TextButton(
//           onPressed: onSeeAll, style: TextButton.styleFrom( padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
//           child: Text('See All', style: TextStyle(color: AppColors.primary, fontSize: 13)))
//     ]);
//   }
//
//   Widget _buildBottomNavigationBar(BuildContext context) {
//     const currentIndex = 0; // Hardcoded for now
//
//     return BottomNavigationBar(
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.grey[600],
//       type: BottomNavigationBarType.fixed, // Ensures all labels are visible
//       showUnselectedLabels: true, // Show labels for unselected items
//       selectedFontSize: 12, // Adjust font size if needed
//       unselectedFontSize: 12, // Adjust font size if needed
//       currentIndex: currentIndex, // Use state variable here
//       onTap: (index) {
//         if (index == currentIndex) return; // Do nothing if tapping the current tab
//
//         switch (index) {
//           case 0: break; // Home - Already here
//           case 1: Get.toNamed(AppRoutes.categories); break; // Categories Tab
//           case 2: // Cart
//             if (_authController.requireLogin(actionName: 'view your cart')) {
//               _cartController.fetchCartItems(); // Fetch items when navigating
//               Get.toNamed(AppRoutes.cart);
//             } break;
//           case 3: // Wishlist
//           // --- Add Debug Prints Here ---
//             print("--- Wishlist Tap ---");
//             final authController = Get.find<AuthController>(); // Get instance
//             final storageService = Get.find<StorageService>(); // Get instance
//             print("HomeView Check: isLoggedIn.value = ${authController.isLoggedIn.value}");
//             print("HomeView Check: user.value = ${authController.user.value?.toJson()}"); // Print user data if exists
//             print("HomeView Check: getTokenSync() = ${storageService.getTokenSync()}");
//             print("--- End Wishlist Tap ---");
//             // --- End Debug Prints ---
//
//             if (authController.requireLogin(actionName: 'view your wishlist')) {
//               // _wishlistController.fetchWishlist(); // Maybe fetch *after* navigation or inside WishlistScreen.initState
//               Get.toNamed(AppRoutes.wishlist);
//             }
//             break;
//         }
//       },
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
//         BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Categories'),
//         BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
//         BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wish')
//       ],
//     );
//   }
//
//   // --- Filter Bottom Sheet Helper Widgets ---
//   Widget _buildSortByFilter(String? currentSelection, ValueChanged<String?> onChanged) {
//     final List<String> sortByOptions = ['Relevance', 'Price: Low to High', 'Price: High to Low', 'Newest Arrivals'];
//     return Column( crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Sort By", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         DropdownButton<String>(
//           value: currentSelection, isExpanded: true, hint: const Text("Select sorting"),
//           icon: const Icon(Icons.arrow_drop_down), elevation: 16,
//           underline: Container(height: 1, color: AppColors.divider),
//           onChanged: onChanged,
//           items: sortByOptions.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(value: value, child: Text(value));
//           }).toList(),
//         ), ], );
//   }
//
//   Widget _buildPriceRangeFilter(RangeValues currentRange, ValueChanged<RangeValues> onChanged) {
//     const double maxPrice = 10000.0; // Adjust max price based on your products
//     return Column( crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Price Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         RangeSlider(
//           values: currentRange, min: 0, max: maxPrice, divisions: 100, // More divisions for smoother sliding
//           labels: RangeLabels('${AppConstants.currencySymbol}${currentRange.start.round()}', '${AppConstants.currencySymbol}${currentRange.end.round()}',),
//           onChanged: onChanged, activeColor: AppColors.primary, inactiveColor: AppColors.primary.withOpacity(0.3),
//         ),
//         Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text('${AppConstants.currencySymbol}${currentRange.start.round()}'), Text('${AppConstants.currencySymbol}${currentRange.end.round()}'), ],)
//       ], );
//   }
//
//   Widget _buildCheckboxGroupFilter(List<String> options, List<String> currentSelections, Function(String value, bool isSelected) onChanged) {
//     return Wrap( spacing: 8.0, runSpacing: 0.0,
//       children: options.map((option) {
//         final bool isSelected = currentSelections.contains(option);
//         return ChoiceChip(
//           label: Text(option), selected: isSelected, onSelected: (selected) { onChanged(option, selected); },
//           selectedColor: AppColors.primary.withOpacity(0.15),
//           backgroundColor: AppColors.inputBackground,
//           labelStyle: TextStyle( fontSize: 13, color: isSelected ? AppColors.primary : AppColors.textPrimary.withOpacity(0.8), ),
//           shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(6), side: BorderSide( color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.border), ),
//           showCheckmark: false, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         ); }).toList(), );
//   }
//
// } // End of HomeScreen Class

// lib/core/views/home_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/filter_model.dart'; // Ensure this is your updated FilterModel
import '../models/item_model.dart';
import '../models/product_model.dart';
import '../models/sub_category_model.dart';
import '../routes/routes.dart';
import '../services/storage_service.dart'; // Required by bottom nav bar logic example
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
// import '../widgets/loading_indicator.dart'; // Uncomment if you have this widget

class HomeScreen extends StatelessWidget {
  final ProductController _productController = Get.find<ProductController>();
  final AuthController _authController = Get.find<AuthController>();
  final CartController _cartController = Get.find<CartController>();
  final WishlistController _wishlistController = Get.find<WishlistController>();
  final TextEditingController _searchController = TextEditingController();

  HomeScreen({super.key});

  // Helper to build image URL, ensure it's consistent with your AppConstants
  // This might be defined globally or in AppConstants as well.
  String _buildLocalImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '';
    }
    if (imagePath.trim().startsWith('http')) {
      return imagePath.trim();
    }
    final baseUrl = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl
        : '${AppConstants.baseUrl}/';
    // Assuming product.mainImage already contains "manual_storage/" if needed
    // Or, if it's just "products/imagename.jpg", the path construction is simpler:
    final path = imagePath.trim().startsWith('/')
        ? imagePath.substring(1)
        : imagePath.trim();
    // If your AppConstants.buildImageUrl handles all cases, prefer using that.
    // For this example, using a local one based on common patterns.
    return '$baseUrl$path';
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Attempt to fetch filters if they are not loaded for the current item context
    if (_productController.selectedItemId.value == -1 &&
        _productController.filterOptions.value == null) {
      Get.snackbar("Select an Item Category",
          "Please select a specific item category to see available filters.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white);
      return;
    } else if (_productController.selectedItemId.value != -1 &&
        (_productController.filterOptions.value == null ||
            _productController.isLoading.value)) {
      // If an item is selected, and filters are null or product controller is generally loading,
      // attempt to fetch and then inform the user.
      if (!_productController.isLoading.value) {
        // Avoid multiple calls if already loading
        _productController
            .fetchFilters(_productController.selectedItemId.value);
      }
      Get.snackbar("Loading Filters",
          "Filter options are being fetched. Please try again in a moment.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white);
      return;
    }

    final FilterModel? currentApiFilters =
        _productController.filterOptions.value;

    if (currentApiFilters == null) {
      Get.snackbar("Filters Not Available",
          "No filter options found for the current selection or they could not be loaded.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }

    final Map<String, List<String>> dynamicApiFilters =
        currentApiFilters.dynamicFilters ?? {};
    final List<String> apiBrands = currentApiFilters.brands ?? [];
    final double apiMinPrice = currentApiFilters.minPrice ?? 0.0;
    // Ensure apiMaxPrice is greater than apiMinPrice, provide a sensible default.
    final double apiMaxPrice = (currentApiFilters.maxPrice != null &&
            currentApiFilters.maxPrice! > apiMinPrice)
        ? currentApiFilters.maxPrice!
        : apiMinPrice + 10000.0;

    String? selectedSortBy;
    RangeValues currentPriceRange = RangeValues(apiMinPrice, apiMaxPrice);
    Map<String, List<String>> selectedDynamicFilters = {};
    dynamicApiFilters.forEach((key, valueList) {
      selectedDynamicFilters[key] = [];
    });
    List<String> selectedBrands = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filters & Sort",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSortByFilter(selectedSortBy, (newValue) {
                          setModalState(() => selectedSortBy = newValue);
                        }, context),
                        const SizedBox(height: 20),
                        if (apiMaxPrice > apiMinPrice) ...[
                          _buildPriceRangeFilter(currentPriceRange, (newRange) {
                            setModalState(() => currentPriceRange = newRange);
                          }, apiMinPrice, apiMaxPrice, context),
                          const SizedBox(height: 20),
                        ],
                        if (apiBrands.isNotEmpty) ...[
                          Text("Brands",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          _buildCheckboxGroupFilter("Brands", apiBrands,
                              selectedBrands, // GroupKey "Brands"
                              (brandName, isSelected) {
                            // `value` here is brandName
                            setModalState(() {
                              if (isSelected) {
                                selectedBrands.add(brandName);
                              } else {
                                selectedBrands.remove(brandName);
                              }
                            });
                          }),
                          const SizedBox(height: 20),
                        ],
                        ...dynamicApiFilters.entries.map((entry) {
                          final filterName = entry.key;
                          final filterValues = entry.value;
                          selectedDynamicFilters.putIfAbsent(
                              filterName, () => []);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(filterName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              _buildCheckboxGroupFilter(
                                  filterName, // Unique groupKey
                                  filterValues,
                                  selectedDynamicFilters[filterName]!,
                                  (value, isSelected) {
                                setModalState(() {
                                  final currentSelection =
                                      selectedDynamicFilters[filterName]!;
                                  if (isSelected) {
                                    currentSelection.add(value);
                                  } else {
                                    currentSelection.remove(value);
                                  }
                                });
                              }),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                selectedSortBy = null;
                                currentPriceRange =
                                    RangeValues(apiMinPrice, apiMaxPrice);
                                selectedDynamicFilters
                                    .forEach((key, value) => value.clear());
                                selectedBrands.clear();
                              });
                              _productController.resetFilters();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.textSecondary),
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Clear All"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Map<String, List<String>> filtersToApply = {};
                              selectedDynamicFilters.forEach((key, value) {
                                if (value.isNotEmpty) {
                                  filtersToApply[key] = List.from(value);
                                }
                              });

                              // Add selected brands to the dynamic filters if "Brands" is expected as a dynamic filter key
                              // Or handle brandNames separately in applyFilters if your backend expects that
                              if (selectedBrands.isNotEmpty) {
                                // Option 1: If backend expects brands under a specific dynamic filter key like "Brand" or "brand_name"
                                filtersToApply['brand_name'] =
                                    List.from(selectedBrands); // Example key
                                // Option 2: Or if your ProductController's applyFilters takes a separate brandNames list
                                // This would be handled by passing `brandNames: selectedBrands` to `applyFilters`.
                                // The current applyFilters in ProductController uses dynamicFilters.
                              }

                              _productController.applyFilters(
                                sortBy: selectedSortBy,
                                dynamicFilters: filtersToApply.isNotEmpty
                                    ? filtersToApply
                                    : null,
                                minPrice: currentPriceRange.start > apiMinPrice
                                    ? currentPriceRange.start
                                    : null,
                                maxPrice: currentPriceRange.end < apiMaxPrice
                                    ? currentPriceRange.end
                                    : null,
                              );
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Apply Filters"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortByFilter(String? currentSelection,
      ValueChanged<String?> onChanged, BuildContext context) {
    final List<Map<String, String>> sortByOptions = [
      {
        'value': 'relevance',
        'label': 'Relevance'
      }, // Default/Relevance often implies no specific sort param
      {'value': 'name_asc', 'label': 'Name: A to Z'},
      {'value': 'name_desc', 'label': 'Name: Z to A'},
      {'value': 'price_asc', 'label': 'Price: Low to High'},
      {'value': 'price_desc', 'label': 'Price: High to Low'},
      {'value': 'newest', 'label': 'Newest Arrivals'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Sort By",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: AppColors.border.withOpacity(0.7), width: 0.8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentSelection,
              isExpanded: true,
              hint: Text("Default",
                  style: TextStyle(color: AppColors.textSecondary)),
              icon: Icon(Icons.arrow_drop_down_rounded,
                  color: AppColors.textSecondary),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textPrimary),
              onChanged: onChanged,
              items: sortByOptions
                  .map<DropdownMenuItem<String>>((Map<String, String> option) {
                return DropdownMenuItem<String>(
                    value: option['value'], child: Text(option['label']!));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter(
      RangeValues currentRange,
      ValueChanged<RangeValues> onChanged,
      double actualMinPrice,
      double actualMaxPrice,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price Range",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        RangeSlider(
          values: currentRange,
          min: actualMinPrice,
          max: actualMaxPrice,
          divisions: (actualMaxPrice - actualMinPrice) > 1
              ? ((actualMaxPrice - actualMinPrice) / 10).round().clamp(10, 200)
              : 10,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.25),
          labels: RangeLabels(
            '${AppConstants.currencySymbol}${currentRange.start.round()}',
            '${AppConstants.currencySymbol}${currentRange.end.round()}',
          ),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${AppConstants.currencySymbol}${currentRange.start.round()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              Text('${AppConstants.currencySymbol}${currentRange.end.round()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCheckboxGroupFilter(
    String groupKey,
    List<String> options,
    List<String> currentSelections,
    Function(String value, bool isSelected) onChanged,
  ) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        final bool isSelected = currentSelections.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(option, selected);
          },
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary.withOpacity(0.9),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          selectedColor: AppColors.primary.withOpacity(0.12),
          backgroundColor: AppColors.inputBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.border.withOpacity(0.7),
              width: isSelected ? 1.3 : 0.8,
            ),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        final categoryId = arguments['categoryId'] as int?;
        final subCategoryId = arguments['subCategoryId'] as int?;
        final itemId = arguments['itemId'] as int?; // Check if itemId is passed

        print(
            "HomeScreen received arguments: cat=$categoryId, subCat=$subCategoryId, item=$itemId");

        if (itemId != null && itemId != -1) {
          _productController.selectItem(Get.find<ProductController>()
              .items
              .firstWhere((i) => i.id == itemId,
                  orElse: () => ItemModel(
                      id: -1,
                      name: '',
                      subCategoryId: -1,
                      image: ''))); // Fetch filters and products for this item
        } else if (subCategoryId != null && subCategoryId != -1) {
          _productController.selectSubCategory(Get.find<ProductController>()
              .subCategories
              .firstWhere((sc) => sc.id == subCategoryId,
                  orElse: () => SubCategoryModel(
                      id: -1, name: ''))); // Fetch items and products
        } else if (categoryId != null && categoryId != -1) {
          _productController.selectCategoryForView(
              categoryId); // Fetch subcategories and products
        }
      } else if (_productController.products.isEmpty &&
          !_productController.isLoading.value) {
        print(
            "HomeScreen: No arguments, fetching initial categories and products.");
        _productController
            .fetchCategories(); // Should trigger initial selection if implemented
        _productController.fetchProducts(); // Default products
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            _searchController.clear();
            // Reset selections in controller if any
            _productController.selectedCategoryId.value = -1;
            _productController.selectedSubCategoryId.value = -1;
            _productController.selectedItemId.value = -1;
            _productController.filterOptions.value =
                null; // Clear loaded filters
            // When refreshing, fetch default lists
            await _productController
                .fetchCategories(); // This might trigger initial subcat/item fetch if logic exists
            await _productController.fetchProducts();
          },
          child: CustomScrollView(
            // Use CustomScrollView for more complex scroll effects if needed
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                automaticallyImplyLeading: false, // No back button
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: _buildTopBar(context),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchBar(context)),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.filter_list_rounded,
                                color: AppColors.primary, size: 24),
                            onPressed: () => _showFilterBottomSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 12), // Space after app bar elements
                    _buildFeaturedBanner(context),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildSectionHeader(context, 'Shop by Category',
                            () {
                          Get.toNamed(AppRoutes.categories);
                        })),
                    const SizedBox(height: 12),
                    _buildCategoryList(context),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildSectionHeader(context, 'Popular Products',
                            () {
                          // TODO: Implement navigation or filter for "Popular Products"
                          _productController
                              .fetchProducts(); // Example: fetch all if no specific popular endpoint
                          Get.snackbar(
                              "Info", "Showing all products as 'Popular'.");
                        })),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList(context),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildSectionHeader(context, 'All Products', () {
                          _productController
                              .fetchProducts(); // Fetch all products
                        })),
                    const SizedBox(height: 12),
                    _buildVerticalProductGrid(context), // Products grid
                    const SizedBox(height: 20), // Padding at the bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // --- UI Builder Methods (TopBar, SearchBar, Banners, Lists, Grids, Headers, BottomNav) ---
  // (These methods were provided in the previous response and can be reused here)
  // Make sure _buildLocalImageUrl is used if ProductCard/CategoryCard don't handle full URL construction.

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/logo.png',
            height: 36,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.storefront_outlined, size: 36)),
        Row(
          children: [
            IconButton(
                icon: Icon(Icons.call_outlined,
                    color: AppColors.textSecondary, size: 22),
                onPressed: () {
                  /* TODO: Implement Call */ Get.snackbar(
                      'Info', 'Call Feature Not Implemented');
                }),
            IconButton(
                icon: Icon(Icons.notifications_none_outlined,
                    color: AppColors.textSecondary, size: 22),
                onPressed: () {
                  /* TODO: Implement Notifications */ Get.snackbar(
                      'Info', 'Notifications Not Implemented');
                }),
            IconButton(
              icon: Icon(Icons.person_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 24), // Changed to person
              onPressed: () {
                if (_authController.requireLogin(
                    actionName: 'view your profile')) {
                  Get.toNamed(AppRoutes.profile);
                }
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      readOnly: true,
      onTap: () {
        Get.snackbar('Info', 'Search screen not implemented yet.',
            snackPosition: SnackPosition.BOTTOM);
        // TODO: Get.toNamed(AppRoutes.search);
      },
      decoration: InputDecoration(
        hintText: "Search products, brands & more...",
        hintStyle: TextStyle(
            fontSize: 14, color: AppColors.textSecondary.withOpacity(0.8)),
        prefixIcon: Icon(Icons.search_rounded,
            color: AppColors.textSecondary.withOpacity(0.6), size: 20),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary, width: 1.0)),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final product = _productController.featuredProduct.value;
      // Show shimmer if loading AND product is null (meaning featured product hasn't loaded yet)
      final isLoading = _productController.isLoading.value && product == null;

      if (isLoading) {
        return _buildShimmerFeaturedBanner();
      }
      if (product == null) {
        return const SizedBox.shrink();
      } // Don't show anything if no featured product after loading

      final imageUrl = _buildLocalImageUrl(product.mainImage);

      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 160,
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {
                      _productController.selectProduct(product);
                      Get.toNamed(AppRoutes.productDetails, arguments: product);
                    },
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (c, u) => Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(color: Colors.white)),
                              errorWidget: (c, u, e) => Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: Colors.grey[400], size: 50)),
                              fit: BoxFit.cover,
                              height: double.infinity)),
                      Expanded(
                          flex: 3,
                          child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't Miss!",
                                        style: textTheme.labelMedium?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(product.name,
                                        style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text(
                                        '${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}',
                                        style: textTheme.titleSmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                        onPressed: () {
                                          _productController
                                              .selectProduct(product);
                                          Get.toNamed(AppRoutes.productDetails,
                                              arguments: product);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            textStyle: textTheme.labelSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6))),
                                        child: const Text('View Details'))
                                  ])))
                    ]))),
          ));
    });
  }

  Widget _buildShimmerFeaturedBanner() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 160,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12))));
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Obx(() {
        final isLoading = _productController.isLoading.value &&
            _productController.categories.isEmpty;
        final categories = _productController.categories;

        if (isLoading) {
          return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => _buildShimmerCategoryCard());
        }
        if (_productController.errorMessage.value.isNotEmpty &&
            categories.isEmpty) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error: Could not load categories.',
                      style: TextStyle(color: AppColors.textSecondary))));
        }
        if (categories.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No categories available.')));
        }

        final displayedCategories = categories.take(8).toList();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: displayedCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = displayedCategories[index];
            return GestureDetector(
                onTap: () {
                  _productController.selectCategoryForView(category.id);
                  Get.toNamed(AppRoutes.categories);
                },
                child:
                    CategoryCard(imageUrl: category.img, title: category.name));
          },
        );
      }),
    );
  }

  Widget _buildShimmerCategoryCard() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(
            width: 70,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 5),
              Container(
                  height: 8,
                  width: 45,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)))
            ])));
  }

  Widget _buildHorizontalProductList(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Obx(() {
        final bool isLoading = _productController.isLoading.value &&
            _productController.products.isEmpty;
        final products = _productController.products;
        final popularProducts = products
            .where((p) => p.id != _productController.featuredProduct.value?.id)
            .take(6)
            .toList();

        if (isLoading) {
          return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) =>
                  SizedBox(width: 140, child: _buildShimmerProductCard()));
        }
        if (_productController.errorMessage.value.isNotEmpty &&
            popularProducts.isEmpty &&
            !isLoading) {
          // Check !isLoading
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error: Could not load products.',
                      style: TextStyle(color: AppColors.textSecondary))));
        }
        if (popularProducts.isEmpty && !isLoading) {
          // Check !isLoading
          return const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No popular products to show.')));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: popularProducts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final product = popularProducts[index];
            return SizedBox(
                width: 140,
                child: GestureDetector(
                    onTap: () {
                      _productController.selectProduct(product);
                      Get.toNamed(AppRoutes.productDetails, arguments: product);
                    },
                    child: ProductCard(product: product)));
          },
        );
      }),
    );
  }

  Widget _buildVerticalProductGrid(BuildContext context) {
    return Obx(() {
      final bool isLoading = _productController.isLoading.value &&
          _productController.products.isEmpty;
      final products = _productController.products;
      final errorMessage = _productController.errorMessage.value;

      if (isLoading) {
        return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70),
            itemBuilder: (context, index) => _buildShimmerProductCard());
      }
      if (errorMessage.isNotEmpty && products.isEmpty && !isLoading) {
        // Check !isLoading
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $errorMessage',
                    style: TextStyle(color: AppColors.textSecondary))));
      }
      if (products.isEmpty && !isLoading) {
        // Check !isLoading
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No products found.')));
      }

      return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.70),
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
                onTap: () {
                  _productController.selectProduct(product);
                  Get.toNamed(AppRoutes.productDetails, arguments: product);
                },
                child: ProductCard(product: product));
          });
    });
  }

  Widget _buildShimmerProductCard() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(
                  aspectRatio: 1.25, child: Container(color: Colors.white)),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 5),
                        Container(
                            height: 10,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 6),
                        Container(
                            height: 12,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4)))
                      ]))
            ])));
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
      TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
          child: Text('See All',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)))
    ]);
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    return Obx(() => BottomNavigationBar(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 8.0,
          currentIndex: currentIndex.value,
          onTap: (index) {
            if (index == currentIndex.value && index == 0)
              return; // Do nothing if already on Home

            currentIndex.value =
                index; // Update for visual feedback, actual navigation below

            switch (index) {
              case 0:
                // If already on home, maybe refresh or do nothing
                if (Get.currentRoute != AppRoutes.home) {
                  Get.offAllNamed(
                      AppRoutes.home); // Use offAllNamed to make it the root
                } else {
                  // Optionally refresh home screen data if already on it
                  _productController.fetchCategories();
                  _productController.fetchProducts();
                }
                break;
              case 1:
                Get.toNamed(AppRoutes.categories);
                break;
              case 2:
                if (_authController.requireLogin(
                    actionName: 'view your cart')) {
                  _cartController.fetchCartItems();
                  Get.toNamed(AppRoutes.cart);
                } else {
                  currentIndex.value =
                      0; // Revert visual selection if login is cancelled/required
                }
                break;
              case 3:
                if (_authController.requireLogin(
                    actionName: 'view your wishlist')) {
                  _wishlistController.fetchWishlist();
                  Get.toNamed(AppRoutes.wishlist);
                } else {
                  currentIndex.value = 0; // Revert visual selection
                }
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Categories'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded), label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: 'Wishlist')
          ],
        ));
  }
}
