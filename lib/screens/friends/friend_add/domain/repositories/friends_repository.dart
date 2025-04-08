import '../../domain/entities/friend_user.dart';

abstract class FriendsRepository {
  Future<FriendUser?> searchUserByEmail(String email);
  Future<String> checkFriendStatus(String uid);
  Future<void> sendFriendRequest(String targetUid);
}