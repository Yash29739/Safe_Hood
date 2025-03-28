import 'package:flutter/material.dart';

class VisitorEntryScreen extends StatefulWidget {
  const VisitorEntryScreen({super.key});

  @override
  _VisitorEntryScreenState createState() => _VisitorEntryScreenState();
}

class _VisitorEntryScreenState extends State<VisitorEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _visitorList = [];
  List<Map<String, String>> _filteredVisitors = [];

  void _addVisitor() {
    if (_nameController.text.isNotEmpty && _purposeController.text.isNotEmpty) {
      setState(() {
        _visitorList.add({
          "name": _nameController.text,
          "purpose": _purposeController.text,
          "time": TimeOfDay.now().format(context),
        });
        _filteredVisitors = List.from(_visitorList);
      });
      _nameController.clear();
      _purposeController.clear();
    }
  }

  void _searchVisitor(String query) {
    setState(() {
      _filteredVisitors = _visitorList
          .where((visitor) => visitor["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredVisitors = List.from(_visitorList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFCC00FF),
        title: Column(
          children: [
            _buildHeader(),
            const Text(
              "Visitor's",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Visitor Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white, // TextField background color white
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(
                labelText: "Purpose of Visit",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white, // TextField background color white
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addVisitor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background color white
                  foregroundColor: Colors.purple, // Button text color purple
                ),
                child: const Text("Add Visitor",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: _searchVisitor,
              decoration: InputDecoration(
                labelText: "Search Visitor",
                prefixIcon: const Icon(Icons.search, color: Colors.purple), // Search icon color
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white, // Search bar background color white
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: const Text(
                "Visitor Log",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 38, 38, 38)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: _filteredVisitors.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "No visitor logs available",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.purple),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredVisitors.length,
                        itemBuilder: (context, index) {
                          final visitor = _filteredVisitors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: Text(visitor["name"]![0], style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(visitor["name"]!),
                              subtitle: Text("Purpose: ${visitor["purpose"]}\nTime: ${visitor["time"]}"),
                            ),
                          );
                        },
                      ),
              ),
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
      ],
    );
  }
}
