// Card for displaying Admin User information
import 'package:flutter/material.dart';

class AdminUserCard extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final Color statusColor;
  final VoidCallback? onActivate;

  const AdminUserCard(
      {super.key,
      required this.name,
      required this.email,
      required this.status,
      required this.statusColor,
      this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name', name),
          SizedBox(height: 8),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          _buildInfoRow('Email', email),
          SizedBox(height: 8),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Color(0xFFEEEEF1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: onActivate,
                  child: Text('Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
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
        Text(label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.15,
            )),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
