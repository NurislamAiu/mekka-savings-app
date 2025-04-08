

import '../data/my_shared_goal_repository.dart';

class MySharedGoalUseCase {
  final MySharedGoalRepository repository;

  MySharedGoalUseCase(this.repository);

  Future<List<Map<String, dynamic>>> getUserSharedGoals(String uid) {
    return repository.fetchSharedGoals(uid);
  }
}