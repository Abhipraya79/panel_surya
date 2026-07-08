import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';

/// Redesigned sensor progress bar — now an actuator status tile.
class SensorProgressBar extends StatelessWidget {
  final IconData icon;
  final double progress;

  const SensorProgressBar({
    super.key,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    if (icon == LucideIcons.thermometer) return 'Suhu Panel';
    if (icon == LucideIcons.wind) return 'Debu';
    if (icon == LucideIcons.zap) return 'Tegangan';
    if (icon == LucideIcons.activity) return 'Arus';
    return 'Sensor';
  }

  Color get _progressColor {
    if (progress < 0.4) return AppColors.success;
    if (progress < 0.75) return AppColors.warning;
    return AppColors.danger;
  }
}
