import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && nickname.isEmpty)) {
      setState(() => errorMessage = "Пожалуйста, заполните все поля");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      UserCredential cred;

      if (isLogin) {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'nickname': nickname,
          'bio': 'коплю с друзьями',
          'friends': [],
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      setState(() => errorMessage = "Ошибка: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    SvgPicture.asset('assets/kaaba.svg', height: 60),
                    SizedBox(height: 20),

                    Text(
                      isLogin ? "Вход" : "Регистрация",
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),

                    SizedBox(height: 30),

                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email", Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      decoration: _inputDecoration("Пароль", Icons.lock_outline),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),

                    if (!isLogin)
                      TextField(
                        controller: _nicknameController,
                        decoration: _inputDecoration("Никнейм", Icons.person_outline),
                      ),

                    if (errorMessage.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text(errorMessage,
                          style: GoogleFonts.nunito(
                            color: Colors.red,
                            fontSize: 14,
                          )),
                    ],

                    SizedBox(height: 30),

                    isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(Icons.check_circle_outline, color: Colors.white),
                        label: Text(
                          isLogin ? "Войти" : "Зарегистрироваться",
                          style: GoogleFonts.nunito(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          errorMessage = '';
                        });
                      },
                      child: Text(
                        isLogin
                            ? "Нет аккаунта? Зарегистрироваться"
                            : "Уже есть аккаунт? Войти",
                        style: GoogleFonts.nunito(color: Colors.teal[700]),
                      ),
                    ),

                    SizedBox(height: 30),

                    Text(
                      "“Поистине, дела оцениваются по намерению…” (Хадис)",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal.shade100),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}