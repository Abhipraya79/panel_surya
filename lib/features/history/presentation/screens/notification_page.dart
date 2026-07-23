import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  void _clearNotifications() {
    context.read<EventProvider>().clearEvents();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi telah dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Consumer<EventProvider>(
            builder: (context, provider, child) {
              if (provider.events.isNotEmpty) {
                return IconButton(
                  icon: const Icon(LucideIcons.trash2, color: Colors.white),
                  onPressed: _clearNotifications,
                  tooltip: 'Hapus Semua',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.events.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadEvents(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: provider.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = provider.events[index];
                
                // Helper to determine icon and color based on event type
                IconData icon = LucideIcons.info;
                Color color = AppColors.primary;
                Color bgColor = AppColors.primaryContainer;
                
                final evtLower = item.event.toLowerCase();
                if (evtLower.contains('error') || evtLower.contains('fail') || evtLower.contains('tinggi')) {
                  icon = LucideIcons.alertTriangle;
                  color = AppColors.warning;
                  bgColor = AppColors.warningLight;
                } else if (evtLower.contains('completed') || evtLower.contains('connected') || evtLower.contains('selesai')) {
                  icon = LucideIcons.checkCircle2;
                  color = AppColors.success;
                  bgColor = AppColors.successLight;
                } else if (evtLower.contains('started') || evtLower.contains('cleaning') || evtLower.contains('mulai')) {
                  icon = LucideIcons.brush;
                  color = AppColors.powerColor;
                  bgColor = AppColors.powerColor.withOpacity(0.12);
                } else if (evtLower.contains('cooling') || evtLower.contains('peltier')) {
                  icon = LucideIcons.snowflake;
                  color = AppColors.tempWater;
                  bgColor = AppColors.tempWater.withOpacity(0.12);
                }

                // parse time
                String displayTime = item.receivedAt;
                try {
                  final dt = DateTime.parse(item.receivedAt).toLocal();
                  displayTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
                } catch (_) {}

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.lg,
                    boxShadow: AppShadows.subtle,
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.lg,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left accent color bar
                          Container(
                            width: 5,
                            color: color,
                          ),
                          const SizedBox(width: 12),
                          // Icon
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: color,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Text contents
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    displayTime,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Event Info',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.event,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.bellOff,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semua riwayat sistem Anda bersih',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
