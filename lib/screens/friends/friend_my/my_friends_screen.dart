import 'package:flutter/material.dart';
import 'package:mekka_savings_app/screens/friends/friend_my/presentation/my_friends_provider.dart';
import 'package:mekka_savings_app/screens/friends/friend_my/widgets/my_friends_header.dart';
import 'package:mekka_savings_app/screens/friends/friend_my/widgets/my_friends_list.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/close_screen_button.dart';
import '../friend_add/friends_screen.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<MyFriendsProvider>(context, listen: false).loadFriends());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          const SafeArea(
            child: Column(
              children: [
                MyFriendsHeader(),
                Expanded(child: MyFriendsList()),
              ],
            ),
          ),
          const CloseScreenButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FriendsScreen()),
          );
        },
        child: const Icon(Icons.person_add_alt, size: 24, color: Colors.teal),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}