import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/product.dart';
import 'package:crafted_by_her/presentation/reusable_components/banner_widget.dart';
import 'package:crafted_by_her/presentation/reusable_components/product_card.dart';
import 'package:crafted_by_her/presentation/reusable_components/section_item_grid.dart';
import 'package:crafted_by_her/presentation/reusable_components/video_card.dart';
import 'package:crafted_by_her/presentation/seller_form_submission.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

import 'reusable_components/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  List<Map<String, String>> videoDataList = [];
  List<Product> filteredProducts = [];

  Future<void> loadVideoData() async {
    try {
      final List<Map<String, String>> dataList = [
        {
          "videoId": "NTVGpy12qNg",
          "title": "Made in Africa: Ethiopian weaver modernises ancient craft",
          "description":
              "Explore how an Ethiopian weaver is revitalizing traditional hand-weaving techniques for modern audiences."
        },
        {
          "videoId": "hCGieyTOGr8",
          "title": "Aari Women Demonstrating Pottery-making, Ethiopia",
          "description":
              "Watch Aari women showcase traditional Ethiopian pottery-making methods passed down through generations."
        },
        {
          "videoId": "30PGFTV0buQ",
          "title": "Making Ethiopian Cross Necklace | Jewelry Making Tutorial",
          "description":
              "Step-by-step guide to crafting a traditional Ethiopian cross necklace using brass."
        },
        {
          "videoId": "0pF3cVsIKoc",
          "title":
              "How to Hand-Sew African Style Baskets | Traditional Weaving Guide",
          "description":
              "Learn the art of hand-sewing African-style baskets with this beginner-friendly tutorial."
        },
        {
          "videoId": "76hYyQE3iXE",
          "title": "Handweaving Traditional Ethiopian Scarves",
          "description":
              "Discover the intricate process of handweaving traditional Ethiopian scarves, known for their unique patterns."
        },
        {
          "videoId": "s5Gzbn-55Og",
          "title":
              "The Art of Making Traditional Coffee Pot 'Jebena' With CLAY",
          "description":
              "Delve into the craftsmanship behind creating the iconic Ethiopian clay coffee pot, the Jebena."
        },
        {
          "videoId": "oehNExDhN-k",
          "title":
              "ET A TO Z - Arts and Crafts - Discover Ethiopia's Unique Craftsmanship",
          "description":
              "A comprehensive look into Ethiopia's diverse arts and crafts scene, highlighting unique traditional practices."
        },
        {
          "videoId": "d1VpadSDZrc",
          "title": "I am learning how to spin cotton traditionally ፈትል",
          "description":
              "Experience the traditional Ethiopian method of spinning cotton, a foundational textile skill."
        },
      ];

      setState(() {
        videoDataList = dataList;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading video data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    loadVideoData();
  }

  Future<void> _loadInitialData() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    await viewModel.fetchProductsByCategory('New Release');
    setState(() {
      filteredProducts = viewModel.newReleaseProducts;
    });
  }

  void _filterProducts(String query) {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        filteredProducts = viewModel.newReleaseProducts;
      });
    } else {
      setState(() {
        filteredProducts = viewModel.newReleaseProducts.where((product) {
          final titleLower = product.title.toLowerCase();
          final descriptionLower = product.description.toLowerCase();
          final queryLower = query.toLowerCase();
          return titleLower.contains(queryLower) ||
              descriptionLower.contains(queryLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      key: _scaffoldKey,
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
        elevation: 0,
        actions: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SellerFlowScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Sell',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
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
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            searchBar(
              hintText: 'Search New Releases...',
              controller: _searchController,
              onChanged: _filterProducts,
              onPressed: () {
                _filterProducts(_searchController.text);
              },
            ),
            const SizedBox(height: 32),
            const BannerWidget(
              imagePath: 'assets/images/hero_image.png',
            ),
            const SizedBox(height: 16),
            // New Release Section
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (viewModel.errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: Colors.grey),
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
                        await viewModel.fetchProductsByCategory('New Release');
                        setState(() {
                          filteredProducts = viewModel.currentProducts;
                        });
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
            else
              sectionItemGrid(
                title: 'New Release',
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
            const SizedBox(height: 16),
            sectionItemGrid(
              title: 'Creative Learning',
              items: videoDataList,
              itemBuilder: (context, index) {
                final video = videoDataList[index];
                final videoId = video['videoId'] ?? '';
                final videoUrl = 'https://www.youtube.com/watch?v=$videoId';

                return YouTubeVideoCard(
                  youtubeUrl: videoUrl,
                  videoTitle: video['title'] ?? 'Unknown Title',
                  videoDuration: video['duration'] ?? '0:00',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
