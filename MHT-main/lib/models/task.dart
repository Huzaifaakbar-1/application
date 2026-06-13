import 'dart:convert';

enum TaskCategory { gym, study, language, health, work, other }
enum RepeatType { none, daily, weekdays, weekends, weekly }

extension TaskCategoryExt on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.gym:      return 'Gym & Fitness';
      case TaskCategory.study:    return 'Study & Class';
      case TaskCategory.language: return 'Language';
      case TaskCategory.health:   return 'Health';
      case TaskCategory.work:     return 'Work';
      case TaskCategory.other:    return 'Other';
    }
  }
  String get emoji {
    switch (this) {
      case TaskCategory.gym:      return '💪';
      case TaskCategory.study:    return '📚';
      case TaskCategory.language: return '🌍';
      case TaskCategory.health:   return '❤️';
      case TaskCategory.work:     return '💼';
      case TaskCategory.other:    return '⚡';
    }
  }
}

extension RepeatTypeExt on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.none:     return 'Once';
      case RepeatType.daily:    return 'Every Day';
      case RepeatType.weekdays: return 'Weekdays';
      case RepeatType.weekends: return 'Weekends';
      case RepeatType.weekly:   return 'Weekly';
    }
  }
}

class Task {
  final String id;
  String name;
  String? note;
  TaskCategory category;
  RepeatType repeat;
  int? reminderHour;
  int? reminderMinute;
  bool isDone;
  bool notifiedToday;
  DateTime createdAt;

  Task({
    required this.id,
    required this.name,
    this.note,
    required this.category,
    required this.repeat,
    this.reminderHour,
    this.reminderMinute,
    this.isDone = false,
    this.notifiedToday = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasReminder => reminderHour != null && reminderMinute != null;

  String get timeString {
    if (!hasReminder) return '';
    final h = reminderHour!;
    final m = reminderMinute!.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $ampm';
  }

  bool shouldShowToday() {
    final day = DateTime.now().weekday; // 1=Mon, 7=Sun
    switch (repeat) {
      case RepeatType.daily:    return true;
      case RepeatType.weekdays: return day <= 5;
      case RepeatType.weekends: return day >= 6;
      case RepeatType.weekly:   return day == createdAt.weekday;
      case RepeatType.none:     return true;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'note': note,
    'category': category.index,
    'repeat': repeat.index,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'isDone': isDone,
    'notifiedToday': notifiedToday,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    name: j['name'],
    note: j['note'],
    category: TaskCategory.values[j['category'] ?? 5],
    repeat: RepeatType.values[j['repeat'] ?? 0],
    reminderHour: j['reminderHour'],
    reminderMinute: j['reminderMinute'],
    isDone: j['isDone'] ?? false,
    notifiedToday: j['notifiedToday'] ?? false,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  Task copyWith({
    String? name, String? note, TaskCategory? category,
    RepeatType? repeat, int? reminderHour, int? reminderMinute,
    bool? isDone, bool? notifiedToday,
  }) => Task(
    id: id,
    name: name ?? this.name,
    note: note ?? this.note,
    category: category ?? this.category,
    repeat: repeat ?? this.repeat,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    isDone: isDone ?? this.isDone,
    notifiedToday: notifiedToday ?? this.notifiedToday,
    createdAt: createdAt,
  );
}
