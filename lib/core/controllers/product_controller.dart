// import 'package:get/get.dart';
// import '../models/product_details_data.dart';
// import '../repositories/product_repository.dart';
// import '../models/category_model.dart';
// import '../models/sub_category_model.dart';
// import '../models/item_model.dart';
// // import '../models/brand_model.dart'; // Removed: No longer fetching all brands
// import '../models/product_model.dart';
// import '../models/filter_model.dart';
//
// class ProductController extends GetxController {
//   final ProductRepository _productRepository = Get.find<ProductRepository>();
//
//   // Categories, SubCategories, Items
//   final RxList<CategoryModel> categories = <CategoryModel>[].obs;
//   final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;
//   final RxList<ItemModel> items = <ItemModel>[].obs;
//   // final RxList<BrandModel> brands = <BrandModel>[].obs; // Removed brand state
//
//   // Products
//   final RxList<ProductModel> products = <ProductModel>[].obs; // Main list for all products
//   final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null); // For product detail view
//   final Rx<ProductModel?> featuredProduct = Rx<ProductModel?>(null); // State for featured product
//   final Rx<ProductDetailData?> productDetailsData = Rx<ProductDetailData?>(null);
//   final RxBool isProductDetailsLoading = false.obs;
//   final RxBool isLoadingSubCategories = false.obs;
//   // Filters
//   final Rx<FilterModel?> filterOptions = Rx<FilterModel?>(null);
//
//   // State management
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//
//   // Selected IDs (remove selectedBrandId if truly unused)
//   // final RxInt selectedCategoryId = RxInt(-1);
//   final RxInt selectedSubCategoryId = RxInt(-1);
//   final RxInt selectedItemId = RxInt(-1);
//   // final RxInt selectedBrandId = RxInt(-1); // Removed: No longer fetching/filtering by all brands here
//
//   // --- MODIFIED/ADDED State ---
//   // selectedCategoryId used for fetching products/sub-categories related to the chosen category
//   final RxInt selectedCategoryId = RxInt(-1);
//   // currentViewCategoryId tracks the category selected in the CategoriesScreen UI
//   final RxInt currentViewCategoryId = RxInt(-1); // Initialize with -1 (nothing selected)
//   // --- END MODIFICATION ---
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchCategories();
//     // fetchAllBrands(); // Removed call to fetch brands
//     fetchProducts(); // Fetch initial products (also sets the featured product)
//   }
//
//   // --- ADDED/MODIFIED Methods ---
//
//   // Fetch categories and automatically select the first one if available
//   Future<void> fetchCategoriesAndInitialSelection() async {
//     await fetchCategories(); // Use existing fetchCategories
//     if (categories.isNotEmpty) {
//       // Automatically select the first category and fetch its sub-categories
//       selectCategoryForView(categories.first.id);
//     } else {
//       currentViewCategoryId.value = -1; // Ensure nothing is selected if categories are empty
//       subCategories.clear();
//     }
//   }
//
//   // Method called when a user taps a category in the new CategoriesScreen UI
//   void selectCategoryForView(int categoryId) {
//     if (currentViewCategoryId.value != categoryId) {
//       print("Selecting category for view: $categoryId");
//       currentViewCategoryId.value = categoryId;
//       selectedCategoryId.value = categoryId; // Also update the main selected ID
//       fetchSubCategories(categoryId); // Fetch sub-categories for the new selection
//     }
//   }
//
//   Future<void> fetchSubCategories(int categoryId) async {
//     // Use a separate loading state for sub-categories
//     if (isLoadingSubCategories.value) return; // Prevent concurrent fetches
//
//     try {
//       isLoadingSubCategories.value = true;
//       errorMessage.value = '';
//       // selectedCategoryId.value = categoryId; // No need to set this here, already set by selectCategoryForView
//
//       // Clear previous sub-categories before fetching new ones
//       subCategories.clear();
//       print("Fetching sub-categories for category ID: $categoryId");
//
//       final subCategoryList = await _productRepository.getSubCategories(categoryId);
//       subCategories.assignAll(subCategoryList);
//       print("Fetched ${subCategoryList.length} sub-categories.");
//
//     } catch (e) {
//       print("Error fetching sub-categories: $e");
//       errorMessage.value = e.toString();
//       subCategories.clear(); // Clear on error too
//     } finally {
//       isLoadingSubCategories.value = false;
//       print("Finished fetching sub-categories. isLoadingSubCategories: ${isLoadingSubCategories.value}");
//     }
//   }
//   // --- END ADDED/MODIFIED Methods ---
//
//   Future<void> fetchCategories() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final categoryList = await _productRepository.getCategories();
//       categories.assignAll(categoryList);
//
//     } catch (e) {
//       errorMessage.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Future<void> fetchSubCategories(int categoryId) async {
//   //   try {
//   //     isLoading.value = true;
//   //     errorMessage.value = '';
//   //     selectedCategoryId.value = categoryId; // Keep track of selected category
//   //
//   //     // --- Modification: Clear previous sub-categories ---
//   //     subCategories.clear();
//   //     // --- End Modification ---
//   //
//   //     final subCategoryList = await _productRepository.getSubCategories(categoryId);
//   //     subCategories.assignAll(subCategoryList);
//   //
//   //   } catch (e) {
//   //     errorMessage.value = e.toString();
//   //     subCategories.clear(); // Clear on error too
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
//
//
//   Future<void> fetchItems(int subCategoryId) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       selectedSubCategoryId.value = subCategoryId;
//
//       final itemList = await _productRepository.getItems(subCategoryId);
//       items.assignAll(itemList);
//
//     } catch (e) {
//       errorMessage.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Method to fetch products, also sets the featured product
//   Future<void> fetchProducts({
//     int? categoryId,
//     int? subCategoryId,
//     int? itemId,
//     // int? brandId, // Removed brandId parameter
//   }) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       featuredProduct.value = null; // Clear previous featured product
//
//       // if (brandId != null) selectedBrandId.value = brandId; // Removed brand handling
//
//       final productList = await _productRepository.getProducts(
//         categoryId: categoryId ?? (selectedCategoryId.value != -1 ? selectedCategoryId.value : null),
//         subCategoryId: subCategoryId ?? (selectedSubCategoryId.value != -1 ? selectedSubCategoryId.value : null),
//         itemId: itemId ?? (selectedItemId.value != -1 ? selectedItemId.value : null),
//         // brandId: brandId ?? (selectedBrandId.value != -1 ? selectedBrandId.value : null), // Removed brandId
//       );
//
//       // Update the main product list
//       products.assignAll(productList);
//
//       // --- Logic to set Featured Product ---
//       // Example: take the first product if the list is not empty
//       if (productList.isNotEmpty) {
//         featuredProduct.value = productList.first;
//       } else {
//         featuredProduct.value = null; // Ensure it's null if list is empty
//       }
//       // --- End Featured Product Logic ---
//
//     } catch (e) {
//       errorMessage.value = e.toString();
//       products.clear(); // Clear products on error
//       featuredProduct.value = null; // Clear featured product on error
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Modify this method
//   Future<void> fetchProductDetails(int productId) async {
//     // Assumes base product info (like name, images) is already loaded into 'selectedProduct'
//     // Or modify to fetch base product info here if needed.
//     try {
//       isProductDetailsLoading.value = true; // Use specific loading state
//       errorMessage.value = ''; // Clear previous errors
//       productDetailsData.value = null; // Clear previous details
//
//       final details = await _productRepository.getProductDetails(productId);
//       productDetailsData.value = details;
//
//     } catch (e) {
//       print("Error fetching product details: $e");
//       errorMessage.value = e.toString(); // Set error message
//     } finally {
//       isProductDetailsLoading.value = false; // Reset specific loading state
//     }
//   }
//
//   // Method to select a base product (e.g., when navigating from list)
//   // Ensure this is called before fetchProductDetails
//   void selectProduct(ProductModel product) {
//     selectedProduct.value = product;
//     // Clear old details when selecting a new product
//     productDetailsData.value = null;
//     // Optionally trigger fetchProductDetails immediately
//     // fetchProductDetails(product.id);
//   }
//
//
//   // Method to clear selection and details when leaving the screen
//   void clearProductSelectionAndDetails() {
//     selectedProduct.value = null;
//     productDetailsData.value = null;
//     errorMessage.value = '';
//   }
//
//   Future<void> fetchFilters(int itemId) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final filters = await _productRepository.getFilters(itemId);
//       filterOptions.value = filters;
//
//     } catch (e) {
//       errorMessage.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> applyFilters({
//     String? sortBy,
//     List<String>? discounts,
//     Map<String, List<String>>? dynamicFilters,
//     double? minPrice,
//     double? maxPrice,
//     int? brandId, // Keep brandId here if needed for filtering specific brands
//   }) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final filteredProducts = await _productRepository.filterProducts(
//         categoryId: selectedCategoryId.value != -1 ? selectedCategoryId.value : null,
//         subCategoryId: selectedSubCategoryId.value != -1 ? selectedSubCategoryId.value : null,
//         itemId: selectedItemId.value != -1 ? selectedItemId.value : null,
//         brandId: brandId, // Pass brandId if provided for filtering
//         sortBy: sortBy,
//         discounts: discounts,
//         dynamicFilters: dynamicFilters,
//         minPrice: minPrice,
//         maxPrice: maxPrice,
//       );
//
//       // Update main list with filtered results
//       products.assignAll(filteredProducts);
//
//       // Decide if filtering should also update the featured product
//       // Option 1: Keep the original featured product regardless of filters
//       // Option 2: Update featured product based on filtered results (like below)
//       if (filteredProducts.isNotEmpty) {
//         featuredProduct.value = filteredProducts.first;
//       } else {
//         featuredProduct.value = null;
//       }
//
//     } catch (e) {
//       errorMessage.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearSelectedProduct() {
//     selectedProduct.value = null;
//   }
//
//   void resetFilters() {
//     filterOptions.value = null;
//     // Optionally re-fetch default products after resetting filters
//     // fetchProducts();
//   }
// }

// lib/core/controllers/product_controller.dart
import 'package:get/get.dart';
import '../models/product_details_data.dart';
import '../repositories/product_repository.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/item_model.dart';
import '../models/product_model.dart';
import '../models/filter_model.dart'; // Ensure this is the updated FilterModel

class ProductController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;
  final RxList<ItemModel> items = <ItemModel>[].obs;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final Rx<ProductModel?> featuredProduct = Rx<ProductModel?>(null);
  final Rx<ProductDetailData?> productDetailsData = Rx<ProductDetailData?>(null);
  final RxBool isProductDetailsLoading = false.obs;
  final RxBool isLoadingSubCategories = false.obs;

  final Rx<FilterModel?> filterOptions = Rx<FilterModel?>(null); // Correctly typed

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt selectedCategoryId = RxInt(-1);
  final RxInt selectedSubCategoryId = RxInt(-1);
  final RxInt selectedItemId = RxInt(-1); // This ID is crucial for fetching relevant filters

  final RxInt currentViewCategoryId = RxInt(-1);

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts(); // Fetch initial all products or featured
    // Consider fetching filters if a default item_id context exists
    // For example, if your home screen always shows products from a specific item initially:
    // if (defaultItemId != -1) fetchFilters(defaultItemId);
  }

  Future<void> fetchCategoriesAndInitialSelection() async {
    await fetchCategories();
    if (categories.isNotEmpty) {
      selectCategoryForView(categories.first.id);
    } else {
      currentViewCategoryId.value = -1;
      subCategories.clear();
    }
  }

  void selectCategoryForView(int categoryId) {
    if (currentViewCategoryId.value != categoryId) {
      print("Selecting category for view: $categoryId");
      currentViewCategoryId.value = categoryId;
      selectedCategoryId.value = categoryId;
      // Reset deeper selections when category changes
      selectedSubCategoryId.value = -1;
      selectedItemId.value = -1;
      items.clear();
      filterOptions.value = null; // Clear filters from previous category
      fetchSubCategories(categoryId);
      fetchProducts(categoryId: categoryId); // Fetch products for this category
    }
  }

  void selectSubCategory(SubCategoryModel subCategory) {
    print("Selecting sub-category: ${subCategory.name}");
    selectedSubCategoryId.value = subCategory.id;
    // Reset deeper selections
    selectedItemId.value = -1;
    filterOptions.value = null; // Clear filters
    fetchItems(subCategory.id);
    fetchProducts(subCategoryId: subCategory.id);
  }

  void selectItem(ItemModel item) {
    print("Selecting item: ${item.name}");
    selectedItemId.value = item.id;
    fetchFilters(item.id); // Fetch filters for this specific item
    fetchProducts(itemId: item.id); // Fetch products for this item
  }


  Future<void> fetchSubCategories(int categoryId) async {
    if (isLoadingSubCategories.value) return;
    try {
      isLoadingSubCategories.value = true;
      errorMessage.value = '';
      subCategories.clear();
      print("Fetching sub-categories for category ID: $categoryId");
      final subCategoryList = await _productRepository.getSubCategories(categoryId);
      subCategories.assignAll(subCategoryList);
      print("Fetched ${subCategoryList.length} sub-categories.");
    } catch (e) {
      print("Error fetching sub-categories: $e");
      errorMessage.value = e.toString();
      subCategories.clear();
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final categoryList = await _productRepository.getCategories();
      categories.assignAll(categoryList);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchItems(int subCategoryId) async {
    try {
      isLoading.value = true; // Or a more specific loading state
      errorMessage.value = '';
      items.clear(); // Clear previous items
      selectedSubCategoryId.value = subCategoryId;
      final itemList = await _productRepository.getItems(subCategoryId);
      items.assignAll(itemList);
    } catch (e) {
      errorMessage.value = e.toString();
      items.clear();
    } finally {
      isLoading.value = false; // Reset general loading or specific one
    }
  }

  Future<void> fetchProducts({
    int? categoryId,
    int? subCategoryId,
    int? itemId,
    int? brandId, // This is for specific brand ID filtering, not brand names from filter options
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      // featuredProduct.value = null; // Decide if this should be cleared

      final productList = await _productRepository.getProducts(
        categoryId: categoryId ?? (selectedCategoryId.value != -1 ? selectedCategoryId.value : null),
        subCategoryId: subCategoryId ?? (selectedSubCategoryId.value != -1 ? selectedSubCategoryId.value : null),
        itemId: itemId ?? (selectedItemId.value != -1 ? selectedItemId.value : null),
        brandId: brandId,
      );
      products.assignAll(productList);
      if (productList.isNotEmpty && featuredProduct.value == null) { // Set featured product if not set
        featuredProduct.value = productList.first;
      } else if (productList.isEmpty) {
        // featuredProduct.value = null; // Optionally clear if list is empty
      }
    } catch (e) {
      errorMessage.value = e.toString();
      products.clear();
      // featuredProduct.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductDetails(int productId) async {
    try {
      isProductDetailsLoading.value = true;
      errorMessage.value = '';
      productDetailsData.value = null;
      final details = await _productRepository.getProductDetails(productId);
      productDetailsData.value = details;
    } catch (e) {
      print("Error fetching product details: $e");
      errorMessage.value = e.toString();
    } finally {
      isProductDetailsLoading.value = false;
    }
  }

  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
    productDetailsData.value = null;
  }

  void clearProductSelectionAndDetails() {
    selectedProduct.value = null;
    productDetailsData.value = null;
    errorMessage.value = '';
  }

  Future<void> fetchFilters(int itemId) async {
    // Only fetch if itemId is valid and different or filters are not yet loaded for it
    if (itemId == -1) {
      print("Skipping fetchFilters: Invalid itemId (-1)");
      filterOptions.value = null; // Clear filters if itemId is invalid
      return;
    }
    // Optimization: check if filters for this itemId are already loaded
    // This simple check might need refinement if filters can change server-side without itemId changing
    // if (selectedItemId.value == itemId && filterOptions.value != null && !isLoading.value) {
    //   print("Skipping fetchFilters: Filters for itemId $itemId already loaded.");
    //   return;
    // }

    print("Fetching filters for itemId: $itemId");
    try {
      isLoading.value = true; // Consider a specific isLoadingFilters
      errorMessage.value = '';
      filterOptions.value = null;

      final filtersData = await _productRepository.getFilters(itemId);
      filterOptions.value = filtersData;
      selectedItemId.value = itemId; // Ensure selectedItemId is updated
      print("Filters fetched: ${filterOptions.value?.brands}, ${filterOptions.value?.dynamicFilters?.keys}");
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", "Could not fetch filters: ${e.toString()}");
      print("Error fetching filters for itemId $itemId: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilters({
    String? sortBy,
    // brandNames are now part of dynamicFilters if "Brands" is a filter key
    Map<String, List<String>>? dynamicFilters,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Applying filters with: dynamic=$dynamicFilters, sort=$sortBy, minP=$minPrice, maxP=$maxPrice");


      final filteredProducts = await _productRepository.filterProducts(
        // Pass current category/sub-category/item context for filtering
        categoryId: selectedCategoryId.value != -1 ? selectedCategoryId.value : null,
        subCategoryId: selectedSubCategoryId.value != -1 ? selectedSubCategoryId.value : null,
        itemId: selectedItemId.value != -1 ? selectedItemId.value : null,
        sortBy: sortBy,
        dynamicFilters: dynamicFilters,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      products.assignAll(filteredProducts);

      if (filteredProducts.isNotEmpty) {
        // featuredProduct.value = filteredProducts.first; // Decide if you want to update featured product on filter
      } else {
        // featuredProduct.value = null;
      }
      print("Filtered products count: ${products.length}");
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", "Could not apply filters: ${e.toString()}");
      print("Error applying filters: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearSelectedProduct() {
    selectedProduct.value = null;
  }

  void resetFilters() {
    // This should clear UI selections and refetch products without filters
    // The actual clearing of UI selections will happen in the filter bottom sheet's "Clear All"
    filterOptions.value = null; // Clear loaded filter options
    // Refetch products based on the current category/item context, without additional filters
    fetchProducts(
        categoryId: selectedCategoryId.value != -1 ? selectedCategoryId.value : null,
        subCategoryId: selectedSubCategoryId.value != -1 ? selectedSubCategoryId.value : null,
        itemId: selectedItemId.value != -1 ? selectedItemId.value : null
    );
  }
}