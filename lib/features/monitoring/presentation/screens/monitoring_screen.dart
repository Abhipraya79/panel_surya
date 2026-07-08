import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  int _selectedTime = 0; // 0=Realtime 1=1Hari 2=7Hari 3=30Hari

  final _timeFilters = ['Real-time', '1 Hari', '7 Hari', '30 Hari'];

  final _charts = [
    _ChartData(
        title: 'Suhu Panel (°C)',
        value: '41.8 °C',
        color: AppColors.tempPanel,
        dataPoints: [35, 38, 41, 43, 41, 40, 41, 42, 41, 41]),
    _ChartData(
        title: 'Suhu Air (°C)',
        value: '24.6 °C',
        color: AppColors.tempWater,
        dataPoints: [22, 23, 24, 25, 24, 25, 24, 24, 25, 24]),
    _ChartData(
        title: 'Debu (μg/m³)',
        value: '128 μg/m³',
        color: AppColors.dustColor,
        dataPoints: [80, 100, 120, 150, 130, 128, 125, 130, 128, 130]),
    _ChartData(
        title: 'Tegangan (V)',
        value: '18.72 V',
        color: AppColors.voltageColor,
        dataPoints: [17, 18, 18, 19, 18, 18, 18, 19, 18, 18]),
    _ChartData(
        title: 'Arus (A)',
        value: '4.25 A',
        color: AppColors.currentColor,
        dataPoints: [3, 4, 4, 5, 4, 4, 4, 4, 4, 4]),
    _ChartData(
        title: 'Daya (W)',
        value: '79.8 W',
        color: AppColors.powerColor,
        dataPoints: [55, 70, 75, 90, 80, 79, 78, 80, 79, 80]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Header + Time Filter ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Column(
                children: [
                  Row(
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
                              'Grafik sensor real-time',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.calendar,
                          color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTimeFilter(),
                ],
              ),
            ),

            // ─── Chart Cards ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 120),
                physics: const BouncingScrollPhysics(),
                itemCount: _charts.length,
                itemBuilder: (_, i) => _ChartCard(
                  data: _charts[i],
                  timeFilter: _timeFilters[_selectedTime],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: AppRadius.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_timeFilters.length, (i) {
          final selected = _selectedTime == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTime = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.pill,
                ),
                child: Center(
                  child: Text(
                    _timeFilters[i],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Chart Card ──────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final _ChartData data;
  final String timeFilter;

  const _ChartCard({required this.data, required this.timeFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.12),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  data.value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: data.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ─── Mini Line Chart (canvas-painted) ──────────────────────
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _MiniChartPainter(
                data: data.dataPoints,
                color: data.color,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (i) => Text(
                '${9 + i}:00',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Mini Chart Painter ────────────────────────────────────────────────

class _MiniChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;

  const _MiniChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.reduce((a, b) => a < b ? a : b).toDouble();
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height -
          ((data[i].toDouble() - minVal) / range) * size.height * 0.85 -
          size.height * 0.05;
      points.add(Offset(x, y));
    }

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Smooth line path
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Last point dot
    canvas.drawCircle(
      points.last,
      4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      points.last,
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_MiniChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _ChartData {
  final String title;
  final String value;
  final Color color;
  final List<int> dataPoints;

  const _ChartData({
    required this.title,
    required this.value,
    required this.color,
    required this.dataPoints,
  });
}
