import 'package:flutter/material.dart';
import 'package:projet_mobile/HomePage.dart';
import 'person.dart';
import 'activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProfilePage.dart';

class CartPage extends StatefulWidget {
  final Person person;

  const CartPage({Key? key, required this.person}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late double totalPrice;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    totalPrice = calculateTotalPrice();
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var activity in widget.person.activities) {
      total += activity.price;
    }
    return total;
  }

  void removeFromCart(Act activity) async {
  setState(() {
    widget.person.activities.remove(activity);
    totalPrice = calculateTotalPrice();
  });

  try {
    await FirebaseFirestore.instance.collection('Users').doc(widget.person.username).update({
      'activities': FieldValue.arrayRemove([activity.id]),
    });
    print('Activity removed from the cart in Firestore');
  } catch (error) {
    print('Failed to remove activity from the cart in Firestore: $error');

  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Your cart',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.person.activities.length,
              itemBuilder: (BuildContext context, int index) {
                Act activity = widget.person.activities[index];
                return ListTile(
                  leading: Image.network(
                    activity.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(activity.title),
                  subtitle: Text(activity.location),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      removeFromCart(activity);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Price: \$${calculateTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex){
        case 0: 
        Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(person: widget.person)),
              );

        case 1: break;

        case 2: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(person: widget.person)),
              );
      }
      
    });
  }
}

