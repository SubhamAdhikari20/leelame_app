// lib/features/auth/presentation/widgets/custom_auth_text_field.dart
import 'package:flutter/material.dart';

class CustomAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final bool? showClearButton;

  const CustomAuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.labelText,
    this.keyboardType,
    this.isPassword,
    this.showClearButton,
  });

  @override
  State<CustomAuthTextField> createState() => _CustomAuthTextFieldState();
}

class _CustomAuthTextFieldState extends State<CustomAuthTextField> {
  late bool _obscureText;
  bool _hasText = false;

  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  static const Color _hintColor = Color(0xFF999999);
  static const Color _focusedColor = Color(0xFF4CAF50);
  static const Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ?? false;

    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty != _hasText) {
        _updateState();
      }
    });
  }

  void _updateState() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _clearText() {
    widget.controller.clear();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayLabel = widget.labelText ?? widget.hintText;

    final bool hasError =
        _fieldKey.currentState?.errorText != null &&
        _fieldKey.currentState!.errorText!.isNotEmpty;

    final Color effectiveHintColor = hasError ? _errorColor : _hintColor;
    final Color effectiveFloatingLabelColor = hasError
        ? _errorColor
        : _focusedColor;

    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      obscureText: widget.isPassword == true ? _obscureText : false,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: effectiveHintColor, fontSize: 17),
        labelText: widget.labelText,
        labelStyle: TextStyle(color: effectiveHintColor),
        floatingLabelStyle: TextStyle(
          color: effectiveFloatingLabelColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isPassword != true &&
                (widget.showClearButton == true || _hasText)) ...{
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF999999),
                  size: 22,
                ),
                onPressed: _clearText,
                splashRadius: 20,
              ),
            },

            if (widget.isPassword == true && _hasText) ...{
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    key: ValueKey<bool>(_obscureText),
                    color: const Color(0xFF999999),
                    size: 24,
                  ),
                ),
                onPressed: _toggleVisibility,
                splashRadius: 20,
              ),
            },
          ],
        ),
      ),
      validator: (value) {
        _updateState();
        if (value == null || value.isEmpty) {
          return "Please enter ${displayLabel.toLowerCase()}";
        }
        return null;
      },
    );
  }
}
