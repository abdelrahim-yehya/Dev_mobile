import 'package:flutter/material.dart';
import 'activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'person.dart';

class DetailPage extends StatelessWidget {
  final Act activity;
  final Person person;
  bool _exists =false ;
  String message = "Activity added!";

  DetailPage({Key? key, required this.activity,required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              activity.image,
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              activity.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Category: ${activity.category}',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Location: ${activity.location}',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Minimum Participants: ${activity.min_participants}',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Price: ${activity.price}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    person.activities.forEach((element) {
                      if (activity.id == element.id) {
                        _exists = true;
                        message = "Activity already in cart";
                      }
                    });
                    if (!_exists) {
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(person.username).get();
                      print("------------------------------------------------>shou l wad3 ?");
                      await userDoc.reference.update({'activities': FieldValue.arrayUnion([activity.id])});

                      person.activities.add(activity);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
