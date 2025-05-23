import 'package:flutter/material.dart';
// Import the constants file

enum Gender { male, female }

enum Role { admin, superAdmin, user }

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profilePhoto;
  final Gender gender;
  final Role role;
  final Map<String, dynamic> interfaceAccess;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePhoto,
    required this.gender,
    required this.role,
    required this.interfaceAccess,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? json;

    // Extract the profilePhoto url from the nested object
    String? profilePhotoUrl;
    final profilePhotoRaw = userData['profilePhoto'];
    if (profilePhotoRaw is Map<String, dynamic>) {
      // From login response: { "url": "...", "public_id": "..." }
      profilePhotoUrl = profilePhotoRaw['url'] as String?;
    } else if (profilePhotoRaw is String?) {
      // From updateProfile response: "https://example.com/photo.jpg"
      profilePhotoUrl = profilePhotoRaw;
    } else {
      profilePhotoUrl = null; // Fallback for unexpected types
    }

    return UserModel(
      id: userData['id'] as String? ?? userData['_id'] as String? ?? '',
      firstName: userData['firstName'] as String? ?? '',
      lastName: userData['lastName'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      phoneNumber: userData['phoneNumber'] as String? ?? '',
      profilePhoto: profilePhotoUrl, // Assign the url from the object
      gender: _parseGender(userData['gender'] as String? ?? ''),
      role: _parseRole(userData['role'] as String? ?? ''),
      interfaceAccess: (userData['interfaceAccess'] as Map<String, dynamic>?) ??
          {'dashboard': '', 'features': []},
    );
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePhoto,
    Gender? gender,
    Role? role,
    Map<String, dynamic>? interfaceAccess,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      interfaceAccess: interfaceAccess ?? this.interfaceAccess,
    );
  }

  Map<String, dynamic> toJson({bool nested = true}) {
    final data = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhoto': profilePhoto,
      'gender': gender.name,
      'role': role.name,
      'interfaceAccess': interfaceAccess,
    };
    return nested ? {'user': data} : data;
  }

  static Gender _parseGender(String? value) {
    if (value == null) return Gender.male;
    try {
      return Gender.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => Gender.male,
      );
    } catch (e) {
      debugPrint('Error parsing gender: $value, defaulting to male');
      return Gender.male;
    }
  }

  static Role _parseRole(String? value) {
    if (value == null) return Role.user;
    try {
      return Role.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => Role.user,
      );
    } catch (e) {
      debugPrint('Error parsing role: $value, defaulting to user');
      return Role.user;
    }
  }
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePhoto,
    Gender? gender,
    Role? role,
    Map<String, dynamic>? interfaceAccess,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        profilePhoto: profilePhoto,
        gender: gender,
        role: role,
        interfaceAccess: interfaceAccess,
      );
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
