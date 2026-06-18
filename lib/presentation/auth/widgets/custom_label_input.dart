import 'package:flutter/material.dart';

class CustomLabelInput extends StatelessWidget {
  final String text;

  const CustomLabelInput({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500, // Thêm chút đậm cho chuyên nghiệp
        ),
      ),
    );
  }
}