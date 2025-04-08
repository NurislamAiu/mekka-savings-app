abstract class ISharedGoalRepository {
  Future<Map<String, dynamic>?> fetchGoal(String goalId);
  Future<List<Map<String, dynamic>>> fetchTransactions(String goalId);
  Future<void> addTransaction(String goalId, double amount, String note, String uid);
  Future<void> confirmParticipation(String goalId);
  Future<void> exitGoal(String goalId);
}