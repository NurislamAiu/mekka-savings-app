import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/goal_repository.dart';
import '../../../models/goal_model.dart';

class GoalUseCase {
  final GoalRepository repository;

  GoalUseCase (this.repository);

  Future<List<GoalModel>> loadGoals() async {
    final goals = await repository.fetchGoals();
    if (goals.isEmpty) {
      await repository.createDefaultGoal();
      return repository.fetchGoals();
    }
    return goals;
  }

  Future<List<GoalModel>> loadFriendsGoals() {
    return repository.fetchFriendsGoals();
  }

  Future<void> addTransaction(String goalId, double amount, String note) {
    return repository.addTransaction(goalId, amount, note);
  }

  Future<DateTime?> calculateForecastDate(GoalModel goal) async {
    final txs = await repository.fetchTransactions(goal.id);
    if (txs.isEmpty) return null;

    double total = 0;
    DateTime first = DateTime.now();

    for (int i = 0; i < txs.length; i++) {
      final tx = txs[i];
      total += (tx['amount'] ?? 0).toDouble();
      final txDate = (tx['date'] as Timestamp).toDate();
      if (i == 0) first = txDate;
    }

    final daysPassed = DateTime.now().difference(first).inDays.clamp(1, 1000);
    final avgPerDay = total / daysPassed;

    final left = (goal.targetAmount - goal.savedAmount).clamp(0, double.infinity);
    final daysToFinish = (avgPerDay > 0) ? (left / avgPerDay).ceil() : 9999;

    return DateTime.now().add(Duration(days: daysToFinish));
  }
}