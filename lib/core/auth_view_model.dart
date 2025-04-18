import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  bool get isLoading => _isLoading;

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

  bool validateLoginForm() {
    bool isEmailValid = _validateEmail();
    bool isPasswordValid = _validatePassword();
    return isEmailValid && isPasswordValid;
  }

  bool validateRegisterForm() {
    bool isEmailValid = _validateEmail();
    bool isPasswordValid = _validatePassword();
    bool isConfirmPasswordValid = _validateConfirmPassword();
    return isEmailValid && isPasswordValid && isConfirmPasswordValid;
  }

  Future<bool> login() async {
    if (!validateLoginForm()) return false;
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future<Duration>.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register() async {
    if (!validateRegisterForm()) return false;
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future<Duration>.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }
}