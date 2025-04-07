import 'package:flutter/material.dart';

class CloseScreenButton extends StatelessWidget {
  const CloseScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 30,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, size: 24, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
