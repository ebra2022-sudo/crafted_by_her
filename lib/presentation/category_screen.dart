import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/product.dart';
import 'package:crafted_by_her/presentation/reusable_components/product_card.dart';
import 'package:crafted_by_her/presentation/reusable_components/search_bar.dart';
import 'package:crafted_by_her/presentation/reusable_components/section_item_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/product_categories.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = 'All';
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    ...ProductCategory.values.map((e) => e.name).toList()
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    final filteredProducts = viewModel.currentProducts.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch = _searchText.isEmpty ||
          product.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchText.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crafted by Her',
          style: TextStyle(
            fontFamily: 'DMSerif',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 242, 92, 5),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            searchBar(
              hintText: 'Search here',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              onPressed: () {
                setState(() {
                  _searchText = _searchController.text;
                });
              },
            ),
            const SizedBox(height: 16),

            // Category Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Chip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? const Color.fromARGB(255, 242, 92, 5)
                            : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Product Grid / Loader / Error / Empty State
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (viewModel.errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Network Error',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          viewModel.setErrorMessage(null);
                          viewModel.setLoading(true);
                        });
                        await viewModel.fetchProductsByCategory('All');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6200),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else if (filteredProducts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    'No products found for "${_searchText.trim()}"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              sectionItemGrid(
                title: 'Products',
                items: filteredProducts,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    imageId: product.id,
                    imageUrl: product.images.isNotEmpty
                        ? product.images[0]
                        : 'assets/images/sample_product_image.png',
                    title: product.title,
                    description: product.description,
                    rating: product.averageRating,
                    price: product.price,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
