import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../services/app_theme.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/quotes.dart';
import '../widgets/task_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/add_task_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Task> _tasks = [];
  int _streak = 0;
  bool _atRisk = false;
  String _quote = Quotes.next();
  String _filter = 'all'; // 'all' | 'pending' | 'done'
  Timer? _timer;
  late AnimationController _quoteAnim;
  late Animation<double> _quoteFade;

  // Filter options: list of (value, label) pairs — using explicit type, not
  // record syntax, to avoid any Dart version ambiguity.
  static const List<List<String>> _filterOptions = [
    ['all', 'All'],
    ['pending', 'Pending'],
    ['done', '✓ Done'],
  ];

  @override
  void initState() {
    super.initState();
    _quoteAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _quoteFade = CurvedAnimation(parent: _quoteAnim, curve: Curves.easeIn);
    _quoteAnim.forward();
    _load();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkReminders(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quoteAnim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Daily reset — reset isDone / notifiedToday for repeating tasks
    if (await StorageService.shouldReset()) {
      final tasks = await StorageService.loadTasks();
      for (final t in tasks) {
        if (t.repeat != RepeatType.none && t.shouldShowToday()) {
          t.isDone = false;
          t.notifiedToday = false;
        }
      }
      await StorageService.saveTasks(tasks);
      await StorageService.markResetDone();
    }

    final tasks  = await StorageService.loadTasks();
    final streak = await StorageService.getStreak();
    final atRisk = await StorageService.isStreakAtRisk();

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _streak = streak;
      _atRisk = atRisk;
    });

    if (atRisk && streak > 0) {
      await NotificationService.showStreakAtRisk(streak);
    }
  }

  Future<void> _saveAndRefresh() async {
    await StorageService.saveTasks(_tasks);

    final today   = _tasks.where((t) => t.shouldShowToday()).toList();
    final allDone = today.isNotEmpty && today.every((t) => t.isDone);
    final streak  = await StorageService.updateStreak(allDone);
    final atRisk  = await StorageService.isStreakAtRisk();

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _atRisk = atRisk;
    });
  }

  void _toggle(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      final t = _tasks.firstWhere((x) => x.id == id);
      t.isDone = !t.isDone;
    });
    _saveAndRefresh();
    final t = _tasks.firstWhere((x) => x.id == id);
    if (t.isDone) _showToast('🎉 ${t.name} — Done!');
  }

  void _delete(String id) {
    final t = _tasks.firstWhere((x) => x.id == id);
    NotificationService.cancelTaskReminder(id);
    setState(() => _tasks.removeWhere((x) => x.id == id));
    _saveAndRefresh();
    _showToast('🗑️ "${t.name}" removed');
  }

  void _openAdd([Task? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTaskSheet(
        existing: existing,
        onSave: (task) async {
          setState(() {
            final idx = _tasks.indexWhere((x) => x.id == task.id);
            if (idx >= 0) {
              _tasks[idx] = task;
            } else {
              _tasks.insert(0, task);
            }
          });
          await _saveAndRefresh();
          if (task.hasReminder) {
            await NotificationService.scheduleTaskReminder(task);
          }
          _showToast(
            existing == null ? '✅ "${task.name}" added!' : '✅ Updated!',
          );
        },
      ),
    );
  }

  /// Poll-based fallback reminder (fires even without exact alarm permission).
  void _checkReminders() {
    bool changed = false;
    for (final t in _tasks) {
      if (!t.isDone && t.hasReminder && !t.notifiedToday) {
        final now = DateTime.now();
        final rem = DateTime(
          now.year, now.month, now.day,
          t.reminderHour!, t.reminderMinute!,
        );
        final diff = rem.difference(now).inMinutes;
        if (diff >= 0 && diff <= 1) {
          t.notifiedToday = true;
          changed = true;
        }
      }
    }
    if (changed) StorageService.saveTasks(_tasks);
  }

  void _newQuote() {
    _quoteAnim.reverse().then((_) {
      if (!mounted) return;
      setState(() => _quote = Quotes.next());
      _quoteAnim.forward();
    });
  }

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Task> get _filtered {
    final today = _tasks.where((t) => t.shouldShowToday()).toList();
    if (_filter == 'pending') return today.where((t) => !t.isDone).toList();
    if (_filter == 'done')    return today.where((t) =>  t.isDone).toList();
    return today;
  }

  int get _doneCount  => _tasks.where((t) => t.shouldShowToday() && t.isDone).length;
  int get _totalCount => _tasks.where((t) => t.shouldShowToday()).length;

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final days   = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppTheme.bg,
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Daily Habits',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick add button
                  GestureDetector(
                    onTap: _openAdd,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Streak + Quote + Filters ──────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Streak Card
                StreakCard(
                  streak: _streak,
                  atRisk: _atRisk,
                  done: _doneCount,
                  total: _totalCount,
                ),

                // Motivation Quote Card
                GestureDetector(
                  onTap: _newQuote,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        top:    BorderSide(color: AppTheme.accent, width: 2),
                        right:  BorderSide(color: AppTheme.border),
                        bottom: BorderSide(color: AppTheme.border),
                        left:   BorderSide(color: AppTheme.border),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              "⚡  TODAY'S MOTIVATION",
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accent,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Tap for new',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _quoteFade,
                          child: Text(
                            _quote,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Pills
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      const Text(
                        'TASKS',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      ..._filterOptions.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = e[0]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _filter == e[0]
                                    ? AppTheme.accent
                                    : AppTheme.card,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _filter == e[0]
                                      ? AppTheme.accent
                                      : AppTheme.border,
                                ),
                              ),
                              child: Text(
                                e[1],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _filter == e[0]
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Task List ─────────────────────────────────────
          _filtered.isEmpty
              ? SliverToBoxAdapter(child: _emptyState())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final t = _filtered[i];
                        return TaskCard(
                          task: t,
                          onToggle: () => _toggle(t.id),
                          onEdit:   () => _openAdd(t),
                          onDelete: () => _delete(t.id),
                        );
                      },
                      childCount: _filtered.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Habit',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
    child: Column(
      children: [
        Text(
          _filter == 'done' ? '🌟' : '📋',
          style: const TextStyle(fontSize: 52),
        ),
        const SizedBox(height: 16),
        Text(
          _filter == 'done'
              ? 'No tasks completed yet.\nKeep going!'
              : 'No tasks here.\nTap + to add a new habit!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}