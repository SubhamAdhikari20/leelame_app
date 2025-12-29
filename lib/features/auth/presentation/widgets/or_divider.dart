// lib/features/auth/presentation/widgets/or_divider.dart
import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 2)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(color: Color(0xFF999999), fontSize: 16),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 2)),
      ],
    );
  }
}
