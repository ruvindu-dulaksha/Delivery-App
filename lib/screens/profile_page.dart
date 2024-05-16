import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Upload image file to Firebase storage or update user profile
      // Uncomment the following lines and replace with your implementation
      // final imageUrl = await uploadImageToStorage(_imageFile);
      // await updateUserProfile(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider<Object>?
                    : NetworkImage(_user.photoURL ?? ''),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'User Name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _user.displayName ?? 'Anonymous',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _user.email ?? 'No Email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Purchase History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Fetch and display user's purchase history
            FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('purchases')
                  .doc(_user.uid)
                  .collection('history')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final purchases = snapshot.data!.docs;
                  return Column(
                    children: purchases.map((purchase) {
                      return ListTile(
                        title: Text(purchase['product']),
                        subtitle: Text('Amount: ${purchase['amount']}'),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement change password functionality
              },
              child: Text('Request to Change Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement select account functionality
              },
              child: Text('Select Account'),
            ),
          ],
        ),
      ),
    );
  }
}
