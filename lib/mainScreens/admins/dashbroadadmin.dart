import 'package:flutter/material.dart';
import 'package:safe_hood/mainScreens/admins/ManageComplaints.dart';
import 'package:safe_hood/mainScreens/admins/ManageResidents.dart';
import 'package:safe_hood/mainScreens/admins/adminAddNotices.dart';
import 'package:safe_hood/mainScreens/admins/adminManageStaff.dart';
import 'package:safe_hood/mainScreens/admins/adminSecurityManagement.dart';
import 'package:safe_hood/mainScreens/admins/adminmanageevents.dart';
import 'package:safe_hood/mainScreens/admins/adminrulesand%20regulation.dart';
import 'package:safe_hood/mainScreens/admins/adminvisitors.dart';



class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildGridItem(context, "Manage Complaints", Icons.report, const ManageComplaintsScreen()),
            _buildGridItem(context, "Add Notices", Icons.announcement,  AdminNoticeBoard()),
            _buildGridItem(context, "Manage Events", Icons.event, const AdminEventsScreen()),
            _buildGridItem(context, "Visitor Logs", Icons.group, const VisitorLogScreen()),
            _buildGridItem(context, "Manage Staff", Icons.people,  AdminStaffManagementPage()),
            _buildGridItem(context, "Manage Residents", Icons.person, const AdminNeighborManagementScreen ()),
            _buildGridItem(context, "Security Management", Icons.security, const SecurityManagementScreen()),
            _buildGridItem(context, "ruless", Icons.message, const AdminRulesPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.deepPurple),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Screen Classes

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildScreen(context, "Manage Events");
  }
}

class ManageVisitorsScreen extends StatelessWidget {
  const ManageVisitorsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildScreen(context, "Visitor Logs");
  }
}






class BroadcastMessagesScreen extends StatelessWidget {
  const BroadcastMessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildScreen(context, "Broadcast Messages");
  }
}

// Utility Function for Screens
Widget _buildScreen(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title), backgroundColor: Colors.deepPurple),
    body: Center(
      child: Text(
        "$title Screen",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
