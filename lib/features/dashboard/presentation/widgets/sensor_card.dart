import 'package:flutter/material.dart';
import '../../../../core/widgets/app_metric_card.dart';
import '../../../../core/widgets/app_status_chip.dart';

/// SensorCard is now an alias for AppMetricCard to preserve any existing usage.
/// Existing call sites in the project can continue to reference SensorCard.
class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppMetricCard(
      title: title,
      value: value,
      unit: '',
      icon: icon,
      iconColor: color,
      iconBgColor: color.withOpacity(0.12),
      status: 'Active',
      statusVariant: AppChipVariant.success,
    );
  }
}
