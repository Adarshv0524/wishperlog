import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class GlassTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassTitleBar({
    required this.title,
    required this.onBack,
    super.key,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: GlassPane(
          level: 1,
          radius: 22,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          tintOverride: context.isDark
              ? const Color(0x6610243F)
              : const Color(0xBFEFF7FF),
          child: Row(
            children: [
              _GlassBackButton(onTap: onBack),
              const SizedBox(width: 8),
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDark
                  ? [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.06),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.48),
                    ],
            ),
            border: Border.all(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.22)
                  : const Color(0x1A204268),
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPri,
            size: 18,
          ),
        ),
      ),
    );
  }
}
