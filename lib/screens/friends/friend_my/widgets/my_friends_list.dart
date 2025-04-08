import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../presentation/my_friends_provider.dart';
import 'my_friends_empty.dart';

class MyFriendsList extends StatelessWidget {
  const MyFriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyFriendsProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.friends.isEmpty) {
      return const MyFriendsEmpty();
    }

    return RefreshIndicator(
      onRefresh: provider.loadFriends,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: provider.friends.length,
        itemBuilder: (context, index) {
          final friend = provider.friends[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Icon(Icons.person, color: Colors.teal[800]),
              ),
              title: Text(
                "@${friend.nickname}",
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(friend.email),
            ),
          );
        },
      ),
    );
  }
}