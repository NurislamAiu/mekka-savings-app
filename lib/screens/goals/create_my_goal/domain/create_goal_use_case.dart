import '../data/create_goal_repository.dart';

class CreateGoalUseCase {
  final CreateGoalRepository repository;

  CreateGoalUseCase({required this.repository});

  Future<void> execute({
    required String title,
    required double amount,
    required DateTime deadline,
  }) {
    return repository.createGoal(
      title: title,
      amount: amount,
      deadline: deadline,
    );
  }
}