import 'package:fingerprint_authentication/modules/Admin/presentation/widgets/qr_scanner.dart';
import 'package:fingerprint_authentication/modules/Attendence/presentation/views/view_attendence.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint_authentication/modules/Students/presentation/views/student_registration.dart';

import 'create_batch.dart';
import 'create_session.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ LEFT MENU (Drawer)
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),

        // ✅ RIGHT SIDE LOGO
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/logo.png', // <-- your logo path
              height: 32,
            ),
          ),
        ],
      ),

      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _card(context, "Register Student", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterStudent()),
            );
          }),
          _card(context, "Create Batch", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateBatchScreen()),
            );
          }),
          _card(context, "Create Session QR", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BatchListScreen()),
            );
          }),
           _card(context, "Attendence", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceListScreen()),
            );
          }),
        ],
      ),
    );
  }

  // 🔹 Dashboard Cards
  Widget _card(BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 🔹 Drawer Menu
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Admin"),
            accountEmail: Text("admin@college.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.admin_panel_settings, size: 40),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Register Student"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterStudent()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text("Create Batch"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateBatchScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("Batch Details"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BatchListScreen()),
              );
            },
          ),
ListTile(
            leading:const Icon(Icons.qr_code_scanner),
            title: const Text("Scan Batch QR"),
            onTap: () {
              Navigator.pop(context);
             Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanQRScreen()),
    );
            },
          ),
          ListTile(
            leading:const Icon(Icons.calendar_month_outlined),
            title: const Text("Attendence"),
            onTap: () {
              Navigator.pop(context);
             Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceListScreen()),
    );
            },
          ),
          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // or FirebaseAuth signOut
            },
          ),
        ],
      ),
    );
  }
}
