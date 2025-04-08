import '../domain/i_shared_goal_repository.dart';

class SharedGoalUseCase {
  final ISharedGoalRepository repository;

  SharedGoalUseCase({required this.repository});

  Future<Map<String, dynamic>?> fetchGoal(String goalId) => repository.fetchGoal(goalId);
  Future<List<Map<String, dynamic>>> fetchTransactions(String goalId) => repository.fetchTransactions(goalId);
  Future<void> addTransaction(String goalId, double amount, String note, String uid) =>
      repository.addTransaction(goalId, amount, note, uid);
  Future<void> confirmParticipation(String goalId) => repository.confirmParticipation(goalId);
  Future<void> exitGoal(String goalId) => repository.exitGoal(goalId);
}