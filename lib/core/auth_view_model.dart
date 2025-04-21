import 'package:flutter/material.dart';
import '../domain/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  Role _selectedRole = Role.buyer; // Default role
  Gender? _selectedGender;
  String _adminToken = '';
  String? _adminTokenError;
  String? _roleError;
  String? _genderError;

  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  bool get isLoading => _isLoading;
  Role get selectedRole => _selectedRole;
  Gender? get selectedGender => _selectedGender;
  String get adminToken => _adminToken;
  String? get adminTokenError => _adminTokenError;
  String? get roleError => _roleError;
  String? get genderError => _genderError;

  void setFirstName(String value) {
    _firstName = value;
    if (_firstName.length > 12) {
      _firstNameError = 'The length should be at most 12 characters';
    }
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    if (_lastName.length > 12) {
      _lastNameError = 'The length should be at most 12 characters';
    }
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _validateEmail();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _validatePassword();
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _validateConfirmPassword();
    notifyListeners();
  }

  void setRole(Role? value) {
    if (value != null) {
      _selectedRole = value;
      _validateRole();
    }
    notifyListeners();
  }

  void setGender(Gender? value) {
    if (value != null) {
      _selectedGender = value;
      _validateRole(); // Re-validate role based on gender
    }
    notifyListeners();
  }

  void setAdminToken(String value) {
    _adminToken = value;
    _validateAdminToken();
    notifyListeners();
  }


  bool _validateEmail() {
    if (_email.isEmpty) {
      _emailError = 'Email is required';
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_email)) {
      _emailError = 'Enter a valid email';
      return false;
    }
    _emailError = null;
    return true;
  }

  bool _validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Password is required';
      return false;
    }
    if (_password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      return false;
    }
    _passwordError = null;
    return true;
  }

  bool _validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm password is required';
      return false;
    }
    if (_confirmPassword != _password) {
      _confirmPasswordError = 'Passwords do not match';
      return false;
    }
    _confirmPasswordError = null;
    return true;
  }

  bool _validateRole() {
    if (_selectedGender == null) {
      _roleError = null;
      return true;
    }
    if (_selectedGender == Gender.male && _selectedRole == Role.seller) {
      _roleError = 'Males can only be Buyers';
      return false;
    }
    if (_selectedRole == Role.admin && _adminToken.isEmpty) {
      _roleError = 'Admin role requires a token';
      return false;
    }
    _roleError = null;
    return true;
  }

  bool _validateGender() {
    if (_selectedGender == null) {
      _genderError = 'Gender is required';
      return false;
    }
    _genderError = null;
    return true;
  }

  bool _validateAdminToken() {
    if (_selectedRole == Role.admin && _adminToken.isEmpty) {
      _adminTokenError = 'Admin token is required';
      return false;
    }
    // Simulate token validation (replace with actual validation)
    if (_selectedRole == Role.admin && _adminToken != 'ADMIN_TOKEN_123') {
      _adminTokenError = 'Invalid admin token';
      return false;
    }
    _adminTokenError = null;
    return true;
  }

  bool validateLoginForm() {
    bool isEmailValid = _validateEmail();
    bool isPasswordValid = _validatePassword();
    return isEmailValid && isPasswordValid;
  }

  bool validateRegisterForm() {
    bool isEmailValid = _validateEmail();
    bool isPasswordValid = _validatePassword();
    bool isConfirmPasswordValid = _validateConfirmPassword();
    bool isRoleValid = _validateRole();
    bool isGenderValid = _validateGender();
    bool isAdminTokenValid = _selectedRole == Role.admin ? _validateAdminToken() : true;
    return isEmailValid &&
        isPasswordValid &&
        isConfirmPasswordValid &&
        isRoleValid &&
        isGenderValid &&
        isAdminTokenValid;
  }

  Future<bool> login() async {
    if (!validateLoginForm()) return false;
    _isLoading = true;
    notifyListeners();

    // Simulate API call for login
    await Future<Duration>.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register() async {
    if (!validateRegisterForm()) return false;
    _isLoading = true;
    notifyListeners();

    // Simulate API call for registration
    await Future<Duration>.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }
}