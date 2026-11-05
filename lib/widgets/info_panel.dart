import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFE6F3ED),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: dark, height: 1.5, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
