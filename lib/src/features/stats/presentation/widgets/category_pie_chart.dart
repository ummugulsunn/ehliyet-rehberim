import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget that displays a pie chart showing category performance distribution
class CategoryPerformancePieChart extends StatelessWidget {
  final Map<String, double> categoryScores;
  
  const CategoryPerformancePieChart({
    super.key,
    required this.categoryScores,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryScores.isEmpty) {
      return Center(
        child: Text(
          'Henüz kategori verisi yok',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: _createSections(context),
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Handle touch events if needed
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF9800), // Orange
    ];

    int index = 0;
    return categoryScores.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.value.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
      );
    }).toList();
  }
}

/// Legend widget for the pie chart
class CategoryLegend extends StatelessWidget {
  final Map<String, double> categoryScores;
  
  const CategoryLegend({
    super.key,
    required this.categoryScores,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryScores.entries.toList().asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final entry = mapEntry.value;
        final color = colors[index % colors.length];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
