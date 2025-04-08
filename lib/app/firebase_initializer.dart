import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await initializeDateFormatting('ru');
  }
}