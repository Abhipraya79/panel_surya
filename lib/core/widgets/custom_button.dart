import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_shadows.dart';
import '../constants/app_spacing.dart';

/// Reusable premium button for Panel Care.
/// Supports primary, secondary, outline, danger, and ghost variants.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  }) : variant = AppButtonVariant.outline;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  }) : variant = AppButtonVariant.danger;

  const AppButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.padding,
  }) : variant = AppButtonVariant.success;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _PrimaryButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          padding: padding,
        );
      case AppButtonVariant.secondary:
        return _SecondaryButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
        );
      case AppButtonVariant.outline:
        return _OutlineButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
        );
      case AppButtonVariant.danger:
        return _ColorButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          color: AppColors.danger,
        );
      case AppButtonVariant.success:
        return _ColorButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          color: AppColors.success,
        );
    }
  }
}

enum AppButtonVariant { primary, secondary, outline, danger, success }

// ─── Primary Button ────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppColors.heroGradient : null,
        color: onPressed != null ? null : AppColors.divider,
        borderRadius: AppRadius.lg,
        boxShadow: onPressed != null ? AppShadows.button : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lg,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Secondary Button ──────────────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SecondaryButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.lg,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lg,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _OutlineButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lg,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Color Button (danger / success) ──────────────────────────────────────
class _ColorButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color color;

  const _ColorButton({
    required this.label,
    required this.color,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lg,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Button Content ────────────────────────────────────────────────────────
class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color color;

  const _ButtonContent({
    required this.label,
    required this.color,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
