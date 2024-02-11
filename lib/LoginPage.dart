import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_mobile/activity.dart';
import 'person.dart';
import 'SignUpPage.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> login() async {
  if (_formKey.currentState!.validate()) {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: _usernameController.text)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid username';
        });
        return;
      }

      final userData = querySnapshot.docs.first.data();
      if (userData == null || userData is! Map<String, dynamic>) {
        setState(() {
          _errorMessage = 'Failed to retrieve user data';
        });
        return;
      }

      final password = userData['password'];
      if (password == null || password != _passwordController.text) {
        setState(() {
          _errorMessage = 'Invalid password';
        });
        return;
      }

      final firstName = userData['firstName'];
      final lastName = userData['lastName'];
      var acts = [];
      if(userData['activities'] != "")
      {
        acts = userData['activities'];
        print("------------------------------------------------>>>>>>>>${userData['activities']}");
      }
      final activities = acts;
      List<Act> userActivities = [];
      for (var activityId in activities) {
        DocumentSnapshot activityDoc = await FirebaseFirestore.instance
        .collection('Activities')
        .doc(activityId)
        .get();
        if (activityDoc.exists) {
              Act activity = Act.fromMap(activityDoc.data() as Map<String, dynamic>);
              activity.setId(activityDoc.id);
              userActivities.add(activity);
              }
      }
      print("------------------------------------------------>>>>>>>>${userActivities.length}");


      final person = Person(
        username: _usernameController.text,
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName, 
        activities: userActivities,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(person: person),
        ),
      );
    } catch (error) {
      print('Failed to log in: $error');
      setState(() {
        _errorMessage = 'Failed to log in';
      });
    }
  }
}

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.lightBlueAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.7],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Image.asset(
                    'assets/logo.jpg',
                    height: 150,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: login,
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text('Don\'t have an account? Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
