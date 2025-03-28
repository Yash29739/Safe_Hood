import 'package:flutter/material.dart';


class MaintenanceRequestsScreen extends StatelessWidget {
  const MaintenanceRequestsScreen({super.key});

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
            _buildNewRequestCard(),
            SizedBox(height: 16),
            _buildSectionTitle("Active Requests"),
            _buildRequestCard("Plumbing Issue", "Leaking faucet in master bathroom needs immediate attention",
                "Submitted: June 16, 2023", "High Priority", "In Progress", Colors.purple[100]!, Colors.red),
            _buildRequestCard("Electrical Issue", "Kitchen outlet not working properly", "Submitted: June 14, 2023",
                "Medium Priority", "Scheduled", Colors.teal[100]!, Colors.orange),
            SizedBox(height: 16),
            _buildSectionTitle("Completed Requests"),
            _buildRequestCard("AC Maintenance", "Annual AC maintenance and filter replacement",
                "Completed: June 10, 2023", "Completed", "", Colors.orange[100]!, Colors.green),
            _buildRequestCard("Lock Replacement", "Front door lock replacement", "Completed: June 8, 2023",
                "Completed", "", Colors.orange[100]!, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRequestCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("New Request"),
            TextField(
              decoration: InputDecoration(
                hintText: "Issue Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDropdown("Select Priority", Icons.flag)),
                SizedBox(width: 10),
                Expanded(child: _buildDropdown("Select Category", Icons.category)),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Submit Request", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Text(hint, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRequestCard(String title, String desc, String date, String priority, String status, Color bgColor, Color labelColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (priority.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: labelColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(priority, style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 6),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.black54)),
            if (status.isNotEmpty)
              Align(
                alignment: Alignment.bottomRight,
                child: Text("Status: $status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
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
