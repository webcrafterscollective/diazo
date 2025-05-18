import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import this
import 'package:shimmer/shimmer.dart';                         // Import Shimmer for placeholder
import '../constants/app_colors.dart';
import '../constants/app_constants.dart'; // Import AppConstants for base URL

class CategoryCard extends StatelessWidget {
  final String? imageUrl; // Changed to imageUrl (nullable String)
  final String title;

  const CategoryCard({
    super.key,
    required this.imageUrl, // Added imageUrl
    required this.title,
  });

  // Helper to build image URL (reuse or centralize this logic)
  String _buildFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return ''; // Handle null or empty path
    if (path.startsWith('http')) return path;
    final baseUrl = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl
        : '${AppConstants.baseUrl}/';
    final imagePath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl$imagePath';
  }


  @override
  Widget build(BuildContext context) {
    final fullImageUrl = _buildFullImageUrl("manual_storage/$imageUrl");

    return SizedBox(
      width: 75, // Keep fixed width
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias, // Clip the image
            color: AppColors.inputBackground,
            child: AspectRatio( // Maintain aspect ratio for the image container
              aspectRatio: 1.0, // Square aspect ratio
              child: CachedNetworkImage(
                imageUrl: fullImageUrl,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  // Display a placeholder icon if image fails
                  child: Icon(Icons.category_outlined, color: Colors.grey, size: 28),
                ),
                fit: BoxFit.cover, // Cover the card area
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1, // Ensure title doesn't wrap excessively
            overflow: TextOverflow.ellipsis, // Handle overflow
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}