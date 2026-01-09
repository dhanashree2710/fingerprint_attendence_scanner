import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fingerprint_authentication/modules/Services/presentation/bloc/biometrics.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController controller =
      MobileScannerController(formats: [BarcodeFormat.qrCode]);

  bool scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Batch QR")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (BarcodeCapture capture) {
                if (scanned) return;

                final barcode = capture.barcodes.first;
                final String? batchId = barcode.rawValue;

                if (batchId == null || batchId.isEmpty) return;

                scanned = true;

                debugPrint("✅ SCANNED BATCH ID: $batchId");

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BatchAttendanceScreen(batchId: batchId),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: const Text(
              "Place QR inside the box",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}





class BatchAttendanceScreen extends StatefulWidget {
  final String batchId;

  const BatchAttendanceScreen({super.key, required this.batchId});

  @override
  State<BatchAttendanceScreen> createState() => _BatchAttendanceScreenState();
}

class _BatchAttendanceScreenState extends State<BatchAttendanceScreen> {
  final studentIdCtrl = TextEditingController();
  bool loading = false;

  Future<void> markAttendance() async {
    if (studentIdCtrl.text.isEmpty) return;

    setState(() => loading = true);

    /// 🔐 Fingerprint
    final ok = await BiometricService().authenticate();
    if (!ok) {
      setState(() => loading = false);
      return;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final query = await FirebaseFirestore.instance
        .collection('attendance')
        .where('student_id', isEqualTo: studentIdCtrl.text.trim())
        .where('batch_id', isEqualTo: widget.batchId)
        .where('date', isEqualTo: today)
        .get();

    if (query.docs.isEmpty) {
      /// ✅ IN TIME
      await FirebaseFirestore.instance.collection('attendance').add({
        'student_id': studentIdCtrl.text.trim(),
        'batch_id': widget.batchId,
        'date': today,
        'in_time': Timestamp.now(),
        'out_time': null,
        'verified_by': 'QR + Fingerprint',
      });
    } else {
      /// ✅ OUT TIME
      await query.docs.first.reference.update({
        'out_time': Timestamp.now(),
      });
    }

    setState(() => loading = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance updated successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Batch Attendance")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('batches')
            .doc(widget.batchId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Batch Details
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['course_name'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("College: ${data['college_name']}"),
                        Text("Location: ${data['location']}"),
                        Text(
                            "Duration: ${data['start_date']} - ${data['end_date']}"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔹 Student ID
                TextField(
                  controller: studentIdCtrl,
                  decoration: const InputDecoration(
                    labelText: "Student ID / Roll No",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : markAttendance,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Mark Attendance"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}