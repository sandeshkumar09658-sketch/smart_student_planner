import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [
            isDark ? AppColors.glassDark : AppColors.glassLight,
            isDark ? AppColors.cardDark : AppColors.cardLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          width: 1.5,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius as BorderRadius? ?? BorderRadius.circular(24),
                onTap: onTap,
                child: child,
              ),
            )
          : child,
    );
  }
}
