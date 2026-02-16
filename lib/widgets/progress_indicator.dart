import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int current;
  final int total;
  final Color? color;

  const CustomProgressIndicator({
    super.key,
    required this.current,
    required this.total,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1 : total;
    final progress = (current / safeTotal).clamp(0.0, 1.0);
    final barColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$current/$total',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: barColor,
              backgroundColor: barColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
