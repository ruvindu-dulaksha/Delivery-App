import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {
              // Implement logout functionality
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'John Doe', // Replace with dynamic user data
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'johndoe@example.com', // Replace with dynamic user data
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Purchase History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Implement purchase history widget here
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
