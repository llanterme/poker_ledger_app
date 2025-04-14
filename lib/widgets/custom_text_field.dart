import 'package:flutter/material.dart';
import 'package:poker_ledger/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final bool isEnabled;
  final int maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.isEnabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: isEnabled,
          maxLines: maxLines,
          focusNode: focusNode,
          onChanged: onChanged,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            contentPadding: const EdgeInsets.all(16),
            hintStyle: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
            errorStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ),
      ],
    );
  }
}
