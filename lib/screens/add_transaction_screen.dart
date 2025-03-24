import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String userId;
  AddTransactionScreen({required this.userId});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(_amountController.text);
      String note = _noteController.text;

      await firebaseService.addTransaction(widget.userId, amount, note);
      Navigator.pop(context); // возвращаемся обратно после добавления
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить сумму')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Сумма (тг)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите сумму';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Комментарий (необязательно)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTransaction,
                child: Text('Добавить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}