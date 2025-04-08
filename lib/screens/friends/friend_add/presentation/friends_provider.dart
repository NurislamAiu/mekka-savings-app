import 'package:flutter/material.dart';

import '../domain/entities/friend_user.dart';
import '../domain/usecases/search_user_usecase.dart';
import '../domain/usecases/send_friend_request_usecase.dart';

class FriendsProvider with ChangeNotifier {
  final SearchUserUseCase searchUserUseCase;
  final SendFriendRequestUseCase sendRequestUseCase;

  FriendsProvider({
    required this.searchUserUseCase,
    required this.sendRequestUseCase,
  });

  final controller = TextEditingController();

  FriendUser? foundUser;
  String status = '';
  bool isSearching = false;

  TextEditingController get searchController => controller;

  Future<void> searchUser() async {
    final email = controller.text.trim().toLowerCase();
    isSearching = true;
    notifyListeners();

    final (user, newStatus) = await searchUserUseCase(email);

    foundUser = user;
    status = newStatus;
    isSearching = false;
    notifyListeners();
  }

  Future<void> sendFriendRequest(BuildContext context) async {
    if (foundUser == null) return;

    await sendRequestUseCase(foundUser!.uid);
    status = 'request_sent';
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запрос отправлен 🌙'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}