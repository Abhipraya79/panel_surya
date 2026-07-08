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
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _setpointTemp = 42;

  // ─── Existing logout logic — preserved ─────────────────────────────────────
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
            child: Text('Ya, Keluar',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showEditSetpointDialog(BuildContext context) {
    final controller = TextEditingController(text: _setpointTemp.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Setpoint Suhu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentukan batas suhu panel untuk memicu pendinginan otomatis:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Contoh: 42',
                suffixText: '°C',
                suffixStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                setState(() => _setpointTemp = val);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
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
            // ─── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ─── WiFi Section ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildSettingsTile(
                icon: LucideIcons.wifi,
                label: 'WiFi',
                value: 'SOLARCARE_24GHz',
                iconColor: AppColors.info,
                iconBg: AppColors.infoLight,
                onTap: () {},
              )),
            ),

            // ─── ESP32 ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildSettingsTile(
                icon: LucideIcons.cpu,
                label: 'Perangkat (ESP32)',
                value: 'Online',
                valueVariant: AppChipVariant.success,
                iconColor: AppColors.success,
                iconBg: AppColors.successLight,
                onTap: () {},
              )),
            ),

            // ─── Temp Setpoint ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildSettingsTile(
                icon: LucideIcons.thermometer,
                label: 'Setpoint Suhu Panel (Editing)',
                value: '$_setpointTemp °C',
                iconColor: AppColors.tempPanel,
                iconBg: AppColors.tempPanel.withOpacity(0.12),
                onTap: () => _showEditSetpointDialog(context),
              )),
            ),

            // ─── System Info ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionTitle(title: 'Informasi Sistem'),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Versi Aplikasi', value: '1.0.0'),
                          const Divider(height: 20),
                          _InfoRow(
                              label: 'Versi Firmware ESP32', value: '1.0.0'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── About ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(child: _buildAboutTile(context)),
            ),

            // ─── Logout Button ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg, AppSpacing.md, 120),
              sliver: SliverToBoxAdapter(
                child: AppButton.outline(
                  label: 'Logout',
                  icon: LucideIcons.logOut,
                  onPressed: () => _handleLogout(context),
                ),
              ),
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
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Konfigurasi sistem',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
    AppChipVariant? valueVariant,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lg,
          boxShadow: AppShadows.subtle,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.md,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (valueVariant != null)
              AppStatusChip(label: value, variant: valueVariant)
            else
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAboutSheet(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lg,
          boxShadow: AppShadows.subtle,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.md,
              ),
              child: const Icon(LucideIcons.info,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tentang Sistem',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AboutBottomSheet(),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AboutBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.topOnly(24),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: AppRadius.pill,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: AppRadius.lg,
            ),
            child: const Icon(LucideIcons.sun,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Panel Care',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Versi 1.0.0',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sistem Pendinginan dan Pembersihan Panel Surya Berbasis Internet of Things',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Dibuat oleh', value: 'Hayatun Nufus'),
          const SizedBox(height: 8),
          _InfoRow(
              label: 'Institusi',
              value: 'Politeknik Perkapalan Negeri Surabaya'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Tahun', value: '2026'),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
