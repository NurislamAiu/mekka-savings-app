import '../repositories/friends_repository.dart';

class SendFriendRequestUseCase {
  final FriendsRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<void> call(String targetUid) async {
    await repository.sendFriendRequest(targetUid);
  }
}