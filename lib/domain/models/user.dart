enum Role { buyer, seller, admin }
enum Gender { male, female }

class User {
  final String email;
  final Role role;
  final Gender gender;
  final String? adminToken;

  User({
    required this.email,
    required this.role,
    required this.gender,
    this.adminToken,
  });
}