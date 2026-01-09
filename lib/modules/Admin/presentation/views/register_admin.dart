import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  final LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xFFC31432), Color(0xFF240B36)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 🔹 Gradient Border Wrapper
  Widget gradientBorderWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: redGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  /// 🔹 Input Decoration
  InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  /// 🔹 Register Admin
  Future<void> registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // 1️⃣ Create Firebase Auth User
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailCtrl.text.trim(), password: passCtrl.text.trim());

      final uid = user.user!.uid;

      // 2️⃣ Save in admins collection
      await FirebaseFirestore.instance.collection('admins').doc(uid).set({
        'admin_id': uid,
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'created_at': Timestamp.now(),
      });

      // 3️⃣ Save in users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'user_id': uid,
        'user_name': nameCtrl.text.trim(),
        'user_email': emailCtrl.text.trim(),
        'role': 'admin',
        'created_at': Timestamp.now(),
      });

      setState(() => loading = false);

      // 4️⃣ Show success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Admin registered successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nameCtrl.clear();
                emailCtrl.clear();
                passCtrl.clear();
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() => loading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Registration"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: redGradient),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: nameCtrl,
                      decoration: inputDecoration("Admin Name"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: emailCtrl,
                      decoration: inputDecoration("Email"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePassword,
                      decoration: inputDecoration(
                        "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFFC31432),
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) =>
                          v != null && v.length < 6
                              ? "Minimum 6 characters"
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: registerAdmin,
                          child: Container(
                            height: 55,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: redGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Register Admin",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
