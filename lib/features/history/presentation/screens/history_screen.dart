import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../widgets/history_item_card.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                  Consumer<EventProvider>(
                    builder: (context, provider, child) {
                      if (provider.events.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            provider.clearEvents();
                          },
                          tooltip: 'Hapus semua',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ─── Notification Timeline ────────────────────────────────
            Expanded(
              child: Consumer<EventProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.events.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.events.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada notifikasi',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.loadEvents(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, 120),
                      itemCount: provider.events.length,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemBuilder: (context, index) {
                        final item = provider.events[index];
                        
                        NotifType type = NotifType.info;
                        final evtLower = item.event.toLowerCase();
                        if (evtLower.contains('error') || evtLower.contains('fail') || evtLower.contains('tinggi')) {
                          type = NotifType.warning;
                        } else if (evtLower.contains('completed') || evtLower.contains('connected') || evtLower.contains('selesai') || evtLower.contains('started')) {
                          type = NotifType.success;
                        }

                        // parse time
                        String displayTime = item.receivedAt;
                        try {
                          final dt = DateTime.parse(item.receivedAt).toLocal();
                          displayTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
                        } catch (_) {}

                        return HistoryItemCard(
                          time: displayTime,
                          title: 'Event Info',
                          body: item.event,
                          type: type,
                        );
                      },
                    ),
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
