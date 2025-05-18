// lib/core/widgets/sub_category_card.dart
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/sub_category_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart'; // Ensure AppConstants is imported

// Define or import the helper function (ensure only one definition)
String buildImageUrl(String? imagePath) {
  if (kDebugMode) { print('[DEBUG buildImageUrl] received: $imagePath'); }
  if (imagePath == null || imagePath.trim().isEmpty) {
    if (kDebugMode) { print('[DEBUG buildImageUrl] returning empty string for null/empty input.'); }
    return '';
  }
  if (imagePath.trim().startsWith('http')) {
    if (kDebugMode) { print('[DEBUG buildImageUrl] returning existing URL: $imagePath'); }
    return imagePath.trim();
  }
  final baseUrl = AppConstants.baseUrl.endsWith('/') ? AppConstants.baseUrl : '${AppConstants.baseUrl}/';
  const pathSegment = "manual_storage/"; // Adjust if needed
  final path = imagePath.trim().startsWith('/') ? imagePath.substring(1) : imagePath.trim();
  final fullUrl = '$baseUrl$pathSegment$path';
  if (kDebugMode) { print('[DEBUG buildImageUrl] constructed URL: $fullUrl'); }
  return fullUrl;
}


class SubCategoryCard extends StatelessWidget {
  final SubCategoryModel subCategory;
  final VoidCallback onTap;

  const SubCategoryCard({
    super.key,
    required this.subCategory,
    required this.onTap,
  });

  // Define the placeholder widget separately for reuse
  Widget _buildPlaceholder(String reason) {
    if (kDebugMode) { print('[DEBUG SubCategoryCard ${subCategory.name}] Building placeholder. Reason: $reason'); }
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.grey[400], size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) { print('[DEBUG SubCategoryCard] Building card for: ${subCategory.name} (ID: ${subCategory.id})'); }
    final imageUrl = buildImageUrl(subCategory.img);
    if (kDebugMode) { print('[DEBUG SubCategoryCard ${subCategory.name}] Final imageUrl: "$imageUrl"'); }

    // --- Debug Numeric Properties ---
    const double cardElevation = 1.5;
    const double textFontSize = 12.0;
    const EdgeInsets textPadding = EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0);
    if (kDebugMode) {
      print('[DEBUG SubCategoryCard ${subCategory.name}] Card Elevation: $cardElevation (Type: ${cardElevation.runtimeType})');
      print('[DEBUG SubCategoryCard ${subCategory.name}] Text Font Size: $textFontSize (Type: ${textFontSize.runtimeType})');
      print('[DEBUG SubCategoryCard ${subCategory.name}] Text Padding: $textPadding');
    }
    // --- End Debug ---

    return Card(
      elevation: cardElevation, // Use variable
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // --- Strict Conditional Logic ---
              child: imageUrl.isNotEmpty // Check if URL is valid *before* creating widget
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) {
                  if (kDebugMode) { print('‼️ [DEBUG SubCategoryCard ${subCategory.name}] Error loading image "$url": $error'); }
                  return _buildPlaceholder("Image load error"); // Show placeholder on error
                },
                fit: BoxFit.cover,
              )
                  : _buildPlaceholder("Empty image URL"), // Show placeholder directly if URL is empty
              // --- End Strict Conditional Logic ---
            ),
            Padding(
              padding: textPadding, // Use variable
              child: Text(
                subCategory.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: textFontSize, // Use variable
                    color: AppColors.textPrimary.withOpacity(0.9),
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}