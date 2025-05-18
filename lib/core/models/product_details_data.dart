// lib/core/models/product_detail_data.dart

import 'dart:convert'; // For jsonDecode if parsing options/attributes

class ProductDetailData {
  final int? variantId; // <-- ADDED: To store the ID of the specific variant
  final String? description;
  final int? returnDay;
  final String? returnDayUnit;
  final String? warranty; // Assuming warranty duration (e.g., "1", "2")
  final String? warrantyUnit; // E.g., "year", "month"
  final String? coverWarranty;
  final String? notCoverWarranty;
  final String? warrantySummary;
  final String? manufacturerDetails;
  final String? optionName; // e.g., "Color||Size"
  final String? optionValue; // e.g., "Red||XXL"
  final double printedPrice;
  final double price;
  final int stock;
  final String? attributeName; // e.g., "Material||Weight"
  final String? attributeValue; // e.g., "Cotton||200g"
  final String? featureName; // e.g., "trending"
  final String? featureValue; // e.g., "rr"

  // Processed Options/Attributes (optional, can be done in UI too)
  late final Map<String, List<String>> optionsMap;
  late final Map<String, String> attributesMap;

  ProductDetailData({
    this.variantId, // <-- ADDED to constructor
    this.description,
    this.returnDay,
    this.returnDayUnit,
    this.warranty,
    this.warrantyUnit,
    this.coverWarranty,
    this.notCoverWarranty,
    this.warrantySummary,
    this.manufacturerDetails,
    this.optionName,
    this.optionValue,
    required this.printedPrice,
    required this.price,
    required this.stock,
    this.attributeName,
    this.attributeValue,
    this.featureName,
    this.featureValue,
  }) {
    optionsMap = _parseOptions(optionName, optionValue);
    attributesMap = _parseAttributes(attributeName, attributeValue);
  }

  // Helper function to parse "Key1||Key2" and "Val1||Val2" into a map
  static Map<String, List<String>> _parseOptions(String? names, String? values) {
    if (names == null || values == null || names.isEmpty || values.isEmpty) {
      return {};
    }
    final Map<String, List<String>> map = {};
    try {
      final nameList = names.split('||');
      final valueList = values.split('||');

      if (nameList.length == valueList.length) {
        for (int i = 0; i < nameList.length; i++) {
          map[nameList[i]] = [valueList[i]];
        }
      } else {
        print("Warning: Option names and values lengths do not match.");
      }
    } catch (e) {
      print("Error parsing options: $e");
    }
    return map;
  }

  // Similar parsing for attributes if needed
  static Map<String, String> _parseAttributes(String? names, String? values) {
    if (names == null || values == null || names.isEmpty || values.isEmpty) {
      return {};
    }
    final Map<String, String> map = {};
    try {
      final nameList = names.split('||');
      final valueList = values.split('||');
      if (nameList.length == valueList.length) {
        for (int i = 0; i < nameList.length; i++) {
          map[nameList[i]] = valueList[i];
        }
      } else {
        print("Warning: Attribute names and values lengths do not match.");
      }
    } catch (e) {
      print("Error parsing attributes: $e");
    }
    return map;
  }


  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse double
    double parseDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      return double.tryParse(value.toString()) ?? defaultValue;
    }
    // Helper to safely parse int
    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return ProductDetailData(
      // Assuming your API response for product details includes a 'variant_id' field
      // for the specific product variant being displayed.
      variantId: parseInt(json['variant_id']), // <-- ADDED parsing for variant_id
      description: json['description'] as String?,
      returnDay: parseInt(json['return_day']),
      returnDayUnit: json['return_day_unit'] as String?,
      warranty: json['warranty'] as String?,
      warrantyUnit: json['warranty_unit'] as String?,
      coverWarranty: json['cover_warranty'] as String?,
      notCoverWarranty: json['not_cover_warranty'] as String?,
      warrantySummary: json['warranty_summary'] as String?,
      manufacturerDetails: json['manufacturer_details'] as String?,
      optionName: json['option_name'] as String?,
      optionValue: json['option_value'] as String?,
      printedPrice: parseDouble(json['printed_price']),
      price: parseDouble(json['price']),
      stock: parseInt(json['stock']),
      attributeName: json['attribute_name'] as String?,
      attributeValue: json['attribute_value'] as String?,
      featureName: json['feature_name'] as String?,
      featureValue: json['feature_value'] as String?,
    );
  }
}