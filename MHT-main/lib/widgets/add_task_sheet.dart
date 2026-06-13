import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/app_theme.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? existing;
  final Function(Task) onSave;
  const AddTaskSheet({super.key, this.existing, required this.onSave});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TaskCategory _cat    = TaskCategory.gym;
  RepeatType   _repeat = RepeatType.daily;
  TimeOfDay?   _time;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      _nameCtrl.text = t.name;
      _noteCtrl.text = t.note ?? '';
      _cat    = t.category;
      _repeat = t.repeat;
      if (t.hasReminder) _time = TimeOfDay(hour: t.reminderHour!, minute: t.reminderMinute!);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  void _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent, surface: AppTheme.card),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name'), backgroundColor: AppTheme.accentD),
      );
      return;
    }
    final task = Task(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: name,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      category: _cat,
      repeat: _repeat,
      reminderHour:   _time?.hour,
      reminderMinute: _time?.minute,
      isDone: widget.existing?.isDone ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    widget.onSave(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(
            width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          )),
          Text(widget.existing == null ? '✏️  Add New Habit' : '✏️  Edit Habit',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),

          // Name
          _label('Task Name'),
          _input(_nameCtrl, 'e.g. Go to Gym, German Practice...'),
          const SizedBox(height: 16),

          // Note
          _label('Note (Optional)'),
          _input(_noteCtrl, 'Add a small note...', maxLines: 2),
          const SizedBox(height: 16),

          // Category
          _label('Category'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: TaskCategory.values.map((c) {
            final sel = _cat == c;
            return GestureDetector(
              onTap: () => setState(() => _cat = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
                  border: Border.all(color: sel ? AppTheme.accent : AppTheme.border, width: sel ? 1.5 : 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${c.emoji} ${c.label}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: sel ? AppTheme.accent : AppTheme.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          // Repeat
          _label('Repeat'),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: RepeatType.values.map((r) {
              final sel = _repeat == r;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _repeat = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.blue.withOpacity(0.15) : AppTheme.card,
                      border: Border.all(color: sel ? AppTheme.blue : AppTheme.border, width: sel ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(r.label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: sel ? AppTheme.blue : AppTheme.textSecondary)),
                  ),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 16),

          // Reminder
          _label('Reminder Time'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.card, border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.alarm_rounded, color: AppTheme.gold, size: 20),
                const SizedBox(width: 10),
                Text(
                  _time == null ? 'Tap to set reminder time' : _time!.format(context),
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: _time == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_time != null)
                  GestureDetector(
                    onTap: () => setState(() => _time = null),
                    child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                widget.existing == null ? '💾  Save Habit' : '💾  Update Habit',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700,
      color: AppTheme.textSecondary, fontFamily: 'monospace')),
  );

  Widget _input(TextEditingController c, String hint, {int maxLines = 1}) => TextField(
    controller: c, maxLines: maxLines,
    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w400),
      filled: true, fillColor: AppTheme.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
  );
}
