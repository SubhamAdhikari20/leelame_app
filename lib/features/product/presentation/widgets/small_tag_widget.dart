// lib/features/product/presentation/widgets/small_tag_widget.dart
import 'package:flutter/material.dart';

class SmallTagWidget extends StatelessWidget {
  const SmallTagWidget({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontFamily: "OpenSans Medium",
        ),
      ),
    );
  }
}
