import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';

enum NotifType { success, warning, danger, info }

/// Timeline-style notification card with type-based color and icon.
class HistoryItemCard extends StatelessWidget {
  final String time;
  final String title;
  final String body;
  final NotifType type;

  const HistoryItemCard({
    super.key,
    this.time = '00:00:00',
    this.title = 'Pembersihan Manual',
    this.body = 'Selesai pada 08:30',
    this.type = NotifType.success,
  });

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = _typeProps;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // ─── Color indicator bar ────────────────────────────────────
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          // ─── Icon ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ),

          // ─── Text content ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Timestamp ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) get _typeProps => switch (type) {
        NotifType.success => (
            AppColors.success,
            AppColors.successLight,
            LucideIcons.checkCircle2
          ),
        NotifType.warning => (
            AppColors.warning,
            AppColors.warningLight,
            LucideIcons.alertTriangle
          ),
        NotifType.danger => (
            AppColors.danger,
            AppColors.dangerLight,
            LucideIcons.alertOctagon
          ),
        NotifType.info => (
            AppColors.info,
            AppColors.infoLight,
            LucideIcons.info
          ),
      };
}
