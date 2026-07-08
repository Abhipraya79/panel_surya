import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

/// Semantic status pill chip — adapts color based on variant.
class AppStatusChip extends StatelessWidget {
  final String label;
  final AppChipVariant variant;
  final bool dot;

  const AppStatusChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.info,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                borderRadius: AppRadius.pill,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg) get _colors => switch (variant) {
        AppChipVariant.success => (AppColors.successLight, AppColors.success),
        AppChipVariant.warning => (AppColors.warningLight, Color(0xFFE65100)),
        AppChipVariant.danger => (AppColors.dangerLight, AppColors.danger),
        AppChipVariant.info => (AppColors.infoLight, AppColors.info),
        AppChipVariant.primary =>
          (AppColors.primaryContainer, AppColors.primary),
        AppChipVariant.neutral =>
          (AppColors.divider, AppColors.textSecondary),
      };
}

enum AppChipVariant { success, warning, danger, info, primary, neutral }
