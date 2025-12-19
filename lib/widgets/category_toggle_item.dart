// lib/widgets/category_toggle_item.dart
import 'package:flutter/material.dart';

class CategoryToggleItem extends StatelessWidget {
  const CategoryToggleItem({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(label, style: TextStyle(fontSize: 15)),
    );
  }
}
