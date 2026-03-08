// lib/core/services/proximity_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class ProximitySensorService {
  StreamSubscription<int>? _subscription;
  final ValueNotifier<bool> isPrivacyMode = ValueNotifier(false);

  void start() {
    _subscription ??= ProximitySensor.events.listen((int event) {
      isPrivacyMode.value = event > 0;
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    isPrivacyMode.value = false;
  }

  void dispose() {
    stop();
    isPrivacyMode.dispose();
  }
}

class PrivacyText extends StatelessWidget {
  const PrivacyText(
    this.text, {
    super.key,
    required this.isPrivate,
    this.style,
    this.obscureChar = '●',
  });

  final String text;
  final bool isPrivate;
  final TextStyle? style;
  final String obscureChar;

  @override
  Widget build(BuildContext context) {
    return Text(
      isPrivate ? obscureChar * text.length.clamp(4, 12) : text,
      style: style,
    );
  }
}

class PrivacyWidget extends StatelessWidget {
  const PrivacyWidget({
    super.key,
    required this.isPrivate,
    required this.child,
    this.placeholder,
  });

  final bool isPrivate;
  final Widget child;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (!isPrivate) return child;
    return placeholder ??
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
  }
}
