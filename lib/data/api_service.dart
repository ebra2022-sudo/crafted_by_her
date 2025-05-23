import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

import '../domain/models/review.dart';
import 'prefference_keys.dart';

class ApiService {
  static const String baseUrl = 'https://crafted-by-her-backend.onrender.com';
  static const String authEndpoint = '$baseUrl/api/auth';
  static const String productEndpoint = '$baseUrl/api/products';
  static const String adminEndpoint = '$baseUrl/api/admin';
  static const String ratingsEndpoint = '$baseUrl/api/ratings';
  static const String profileEndpoint = '$baseUrl/api/users';

  Future<Map<String, dynamic>> createAdmin(
      {required String firstName,
      required String lastName,
      required String email,
      required String phoneNumber,
      required String password,
      required String gender}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not authenticated. Please log in.');
      }
      print('Creating admin with token: $token');
      print('Request body: ${jsonEncode({
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password,
            "phoneNumber": phoneNumber,
            "gender": gender
          })}');

      // sample response of the current value

      final response = await http.post(
        Uri.parse('$adminEndpoint/create-admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "phoneNumber": phoneNumber,
          "gender": gender
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        String errorMessage = errorBody?['error'] as String? ?? 'Unknown error';
        if (response.statusCode == 400 &&
            errorMessage.contains('already exists')) {
          throw Exception('Admin creation failed: Email already exists.');
        } else if (response.statusCode == 403) {
          throw Exception(
              'Admin creation failed: Insufficient permissions. Only super admins can create admins.');
        } else if (response.statusCode == 500) {
          throw Exception(
              'Admin creation failed: Server error - $errorMessage. Please try again or contact support.');
        }
        throw Exception(
            'Failed to create admin: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('Create admin error: $e');
      throw Exception('Create admin error: $e');
    }
  }

  Future<Map<String, dynamic>> updateAdmin({
    required String adminId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? gender,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final Map<String, dynamic> body = {};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (email != null) body['email'] = email;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (gender != null) body['gender'] = gender;

    final response = await http.put(
      Uri.parse('$adminEndpoint/update-admin/$adminId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to update admin: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    final token = await getToken() ?? '';
    final response = await http.delete(
      Uri.parse('$adminEndpoint/delete-admin/$adminId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete admin: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.delete(
      Uri.parse('$adminEndpoint/products/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to delete product: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllAdminProducts() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$adminEndpoint/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return (responseData['products'] as List<dynamic>)
          .map((product) => product as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception(
          'Failed to fetch products: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchInactiveUsers() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$adminEndpoint/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return (responseData['users'] as List<dynamic>)
          .map((user) => user as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception(
          'Failed to fetch inactive users: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. User not logged in.');
    }

    final uri = Uri.parse('$baseUrl/api/users/password');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print("Response body: ${response.body}");
      throw Exception(
        'Failed to change password: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> changePasswordAdmin({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await getToken();
    debugPrint('thi code is is executed from api service');

    if (token == null) {
      throw Exception('Token not found. User not logged in.');
    }

    final uri = Uri.parse('$baseUrl/api/admin/change-password');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print("Response body: ${response.body}");
      throw Exception(
        'Failed to change password: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getMyProducts() async {
    final token = await getToken();
    final userId = await _getLoggedInUserId();

    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final uri = Uri.parse('$profileEndpoint/my-products');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      if (decodedData is List) {
        return decodedData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Unexpected response format for user products.');
      }
    } else {
      throw Exception(
        'Failed to get user products: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<String?> _getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(PreferencesKeys.userKey);
    if (userJson != null) {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return userData['id'] as String?;
    }
    return null;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? gender,
    XFile? profileImage,
  }) async {
    final token = await _ensureToken();
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$profileEndpoint/profile'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    try {
      if (firstName?.isEmpty ?? false) {
        throw Exception('First name cannot be empty');
      }
      if (lastName?.isEmpty ?? false) {
        throw Exception('Last name cannot be empty');
      }
      if (email != null &&
          (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email) || email.isEmpty)) {
        throw Exception('Invalid email');
      }
      if (phoneNumber != null &&
          (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phoneNumber) ||
              phoneNumber.isEmpty)) {
        throw Exception('Invalid phone number');
      }

      if (firstName != null) request.fields['firstName'] = firstName;
      if (lastName != null) request.fields['lastName'] = lastName;
      if (email != null) request.fields['email'] = email;
      if (phoneNumber != null) request.fields['phoneNumber'] = phoneNumber;
      if (gender != null) request.fields['gender'] = gender;

      if (profileImage != null) {
        final file = File(profileImage.path);
        if (!await file.exists()) {
          throw Exception('Profile image file does not exist');
        }
        final bytes = await file.readAsBytes();
        var mimeType = lookupMimeType(profileImage.path, headerBytes: bytes) ??
            'image/jpeg';
        if (!mimeType.startsWith('image/')) {
          throw Exception('Selected file is not an image');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(responseBody)['message'] ??
            'Failed with status ${response.statusCode}';
        throw Exception('Failed to update profile: $error');
      }
    } catch (e) {
      throw Exception('Profile update error: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authEndpoint/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'gender': gender,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to register: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    debugPrint("In login api");
    final uri = Uri.parse('$authEndpoint/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PreferencesKeys.tokenKey, token as String);
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferencesKeys.tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(PreferencesKeys.userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferencesKeys.isLoggedInKey) ?? false;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$authEndpoint/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to send reset email: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Forgot password error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    try {
      List<Map<String, dynamic>> allProducts = [];
      int page = 1;
      const int limit = 10;
      bool hasMore = true;

      print('Fetching all products...');

      while (hasMore) {
        final uri =
            Uri.parse('$productEndpoint?category=All&page=$page&limit=$limit');
        print('Fetching page $page at: $uri');
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer ${await getToken() ?? ''}', // Add authentication if required
          },
        ).timeout(const Duration(seconds: 30));

        print('Page $page - Status: ${response.statusCode}');
        print('Page $page - Response: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic decodedData = jsonDecode(response.body);

          if (decodedData is Map<String, dynamic> &&
              decodedData['success'] == true) {
            final List<dynamic> productsData =
                decodedData['data'] as List<dynamic>;
            final List<Map<String, dynamic>> products = productsData
                .map((item) => item as Map<String, dynamic>)
                .toList();

            allProducts.addAll(products);
            print(
                'Page $page - Fetched ${products.length} products (Total: ${allProducts.length})');

            // Use pagination metadata to determine if there are more pages
            final total = decodedData['total'] as int? ?? 0;
            hasMore = (page * limit) < total;
            page++;
          } else {
            throw Exception(
                'Invalid response format or request failed: ${response.body}');
          }
        } else {
          throw Exception(
              'Failed to fetch products: ${response.statusCode} - ${response.body}');
        }
      }

      print('Total products fetched: ${allProducts.length}');
      return allProducts;
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error: Unable to connect to the server. $e');
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      throw Exception(
          'Request timed out. Please check your internet connection. $e');
    } catch (e) {
      print('Fetch products error: $e');
      throw Exception('Fetch products error: $e');
    }
  }

  Future<Map<String, dynamic>> increaseUserWarning(String userId) async {
    try {
      final response = await http.patch(
        Uri.parse('$adminEndpoint/users/$userId/warnings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken() ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to increase warning: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Increase warning error: $e');
    }
  }

  Future<Map<String, dynamic>> addRating({
    required String productId,
    required String userId,
    required double score,
    required String comment,
  }) async {
    final uri = Uri.parse(
        '${ApiService.ratingsEndpoint}/add'); // https://hall-server-screens-drill.trycloudflare.com/api/ratings/add

    final token = await ApiService().getToken();
    if (token == null) {
      debugPrint('[addRating] No token available');
      throw Exception('Unauthorized: No token available');
    }

    debugPrint(
        '[addRating] Sending request to $uri with productId: $productId, userId: $userId, score: $score, comment: $comment');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
        'userId': userId,
        'score': score,
        'comment': comment,
      }),
    );

    debugPrint(
        '[addRating] Response status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('[addRating] Parsed response: $responseBody');
        return responseBody;
      } catch (e) {
        debugPrint('[addRating] Failed to parse response: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else {
      String errorMessage = 'Failed to add rating: ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body.containsKey('message')) {
          errorMessage = body['message'] as String;
          debugPrint('[addRating] API error message: $errorMessage');
        } else {
          debugPrint('[addRating] Unparsed error body: ${response.body}');
          errorMessage = 'Failed to add rating: ${response.body}';
        }
      } catch (e) {
        debugPrint('[addRating] Failed to parse error body: $e');
        errorMessage = 'Failed to add rating: ${response.body}';
      }
      if (response.statusCode == 401) {
        errorMessage = 'Unauthorized: Invalid or missing token';
      } else if (response.statusCode == 400 &&
          errorMessage.contains('User has already rated this product')) {
        errorMessage = 'User has already rated this product';
      } else if (response.statusCode == 404) {
        errorMessage = 'Product or user not found';
      }
      throw Exception(errorMessage);
    }
  }

  Future<String> _ensureToken() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in. Token is missing.');
    }
    return token;
  }

  Future<Map<String, dynamic>> createProduct({
    required String title,
    required String description,
    required String category,
    required String price,
    required List<XFile> images,
    required String userId,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiService.productEndpoint),
    );

    try {
      request.headers['Authorization'] = await _ensureToken();
      request.headers['Authorization'] = await getToken() ?? '';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['price'] = price;
      request.fields['userId'] = userId;

      print(
          'Submitting product: title=$title, category=$category, price=$price, userId=$userId');
      print('Uploading ${images.length} images:');
      for (var image in images) {
        final file = File(image.path);
        if (!await file.exists()) {
          throw Exception('Image file does not exist: ${image.path}');
        }
        final bytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage == null) {
          throw Exception(
              'Invalid image file: ${image.path} is not a valid image');
        }
        var mimeType = lookupMimeType(image.path, headerBytes: bytes);
        if (mimeType == null) {
          final extension = image.path.split('.').last.toLowerCase();
          switch (extension) {
            case 'png':
              mimeType = 'image/png';
              break;
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
            default:
              mimeType = 'application/octet-stream';
          }
        }
        if (!mimeType.startsWith('image/')) {
          throw Exception(
              'File is not an image: ${image.path}, MIME: $mimeType');
        }
        print(
            ' - ${image.path} (${(await file.length()) ~/ 1024} KB), MIME: $mimeType');
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            image.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('API Response: ${response.statusCode} - $responseBody');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to updateProfile product: ${response.reasonPhrase} - $responseBody');
      }
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected API response format: $responseBody');
      }
      return decoded;
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else if (e is FileSystemException) {
        throw Exception('File access error: $e');
      }
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByCategory(
      String category) async {
    try {
      List<Map<String, dynamic>> allProducts = [];
      int page = 1;
      const int limit = 10;
      bool hasMore = true;

      print('Fetching products for category: $category');

      while (hasMore) {
        final uri = Uri.parse(
            '$productEndpoint?category=$category&page=$page&limit=$limit');
        print('Fetching page $page at: $uri');
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer ${await getToken() ?? ''}', // Add authentication if required
          },
        ).timeout(const Duration(seconds: 30));

        print('Page $page - Status: ${response.statusCode}');
        print('Page $page - Response: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic decodedData = jsonDecode(response.body);

          if (decodedData is Map<String, dynamic> &&
              decodedData['success'] == true) {
            final List<dynamic> productsData =
                decodedData['data'] as List<dynamic>;
            final List<Map<String, dynamic>> products = productsData
                .map((item) => item as Map<String, dynamic>)
                .toList();

            allProducts.addAll(products);
            print(
                'Page $page - Fetched ${products.length} products (Total: ${allProducts.length})');

            // Determine if there are more pages
            final count = decodedData['count'] as int? ?? 0;
            hasMore = (page * limit) < count;
            page++;
          } else {
            throw Exception(
                'Invalid response format or request failed: ${response.body}');
          }
        } else {
          throw Exception(
              'Failed to fetch products: ${response.statusCode} - ${response.body}');
        }
      }

      print(
          'Total products fetched for category $category: ${allProducts.length}');
      return allProducts;
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error: Unable to connect to the server. $e');
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      throw Exception(
          'Request timed out. Please check your internet connection. $e');
    } catch (e) {
      print('Fetch products by category error: $e');
      throw Exception('Fetch products by category error: $e');
    }
  }

  Future<List<ReviewModel>> getUserRatings() async {
    try {
      final token = await _ensureToken();
      final uri = Uri.parse('$profileEndpoint/product-ratings');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data.containsKey('ratings')) {
          return (data['ratings'] as List)
              .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch user ratings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fetch user ratings error: $e');
    }
  }

  Future<Map<String, dynamic>> getProductDetail(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$productEndpoint/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken() ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to get product detail: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Get product detail error: $e');
    }
  }

  Future<List<String>> uploadImages(
      List<XFile> images, BuildContext context) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(productEndpoint));
      request.headers['Authorization'] = await getToken() ?? '';
      for (var image in images) {
        final file = File(image.path);
        if (await file.length() > 10 * 1024 * 1024) {
          throw Exception('Image ${image.name} exceeds 10MB limit');
        }
        request.files
            .add(await http.MultipartFile.fromPath('images', image.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);

      if (response.statusCode == 200 && json['success'] as bool) {
        return List<String>.from(json['imageUrls'] as List<String>);
      } else {
        throw Exception(json['message'] ?? 'Failed to upload images');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'message': responseData['message'] as String?,
        'stats': responseData['stats'] as Map<String, dynamic>,
        'admins': responseData['admins'] as List<dynamic>,
      };
    } else {
      throw Exception(
          'Failed to fetch dashboard: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProductStatus(
      String productId, bool isActive) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$productId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'isActive': isActive}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to update product status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<ReviewModel>> getProductReviews({String? productId}) async {
    try {
      final uri = Uri.parse(productId != null
          ? '$ratingsEndpoint?productId=$productId'
          : ratingsEndpoint);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken() ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> &&
            data.containsKey('reviews')) {
          return (data['reviews'] as List)
              .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'Failed to fetch reviews: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fetch reviews error: $e');
    }
  }

  Future<Map<String, dynamic>> activateUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.put(
        Uri.parse('$adminEndpoint/users/$userId/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Parse the error response for more specific messaging
        String errorMessage = 'Failed to activate user: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (errorBody['error']?.toString().contains('profilePhoto') ??
              false) {
            errorMessage = 'Invalid profile photo data in user record.';
          } else {
            errorMessage = errorBody['error']?.toString() ?? errorMessage;
          }
        } catch (_) {
          // If response body isn't JSON, use the status code message
        }
        throw Exception(
            'Failed to activate user: $errorMessage - Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Activate user error: $e');
    }
  }

  // sample o fthe current value
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferencesKeys.tokenKey);
    await prefs.remove(PreferencesKeys.userKey);
    await prefs.remove(PreferencesKeys.profileImagePathKey);
    await prefs.setBool(PreferencesKeys.isLoggedInKey, false);
  }
}
