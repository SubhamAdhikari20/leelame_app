// lib/widgets/custom_outlined_button.dart
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget? prefixIcon;
  final bool? hasIcon;
  final Icon? icon;

  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.prefixIcon,
    this.hasIcon,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: hasIcon == true
          ? OutlinedButton.icon(
              onPressed: onPressed,
              label: Text(text),
              icon: icon,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: Color(0xFF2ADA03),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
