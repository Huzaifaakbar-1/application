import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key, required this.task,
    required this.onToggle, required this.onEdit, required this.onDelete,
  });

  Color get _catColor {
    final key = task.category.name;
    return AppTheme.catColor(key);
  }

  bool get _isNear {
    if (!task.hasReminder || task.isDone) return false;
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day, task.reminderHour!, task.reminderMinute!);
    final diff = t.difference(now).inMinutes;
    return diff >= 0 && diff <= 15;
  }

  bool get _isOverdue {
    if (!task.hasReminder || task.isDone) return false;
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day, task.reminderHour!, task.reminderMinute!);
    return t.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.accent, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Task?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
            content: Text('Remove "${task.name}"?', style: const TextStyle(color: AppTheme.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
              TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Delete', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w800))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: task.isDone ? 0.5 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              // Left color bar
              Container(
                width: 4, height: 72,
                decoration: BoxDecoration(
                  color: task.isDone ? AppTheme.textSecondary : _catColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18), bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone ? AppTheme.green : Colors.transparent,
                    border: Border.all(
                      color: task.isDone ? AppTheme.green : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF0A0A14))
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task.name,
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.note != null) ...[
                    const SizedBox(height: 2),
                    Text(task.note!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 5),
                  Row(children: [
                    // Category pill
                    _pill('${task.category.emoji} ${task.category.label}', _catColor),
                    const SizedBox(width: 6),
                    // Repeat badge
                    if (task.repeat != RepeatType.none)
                      _pill('🔄 ${task.repeat.label}', AppTheme.blue),
                    const SizedBox(width: 6),
                    // Time
                    if (task.hasReminder)
                      _timePill(),
                  ]),
                ]),
              )),

              // Edit icon
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary.withOpacity(0.4), size: 20),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );

  Widget _timePill() {
    Color color = AppTheme.textSecondary;
    String suffix = '';
    if (_isNear)    { color = AppTheme.accent; suffix = ' — Do it now!'; }
    if (_isOverdue) { color = AppTheme.gold;   suffix = ' — Overdue'; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text('⏰ ${task.timeString}$suffix',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
