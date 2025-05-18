// lib/models/item_model.dart
class ItemModel {
  final int id;
  final int subCategoryId;
  final String name;
  final String image;

  ItemModel({
    required this.id,
    required this.subCategoryId,
    required this.name,
    required this.image,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      subCategoryId: json['sub_cat_id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
