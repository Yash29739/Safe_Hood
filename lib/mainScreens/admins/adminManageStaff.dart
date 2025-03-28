import 'package:flutter/material.dart';

class AdminStaffManagementPage extends StatefulWidget {
  const AdminStaffManagementPage({super.key});

  @override
  _AdminStaffManagementPageState createState() => _AdminStaffManagementPageState();
}

class _AdminStaffManagementPageState extends State<AdminStaffManagementPage> {
  List<Map<String, dynamic>> securityTeam = [
    {"name": "John Martinez", "position": "Head of Security", "details": "Available 24/7", "color": Colors.blue},
    {"name": "Sarah Wilson", "position": "Night Shift Supervisor", "details": "8:00 PM - 5:00 AM", "color": Colors.blue},
  ];

  List<Map<String, dynamic>> maintenanceTeam = [
    {"name": "Robert Chen", "position": "Lead Maintenance Engineer", "details": "Mon-Fri: 8:00 AM - 5:00 PM", "color": Colors.teal},
    {"name": "Mike Thompson", "position": "General Maintenance", "details": "Mon-Fri: 8:00 AM - 5:00 PM", "color": Colors.teal},
  ];

  List<Map<String, dynamic>> adminStaff = [
    {"name": "Emily Parker", "position": "Community Manager", "details": "emily.parker@safehood.com", "color": Colors.orange},
    {"name": "David Kim", "position": "Resident Services Coordinator", "details": "david.kim@safehood.com", "color": Colors.orange},
  ];

  void _removeStaffMember(List<Map<String, dynamic>> team, String name) {
    setState(() {
      team.removeWhere((member) => member['name'] == name);
    });
  }

  void _addStaffMember(List<Map<String, dynamic>> team) {
    setState(() {
      team.add({
        "name": "New Member",
        "position": "New Position",
        "details": "Details",
        "color": Colors.grey
      });
    });
  }

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
            _buildTeamSection("Security Team", securityTeam),
            _buildTeamSection("Maintenance Team", maintenanceTeam),
            _buildTeamSection("Administrative Staff", adminStaff),
            SizedBox(height: 16),
            _buildSectionTitle("Emergency Contacts"),
            _buildEmergencyButton("Call Emergency Services (911)", Colors.red, Icons.warning, () {}),
            _buildEmergencyButton("Building Emergency Line", Colors.red, Icons.phone, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(String title, List<Map<String, dynamic>> team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        for (var member in team)
          Dismissible(
            key: Key(member['name']), // Unique key per staff member
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _removeStaffMember(team, member['name']),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildStaffCard(member),
          ),
        IconButton(
          icon: Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => _addStaffMember(team),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> member) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member['color'],
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(member['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member['position'], style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Text(member['details'], style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(String text, Color color, IconData icon, VoidCallback onPressed) {
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
        onPressed: onPressed,
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
        SizedBox(width: 10),
        Text(
          "SAFE HOOD",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
      ],
    );
  }
}
