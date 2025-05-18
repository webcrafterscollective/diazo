// class ProductModel {
//   final int id;
//   final String uid;
//   final String sku;
//   final String name;
//   final String title;
//   final double price;
//   final double printedPrice;
//   final int stock;
//   final String mainImage;
//   final List<String> images; // Will include main and optional other images
//   final bool inWishlist; // Still keeping it for app-level logic
//
//   ProductModel({
//     required this.id,
//     required this.uid,
//     required this.sku,
//     required this.name,
//     required this.title,
//     required this.price,
//     required this.printedPrice,
//     required this.stock,
//     required this.mainImage,
//     required this.images,
//     this.inWishlist = false,
//   });
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     final mainImg = json['main_img'] ?? '';
//     final otherImg = json['other_img'];
//
//     return ProductModel(
//       id: json['id'],
//       uid: json['uid'],
//       sku: json['sku'],
//       name: json['name'],
//       title: json['title'],
//       price: double.tryParse(json['price'].toString()) ?? 0.0,
//       printedPrice: double.tryParse(json['printed_price'].toString()) ?? 0.0,
//       stock: json['stock'] ?? 0,
//       mainImage: mainImg,
//       images: [
//         if (mainImg.isNotEmpty) mainImg,
//         if (otherImg != null && otherImg.isNotEmpty) otherImg,
//       ],
//       inWishlist: json['in_wishlist'] ?? false,
//     );
//   }
// }
// lib/core/models/product_model.dart
class ProductModel {
  final int id;
  final String? uid;
  final String? sku;
  final String name;
  final String? title;
  final double price;
  final double printedPrice;
  final int stock;
  final String? mainImage; // Stores the path like "manual_storage/products/..."
  final List<String> images; // Can be built from mainImage and other_img if present
  final bool inWishlist;

  // New fields from filterProduct response
  final String? categoryName;
  final String? categoryTitle;
  final String? subcategoryName;
  final String? subcategoryTitle;
  final String? itemName;
  final String? itemTitle;
  final String? featureValues; // This is a comma-separated string: "trending: Red,abc: Xl,..."
  final String? brandName;

  ProductModel({
    required this.id,
    this.uid,
    this.sku,
    required this.name,
    this.title,
    required this.price,
    required this.printedPrice,
    required this.stock,
    this.mainImage,
    required this.images,
    this.inWishlist = false,
    this.categoryName,
    this.categoryTitle,
    this.subcategoryName,
    this.subcategoryTitle,
    this.itemName,
    this.itemTitle,
    this.featureValues,
    this.brandName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final mainImgPath = json['main_img'] as String?;
    // Assuming 'other_img' might be a single string or null
    final otherImgPath = json['other_img'] as String?;

    List<String> imageList = [];
    if (mainImgPath != null && mainImgPath.isNotEmpty) {
      imageList.add(mainImgPath);
    }
    if (otherImgPath != null && otherImgPath.isNotEmpty) {
      // If other_img can also be a list of strings (though unlikely based on typical structures)
      // you might need to adjust this. For now, assuming it's a single image path.
      imageList.add(otherImgPath);
    }

    return ProductModel(
      id: json['id'] as int,
      uid: json['uid'] as String?,
      sku: json['sku'] as String?, // Assuming 'sku' might not be in filterProduct response
      name: json['name'] as String? ?? 'Unnamed Product',
      title: json['title'] as String?,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      printedPrice: double.tryParse(json['printed_price'].toString()) ?? 0.0,
      stock: json['stock'] is int ? json['stock'] : (int.tryParse(json['stock'].toString()) ?? 0),
      mainImage: mainImgPath, // Store the raw path as API returns
      images: imageList, // Use the constructed list
      inWishlist: json['in_wishlist'] as bool? ?? false, // Assuming this might not be in filterProduct response

      categoryName: json['category_name'] as String?,
      categoryTitle: json['category_title'] as String?,
      subcategoryName: json['subcategory_name'] as String?,
      subcategoryTitle: json['subcategory_title'] as String?,
      itemName: json['item_name'] as String?,
      itemTitle: json['item_title'] as String?,
      featureValues: json['feature_values'] as String?,
      brandName: json['brand_name'] as String?,
    );
  }
}