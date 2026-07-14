import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../providers/history_provider.dart';
import '../../data/models/telemetry_history_model.dart';
import '../../../settings/presentation/screens/connection_test_screen.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                          'Monitoring',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Grafik sensor historis',
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

            // Limit Selector
            const _LimitSelector(),

            // Content
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.records.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.hasError && provider.records.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.wifiOff,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              provider.errorMessage ?? 'Gagal memuat data history',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: AppSpacing.md),
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
                                  onPressed: () => provider.loadHistory(),
                                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                                  label: Text(
                                    'Coba Lagi',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
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
                                  icon: const Icon(LucideIcons.network, size: 14),
                                  label: Text(
                                    'Uji Koneksi',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.database,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Belum ada data history',
                              style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadHistory(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 120),
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      children: [
                        // Statistics Card
                        const _StatisticsCard(),
                        const SizedBox(height: AppSpacing.md),

                        // Charts
                        _ChartCard(
                          title: 'Suhu Panel (°C)',
                          color: AppColors.tempPanel,
                          dataExtractor: (model) => model.temperature,
                          unit: '°C',
                        ),
                        _ChartCard(
                          title: 'Kelembaban (%)',
                          color: AppColors.tempWater,
                          dataExtractor: (model) => model.humidity,
                          unit: '%',
                        ),
                        _ChartCard(
                          title: 'Tegangan (V)',
                          color: AppColors.voltageColor,
                          dataExtractor: (model) => model.voltage,
                          unit: 'V',
                        ),
                        _ChartCard(
                          title: 'Arus (A)',
                          color: AppColors.currentColor,
                          dataExtractor: (model) => model.current,
                          unit: 'A',
                        ),
                        _ChartCard(
                          title: 'Daya (W)',
                          color: AppColors.powerColor,
                          dataExtractor: (model) => model.power,
                          unit: 'W',
                        ),
                        _ChartCard(
                          title: 'Debu (μg/m³)',
                          color: AppColors.dustColor,
                          dataExtractor: (model) => model.dust,
                          unit: 'μg/m³',
                        ),
                      ],
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

class _LimitSelector extends StatelessWidget {
  const _LimitSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [20, 50, 100, 200].map((limit) {
              final isSelected = provider.selectedLimit == limit;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text('$limit Data'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setLimit(limit);
                    }
                  },
                  labelStyle: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.card,
                  side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border.withValues(alpha: 0.5)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lg,
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Data',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _StatItem(label: 'Avg Temp', value: '${provider.avgTemperature.toStringAsFixed(1)} °C'),
                        _StatItem(label: 'Max Temp', value: '${provider.maxTemperature.toStringAsFixed(1)} °C'),
                        _StatItem(label: 'Min Temp', value: '${provider.minTemperature.toStringAsFixed(1)} °C'),
                        _StatItem(label: 'Avg Hum', value: '${provider.avgHumidity.toStringAsFixed(1)} %'),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      children: [
                        _StatItem(label: 'Avg Volt', value: '${provider.avgVoltage.toStringAsFixed(1)} V'),
                        _StatItem(label: 'Avg Curr', value: '${provider.avgCurrent.toStringAsFixed(2)} A'),
                        _StatItem(label: 'Avg Pwr', value: '${provider.avgPower.toStringAsFixed(1)} W'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final double Function(TelemetryHistoryModel) dataExtractor;
  final String unit;

  const _ChartCard({
    required this.title,
    required this.color,
    required this.dataExtractor,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        final records = provider.records;
        if (records.isEmpty) return const SizedBox.shrink();

        final latestValue = dataExtractor(records.last);
        
        // Find min and max for Y axis
        double minY = double.infinity;
        double maxY = double.negativeInfinity;
        for (var r in records) {
          final val = dataExtractor(r);
          if (val < minY) minY = val;
          if (val > maxY) maxY = val;
        }

        // Add some padding to Y axis
        final yPadding = (maxY - minY) * 0.1;
        minY = minY - yPadding;
        maxY = maxY + yPadding;
        if (minY == maxY) {
          minY -= 1;
          maxY += 1;
        }

        // Generate FlSpot data
        final spots = <FlSpot>[];
        for (int i = 0; i < records.length; i++) {
          spots.add(FlSpot(i.toDouble(), dataExtractor(records[i])));
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lg,
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      '${latestValue.toStringAsFixed(1)} $unit',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Chart Body
              SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY - minY) / 3,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.border.withValues(alpha: 0.3),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: (records.length > 5) ? (records.length / 5).floorToDouble() : 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= records.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                records[index].timeLabel,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (maxY - minY) / 3,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: GoogleFonts.poppins(
                                color: AppColors.textHint,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.right,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (records.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (LineBarSpot spot) => AppColors.primary,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final record = records[spot.x.toInt()];
                            return LineTooltipItem(
                              '${record.timeLabel}\n${spot.y.toStringAsFixed(1)} $unit',
                              GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
