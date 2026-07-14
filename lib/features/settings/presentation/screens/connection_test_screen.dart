import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/socket/socket_service.dart';
import '../../../../core/services/network_error_handler.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  // REST API status
  bool _isTestingApi = false;
  String _apiStatus = 'Belum diuji';
  String? _apiResponse;
  String? _apiError;
  int? _apiStatusCode;
  int _apiLatencyMs = 0;

  // Socket.IO status
  String _socketStatus = 'Disconnected';
  bool _isSocketConnected = false;

  // Device network info
  List<String> _localIps = [];
  bool _isLoadingNetwork = true;

  // Log stream
  List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _logs = List.from(SocketService.connectionLogs);
    SocketService.setLogListener(_onSocketLogUpdated);
    _isSocketConnected = SocketService.instance.isConnected;
    _socketStatus = _isSocketConnected ? 'Connected' : 'Disconnected';
    _fetchNetworkInfo();
    _runApiTest();
  }

  @override
  void dispose() {
    SocketService.setLogListener(null);
    _logScrollController.dispose();
    super.dispose();
  }

  void _onSocketLogUpdated() {
    if (mounted) {
      setState(() {
        _logs = List.from(SocketService.connectionLogs);
        _isSocketConnected = SocketService.instance.isConnected;
        _socketStatus = _isSocketConnected ? 'Connected' : 'Disconnected';
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_logScrollController.hasClients) {
      _logScrollController.animateTo(
        _logScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchNetworkInfo() async {
    setState(() => _isLoadingNetwork = true);
    final ips = <String>[];
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          ips.add('${interface.name}: ${addr.address}');
        }
      }
      if (ips.isEmpty) {
        ips.add('Tidak terhubung ke Wi-Fi (No IPv4 address)');
      }
    } catch (e) {
      ips.add('Gagal mengambil IP: $e');
    }
    if (mounted) {
      setState(() {
        _localIps = ips;
        _isLoadingNetwork = false;
      });
    }
  }

  Future<void> _runApiTest() async {
    if (_isTestingApi) return;
    setState(() {
      _isTestingApi = true;
      _apiStatus = 'Menguji...';
      _apiResponse = null;
      _apiError = null;
      _apiStatusCode = null;
    });

    final stopwatch = Stopwatch()..start();
    final client = http.Client();
    final uri = Uri.parse('${AppConfig.baseUrl}/health');

    try {
      final response = await client.get(uri).timeout(
            const Duration(seconds: 5),
          );
      stopwatch.stop();

      if (mounted) {
        setState(() {
          _apiLatencyMs = stopwatch.elapsedMilliseconds;
          _apiStatusCode = response.statusCode;
          _apiResponse = response.body;
          if (response.statusCode == 200) {
            _apiStatus = 'Connected';
            _apiError = null;
          } else {
            _apiStatus = 'HTTP Error';
            _apiError = 'Server merespon dengan status code ${response.statusCode}';
          }
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _apiLatencyMs = stopwatch.elapsedMilliseconds;
          _apiStatus = 'Failed';
          _apiError = NetworkErrorHandler.getFriendlyMessage(e);
        });
      }
    } finally {
      client.close();
      if (mounted) {
        setState(() => _isTestingApi = false);
      }
    }
  }

  void _runDiagnostics() {
    _runApiTest();
    _fetchNetworkInfo();
    // Trigger socket connection refresh
    SocketService.instance.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Connection Test',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Uji Ulang',
            onPressed: _isTestingApi ? null : _runDiagnostics,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header Info Card ──────────────────────────────────────────
              _buildConfigCard(),
              const SizedBox(height: AppSpacing.md),

              // ─── Device Network Interfaces ──────────────────────────────────
              _buildNetworkCard(),
              const SizedBox(height: AppSpacing.md),

              // ─── REST API Card ─────────────────────────────────────────────
              _buildApiCard(),
              const SizedBox(height: AppSpacing.md),

              // ─── Socket.IO Card ────────────────────────────────────────────
              _buildSocketCard(),
              const SizedBox(height: AppSpacing.md),

              // ─── Live Socket.IO Logs Terminal ──────────────────────────────
              _buildLogsCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.globe, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Configuration endpoints',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Backend Base URL', AppConfig.baseUrl),
          const Divider(height: 16),
          _buildInfoRow('Socket.IO URL', AppConfig.socketUrl),
          if (AppConfig.isDebugMode) ...[
            const Divider(height: 16),
            _buildInfoRow('Environment', AppConfig.environment.toUpperCase()),
            const Divider(height: 16),
            _buildInfoRow('Debug Mode', 'ACTIVE', valueColor: AppColors.success),
          ]
        ],
      ),
    );
  }

  Widget _buildNetworkCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.wifi, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                'Device Network Info',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoadingNetwork)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            Text(
              'IP Address di Handphone:',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _localIps
                  .map((ip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '• $ip',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoLight.withOpacity(0.4),
                borderRadius: AppRadius.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan IP HP Anda memiliki subnet yang sama dengan laptop (misal sama-sama berada di 10.208.x.x atau 192.168.x.x).',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.info,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildApiCard() {
    final isSuccess = _apiStatus == 'Connected';
    final isTesting = _isTestingApi;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.server, color: AppColors.tempPanel, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'REST API Diagnostic',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isTesting)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.successLight
                        : (_apiStatus == 'Failed' ? AppColors.dangerLight : Colors.grey.shade100),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    _apiStatus,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: isSuccess
                          ? AppColors.success
                          : (_apiStatus == 'Failed' ? AppColors.danger : Colors.grey.shade700),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Endpoint', '${AppConfig.baseUrl}/health'),
          const Divider(height: 16),
          _buildInfoRow(
            'HTTP Status Code',
            _apiStatusCode != null ? '$_apiStatusCode' : '-',
            valueColor: _apiStatusCode == 200 ? AppColors.success : AppColors.danger,
          ),
          const Divider(height: 16),
          _buildInfoRow('Latency', '$_apiLatencyMs ms'),

          if (_apiResponse != null) ...[
            const Divider(height: 16),
            Text(
              'Server Response:',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: AppRadius.md,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _apiResponse!,
                style: GoogleFonts.firaCode(fontSize: 11, color: Colors.grey.shade800),
              ),
            ),
          ],

          if (_apiError != null) ...[
            const Divider(height: 16),
            Text(
              'Error Detail:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _apiError!,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocketCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.plug, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Socket.IO Diagnostic',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _isSocketConnected
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  _socketStatus,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: _isSocketConnected
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Endpoint', AppConfig.socketUrl),
          const Divider(height: 16),
          _buildInfoRow('Transports', 'WebSocket Only'),
        ],
      ),
    );
  }

  Widget _buildLogsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark Theme Terminal
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.terminal, color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Socket.IO Live Log Terminal',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  SocketService.clearLogs();
                  setState(() => _logs = []);
                },
                icon: const Icon(LucideIcons.trash2, color: Colors.grey, size: 12),
                label: Text(
                  'Clear',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: AppRadius.md,
            ),
            child: _logs.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada log log koneksi.',
                      style: GoogleFonts.firaCode(fontSize: 11, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _logScrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      // Highlight success green vs error red
                      Color logColor = Colors.white70;
                      if (log.contains('Connected') || log.contains('Reconnected')) {
                        logColor = Colors.greenAccent;
                      } else if (log.contains('Error') || log.contains('Timeout') || log.contains('Ditolak')) {
                        logColor = Colors.redAccent;
                      } else if (log.contains('Attempt') || log.contains('Connecting')) {
                        logColor = Colors.amberAccent;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Text(
                          log,
                          style: GoogleFonts.firaCode(
                            fontSize: 11,
                            color: logColor,
                            height: 1.3,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
