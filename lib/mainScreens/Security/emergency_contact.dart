import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends StatefulWidget {
  @override
  _EmergencyContactsPageState createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final List<Map<String, String>> emergencyContacts = [
    {"name": "Police", "phone": "100"},
    {"name": "Fire Department", "phone": "101"},
    {"name": "Ambulance", "phone": "102"},
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _addEmergencyContact() {
    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
      setState(() {
        emergencyContacts.add({
          "name": nameController.text,
          "phone": phoneController.text,
        });
      });
      nameController.clear();
      phoneController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Emergency Contact",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 148, 45, 148),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Contact Name",
                prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 148, 45, 148)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone, color: Color.fromARGB(255, 148, 45, 148)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 148, 45, 148),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addEmergencyContact,
                  icon: Icon(Icons.add),
                  label: Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 148, 45, 148),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callContact(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch call")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Contacts"),
        backgroundColor: Color.fromARGB(255, 196, 62, 196),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Color.fromARGB(255, 193, 164, 199)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: emergencyContacts.length,
          itemBuilder: (context, index) {
            final contact = emergencyContacts[index];
            return Card(
              margin: EdgeInsets.all(10),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade700,
                  child: Icon(Icons.phone, color: Colors.white),
                ),
                title: Text(
                  contact["name"]!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 148, 45, 148),
                  ),
                ),
                subtitle: Text(
                  "Phone: ${contact["phone"]}",
                  style: TextStyle(color: Colors.black87),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () => _callContact(contact["phone"]!),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Color.fromARGB(255, 196, 62, 196),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
