import 'package:flutter/material.dart';

class Neighbor {
  final String name;
  final int age;
  final String occupation;
  final String phoneNumber;
  final String address;

  Neighbor({
    required this.name,
    required this.age,
    required this.occupation,
    required this.phoneNumber,
    required this.address,
  });
}

class AdminNeighborManagementScreen extends StatefulWidget {
  const AdminNeighborManagementScreen({super.key});

  @override

  _AdminNeighborManagementScreenState createState() => _AdminNeighborManagementScreenState();
}

class _AdminNeighborManagementScreenState extends State<AdminNeighborManagementScreen> {
  List<Neighbor> neighbors = [
    Neighbor(name: 'John Doe', age: 32, occupation: 'Engineer', phoneNumber: '123-456-7890', address: '1234 Elm Street'),
    Neighbor(name: 'Jane Smith', age: 28, occupation: 'Teacher', phoneNumber: '234-567-8901', address: '5678 Oak Avenue'),
    Neighbor(name: 'Michael Johnson', age: 45, occupation: 'Doctor', phoneNumber: '345-678-9012', address: '91011 Maple Road'),
  ];

  /// Function to show a dialog and add a new neighbor
  void _addNeighbor() {
    String name = '';
    int age = 0;
    String occupation = '';
    String phoneNumber = '';
    String address = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Neighbor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onChanged: (value) => age = int.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Occupation"),
                onChanged: (value) => occupation = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) => phoneNumber = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Address"),
                onChanged: (value) => address = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && occupation.isNotEmpty && phoneNumber.isNotEmpty && address.isNotEmpty) {
                  setState(() {
                    neighbors.add(Neighbor(
                      name: name,
                      age: age,
                      occupation: occupation,
                      phoneNumber: phoneNumber,
                      address: address,
                    ));
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields"))
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// Function to remove a neighbor from the list

  void _removeNeighbor(int index) {
    setState(() {
      neighbors.removeAt(index);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: neighbors.length,
                itemBuilder: (context, index) {
                  final neighbor = neighbors[index];
                  return Dismissible(
                    key: Key(neighbor.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => _removeNeighbor(index),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            neighbor.name[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(neighbor.name),
                        subtitle: Text('Age: ${neighbor.age} | Occupation: ${neighbor.occupation}'),

                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(neighbor.name),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Age: ${neighbor.age}'),
                                    Text('Occupation: ${neighbor.occupation}'),
                                    Text('Phone: ${neighbor.phoneNumber}'),
                                    Text('Address: ${neighbor.address}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addNeighbor,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add Neighbor", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom header for the app bar

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
            child: Image.asset("assets/logo.jpg", height: 60, errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, size: 60, color: Colors.white);
            }),

          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "SAFE HOOD - Admin",
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
