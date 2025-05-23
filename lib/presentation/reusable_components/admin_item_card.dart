import 'package:flutter/material.dart';

/// A reusable widget to display product details in a card format.
/// It includes fields for product information and action icons.
class ProductDetailsCard extends StatelessWidget {
  final String productName;
  final String sellerEmail;
  final double averageRating;
  final String status;
  final Color statusColor; // Color for the status indicator
  final VoidCallback? onFlagPressed; // Callback for flag icon press
  final VoidCallback? onTrashPressed; // Callback for trash icon press

  /// Constructor for the ProductDetailsCard.
  const ProductDetailsCard({
    super.key,
    required this.productName,
    required this.sellerEmail,
    required this.averageRating,
    required this.status,
    this.statusColor = Colors.green, // Default status color is green
    this.onFlagPressed,
    this.onTrashPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center the card horizontally
      child: Container(
        // Constrain the width for larger screens, allowing it to be full width on smaller screens
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.all(16.0), // Add margin around the card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the column take minimum space
          children: [
            // Product Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow("Product Name", productName),
                  _buildDetailRow("Seller Email", sellerEmail),
                  _buildDetailRow("Average Rating", averageRating.toString()),
                  _buildStatusRow("Status", status, statusColor),
                ],
              ),
            ),

            // Action Icons Section
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color:
                    Colors.grey[50], // Light grey background for icons section
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align icons to the right
                children: [
                  // Flag Icon Button
                  IconButton(
                    icon: const Icon(Icons.flag_outlined),
                    color: Colors.grey[600],
                    onPressed: onFlagPressed,
                    tooltip: 'Report', // Add tooltip for accessibility
                  ),
                  // Trash Icon Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey[600],
                    onPressed: onTrashPressed,
                    tooltip: 'Delete', // Add tooltip for accessibility
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a single detail row.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space out label and value
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            // Allow the value text to take available space
            child: Text(
              value,
              textAlign: TextAlign.right, // Align value to the right
              style: TextStyle(
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build the status row with a colored indicator.
  Widget _buildStatusRow(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: color, // Use the provided color
              borderRadius:
                  BorderRadius.circular(20.0), // Rounded corners for status
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example Usage:
/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Details Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
        ),
        body:
      ),
    );
  }
}
*/
