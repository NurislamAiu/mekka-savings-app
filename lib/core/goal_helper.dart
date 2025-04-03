import '../models/goal_model.dart';

class GoalHelper {
  static Map<String, dynamic> calculatePlan(GoalModel goal) {
    final now = DateTime.now();
    final deadline = goal.deadline;

    final totalDaysLeft = deadline.difference(now).inDays.clamp(1, 1000);
    final weeksLeft = (totalDaysLeft / 7).ceil();
    final monthsLeft = ((deadline.year - now.year) * 12 + deadline.month - now.month).clamp(1, 100);

    final amountLeft = (goal.targetAmount - goal.savedAmount).clamp(0, double.infinity);

    final perDay = (amountLeft / totalDaysLeft).ceilToDouble();
    final perWeek = (amountLeft / weeksLeft).ceilToDouble();
    final perMonth = (amountLeft / monthsLeft).ceilToDouble();

    return {
      'daysLeft': totalDaysLeft,
      'weeksLeft': weeksLeft,
      'monthsLeft': monthsLeft,
      'amountLeft': amountLeft,
      'perDay': perDay,
      'perWeek': perWeek,
      'perMonth': perMonth,
    };
  }

  static String getProgressStatus(GoalModel goal) {
    final now = DateTime.now();
    final totalDuration = goal.deadline.difference(goal.deadline.subtract(Duration(days: 1))).inDays;
    final daysPassed = now.difference(DateTime(now.year, now.month, now.day)).inDays;
    final daysTotal = goal.deadline.difference(now).inDays + daysPassed;

    if (daysTotal <= 0) return "🛑 Срок истёк";

    final expectedProgress = daysPassed / daysTotal;
    final actualProgress = goal.savedAmount / goal.targetAmount;

    final delta = actualProgress - expectedProgress;

    if (delta >= 0.05) {
      return "✅ Ты опережаешь план";
    } else if (delta >= -0.05) {
      return "⚠️ Идёшь примерно по плану";
    } else {
      return "🛑 Отстаёшь от плана";
    }
  }


}