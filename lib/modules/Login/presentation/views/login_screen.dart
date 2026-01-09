import 'package:fingerprint_authentication/modules/Admin/presentation/views/admin_dashboard.dart';
import 'package:fingerprint_authentication/modules/Services/presentation/bloc/biometrics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool showBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showBiometric = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> login() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('biometric_enabled', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }

  Future<void> biometricLogin() async {
    final ok = await BiometricService().authenticate();
    if (!ok) return;

    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: "Email")),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(hintText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            if (showBiometric)
              IconButton(
                icon: const Icon(Icons.fingerprint, size: 40),
                onPressed: biometricLogin,
              )
          ],
        ),
      ),
    );
  }
}
