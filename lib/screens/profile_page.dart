import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savorease_app/screens/login_page.dart';

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
  String? _profilePicURL; // Declare profile picture URL variable
  final ImagePicker _picker = ImagePicker();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchUserName();
    _fetchProfilePicture();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchProfilePicture();
  }

  Future<void> _fetchUserName() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(_user.uid).get();
    setState(() {
      _userName = userDoc['name'];
    });
  }

  Future<String?> _fetchProfilePicture() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(_user.uid).get();
    return userDoc['profile_picture'];
  }

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _profilePicURL =
            pickedFile.path; // Update _profilePicURL with local file path
      });

      // Upload image file to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${_user.uid}.jpg');
      UploadTask uploadTask = ref.putFile(_imageFile!);

      // Initialize downloadURL with null
      String? downloadURL = null;

      // Get download URL of uploaded image
      await uploadTask.whenComplete(() async {
        downloadURL = await ref.getDownloadURL();
      });

      // Save download URL to Firestore
      if (downloadURL != null) {
        await _firestore.collection('users').doc(_user.uid).set({
          'profile_picture': downloadURL,
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> _changeUserName(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change User Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter new user name',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text;
                if (newName.isNotEmpty) {
                  await _firestore.collection('users').doc(_user.uid).set({
                    'name': newName,
                    'email': _user.email,
                  }, SetOptions(merge: true));

                  setState(() {
                    _userName = newName;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                  hintText: 'Enter current password',
                ),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String oldPassword = oldPasswordController.text;
                String newPassword = newPasswordController.text;
                if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
                  try {
                    // Reauthenticate user
                    UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: _user.email!,
                      password: oldPassword,
                    );

                    // Update password
                    await userCredential.user!.updatePassword(newPassword);

                    // Update users table in Firestore
                    await _firestore.collection('users').doc(_user.uid).update({
                      'password': newPassword,
                    });

                    // Notify user of success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated successfully')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Notify user of error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchUserOrders(BuildContext context) async {
    // Fetch orders based on the user's email
    QuerySnapshot ordersSnapshot = await _firestore
        .collection('orders')
        .where('userEmail', isEqualTo: _user.email)
        .get();

    // Show fetched orders in a dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Orders'),
          content: SingleChildScrollView(
            child: ordersSnapshot.docs.isEmpty
                ? Text('No orders found.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: ordersSnapshot.docs.map((orderDoc) {
                      List<dynamic> items = orderDoc['items'];

                      // Create a list of ListTile for each item in the order
                      List<Widget> orderItems = items.map<Widget>((item) {
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text(
                              'Price: ${item['price']}, Quantity: ${item['quantity']}'),
                        );
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('City: ${orderDoc['city']}'),
                          Column(
                            children: orderItems,
                          ),
                          Text('Total Price: ${orderDoc['totalPrice']}'),
                          Divider(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () => _fetchUserOrders(context),
            icon: Icon(Icons.shopping_bag),
          ),
          IconButton(
            onPressed: () => _signOut(context), // Call sign out method
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _profilePicURL != null
                      ? _imageFile != null
                          ? FileImage(File(_profilePicURL!))
                              as ImageProvider<Object>?
                          : NetworkImage(_profilePicURL!)
                              as ImageProvider<Object>?
                      : NetworkImage(_user.photoURL ?? ''),
                  child: _imageFile == null && _profilePicURL == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey.withOpacity(0.5),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _changeUserName(context),
                  ),
                ],
              ),
              Text(
                _userName ?? 'Loading...',
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
              ElevatedButton(
                onPressed: () => _changePassword(context),
                child: Text('Request to Change Password'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
