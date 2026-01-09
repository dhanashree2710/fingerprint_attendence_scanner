import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController collegeCtrl = TextEditingController();
  final TextEditingController courseCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();

  bool loading = false;
  String? batchId;

  /// 🔹 Pick date
  Future<void> pickDate(TextEditingController ctrl) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  /// 🔹 Create Batch
  Future<void> createBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    // generate unique batch ID
    String uniqueId = FirebaseFirestore.instance.collection('batches').doc().id;

    await FirebaseFirestore.instance.collection('batches').doc(uniqueId).set({
      'batch_id': uniqueId,
      'college_name': collegeCtrl.text.trim(),
      'course_name': courseCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'start_date': startDateCtrl.text.trim(),
      'end_date': endDateCtrl.text.trim(),
      'created_at': Timestamp.now(),
    });

    setState(() {
      loading = false;
      batchId = uniqueId; // for QR code
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Batch")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: collegeCtrl,
                decoration: const InputDecoration(hintText: "College/Institute Name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: courseCtrl,
                decoration: const InputDecoration(hintText: "Course Name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: locationCtrl,
                decoration: const InputDecoration(hintText: "Location"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: startDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(hintText: "Start Date"),
                onTap: () => pickDate(startDateCtrl),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: endDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(hintText: "End Date"),
                onTap: () => pickDate(endDateCtrl),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: createBatch,
                      child: const Text("Create Batch"),
                    ),
              const SizedBox(height: 30),
              batchId != null
    ? Column(
        children: [
          const Text(
            "Batch QR Code (Scan to mark attendance)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          QrImageView(
            data: batchId!, // this is your unique batch id
            version: QrVersions.auto,
            size: 200,
          ),
          const SizedBox(height: 10),
          SelectableText(batchId!),
        ],
      )
    : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
