import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../providers/history_provider.dart';
import '../widgets/monitoring_filter_card.dart';
import '../widgets/monitoring_table.dart';
import '../../../settings/presentation/screens/connection_test_screen.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monitoring Panel Surya',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Realtime Telemetry History',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Card
            const MonitoringFilterCard(),
            const SizedBox(height: AppSpacing.sm),

            // Toolbar
            const _Toolbar(),
            const SizedBox(height: AppSpacing.sm),

            // Content
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const _SkeletonLoader();
                  }

                  if (provider.hasError && provider.records.isEmpty) {
                    return const _ErrorState();
                  }

                  return const MonitoringTable();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Text(
                'Total Data : ${provider.totalData}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _ToolbarButton(
                icon: LucideIcons.refreshCw,
                label: 'Refresh',
                color: AppColors.primary,
                onTap: () => provider.loadHistory(isRefresh: true),
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: LucideIcons.fileSpreadsheet,
                label: 'Excel',
                color: Colors.green,
                onTap: () => provider.exportToExcel(context),
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: LucideIcons.fileText,
                label: 'PDF',
                color: Colors.red,
                onTap: () => provider.exportToPdf(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.sm,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(
          10,
          (index) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _shimmerBox(24, 24),
                const SizedBox(width: 16),
                _shimmerBox(80, 20),
                const SizedBox(width: 16),
                _shimmerBox(60, 20),
                const Spacer(),
                _shimmerBox(100, 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.3),
        borderRadius: AppRadius.sm,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: AppRadius.lg,
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Gagal mengambil data monitoring.',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.errorMessage ?? 'Terjadi kesalahan sistem',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => provider.loadHistory(isRefresh: true),
                icon: const Icon(LucideIcons.refreshCw, size: 14),
                label: Text('Coba Lagi', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectionTestScreen(),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.network, size: 14),
                label: Text('Uji Koneksi', style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
