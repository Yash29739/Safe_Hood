import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NearByShops extends StatefulWidget {
  const NearByShops({super.key});

  @override
  State<NearByShops> createState() => _NearByShopsState();
}

class _NearByShopsState extends State<NearByShops> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredShops = [];
  List<Map<String, dynamic>> allShops = [];
  String? flatCode; // Store flatCode here
  String? userRole; // Store user role here

  @override
  void initState() {
    super.initState();
    _loadFlatCodeAndRole(); // Load flatCode and role from SharedPreferences
  }

  // ✅ Load flatCode and role from SharedPreferences
  Future<void> _loadFlatCodeAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      flatCode = prefs.getString("flatCode");
      userRole = prefs.getString("role");
    });
    if (flatCode != null) {
      _fetchShops(); // Fetch shops only after flatCode is loaded
    }
  }

  // ✅ Fetch shops from Firestore
  Future<void> _fetchShops() async {
    if (flatCode == null) return;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('flatcode')
            .doc(flatCode)
            .collection('shops')
            .get();

    List<Map<String, dynamic>> shops =
        querySnapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc["name"],
            "contact": doc["contact"],
            "hours": doc["hours"],
            "mapLink": doc["mapLink"],
          };
        }).toList();

    setState(() {
      allShops = shops;
      filteredShops = shops;
    });
  }

  // ✅ Add or Update shop in Firestore
  Future<void> _addOrUpdateShop({
    String? shopId,
    required String name,
    required String contact,
    required String hours,
    required String mapLink,
  }) async {
    if (flatCode == null) return;

    if (shopId == null) {
      // ✅ Add new shop
      DocumentReference shopRef = await FirebaseFirestore.instance
          .collection('flatcode')
          .doc(flatCode)
          .collection('shops')
          .add({
            "name": name,
            "contact": contact,
            "hours": hours,
            "mapLink": mapLink,
          });

      // ✅ Add shopId to the document
      await shopRef.update({"shopId": shopRef.id});
    } else {
      // ✅ Update existing shop
      await FirebaseFirestore.instance
          .collection('flatcode')
          .doc(flatCode)
          .collection('shops')
          .doc(shopId)
          .update({
            "name": name,
            "contact": contact,
            "hours": hours,
            "mapLink": mapLink,
          });
    }

    _fetchShops(); // Refresh list after add/update
  }

  // ✅ Delete shop from Firestore
  Future<void> _deleteShop(String shopId) async {
    if (flatCode == null || userRole != "Admin") return;

    await FirebaseFirestore.instance
        .collection('flatcode')
        .doc(flatCode)
        .collection('shops')
        .doc(shopId)
        .delete();

    _fetchShops(); // Refresh list after deleting
  }

  // ✅ Filter shops based on search query
  void _filterShops(String query) {
    setState(() {
      filteredShops =
          allShops
              .where(
                (shop) =>
                    shop["name"]!.toLowerCase().contains(query.toLowerCase()) ||
                    shop["contact"]!.contains(query),
              )
              .toList();
    });
  }

  // ✅ Open Google Maps using the provided link
  Future<void> _openMapLink(String mapLink) async {
    final Uri mapUrl = Uri.parse(mapLink);

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map link.';
    }
  }

  // ✅ Show dialog to add or edit a shop
  void _showAddOrEditShopDialog({
    String? shopId,
    String? initialName,
    String? initialContact,
    String? initialHours,
    String? initialMapLink,
  }) {
    String name = initialName ?? "";
    String contact = initialContact ?? "";
    String hours = initialHours ?? "";
    String mapLink = initialMapLink ?? "";

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(shopId == null ? "Add New Shop" : "Edit Shop"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    "Shop Name",
                    initialName,
                    (value) => name = value,
                  ),
                  _buildTextField(
                    "Contact Number",
                    initialContact,
                    (value) => contact = value,
                  ),
                  _buildTextField(
                    "Working Hours",
                    initialHours,
                    (value) => hours = value,
                  ),
                  _buildTextField(
                    "Google Maps Link",
                    initialMapLink,
                    (value) => mapLink = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (name.isNotEmpty &&
                      contact.isNotEmpty &&
                      hours.isNotEmpty &&
                      mapLink.isNotEmpty) {
                    _addOrUpdateShop(
                      shopId: shopId,
                      name: name,
                      contact: contact,
                      hours: hours,
                      mapLink: mapLink,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(shopId == null ? "Add" : "Update"),
              ),
            ],
          ),
    );
  }

  // ✅ Build a reusable text field
  Widget _buildTextField(
    String label,
    String? initialValue,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        onChanged: onChanged,
        controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ✅ Build shop list UI
  Widget _buildShopList() {
    if (filteredShops.isEmpty) {
      return const Center(
        child: Text(
          "No shops added yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredShops.length,
      itemBuilder: (context, index) {
        final shop = filteredShops[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop["name"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 18),
                    const SizedBox(width: 5),
                    Text(shop["contact"]),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue, size: 18),
                    const SizedBox(width: 5),
                    Text(shop["hours"]),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 18),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        _openMapLink(shop["mapLink"]);
                      },
                      child: const Text(
                        "Open in Google Maps",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // ✅ Show edit and delete buttons only for admin
                if (userRole == "Admin")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showAddOrEditShopDialog(
                            shopId: shop["id"],
                            initialName: shop["name"],
                            initialContact: shop["contact"],
                            initialHours: shop["hours"],
                            initialMapLink: shop["mapLink"],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteShop(shop["id"]);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (flatCode == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Nearby Shops",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF77008B),
          ),
        ),
        backgroundColor: const Color(0x13A100AF),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterShops,
              decoration: InputDecoration(
                labelText: "Search Shops",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(child: _buildShopList()),
        ],
      ),
      // ✅ Floating Action Button to add new shop (only for admin)
      floatingActionButton:
          userRole == "Admin"
              ? FloatingActionButton(
                onPressed: () => _showAddOrEditShopDialog(),
                backgroundColor: const Color(0xFF77008B),
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
