// import 'package:get/get.dart';
//
// import '../constants/app_constants.dart';
// import '../models/brand_model.dart';
// import '../models/category_model.dart';
// import '../models/product_details_data.dart';
// import '../models/product_model.dart';
// import '../models/sub_category_model.dart';
// import '../models/item_model.dart';
//
// import '../models/filter_model.dart';
// import '../network/api_provider.dart';
// import '../utils/app_exceptions.dart';
//
// class ProductRepository {
//   final ApiProvider _apiProvider = Get.find<ApiProvider>();
//
//   Future<List<CategoryModel>> getCategories() async {
//     // Consider changing to _apiProvider.get if your API uses GET for categories
//     final response = await _apiProvider.post(AppConstants.categoryEndpoint);
//
//     List<CategoryModel> categories = [];
//     // Use the correct key 'category' provided by the API response
//     for (var item in response['category']) {
//       categories.add(CategoryModel.fromJson(item));
//     }
//
//     return categories;
//   }
//
//   Future<List<SubCategoryModel>> getSubCategories(int categoryId) async {
//     final fields = {'cat_id': categoryId.toString()};
//
//     // Consider changing to _apiProvider.get if your API uses GET for sub-categories
//     final response = await _apiProvider.post(
//       AppConstants.subCategoryEndpoint,
//       fields: fields,
//     );
//
//     List<SubCategoryModel> subCategories = [];
//     // Use the correct key 'subCategory' provided by the API response
//     for (var item in response['subCategory']) {
//       print(item);
//       subCategories.add(SubCategoryModel.fromJson(item));
//     }
//
//     return subCategories;
//   }
//
//
//   Future<List<ItemModel>> getItems(int subCategoryId) async {
//     final fields = {'sub_cat_id': subCategoryId.toString()};
//
//     final response = await _apiProvider.post(
//       AppConstants.itemEndpoint,
//       fields: fields,
//     );
//
//     List<ItemModel> items = [];
//     for (var item in response['data']) {
//       items.add(ItemModel.fromJson(item));
//     }
//
//     return items;
//   }
//
//   Future<List<BrandModel>> getBrands(int itemId) async {
//     final fields = {'item_id': itemId.toString()};
//
//     final response = await _apiProvider.post(
//       AppConstants.brandEndpoint,
//       fields: fields,
//     );
//
//     List<BrandModel> brands = [];
//     for (var item in response['data']) {
//       brands.add(BrandModel.fromJson(item));
//     }
//
//     return brands;
//   }
//
//   Future<List<ProductModel>> getProducts({
//     int? categoryId,
//     int? subCategoryId,
//     int? itemId,
//     int? brandId,
//   }) async {
//     final fields = <String, String>{};
//
//     if (categoryId != null) fields['cat_id'] = categoryId.toString();
//     if (subCategoryId != null) fields['sub_cat_id'] = subCategoryId.toString();
//     if (itemId != null) fields['item_id'] = itemId.toString();
//     if (brandId != null) fields['brand_id'] = brandId.toString();
//
//     final response = await _apiProvider.post(
//       AppConstants.productEndpoint,
//       fields: fields,
//     );
//
//     List<ProductModel> products = [];
//     for (var item in response['product']) {
//       products.add(ProductModel.fromJson(item));
//     }
//
//     return products;
//   }
//
//   // Modify this method
//   Future<ProductDetailData> getProductDetails(int productId) async { // Change return type
//     final fields = {'product_id': productId.toString()};
//
//     final response = await _apiProvider.post(
//       AppConstants.productDetailsEndpoint,
//       fields: fields,
//     );
//
//     // Parse the 'productDetail' object using the new model's factory
//     if (response != null && response['productDetail'] != null && response['productDetail'] is Map<String, dynamic>) {
//       return ProductDetailData.fromJson(response['productDetail']);
//     } else {
//       // Handle error: Invalid response format
//       throw FetchDataException("Failed to parse product details from response.");
//     }
//     // Old incorrect line: return ProductModel.fromJson(response['data']);
//   }
//
//   Future<FilterModel> getFilters(int itemId) async {
//     final fields = {'item_id': itemId.toString()};
//
//     final response = await _apiProvider.post(
//       AppConstants.filterEndpoint,
//       fields: fields,
//     );
//
//     return FilterModel.fromJson(response['data']);
//   }
//
//   Future<List<ProductModel>> filterProducts({
//     int? categoryId,
//     int? subCategoryId,
//     int? itemId,
//     int? brandId,
//     String? sortBy,
//     List<String>? discounts,
//     Map<String, List<String>>? dynamicFilters,
//     double? minPrice,
//     double? maxPrice,
//   }) async {
//     final fields = <String, String>{};
//
//     if (categoryId != null) fields['cat_id'] = categoryId.toString();
//     if (subCategoryId != null) fields['sub_cat_id'] = subCategoryId.toString();
//     if (itemId != null) fields['item_id'] = itemId.toString();
//     if (brandId != null) fields['brand_id'] = brandId.toString();
//     if (sortBy != null) fields['sortBy'] = sortBy;
//     if (minPrice != null) fields['min_price'] = minPrice.toString();
//     if (maxPrice != null) fields['max_price'] = maxPrice.toString();
//
//     if (discounts != null) {
//       for (int i = 0; i < discounts.length; i++) {
//         fields['discounts[$i]'] = discounts[i];
//       }
//     }
//
//     if (dynamicFilters != null) {
//       dynamicFilters.forEach((key, value) {
//         for (int i = 0; i < value.length; i++) {
//           fields['dynamicFilters[$key][$i]'] = value[i];
//         }
//       });
//     }
//
//     final response = await _apiProvider.post(
//       AppConstants.filterProductEndpoint,
//       fields: fields,
//     );
//
//     List<ProductModel> products = [];
//     for (var item in response['data']) {
//       products.add(ProductModel.fromJson(item));
//     }
//
//     return products;
//   }
//
//   // In lib/core/repositories/product_repository.dart
//
//   // Method to fetch ALL brands (assumes a new endpoint)
//   Future<List<BrandModel>> getAllBrands() async {
//     // TODO: Define AppConstants.allBrandsEndpoint in app_constants.dart
//     // Assume POST for now, change to .get if needed
//     final response = await _apiProvider.post(AppConstants.brandEndpoint); // Using existing for now, replace if needed
//
//     List<BrandModel> brands = [];
//     // Use the correct key 'brand' provided by the API response
//     for (var item in response['brand']) {
//       brands.add(BrandModel.fromJson(item));
//     }
//     return brands;
//   }
// }

// lib/core/repositories/product_repository.dart
import 'package:get/get.dart';

import '../constants/app_constants.dart';
// Remove BrandModel import if not used elsewhere, or ensure it's appropriate
// import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/product_details_data.dart';
import '../models/product_model.dart';
import '../models/sub_category_model.dart';
import '../models/item_model.dart';
import '../models/filter_model.dart'; // Ensure this is the updated FilterModel
import '../network/api_provider.dart';
import '../utils/app_exceptions.dart';

class ProductRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiProvider.post(AppConstants.categoryEndpoint);
    List<CategoryModel> categories = [];
    if (response['category'] != null && response['category'] is List) {
      for (var item in response['category']) {
        categories.add(CategoryModel.fromJson(item));
      }
    }
    return categories;
  }

  Future<List<SubCategoryModel>> getSubCategories(int categoryId) async {
    final fields = {'cat_id': categoryId.toString()};
    final response = await _apiProvider.post(
      AppConstants.subCategoryEndpoint,
      fields: fields,
    );
    List<SubCategoryModel> subCategories = [];
    if (response['subCategory'] != null && response['subCategory'] is List) {
      for (var item in response['subCategory']) {
        subCategories.add(SubCategoryModel.fromJson(item));
      }
    }
    return subCategories;
  }

  Future<List<ItemModel>> getItems(int subCategoryId) async {
    final fields = {'sub_cat_id': subCategoryId.toString()};
    final response = await _apiProvider.post(
      AppConstants.itemEndpoint,
      fields: fields,
    );
    List<ItemModel> items = [];
    // Assuming the API returns items under a 'data' key or similar. Adjust if different.
    final itemListData = response['data'] ?? response['items'];
    if (itemListData != null && itemListData is List) {
      for (var item in itemListData) {
        items.add(ItemModel.fromJson(item));
      }
    }
    return items;
  }

  // getBrands might need to be getAllBrands if it's not item_id specific for filters
  // For now, assuming getBrands(int itemId) is for item-specific brands not general filter options
  // Future<List<BrandModel>> getBrands(int itemId) async { ... }


  Future<List<ProductModel>> getProducts({
    int? categoryId,
    int? subCategoryId,
    int? itemId,
    int? brandId, // This brandId would be an actual ID, not a name
  }) async {
    final fields = <String, String>{};
    if (categoryId != null) fields['cat_id'] = categoryId.toString();
    if (subCategoryId != null) fields['sub_cat_id'] = subCategoryId.toString();
    if (itemId != null) fields['item_id'] = itemId.toString();
    if (brandId != null) fields['brand_id'] = brandId.toString();

    final response = await _apiProvider.post(
      AppConstants.productEndpoint,
      fields: fields,
    );
    List<ProductModel> products = [];
    final productListData = response['product'] ?? response['products'] ?? response['data'];
    if (productListData != null && productListData is List) {
      for (var item in productListData) {
        products.add(ProductModel.fromJson(item));
      }
    }
    return products;
  }

  Future<ProductDetailData> getProductDetails(int productId) async {
    final fields = {'product_id': productId.toString()};
    final response = await _apiProvider.post(
      AppConstants.productDetailsEndpoint,
      fields: fields,
    );
    if (response['productDetail'] != null && response['productDetail'] is Map<String, dynamic>) {
      return ProductDetailData.fromJson(response['productDetail']);
    } else {
      throw FetchDataException("Failed to parse product details from response.");
    }
  }

  Future<FilterModel> getFilters(int itemId) async {
    final fields = {'item_id': itemId.toString()};
    final response = await _apiProvider.post(
      AppConstants.filterEndpoint,
      fields: fields,
    );
    // FilterModel.fromJson expects the whole response map
    return FilterModel.fromJson(response);
  }

  Future<List<ProductModel>> filterProducts({
    int? categoryId,
    int? subCategoryId,
    int? itemId,
    // brandNames are now handled within dynamicFilters if "Brands" is a key there
    String? sortBy,
    List<String>? discounts,
    Map<String, List<String>>? dynamicFilters,
    double? minPrice,
    double? maxPrice,
  }) async {
    final fields = <String, String>{};

    if (categoryId != null) fields['cat_id'] = categoryId.toString();
    if (subCategoryId != null) fields['sub_cat_id'] = subCategoryId.toString();
    if (itemId != null) fields['item_id'] = itemId.toString();
    if (sortBy != null) fields['sortBy'] = sortBy;
    if (minPrice != null) fields['min_price'] = minPrice.toString();
    if (maxPrice != null) fields['max_price'] = maxPrice.toString();

    if (discounts != null) {
      for (int i = 0; i < discounts.length; i++) {
        fields['discounts[$i]'] = discounts[i];
      }
    }

    if (dynamicFilters != null) {
      dynamicFilters.forEach((key, values) {
        if (values.isNotEmpty) {
          for (int i = 0; i < values.length; i++) {
            // This creates: dynamicFilters[FilterName][0]=Value1, dynamicFilters[FilterName][1]=Value2
            // The API might expect dynamicFilters[FilterName][]=Value1&dynamicFilters[FilterName][]=Value2
            // The http package handles list parameters like this usually by appending []
            fields['dynamicFilters[$key][]'] = values[i];
          }
        }
      });
    }
    print("Filtering products with fields: $fields"); // For debugging

    final response = await _apiProvider.post(
      AppConstants.filterProductEndpoint,
      fields: fields,
    );

    List<ProductModel> products = [];
    final productListData = response['products'] ?? response['data'];
    if (productListData != null && productListData is List) {
      for (var item in productListData) {
        products.add(ProductModel.fromJson(item));
      }
    }
    return products;
  }

// Method to fetch ALL brands (if needed for a general brand filter separate from dynamic filters)
// Future<List<BrandModel>> getAllBrands() async { ... }
}