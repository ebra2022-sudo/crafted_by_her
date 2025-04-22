import 'package:flutter/material.dart';
import '../domain/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _adminToken = '';
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneNumberError;
  String? _adminTokenError;
  String? _roleError;
  String? _genderError;
  bool _isLoading = false;
  Role _selectedRole = Role.buyer;
  Gender? _selectedGender;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // TextEditingControllers for each field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _adminTokenController = TextEditingController();

  // Getters for controllers
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get adminTokenController => _adminTokenController;

  // Getters for state
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phoneNumber => _phoneNumber;
  String get adminToken => _adminToken;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get phoneNumberError => _phoneNumberError;
  String? get adminTokenError => _adminTokenError;
  String? get roleError => _roleError;
  String? get genderError => _genderError;
  bool get isLoading => _isLoading;
  Role get selectedRole => _selectedRole;
  Gender? get selectedGender => _selectedGender;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get rememberMe => _rememberMe;

  AuthViewModel() {
    // Add listeners to controllers to update state
    _emailController.addListener(() {
      _email = _emailController.text;
      _validateEmail();
      notifyListeners();
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
      _validatePassword();
      notifyListeners();
    });
    _confirmPasswordController.addListener(() {
      _confirmPassword = _confirmPasswordController.text;
      _validateConfirmPassword();
      notifyListeners();
    });
    _firstNameController.addListener(() {
      _firstName = _firstNameController.text;
      _validateFirstName();
      notifyListeners();
    });
    _lastNameController.addListener(() {
      _lastName = _lastNameController.text;
      _validateLastName();
      notifyListeners();
    });
    _phoneNumberController.addListener(() {
      _phoneNumber = _phoneNumberController.text;
      _validatePhoneNumber();
      notifyListeners();
    });
    _adminTokenController.addListener(() {
      _adminToken = _adminTokenController.text;
      _validateAdminToken();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _adminTokenController.dispose();
    super.dispose();
  }

  // Setter methods
  void setEmail(String value) {
    _email = value;
    _emailController.text = value;
    _validateEmail();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordController.text = value;
    _validatePassword();
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPasswordController.text = value;
    _validateConfirmPassword();
    notifyListeners();
  }

  void setFirstName(String value) {
    _firstName = value;
    _firstNameController.text = value;
    _validateFirstName();
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    _lastNameController.text = value;
    _validateLastName();
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    _phoneNumberController.text = value;
    _validatePhoneNumber();
    notifyListeners();
  }

  void setAdminToken(String value) {
    _adminToken = value;
    _adminTokenController.text = value;
    _validateAdminToken();
    notifyListeners();
  }

  // Clear methods
  void clearEmail() {
    _email = '';
    _emailController.clear();
    _validateEmail();
    notifyListeners();
  }

  void clearPassword() {
    _password = '';
    _passwordController.clear();
    _validatePassword();
    notifyListeners();
  }

  void clearConfirmPassword() {
    _confirmPassword = '';
    _confirmPasswordController.clear();
    _validateConfirmPassword();
    notifyListeners();
  }

  void clearFirstName() {
    _firstName = '';
    _firstNameController.clear();
    _validateFirstName();
    notifyListeners();
  }

  void clearLastName() {
    _lastName = '';
    _lastNameController.clear();
    _validateLastName();
    notifyListeners();
  }

  void clearPhoneNumber() {
    _phoneNumber = '';
    _phoneNumberController.clear();
    _validatePhoneNumber();
    notifyListeners();
  }

  void clearAdminToken() {
    _adminToken = '';
    _adminTokenController.clear();
    _validateAdminToken();
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
      _validateRole();
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
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

  bool _validateFirstName() {
    if (_firstName.isEmpty) {
      _firstNameError = 'First name is required';
      return false;
    }
    _firstNameError = null;
    return true;
  }

  bool _validateLastName() {
    if (_lastName.isEmpty) {
      _lastNameError = 'Last name is required';
      return false;
    }
    _lastNameError = null;
    return true;
  }

  bool _validatePhoneNumber() {
    if (_phoneNumber.isEmpty) {
      _phoneNumberError = 'Phone number is required';
      return false;
    }
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(_phoneNumber)) {
      _phoneNumberError = 'Enter a valid phone number';
      return false;
    }
    _phoneNumberError = null;
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
    bool isFirstNameValid = _validateFirstName();
    bool isLastNameValid = _validateLastName();
    bool isPhoneNumberValid = _validatePhoneNumber();
    bool isRoleValid = _validateRole();
    bool isGenderValid = _validateGender();
    bool isAdminTokenValid =
        _selectedRole == Role.admin ? _validateAdminToken() : true;
    return isEmailValid &&
        isPasswordValid &&
        isConfirmPasswordValid &&
        isFirstNameValid &&
        isLastNameValid &&
        isPhoneNumberValid &&
        isRoleValid &&
        isGenderValid &&
        isAdminTokenValid;
  }

  Future<bool> login() async {
    if (!validateLoginForm()) return false;
    _isLoading = true;
    notifyListeners();

    await Future<Duration>.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register() async {
    if (!validateRegisterForm()) return false;
    _isLoading = true;
    notifyListeners();

    await Future<Duration>.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> forgotPassword() async {
    if (!_validateEmail()) return false;
    _isLoading = true;
    notifyListeners();

    try {
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _emailError = 'Failed to send reset email: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
