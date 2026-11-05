import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key, this.subtitle});
  final String text;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: dark,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle!, style: TextStyle(color: Colors.grey.shade600)),
      ],
    ],
  );
}
