import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum AppBtnVariant { primary, outline, danger, success, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppBtnVariant variant;
  final bool loading;
  final bool fullWidth;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppBtnVariant.primary,
    this.loading = false,
    this.fullWidth = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? _baseColor();
    final isOutlineOrGhost =
        variant == AppBtnVariant.outline || variant == AppBtnVariant.ghost;

    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: isOutlineOrGhost ? base : Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isOutlineOrGhost ? base : Colors.white,
                ),
              ),
            ],
          );

    final btn = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: isOutlineOrGhost ? null : AppGradients.of(base),
        color: variant == AppBtnVariant.ghost ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: variant == AppBtnVariant.outline
            ? Border.all(color: base, width: 1.5)
            : null,
        boxShadow: isOutlineOrGhost ? null : AppShadow.colored(base),
      ),
      child: child,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: loading ? null : onPressed,
        child: btn,
      ),
    );
  }

  Color _baseColor() {
    switch (variant) {
      case AppBtnVariant.danger:
        return AppColors.danger;
      case AppBtnVariant.success:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}
