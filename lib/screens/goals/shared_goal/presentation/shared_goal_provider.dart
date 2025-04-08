import 'package:flutter/material.dart';
import '../domain/shared_goal_use_case.dart';

class SharedGoalProvider extends ChangeNotifier {
  final SharedGoalUseCase useCase;

  SharedGoalProvider({required this.useCase});

  bool isLoading = true;
  Map<String, dynamic>? goalData;
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> transactions = [];

  Future<void> loadSharedGoal(String goalId) async {
    isLoading = true;
    notifyListeners();

    goalData = await useCase.fetchGoal(goalId);
    if (goalData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    members = List<Map<String, dynamic>>.from(goalData!['members'] ?? []);
    transactions = await useCase.fetchTransactions(goalId);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(String goalId, double amount, String note, String uid) async {
    await useCase.addTransaction(goalId, amount, note, uid);
    await loadSharedGoal(goalId);
  }

  Future<void> confirmParticipation(String goalId) async {
    await useCase.confirmParticipation(goalId);
    await loadSharedGoal(goalId);
  }

  Future<void> exitGoal(String goalId) async {
    await useCase.exitGoal(goalId);
    goalData = null;
    members = [];
    transactions = [];
    notifyListeners();
  }
}