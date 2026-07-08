import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../widgets/manual_play_button.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  // ─── Existing state ─────────────────────────────────────────────────────────
  bool _isManualMode = true;
  bool _wiperOn = false;
  bool _pumpOn = false;
  bool _schedule07 = true;
  bool _schedule18 = true;
  bool _isCleaning = false;

  void _startCleaning() {
    setState(() => _isCleaning = true);
    // Existing logic: show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembersihan Manual Dimulai...')),
    );
  }

  void _stopCleaning() {
    setState(() => _isCleaning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembersihan Dihentikan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ─── Mode Selection ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildModeSelector()),
            ),

            // ─── Manual Controls ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildManualControls()),
            ),

            // ─── Device Status ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildDeviceStatus()),
            ),

            // ─── RTC Schedule ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 120),
              sliver: SliverToBoxAdapter(child: _buildSchedule()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cleaning',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Mode Pembersihan Panel',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Mode Pembersihan'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _ModeChip(
                label: 'Manual',
                selected: _isManualMode,
                onTap: () => setState(() => _isManualMode = true),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ModeChip(
                label: 'Auto (Terjadwal RTC)',
                selected: !_isManualMode,
                onTap: () => setState(() => _isManualMode = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualControls() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Kontrol Manual'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ManualPlayButton(
                  onTap: _isManualMode && !_isCleaning ? _startCleaning : null,
                  isActive: _isCleaning,
                  isStart: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ManualPlayButton(
                  onTap: _isCleaning ? _stopCleaning : null,
                  isActive: _isCleaning,
                  isStart: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatus() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Status Perangkat'),
          const SizedBox(height: AppSpacing.sm),
          _DeviceToggleRow(
            icon: LucideIcons.brush,
            label: 'Wiper (Motor Power Window)',
            value: _wiperOn,
            onChanged: (v) => setState(() => _wiperOn = v),
            iconColor: AppColors.tempWater,
          ),
          const Divider(height: 16),
          _DeviceToggleRow(
            icon: LucideIcons.droplets,
            label: 'Pompa Pembersih (Water Pump)',
            value: _pumpOn,
            onChanged: (v) => setState(() => _pumpOn = v),
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Jadwal Pembersihan (RTC)'),
          const SizedBox(height: AppSpacing.sm),
          _ScheduleRow(
            time: '07:00',
            value: _schedule07,
            onChanged: (v) => setState(() => _schedule07 = v),
          ),
          const Divider(height: 16),
          _ScheduleRow(
            time: '18:00',
            value: _schedule18,
            onChanged: (v) => setState(() => _schedule18 = v),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  const _DeviceToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: AppRadius.sm,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: AppStatusChip(
                  key: ValueKey(value),
                  label: value ? 'ON' : 'OFF',
                  variant:
                      value ? AppChipVariant.success : AppChipVariant.neutral,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String time;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ScheduleRow({
    required this.time,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.sm,
          ),
          child: const Icon(LucideIcons.clock,
              color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}
