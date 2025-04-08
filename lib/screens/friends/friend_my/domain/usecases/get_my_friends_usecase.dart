import '../../../friend_add/domain/entities/friend_user.dart';
import '../entities/friend_user.dart';
import '../repositories/my_friends_repository.dart';

class GetMyFriendsUseCase {
  final MyFriendsRepository repository;

  GetMyFriendsUseCase(this.repository);

  Future<List<FriendUser>> call() {
    return repository.getMyFriends();
  }
}