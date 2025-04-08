import 'package:flutter/material.dart';

import '../../friend_add/domain/entities/friend_user.dart';
import '../domain/usecases/get_my_friends_usecase.dart';

class MyFriendsProvider with ChangeNotifier {
  final GetMyFriendsUseCase getMyFriendsUseCase;

  MyFriendsProvider({required this.getMyFriendsUseCase});

  List<FriendUser> friends = [];
  bool isLoading = true;

  Future<void> loadFriends() async {
    isLoading = true;
    notifyListeners();

    friends = await getMyFriendsUseCase();
    isLoading = false;
    notifyListeners();
  }
}