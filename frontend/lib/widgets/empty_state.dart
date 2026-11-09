import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyState({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Iconsax.info_circle, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
