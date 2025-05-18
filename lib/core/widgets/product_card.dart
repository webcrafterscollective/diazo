import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart'; // Import AppConstants
import '../models/product_model.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = AppConstants.baseUrl.endsWith('/') ? AppConstants.baseUrl : '${AppConstants.baseUrl}/';
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _buildImageUrl(product.mainImage);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2, // Adjusted aspect ratio
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white), ),
              errorWidget: (context, url, error) => const Center( child: Icon(Icons.broken_image, color: Colors.grey, size: 40) ),
              fit: BoxFit.cover,
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text( product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13) ),
                  const SizedBox(height: 4),
                  // Use AppConstants.currencySymbol
                  Text(
                    '${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}', // <-- Use constant
                    maxLines: 1,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14 ),
                  ),
                  if (product.printedPrice > product.price)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '${AppConstants.currencySymbol}${product.printedPrice.toStringAsFixed(2)}', // <-- Use constant
                        maxLines: 1,
                        style: textTheme.bodySmall?.copyWith( decoration: TextDecoration.lineThrough, color: Colors.grey ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}