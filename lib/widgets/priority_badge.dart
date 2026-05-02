import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool small;

  const PriorityBadge({super.key, required this.priority, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: priority.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: small ? 10 : 12, color: priority.color),
          const SizedBox(width: 3),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  final bool small;

  const StatusChip({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: small ? 10 : 12, color: status.color),
          const SizedBox(width: 3),
          Text(
            status.label,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
