// class FilterModel {
//   final List<String>? brands;
//   final List<String>? colors;
//   final List<String>? sizes;
//   final double? minPrice;
//   final double? maxPrice;
//   final Map<String, List<String>>? dynamicFilters;
//
//   FilterModel({
//     this.brands,
//     this.colors,
//     this.sizes,
//     this.minPrice,
//     this.maxPrice,
//     this.dynamicFilters,
//   });
//
//   factory FilterModel.fromJson(Map<String, dynamic> json) {
//     Map<String, List<String>> dynamicFiltersMap = {};
//
//     if (json['dynamic_filters'] != null) {
//       json['dynamic_filters'].forEach((key, value) {
//         dynamicFiltersMap[key] = List<String>.from(value);
//       });
//     }
//
//     return FilterModel(
//       brands: json['brands'] != null ? List<String>.from(json['brands']) : null,
//       colors: json['colors'] != null ? List<String>.from(json['colors']) : null,
//       sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
//       minPrice: json['min_price'] != null ? double.parse(json['min_price'].toString()) : null,
//       maxPrice: json['max_price'] != null ? double.parse(json['max_price'].toString()) : null,
//       dynamicFilters: dynamicFiltersMap.isNotEmpty ? dynamicFiltersMap : null,
//     );
//   }
// }

// lib/core/models/filter_model.dart
class FilterModel {
  final Map<String, List<String>>? dynamicFilters; // To store things like "Trending", "Color", "Size"
  final List<String>? brands;
  final double? minPrice;
  final double? maxPrice;

  FilterModel({
    this.dynamicFilters,
    this.brands,
    this.minPrice,
    this.maxPrice,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> parsedDynamicFilters = {};
    if (json['filters'] != null && json['filters'] is Map) {
      (json['filters'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          parsedDynamicFilters[key] = value.map((item) => item.toString()).toList();
        }
      });
    }

    List<String>? parsedBrands;
    if (json['brands'] != null && json['brands'] is List) {
      parsedBrands = (json['brands'] as List).map((item) => item.toString()).toList();
    }

    // Assuming min_price and max_price are NOT part of the main 'filters' object in the API response,
    // but could be at the same level as 'filters' and 'brands' if your API supports it.
    // If they are indeed within the 'filters' map, you'd parse them from there.
    // For this implementation, we assume they might be top-level like "brands".
    double? minP = json['min_price'] != null ? double.tryParse(json['min_price'].toString()) : null;
    double? maxP = json['max_price'] != null ? double.tryParse(json['max_price'].toString()) : null;

    return FilterModel(
      dynamicFilters: parsedDynamicFilters.isNotEmpty ? parsedDynamicFilters : null,
      brands: parsedBrands,
      minPrice: minP, // Assign parsed min price
      maxPrice: maxP, // Assign parsed max price
    );
  }
}