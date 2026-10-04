import 'package:flutter/material.dart';
import '../../../../core/models/expense.dart';

class EmotionSelector extends StatelessWidget {
  final GuiltLevel selectedLevel;
  final ValueChanged<GuiltLevel> onSelected;

  const EmotionSelector({
    super.key,
    required this.selectedLevel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEmotionOption(
          GuiltLevel.essential,
          'Essential',
          Icons.favorite,
          Colors.green,
        ),
        _buildEmotionOption(
          GuiltLevel.guiltFree,
          'Guilt-Free',
          Icons.sentiment_satisfied_alt,
          Colors.blue,
        ),
        _buildEmotionOption(
          GuiltLevel.oops,
          'Oops',
          Icons.sentiment_dissatisfied,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildEmotionOption(
    GuiltLevel level,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedLevel == level;
    return GestureDetector(
      onTap: () => onSelected(level),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
