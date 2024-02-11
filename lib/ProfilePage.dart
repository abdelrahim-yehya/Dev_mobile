import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_mobile/LoginPage.dart';
import 'person.dart';
import 'CartPage.dart';
import 'HomePage.dart';

class ProfilePage extends StatefulWidget {
  final Person person;
  

  ProfilePage({required this.person});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;
  int _selectedIndex = 2;
  bool _showPassword = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _birthdayController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _cityController = TextEditingController();
    fetchUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void fetchUserProfile() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(widget.person.username).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _usernameController.text = userData['username'];
          _passwordController.text = userData['password'];
          _birthdayController.text = userData['birthday'];
          _addressController.text = userData['address'];
          _postalCodeController.text = userData['postalCode'];
          _cityController.text = userData['city'];
        });
      }
    } catch (error) {
      print('Failed to fetch user profile: $error');
    }
  }

  void saveUserProfile() async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(widget.person.username).update({
        'password': _passwordController.text,
        'birthday': _birthdayController.text,
        'address': _addressController.text,
        'postalCode': _postalCodeController.text,
        'city': _cityController.text,
      });
      print('User profile updated successfully');
    } catch (error) {
      print('Failed to update user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword, // Use the _showPassword variable to toggle visibility
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Birthday'),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
              readOnly: true,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _postalCodeController,
              decoration: InputDecoration(labelText: 'Postal Code'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: saveUserProfile,
              child: Text('Validate'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
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
        _selectedIndex = 0;

        case 1: 
        {
        Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(person: widget.person)),
              );
        _selectedIndex = 0;
        }
              

        case 2:break;
      }
      
    });
  }
  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );
  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
      _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }
}
}
