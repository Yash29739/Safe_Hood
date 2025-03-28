import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening Google Maps in browser

class AdminNearByShops extends StatefulWidget {
  const AdminNearByShops({super.key});

  @override
  State<AdminNearByShops> createState() => _AdminNearByShopsState();
}

class _AdminNearByShopsState extends State<AdminNearByShops> {
  final TextEditingController _searchController = TextEditingController();

  // Predefined list of shops with their location (latitude and longitude)
  List<Map<String, dynamic>> shops = [
    {
      "name": "ABC Supermarket",
      "contact": "9876543210",
      "hours": "8 AM - 9 PM",
      "latitude": 37.7749, // Example latitude
      "longitude": -122.4194, // Example longitude
    },
    {
      "name": "XYZ Electronics",
      "contact": "9123456789",
      "hours": "10 AM - 7 PM",
      "latitude": 34.0522, // Example latitude
      "longitude": -118.2437, // Example longitude
    },
    {
      "name": "Local Bakery",
      "contact": "9456781234",
      "hours": "6 AM - 8 PM",
      "latitude": 40.7128, // Example latitude
      "longitude": -74.0060, // Example longitude
    },
    {
      "name": "Fashion Hub",
      "contact": "9871234567",
      "hours": "11 AM - 9 PM",
      "latitude": 51.5074, // Example latitude
      "longitude": -0.1278, // Example longitude
    },
    {
      "name": "Pet Care Center",
      "contact": "9734567890",
      "hours": "9 AM - 6 PM",
      "latitude": 48.8566, // Example latitude
      "longitude": 2.3522, // Example longitude
    },
  ];

  List<Map<String, dynamic>> filteredShops = [];

  @override
  void initState() {
    super.initState();
    filteredShops = shops; // Initialize filtered list with predefined shops
  }

  // Function to filter shops based on search
  void _filterShops(String query) {
    setState(() {
      filteredShops =
          shops
              .where(
                (shop) =>
                    shop["name"]!.toLowerCase().contains(query.toLowerCase()) ||
                    shop["contact"]!.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  // Function to open Google Maps in the browser
  Future<void> _openMapInBrowser(double latitude, double longitude) async {
    final Uri mapUrl = Uri.parse(
      'https://maps.google.com/?q=$latitude,$longitude',
    );

    // Debugging: print the URL to make sure it's correct
    print('Opening map in browser with URL: $mapUrl');

    // Launch the map URL in a browser
    if (await canLaunch(mapUrl.toString())) {
      await launch(mapUrl.toString());
    } else {
      // Show error message if the map can't be opened
      print('Could not open the map in browser.');
      throw 'Could not open the map in browser.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Nearby Shops",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
            fontSize: 28,
            color: Color(0xFF77008B),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0x13A100AF),
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
          Expanded(
            child: ListView.builder(
              itemCount: filteredShops.length,
              itemBuilder: (context, index) {
                final shop = filteredShops[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
                          shop["name"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(shop["contact"]!),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(shop["hours"]!),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                _openMapInBrowser(
                                  shop["latitude"],
                                  shop["longitude"],
                                );
                              },
                              child: const Text(
                                "Open in Google Maps (Browser)",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(thickness: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
