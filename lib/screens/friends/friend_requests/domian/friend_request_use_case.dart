import '../data/friend_repository.dart';

class FriendRequestUseCase {
  final FriendRepository repository;

  FriendRequestUseCase({required this.repository});

  Future<List<Map<String, dynamic>>> loadRequests() {
    return repository.fetchFriendRequests();
  }

  Future<void> accept(String uid) {
    return repository.acceptFriend(uid);
  }

  Future<void> decline(String uid) {
    return repository.declineFriend(uid);
  }
}