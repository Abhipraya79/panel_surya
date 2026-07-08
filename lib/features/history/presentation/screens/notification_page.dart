import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Mock data list matching the requirements
  final List<Map<String, dynamic>> _notifications = [
    {
      'time': '09:41:12',
      'title': 'Sistem Connected',
      'subtitle': 'ESP32 berhasil terhubung',
      'icon': LucideIcons.checkCircle2,
      'iconColor': AppColors.success,
      'bgColor': AppColors.successLight,
    },
    {
      'time': '09:40:31',
      'title': 'Peltier ON',
      'subtitle': 'Pendinginan air aktif',
      'icon': LucideIcons.snowflake,
      'iconColor': AppColors.tempWater,
      'bgColor': AppColors.tempWater.withOpacity(0.12),
    },
    {
      'time': '18:00:01',
      'title': 'Cleaning Started',
      'subtitle': 'Pembersihan panel dimulai',
      'icon': LucideIcons.brush,
      'iconColor': AppColors.powerColor,
      'bgColor': AppColors.powerColor.withOpacity(0.12),
    },
    {
      'time': '18:02:25',
      'title': 'Cleaning Finished',
      'subtitle': 'Pembersihan panel selesai',
      'icon': LucideIcons.checkCircle2,
      'iconColor': AppColors.success,
      'bgColor': AppColors.successLight,
    },
    {
      'time': '14:23:10',
      'title': 'Suhu Tinggi',
      'subtitle': 'Suhu panel melebihi setpoint',
      'icon': LucideIcons.alertTriangle,
      'iconColor': AppColors.warning,
      'bgColor': AppColors.warningLight,
    },
    {
      'time': '07:00:10',
      'title': 'Cleaning Scheduled',
      'subtitle': 'Pembersihan terjadwal dimulai',
      'icon': LucideIcons.calendar,
      'iconColor': AppColors.info,
      'bgColor': AppColors.infoLight,
    },
  ];

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
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
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.white),
              onPressed: _clearNotifications,
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _notifications[index];
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
                            color: item['iconColor'] as Color,
                          ),
                          const SizedBox(width: 12),
                          // Icon
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item['bgColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['iconColor'] as Color,
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
                                    item['time'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['subtitle'] as String,
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
