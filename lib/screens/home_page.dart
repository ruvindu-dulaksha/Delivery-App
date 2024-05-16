import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savorease_app/screens/payment_page.dart';
import 'package:savorease_app/screens/profile_page.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
      primaryColor: Colors.orange,
    ),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<CartItem> _cartItems = [];
  String _selectedCategory = 'Burgers';

  void _addToCart(String productName, String productPrice, int quantity) {
    setState(() {
      final cartItem = _cartItems.firstWhere(
        (item) => item.name == productName,
        orElse: () =>
            CartItem(name: productName, price: productPrice, quantity: 0),
      );

      if (cartItem.quantity == 0) {
        _cartItems.add(cartItem);
      }
      cartItem.quantity += quantity;
    });
  }

  void _removeFromCart(String productName) {
    setState(() {
      final cartItem =
          _cartItems.firstWhere((item) => item.name == productName);
      if (cartItem.quantity > 0) {
        cartItem.quantity = 0;
        _cartItems.remove(cartItem);
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  double _calculateTotalPrice() {
    return _cartItems.fold(0.0, (total, item) {
      return total + (item.quantity * double.parse(item.price.substring(1)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Savor Ease'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              _showCart(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          Expanded(
            child: PageView(
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                PlaceholderWidget(
                  color: Colors.blueGrey,
                  category: _selectedCategory,
                  onAddToCart: _addToCart,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavBarItem(Icons.home, 'Home', 0),
              _buildNavBarItem(Icons.local_offer, 'Promotion', 1),
              _buildNavBarItem(Icons.person, 'Profile', 2),
              _buildNavBarItem(Icons.search, 'Search', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 58,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryButton('Burgers'),
          _buildCategoryButton('Drinks'),
          _buildCategoryButton('Desserts'),
          _buildCategoryButton('Rice and Pasta'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            setState(() {
              _currentIndex = index;
            });
            break;
          case 1:
            _showPromotions(context);
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
            break;
          default:
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? Colors.orange : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _currentIndex == index ? Colors.orange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return ListTile(
                          title: Text('${item.name} x${item.quantity}'),
                          subtitle: Text(
                            'Total: \$${(item.quantity * double.parse(item.price.substring(1))).toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                _removeFromCart(item.name);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Price: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _storeOrderDetails();
                        String city = 'Colombo'; // Example city
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(city: city),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        minimumSize: Size(double.infinity, 36),
                      ),
                      child: Text(
                        'Pay Here',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _storeOrderDetails() async {
    // Get the current user's email
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    // Get the total price
    double totalPrice = _calculateTotalPrice();

    // Get the city from the addresses table
    String city = 'Colombo'; // Example city
    // You can fetch the city from the addresses table in Firebase here

    // Store the order details in the "orders" collection in Firestore
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userEmail': userEmail,
        'city': city,
        'totalPrice': totalPrice,
        'items': _cartItems.map((item) {
          return {
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
          };
        }).toList(),
      });
      print('Order details stored successfully!');
    } catch (error) {
      print('Failed to store order details: $error');
    }
  }

  void _showPromotions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Promotions'),
          content: Text('Check out our latest promotions!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;
  final String category;
  final Function(String, String, int) onAddToCart;

  PlaceholderWidget(
      {required this.color, required this.category, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    List<Product> products = getProductList(category);
    Map<String, int> quantities = {};

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      padding: EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (context, index) {
        String productName = products[index].name;
        quantities[productName] = 1;

        return Card(
          elevation: 5.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  products[index].image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  products[index].name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  products[index].price,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              QuantitySelector(
                onChanged: (quantity) {
                  quantities[productName] = quantity;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    int quantity = quantities[productName] ?? 1;
                    onAddToCart(
                        products[index].name, products[index].price, quantity);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    minimumSize: Size(double.infinity, 36),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Product> getProductList(String category) {
    List<Product> productList = [];

    if (category == 'Burgers') {
      productList = [
        Product(
            name: 'Cheese Burger',
            price: '\$10.99',
            image: 'assets/category/hamburger.jpg'),
        Product(
            name: 'Chicken Burger',
            price: '\$9.99',
            image: 'assets/category/hamburger3.jpg'),
        Product(
            name: 'Beef Burger',
            price: '\$12.99',
            image:
                'assets/category/delicious-burger-with-many-ingredients-isolated-white-background-tasty-cheeseburger-splash-sauce.jpg'),
      ];
    } else if (category == 'Drinks') {
      productList = [
        Product(
            name: 'Ice Tea',
            price: '\$2.99',
            image: 'assets/category/ice-tea-with-mint.jpg'),
        Product(
            name: 'Mojito',
            price: '\$3.99',
            image:
                'assets/category/refreshing-alcoholic-drink-ready-be-served.jpg'),
        Product(
            name: 'Cola',
            price: '\$4.99',
            image: 'assets/category/fresh-cola-drink-glass.jpg'),
      ];
    } else if (category == 'Desserts') {
      productList = [
        Product(
            name: 'Ice Cream',
            price: '\$5.99',
            image: 'assets/category/dessert.jpg'),
        Product(
            name: 'Banana Bread',
            price: '\$6.99',
            image: 'assets/category/dessert3.jpg'),
        Product(
            name: 'Lava Cake',
            price: '\$7.99',
            image: 'assets/category/dessert5.jpg'),
      ];
    } else if (category == 'Rice and Pasta') {
      productList = [
        Product(
            name: 'Pasta Tomato Sauce with Chicken',
            price: '\$8.99',
            image:
                'assets/category/penne-pasta-tomato-sauce-with-chicken-tomatoes-wooden-table.jpg'),
        Product(
            name: 'Grilled Seafood',
            price: '\$9.99',
            image:
                'assets/category/grilled-seafood-paella-gourmet-healthy-meal-generated-by-ai.jpg'),
        Product(
            name: 'Shawarma',
            price: '\$10.99',
            image:
                'assets/category/side-view-shawarma-with-fried-potatoes-board-cookware.jpg'),
      ];
    }

    return productList;
  }
}

class Product {
  final String name;
  final String price;
  final String image;

  Product({required this.name, required this.price, required this.image});
}

class QuantitySelector extends StatefulWidget {
  final ValueChanged<int>? onChanged;

  const QuantitySelector({Key? key, this.onChanged}) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              if (_quantity > 1) _quantity--;
            });
            widget.onChanged?.call(_quantity);
          },
          icon: Icon(Icons.remove),
        ),
        Text('$_quantity'),
        IconButton(
          onPressed: () {
            setState(() {
              _quantity++;
            });
            widget.onChanged?.call(_quantity);
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}

class CartItem {
  final String name;
  final String price;
  int quantity;

  CartItem({required this.name, required this.price, required this.quantity});
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            // Perform search functionality here
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Search Result'),
                content: Text('Searched for: $value'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
