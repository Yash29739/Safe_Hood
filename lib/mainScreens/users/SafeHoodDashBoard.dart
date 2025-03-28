import 'package:flutter/material.dart';
import 'package:safe_hood/mainScreens/users/community/friend_list_screen.dart';
import 'package:safe_hood/mainScreens/users/community/neighbor_profile_screen.dart';
import 'package:safe_hood/mainScreens/users/community/todo_list_screen.dart';
import 'package:safe_hood/mainScreens/users/community/visitorenteryscreen.dart';
import 'package:safe_hood/mainScreens/users/service/CommunityNoticeBoard.dart';
import 'package:safe_hood/mainScreens/users/service/communityRules.dart';
import 'package:safe_hood/mainScreens/users/service/complaintscreen.dart';
import 'package:safe_hood/mainScreens/users/service/maintenancerequestscreen.dart';
import 'package:safe_hood/mainScreens/users/service/safffdirectory.dart';
import 'package:safe_hood/mainScreens/users/service/upcomingevents.dart';

// ignore: camel_case_types
class SafeHoodDashboard extends StatefulWidget {
  const SafeHoodDashboard({super.key});

  @override
  State<SafeHoodDashboard> createState() => _SafeHoodDashboardState();
}

class _SafeHoodDashboardState extends State<SafeHoodDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildSOSButton(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("SERVICE"),
                      const SizedBox(height: 10),
                      _buildGrid([
                        _gridItem(
                          "File a Complaint",
                          Icons.report_problem,
                          ComplaintScreen(),
                          context,
                        ),
                        _gridItem(
                          "Maintenance",
                          Icons.build,
                          MaintenanceRequestsScreen(),
                          context,
                        ),
                        _gridItem(
                          "Community Notice Board",
                          Icons.dashboard,
                          CommunityNoticeBoard(),
                          context,
                        ),
                        _gridItem(
                          "Staffs",
                          Icons.people,
                          StaffDirectoryPage(),
                          context,
                        ),
                        _gridItem(
                          "Community Rules",
                          Icons.article,
                          CommunityRulesApp(),
                          context,
                        ),
                      ]),
                      const SizedBox(height: 30),
                      _buildSectionTitle("COMMUNITY"),
                      const SizedBox(height: 10),
                      _buildGrid([
                        _gridItem(
                          "Do-To-List",
                          Icons.checklist,
                          ToDoListScreen(),
                          context,
                        ),
                        _gridItem(
                          "Visitor's",
                          Icons.sync_alt,
                          VisitorEntryScreen(),
                          context,
                        ),
                        _gridItem(
                          "Friends",
                          Icons.people_alt,
                          FriendListScreen(),
                          context,
                        ),
                        _gridItem(
                          "Neighbors Screen",
                          Icons.home,
                          NeighborProfileScreen(),
                          context,
                        ),
                        _gridItem(
                          "Community Events",
                          Icons.event,
                          UpcomingEventsScreen(),
                          context,
                        ),
                      ]),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        ),
        child: Column(
          children: const [
            Icon(Icons.sos, size: 40, color: Colors.black),
            Text(
              "Emergency !",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontFamily: "Merriweather",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGrid(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }

  Widget _gridItem(
    String title,
    IconData icon,
    Widget nav,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => nav));
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15), // Adjust padding if needed
        backgroundColor: Colors.white, // Set button background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
