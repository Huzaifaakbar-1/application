import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const _tasksKey  = 'tasks_v2';
  static const _streakKey = 'streak_v1';
  static const _lastDate  = 'last_date';
  static const _resetDate = 'reset_date';

  // ── Tasks ──────────────────────────────────────────────
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return _defaultTasks();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultTasks();
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  // ── Streak ─────────────────────────────────────────────
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<int> updateStreak(bool allDone) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateStr(DateTime.now());
    final last  = prefs.getString(_lastDate) ?? '';
    int streak  = prefs.getInt(_streakKey) ?? 0;

    if (allDone && last != today) {
      final yesterday = _dateStr(DateTime.now().subtract(const Duration(days: 1)));
      streak = (last == yesterday) ? streak + 1 : 1;
      await prefs.setInt(_streakKey, streak);
      await prefs.setString(_lastDate, today);
    } else if (!allDone) {
      // Check if streak is broken (yesterday was not recorded and today also not done)
      final yesterday = _dateStr(DateTime.now().subtract(const Duration(days: 1)));
      if (last != today && last != yesterday && streak > 0) {
        // More than one day gap — streak broken
        streak = 0;
        await prefs.setInt(_streakKey, 0);
      }
    }
    return streak;
  }

  static Future<bool> isStreakAtRisk() async {
    final prefs = await SharedPreferences.getInstance();
    final today  = _dateStr(DateTime.now());
    final last   = prefs.getString(_lastDate) ?? '';
    final streak = prefs.getInt(_streakKey) ?? 0;
    if (streak == 0) return false;
    return last != today;
  }

  // ── Daily Reset ────────────────────────────────────────
  static Future<bool> shouldReset() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateStr(DateTime.now());
    return prefs.getString(_resetDate) != today;
  }

  static Future<void> markResetDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resetDate, _dateStr(DateTime.now()));
  }

  // Zero-pad month/day so comparisons are unambiguous.
  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Default Tasks ──────────────────────────────────────
  static List<Task> _defaultTasks() => [
    Task(
      id: 'default_1',
      name: 'Go to Gym',
      category: TaskCategory.gym,
      repeat: RepeatType.daily,
      reminderHour: 7,
      reminderMinute: 0,
    ),
    Task(
      id: 'default_2',
      name: 'Cyber Security Class',
      category: TaskCategory.study,
      repeat: RepeatType.weekdays,
      reminderHour: 10,
      reminderMinute: 0,
    ),
    Task(
      id: 'default_3',
      name: 'German Language Practice',
      category: TaskCategory.language,
      repeat: RepeatType.daily,
      reminderHour: 19,
      reminderMinute: 0,
    ),
  ];
}