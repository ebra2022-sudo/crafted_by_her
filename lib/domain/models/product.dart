import 'package:crafted_by_her/domain/models/rating.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

// UserInfo model
class UserInfo {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String profilePhoto;

  UserInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profilePhoto: json['profilePhoto'] as String? ?? '',
    );
  }
}

// ProductStats model
class ProductStats {
  final double averageRating;
  final int ratingCount;

  ProductStats({
    required this.averageRating,
    required this.ratingCount,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
    );
  }
}

// Product model
class Product {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final List<String> images; // Extracted from image objects
  final String contactInfo;
  final UserInfo userId;
  final double averageRating;
  final int ratingCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Rating> ratings;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.images,
    required this.contactInfo,
    required this.userId,
    required this.averageRating,
    required this.ratingCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.ratings,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageList = (json['images'] as List<dynamic>?)
            ?.map((e) =>
                e is Map<String, dynamic> ? e['url']?.toString() ?? '' : '')
            .where((url) => url.isNotEmpty)
            .toList() ??
        [];

    return Product(
      id: json['_id'] as String? ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      contactInfo: json['contactInfo']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: imageList,
      userId: UserInfo.fromJson(
        (json['userId'] as Map<String, dynamic>?) ??
            {
              '_id': '',
              'email': '',
              'firstName': '',
              'lastName': '',
              'profilePhoto': ''
            },
      ),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      ratings: (json['ratings'] as List<dynamic>?)
              ?.map((e) => Rating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CreateProductRequest {
  final String title;
  final String description;
  final String category;
  final double price;
  final List<String> images;
  final String contactInfo;
  final String userId;
  final String expirationDate;

  CreateProductRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.images,
    required this.contactInfo,
    required this.userId,
    required this.expirationDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'images': images,
        'contactInfo': contactInfo,
        'userId': userId,
        'expirationDate': expirationDate,
      };
}

class ProductData with ChangeNotifier {
  String? category;
  String? productName;
  String? description;
  String? price;
  XFile? previewImage;
  List<XFile> images = [];
  List<String> imageUrls = [];

  void updateProduct({
    String? category,
    String? productName,
    String? description,
    String? price,
    XFile? previewImage,
    List<String>? imageUrls,
  }) {
    if (category != null) this.category = category;
    if (productName != null) this.productName = productName;
    if (description != null) this.description = description;
    if (price != null) this.price = price;
    if (previewImage != null) this.previewImage = previewImage;
    if (imageUrls != null) this.imageUrls = imageUrls;
    notifyListeners();
  }

  void addImages(List<XFile> newImages) {
    if (images.length + newImages.length <= 10) {
      images.addAll(newImages);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      notifyListeners();
    }
  }

  void setPreviewImage(XFile? image) {
    previewImage = image;
    notifyListeners();
  }

  void clear() {
    category = null;
    productName = null;
    description = null;
    price = null;
    previewImage = null;
    images.clear();
    imageUrls.clear();
    notifyListeners();
  }

  void copyFrom(ProductData source) {
    category = source.category;
    productName = source.productName;
    description = source.description;
    price = source.price;
    previewImage = source.previewImage;
    images = List<XFile>.from(source.images);
    imageUrls = List<String>.from(source.imageUrls);
  }

  bool get isProductInfoValid {
    return category != null &&
        category!.isNotEmpty &&
        productName != null &&
        productName!.isNotEmpty &&
        price != null &&
        price!.isNotEmpty;
  }

  bool get hasPreviewImage => previewImage != null;

  bool get hasAdditionalImages => images.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'productName': productName,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
    };
  }

  @override
  String toString() {
    return 'ProductData{category: $category, productName: $productName, '
        'description: $description, price: $price, previewImage: $previewImage, '
        'images: ${images.length}, imageUrls: $imageUrls}';
  }
}
