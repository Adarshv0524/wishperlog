import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final outline = scheme.outline.withValues(alpha: 0.65);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBg
          : AppColors.lightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: isDark
            ? AppColors.darkGlass2
            : AppColors.lightGlass2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline, width: 0.7),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkGlass3.withValues(alpha: 0.7)
            : AppColors.lightGlass3.withValues(alpha: 0.9),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? AppColors.darkGlass2.withValues(alpha: 0.92)
            : AppColors.lightGlass1.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline, width: 0.8),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? AppColors.darkGlass2.withValues(alpha: 0.92)
            : AppColors.lightGlass1.withValues(alpha: 0.96),
        modalBackgroundColor: isDark
            ? AppColors.darkGlass2.withValues(alpha: 0.92)
            : AppColors.lightGlass1.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: outline, width: 0.8),
        ),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      dividerColor: outline,
    );
  }

  static ThemeData get lightTheme {
    return _base(
      ColorScheme.fromSeed(
        seedColor: AppColors.tasks,
        brightness: Brightness.light,
      ).copyWith(
        surface: AppColors.lightGlass1,
        onSurface: AppColors.lightTextPri,
        outline: AppColors.lightBorder,
      ),
    );
  }

  static ThemeData get darkTheme {
    return _base(
      ColorScheme.fromSeed(
        seedColor: AppColors.tasks,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.darkGlass1,
        onSurface: AppColors.darkTextPri,
        outline: AppColors.darkBorder,
      ),
    );
  }
}
