import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class PriorityBadge extends StatelessWidget {
  final int priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  Color get priorityColor {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        AppConstants.priorityLabel(priority),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: priorityColor,
      side: BorderSide.none,
    );
  }
}
