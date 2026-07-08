import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_shadows.dart';
import 'app_status_chip.dart';

/// Premium sensor metric card — displays icon, name, value, unit, and status.
class AppMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? status;
  final AppChipVariant statusVariant;
  final String? trend;
  final bool isCompact;

  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.status,
    this.statusVariant = AppChipVariant.info,
    this.trend,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.card,
        border: Border.all(
            color: AppColors.border.withOpacity(0.5), width: 0.5),
      ),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, color: iconColor, size: isCompact ? 16 : 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null)
                Icon(
                  trend == 'up'
                      ? LucideIcons.trendingUp
                      : trend == 'down'
                          ? LucideIcons.trendingDown
                          : LucideIcons.minus,
                  size: 16,
                  color: trend == 'up'
                      ? AppColors.danger
                      : trend == 'down'
                          ? AppColors.success
                          : AppColors.textHint,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 20 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 10 : 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (status != null) ...[
            const SizedBox(height: 8),
            AppStatusChip(label: status!, variant: statusVariant),
          ],
        ],
      ),
    );
  }
}
