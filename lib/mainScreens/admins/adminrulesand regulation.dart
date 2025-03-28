import 'package:flutter/material.dart';


class AdminRulesPage extends StatefulWidget {
  const AdminRulesPage({super.key});

  @override
  _AdminRulesPageState createState() => _AdminRulesPageState();
}

class _AdminRulesPageState extends State<AdminRulesPage> {
  final List<Map<String, dynamic>> _rules = [
    {"icon": Icons.volume_up, "title": "Quiet Hours", "content": "10:00 PM - 7:00 AM daily\nBe mindful of noise levels."},
    {"icon": Icons.local_parking, "title": "Parking Regulations", "content": "Max 2 vehicles per unit.\nGuest parking in designated areas."},
    {"icon": Icons.pets, "title": "Pet Policy", "content": "Max 2 pets per unit.\nLeash required.\nClean up after pets."},
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _addRule() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      setState(() {
        _rules.add({
          "icon": Icons.rule, // Default icon
          "title": _titleController.text,
          "content": _contentController.text,
        });
      });
      _titleController.clear();
      _contentController.clear();
      Navigator.pop(context);
    }
  }

  void _deleteRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  void _showAddRuleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Rule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Rule Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Rule Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addRule,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFCC00FF),
        title: _buildHeader(),
      ),
      body: ListView.builder(
        itemCount: _rules.length,
        itemBuilder: (context, index) {
          final rule = _rules[index];
          return Dismissible(
            key: Key(rule["title"]),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteRule(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(rule["icon"], color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Text(
                          rule["title"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rule["content"],
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _showAddRuleDialog,
        child: const Icon(Icons.add, color: Colors.white),
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
          "SAFE HOOD - Admin Rules",
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
