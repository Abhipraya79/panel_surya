import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../widgets/history_item_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Sample notification data
  static const List<_NotifData> _notifications = [
    _NotifData(
      time: '09:41:12',
      title: 'Sistem Connected',
      body: 'ESP32 berhasil terhubung',
      type: NotifType.success,
    ),
    _NotifData(
      time: '09:40:31',
      title: 'Peltier ON',
      body: 'Pendinginan air aktif',
      type: NotifType.info,
    ),
    _NotifData(
      time: '18:00:01',
      title: 'Cleaning Started',
      body: 'Pembersihan panel dimulai',
      type: NotifType.success,
    ),
    _NotifData(
      time: '18:02:35',
      title: 'Cleaning Finished',
      body: 'Pembersihan panel selesai',
      type: NotifType.success,
    ),
    _NotifData(
      time: '14:23:10',
      title: 'Suhu Tinggi',
      body: 'Suhu panel melebihi setpoint',
      type: NotifType.warning,
    ),
    _NotifData(
      time: '07:00:19',
      title: 'Cleaning Scheduled',
      body: 'Pembersihan terjadwal dimulai',
      type: NotifType.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Riwayat sistem & aktuator',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                    tooltip: 'Hapus semua',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Notification Timeline ────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, 120),
                itemCount: _notifications.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  return HistoryItemCard(
                    time: n.time,
                    title: n.title,
                    body: n.body,
                    type: n.type,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifData {
  final String time, title, body;
  final NotifType type;
  const _NotifData({
    required this.time,
    required this.title,
    required this.body,
    required this.type,
  });
}
