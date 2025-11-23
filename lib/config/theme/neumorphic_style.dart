// lib/config/theme/neumorphic_style.dart
import 'package:flutter/material.dart';

class Neu {
  static const Color base = Color(0xFFE9E9EF);

  static BoxDecoration box({
    double radius = 18,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isPressed
          ? [
        const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
        BoxShadow(color: Colors.black.withOpacity(0.18), offset: Offset(2, 2), blurRadius: 4),
      ]
          : [
        const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
        BoxShadow(color: Colors.black.withOpacity(0.18), offset: Offset(4, 4), blurRadius: 12),
      ],
    );
  }
}
