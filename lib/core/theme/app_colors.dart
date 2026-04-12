import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WishperLog Design System v3.0 — Tactile Soft-Glass UI
//
// CHANGELOG from v2.1:
//   • Added rimLight tokens (the 1-2 px specular highlight on top-left bevel)
//   • Added compoundShadow tokens (3 layered diffused drop shadows per mode)
//   • Added extrusionOverlay tokens (subtle inner-shadow for 3D volume)
//   • Tightened dark mode glass fills for better smoked-glass fidelity
//   • Pure #000000 / #FFFFFF backgrounds remain strictly avoided per spec
//
// DO NOT add colour literals anywhere else in the codebase.
// ══════════════════════════════════════════════════════════════════════════════
abstract class AppColors {
  // ── DARK GLASS SURFACES ────────────────────────────────────────────────────
  static const Color darkBg     = Color(0xFF090F1A);
  static const Color darkGlass1 = Color(0x30F5FAFF);
  static const Color darkGlass2 = Color(0x22EFF6FF);
  static const Color darkGlass3 = Color(0x14E8F0FF);
  static const Color darkTextPri = Color(0xFFEAF1FF);
  static const Color darkTextSec = Color(0xFFA7B6CC);
  static const Color darkTextTer = Color(0xFF75D6B0);
  static const Color darkBorder  = Color(0x2DDAE8FF);

  // ── LIGHT GLASS SURFACES ───────────────────────────────────────────────────
  static const Color lightBg     = Color(0xFFF0F4F9);   // slightly deeper for shadow contrast
  static const Color lightGlass1 = Color(0xE8FFFFFF);
  static const Color lightGlass2 = Color(0xC5FFFFFF);
  static const Color lightGlass3 = Color(0xA0FFFFFF);
  static const Color lightTextPri = Color(0xFF102037);
  static const Color lightTextSec = Color(0xFF4E6485);
  static const Color lightTextTer = Color(0xFF7E8EAB);
  static const Color lightBorder  = Color(0x1A204268);

  // ── RIM LIGHT TOKENS (the specular highlight, top-left bevel) ─────────────
  // "Smoked Glass" dark mode: metallic, brighter, as it's the PRIMARY depth cue
  static const Color darkRimBright = Color(0x4DFFFFFF);  // 30% white — bright catch
  static const Color darkRimMid    = Color(0x14FFFFFF);  // 8%  white — fade-off
  static const Color darkRimDark   = Color(0x28000000);  // 16% black — bottom-right recession

  // "Polished Resin" light mode: crisper, slightly less intense than dark (shadows do more work)
  static const Color lightRimBright = Color(0x66FFFFFF);  // 40% white — crisp top-left highlight
  static const Color lightRimMid    = Color(0x1EFFFFFF);  // 12% white — mid-point transition
  static const Color lightRimDark   = Color(0x12000000);  // 7%  black — very soft bottom-right

  // ── TACTILE EXTRUSION TOKENS (inner shadow — bottom-right) ─────────────────
  // Simulates physical "puffed" 3D volume; very low opacity to not obstruct content
  static const Color darkExtrusionShadow  = Color(0x1A000000);  // 10% black
  static const Color lightExtrusionShadow = Color(0x0D000000);  // 5%  black

  // ── COMPOUND DROP SHADOW TOKENS ────────────────────────────────────────────
  // Dark mode: coloured "LED backlight" ambient glows instead of pure grey shadows
  static const Color darkShadowClose  = Color(0x3D000000);  // alpha 24%
  static const Color darkShadowMid    = Color(0x2E000000);  // alpha 18%
  static const Color darkShadowFar    = Color(0x1E000000);  // alpha 12%

  // Light mode: soft desaturated grey tints faintly matching background
  static const Color lightShadowClose = Color(0x2E3B5E8A);  // 18% cool blue-grey
  static const Color lightShadowMid   = Color(0x1F3B5E8A);  // 12% cool blue-grey
  static const Color lightShadowFar   = Color(0x143B5E8A);  // 8%  cool blue-grey

  // ── CATEGORY CHROMATICS ────────────────────────────────────────────────────
  static const Color tasks     = Color(0xFF6045FA);
  static const Color reminders = Color(0xFFF472B6);
  static const Color ideas     = Color(0xFFFBBF24);
  static const Color followUp  = Color(0xFF34D399);
  static const Color journal   = Color(0xFFA78BFA);
  static const Color general   = Color(0xFF94A3B8);
  static const Color errorStatus = Color(0xFFEF4444);

  // ── DARK FOLDER COLOUR-LEAK BG TINTS ──────────────────────────────────────
  static const Color tasksDarkBg    = Color(0xFF060DD1);
  static const Color remindersDarkBg = Color(0xFFF04010);
  static const Color ideasDarkBg    = Color(0xFFF0CF86);
  static const Color followUpDarkBg = Color(0xFF866F0C);
  static const Color journalDarkBg  = Color(0xFF9C0AA6);
  static const Color generalDarkBg  = Color(0xFF4FADAE);

  // ── LIGHT FOLDER COLOUR-LEAK BG TINTS ─────────────────────────────────────
  static const Color tasksLightBg    = Color(0xFFF0F0FF);
  static const Color remindersLightBg = Color(0xFFFFF0F8);
  static const Color ideasLightBg    = Color(0xFFFDF8F0);
  static const Color followUpLightBg = Color(0xFFFEFFA6);
  static const Color journalLightBg  = Color(0xFFF5F0FF);
  static const Color generalLightBg  = Color(0xFFF4F5F8);

  // ── BACKGROUND MESH NODES ──────────────────────────────────────────────────
  static const List<Color> darkMesh = [
    Color(0xFF090F1A),
    Color(0xFF10223D),
    Color(0xFF0A2D2D),
    Color(0xFF1A1636),
    Color(0xFF2A1E3D),
  ];
  static const List<Color> lightMesh = [
    Color(0xFFF0F4F9),
    Color(0xFFE4EEFF),
    Color(0xFFDDF6F4),
    Color(0xFFEDE8FF),
    Color(0xFFF7F4FF),
  ];
}