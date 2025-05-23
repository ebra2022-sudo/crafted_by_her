import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/super_admin_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/product_categories.dart';
import '../domain/models/user.dart';
import 'reusable_components/admin_product_card.dart';
import 'reusable_components/search_bar.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false)
          .fetchAllAdminProducts();
    });
  }

  void _deleteProduct(String productId) {
    // Capture the parent context (AdminProductsScreen's context) before showing the dialog
    final parentContext = context;

    showDialog<Widget>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Dismiss the dialog
              // Use the parent context for deleteProduct
              Provider.of<AuthViewModel>(parentContext, listen: false)
                  .deleteProduct(productId, parentContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _increaseWarning(String userId, int currentWarnings) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.user;
    final currentUserRole = currentUser?.role;

    Future<void> Function(String, BuildContext)? warningFunction;

    // Select correct function based on current user's role
    if (currentUserRole == Role.superAdmin) {
      warningFunction = authViewModel.increaseUserWarningSuperAdmin;
    } else if (currentUserRole == Role.admin) {
      warningFunction = authViewModel.increaseUserWarningAdmin;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to issue warnings.'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    warningFunction(userId, context).then((_) {
      final updatedUser = authViewModel.inactiveUsers.firstWhere(
        (user) => user['id'] == userId || user['_id'] == userId,
        orElse: () => {},
      );

      if (updatedUser.isNotEmpty) {
        final warnings = updatedUser['warnings'] as int? ?? 0;

        if (warnings >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('User has been deactivated due to excessive warnings!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  List<ProductModel> _mapProducts(List<Map<String, dynamic>> products) {
    return products.map((product) {
      final userInfo = product['userId'] as Map<String, dynamic>? ?? {};
      return ProductModel(
        id: product['id'] as String? ?? product['_id'] as String? ?? '',
        name: product['title'] as String? ?? '',
        sellerEmail: userInfo['email'] as String? ?? '',
        averageRating: (product['averageRating'] as num?)?.toDouble() ?? 0.0,
        status: product['isActive'] == true ? 'Active' : 'Inactive',
        userId: userInfo['id'] as String? ?? userInfo['_id'] as String? ?? '',
        warnings: userInfo['warnings'] as int? ?? 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final products = _mapProducts(viewModel.adminProducts);

        // 🔍 Filter by search text
        final filteredProducts = _searchText.isEmpty
            ? products
            : products.where((product) {
                final query = _searchText.toLowerCase();
                return product.name.toLowerCase().contains(query) ||
                    product.sellerEmail.toLowerCase().contains(query);
              }).toList();

        // 🧭 Apply pagination after filtering
        final paginatedProducts = filteredProducts
            .skip((_currentPage - 1) * _itemsPerPage)
            .take(_itemsPerPage)
            .toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
              title: const Text(
                'Products',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              actions: [
                Flexible(
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    onSelected: (String value) async {
                      if (value == 'logout') {
                        final authViewModel =
                            Provider.of<AuthViewModel>(context, listen: false);
                        await authViewModel.logout(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text(
                          'Logout',
                          style: TextStyle(fontFamily: 'OpenSans'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ]),
          backgroundColor: Colors.white,
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 🔍 Search Bar
              searchBar(
                hintText: 'Search here',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                    _currentPage = 1;
                  });
                },
                onPressed: () {
                  setState(() {
                    _searchText = _searchController.text;
                    _currentPage = 1;
                  });
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.errorMessage != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.fetchAllAdminProducts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (filteredProducts.isEmpty)
                const Center(child: Text("No products found."))
              else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paginatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = paginatedProducts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ProductItemCard(
                        productName: product.name,
                        sellerEmail: product.sellerEmail,
                        averageRating: product.averageRating,
                        status: product.status,
                        statusColor: product.status == 'Active'
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        onDeletePressed: () => _deleteProduct(product.id),
                        onFlagPressed: product.userId.isNotEmpty
                            ? () => _increaseWarning(
                                product.userId, product.warnings)
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (filteredProducts.length > _itemsPerPage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: OutlinedButton(
                          onPressed: _currentPage == 1
                              ? null
                              : () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                },
                          child: const Text('Prev',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'page $_currentPage of ${(filteredProducts.length / _itemsPerPage).ceil()}',
                          ),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: (_currentPage * _itemsPerPage >=
                                  filteredProducts.length)
                              ? null
                              : () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Next',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Flexible(
                                child: Icon(Icons.chevron_right, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Updated ProductModel for live search + warnings
class ProductModel {
  final String id;
  final String name;
  final String sellerEmail;
  final double averageRating;
  final String status;
  final String userId;
  final int warnings;

  ProductModel({
    required this.id,
    required this.name,
    required this.sellerEmail,
    required this.averageRating,
    required this.status,
    this.userId = '',
    this.warnings = 0,
  });
}
