import 'package:flutter/material.dart';

class SelectFriendsList extends StatelessWidget {
  final List<Map<String, dynamic>> allFriends;
  final Set<String> selectedUIDs;
  final void Function(String uid, bool selected) onSelectionChanged;

  const SelectFriendsList({
    super.key,
    required this.allFriends,
    required this.selectedUIDs,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: allFriends.map((f) {
        final isSelected = selectedUIDs.contains(f['uid']);
        return CheckboxListTile(
          activeColor: Colors.teal,
          value: isSelected,
          title: Text("@${f['nickname']}"),
          subtitle: Text(f['email']),
          onChanged: (val) => onSelectionChanged(f['uid'], val ?? false),
        );
      }).toList(),
    );
  }
}