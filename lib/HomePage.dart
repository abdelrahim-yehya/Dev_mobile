import 'package:flutter/material.dart';
import 'package:projet_mobile/ProfilePage.dart';
import 'LoginPage.dart';
import 'activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'person.dart';
import 'DetailPage.dart';
import 'CartPage.dart' ;
import 'AddActivityPage.dart';

class HomePage extends StatefulWidget {
  final Person person;

  HomePage({required this.person});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Act> activities = [];
  late List<String> categories = [];
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    fetchActivities().then((value) {
      setState(() {
        activities = value;
        categories = activities.map((activity) => activity.category).toSet().toList();
      });
    }).catchError((error) {
      print('Failed to fetch activities: $error');
    });
  }

  Future<List<Act>> fetchActivities() async {
    List<Act> activities = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Activities').get();
    querySnapshot.docs.forEach((doc) {
      var data = doc.data();
      if (data != null) {
        Act activ = Act.fromMap(data as Map<String, dynamic>);
        activ.setId(doc.id);
        activities.add(activ);
      }
    });
    return activities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Welcome ${widget.person.firstName}',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddActivityPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Activities',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Center(
                child: DropdownButton<String>(
                  value: selectedCategory.isNotEmpty ? selectedCategory : null,
                  hint: Text('Filter by category'),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory = value ?? '';
                    });
                  },
                  items: ['All', ...categories].map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category.isNotEmpty ? category : 'All',
                      child: Text(category.isNotEmpty ? category : 'All'),
                    );
                  }).toList(),
                ),
              ),
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (BuildContext context, int index) {
                Act activity = activities[index];
                if (selectedCategory.isNotEmpty && selectedCategory != 'All' && activity.category != selectedCategory) {
                  return SizedBox.shrink();
                }
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(activity.location),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        activity.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(activity: activity, person: widget.person),
                        ),
                      );
                    },
                  ),
                );
              },
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
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex){
        case 0: break;

        case 1: 
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CartPage(person: widget.person)),
          );
          _selectedIndex = 0;
        }
              

        case 2: Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(person: widget.person)),
        );
        _selectedIndex = 0;
      }
    });
  }
}
