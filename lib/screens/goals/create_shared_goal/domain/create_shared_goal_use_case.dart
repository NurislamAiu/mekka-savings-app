import '../data/create_shared_goal_repository.dart';

class CreateSharedGoalUseCase {
  final CreateSharedGoalRepository repository;

  CreateSharedGoalUseCase({required this.repository});

  Future<List<Map<String, dynamic>>> getFriends() {
    return repository.fetchFriends();
  }

  Future<void> createGoal({
    required String title,
    required double amount,
    required DateTime deadline,
    required Set<String> selectedUIDs,
    required List<Map<String, dynamic>> allFriends,
  }) {
    return repository.createSharedGoal(
      title: title,
      amount: amount,
      deadline: deadline,
      selectedUIDs: selectedUIDs,
      allFriends: allFriends,
    );
  }
}