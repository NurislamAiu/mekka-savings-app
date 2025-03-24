import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();
  final String userId = "testUser"; // Временно для тестирования

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Цель накопления')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firebaseService.getGoalStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          var data = snapshot.data!.data() as Map<String, dynamic>;
          double savedAmount = data['savedAmount'].toDouble();
          double targetAmount = data['targetAmount'].toDouble();
          String title = data['title'];

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: savedAmount / targetAmount,
                  minHeight: 15,
                ),
                SizedBox(height: 10),
                Text(
                  '${savedAmount.toStringAsFixed(0)} / ${targetAmount.toStringAsFixed(0)} тг',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}