import 'package:flutter/material.dart';

class CommunityNoticeBoard extends StatelessWidget {
  const CommunityNoticeBoard({super.key});

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
            _buildSectionTitle("Important Announcements"),
            _buildAlertBox("Emergency Notice", "Building maintenance: Water shutdown tomorrow 8AM-2PM",
                "Posted by Management • 2 hours ago", Colors.red, Icons.warning),
            SizedBox(height: 16),
            _buildSectionTitle("Community Events"),
            _buildEventCard("Weekend BBQ", "Join us for our monthly community BBQ at the courtyard!",
                "Saturday, July 15 • 4:00 PM", "Posted by Social Committee • 1 day ago", Colors.blue, Icons.event),
            _buildEventCard("Yoga in the Park", "Free yoga session for all community members",
                "Sunday, July 16 • 6:00 AM", "Posted by Sarah Johnson • 2 days ago", Colors.green, Icons.spa),
            SizedBox(height: 16),
            _buildSectionTitle("General Notices"),
            _buildNoticeCard("Lost & Found", "Found: House keys with blue keychain near Building C",
                "Posted by John Smith • 3 hours ago", Icons.search),
            _buildNoticeCard("Parking Notice", "Please remember to display your parking permit at all times",
                "Posted by Security Team • 5 hours ago", Icons.local_parking),
            SizedBox(height: 16),
            _buildSectionTitle("Marketplace"),
            _buildForSaleCard("For Sale", "Gently used patio furniture set - \$200",
                "Posted by Maria Garcia • 1 day ago", Icons.sell),
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

  Widget _buildAlertBox(String title, String desc, String footer, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration( borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 6),
            Text(footer, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String desc, String time, String footer, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 6),
            Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(footer, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeCard(String title, String desc, String footer, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Text(footer, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildForSaleCard(String title, String desc, String footer, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Text(footer, style: TextStyle(fontSize: 12, color: Colors.black54)),
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
