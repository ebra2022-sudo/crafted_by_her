// Assuming this path is correct

// Assuming this path is correct

class AdminModel {
  final String id;
  final String name;
  final String email;
  final String role;
  String status; // Can be 'Active' or 'Inactive'

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}
