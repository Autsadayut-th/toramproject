import 'package:flutter/material.dart';

class CustomEquipmentBadge extends StatelessWidget {
  const CustomEquipmentBadge({super.key, this.label = 'Custom'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
