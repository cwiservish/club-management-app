import 'package:flutter/material.dart';

class HomeMenuItem extends StatelessWidget {
  final String title;

  const HomeMenuItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF20242A),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF4E5663),
            size: 20,
          ),
        ],
      ),
    );
  }
}
