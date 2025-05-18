// lib/core/models/brand_model.dart
class BrandModel {
  final int id;
  // final int itemId; // Removed: Not in the provided 'all brands' response structure
  final String name;
  final String? title;    // Added field, make it nullable
  final int? position;   // Added field, make it nullable
  final String? img;      // Changed from 'image', make it nullable

  BrandModel({
    required this.id,
    // required this.itemId, // Removed from constructor
    required this.name,
    this.title,       // Added to constructor
    this.position,    // Added to constructor
    this.img,         // Changed in constructor
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'], // Keep as is
      name: json['name'], // Keep as is
      title: json['title'] as String?, // Parse 'title', handle potential null
      position: json['position'] as int?, // Parse 'position', handle potential null
      img: json['img'] as String?,       // Parse 'img' instead of 'image', handle potential null
    );
  }
}