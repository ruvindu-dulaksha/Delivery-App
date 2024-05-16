import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class BranchAdminDashboardPage extends StatefulWidget {
  const BranchAdminDashboardPage({Key? key}) : super(key: key);

  @override
  _BranchAdminDashboardPageState createState() =>
      _BranchAdminDashboardPageState();
}

class _BranchAdminDashboardPageState extends State<BranchAdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Branch Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('purchase').snapshots(),
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

  Widget _buildOrderCard(DocumentSnapshot order) {
    Map<String, dynamic> orderData = order.data() as Map<String, dynamic>;
    List<dynamic> products = orderData['products'] ?? [];
    String productsString = products
        .map((product) => '${product['name']} (x${product['quantity']})')
        .join(', ');

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
            Text(
              'Invoice: ${orderData['invoice_number']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Payment Date: ${orderData['payment_date'].toDate()}'),
            SizedBox(height: 8),
            Text('City: ${orderData['city']}'),
            SizedBox(height: 8),
            Text('Products: $productsString'),
            SizedBox(height: 8),
            Text('Total Amount: \$${orderData['total_amount']}'),
          ],
        ),
      ),
    );
  }
}
