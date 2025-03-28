import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditEmergencyContactsScreen extends StatefulWidget {
  const EditEmergencyContactsScreen({
    super.key,
    required List<Map<String, String>> emergencyContacts,
  });

  @override
  State<EditEmergencyContactsScreen> createState() =>
      _EditEmergencyContactsScreenState();
}

class _EditEmergencyContactsScreenState
    extends State<EditEmergencyContactsScreen> {
  List<Map<String, String>> emergencyContacts = [];
  bool isLoading = true;
  String? userId;
  String? flatCode;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    flatCode = prefs.getString('flatCode');

    if (userId != null && flatCode != null) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('flats')
              .doc(flatCode)
              .collection('members')
              .doc(userId)
              .collection('emergencyContacts')
              .get();

      emergencyContacts =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['name']?.toString() ?? '',
              'phone': data['phone']?.toString() ?? '',
              'id': doc.id,
            };
          }).toList();
    }
    setState(() {
      isLoading = false;
    });
  }

  void _addContact() {
    setState(() {
      emergencyContacts.add({'name': '', 'phone': '', 'id': ''});
    });
  }

  void _updateContact(int index, String key, String value) {
    setState(() {
      emergencyContacts[index][key] = value;
    });
  }

  Future<void> _saveContacts() async {
    if (userId != null && flatCode != null) {
      CollectionReference contactRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flats')
          .doc(flatCode)
          .collection('members')
          .doc(userId)
          .collection('emergencyContacts');

      // Clear existing contacts and re-add
      QuerySnapshot existingContacts = await contactRef.get();
      for (var doc in existingContacts.docs) {
        await doc.reference.delete();
      }

      for (var contact in emergencyContacts) {
        await contactRef.add({
          'name': contact['name'],
          'phone': contact['phone'],
        });
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency contacts updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Emergency Contacts'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveContacts),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: emergencyContacts.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    initialValue:
                                        emergencyContacts[index]['name'],
                                    decoration: const InputDecoration(
                                      labelText: 'Contact Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged:
                                        (value) => _updateContact(
                                          index,
                                          'name',
                                          value,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    initialValue:
                                        emergencyContacts[index]['phone'],
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    onChanged:
                                        (value) => _updateContact(
                                          index,
                                          'phone',
                                          value,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeContact(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: _addContact,
                      backgroundColor: Colors.purple,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
    );
  }
}
