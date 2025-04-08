import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  runApp(const App());
}