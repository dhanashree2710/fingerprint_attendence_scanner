import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fingerprint_authentication/modules/Services/presentation/bloc/biometrics.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController controller = MobileScannerController();
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
      body: MobileScanner(
        controller: controller,
        fit: BoxFit.cover,
        onDetect: (BarcodeCapture capture) {
          if (scanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final String? batchId = barcodes.first.rawValue;
          if (batchId == null || batchId.isEmpty) return;

          scanned = true;

          debugPrint("✅ QR SCANNED: $batchId");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BatchAttendanceScreen(batchId: batchId),
            ),
          );
        },
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

    // 🔐 Fingerprint authentication
    final ok = await BiometricService().authenticate();
    if (!ok) {
      setState(() => loading = false);
      return;
    }

    await FirebaseFirestore.instance.collection('attendance').add({
      'student_id': studentIdCtrl.text.trim(),
      'batch_id': widget.batchId,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'in_time': Timestamp.now(),
      'verified_by': 'QR + Fingerprint',
    });

    setState(() => loading = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance marked successfully")),
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
                /// Batch Details Card
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
                        Text("Institute: ${data['institute_name']}"),
                        Text("Location: ${data['location']}"),
                        Text("Duration: ${data['start_date']} - ${data['end_date']}"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Student ID Input
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
