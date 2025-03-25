import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // 🌅 Красивый градиент (как HomeScreen)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/kaaba.svg', height: 32),
                      const SizedBox(width: 10),
                      Text("Настройки", style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[800])),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 📜 Аят
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "فَاذْكُرُونِي أَذْكُرْكُمْ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontFamily: 'Amiri'),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "«Поминайте Меня, и Я буду помнить о вас» (Коран, 2:152)",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 👤 Карточка пользователя
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(Icons.person, color: Colors.teal[800]),
                      ),
                      title: Text(user?.displayName ?? "Пользователь", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                      subtitle: Text(user?.email ?? ''),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⚙️ Основные настройки
                  _settingItem(Icons.notifications_outlined, "Уведомления", () {}),
                  _settingItem(Icons.palette_outlined, "Цветовая тема", () {}),
                  _settingItem(Icons.language_outlined, "Язык", () {}),
                  _settingItem(Icons.lock_outline, "Изменить пароль", () {}),
                  _settingItem(Icons.delete_outline, "Удалить аккаунт", () {}, danger: true),

                  const SizedBox(height: 30),

                  // 🚪 Выйти
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text("Выйти из аккаунта", style: GoogleFonts.nunito(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔙 Закрыть экран
          Positioned(
            top: 50,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String text, VoidCallback onTap, {bool danger = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: danger ? Colors.red[400] : Colors.teal),
        title: Text(text, style: GoogleFonts.nunito(color: danger ? Colors.red[400] : Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}