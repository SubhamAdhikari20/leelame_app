// lib/core/widgets/custom_tab_item.dart
import 'package:flutter/material.dart';

class CustomTabItem extends StatelessWidget {
  const CustomTabItem({super.key, required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(fontFamily: 'OpenSans Medium'),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              width: 20,
              height: 20,
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
