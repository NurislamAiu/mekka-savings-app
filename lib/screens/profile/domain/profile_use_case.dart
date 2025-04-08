import '../data/profile_repository.dart';

class ProfileUseCase {
  final ProfileRepository repository;

  ProfileUseCase({required this.repository});

  Future<Map<String, dynamic>> getUserInfo() => repository.fetchUserProfile();

  Future<Map<String, dynamic>> getGoalInfo(String goalId) =>
      repository.fetchGoalData(goalId);

  Future<int> getTransactionCount(String goalId) =>
      repository.fetchTransactionCount(goalId);
}