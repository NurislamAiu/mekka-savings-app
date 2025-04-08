import 'package:flutter/material.dart';

import '../domian/friend_request_use_case.dart';

class FriendRequestsProvider extends ChangeNotifier {
  final FriendRequestUseCase useCase;

  FriendRequestsProvider({required this.useCase});

  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];

  Future<void> loadRequests() async {
    isLoading = true;
    notifyListeners();

    requests = await useCase.loadRequests();

    isLoading = false;
    notifyListeners();
  }

  Future<void> accept(String uid) async {
    await useCase.accept(uid);
    await loadRequests();
  }

  Future<void> decline(String uid) async {
    await useCase.decline(uid);
    await loadRequests();
  }
}