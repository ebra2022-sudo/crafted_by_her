import 'package:crafted_by_her/presentation/category_screen.dart';
import 'package:crafted_by_her/presentation/reusable_components/video_card.dart';
import 'package:flutter/material.dart';
import 'package:crafted_by_her/data/api_service.dart';
import 'package:crafted_by_her/domain/models/video.dart';
import 'package:flutter_svg/svg.dart';

class CreativeLearningScreen extends StatefulWidget {
  const CreativeLearningScreen({super.key});

  @override
  _CreativeLearningScreenState createState() => _CreativeLearningScreenState();
}

class _CreativeLearningScreenState extends State<CreativeLearningScreen> {
  final List<Video> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Color.fromARGB(255, 242, 92, 5),
            ),
            onPressed: () {
              // Implement filter functionality if needed
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      hintStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 242, 92, 5),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          // Creative Learning Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Creative Learning',
              style: TextStyle(
                fontFamily: 'DMSerif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Video Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _videos.length + 1,
              itemBuilder: (context, index) {
                if (index == _videos.length) {
                  _loadVideos();
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }
                final video = _videos[index];
                return null;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icon/home.svg'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icon/category.svg'),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icon/account.svg'),
            label: 'Account',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 242, 92, 5),
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CategoryScreen()),
            );
          } else if (index == 2) {
            Navigator.pushNamed(context, '/login');
          }
        },
      ),
    );
  }
}
