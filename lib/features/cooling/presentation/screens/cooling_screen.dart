import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/state/app_state.dart';

class CoolingScreen extends StatefulWidget {
  const CoolingScreen({super.key});

  @override
  State<CoolingScreen> createState() => _CoolingScreenState();
}

class _CoolingScreenState extends State<CoolingScreen> {
  late bool _peltierOn;
  late bool _fanOn;

  @override
  void initState() {
    super.initState();
    _peltierOn = AppState.instance.peltierOn;
    _fanOn = AppState.instance.fanOn;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cooling',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Sistem Pendinginan Panel',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Temperature Info Cards ──────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildTempSection()),
            ),

            // ─── Cooling Controls ─────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildCoolingControls()),
            ),

            // ─── Pump Status ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildPumpStatus()),
            ),

            // ─── Info note ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 120),
              sliver: SliverToBoxAdapter(child: _buildInfoNote()),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Temperature Section ─────────────────────────────────────────────────
  Widget _buildTempSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(title: 'Informasi Suhu'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TempDisplayCard(
                label: 'Suhu Panel',
                value: '41.8',
                unit: '°C',
                icon: LucideIcons.thermometer,
                iconColor: AppColors.tempPanel,
                status: 'Optimal',
                statusVariant: AppChipVariant.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TempDisplayCard(
                label: 'Suhu Air',
                value: '24.6',
                unit: '°C',
                icon: LucideIcons.droplet,
                iconColor: AppColors.tempWater,
                status: 'Dingin',
                statusVariant: AppChipVariant.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Cooling Controls ────────────────────────────────────────────────────
  Widget _buildCoolingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(title: 'Kontrol Pendinginan'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Peltier toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tempWater.withOpacity(0.12),
                      borderRadius: AppRadius.md,
                    ),
                    child: Icon(LucideIcons.snowflake,
                        color: AppColors.tempWater, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peltier (Pendingin Air)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: AppStatusChip(
                            key: ValueKey(_peltierOn),
                            label: _peltierOn ? 'ON' : 'OFF',
                            variant: _peltierOn
                                ? AppChipVariant.success
                                : AppChipVariant.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _peltierOn,
                    onChanged: (v) => setState(() {
                      _peltierOn = v;
                      AppState.instance.peltierOn = v;
                    }),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Peltier akan mendinginkan air di dalam tangki.\nFan akan menyala mengikuti status Peltier.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),

              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              // Fan toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.12),
                      borderRadius: AppRadius.md,
                    ),
                    child: Icon(LucideIcons.wind,
                        color: AppColors.info, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: AppStatusChip(
                            key: ValueKey(_fanOn),
                            label: _fanOn ? 'ON' : 'OFF',
                            variant: _fanOn
                                ? AppChipVariant.success
                                : AppChipVariant.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _fanOn,
                    onChanged: (v) => setState(() {
                      _fanOn = v;
                      AppState.instance.fanOn = v;
                    }),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Pump Status Card ────────────────────────────────────────────────────
  Widget _buildPumpStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(title: 'Pompa Pendingin (Water Pump)'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: AppRadius.md,
                ),
                child:
                    const Icon(LucideIcons.droplets, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const AppStatusChip(
                      label: 'RUNNING',
                      variant: AppChipVariant.success,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PWM',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '72 %',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Info Note ───────────────────────────────────────────────────────────
  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info,
              color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sistem pendinginan otomatis menjaga suhu panel tetap optimal.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.info,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Temperature Display Card ─────────────────────────────────────────────────

class _TempDisplayCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final String status;
  final AppChipVariant statusVariant;

  const _TempDisplayCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.statusVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: unit,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          AppStatusChip(label: status, variant: statusVariant),
        ],
      ),
    );
  }
}
