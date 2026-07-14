import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/widgets/app_metric_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../history/presentation/screens/notification_page.dart';
import '../providers/dashboard_provider.dart';
import '../../data/models/dashboard_model.dart';
import '../../../settings/presentation/screens/connection_test_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ─── Existing logout logic — preserved ─────────────────────────────────────
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Ya, Keluar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        // ── Loading State ────────────────────────────────────────────────────
        if (provider.isLoading) {
          return Material(
            color: AppColors.background,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // ── Error State (no data at all) ─────────────────────────────────────
        if (provider.hasError && provider.data == null) {
          return Material(
            color: AppColors.background,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wifiOff,
                        size: 48, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tidak dapat terhubung ke backend',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      provider.errorMessage ?? 'Pastikan backend berjalan dan periksa AppConfig.baseUrl',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md),
                          ),
                          onPressed: () => provider.initialize(),
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: Text(
                            'Coba Lagi',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ConnectionTestScreen(),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.network, size: 16),
                          label: Text(
                            'Uji Koneksi',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Normal / Data State ──────────────────────────────────────────────
        final data = provider.data!;

        return Material(
          color: AppColors.background,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Header ────────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader(context, provider)),

                // ─── Hero System Card ───────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                      child: _buildHeroCard(context, data)),
                ),

                // ─── Monitoring Metrics Grid ────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: AppSectionTitle(
                      title: 'Sensor Monitoring',
                      subtitle: 'Real-time sensor readings',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  sliver:
                      SliverToBoxAdapter(child: _buildMetricsGrid(data)),
                ),

                // ─── Actuator Status ────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: AppSectionTitle(
                      title: 'Status Aktuator',
                      subtitle: 'Device control status',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, 120),
                  sliver:
                      SliverToBoxAdapter(child: _buildActuatorRow(data)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Care',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // ─── Realtime Connection Status Indicator ──────────────────────
          _ConnectionStatusChip(isConnected: provider.isSocketConnected),
          const SizedBox(width: AppSpacing.sm),
          // Notification + Logout icon
          _HeaderIconButton(
            icon: LucideIcons.bell,
            badge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _HeaderIconButton(
            icon: LucideIcons.logOut,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  // ─── Hero System Card ────────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context, DashboardModel data) {
    final w = MediaQuery.of(context).size.width - AppSpacing.md * 2;

    // Format lastUpdate time
    String formattedTime = '--:--:--';
    if (data.lastUpdate.isNotEmpty) {
      try {
        final dt = DateTime.parse(data.lastUpdate).toLocal();
        formattedTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedTime = data.lastUpdate;
      }
    }

    return Container(
      width: w,
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.xl,
        boxShadow: AppShadows.hero,
      ),
      child: Stack(
        children: [
          // Decorative circle bg
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Dynamic device status chip
                    AppStatusChip(
                      label: data.isOnline ? '● Online' : '● Offline',
                      variant: data.isOnline
                          ? AppChipVariant.success
                          : AppChipVariant.danger,
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Terakhir diperbarui',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Status Sistem',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  data.isOnline ? 'Sistem Aktif' : 'Sistem Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  data.isOnline
                      ? 'Semua sensor berjalan normal'
                      : 'Menunggu koneksi perangkat...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2×3 Metrics Grid ────────────────────────────────────────────────────────
  Widget _buildMetricsGrid(DashboardModel data) {
    final metrics = [
      _MetricData(
        title: 'Suhu Panel',
        value: data.temperature.toStringAsFixed(1),
        unit: '°C',
        icon: LucideIcons.thermometer,
        iconColor: AppColors.tempPanel,
        iconBg: AppColors.tempPanel.withOpacity(0.12),
        status: _tempStatus(data.temperature),
        statusVariant: _tempVariant(data.temperature),
        trend: 'up',
      ),
      _MetricData(
        title: 'Kelembaban',
        value: data.humidity.toStringAsFixed(0),
        unit: '%',
        icon: LucideIcons.droplet,
        iconColor: AppColors.tempWater,
        iconBg: AppColors.tempWater.withOpacity(0.12),
        status: _humidityStatus(data.humidity),
        statusVariant: _humidityVariant(data.humidity),
        trend: 'flat',
      ),
      _MetricData(
        title: 'Debu',
        value: data.dust.toStringAsFixed(0),
        unit: 'μg/m³',
        icon: LucideIcons.wind,
        iconColor: AppColors.dustColor,
        iconBg: AppColors.dustColor.withOpacity(0.12),
        status: _dustStatus(data.dust),
        statusVariant: _dustVariant(data.dust),
        trend: 'up',
      ),
      _MetricData(
        title: 'Tegangan',
        value: data.voltage.toStringAsFixed(2),
        unit: 'V',
        icon: LucideIcons.zap,
        iconColor: AppColors.voltageColor,
        iconBg: AppColors.voltageColor.withOpacity(0.12),
        status: 'Normal',
        statusVariant: AppChipVariant.success,
        trend: 'flat',
      ),
      _MetricData(
        title: 'Arus',
        value: data.current.toStringAsFixed(2),
        unit: 'A',
        icon: LucideIcons.activity,
        iconColor: AppColors.currentColor,
        iconBg: AppColors.currentColor.withOpacity(0.12),
        status: 'Normal',
        statusVariant: AppChipVariant.success,
        trend: 'down',
      ),
      _MetricData(
        title: 'Daya',
        value: data.power.toStringAsFixed(1),
        unit: 'W',
        icon: LucideIcons.power,
        iconColor: AppColors.powerColor,
        iconBg: AppColors.powerColor.withOpacity(0.12),
        status: 'Optimal',
        statusVariant: AppChipVariant.success,
        trend: 'flat',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.3,
      ),
      itemCount: metrics.length,
      itemBuilder: (_, i) {
        final m = metrics[i];
        return AppMetricCard(
          title: m.title,
          value: m.value,
          unit: m.unit,
          icon: m.icon,
          iconColor: m.iconColor,
          iconBgColor: m.iconBg,
          status: m.status,
          statusVariant: m.statusVariant,
          trend: m.trend,
        );
      },
    );
  }

  // ─── Actuator Status Row ──────────────────────────────────────────────────────
  Widget _buildActuatorRow(DashboardModel data) {
    final actuators = [
      _ActuatorData('Peltier', LucideIcons.snowflake, true,
          AppColors.tempWater, AppChipVariant.success),
      _ActuatorData('Fan', LucideIcons.wind, true,
          AppColors.info, AppChipVariant.success),
      _ActuatorData(
        'Pompa Pembersih',
        LucideIcons.droplets,
        data.pumpStatus,
        data.pumpStatus ? AppColors.tempWater : AppColors.textSecondary,
        data.pumpStatus ? AppChipVariant.success : AppChipVariant.neutral,
      ),
      _ActuatorData(
        'Wiper',
        LucideIcons.brush,
        data.wiperStatus,
        data.wiperStatus ? AppColors.info : AppColors.textSecondary,
        data.wiperStatus ? AppChipVariant.success : AppChipVariant.neutral,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.8,
      ),
      itemCount: actuators.length,
      itemBuilder: (_, i) => _ActuatorCard(data: actuators[i]),
    );
  }

  // ─── Status label helpers ─────────────────────────────────────────────────────

  String _tempStatus(double t) {
    if (t < 30) return 'Dingin';
    if (t < 45) return 'Optimal';
    return 'Panas';
  }

  AppChipVariant _tempVariant(double t) {
    if (t < 30) return AppChipVariant.info;
    if (t < 45) return AppChipVariant.success;
    return AppChipVariant.danger;
  }

  String _humidityStatus(double h) {
    if (h < 40) return 'Rendah';
    if (h < 80) return 'Normal';
    return 'Tinggi';
  }

  AppChipVariant _humidityVariant(double h) {
    if (h < 40) return AppChipVariant.warning;
    if (h < 80) return AppChipVariant.success;
    return AppChipVariant.info;
  }

  String _dustStatus(double d) {
    if (d < 50) return 'Bersih';
    if (d < 100) return 'Sedang';
    return 'Kotor';
  }

  AppChipVariant _dustVariant(double d) {
    if (d < 50) return AppChipVariant.success;
    if (d < 100) return AppChipVariant.warning;
    return AppChipVariant.danger;
  }
}

// ─── Connection Status Chip ───────────────────────────────────────────────────

class _ConnectionStatusChip extends StatelessWidget {
  final bool isConnected;
  const _ConnectionStatusChip({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.success.withOpacity(0.12)
            : AppColors.danger.withOpacity(0.12),
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: isConnected
              ? AppColors.success.withOpacity(0.3)
              : AppColors.danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isConnected ? AppColors.success : AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Realtime' : 'Disconnected',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isConnected ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActuatorCard extends StatelessWidget {
  final _ActuatorData data;
  const _ActuatorCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, color: data.color, size: 18),
              const Spacer(),
              AppStatusChip(
                label: data.isOn ? 'ON' : 'OFF',
                variant: data.variant,
              ),
            ],
          ),
          Text(
            data.name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _MetricData {
  final String title, value, unit, status;
  final IconData icon;
  final Color iconColor, iconBg;
  final AppChipVariant statusVariant;
  final String? trend;

  const _MetricData({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.status,
    required this.statusVariant,
    this.trend,
  });
}

class _ActuatorData {
  final String name;
  final IconData icon;
  final bool isOn;
  final Color color;
  final AppChipVariant variant;

  const _ActuatorData(
      this.name, this.icon, this.isOn, this.color, this.variant);
}
