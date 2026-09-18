import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/providers/habit_weekly_rates_provider.dart';
import 'package:kusari/ui/theme/app_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(habitWeeklyRatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('達成状況')),
      body: ratesAsync.when(
        data: (rates) {
          if (rates.isEmpty) {
            return const Center(child: Text('習慣がまだありません'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '習慣ごとの週間達成率',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.1,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < rates.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    _HabitRateRow(rate: rates[i]),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }
}

class _HabitRateRow extends StatelessWidget {
  final HabitWeeklyRate rate;

  const _HabitRateRow({required this.rate});

  @override
  Widget build(BuildContext context) {
    final pct = (rate.stats.rate * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rate.habit.name, style: const TextStyle(fontSize: 13)),
            Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accent300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.neutral800,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      ],
    );
  }
}
