class UserModel {
  final String id;
  final String name;
  final String email;
  String status; // Can be 'Active' or 'Inactive'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });
}
