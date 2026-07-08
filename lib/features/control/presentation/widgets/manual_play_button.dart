import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';

/// Redesigned Start/Stop cleaning button with colored state variants.
class ManualPlayButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;
  final bool isStart;

  const ManualPlayButton({
    super.key,
    required this.onTap,
    this.isActive = false,
    this.isStart = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final bg = isStart ? AppColors.success : AppColors.danger;
    final label = isStart ? 'Start Cleaning' : 'Stop Cleaning';
    final icon =
        isStart ? Icons.play_arrow_rounded : Icons.stop_rounded;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.lg,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: bg.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
