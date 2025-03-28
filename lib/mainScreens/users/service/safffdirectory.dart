import 'package:flutter/material.dart';

class StaffDirectoryPage extends StatelessWidget {
  const StaffDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF),
     appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Color(0xFFCC00FF),
        title: _buildHeader(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Security Team"),
            _buildStaffCard("John Martinez", "Head of Security", "Available 24/7", Colors.blue),
            _buildStaffCard("Sarah Wilson", "Night Shift Supervisor", "8:00 PM - 5:00 AM", Colors.blue),
            SizedBox(height: 16),

            _buildSectionTitle("Maintenance Team"),
            _buildStaffCard("Robert Chen", "Lead Maintenance Engineer", "Mon-Fri: 8:00 AM - 5:00 PM", Colors.teal),
            _buildStaffCard("Mike Thompson", "General Maintenance", "Mon-Fri: 8:00 AM - 5:00 PM", Colors.teal),
            SizedBox(height: 16),

            _buildSectionTitle("Administrative Staff"),
            _buildStaffCard("Emily Parker", "Community Manager", "emily.parker@safehood.com", Colors.orange),
            _buildStaffCard("David Kim", "Resident Services Coordinator", "david.kim@safehood.com", Colors.orange),
            SizedBox(height: 16),

            _buildSectionTitle("Emergency Contacts"),
            _buildEmergencyButton("Call Emergency Services (911)", Colors.red, Icons.warning),
            _buildEmergencyButton("Building Emergency Line", Colors.red, Icons.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStaffCard(String name, String position, String details, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(position, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Text(details, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
        onPressed: () {},
      ),
    );
  }
   Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset("assets/logo.jpg", height: 60),
          ),
        ),
        // Add your logo here
        const SizedBox(width: 10),
        const Text(
          "SAFE HOOD",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
