import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final VoidCallback? onSuffixIconTap;

  final bool filled;
  final Color fillColor;

  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onSuffixIconTap,
    this.filled = true,
    this.fillColor = const Color(0xFFFFFDFC), // Cream tone
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  // Radha-Krishna divine palette
  final Color krishnaBlue = const Color(0xFF2B65A8); // deep sky blue
  final Color radhaPink = const Color(0xFFE85A8A);   // lotus pink

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // TEXT STYLE
    final effectiveTextStyle = widget.textStyle ??
        TextStyle(
          color: krishnaBlue,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

    // LABEL STYLE
    final effectiveLabelStyle = widget.labelStyle ??
        TextStyle(
          color: radhaPink,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        );

    // HINT STYLE
    final effectiveHintStyle = widget.hintStyle ??
        TextStyle(
          color: krishnaBlue.withOpacity(0.45),
          fontSize: 15,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// FIELD LABEL
        Text(
          widget.label,
          style: effectiveLabelStyle,
        ),

        const SizedBox(height: 10),

        /// TEXT FIELD BOX + SHADOW + INPUT
        Container(
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Radha Pink glow
              BoxShadow(
                color: radhaPink.withOpacity(0.10),
                offset: const Offset(-3, -3),
                blurRadius: 8,
              ),
              // Krishna Blue shadow
              BoxShadow(
                color: krishnaBlue.withOpacity(0.15),
                offset: const Offset(3, 3),
                blurRadius: 10,
              ),
            ],
          ),

          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText && _isObscured,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            style: effectiveTextStyle,

            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: effectiveHintStyle,

              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                size: 22,
                color: krishnaBlue,
              )
                  : null,

              suffixIcon: widget.obscureText
                  ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: krishnaBlue,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                  widget.onSuffixIconTap?.call();
                },
              )
                  : widget.suffixIcon,

              filled: true,
              fillColor: widget.fillColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 14,
              ),

              // NORMAL BORDER
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: krishnaBlue.withOpacity(0.15),
                ),
              ),

              // FOCUSED BORDER — divine pink
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: radhaPink,
                  width: 1.5,
                ),
              ),

              // NO ERROR BORDER CUTTING THE UI
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
