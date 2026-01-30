import 'package:flutter/material.dart';

class CustomTextAreaField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const CustomTextAreaField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  State<CustomTextAreaField> createState() => _CustomTextAreaFieldState();
}

class _CustomTextAreaFieldState extends State<CustomTextAreaField> {
  final GlobalKey<FormFieldState<String>> _customTextAreaFieldKey =
      GlobalKey<FormFieldState<String>>();

  static const Color _hintColor = Color(0xFF999999);
  static const Color _errorColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final String displayLabel = widget.hintText;
    final bool hasError =
        _customTextAreaFieldKey.currentState?.errorText != null &&
        _customTextAreaFieldKey.currentState!.errorText!.isNotEmpty;

    final Color effectiveHintColor = hasError ? _errorColor : _hintColor;

    return TextFormField(
      key: _customTextAreaFieldKey,
      controller: widget.controller,
      minLines: 4,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: effectiveHintColor, fontSize: 17),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
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
