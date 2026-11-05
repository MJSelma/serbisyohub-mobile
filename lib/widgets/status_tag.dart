import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F3ED),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      status.replaceAll('_', ' ').toUpperCase(),
      style: const TextStyle(
        color: green,
        fontSize: 10,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
