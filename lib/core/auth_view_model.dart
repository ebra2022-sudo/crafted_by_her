import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:crafted_by_her/data/prefference_keys.dart';
import 'package:crafted_by_her/domain/models/product.dart';
import 'package:crafted_by_her/domain/models/rating.dart';
import 'package:crafted_by_her/domain/models/review.dart';
import 'package:crafted_by_her/domain/models/user.dart';
import 'package:crafted_by_her/presentation/seller_form_submission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crafted_by_her/data/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/login_screen.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final UserProvider _userProvider;

  AuthViewModel({
    ApiService? apiService,
    Future<void> Function(Duration)? delay,
    UserProvider? userProvider,
  })  : _apiService = apiService ?? ApiService(),
        _userProvider = userProvider ?? UserProvider() {
    _initializeControllers();
    _loadStoredUser();
  }

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  Gender? _selectedGender;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneNumberError;
  String? _genderError;
  String? _apiError;

  // Status fields
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFetchingReviews = false;
  String? _reviewsError;
  List<ReviewModel> _productReviews = [];
  List<Map<String, dynamic>> _myProducts = [];
  bool _isFetchingMyProducts = false;
  String? _myProductsError;
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;
  int _sellerProfileSelectedTabIndex = 0;
  int _profileSelectedTabIndex = 0;

  UserModel? _user;
  String? _token;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController genderController = TextEditingController();

  Timer? _debounce;

  // Product-related fields
  Product? _createdProduct;
  List<Product> _currentProducts = [];
  List<Product> _newReleaseProducts = [];
  Product? _productDetail;
  List<String> _uploadedImageUrls = [];
  ProductData _currentProductData = ProductData();

  // Admin-related fields
  List<Map<String, dynamic>> _inactiveUsers = [];
  List<Map<String, dynamic>> _adminProducts = [];
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _admins = [];
  bool _isFetchingInactiveUsers = false;
  String? _inactiveUsersError;
  bool _isFetchingAdminProducts = false;
  String? _adminProductsError;

  // Admin creation fields
  String _adminFirstName = '';
  String _adminLastName = '';
  String _adminEmail = '';
  String _adminPassword = '';
  String _adminPhoneNumber = '';
  Gender? _adminSelectedGender;
  bool _isAdminPasswordVisible = false;
  String? _adminFirstNameError;
  String? _adminLastNameError;
  String? _adminEmailError;
  String? _adminPasswordError;
  String? _adminPhoneNumberError;
  String? _adminGenderError;

  // Admin creation controllers
  final TextEditingController _adminFirstNameController =
      TextEditingController();
  final TextEditingController _adminLastNameController =
      TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPhoneNumberController =
      TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  // User ratings fields
  List<ReviewModel> _userRatings = [];
  bool _isFetchingUserRatings = false;
  String? _userRatingsError;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  String? get token => _token;
  List<Product> get currentProducts => _currentProducts;
  List<Product> get newReleaseProducts => _newReleaseProducts;
  int get profileSelectedTabIndex => _profileSelectedTabIndex;
  Gender? get selectedGender => _selectedGender;
  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get currentPasswordController =>
      _currentPasswordController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmNewPasswordController =>
      _confirmNewPasswordController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  bool get isFetchingReviews => _isFetchingReviews;
  String? get reviewsError => _reviewsError;
  List<ReviewModel> get productReviews => _productReviews;
  bool get isFetchingMyProducts => _isFetchingMyProducts;
  String? get myProductsError => _myProductsError;
  List<Map<String, dynamic>> get myProducts => _myProducts;
  int get sellerProfileSelectedTabIndex => _sellerProfileSelectedTabIndex;
  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmNewPassword => _confirmNewPassword;
  String? get currentPasswordError => _currentPasswordError;
  String? get newPasswordError => _newPasswordError;
  String? get confirmNewPasswordError => _confirmNewPasswordError;
  String get currentUserFullName =>
      user?.firstName ?? 'Unknown ${user?.lastName ?? ''}';
  bool get isAdmin =>
      _userProvider.user?.role == Role.admin ||
      _userProvider.user?.role == Role.superAdmin;
  bool get isSuperAdmin => _userProvider.user?.role == Role.superAdmin;
  bool get isUser => _userProvider.user?.role == Role.user;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get admins => _admins;
  List<Map<String, dynamic>> get inactiveUsers => _inactiveUsers;
  List<Map<String, dynamic>> get adminProducts => _adminProducts;
  bool get isFetchingInactiveUsers => _isFetchingInactiveUsers;
  String? get inactiveUsersError => _inactiveUsersError;
  bool get isFetchingAdminProducts => _isFetchingAdminProducts;
  String? get adminProductsError => _adminProductsError;
  Product? get createdProduct => _createdProduct;
  Product? get productDetail => _productDetail;
  List<String> get uploadedImageUrls => _uploadedImageUrls;
  ProductData get currentProductData => _currentProductData;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phoneNumber => _phoneNumber;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get rememberMe => _rememberMe;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get phoneNumberError => _phoneNumberError;
  String? get genderError => _genderError;
  String? get apiError => _apiError;
  TextEditingController get adminFirstNameController =>
      _adminFirstNameController;
  TextEditingController get adminLastNameController => _adminLastNameController;
  TextEditingController get adminEmailController => _adminEmailController;
  TextEditingController get adminPhoneNumberController =>
      _adminPhoneNumberController;
  TextEditingController get adminPasswordController => _adminPasswordController;
  String? get adminFirstNameError => _adminFirstNameError;
  String? get adminLastNameError => _adminLastNameError;
  String? get adminEmailError => _adminEmailError;
  String? get adminPasswordError => _adminPasswordError;
  String? get adminPhoneNumberError => _adminPhoneNumberError;
  String? get adminGenderError => _adminGenderError;
  Gender? get adminSelectedGender => _adminSelectedGender;
  bool get isAdminPasswordVisible => _isAdminPasswordVisible;
  List<ReviewModel> get userRatings => _userRatings;
  bool get isFetchingUserRatings => _isFetchingUserRatings;
  String? get userRatingsError => _userRatingsError;

  @override
  void dispose() {
    // Dispose admin creation controllers
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneNumberController.dispose();
    _adminPasswordController.dispose();

    // Dispose existing general controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  void _initializeControllers() {
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // General field listeners
    _emailController.addListener(() => _debouncedUpdate(() {
          _email = _emailController.text;
          _validateEmail();
          notifyListeners();
        }));
    _passwordController.addListener(() => _debouncedUpdate(() {
          _password = _passwordController.text;
          _validatePassword();
          notifyListeners();
        }));
    _confirmPasswordController.addListener(() => _debouncedUpdate(() {
          _confirmPassword = _confirmPasswordController.text;
          _validateConfirmPassword();
          notifyListeners();
        }));
    _firstNameController.addListener(() => _debouncedUpdate(() {
          _firstName = _firstNameController.text;
          _validateFirstName();
          notifyListeners();
        }));
    _lastNameController.addListener(() => _debouncedUpdate(() {
          _lastName = _lastNameController.text;
          _validateLastName();
          notifyListeners();
        }));
    _phoneNumberController.addListener(() => _debouncedUpdate(() {
          _phoneNumber = _phoneNumberController.text;
          _validatePhoneNumber();
          notifyListeners();
        }));
    _currentPasswordController.addListener(() => _debouncedUpdate(() {
          _currentPassword = _currentPasswordController.text;
          _validateCurrentPassword();
          notifyListeners();
        }));
    _newPasswordController.addListener(() => _debouncedUpdate(() {
          _newPassword = _newPasswordController.text;
          _validateNewPassword();
          notifyListeners();
        }));
    _confirmNewPasswordController.addListener(() => _debouncedUpdate(() {
          _confirmNewPassword = _confirmNewPasswordController.text;
          _validateConfirmNewPassword();
          notifyListeners();
        }));

    // Admin creation field listeners
    _adminFirstNameController.addListener(() => _debouncedUpdate(() {
          _adminFirstName = _adminFirstNameController.text;
          _validateAdminFirstName();
          notifyListeners();
        }));
    _adminLastNameController.addListener(() => _debouncedUpdate(() {
          _adminLastName = _adminLastNameController.text;
          _validateAdminLastName();
          notifyListeners();
        }));
    _adminEmailController.addListener(() => _debouncedUpdate(() {
          _adminEmail = _adminEmailController.text;
          _validateAdminEmail();
          notifyListeners();
        }));
    _adminPasswordController.addListener(() => _debouncedUpdate(() {
          _adminPassword = _adminPasswordController.text;
          _validateAdminPassword();
          notifyListeners();
        }));
    _adminPhoneNumberController.addListener(() => _debouncedUpdate(() {
          _adminPhoneNumber = _adminPhoneNumberController.text;
          _validateAdminPhoneNumber();
          notifyListeners();
        }));
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(PreferencesKeys.isLoggedInKey) ?? false;
    final userData = prefs.getString(PreferencesKeys.userKey);
    final token = prefs.getString(PreferencesKeys.tokenKey);
    final profileImagePath =
        prefs.getString(PreferencesKeys.profileImagePathKey);

    if (isLoggedIn && userData != null && token != null) {
      final decodedData = jsonDecode(userData) as Map<String, dynamic>;
      _user = UserModel.fromJson({'user': decodedData});
      _token = token;
      if (_user != null && profileImagePath != null) {
        _user = _user!.copyWith(profilePhoto: profileImagePath);
      }
      _userProvider.setUser(_user!);
      notifyListeners();
    }
  }

  void _debouncedUpdate(VoidCallback callback) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), callback);
  }

  // General field setters
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

  void setFirstName(String value) {
    _firstName = value;
    _validateFirstName();
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    _validateLastName();
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    _validatePhoneNumber();
    notifyListeners();
  }

  void setCurrentPassword(String value) {
    _currentPassword = value;
    _validateCurrentPassword();
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value;
    _validateNewPassword();
    notifyListeners();
  }

  void setConfirmNewPassword(String value) {
    _confirmNewPassword = value;
    _validateConfirmNewPassword();
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

  // Admin field setters
  void setAdminFirstName(String value) {
    _adminFirstName = value;
    _validateAdminFirstName();
    notifyListeners();
  }

  void setAdminLastName(String value) {
    _adminLastName = value;
    _validateAdminLastName();
    notifyListeners();
  }

  void setAdminEmail(String value) {
    _adminEmail = value;
    _validateAdminEmail();
    notifyListeners();
  }

  void setAdminPassword(String value) {
    _adminPassword = value;
    _validateAdminPassword();
    notifyListeners();
  }

  void setAdminPhoneNumber(String value) {
    _adminPhoneNumber = value;
    _validateAdminPhoneNumber();
    notifyListeners();
  }

  void setAdminGender(Gender? gender) {
    _adminSelectedGender = gender;
    _validateAdminGender();
    notifyListeners();
  }

  void toggleAdminPasswordVisibility() {
    _isAdminPasswordVisible = !_isAdminPasswordVisible;
    notifyListeners();
  }

  // General validation methods
  void _validateEmail() {
    if (_email.isEmpty) {
      _emailError = 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_email)) {
      _emailError = 'Enter a valid email';
    } else {
      _emailError = null;
    }
  }

  void _validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Password is required';
    } else if (_password.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
    } else {
      _passwordError = null;
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm Password is required';
    } else if (_confirmPassword != _password) {
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _confirmPasswordError = null;
    }
  }

  void _validateFirstName() {
    if (_firstName.isEmpty) {
      _firstNameError = 'First Name is required';
    } else {
      _firstNameError = null;
    }
  }

  void _validateLastName() {
    if (_lastName.isEmpty) {
      _lastNameError = 'Last Name is required';
    } else {
      _lastNameError = null;
    }
  }

  void _validatePhoneNumber() {
    if (_phoneNumber.isEmpty) {
      _phoneNumberError = 'Phone Number is required';
    } else if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(_phoneNumber)) {
      _phoneNumberError = 'Enter a valid phone number';
    } else {
      _phoneNumberError = null;
    }
  }

  void _validateGender() {
    if (_selectedGender == null) {
      _genderError = 'Gender is required';
    } else {
      _genderError = null;
    }
  }

  void _validateCurrentPassword() {
    if (_currentPassword.isEmpty) {
      _currentPasswordError = 'Current password is required';
    } else {
      _currentPasswordError = null;
    }
  }

  void _validateNewPassword() {
    if (_newPassword.isEmpty) {
      _newPasswordError = 'New password is required';
    } else if (_newPassword.length < 8) {
      _newPasswordError = 'New password must be at least 8 characters';
    } else if (_newPassword == _currentPassword) {
      _newPasswordError =
          'New password cannot be the same as the current password';
    } else {
      _newPasswordError = null;
    }
  }

  void _validateConfirmNewPassword() {
    if (_confirmNewPassword.isEmpty) {
      _confirmNewPasswordError = 'Confirm new password is required';
    } else if (_confirmNewPassword != _newPassword) {
      _confirmNewPasswordError = 'New passwords do not match';
    } else {
      _confirmNewPasswordError = null;
    }
  }

  // Admin validation methods
  void _validateAdminFirstName() {
    if (_adminFirstName.isEmpty) {
      _adminFirstNameError = 'First Name is required';
    } else {
      _adminFirstNameError = null;
    }
  }

  void _validateAdminLastName() {
    if (_adminLastName.isEmpty) {
      _adminLastNameError = 'Last Name is required';
    } else {
      _adminLastNameError = null;
    }
  }

  void _validateAdminEmail() {
    if (_adminEmail.isEmpty) {
      _adminEmailError = 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_adminEmail)) {
      _adminEmailError = 'Enter a valid email';
    } else {
      _adminEmailError = null;
    }
  }

  void _validateAdminPassword() {
    if (_adminPassword.isEmpty) {
      _adminPasswordError = 'Password is required';
    } else if (_adminPassword.length < 8) {
      _adminPasswordError = 'Password must be at least 8 characters';
    } else {
      _adminPasswordError = null;
    }
  }

  void _validateAdminPhoneNumber() {
    if (_adminPhoneNumber.isEmpty) {
      _adminPhoneNumberError = 'Phone Number is required';
    } else if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(_adminPhoneNumber)) {
      _adminPhoneNumberError = 'Enter a valid phone number';
    } else {
      _adminPhoneNumberError = null;
    }
  }

  void _validateAdminGender() {
    if (_adminSelectedGender == null) {
      _adminGenderError = 'Gender is required';
    } else {
      _adminGenderError = null;
    }
  }

  bool _validateForm() {
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();
    _validateFirstName();
    _validateLastName();
    _validatePhoneNumber();
    _validateGender();

    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _firstNameError == null &&
        _lastNameError == null &&
        _phoneNumberError == null &&
        _genderError == null;
  }

  bool validateAdminCreationForm() {
    _validateAdminFirstName();
    _validateAdminLastName();
    _validateAdminEmail();
    _validateAdminPassword();
    _validateAdminPhoneNumber();
    _validateAdminGender();

    return _adminFirstNameError == null &&
        _adminLastNameError == null &&
        _adminEmailError == null &&
        _adminPasswordError == null &&
        _adminPhoneNumberError == null &&
        _adminGenderError == null;
  }

  bool _validatePasswordChangeForm() {
    _validateCurrentPassword();
    _validateNewPassword();
    _validateConfirmNewPassword();
    return _currentPasswordError == null &&
        _newPasswordError == null &&
        _confirmNewPasswordError == null;
  }

  // Methods
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void selectProfileTab(int index) {
    _profileSelectedTabIndex = index;
    notifyListeners();
  }

  void setGender(Gender? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void selectSellerProfileTab(int index) {
    _sellerProfileSelectedTabIndex = index;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
    setLoading(true);
    clearError();

    try {
      final response = await _apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      log("Login API response: $response"); // Debug: Log raw response

      // Check for error response directly in the API response
      if (response.containsKey('error')) {
        _apiError = response['error'] as String? ??
            "Login failed due to an unknown error.";
        setLoading(false);
        notifyListeners();
        return false;
      }

      // Parse user data safely
      try {
        final userData = response['user'] as Map<String, dynamic>;
        _user = UserModel.fromJson({'user': userData});
        _token = response['token'] as String;
      } catch (parseError) {
        log("Parsing error: $parseError");
        _apiError = "Failed to parse user data or token.";
        setLoading(false);
        notifyListeners();
        return false;
      }

      if (_user == null || _token == null) {
        _apiError = "Failed to parse user data or token.";
        setLoading(false);
        notifyListeners();
        return false;
      }

      _userProvider.setUser(_user!);
      _apiError = null;

      await _saveUserData();
      // show success snack message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${user?.firstName} ${user?.lastName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      log("User set successfully: ${_user?.email}, Role: ${_user?.role}, Token: $_token");
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      String errorMessage = 'In valid email or password';

      try {
        log('[Login] Raw exception: $e');

        if (e.toString().toLowerCase().contains('timeout')) {
          errorMessage = 'Connection timed out. Please try again.';
        } else if (e is http.ClientException) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          // Try to extract JSON error message from the exception string
          final match = RegExp(r'body: ({.*})').firstMatch(e.toString());
          if (match != null) {
            final jsonString = match.group(1);
            final json = jsonDecode(jsonString!) as Map<String, dynamic>;
            errorMessage = json['error'] as String? ??
                json['message'] as String? ??
                'An unexpected error occurred.';
          }
        }
      } catch (parseError) {
        log('[Login] Parsing error: $parseError');
        errorMessage = 'Unable to parse server response.';
      }

      _apiError = errorMessage;
      setLoading(false);
      notifyListeners();

      // Assuming this function is called from a widget with context
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      log('[Login] Error: $errorMessage', stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.logout();
      _userProvider.clearUser();
      _user = null;
      _token = null;
      _emailController.clear();
      _passwordController.clear();
      await _clearStoredData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Logout successful!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // This clears the stack
      );
    } catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to logout: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null && _token != null) {
      final userJson = _user!.toJson(nested: false);
      await prefs.setString(PreferencesKeys.userKey, jsonEncode(userJson));
      await prefs.setString(PreferencesKeys.tokenKey, _token!);
      await prefs.setBool(PreferencesKeys.isLoggedInKey, true);

      String? profileImagePath = _user!.profilePhoto;
      if (profileImagePath != null &&
          profileImagePath.startsWith(ApiService.baseUrl)) {
        profileImagePath =
            profileImagePath.replaceFirst(ApiService.baseUrl, '');
      }
      await prefs.setString(
          PreferencesKeys.profileImagePathKey, profileImagePath ?? '');
    }
  }

  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferencesKeys.userKey);
    await prefs.remove(PreferencesKeys.tokenKey);
    await prefs.remove(PreferencesKeys.isLoggedInKey);
    await prefs.remove(PreferencesKeys.profileImagePathKey);
  }

  void clearErrors() {
    _apiError = null;
    notifyListeners();
  }

  Future<bool> register(BuildContext context) async {
    setLoading(true);
    clearError();

    try {
      if (!_validateForm()) {
        setLoading(false);
        return false;
      }

      final response = await _apiService.register(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        password: _password,
        phoneNumber: _phoneNumber,
        gender: _selectedGender.toString().split('.').last,
      );

      if (response.containsKey('message') &&
          response['message'] == 'User registered successfully') {
        _userProvider.setUser(UserModel.fromJson(response));
        _apiError = null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Welcome ${_userProvider.user!.firstName} ${_userProvider.user!.lastName}, you have successfully registered!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        setLoading(false);
        return true;
      } else if (response.containsKey('error') &&
          response['error'].toString().contains('already registered')) {
        _apiError = response['error'] as String?;
        setErrorMessage('You have already registered');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already registered'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        setLoading(false);
        return false;
      } else {
        throw Exception('Unexpected response: $response');
      }
    } catch (e) {
      _apiError = e.toString();
      setErrorMessage(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> forgotPassword(
      {Duration delay = const Duration(milliseconds: 500)}) async {
    setLoading(true);
    clearError();

    try {
      _validateEmail();
      if (_emailError != null) {
        setLoading(false);
        return false;
      }

      final response = await _apiService.forgotPassword(email: _email);
      _apiError = null;
      setLoading(false);
      return true;
    } catch (e) {
      _apiError = e.toString();
      setErrorMessage(e.toString());
      setLoading(false);
      return false;
    }
  }
  // For http.Response, if used by ApiService
// Ensure other necessary imports are included (e.g., logging, context)
// For http.Response, if used by ApiService
// Ensure other necessary imports are included (e.g., logging, context)

  Future<bool> changePassword(BuildContext context) async {
    setLoading(true);
    clearError();

    try {
      if (!_validatePasswordChangeForm()) {
        setLoading(false);
        return false;
      }

      final response = await _apiService.changePassword(
        currentPassword: _currentPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmNewPassword,
      );

      print('[ChangePassword] API response received: ${response.toString()}');
      _apiError = null;
      setLoading(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] as String? ??
                'Password updated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      String errorMessage = 'Current password is incorrect';

      try {
        log('[ChangePassword] Raw exception: $e');

        if (e.toString().toLowerCase().contains('timeout')) {
          errorMessage = 'Connection timed out. Please try again.';
        } else if (e is http.ClientException) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          // Try to extract JSON error message from the exception string
          final match = RegExp(r'body: ({.*})').firstMatch(e.toString());
          if (match != null) {
            final jsonString = match.group(1);
            final json = jsonDecode(jsonString!) as Map<String, dynamic>;
            errorMessage = json['error'] as String? ??
                json['message'] as String? ??
                'An unexpected error occurred.';
          }
        }
      } catch (parseError) {
        errorMessage = 'Unable to parse server response.';
      }

      setErrorMessage(errorMessage);
      setLoading(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  Future<bool> changePasswordAdmin(BuildContext context) async {
    setLoading(true);
    clearError();

    try {
      if (!_validatePasswordChangeForm()) {
        log('[ChangePassword] Form validation failed');
        setLoading(false);
        return false;
      }

      final response = await _apiService.changePasswordAdmin(
        currentPassword: _currentPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmNewPassword,
      );

      _apiError = null;
      setLoading(false);
      print(Text(
          response['message'] as String? ?? 'Password updated successfully!'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] as String? ??
                'Password updated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      _apiError = e.toString();
      setErrorMessage(e.toString());
      setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> updateProfile(
    BuildContext context, {
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    Gender? gender,
    XFile? profileImage,
  }) async {
    setLoading(true);
    clearError();
    debugPrint('[updateProfile] Starting profile update...');

    try {
      // Input validation
      if (firstName != null && firstName.isEmpty) {
        throw Exception('First name cannot be empty');
      }
      if (lastName != null && lastName.isEmpty) {
        throw Exception('Last name cannot be empty');
      }
      if (email != null &&
          (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email))) {
        throw Exception('Invalid email');
      }
      if (phoneNumber != null &&
          (phoneNumber.isEmpty ||
              !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phoneNumber))) {
        throw Exception('Invalid phone number');
      }

      // Prepare multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiService.baseUrl}/api/users/profile'),
      );

      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }
      debugPrint('[updateProfile] Using token: $token');
      request.headers['Authorization'] = 'Bearer $token';

      if (firstName != null) {
        request.fields['firstName'] = firstName;
        debugPrint('[updateProfile] Adding firstName: $firstName');
      }
      if (lastName != null) {
        request.fields['lastName'] = lastName;
        debugPrint('[updateProfile] Adding lastName: $lastName');
      }
      if (email != null) {
        request.fields['email'] = email;
        debugPrint('[updateProfile] Adding email: $email');
      }
      if (phoneNumber != null) {
        request.fields['phoneNumber'] = phoneNumber;
        debugPrint('[updateProfile] Adding phoneNumber: $phoneNumber');
      }
      if (gender != null) {
        request.fields['gender'] = gender.toString().split('.').last;
        debugPrint('[updateProfile] Adding gender: ${gender.toString()}');
      }

      if (profileImage != null) {
        String? mimeType = lookupMimeType(profileImage.path);
        if (mimeType == null || !mimeType.startsWith('image/')) {
          throw Exception(
              'Selected file is not a valid image. Please select a JPG, PNG, or JPEG file.');
        }

        final allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
        if (!allowedTypes.contains(mimeType)) {
          throw Exception('Only JPG, JPEG, and PNG files are allowed.');
        }

        String extension = mimeType.split('/').last;
        if (extension == 'jpeg') extension = 'jpg';

        String filename =
            'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';
        debugPrint(
            '[updateProfile] Adding profile image from path: ${profileImage.path}, MIME type: $mimeType, Filename: $filename');

        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePhoto',
            profileImage.path,
            contentType: MediaType.parse(mimeType),
            filename: filename,
          ),
        );
      }

      debugPrint('[updateProfile] Sending request...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      debugPrint('[updateProfile] Response status: ${response.statusCode}');
      debugPrint('[updateProfile] Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.headers['content-type']?.contains('application/json') !=
            true) {
          throw Exception('Server returned non-JSON response');
        }

        final userJson = jsonDecode(responseBody);
        if (userJson is! Map<String, dynamic>) {
          throw Exception('Server returned unexpected data format');
        }

        final updatedUser = UserModel.fromJson({
          'user': {
            'id': userJson['_id'],
            'firstName': userJson['firstName'],
            'lastName': userJson['lastName'],
            'email': userJson['email'],
            'phoneNumber': userJson['phoneNumber'],
            'gender': userJson['gender'],
            'profilePhoto': userJson['profilePhoto'],
            'createdAt': userJson['createdAt'],
          }
        });

        // Update the user in memory and UserProvider
        _user = updatedUser;
        _userProvider.setUser(updatedUser); // Ensure UserProvider is updated

        // Save to SharedPreferences
        await _saveUserData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } else {
        String errorMessage;
        if (response.statusCode == 404) {
          errorMessage =
              'Profile update endpoint not found. Please contact support.';
        } else if (response.statusCode == 401) {
          errorMessage = 'Unauthorized. Please log in again.';
        } else if (response.statusCode == 400) {
          errorMessage = jsonDecode(responseBody)['message'] as String? ??
              'Invalid data provided';
        } else {
          errorMessage =
              'Failed with status ${response.statusCode}: $responseBody';
        }
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('[updateProfile] Error: $e');
      debugPrint(stackTrace.toString());
      setErrorMessage(e.toString());

      if (context.mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        if (errorMessage.contains('not a valid image')) {
          errorMessage =
              'Please select a valid image file (JPG, PNG, or JPEG).';
        } else if (errorMessage.contains('Only JPG, JPEG, and PNG')) {
          // Message already user-friendly
        } else if (errorMessage.contains('Unauthorized')) {
          errorMessage = 'Session expired. Please log in again.';
        } else {
          errorMessage = 'Failed to update profile. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> fetchMyProducts() async {
    _isFetchingMyProducts = true;
    _myProductsError = null;
    notifyListeners();

    try {
      final products = await _apiService.getMyProducts();
      _myProducts = products;
      _isFetchingMyProducts = false;
      notifyListeners();
      return true;
    } catch (e) {
      _myProductsError = e.toString();
      _isFetchingMyProducts = false;
      notifyListeners();
      return false;
    }
  }

  // preoduct review wlist

  Future<bool> listProductReviews() async {
    try {
      _isFetchingReviews = true;
      _reviewsError = null;
      notifyListeners();

      final reviews = await _apiService.getProductReviews();
      _productReviews = reviews;

      _isFetchingReviews = false;
      notifyListeners();
      return true;
    } catch (e) {
      _reviewsError = e.toString();
      _isFetchingReviews = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Fetching all products to filter by category: $category');
      if (category == 'New Release') {
        final List<Map<String, dynamic>> newReleaseProducts =
            await _apiService.fetchProductsByCategory(category);

        _newReleaseProducts =
            newReleaseProducts.map((json) => Product.fromJson(json)).toList();
      }
      // Fetch all products once
      else {
        final List<Map<String, dynamic>> allProducts =
            await _apiService.fetchAllProducts();
        print('Raw API response: $allProducts');

        // Map the response to Product objects
        List<Product> productList =
            allProducts.map((json) => Product.fromJson(json)).toList();

        // Filter products by category if not 'All'
        if (category == 'All') {
          _currentProducts = productList;
        } else {
          productList = productList
              .where((product) =>
                  product.category.toLowerCase() == category.toLowerCase())
              .toList();
          _currentProducts = productList;
        }
      }
      print(
          'Total products after filtering for category "$category": ${_currentProducts.length}');
    } catch (e) {
      print('Error fetching products: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProductDetail(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Fetching product detail for product id: $productId');

      final allFetchedProducts = await _apiService.fetchAllProducts();
      _productDetail =
          allFetchedProducts.map((json) => Product.fromJson(json)).firstWhere(
                (product) => product.id == productId,
                // Return null if no match is found
              );

      if (_productDetail == null) {
        _errorMessage = 'Product not found';
      } else {
        print('Fetched product detail: $_productDetail');
      }
    } catch (e) {
      print('Error fetching product detail: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add these fields to the class fields section

// Add this method to the methods section
  Future<bool> fetchUserRatings() async {
    _isFetchingUserRatings = true;
    _userRatingsError = null;
    notifyListeners();

    try {
      if (_user == null) {
        throw Exception(
            'User not logged in. Please log in to view your ratings.');
      }

      final ratings = await _apiService.getUserRatings();
      _userRatings = ratings;
      _isFetchingUserRatings = false;
      notifyListeners();
      return true;
    } catch (e) {
      _userRatingsError = e.toString();
      _isFetchingUserRatings = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> addRating({
    required String productId,
    required double score,
    required String comment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (user == null) {
        throw Exception('User not logged in or user data unavailable');
      }

      final userId = user!.id;
      if (userId == null) {
        throw Exception('User ID not found in user data');
      }

      final response = await _apiService.addRating(
        productId: productId,
        userId: userId,
        score: score,
        comment: comment,
      );

      if (!response.containsKey('rating') ||
          !response.containsKey('productStats')) {
        throw Exception(
            'Invalid response format: missing rating or productStats');
      }

      final rating =
          Rating.fromJson(response['rating'] as Map<String, dynamic>);
      final productStats = ProductStats.fromJson(
          response['productStats'] as Map<String, dynamic>);

      if (_productDetail?.id == productId) {
        bool previousIsActive = _productDetail!.isActive;
        bool newIsActive = productStats.averageRating >= 5.0
            ? false
            : _productDetail!.isActive;

        _productDetail = Product(
          id: _productDetail!.id,
          title: _productDetail!.title,
          description: _productDetail!.description,
          category: _productDetail!.category,
          price: _productDetail!.price,
          images: _productDetail!.images,
          contactInfo: _productDetail!.contactInfo,
          userId: _productDetail!.userId,
          averageRating: productStats.averageRating,
          ratingCount: productStats.ratingCount,
          isActive: newIsActive,
          createdAt: _productDetail!.createdAt,
          updatedAt: _productDetail!.updatedAt,
          ratings: [..._productDetail!.ratings, rating],
        );
      }
    } catch (e) {
      debugPrint('Error adding rating: $e');
      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('User not logged in')) {
        throw Exception('Please log in to rate this product.');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAdmin(BuildContext context) async {
    final firstName = adminFirstNameController.text.trim();
    final lastName = adminLastNameController.text.trim();
    final email = adminEmailController.text.trim();
    final password = adminPasswordController.text.trim();
    final phoneNumber = adminPhoneNumberController.text.trim();
    final gender = adminSelectedGender?.name ?? '';

    print('Request body: ${jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "phoneNumber": phoneNumber,
          "gender": gender
        })}');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phoneNumber.isEmpty ||
        gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.createAdmin(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          gender: gender);

      adminFirstNameController.clear();
      adminLastNameController.clear();
      adminEmailController.clear();
      adminPhoneNumberController.clear();
      adminPasswordController.clear();
      _adminSelectedGender = null;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] as String? ??
                'Admin created successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Refresh admin list
      await fetchDashboard();
    } catch (e) {
      print('Create admin error: $e');
      String errorMessage = 'Failed to create admin. Please try again.';
      if (e.toString().contains('Email already exists')) {
        errorMessage = 'An admin with this email already exists.';
      } else if (e.toString().contains('Insufficient permissions')) {
        errorMessage = 'Only super admins can create admins.';
      } else if (e.toString().contains('Server error')) {
        errorMessage =
            'Server error occurred. Please try again or contact support.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAdmin(String adminId, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteAdmin(adminId);
      await fetchDashboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin deleted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete admin: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    /*
    *  "totalUsers": 18,
        "totalAdmins": 1,
        "activeUsers": 17,
        "inactiveUsers": 1
    * */

    try {
      final response = await _apiService.fetchDashboard();
      await fetchAllAdminProducts();
      _dashboardStats = {
        'adminCount': response['stats']['totalAdmins'] as int? ?? 0,
        'productCount': adminProducts
            .length, // This isn't in the provided JSON, assuming it's fetched elsewhere
        'inactiveUsersCount': response['stats']['inactiveUsers'] as int? ??
            0, // Map inactive users count
        // Preserve existing notifications
      };
      print(' Dashboard data:  $_dashboardStats');
      _admins = (response['admins'] as List<dynamic>).map((admin) {
        final userInfo = admin['userInfo'] as Map<String, dynamic>;
        return {
          'id': userInfo['_id'] as String? ?? '',
          'firstName': userInfo['firstName'] as String? ?? '',
          'lastName': userInfo['lastName'] as String? ?? '',
          'email': userInfo['email'] as String? ?? '',
          'role': userInfo['role'] as String? ?? 'admin',
          'isActive': userInfo['isActive'] as bool? ?? false,
          'createdAt': userInfo['createdAt'] as String? ?? '',
          'createdBy': (admin['createdBy'] as Map<String, dynamic>?)
                  ?.cast<String, dynamic>() ??
              {},
        };
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInactiveUsers() async {
    _isFetchingInactiveUsers = true;
    _inactiveUsersError = null;
    notifyListeners();

    try {
      _inactiveUsers = await _apiService.fetchInactiveUsers();
      _isFetchingInactiveUsers = false;
      notifyListeners();
    } catch (e) {
      _inactiveUsersError = e.toString();
      _isFetchingInactiveUsers = false;
      notifyListeners();
    }
  }

  Future<void> activateUser(String userId, BuildContext context) async {
    _isLoading = true;
    _inactiveUsersError = null;
    notifyListeners();

    try {
      final response = await _apiService.activateUser(userId);
      // Log the response to verify the success message
      debugPrint('[ActivateUser] Success response: ${response.toString()}');
      // Show the SnackBar before any UI-changing operations
      if (context.mounted) {
        debugPrint(
            '[ActivateUser] Context mounted for success SnackBar: ${context.mounted}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] as String? ??
                'User activated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // Perform UI-changing operations after showing the SnackBar
      await fetchInactiveUsers(); // Refresh the inactive users list
      if (user?.role == Role.superAdmin) {
        await fetchDashboard();
      }
    } catch (e, stackTrace) {
      String errorMessage = 'An unexpected error occurred.';

      try {
        debugPrint('[ActivateUser] Raw exception: $e');

        if (e.toString().toLowerCase().contains('timeout')) {
          errorMessage = 'Connection timed out. Please try again.';
        } else if (e is http.ClientException) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          // Try to extract JSON error message from the exception string
          final match = RegExp(r'body: ({.*})').firstMatch(e.toString());
          if (match != null) {
            final jsonString = match.group(1);
            final json = jsonDecode(jsonString!) as Map<String, dynamic>;
            errorMessage = json['error'] as String? ??
                json['message'] as String? ??
                'An unexpected error occurred.';
          }
        }
      } catch (parseError) {
        debugPrint('[ActivateUser] Parsing error: $parseError');
        errorMessage = 'Unable to parse server response.';
      }

      _inactiveUsersError = errorMessage;
      if (context.mounted) {
        debugPrint(
            '[ActivateUser] Context mounted for error SnackBar: ${context.mounted}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('[ActivateUser] Error: $errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increaseUserWarningSuperAdmin(
      String userId, BuildContext context) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.increaseUserWarning(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User warning incremented to ${response['warnings']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Check if warnings exceed a threshold (e.g., 5) to deactivate user
      if ((response['warnings'] as int?) != null &&
          response['warnings'] as int >= 5) {
        // Note: The API does not automatically deactivate; this is a manual check
        await _deactivateUserIfThresholdExceeded(userId, context);
        await fetchDashboard();
      }
    } catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to increase warning: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> increaseUserWarningAdmin(
      String userId, BuildContext context) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.increaseUserWarning(userId);
      await fetchInactiveUsers(); // Refresh inactive users list to reflect new status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User warning incremented to ${response['warnings']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Check if warnings exceed a threshold (e.g., 5) to deactivate user
      if ((response['warnings'] as int?) != null &&
          response['warnings'] as int >= 5) {
        // Note: The API does not automatically deactivate; this is a manual check
        await _deactivateUserIfThresholdExceeded(userId, context);
        await fetchAllAdminProducts();
      }
    } catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to increase warning: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      notifyListeners();
    }
  }

  // Helper method to deactivate user if warnings threshold is exceeded
  Future<void> _deactivateUserIfThresholdExceeded(
      String userId, BuildContext context) async {
    try {
      // Assume a PUT or PATCH endpoint to deactivate user (not provided, so placeholder)
      final response = await http.put(
        Uri.parse(
            '${ApiService.baseUrl}/api/admin/users/$userId/deactivate'), // Hypothetical endpoint
        headers: {
          'Authorization': 'Bearer ${await _apiService.getToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await fetchInactiveUsers(); // Refresh list
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deactivated due to excessive warnings!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to deactivate user: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> fetchAllAdminProducts() async {
    _isFetchingAdminProducts = true;
    _adminProductsError = null;
    notifyListeners();

    try {
      _adminProducts = await _apiService.fetchAllAdminProducts();
      await _checkAndUpdateProductStatuses();
      _isFetchingAdminProducts = false;
      notifyListeners();
    } catch (e) {
      _adminProductsError = e.toString();
      _isFetchingAdminProducts = false;
      notifyListeners();
    }
  }

  //
  Future<void> _checkAndUpdateProductStatuses() async {
    for (var product in _adminProducts) {
      final productId =
          product['id'] as String? ?? product['_id'] as String? ?? '';
      final averageRating =
          (product['averageRating'] as num?)?.toDouble() ?? 0.0;
      final currentIsActive = product['isActive'] as bool? ?? true;

      if (averageRating >= 5.0 && currentIsActive) {
        product['isActive'] = false;
        await _apiService.updateProductStatus(productId, false);
        notifyAdminOfStatusChange(
            productId, product['title'] as String? ?? 'Unknown Product', false);
      }
    }
  }

  void notifyAdminOfStatusChange(
      String productId, String productName, bool isActive) {
    _dashboardStats['notifications'] = _dashboardStats['notifications'] ?? [];
    (_dashboardStats['notifications'] as List).add({
      'productId': productId,
      'productName': productName,
      'isActive': isActive,
      'message':
          'Product $productName status changed to ${isActive ? "Active" : "Inactive"}',
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  Future<void> showNotifications(BuildContext context) async {
    final notifications =
        _dashboardStats['notifications'] as List<dynamic>? ?? [];
    if (notifications.isEmpty) return;

    for (var notification in notifications) {
      await Future.delayed(const Duration(
          milliseconds: 100)); // Small delay for smooth transition
      if (context.mounted) {
        await Future.delayed(
          const Duration(seconds: 3), // Match the SnackBar duration
          () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      notification['message'] as String? ?? 'Status update'),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        );
      }
    }
    // Clear notifications after displaying
    _dashboardStats['notifications'] = [];
    notifyListeners();
  }

  Future<void> deleteProduct(String productId, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.deleteProduct(productId);
      await fetchAllAdminProducts();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] as String? ??
                'Product deleted successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      String errorMessage = 'An unexpected error occurred.';

      try {
        log('[DeleteProduct] Raw exception: $e');

        if (e.toString().toLowerCase().contains('timeout')) {
          errorMessage = 'Connection timed out. Please try again.';
        } else if (e is http.ClientException) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          // Try to extract JSON error message from the exception string
          final match = RegExp(r'body: ({.*})').firstMatch(e.toString());
          if (match != null) {
            final jsonString = match.group(1);
            final json = jsonDecode(jsonString!) as Map<String, dynamic>;
            errorMessage = json['error'] as String? ??
                json['message'] as String? ??
                'An unexpected error occurred.';
          }
        }
      } catch (parseError) {
        log('[DeleteProduct] Parsing error: $parseError');
        errorMessage = 'Unable to parse server response.';
      }

      _errorMessage = errorMessage;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      log('[DeleteProduct] Error: $errorMessage', stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProductData(ProductData newData) {
    _currentProductData = ProductData()..copyFrom(newData);
    notifyListeners();
  }

  Future<bool> submitProduct(
      ProductData productData, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    _uploadedImageUrls = [];
    notifyListeners();

    try {
      if (_userProvider.user == null) {
        throw Exception(
            'User not logged in. Please log in to submit a product.');
      }
      if (_userProvider.user!.gender.name != 'female') {
        throw Exception('Only females can sell in this marketplace.');
      }

      if (productData.productName == null || productData.productName!.isEmpty) {
        throw Exception('Product name is required.');
      }
      if (productData.category == null || productData.category!.isEmpty) {
        throw Exception('Category is required.');
      }
      if (productData.price == null || productData.price!.isEmpty) {
        throw Exception('Price is required.');
      }

      List<XFile> allImages = [];
      if (productData.previewImage != null) {
        allImages.add(productData.previewImage!);
      }
      allImages.addAll(productData.images);

      final response = await _apiService.createProduct(
        title: productData.productName!,
        description: productData.description ?? '',
        category: productData.category!,
        price: productData.price!,
        images: allImages,
        userId: _userProvider.user!.id ?? '6808a4eac67f050f67bb72cb',
      );

      if (response['images'] != null) {
        _uploadedImageUrls = (response['images'] as List)
            .map((item) => item.toString())
            .toList();
        productData.updateProduct(imageUrls: _uploadedImageUrls);
      }
      await fetchProductsByCategory('All');
      await fetchProductsByCategory('New Release');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(imageUrls: _uploadedImageUrls),
        ),
      );

      productData.clear();
      _currentProductData.clear();

      return true;
    } catch (e) {
      String errorMsg = 'Failed to submit product: $e';

      try {
        final errorResponse = jsonDecode(e.toString().contains(' - ')
            ? e.toString().split(' - ').last
            : e.toString());

        if (errorResponse is Map<String, dynamic> &&
            errorResponse.containsKey('message')) {
          errorMsg = errorResponse['message'] as String;
        }
      } catch (parseError) {
        log('Failed to parse error response: $parseError');
      }

      _errorMessage = errorMsg;


      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
