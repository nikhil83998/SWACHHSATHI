import 'package:flutter/material.dart';

class AppStyles {
  // Brand Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accentColor = Color(0xFF4CAF50);

  // Dynamic Text Styles
  static TextStyle headlineLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: isDark ? primaryLight : primaryDark,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          color: isDark ? primaryLight : primaryDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle headlineMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: isDark ? primaryLight : primaryDark,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          color: isDark ? primaryLight : primaryDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle bodyText(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        ) ??
        TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 14,
        );
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ) ??
        TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
        );
  }

  // Input Decoration
  static InputDecoration inputDecoration(BuildContext context,
      {String? label, String? hint, Widget? prefixIcon, Widget? suffixIcon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF242424) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? primaryLight : primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
      ),
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
      ),
    );
  }

  // Button Style
  static ButtonStyle primaryButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: isDark ? primaryLight : primaryColor,
      foregroundColor: isDark ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Card Decoration
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? const Color(0xFF2D3748) : Colors.grey.shade200,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}