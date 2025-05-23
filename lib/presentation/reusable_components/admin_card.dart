import 'package:flutter/material.dart';

class AdminCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String status;
  final Color statusColor;
  final VoidCallback? onDeletePressed;

  const AdminCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.statusColor,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name', name),
          const SizedBox(height: 8.0),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          _buildInfoRow('Email', email),
          const SizedBox(height: 8.0),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          _buildInfoRow('Role', role),
          const SizedBox(height: 8.0),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 8.0),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                    color: const Color(0xFFEEEEF1),
                    borderRadius: BorderRadius.circular(4.0),
                    backgroundBlendMode: BlendMode.srcIn),
                child: IconButton(
                  onPressed: onDeletePressed,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ),
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
        Text(label,
            style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.15)),
        Text(value),
      ],
    );
  }
}
