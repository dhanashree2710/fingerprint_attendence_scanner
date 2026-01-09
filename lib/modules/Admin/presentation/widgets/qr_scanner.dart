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




class BatchAttendanceScreen extends StatelessWidget {
  final String batchId;

  const BatchAttendanceScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Batch Attendance")),
      body: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Batch ID",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(batchId, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
