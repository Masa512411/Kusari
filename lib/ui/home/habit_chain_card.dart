import 'package:flutter/material.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/providers/habit_summaries_provider.dart';
import 'package:kusari/ui/theme/app_theme.dart';

const _dowLabels = ['月', '火', '水', '木', '金', '土', '日'];

class HabitChainCard extends StatelessWidget {
  final HabitSummary summary;
  final VoidCallback onToggle;
  final VoidCallback onOpenDetail;

  const HabitChainCard({
    super.key,
    required this.summary,
    required this.onToggle,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = summary.currentStreak ~/ 7;
    final tintFraction = (weeks * 0.06).clamp(0.0, 0.30);
    final cardBg = weeks == 0
        ? AppColors.surface
        : Color.lerp(AppColors.surface, AppColors.accent, tintFraction)!;
    final borderAlpha = weeks == 0
        ? 0
        : ((0.20 + weeks * 0.10).clamp(0.0, 0.70) * 255).round();

    final today = Date.today();
    final recentDays = [for (var i = 6; i >= 0; i--) Date(today.epochDay - i)];

    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: AppColors.accent.withAlpha(borderAlpha)),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${summary.currentStreak}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent300,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '日連続',
                  style: TextStyle(fontSize: 11, color: AppColors.text.withAlpha(128)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < recentDays.length; i++)
                  _ChainLink(
                    date: recentDays[i],
                    index: i,
                    isToday: recentDays[i] == today,
                    done: summary.completions.contains(recentDays[i]),
                    linkedToPrevious:
                        i > 0 &&
                        summary.completions.contains(recentDays[i]) &&
                        summary.completions.contains(recentDays[i - 1]),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onToggle,
              style: OutlinedButton.styleFrom(
                foregroundColor: summary.isCompletedToday
                    ? AppColors.accent300
                    : AppColors.text.withAlpha(179),
                backgroundColor: summary.isCompletedToday
                    ? AppColors.accent.withAlpha(31)
                    : Colors.transparent,
                side: BorderSide(
                  color: summary.isCompletedToday
                      ? AppColors.accent
                      : AppColors.divider,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: Icon(
                summary.isCompletedToday
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 20,
              ),
              label: Text(summary.isCompletedToday ? '達成済み' : 'タップして完了'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChainLink extends StatelessWidget {
  final Date date;
  final int index;
  final bool isToday;
  final bool done;
  final bool linkedToPrevious;

  const _ChainLink({
    required this.date,
    required this.index,
    required this.isToday,
    required this.done,
    required this.linkedToPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final rotated = index.isOdd;
    final borderColor = done
        ? AppColors.accent
        : (isToday ? AppColors.accent.withAlpha(140) : AppColors.divider);
    final labelColor = isToday
        ? AppColors.accent300
        : AppColors.text.withAlpha(115);

    return Expanded(
      child: Transform.translate(
        offset: Offset(index == 0 ? 0 : -9, 0),
        child: Column(
          children: [
            Transform.rotate(
              angle: rotated ? 1.5708 : 0,
              child: Container(
                width: 19,
                height: 30,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.accent.withAlpha(89)
                      : Colors.transparent,
                  border: Border.all(color: borderColor, width: 2.5),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    if (isToday)
                      BoxShadow(
                        color: AppColors.accent.withAlpha(89),
                        spreadRadius: 2,
                      )
                    else if (linkedToPrevious)
                      BoxShadow(
                        color: AppColors.accent.withAlpha(115),
                        blurRadius: 6,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _dowLabels[date.toDateTime().weekday - 1],
              style: TextStyle(fontSize: 10, color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
