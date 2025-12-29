// lib/core/widgets/custom_primary_button.dart
import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final bool? isLoading;

  const CustomPrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: isLoading == true ? null : onPressed,
        child: isLoading == true
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
