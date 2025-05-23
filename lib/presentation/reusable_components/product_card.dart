import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:crafted_by_her/presentation/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final String imageId;
  final String imageUrl;
  final String title;
  final String description;
  final double rating;
  final double price;

  const ProductCard({
    super.key,
    required this.imageId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xB2E3E3E3), // #E3E3E3B2
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<Widget Function(BuildContext)>(
              builder: (context) => ProductDetailScreen(productId: imageId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Card(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardHeight = constraints.maxHeight;
              final imageHeight =
                  cardHeight * 0.65; // Image takes 65% of card height

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/sample_product_image.png',
                          height: imageHeight,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'DMSerif',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${price.toStringAsFixed(0)} ETB',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final double childAspectRatio;
  const ResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.childAspectRatio = 0.7, // Default child aspect ratio
  });

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width >= 1200
        ? 4 // Large screen (desktop)
        : MediaQuery.of(context).size.width >= 650
            ? 3 // Medium screen (tablet)
            : 2; // Small screen (phone)

    return GridView.builder(
      shrinkWrap: true, // Let GridView size itself based on content
      physics: const NeverScrollableScrollPhysics(), // Disable GridView scroll
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: itemBuilder,
    );
  }
}
