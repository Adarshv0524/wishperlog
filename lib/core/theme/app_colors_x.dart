import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/shared/models/enums.dart';

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get glass1 => isDark ? AppColors.darkGlass1 : AppColors.lightGlass1;
  Color get glass2 => isDark ? AppColors.darkGlass2 : AppColors.lightGlass2;
  Color get glass3 => isDark ? AppColors.darkGlass3 : AppColors.lightGlass3;
  Color get textPri => isDark ? AppColors.darkTextPri : AppColors.lightTextPri;
  Color get textSec => isDark ? AppColors.darkTextSec : AppColors.lightTextSec;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get surface1 => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7);
  Color get surface2 => isDark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF);
  List<Color> get meshNodes =>
      isDark ? AppColors.darkMesh : AppColors.lightMesh;
}

Color categoryColor(NoteCategory cat) => switch (cat) {
  NoteCategory.tasks => AppColors.tasks,
  NoteCategory.reminders => AppColors.reminders,
  NoteCategory.ideas => AppColors.ideas,
  NoteCategory.followUp => AppColors.followUp,
  NoteCategory.journal => AppColors.journal,
  NoteCategory.general => AppColors.general,
};

Color categoryFolderBg(NoteCategory cat, bool isDark) => isDark
    ? switch (cat) {
        NoteCategory.tasks => AppColors.tasksDarkBg,
        NoteCategory.reminders => AppColors.remindersDarkBg,
        NoteCategory.ideas => AppColors.ideasDarkBg,
        NoteCategory.followUp => AppColors.followUpDarkBg,
        NoteCategory.journal => AppColors.journalDarkBg,
        NoteCategory.general => AppColors.generalDarkBg,
      }
    : switch (cat) {
        NoteCategory.tasks => AppColors.tasksLightBg,
        NoteCategory.reminders => AppColors.remindersLightBg,
        NoteCategory.ideas => AppColors.ideasLightBg,
        NoteCategory.followUp => AppColors.followUpLightBg,
        NoteCategory.journal => AppColors.journalLightBg,
        NoteCategory.general => AppColors.generalLightBg,
      };
