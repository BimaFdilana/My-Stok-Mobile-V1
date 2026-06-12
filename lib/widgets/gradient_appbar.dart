import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// AppBar dengan gradient warna per fitur + judul + subtitle opsional.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color color;
  final List<Widget>? actions;
  final bool showBack;

  const GradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color = AppColors.primary,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 76 : 60);

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.canPop(context);
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.of(color),
        boxShadow: AppShadow.colored(color),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (canPop)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              else if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
