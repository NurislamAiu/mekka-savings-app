import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/shared_goal_provider.dart';

class SharedGoalScreen extends StatelessWidget {
  final String goalId;
  const SharedGoalScreen({required this.goalId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SharedGoalProvider()..loadSharedGoal(goalId),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Общая цель", style: GoogleFonts.cairo()),
          backgroundColor: Colors.teal,
        ),
        body: Consumer<SharedGoalProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (provider.goalData == null) {
              return Center(
                child: Text(
                  "❗ Цель не найдена или удалена",
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[700]),
                ),
              );
            }

            final goal = provider.goalData!;
            final progress = (goal['savedAmount'] ?? 0) / (goal['targetAmount'] ?? 1);
            final members = provider.members;

            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Прогресс
                _progressCard(goal, progress),

                if ((goal['description'] ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(goal['description'],
                        style: GoogleFonts.nunito(color: Colors.grey[700])),
                  ),

                SizedBox(height: 24),
                Text("👥 Участники", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
                ...members.map(_memberTile),

                SizedBox(height: 24),
                Text("🧾 Взносы", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
                if (provider.transactions.isEmpty)
                  Text("Пока нет взносов", style: GoogleFonts.nunito(color: Colors.grey))
                else
                  ...provider.transactions.map((tx) => _txTile(tx, members)),

                // 🔻 Кнопка выхода
                if (provider.currentUser?.uid != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.exit_to_app),
                      label: Text("Выйти из цели"),
                      onPressed: () => _confirmExit(context, provider, goalId),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _progressCard(Map<String, dynamic> goal, double progress) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Прогресс", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 12, color: Colors.teal),
            SizedBox(height: 8),
            Text(
              "${goal['savedAmount']} / ${goal['targetAmount']} тг",
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberTile(Map<String, dynamic> m) {
    return ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text("@${m['nickname']}", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
      subtitle: Text(m['email']),
    );
  }

  Widget _txTile(Map<String, dynamic> tx, List<Map<String, dynamic>> members) {
    final user = members.firstWhere((u) => u['uid'] == tx['by'], orElse: () => {});
    final nickname = user['nickname'] ?? 'неизвестно';
    final date = (tx['date'] as Timestamp).toDate();

    return ListTile(
      leading: Icon(Icons.attach_money, color: Colors.teal),
      title: Text("${tx['amount']} тг", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
      subtitle: Text("${tx['note'] ?? ''} — @$nickname"),
      trailing: Text(DateFormat('dd.MM', 'ru').format(date)),
    );
  }

  void _confirmExit(BuildContext context, SharedGoalProvider provider, String goalId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Выйти из цели?"),
        content: Text("Ты больше не будешь видеть прогресс и участвовать в этой цели."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Отмена"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final uid = provider.currentUser?.uid;
              if (uid == null) return;

              final goalRef = FirebaseFirestore.instance.collection('sharedGoals').doc(goalId);
              final goalDoc = await goalRef.get();

              if (!goalDoc.exists) return;

              final data = goalDoc.data();
              final members = List<Map<String, dynamic>>.from(data?['members'] ?? []);
              final myEntry = members.firstWhere((m) => m['uid'] == uid, orElse: () => {});
              final isAdmin = myEntry['role'] == 'admin';

              if (members.length == 1 && isAdmin) {
                Navigator.pop(context);
                _showInfoDialog(context, "Ты единственный админ. Нельзя выйти из цели.");
                return;
              }

              // Удаляем участника
              members.removeWhere((m) => m['uid'] == uid);

              if (members.isEmpty) {
                await goalRef.delete();
              } else {
                await goalRef.update({'members': members});

                // Уведомление остальным
                final nickname = myEntry['nickname'] ?? 'участник';
                for (var m in members) {
                  await FirebaseFirestore.instance.collection('notifications').add({
                    'toUid': m['uid'],
                    'message': "📤 @$nickname вышел из цели '${data?['title']}'",
                    'timestamp': Timestamp.now(),
                  });
                }
              }

              Navigator.pop(context); // закрыть диалог
              Navigator.pop(context); // выйти со страницы
            },
            child: Text("Выйти"),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("ℹ️ Информация"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Ок"),
          )
        ],
      ),
    );
  }
}