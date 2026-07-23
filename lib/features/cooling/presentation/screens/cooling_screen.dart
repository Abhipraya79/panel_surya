import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/utils/sensor_formatter.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/socket/socket_service.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/data/models/dashboard_model.dart';

class CoolingScreen extends StatefulWidget {
  const CoolingScreen({super.key});

  @override
  State<CoolingScreen> createState() => _CoolingScreenState();
}

enum CoolingState { idle, running }

class _CoolingScreenState extends State<CoolingScreen> {
  bool _isActionLoading = false;
  CoolingState _coolingState = CoolingState.idle;

  StreamSubscription<Map<String, dynamic>>? _coolingSub;

  @override
  void initState() {
    super.initState();
    // Restore from AppState
    _coolingState =
        AppState.instance.isCooling ? CoolingState.running : CoolingState.idle;

    // Listen to Socket.IO cooling:status events
    _coolingSub = SocketService.instance.coolingStream.listen((payload) {
      if (!mounted) return;
      final isCooling = payload['isCooling'] as bool? ?? false;
      final peltier = payload['peltier'] as bool? ?? false;
      final fan = payload['fan'] as bool? ?? false;

      setState(() {
        _coolingState = isCooling ? CoolingState.running : CoolingState.idle;
        AppState.instance.isCooling = isCooling;
        AppState.instance.peltierOn = peltier;
        AppState.instance.fanOn = fan;
      });
    });
  }

  @override
  void dispose() {
    _coolingSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleCooling(bool start) async {
    setState(() {
      _isActionLoading = true;
    });

    final action = start ? 'START' : 'STOP';
    final uri = Uri.parse('${AppConfig.baseUrl}/control/cooling');
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({'action': action});

    try {
      debugPrint('[API REQUEST] POST $uri');
      final response = await http
          .post(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      debugPrint('[API RESPONSE] POST $uri - Code ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _coolingState = start ? CoolingState.running : CoolingState.idle;
          _isActionLoading = false;
          AppState.instance.isCooling = start;
          AppState.instance.peltierOn = start;
          AppState.instance.fanOn = start;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                start ? 'Pendinginan Dimulai...' : 'Pendinginan Dihentikan'),
            backgroundColor: start ? AppColors.success : AppColors.primary,
          ),
        );
      } else {
        String serverMessage = 'Pendinginan gagal dijalankan.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('message')) {
            serverMessage = body['message'].toString();
          }
        } catch (_) {}

        String errorDisplay;
        switch (response.statusCode) {
          case 400:
            errorDisplay = 'Validasi Gagal (400): $serverMessage';
            break;
          case 401:
            errorDisplay = 'Akses Ditolak (401): Silakan login kembali.';
            break;
          case 403:
            errorDisplay =
                'Akses Dilarang (403): Anda tidak memiliki izin untuk melakukan aksi ini.';
            break;
          case 404:
            errorDisplay =
                'Tidak Ditemukan (404): Endpoint kontrol tidak tersedia.';
            break;
          case 422:
            errorDisplay = 'Data Tidak Valid (422): $serverMessage';
            break;
          case 500:
            errorDisplay = 'Kesalahan Server (500): $serverMessage';
            break;
          default:
            errorDisplay =
                'Kesalahan (${response.statusCode}): $serverMessage';
        }

        setState(() {
          _isActionLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDisplay),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[API ERROR] POST $uri - Exception $e');
      debugPrint('[FLUTTER] Stacktrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isActionLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kesalahan Koneksi: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final data = provider.data;
        final isOnline = data?.isOnline ?? false;
        final isCoolingRunning = _coolingState == CoolingState.running;

        return Material(
          color: AppColors.background,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Header ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                    child: Row(
                      children: [
                        Expanded(
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
                        // Connection Status Badge
                        AppStatusChip(
                          label: isOnline ? 'ONLINE' : 'OFFLINE',
                          variant: isOnline
                              ? AppChipVariant.success
                              : AppChipVariant.danger,
                          dot: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Temperature Info Cards ──────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(child: _buildTempSection(data)),
                ),

                // ─── Device Status Card ─────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                      child: _buildDeviceStatus(isCoolingRunning)),
                ),

                // ─── Cooling Control Card ────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildCoolingControl(isOnline, isCoolingRunning),
                  ),
                ),

                // ─── Info Note ───────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 120),
                  sliver: SliverToBoxAdapter(child: _buildInfoNote()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Temperature Section ─────────────────────────────────────────────────
  Widget _buildTempSection(DashboardModel? data) {
    final panelTempStr = SensorFormatter.format(data?.temperature);
    final waterTempStr = SensorFormatter.format(data?.airTemp);

    return Row(
      children: [
        Expanded(
          child: _TempDisplayCard(
            label: 'Suhu Panel',
            value: panelTempStr,
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
            value: waterTempStr,
            unit: '°C',
            icon: Icons.water_drop,
            iconColor: AppColors.tempWater,
            status: 'Air',
            statusVariant: AppChipVariant.info,
          ),
        ),
      ],
    );
  }

  // ─── Device Status Card ──────────────────────────────────────────────────
  Widget _buildDeviceStatus(bool isCoolingRunning) {
    final peltierActive = isCoolingRunning;
    final fanActive = isCoolingRunning;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  LucideIcons.activity,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Device Status',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Peltier Status Row
          _buildStatusRow(
            icon: LucideIcons.snowflake,
            iconColor: AppColors.tempWater,
            label: 'Peltier',
            isActive: peltierActive,
            activeLabel: 'Peltier Active',
            idleLabel: 'Peltier Idle',
          ),
          const Divider(height: 24, color: AppColors.divider),

          // Fan Status Row
          _buildStatusRow(
            icon: LucideIcons.wind,
            iconColor: AppColors.info,
            label: 'Fan',
            isActive: fanActive,
            activeLabel: 'Fan Active',
            idleLabel: 'Fan Idle',
          ),
        ],
      ),
    );
  }

  // ─── Cooling Control Card ────────────────────────────────────────────────
  Widget _buildCoolingControl(bool isDeviceOnline, bool isRunning) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  LucideIcons.power,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cooling Water Control',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aktifkan atau nonaktifkan sistem pendinginan panel surya.\nPeltier dan Fan akan bekerja bersamaan.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Main button
          _buildMainButton(isDeviceOnline, isRunning),
        ],
      ),
    );
  }

  Widget _buildMainButton(bool isDeviceOnline, bool isRunning) {
    final isEnabled = isDeviceOnline && !_isActionLoading;
    final btnColor = isRunning ? AppColors.danger : AppColors.success;
    final labelText = isRunning ? 'STOP COOLING' : 'START COOLING';
    final btnIcon = isRunning ? LucideIcons.square : LucideIcons.play;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: isEnabled ? () => _toggleCooling(!isRunning) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: 52,
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: AppRadius.lg,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: btnColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: _isActionLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(btnIcon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        labelText,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Status Row (read-only indicator) ────────────────────────────────────
  Widget _buildStatusRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isActive,
    required String activeLabel,
    required String idleLabel,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
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
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey<bool>(isActive),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isActive
                        ? const _PulseDot(color: AppColors.success)
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.danger,
                            ),
                          ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? activeLabel : idleLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ],
                ),
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
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ketika cooling aktif, Peltier akan mendinginkan air di tangki '
              'dan Fan akan membuang panas radiator secara bersamaan. '
              'Sistem pendinginan menjaga suhu panel tetap optimal.',
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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

// ─── Pulsating Dot Animation ──────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: 0.4 * _animation.value),
                blurRadius: 6,
                spreadRadius: 2 * (1.0 - _animation.value),
              )
            ],
          ),
        );
      },
    );
  }
}
