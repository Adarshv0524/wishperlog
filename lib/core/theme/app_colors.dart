import 'package:flutter/material.dart';

// Generated from WhisperLog Design System v2.1
// DO NOT add colour literals anywhere else in the codebase.
abstract class AppColors {
  // DARK GLASS SURFACES
  static const Color darkBg = Color(0xFF08080F);
  static const Color darkGlass1 = Color(0x26FFFFFF);
  static const Color darkGlass2 = Color(0x1AFFFFFF);
  static const Color darkGlass3 = Color(0x0DFFFFFF);
  static const Color darkTextPri = Color(0xFFD8CFF0);
  static const Color darkTextSec = Color(0xFF7A7598);
  static const Color darkTextTer = Color(0xFF58AC72);
  static const Color darkBorder = Color(0x23FFFFFF);

  // LIGHT GLASS SURFACES
  static const Color lightBg = Color(0xFFEEEAFB);
  static const Color lightGlass1 = Color(0xD9FFFFFF);
  static const Color lightGlass2 = Color(0xA6FFFFFF);
  static const Color lightGlass3 = Color(0x80FFFFFF);
  static const Color lightTextPri = Color(0xFF1A1530);
  static const Color lightTextSec = Color(0xFF4B6590);
  static const Color lightTextTer = Color(0xFF9B97BB);
  static const Color lightBorder = Color(0x1A000000);

  // CATEGORY CHROMATICS
  static const Color tasks = Color(0xFF6045FA);
  static const Color reminders = Color(0xFFF472B6);
  static const Color ideas = Color(0xFFFBBF24);
  static const Color followUp = Color(0xFF34D399);
  static const Color journal = Color(0xFFA78BFA);
  static const Color general = Color(0xFF94A3B8);
  static const Color errorStatus = Color(0xFFEF4444);

  // DARK FOLDER COLOUR-LEAK BG TINTS
  static const Color tasksDarkBg = Color(0xFF060DD1);
  static const Color remindersDarkBg = Color(0xFFF04010);
  static const Color ideasDarkBg = Color(0xFFF0CF86);
  static const Color followUpDarkBg = Color(0xFF866F0C);
  static const Color journalDarkBg = Color(0xFF9C0AA6);
  static const Color generalDarkBg = Color(0xFF4FADAE);

  // LIGHT FOLDER COLOUR-LEAK BG TINTS
  static const Color tasksLightBg = Color(0xFFF0F0FF);
  static const Color remindersLightBg = Color(0xFFFFF0F8);
  static const Color ideasLightBg = Color(0xFFFDF8F0);
  static const Color followUpLightBg = Color(0xFFFEFFA6);
  static const Color journalLightBg = Color(0xFFF5F0FF);
  static const Color generalLightBg = Color(0xFFF4F5F8);

  // BACKGROUND MESH NODES
  static const List<Color> darkMesh = [
    Color(0xFF08080F),
    Color(0xFF1B0A3E),
    Color(0xFF061A1A),
    Color(0xFF0D0D1F),
    Color(0xFF1A0A1E),
  ];
  static const List<Color> lightMesh = [
    Color(0xFFEEEAFB),
    Color(0xFFE0D8FA),
    Color(0xFFD8EEF0),
    Color(0xFFEAE0F8),
    Color(0xFFF5F0FF),
  ];
}
