import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'priority_badge.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatusCycle;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusCycle,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = widget.task.status == TaskStatus.done;

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (widget.index * 50).ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          delay: (widget.index * 50).ms,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Card(
            margin: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: widget.task.isOverdue
                    ? Border.all(color: Colors.red.shade300, width: 1.5)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Status icon — tap to cycle
                      GestureDetector(
                        onTap: widget.onStatusCycle,
                        child: Tooltip(
                          message: 'Tap to change status',
                          child: Icon(
                            widget.task.status.icon,
                            color: widget.task.status.color,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: isDone
                                ? theme.colorScheme.onSurface.withOpacity(0.5)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      PriorityBadge(
                          priority: widget.task.priority, small: true),

                      // ── Action buttons (visible on hover or always on touch) ──
                      AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 6),
                            _ActionBtn(
                              icon: Icons.edit_outlined,
                              color: theme.colorScheme.primary,
                              tooltip: 'Edit task',
                              onTap: widget.onEdit,
                            ),
                            const SizedBox(width: 4),
                            _ActionBtn(
                              icon: Icons.delete_outline_rounded,
                              color: Colors.red.shade400,
                              tooltip: 'Delete task',
                              onTap: widget.onDelete,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text(
                        widget.task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Row(
                      children: [
                        StatusChip(status: widget.task.status, small: true),
                        const Spacer(),
                        if (widget.task.dueDate != null) ...[
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: widget.task.isOverdue
                                ? Colors.red
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormat('MMM d').format(widget.task.dueDate!),
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.task.isOverdue
                                  ? Colors.red
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                              fontWeight: widget.task.isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (widget.task.isOverdue) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small icon action button ─────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
