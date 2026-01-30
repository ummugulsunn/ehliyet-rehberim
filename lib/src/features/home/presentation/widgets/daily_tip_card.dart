import 'package:flutter/material.dart';
import '../../data/daily_tips.dart';

class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tip = DailyTips.getTodayTip();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF8E1), // Amber 50
            const Color(0xFFFFECB3), // Amber 100
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD54F), // Amber 300
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFFFFA000), // Amber 700
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günün İpucu',
                  style: TextStyle(
                    color: const Color(0xFFFFA000),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(
                    color: Color(0xFF5D4037), // Brown 700
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
