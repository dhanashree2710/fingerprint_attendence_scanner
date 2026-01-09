import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  String? selectedBatch;
  List<Map<String, dynamic>> batches = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchBatches();
  }

Future<void> fetchBatches() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('batches').get();

    if (snapshot.docs.isEmpty) {
      debugPrint("❌ No batches found");
    }

    final fetchedBatches = snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'id': data['batch_id'] as String,
        'name':
            "${data['course_name']} - ${data['college_name']}",
      };
    }).toList();

    setState(() {
      batches = fetchedBatches;
    });

    debugPrint("✅ Batches loaded: ${batches.length}");
  } catch (e) {
    debugPrint("🔥 Error fetching batches: $e");
  }
}


  /// 🔹 Register student
  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedBatch == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a batch")));
      return;
    }

    setState(() => loading = true);

    final doc = FirebaseFirestore.instance.collection('students').doc();

    await doc.set({
      'student_id': doc.id,
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'batch_id': selectedBatch,
      'created_at': Timestamp.now(),
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Student registered successfully")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Student")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: "Name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(hintText: "Email"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(hintText: "Phone Number"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(hintText: "Address"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              batches.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
  value: selectedBatch,
  items: batches
      .map(
        (b) => DropdownMenuItem<String>(
          value: b['id'] as String, // cast to String
          child: Text(b['name'] as String), // cast to String
        ),
      )
      .toList(),
  onChanged: (val) {
    setState(() {
      selectedBatch = val;
    });
  },
  decoration: const InputDecoration(
    hintText: "Select Batch",
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12),
  ),
  validator: (v) => v == null ? "Required" : null,
),

              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registerStudent,
                      child: const Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
