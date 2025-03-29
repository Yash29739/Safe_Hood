import 'package:flutter/material.dart';
import 'package:safe_hood/mainScreens/Security/emergency_contact.dart';
import 'package:safe_hood/mainScreens/Security/gaurd_patrol.dart';
import 'package:safe_hood/mainScreens/Security/incident_report.dart';
import 'package:safe_hood/mainScreens/users/community/visitorenteryscreen.dart';

class SecurityDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            DashboardCard(
              title: "Visitor Logs",
              icon: Icons.assignment,
              onTap: () => _navigateTo(context, VisitorEntryScreen()),
            ),
            DashboardCard(
              title: "Incident Reports",
              icon: Icons.warning,
              onTap: () => _navigateTo(context, IncidentReportsPage()),
            ),
            DashboardCard(
              title: "Emergency Contacts",
              icon: Icons.phone,
              onTap: () => _navigateTo(context, EmergencyContactsPage()),
            ),
            DashboardCard(
              title: "Guard Patrol",
              icon: Icons.directions_walk,
              onTap: () => _navigateTo(context, GuardPatrolPage()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DashboardCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xFFF2E3FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color(0xFF6A007C)),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A007C),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
