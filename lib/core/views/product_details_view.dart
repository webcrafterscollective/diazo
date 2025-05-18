// lib/core/views/product_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../controllers/cart_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/product_details_data.dart';
import '../models/product_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final WishlistController _wishlistController = Get.find<WishlistController>();
  final AuthController _authController = Get.find<AuthController>();
  final CartController _cartController = Get.find<CartController>();

  final RxString selectedColor = ''.obs;
  final RxString selectedSize = ''.obs;
  final RxInt quantity = 1.obs;

  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;

  @override
  void initState() {
    super.initState();
    final ProductModel? productFromArgOrController = _productController.selectedProduct.value ??
        (Get.arguments is ProductModel ? Get.arguments as ProductModel : null);

    if (productFromArgOrController != null) {
      if (_productController.selectedProduct.value?.id != productFromArgOrController.id) {
        _productController.selectProduct(productFromArgOrController);
      }
      _productController.fetchProductDetails(productFromArgOrController.id);
    } else {
      Get.snackbar(
        "Error",
        "Product data not found. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }

    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page?.round() != _currentPage.value) {
        if (_pageController.page != null) {
          _currentPage.value = _pageController.page!.round();
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _buildImageUrl(String? imagePath) {
    // Using AppConstants.buildImageUrl for consistency
    return AppConstants.buildImageUrl(imagePath);
  }

  void _handleAddToCart() {
    if (!_authController.requireLogin(actionName: 'add items to your cart')) {
      return;
    }

    final ProductModel? product = _productController.selectedProduct.value;
    final ProductDetailData? details = _productController.productDetailsData.value;

    if (product == null) {
      Get.snackbar('Error', 'Product not selected.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    final int? variantId = details?.variantId;

    if (variantId == null) {
      Get.snackbar('Error', 'Could not determine product variant. Please select options if available or try again.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      if (details != null && details.optionsMap.isNotEmpty) {
        print("DEBUG ProductDetails: Options are available but variantId is null. Selected Color: ${selectedColor.value}, Size: ${selectedSize.value}");
        print("DEBUG ProductDetails: Details object optionName: ${details.optionName}, optionValue: ${details.optionValue}");
      } else if (details != null) {
        print("DEBUG ProductDetails: No optionsMap in details, but variantId is null.");
      } else {
        print("DEBUG ProductDetails: 'details' object is null. Cannot determine variantId.");
      }
      return;
    }

    _cartController.addToCart(
      productId: product.id,
      variantId: variantId,
      quantity: quantity.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          _productController.selectedProduct.value?.name ?? 'Product Details',
          style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        )),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      body: Obx(() {
        final ProductModel? product = _productController.selectedProduct.value;
        final ProductDetailData? details = _productController.productDetailsData.value;
        final bool isLoadingDetails = _productController.isProductDetailsLoading.value;
        final String errorMessage = _productController.errorMessage.value;

        if (isLoadingDetails && details == null && product != null) {
          return _buildShimmerLoading(product);
        }
        if (product == null) {
          if (errorMessage.isNotEmpty && !isLoadingDetails) { // Show error if product is null and not loading
            return Center(child: Padding(padding:const EdgeInsets.all(16.0), child:Text("Error loading product: $errorMessage", textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary))));
          }
          return const Center(child: LoadingIndicator());
        }

        final String productName = product.name;
        // Use product.images safely, defaulting to an empty list if null
        final List<String> images = (product.images).map((img) => _buildImageUrl(img)).toList();
        final String description = details?.description ?? "No description available.";
        final int? stock = details?.stock;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(images, isLoadingDetails && images.isEmpty),
              if (images.length > 1) _buildImageIndicator(images.length),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    if (details != null && details.printedPrice > details.price)
                      Text(
                        "Special Offer! Save ${(((details.printedPrice - details.price) / details.printedPrice) * 100).toStringAsFixed(0)}%",
                        style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 10),
                    _buildRatingAndWishlist(product, details),
                    const SizedBox(height: 20),
                    _buildQuantitySelector(stock, isLoadingDetails || details == null), // Pass combined loading state
                    const SizedBox(height: 20),
                    if (isLoadingDetails && details == null) // Shimmer for options if details are loading
                      _buildShimmerOptionsSection()
                    else if (details?.optionsMap.isNotEmpty ?? false) ...[
                      ..._buildOptionsSection(details!.optionsMap),
                      const SizedBox(height: 16),
                    ],
                    if (description.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text("Description", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(description, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (isLoadingDetails && details == null) // Shimmer for additional details
                      _buildShimmerAdditionalDetailsSection()
                    else if (details != null)
                      _buildAdditionalDetailsSection(details),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final ProductModel? product = _productController.selectedProduct.value;
        final ProductDetailData? details = _productController.productDetailsData.value;
        final bool isLoadingController = _productController.isProductDetailsLoading.value; // Controller's loading state for details
        final bool isLoadingCart = _cartController.isLoading.value; // Controller's loading state for cart action

        if (isLoadingController && product == null && details == null) {
          return _buildShimmerBottomBar();
        }
        if (product == null) return const SizedBox.shrink();

        final double currentPrice = details?.price ?? product.price;
        final double originalPrice = details?.printedPrice ?? product.printedPrice;
        // Use stock from details if available, otherwise from product, default to 0 if both are null
        final int currentStock = details?.stock ?? product.stock;
        final bool isOutOfStock = currentStock == 0;

        return _buildBottomAddToCartBar(currentPrice, originalPrice, isOutOfStock, isLoadingCart || (isLoadingController && details == null));
      }),
    );
  }

  Widget _buildImageCarousel(List<String> images, bool isLoading) {
    double screenWidth = MediaQuery.of(context).size.width;
    double carouselHeight = screenWidth * 0.85;

    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(height: carouselHeight, width: screenWidth, decoration: const BoxDecoration(color: Colors.white)), // Fixed: color in decoration
      );
    }
    if (images.isEmpty) {
      return Container(
        width: screenWidth,
        height: carouselHeight,
        decoration: BoxDecoration(color: AppColors.inputBackground), // Fixed: color in decoration
        child: Center(child: Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.grey[400])),
      );
    }
    return Container(
      decoration: const BoxDecoration(color: Colors.white), // Fixed: color in decoration
      height: carouselHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index],
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[50]!,
              child: Container(decoration: const BoxDecoration(color: Colors.white)), // Fixed: color in decoration
            ),
            errorWidget: (context, url, error) => Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 60),
            ),
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  Widget _buildImageIndicator(int imageCount) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white), // Fixed: color in decoration
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(imageCount, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage.value == index ? 12.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(_currentPage.value == index ? 0.9 : 0.4),
            ),
          );
        }),
      )),
    );
  }

  Widget _buildRatingAndWishlist(ProductModel product, ProductDetailData? details) {
    final textTheme = Theme.of(context).textTheme;
    final int wishlistCheckProductId = product.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(Icons.star_rate_rounded, color: Colors.amber, size: 22),
          const SizedBox(width: 4),
          Text("4.8", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          Text("(235 Reviews)", style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ]),
        Obx(() {
          bool isInWishlist = _wishlistController.isProductInWishlist(wishlistCheckProductId);
          return IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: AppColors.primary,
              size: 26,
            ),
            onPressed: () {
              if (!_authController.requireLogin(actionName: 'manage your wishlist')) return;
              final int pId = product.id;
              final int? vId = details?.variantId;
              if (vId == null) {
                Get.snackbar('Error', 'Variant information is required to update wishlist.', snackPosition: SnackPosition.BOTTOM);
                print("DEBUG Wishlist: Attempted action without variantId. ProductId: $pId");
                return;
              }
              if (isInWishlist) {
                _wishlistController.removeFromWishlist(pId, vId);
              } else {
                _wishlistController.addToWishlist(pId, vId);
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuantitySelector(int? availableStock, bool isLoading) {
    final textTheme = Theme.of(context).textTheme;
    if (isLoading) {
      return Row(children: [
        Text("Quantity:", style: textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
        const Spacer(),
        Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(width: 100, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))
        ),
      ]);
    }

    return Obx(() => Row(children: [
      Text("Quantity:", style: textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
      const Spacer(),
      IconButton(
        icon: Icon(Icons.remove_circle_outline_rounded, color: quantity.value > 1 ? AppColors.textPrimary : Colors.grey[400], size: 28),
        onPressed: quantity.value > 1 ? () => quantity.value-- : null,
      ),
      Container(
        width: 40,
        alignment: Alignment.center,
        child: Text(
          quantity.value.toString(),
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      IconButton(
        icon: Icon(Icons.add_circle_rounded, color: (availableStock != null && quantity.value >= availableStock && availableStock > 0) ? Colors.grey[400] : AppColors.primary, size: 28),
        onPressed: (availableStock != null && quantity.value >= availableStock && availableStock > 0)
            ? null
            : () {
          if (availableStock == 0) {
            Get.snackbar('Stock Alert', 'This item is currently out of stock.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
            return;
          }
          quantity.value++;
          if (availableStock != null && quantity.value > availableStock) {
            quantity.value = availableStock; // Cap at available stock
            Get.snackbar('Stock Alert', 'Only $availableStock items available.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: Colors.white);
          }
        },
      )
    ]));
  }

  Widget _buildShimmerOptionsSection() {
    List<Widget> widgets = [];
    for (var i = 0; i < 2; i++) {
      widgets.add(Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 20, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), margin: const EdgeInsets.only(bottom: 8))));
      widgets.add(Wrap(spacing: 10.0, runSpacing: 10.0, children: List.generate(3, (j) => Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Chip(label: Container(width:50, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)) ))))));
      widgets.add(const SizedBox(height: 20));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }


  List<Widget> _buildOptionsSection(Map<String, List<String>> optionsMap) {
    final textTheme = Theme.of(context).textTheme;
    List<Widget> widgets = [];

    optionsMap.forEach((name, values) {
      widgets.add(Text(name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
      widgets.add(const SizedBox(height: 10));
      widgets.add(Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: values.map((value) {
          bool isSelected = false;
          RxString currentSelectionState = ''.obs;

          if (name.toLowerCase().contains('color')) { currentSelectionState = selectedColor; }
          else if (name.toLowerCase().contains('size')) { currentSelectionState = selectedSize; }

          isSelected = currentSelectionState.value == value;

          return ChoiceChip(
            label: Text(value, style: textTheme.bodyMedium?.copyWith(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                currentSelectionState.value = value;
                print("Selected $name: $value. TODO: Implement logic to find and update to the new variantId based on all selected options.");
                Get.snackbar("Option Changed", "$name set to $value. Variant ID might need update.", snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
              }
            },
            selectedColor: AppColors.primary.withOpacity(0.15),
            backgroundColor: AppColors.inputBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1.0),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          );
        }).toList(),
      ));
      widgets.add(const SizedBox(height: 20));
    });
    return widgets;
  }

  Widget _buildShimmerAdditionalDetailsSection() {
    List<Widget> widgets = [];
    widgets.add(const Divider(height: 20));
    widgets.add(Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 22, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), margin: const EdgeInsets.only(bottom: 10))));
    for (var i = 0; i < 3; i++) { // Shimmer for a few detail rows
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))))),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))))),
          ],
        ),
      ));
    }
    widgets.add(const SizedBox(height: 20));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }


  Widget _buildAdditionalDetailsSection(ProductDetailData details) {
    final textTheme = Theme.of(context).textTheme;
    List<Widget> detailItems = [];

    if (details.manufacturerDetails != null && details.manufacturerDetails!.isNotEmpty) {
      detailItems.add(_buildDetailRow("Manufacturer", details.manufacturerDetails!, textTheme));
    }
    if (details.warranty != null && details.warranty!.isNotEmpty) {
      String warrantyInfo = "${details.warranty} ${details.warrantyUnit ?? ''}";
      if (details.warrantySummary != null && details.warrantySummary!.isNotEmpty) {
        warrantyInfo += " (${details.warrantySummary})";
      }
      detailItems.add(_buildDetailRow("Warranty", warrantyInfo, textTheme));
    }
    if (details.returnDay != null && details.returnDay! > 0) {
      detailItems.add(_buildDetailRow("Return Policy", "${details.returnDay} ${details.returnDayUnit ?? 'days'}", textTheme));
    }
    if (details.attributesMap.isNotEmpty) {
      detailItems.add(const SizedBox(height:10));
      detailItems.add(Text("Specifications:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
      details.attributesMap.forEach((key, value) {
        detailItems.add(_buildDetailRow(key, value, textTheme, isSpec: true));
      });
    }

    if (detailItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20),
        Text("More Information", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        ...detailItems,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme, {bool isSpec = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSpec ? 4.0 : 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAddToCartBar(double currentPrice, double originalPrice, bool isOutOfStock, bool isLoadingDetails) {
    final textTheme = Theme.of(context).textTheme;
    bool onSale = originalPrice > 0 && originalPrice > currentPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -2))],
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price Column (remains the same as your last good version)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOutOfStock && !isLoadingDetails)
                Text("Out of Stock", style: textTheme.titleMedium?.copyWith(color: AppColors.error, fontWeight: FontWeight.bold))
              else if (!isLoadingDetails) ...[
                Text("Total Price:", style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                Text(
                  '${AppConstants.currencySymbol}${currentPrice.toStringAsFixed(2)}',
                  style: textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                if (onSale)
                  Text(
                    '${AppConstants.currencySymbol}${originalPrice.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[500],
                        height: 0.9
                    ),
                  ),
              ] else ... [
                Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(width: 60, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 6),
                Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(width: 100, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
              ]
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => CustomButton( // Ensure button is wrapped with Obx to react to isAddingToCart
              text: isOutOfStock ? "Out of Stock" : "Add To Cart",
              // Use the specific loading state from CartController
              isLoading: _cartController.isAddingToCart.value,
              onPressed: (isOutOfStock || _cartController.isAddingToCart.value || isLoadingDetails)
                  ? null
                  : _handleAddToCart,
              height: 50,
              backgroundColor: isOutOfStock ? Colors.grey[400] : AppColors.primary,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ProductModel? product) {
    double screenWidth = MediaQuery.of(context).size.width;
    double carouselHeight = screenWidth * 0.85;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(height: carouselHeight, width: screenWidth, decoration: const BoxDecoration(color: Colors.white)), // Fixed
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 28, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)))),
                const SizedBox(height: 10),
                Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 20, width: MediaQuery.of(context).size.width * 0.5, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: Container(height: 22, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                  Shimmer.fromColors(baseColor: Colors.grey[200]!, highlightColor: Colors.grey[50]!, child: CircleAvatar(radius: 15, backgroundColor: Colors.white)),
                ]),
                const SizedBox(height: 24),
                _buildShimmerQuantitySelector(),
                const SizedBox(height: 24),
                _buildShimmerOptionsSection(),
                const SizedBox(height: 20),
                _buildShimmerAdditionalDetailsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerQuantitySelector() {
    return Row(children: [
      Text("Quantity:", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[400])), // Lighter text for shimmer indication
      const Spacer(),
      Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[50]!,
          child: Container(width: 100, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))
      ),
    ]);
  }


  Widget _buildShimmerBottomBar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer needs a solid color to draw on
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 60, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 100, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}