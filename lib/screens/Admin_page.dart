import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: AdminHomePage(),
    theme: ThemeData(
      primaryColor: Colors.orange,
    ),
  ));
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for total income and date time
    double totalIncome = 2500.0; // Example total income
    DateTime currentDateTime = DateTime.now(); // Current date and time

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Total Income
            Text(
              'Total Income: \$${totalIncome.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Display Date and Time
            Text(
              'Date and Time: ${currentDateTime.toString()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Buttons for different functionalities
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductManagementPage()),
                );
              },
              child: Text('Product Management'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BranchAdminPage()),
                );
              },
              child: Text('Add Branch Admin'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PurchaseTablePage()),
                );
              },
              child: Text('View Purchase Tables'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement log out functionality
                Navigator.pop(context);
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
      ),
      body: ProductForm(),
    );
  }
}

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: 'Enter category',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Text(
              'Product Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter product name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Text(
              'Price:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter price',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save product to Firestore
                  _addProduct();
                }
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'category': _categoryController.text,
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
      });
      // Clear form fields after adding product
      _categoryController.clear();
      _nameController.clear();
      _priceController.clear();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully'),
        ),
      );
      // Navigate back to AdminHomePage to see the updated list of products
      Navigator.pop(context);
    } catch (e) {
      print('Error adding product: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product. Please try again.'),
        ),
      );
    }
  }
}

class BranchAdminPage extends StatelessWidget {
  const BranchAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Branch Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Admin Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'New Admin Password:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Branch City Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement submit functionality
                  },
                  child: Text('Submit'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.grey),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseTablePage extends StatelessWidget {
  const PurchaseTablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Tables'),
      ),
      body: PurchaseTableList(),
    );
  }
}

class PurchaseTableList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('purchase').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No purchase tables found'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return PurchaseTableItem(data: data);
          }).toList(),
        );
      },
    );
  }
}

class PurchaseTableItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const PurchaseTableItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Invoice Number: ${data['invoiceNumber']}'),
      subtitle: Text('Total Amount: \$${data['totalAmount']}'),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        // Handle onTap event if needed
      },
    );
  }
}
