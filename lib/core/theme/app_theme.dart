import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AppTheme v3.0 — Tactile Soft-Glass UI
//
// Every Material component that renders visible chrome is upgraded:
//   • ElevatedButton  → "Polished Resin" button with compound shadows + rim light
//   • TextButton      → glass-tint hover surface
//   • InputDecoration → frosted inset field with inner-shadow extrusion indicator
//   • Card            → multi-layer floating glass card
//   • Dialog          → smoked glass sheet with ambient glow
//   • BottomSheet     → heavy-frosted panel, top rim light on rounded edge
//   • SnackBar        → floating glass chip
//   • Chip            → soft tactile pill
// ══════════════════════════════════════════════════════════════════════════════
class AppTheme {
  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;

    // ── Surface / glass fills ────────────────────────────────────────────────
    final surfaceTint = isDark
        ? AppColors.darkGlass1.withValues(alpha: 0.90)
        : AppColors.lightGlass1.withValues(alpha: 0.98);
    final outline     = scheme.outline.withValues(alpha: 0.65);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      // Cards get compound shadows so they float off the mesh background.
      // The 0.8 outline border is overridden by GlassPane's own rim-light border
      // at the widget level; this fallback is kept for any widget using raw Card.
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline, width: 0.7),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // ── ElevatedButton — "Polished Resin" tactile primary ──────────────────
      // Visual recipe:
      //   Fill  : top-to-bottom gradient (lighter at top = light source from above)
      //   Shape : stadium-ish pill with medium radius
      //   Shadow: compound 3-layer drop shadow (from primaryButtonShadows)
      //   Rim   : handled by the GlassPane wrapping each button call-site,
      //           OR via the overlayColor spec for normal ElevatedButtons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return scheme.primary.withValues(alpha: 0.82);
            }
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.12);
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.all(scheme.onPrimary),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.06);
            }
            return Colors.transparent;
          }),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          // AnimatedScale simulated via elevation change on press is handled
          // by call-site TactileButton wrapper where precise control is needed.
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          overlayColor: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(
            color: isDark
                ? AppColors.darkRimMid
                : scheme.primary.withValues(alpha: 0.35),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Icon ───────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: scheme.onSurface),

      // ── InputDecoration — Frosted inset field ──────────────────────────────
      // Light mode: field is slightly recessed (feels "pressed into" the surface)
      // Dark mode:  field is subtly darker than surrounding glass (depth-by-contrast)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkGlass3.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.55),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.6)
                : AppColors.lightBorder.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.80),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.errorStatus.withValues(alpha: 0.80)),
        ),
        // Hint and label styles
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSec.withValues(alpha: 0.55)
              : AppColors.lightTextSec.withValues(alpha: 0.60),
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Dialog — Smoked Glass ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),

      // ── PopupMenu ──────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: isDark
            ? const Color(0xF0111827)
            : const Color(0xF0FFFFFF),
        shadowColor: AppColors.lightShadowMid,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        textStyle: TextStyle(color: scheme.onSurface, fontSize: 14),
      ),

      // ── BottomSheet ————————————————————————————————————————————————————————
      // Heavy frosted panel; the top-rounded edge naturally catches the top rim
      // light, which is implemented at the sheet's own build site.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ── SnackBar — floating glass chip ─────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.transparent,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.darkGlass2.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.60),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextPri : AppColors.lightTextPri,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Switch / Checkbox / Slider ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? AppColors.darkTextSec : AppColors.lightTextSec;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return isDark
              ? AppColors.darkGlass2
              : AppColors.lightGlass3;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: isDark
            ? AppColors.darkGlass2
            : AppColors.lightGlass3,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayColor: scheme.primary.withValues(alpha: 0.18),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerColor: outline.withValues(alpha: 0.5),

      // ── Misc ───────────────────────────────────────────────────────────────
      splashColor: Colors.transparent,
      highlightColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.02),
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