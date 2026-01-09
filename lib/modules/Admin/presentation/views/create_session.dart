import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BatchListScreen extends StatelessWidget {
  const BatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Batches"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('batches')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final batches = snapshot.data!.docs;

          if (batches.isEmpty) {
            return const Center(child: Text("No batches found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final data = batches[index];
              final batchId = data.id;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Batch Info
                      Text(
                        data['course_name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("Institute/College: ${data['college_name']}"),
                      Text("Location: ${data['location']}"),
                      Text("Start Date: ${data['start_date']}"),
                      Text("End Date: ${data['end_date']}"),

                      const SizedBox(height: 16),

                      /// QR Code
                      Center(
                        child: QrImageView(
                          data: batchId,
                          size: 150,
                          backgroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "Scan to Mark Attendance",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
