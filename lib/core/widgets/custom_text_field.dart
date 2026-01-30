//
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.labelText,
    this.keyboardType,
    this.isPassword,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  bool _hasText = false;

  final GlobalKey<FormFieldState<String>> _customTextFieldKey =
      GlobalKey<FormFieldState<String>>();
  static const Color _hintColor = Color(0xFF999999);
  static const Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ?? false;
    widget.controller.addListener(_handleControllerChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  void _handleControllerChange() {
    final bool hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      if (mounted) {
        setState(() {
          _hasText = hasText;
        });
      }
    }
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayLabel = widget.labelText ?? widget.hintText;

    final bool hasError =
        _customTextFieldKey.currentState?.errorText != null &&
        _customTextFieldKey.currentState!.errorText!.isNotEmpty;

    final Color effectiveHintColor = hasError ? _errorColor : _hintColor;

    return TextFormField(
      key: _customTextFieldKey,
      controller: widget.controller,
      obscureText: widget.isPassword == true ? _obscureText : false,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: effectiveHintColor, fontSize: 17),
        suffixIcon: (widget.isPassword == true && _hasText)
            ? IconButton(
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
              )
            : null,
      ),
      validator:
          widget.validator ??
          (value) {
            // _updateState();
            if (value == null || value.isEmpty) {
              return "Please enter ${displayLabel.toLowerCase()}";
            }
            return null;
          },
    );
  }
}
