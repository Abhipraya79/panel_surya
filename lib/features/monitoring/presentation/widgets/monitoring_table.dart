import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/telemetry_history_model.dart';
import '../providers/history_provider.dart';

class MonitoringTable extends StatefulWidget {
  const MonitoringTable({super.key});

  @override
  State<MonitoringTable> createState() => _MonitoringTableState();
}

class _MonitoringTableState extends State<MonitoringTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<HistoryProvider>();
      if (!provider.isLoadingMore && provider.hasMoreData) {
        provider.loadHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.records.isEmpty && !provider.isLoading) {
          return const _EmptyState();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lg,
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.background),
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  columns: [
                    _buildSortableColumn(provider, 'No', 'No'),
                    _buildSortableColumn(provider, 'Tanggal', 'Tanggal'),
                    _buildSortableColumn(provider, 'Jam', 'Jam'),
                    _buildSortableColumn(provider, 'Suhu Air (°C)', 'Suhu Air'),
                    _buildSortableColumn(provider, 'Tegangan (V)', 'Tegangan'),
                    _buildSortableColumn(provider, 'Arus (A)', 'Arus'),
                    _buildSortableColumn(provider, 'Daya (W)', 'Daya'),
                    _buildSortableColumn(provider, 'Debu', 'Debu'),
                    _buildColumn('Pump'),
                    _buildColumn('Wiper'),
                    _buildColumn('Mode'),
                    _buildColumn('Status'),
                  ],
                  rows: [
                    ...provider.records.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}', style: _cellStyle())),
                          DataCell(Text(DateFormat('dd MMM yyyy').format(record.timestamp), style: _cellStyle())),
                          DataCell(Text(DateFormat('HH:mm:ss').format(record.timestamp), style: _cellStyle())),
                          DataCell(Text(
                            _formatNumber(record.airTemp),
                            style: _cellStyle().copyWith(
                              color: _getTempColor(record.airTemp),
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                          DataCell(Text(_formatNumber(record.voltage), style: _cellStyle())),
                          DataCell(Text(_formatNumber(record.current), style: _cellStyle())),
                          DataCell(Text(_formatNumber(record.power), style: _cellStyle())),
                          DataCell(Text(_formatNumber(record.dust), style: _cellStyle())),
                          DataCell(_Badge(
                            text: record.pumpStatus ? 'ON' : 'OFF',
                            color: record.pumpStatus ? Colors.green : Colors.grey,
                          )),
                          DataCell(_Badge(
                            text: record.wiperStatus ? 'ON' : 'OFF',
                            color: record.wiperStatus ? Colors.green : Colors.grey,
                          )),
                          DataCell(_Badge(
                            text: record.systemMode,
                            color: record.systemMode.toUpperCase() == 'AUTO' ? Colors.blue : Colors.orange,
                          )),
                          DataCell(_Badge(
                            text: record.deviceStatus,
                            color: record.deviceStatus.toUpperCase() == 'ONLINE' ? Colors.green : Colors.red,
                          )),
                        ],
                      );
                    }),
                    if (provider.isLoadingMore)
                      const DataRow(
                        cells: [
                          DataCell(CircularProgressIndicator()),
                          DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
                          DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
                          DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
                          DataCell(Text('')), DataCell(Text('')),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  DataColumn _buildSortableColumn(HistoryProvider provider, String label, String sortKey) {
    final isSorted = provider.sortBy == sortKey;
    final isAscending = provider.sortAscending;

    return DataColumn(
      onSort: (_, __) => provider.updateSort(sortKey),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isSorted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (isSorted) ...[
            const SizedBox(width: 4),
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: AppColors.primary,
            ),
          ]
        ],
      ),
    );
  }

  TextStyle _cellStyle() => GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  String _formatNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    String str = value.toStringAsFixed(3);
    // Remove trailing zeros
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0*$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }

  Color _getTempColor(num temp) {
    if (temp <= 30) return Colors.blue;
    if (temp <= 39) return Colors.orange;
    return Colors.red;
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tidak ada data monitoring.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Silakan ubah filter atau tekan Refresh.',
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
