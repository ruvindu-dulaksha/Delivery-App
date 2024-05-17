import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:savorease_app/screens/login_page.dart';

class BranchAdminDashboardPage extends StatefulWidget {
  final String branchAdminEmail;

  const BranchAdminDashboardPage({Key? key, required this.branchAdminEmail})
      : super(key: key);

  @override
  _BranchAdminDashboardPageState createState() =>
      _BranchAdminDashboardPageState();
}

class _BranchAdminDashboardPageState extends State<BranchAdminDashboardPage> {
  String _userName = "John Doe"; // Default name
  String _userEmail = "johndoe@example.com"; // Default email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Branch Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _showProfileDialog, // Call profile dialog method
            icon: Icon(Icons.account_circle), // Profile icon
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(), // Navigate to login page
                ),
              );
            },
            icon: Icon(Icons.logout), // Logout icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No orders found'));
            }

            return StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot order = snapshot.data!.docs[index];
                return _buildOrderCard(order);
              },
              staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getStream() {
    switch (widget.branchAdminEmail) {
      case 'cadmin@gmail.com':
        return FirebaseFirestore.instance
            .collection('orders')
            .where('city', isEqualTo: 'colombo')
            .snapshots();
      case 'jadmin@gmail.com':
        return FirebaseFirestore.instance
            .collection('orders')
            .where('city', isEqualTo: 'jaffna')
            .snapshots();
      case 'kadmin@gmail.com':
        return FirebaseFirestore.instance
            .collection('orders')
            .where('city', isEqualTo: 'kolkata')
            .snapshots();
      default:
        return FirebaseFirestore.instance.collection('orders').snapshots();
    }
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    Map<String, dynamic>? orderData = order.data() as Map<String, dynamic>?;

    if (orderData == null) {
      return SizedBox(); // Return an empty widget if order data is null
    }

    List<dynamic> products = orderData['items'] ?? [];
    String productsString = products
        .map((product) => '${product['name']} (x${product['quantity']})')
        .join(', ');

    bool isOrderComplete = orderData['complete'] ?? false;

    DateTime paymentDate;
    try {
      paymentDate = DateTime.parse(orderData['dateTime']);
    } catch (e) {
      paymentDate = DateTime.now();
    }
    String formattedDate = DateFormat.yMMMMd().add_jm().format(paymentDate);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Invoice: ${orderData['invoiceNumber']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isOrderComplete)
                  IconButton(
                    icon: Icon(Icons.check_circle),
                    onPressed: () {
                      // Set the 'complete' field of the order to true
                      order.reference.update({'complete': true});
                    },
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text('Payment Date: $formattedDate'),
            SizedBox(height: 8),
            Text('City: ${orderData['city']}'),
            SizedBox(height: 8),
            Text('Products: $productsString'),
            SizedBox(height: 8),
            Text('Total Amount: \$${orderData['totalPrice']}'),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Profile"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Name: $_userName"),
              Text("Email: $_userEmail"),
              Text("Role: Branch Admin"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BranchAdminDashboardPage(branchAdminEmail: 'cadmin@gmail.com'),
  ));
}
