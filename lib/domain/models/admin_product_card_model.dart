class ProductModel {
  final String id;
  final String name;
  final String sellerEmail;
  final double averageRating;
  String status; // Can be 'Active' or 'Inactive'

  ProductModel({
    required this.id,
    required this.name,
    required this.sellerEmail,
    required this.averageRating,
    required this.status,
  });
}
