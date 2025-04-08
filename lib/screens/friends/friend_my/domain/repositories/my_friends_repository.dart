import '../../../friend_add/domain/entities/friend_user.dart';

abstract class MyFriendsRepository {
  Future<List<FriendUser>> getMyFriends();
}