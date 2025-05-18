// lib/core/models/sub_category_model.dart
import 'package:flutter/foundation.dart'; // Import for kDebugMode

class SubCategoryModel {
  final int id;
  final String name;
  final String? title;
  final int? position;
  final String? img;

  SubCategoryModel({
    required this.id,
    required this.name,
    this.title,
    this.position,
    this.img,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('[DEBUG SubCategoryModel.fromJson] Processing ID: ${json['id']}');
    }
    int? parsedPosition;
    final rawPosition = json['position'];

    if (rawPosition != null) {
      parsedPosition = int.tryParse(rawPosition.toString());
      if (kDebugMode) {
        print('[DEBUG SubCategoryModel.fromJson ID: ${json['id']}] rawPosition value: "$rawPosition", type: ${rawPosition.runtimeType}, parsedPosition: $parsedPosition');
        // Explicit check for boolean type
        if (rawPosition is bool) {
          print('‼️ [DEBUG SubCategoryModel.fromJson ID: ${json['id']}] WARNING: rawPosition is a boolean!');
        }
      }
    } else {
      if (kDebugMode) {
        print('[DEBUG SubCategoryModel.fromJson ID: ${json['id']}] rawPosition is null.');
      }
    }

    // --- Debug check for 'id' type ---
    final rawId = json['id'];
    if (kDebugMode && rawId != null && rawId is! int) {
      print('‼️ [DEBUG SubCategoryModel.fromJson ID: ${json['id']}] WARNING: json[\'id\'] is not an integer! Type: ${rawId.runtimeType}');
    }
    // --- End debug check ---

    return SubCategoryModel(
      id: (rawId is int) ? rawId : 0, // Use parsed int or default
      name: json['name'] as String? ?? 'Unnamed', // Handle null name
      title: json['title'] as String?,
      position: parsedPosition,
      img: json['img'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // ... toJson implementation ...
    return {
      'id': id,
      'name': name,
      'title': title,
      'position': position,
      'img': img,
    };
  }
}