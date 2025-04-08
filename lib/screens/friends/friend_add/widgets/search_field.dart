import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../presentation/friends_provider.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FriendsProvider>(context);

    return Column(
      children: [
        TextField(
          controller: provider.searchController,
          decoration: InputDecoration(
            hintText: "Email друга",
            prefixIcon: Icon(Icons.search, color: Colors.teal),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onSubmitted: (_) => provider.searchUser(),
        ),
        SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.searchUser,
            child: Text("Найти друга", style: GoogleFonts.nunito(fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}