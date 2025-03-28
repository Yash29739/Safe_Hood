import 'package:flutter/material.dart';

class Friend {
  final String name;
  final int age;
  final String occupation;
  final String phoneNumber;
  final String address;

  Friend({
    required this.name,
    required this.age,
    required this.occupation,
    required this.phoneNumber,
    required this.address,
  });
}

class FriendListScreen extends StatelessWidget {
  final List<Friend> friends = [
    Friend(
      name: 'Alice Brown',
      age: 29,
      occupation: 'Graphic Designer',
      phoneNumber: '555-123-4567',
      address: '2345 Pine Street',
    ),
    Friend(
      name: 'Bob White',
      age: 35,
      occupation: 'Photographer',
      phoneNumber: '555-234-5678',
      address: '6789 Birch Lane',
    ),
    Friend(
      name: 'Charlie Green',
      age: 40,
      occupation: 'Software Developer',
      phoneNumber: '555-345-6789',
      address: '1012 Cedar Drive',
    ),
    // Add more friends here as needed
  ];

  FriendListScreen({super.key});

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
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  // Placeholder image or icon for each friend
                  backgroundColor: Colors.blue,
                  child: Text(
                    friend.name[0], // Display the first letter of their name
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(friend.name),
                subtitle: Text(
                  'Age: ${friend.age} | Occupation: ${friend.occupation}',
                ),
                onTap: () {
                  // Show the detailed profile in a dialog or navigate to a new screen
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(friend.name),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Age: ${friend.age}'),
                            Text('Occupation: ${friend.occupation}'),
                            Text('Phone: ${friend.phoneNumber}'),
                            Text('Address: ${friend.address}'),
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
