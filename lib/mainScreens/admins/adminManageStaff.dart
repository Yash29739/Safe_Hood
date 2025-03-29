import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminStaffManagementPage extends StatefulWidget {
  const AdminStaffManagementPage({super.key});

  @override
  _AdminStaffManagementPageState createState() => _AdminStaffManagementPageState();
}

class _AdminStaffManagementPageState extends State<AdminStaffManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String staffPath = "flatcode/(flatcode)/staff";
  Map<String, List<Map<String, dynamic>>> staffMembers = {};

  @override
  void initState() {
    super.initState();
    _fetchAllTeams();
  }

  Future<void> _fetchAllTeams() async {
    List<String> teams = ["security_team", "maintenance_team", "admin_staff"];
    Map<String, List<Map<String, dynamic>>> tempStaffMembers = {};

    for (var team in teams) {
      QuerySnapshot snapshot = await _firestore.collection('$staffPath/$team/members').get();
      tempStaffMembers[team] = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    }

    setState(() {
      staffMembers = tempStaffMembers;
    });
  }

  Future<void> _addStaffMember(String team, String name, String position) async {
    await _firestore.collection('$staffPath/$team/members').add({
      "name": name,
      "position": position,
      "color": "grey",
    });
    _fetchAllTeams();
  }

  Future<void> _removeStaffMember(String team, String docId) async {
    await _firestore.collection('$staffPath/$team/members').doc(docId).delete();
    _fetchAllTeams();
  }

  void _showAddStaffDialog() {
    TextEditingController teamController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController positionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Staff Member"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: teamController,
                decoration: InputDecoration(labelText: "Team (e.g., Security, Maintenance)"),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: positionController,
                decoration: InputDecoration(labelText: "Position"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String teamKey = teamController.text.trim().toLowerCase().replaceAll(" ", "_");
                if (teamKey.isNotEmpty &&
                    nameController.text.isNotEmpty &&
                    positionController.text.isNotEmpty) {
                  _addStaffMember(
                    teamKey,
                    nameController.text.trim(),
                    positionController.text.trim(),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields!")),
                  );
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteStaff(String team, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Staff Member"),
          content: Text("Are you sure you want to remove this staff member?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _removeStaffMember(team, docId);
                Navigator.pop(context);
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Color(0xFFCC00FF),
        title: Text("SAFE HOOD",
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamSection("Security Team", "security_team"),
            _buildTeamSection("Maintenance Team", "maintenance_team"),
            _buildTeamSection("Administrative Staff", "admin_staff"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: _showAddStaffDialog,
      ),
    );
  }

  Widget _buildTeamSection(String title, String team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        staffMembers.containsKey(team) == false
            ? Center(child: CircularProgressIndicator())
            : staffMembers[team]!.isEmpty
                ? Text("No staff available.", style: TextStyle(fontSize: 16))
                : Column(
                    children: staffMembers[team]!.map((member) {
                      return _buildStaffCard(team, member);
                    }).toList(),
                  ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStaffCard(String team, Map<String, dynamic> member) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(member['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(member['position'], style: TextStyle(fontSize: 14, color: Colors.black87)),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteStaff(team, member['id']),
        ),
      ),
    );
  }
}
