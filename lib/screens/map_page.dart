import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savorease_app/screens/home_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();

  final Map<String, LatLng> branches = {
    'Colombo': LatLng(6.9271, 79.8612),
    'Negombo': LatLng(7.209, 79.8358),
    'Jaffna': LatLng(9.6615, 80.0255),
    'Kolkata': LatLng(22.5726, 88.3639),
    'Delhi': LatLng(28.7041, 77.1025),
  };

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    branches.forEach((city, location) {
      _markers.add(
        Marker(
          markerId: MarkerId(city),
          position: location,
          infoWindow: InfoWindow(
            title: city,
            snippet: 'Your nearest branch',
          ),
        ),
      );
    });
    _cityController.addListener(_onCityTextChanged);
  }

  void _onCityTextChanged() {
    String branchName = _cityController.text;
    LatLng? branchLocation;
    for (var entry in branches.entries) {
      if (entry.key.toLowerCase() == branchName.toLowerCase()) {
        branchLocation = entry.value;
        break;
      }
    }
    if (branchLocation != null) {
      _controller
          ?.animateCamera(CameraUpdate.newLatLngZoom(branchLocation, 15));
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(branchName),
          position: branchLocation,
          infoWindow: InfoWindow(
            title: branchName,
            snippet: 'Your nearest branch',
          ),
        ),
      );
    }
  }

  void _clearText() {
    _addressController.clear();
    _cityController.clear();
  }

  void _goToHomePage(BuildContext context) async {
    // Get the current user's email
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    // Get the address and city entered by the user
    String address = _addressController.text;
    String city = _cityController.text;

    // Store the address information in the "addresses" collection in Firestore
    try {
      await FirebaseFirestore.instance.collection('addresses').add({
        'userEmail': userEmail,
        'address': address,
        'city': city,
      });
      print('Address stored successfully!');
    } catch (error) {
      print('Failed to store address: $error');
    }

    // Navigate to the home page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Your Nearest Savor Ease'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _controller = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(6.914850, 79.877491), // Default location (Colombo)
                zoom: 8,
              ),
              markers: _markers,
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _goToHomePage(context),
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: _clearText,
                child: Text('Clear'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
