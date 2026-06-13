import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class StreakCard extends StatelessWidget {
  final int streak;
  final bool atRisk;
  final int done;
  final int total;

  const StreakCard({
    super.key,
    required this.streak,
    required this.atRisk,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: atRisk ? AppTheme.gold.withOpacity(0.5) : AppTheme.border,
          width: atRisk ? 1.5 : 1,
        ),
      ),
      child: Row(children: [
        // Streak Circle
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: atRisk
                  ? [AppTheme.gold, AppTheme.accent]
                  : [AppTheme.accent, AppTheme.accentD],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$streak', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
            const Text('🔥', style: TextStyle(fontSize: 14)),
          ]),
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(
              streak == 0 ? 'Start your streak!' : '$streak-Day Streak',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
            ),
            if (atRisk) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                ),
                child: const Text('⚠️ At Risk!',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.gold)),
              ),
            ],
          ]),
          const SizedBox(height: 4),
          Text(
            atRisk
                ? 'Complete tasks today to save your streak!'
                : done == total && total > 0
                    ? '🏆 All done! Streak saved!'
                    : '$done of $total tasks done today',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.07),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct == 1.0 ? AppTheme.green : AppTheme.accent,
              ),
            ),
          ),
        ])),
      ]),
    );
  }
}
