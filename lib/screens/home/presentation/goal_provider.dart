import 'package:flutter/material.dart';
import '../../../models/goal_model.dart';
import '../domain/goal_use_case.dart';

class GoalProvider extends ChangeNotifier {
  final GoalUseCase useCase;

  GoalProvider({required this.useCase});

  List<GoalModel> goals = [];
  List<GoalModel> friendsGoals = [];
  GoalModel? currentGoal;
  DateTime? forecastDate;

  bool _goalReachedShown = false;

  bool get isLoading => currentGoal == null;
  bool get showGoalReached =>
      !_goalReachedShown &&
          currentGoal != null &&
          currentGoal!.savedAmount >= currentGoal!.targetAmount;

  double get progress =>
      currentGoal == null || currentGoal!.targetAmount == 0
          ? 0
          : currentGoal!.savedAmount / currentGoal!.targetAmount;

  void markGoalReachedAsShown() {
    _goalReachedShown = true;
    notifyListeners();
  }

  Future<void> loadGoals() async {
    goals = await useCase.loadGoals();
    friendsGoals = await useCase.loadFriendsGoals();
    currentGoal = goals.isNotEmpty ? goals[0] : null;
    forecastDate = await useCase.calculateForecastDate(currentGoal!);
    notifyListeners();
  }

  void switchGoal(GoalModel goal) {
    currentGoal = goal;
    notifyListeners();
  }

  Future<void> addTransaction(double amount, String note) async {
    if (currentGoal == null) return;
    await useCase.addTransaction(currentGoal!.id, amount, note);
    await loadGoals();
  }

  Future<DateTime?> calculateForecastDate() async {
    if (currentGoal == null) return null;
    return useCase.calculateForecastDate(currentGoal!);
  }
}