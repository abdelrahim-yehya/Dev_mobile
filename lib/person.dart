import 'activity.dart';

class Person {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final List<Act> activities;

  Person({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.activities
  });
}
