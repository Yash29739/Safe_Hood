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

class NeighborProfileScreen extends StatelessWidget {
  // Sample list of neighbors
  final List<Neighbor> neighbors = [
    Neighbor(
      name: 'John Doe',
      age: 32,
      occupation: 'Engineer',
      phoneNumber: '123-456-7890',
      address: '1234 Elm Street',
    ),
    Neighbor(
      name: 'Jane Smith',
      age: 28,
      occupation: 'Teacher',
      phoneNumber: '234-567-8901',
      address: '5678 Oak Avenue',
    ),
    Neighbor(
      name: 'Michael Johnson',
      age: 45,
      occupation: 'Doctor',
      phoneNumber: '345-678-9012',
      address: '91011 Maple Road',
    ),
    // Add more neighbor profiles here
  ];
  NeighborProfileScreen({super.key});

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
        child: ListView.builder(
          itemCount: neighbors.length,
          itemBuilder: (context, index) {
            final neighbor = neighbors[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  // Placeholder image or icon for each neighbor
                  backgroundColor: Colors.purple,
                  child: Text(
                    neighbor.name[0], // Display the first letter of their name
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(neighbor.name),
                subtitle: Text(
                  'Age: ${neighbor.age} | Occupation: ${neighbor.occupation}',
                ),
                onTap: () {
                  // Show the detailed profile in a dialog or navigate to a new screen
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(neighbor.name),
                        content: Column(
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
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
