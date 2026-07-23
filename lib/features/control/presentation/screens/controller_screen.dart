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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/socket/socket_service.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

enum CleaningState { idle, running, completed }

class _ControllerScreenState extends State<ControllerScreen> {
  bool _isActionLoading = false;
  bool _isModeLoading = false;

  // CleaningState is driven by ESP feedback through Socket.IO cleaning:status event.
  // idle → user can press START
  // running → waiting for ESP to finish, button disabled
  // completed → briefly shows completion, then resets to idle
  CleaningState _cleaningState = CleaningState.idle;

  StreamSubscription<Map<String, dynamic>>? _cleaningStatusSub;
  StreamSubscription<Map<String, dynamic>>? _eventSub;
  StreamSubscription<Map<String, dynamic>>? _telemetrySub;

  @override
  void initState() {
    super.initState();
    // 1. Listen to cleaning:update events from backend (triggered by ESP feedback)
    _cleaningStatusSub = SocketService.instance.cleaningStatusStream.listen((payload) {
      final status = payload['status'];
      if ((status == 'idle' || status == 'completed') && mounted) {
        setState(() {
          _cleaningState = CleaningState.idle;
          _isActionLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembersihan selesai.'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else if (status == 'running' && mounted) {
        setState(() {
          _cleaningState = CleaningState.running;
        });
      }
    });

    // 2. Listen to event:new events from backend (triggered when ESP sends payload to solar/panel/event)
    _eventSub = SocketService.instance.eventStream.listen((payload) {
      final eventName = (payload['event'] as String?)?.toLowerCase() ?? '';
      if ((eventName.contains('cleaning finished') ||
           eventName.contains('cleaning completed') ||
           eventName.contains('pembersihan selesai') ||
           eventName.contains('motor stopped')) && mounted) {
        setState(() {
          _cleaningState = CleaningState.idle;
          _isActionLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembersihan selesai. Motor telah berhenti.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    // 3. Listen to telemetry:update to auto-reset button if wiper/pump is stopped on ESP
    _telemetrySub = SocketService.instance.telemetryStream.listen((payload) {
      final wiperStatus = payload['wiperStatus'] as bool?;
      final pumpStatus = payload['pumpStatus'] as bool?;
      if (wiperStatus == false && pumpStatus == false && _cleaningState == CleaningState.running && mounted) {
        setState(() {
          _cleaningState = CleaningState.idle;
          _isActionLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _cleaningStatusSub?.cancel();
    _eventSub?.cancel();
    _telemetrySub?.cancel();
    super.dispose();
  }

  Future<void> _startCleaning() async {
    setState(() {
      _isActionLoading = true;
    });

    final uri = Uri.parse('${AppConfig.baseUrl}/control/cleaning');
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({
      'action': 'START',
      'mode': 'MANUAL',
    });

    try {
      debugPrint('[API REQUEST] POST $uri');
      final response = await http.post(
        uri,
        headers: headers,
        body: requestBody,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      debugPrint('[API RESPONSE] POST $uri - Code ${response.statusCode}');

      if (response.statusCode == 200) {
        // START success: set CleaningState to RUNNING
        // Button will remain disabled until ESP sends feedback via Socket.IO
        setState(() {
          _cleaningState = CleaningState.running;
          _isActionLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembersihan Manual Dimulai...'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Parse error message if available
        String serverMessage = 'Pembersihan gagal dijalankan.';
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
            errorDisplay = 'Akses Dilarang (403): Anda tidak memiliki izin untuk melakukan aksi ini.';
            break;
          case 404:
            errorDisplay = 'Tidak Ditemukan (404): Endpoint kontrol tidak tersedia.';
            break;
          case 422:
            errorDisplay = 'Data Tidak Valid (422): $serverMessage';
            break;
          case 500:
            errorDisplay = 'Kesalahan Server (500): $serverMessage';
            break;
          default:
            errorDisplay = 'Kesalahan (${response.statusCode}): $serverMessage';
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

  Future<void> _changeMode(String mode) async {
    setState(() {
      _isModeLoading = true;
    });

    final uri = Uri.parse('${AppConfig.baseUrl}/control/mode');

    try {
      debugPrint('[API REQUEST] POST $uri');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mode': mode, 'deviceId': 'panel001'}),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      debugPrint('[API RESPONSE] POST $uri - Code ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _isModeLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mode pembersihan berhasil diubah ke $mode'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception('Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[API ERROR] POST $uri - Exception $e');
      if (!mounted) return;

      setState(() {
        _isModeLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah mode pembersihan.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Map<String, String> _getScheduleTimes() {
    final now = DateTime.now();
    final today07 = DateTime(now.year, now.month, now.day, 7, 0);
    final today18 = DateTime(now.year, now.month, now.day, 18, 0);

    String lastCleaning = '';
    String nextCleaning = '';

    if (now.isBefore(today07)) {
      final yesterday18 = today18.subtract(const Duration(days: 1));
      lastCleaning = 'Yesterday 18:00';
      nextCleaning = 'Today 07:00';
    } else if (now.isBefore(today18)) {
      lastCleaning = 'Today 07:00';
      nextCleaning = 'Today 18:00';
    } else {
      final tomorrow07 = today07.add(const Duration(days: 1));
      lastCleaning = 'Today 18:00';
      nextCleaning = 'Tomorrow 07:00';
    }

    return {
      'last': lastCleaning,
      'next': nextCleaning,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final data = provider.data;

        final isOnline = data?.isOnline ?? false;
        final currentMode = data?.mode ?? 'AUTO';
        final isAutoMode = currentMode == 'AUTO';
        // CleaningState is driven ONLY by local _cleaningState.
        // Telemetry pumpStatus/wiperStatus are shown as device indicators only.
        final isCleaningRunning = _cleaningState == CleaningState.running;

        // Formatted last update time
        String formattedTime = '--:--:--';
        if (data != null && data.lastUpdate.isNotEmpty) {
          try {
            final dt = DateTime.parse(data.lastUpdate).toLocal();
            formattedTime =
                '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
          } catch (_) {
            formattedTime = data.lastUpdate;
          }
        }

        final sched = _getScheduleTimes();

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
                                'Cleaning',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Sistem pembersihan solar panel realtime',
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

                // ─── Section 1: Device Status ──────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.4),
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
                          
                          // Pump Status Row
                          _buildStatusRow(
                            icon: LucideIcons.droplets,
                            iconColor: AppColors.tempWater,
                            label: 'Pump Status',
                            isActive: data?.pumpStatus ?? false,
                            activeLabel: 'Pump Active',
                            idleLabel: 'Pump Idle',
                          ),
                          const Divider(height: 24, color: AppColors.divider),

                          // Wiper Status Row
                          _buildStatusRow(
                            icon: LucideIcons.brush,
                            iconColor: AppColors.primary,
                            label: 'Wiper Status',
                            isActive: data?.wiperStatus ?? false,
                            activeLabel: 'Wiper Active',
                            idleLabel: 'Wiper Idle',
                          ),
                          const Divider(height: 24, color: AppColors.divider),

                          // Mode Status Row
                          _buildMetadataRow(
                            icon: LucideIcons.cpu,
                            iconColor: AppColors.powerColor,
                            label: 'Device Mode',
                            value: currentMode == 'AUTO' ? 'AUTO RTC' : 'MANUAL',
                            isBadge: true,
                          ),
                          const Divider(height: 24, color: AppColors.divider),

                          // Last Update Row
                          _buildMetadataRow(
                            icon: LucideIcons.clock,
                            iconColor: AppColors.textSecondary,
                            label: 'Last Update',
                            value: formattedTime,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Section 2: Cleaning Mode Card ──────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.4),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: const Icon(
                                  LucideIcons.settings,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Cleaning Mode',
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
                            'Pilih mode operasional pembersihan panel surya.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Custom Mode Selector Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildModeCard(
                                  label: 'Manual',
                                  subtitle: 'Kontrol manual via tombol',
                                  icon: LucideIcons.sliders,
                                  isSelected: !isAutoMode,
                                  onTap: () {
                                    if (isAutoMode && !_isModeLoading) {
                                      _changeMode('MANUAL');
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildModeCard(
                                  label: 'Auto RTC',
                                  subtitle: 'Pembersihan terjadwal',
                                  icon: LucideIcons.cpu,
                                  isSelected: isAutoMode,
                                  onTap: () {
                                    if (!isAutoMode && !_isModeLoading) {
                                      _changeMode('AUTO');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_isModeLoading) ...[
                            const SizedBox(height: 12),
                            const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Auto RTC Information Card (Conditional) ────────────────
                if (isAutoMode)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.25),
                          borderRadius: AppRadius.lg,
                          border: Border.all(
                            color: AppColors.primaryContainer.withOpacity(0.8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.clock,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Automatic Cleaning Schedule',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeChip(
                                    icon: LucideIcons.sun,
                                    title: 'Morning',
                                    time: '07:00',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _buildTimeChip(
                                    icon: LucideIcons.sunset,
                                    title: 'Evening',
                                    time: '18:00',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Cleaning will run automatically according to RTC schedule.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryDark.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ─── Section 3: Manual Cleaning Control ─────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.4),
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
                                'Manual Cleaning Control',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Manual button
                          _buildMainButton(isOnline, isAutoMode, isCleaningRunning),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Status Information Section ─────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 120),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lg,
                        border: Border.all(color: AppColors.border.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS INFORMATION',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHint,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (isAutoMode) ...[
                            _buildInfoText(
                              label: 'Current Mode',
                              value: 'AUTO RTC',
                              valueColor: AppColors.primary,
                            ),
                            const SizedBox(height: 6),
                            _buildInfoText(
                              label: 'Last Cleaning',
                              value: sched['last']!,
                            ),
                            const SizedBox(height: 6),
                            _buildInfoText(
                              label: 'Next Cleaning',
                              value: sched['next']!,
                              valueColor: AppColors.success,
                            ),
                          ] else ...[
                            _buildInfoText(
                              label: 'Current Mode',
                              value: 'MANUAL',
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Waiting for user command.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip({
    required IconData icon,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

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
            color: iconColor.withOpacity(0.1),
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

  Widget _buildMetadataRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isBadge = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: AppRadius.sm,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        isBadge
            ? AppStatusChip(
                label: value,
                variant: value == 'AUTO RTC'
                    ? AppChipVariant.primary
                    : AppChipVariant.warning,
              )
            : Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
      ],
    );
  }

  Widget _buildMainButton(bool isDeviceOnline, bool isAutoMode, bool isRunning) {
    // Enabled only when device is online, not loading, mode is MANUAL, and NOT currently cleaning
    final isEnabled = isDeviceOnline && !_isActionLoading && !isAutoMode && !isRunning;

    final btnColor = isRunning ? AppColors.warning : AppColors.success;

    return Column(
      children: [
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : (isAutoMode ? 0.5 : 0.6),
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: isEnabled ? () => _startCleaning() : null,
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
                          color: btnColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: (_isActionLoading || isRunning)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          if (isRunning) ...[
                            const SizedBox(width: 10),
                            Text(
                              'CLEANING...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAutoMode ? LucideIcons.lock : LucideIcons.play,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'START CLEANING',
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
        ),
        if (isAutoMode) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.lock,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Manual cleaning is disabled while Auto RTC mode is active.',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
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
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 * _animation.value),
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
