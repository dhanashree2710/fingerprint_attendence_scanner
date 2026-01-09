import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({super.key});

  String formatTime(Timestamp? ts) {
    if (ts == null) return "-";
    return DateFormat('hh:mm a').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('in_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendanceDocs = snapshot.data!.docs;

          if (attendanceDocs.isEmpty) {
            return const Center(child: Text("No attendance records found"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("Roll No")),
                  DataColumn(label: Text("Student Name")),
                  DataColumn(label: Text("Batch")),
                  DataColumn(label: Text("Course")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("In Time")),
                  DataColumn(label: Text("Out Time")),
                ],
                rows: attendanceDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return DataRow(
                    cells: [
                      DataCell(Text(data['student_id'] ?? "-")),
                      DataCell(
                        _StudentNameWidget(
                          rollNo: data['student_id'],
                        ),
                      ),
                      DataCell(
                        _BatchCollegeWidget(
                          batchId: data['batch_id'],
                        ),
                      ),
                      DataCell(
                        _BatchCourseWidget(
                          batchId: data['batch_id'],
                        ),
                      ),
                      DataCell(Text(data['date'] ?? "-")),
                      DataCell(Text(formatTime(data['in_time']))),
                      DataCell(Text(formatTime(data['out_time']))),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------------------------------------------------- */
/* 🔹 FETCH STUDENT NAME USING ROLL NO                        */
/* ---------------------------------------------------------- */

class _StudentNameWidget extends StatelessWidget {
  final String rollNo;

  const _StudentNameWidget({required this.rollNo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('students')
          .where('roll_no', isEqualTo: rollNo)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("-");
        }

        final student = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return Text(student['name'] ?? "-");
      },
    );
  }
}

/* ---------------------------------------------------------- */
/* 🔹 FETCH BATCH COLLEGE NAME                                */
/* ---------------------------------------------------------- */

class _BatchCollegeWidget extends StatelessWidget {
  final String batchId;

  const _BatchCollegeWidget({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('batches')
          .doc(batchId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("-");
        }

        final batch = snapshot.data!.data() as Map<String, dynamic>;
        return Text(batch['college_name'] ?? "-");
      },
    );
  }
}

/* ---------------------------------------------------------- */
/* 🔹 FETCH COURSE NAME                                       */
/* ---------------------------------------------------------- */

class _BatchCourseWidget extends StatelessWidget {
  final String batchId;

  const _BatchCourseWidget({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('batches')
          .doc(batchId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("-");
        }

        final batch = snapshot.data!.data() as Map<String, dynamic>;
        return Text(batch['course_name'] ?? "-");
      },
    );
  }
}
