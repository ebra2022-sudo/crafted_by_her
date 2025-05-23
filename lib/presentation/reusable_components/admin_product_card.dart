import 'package:flutter/material.dart';

class ProductItemCard extends StatelessWidget {
  final String productName;
  final String sellerEmail;
  final double averageRating;
  final String status;
  final Color statusColor;
  final VoidCallback? onFlagPressed;
  final VoidCallback? onDeletePressed;

  const ProductItemCard({
    super.key,
    required this.productName,
    required this.sellerEmail,
    required this.averageRating,
    required this.status,
    required this.statusColor,
    this.onFlagPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300), // Subtle border
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Product Name', productName),
          const SizedBox(height: 8.0),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          const SizedBox(height: 8.0),
          _buildInfoRow('Seller Email', sellerEmail),
          const SizedBox(height: 8.0),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          const SizedBox(height: 8.0),
          _buildInfoRow('Average Rating', averageRating.toString()),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                  child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEF1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: IconButton(
                  onPressed: onFlagPressed,
                  icon: const Icon(Icons.flag_outlined),
                  tooltip: 'Flag',
                ),
              )),
              const SizedBox(width: 8),
              Flexible(
                  child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEF1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: IconButton(
                  onPressed: onDeletePressed,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.15,
          ),
        )),
        Flexible(
            child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
          ),
        ))
      ],
    );
  }
}
