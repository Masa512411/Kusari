const milestoneThresholds = <int>[7, 30, 100, 365];

int? reachedMilestone(int beforeStreak, int afterStreak) {
  if (afterStreak <= beforeStreak) return null;
  return milestoneThresholds.contains(afterStreak) ? afterStreak : null;
}
