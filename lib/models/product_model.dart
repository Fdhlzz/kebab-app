import '../utils/constants.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String categoryName;
  final bool isAvailable;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryName,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1. Handle Image Logic (Laravel sends 'images' array)
    String imageUrl = '';

    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      // Grab the first image from the array
      String rawPath = json['images'][0]['image_path'] ?? '';

      if (rawPath.isNotEmpty) {
        if (rawPath.startsWith('http')) {
          imageUrl = rawPath;
        } else {
          // Combine Storage URL with the path
          imageUrl = '${AppConstants.storageUrl}/$rawPath';
        }
      }
    }

    // 2. Safely parse numbers (API sends numbers, JSON sometimes reads as Strings)
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    return Product(
      id: json['id'],
      title: json['name'] ?? 'Unknown Menu', // Laravel sends 'name'
      description: json['description'] ?? '',
      price: parsedPrice,
      image: imageUrl,
      // Handle null category safely
      categoryName: json['category'] != null
          ? json['category']['name']
          : 'Menu',
      // Laravel sends 1/0 for boolean
      isAvailable: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
