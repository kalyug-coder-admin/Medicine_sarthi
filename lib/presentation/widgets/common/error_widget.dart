// lib/presentation/widgets/common/error_widget.dart

import 'package:flutter/material.dart';
import '../../../config/theme/neumorphic_style.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(28),
            decoration: Neu.box(radius: 60),
            child: Icon(Icons.error_outline,
                size: 60, color: Colors.red.shade400),
          ),

          const SizedBox(height: 20),

          Text(
            "Oops!",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          if (onRetry != null) ...[
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: Neu.box(radius: 14),
                child: const Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
