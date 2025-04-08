import '../entities/friend_user.dart';
import '../repositories/friends_repository.dart';

class SearchUserUseCase {
  final FriendsRepository repository;

  SearchUserUseCase(this.repository);

  Future<(FriendUser?, String)> call(String email) async {
    final user = await repository.searchUserByEmail(email);
    if (user == null) return (null, 'not_found');

    final status = await repository.checkFriendStatus(user.uid);
    return (user, status);
  }
}