
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';



class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String title;
  final String residence;
  final String mobile;
  final String email;
  final List<String>? tags;
  final String? profileImage;
  final int? forum;
  final bool? banner;

  String fullName() {
    return ('$firstName $lastName');
  }

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.residence,
    required this.mobile,
    required this.email,
    required this.tags,
    this.profileImage,
    this.forum,
    this.banner
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'title': title,
      'residence': residence
    };
  }

  Member.DocumentSnapshot(DocumentSnapshot<Object?> doc):
        id = doc.id,
        firstName = doc["firstName"],
        lastName = doc["lastName"],
        title = doc["title"],
        residence = doc["residence"],
        mobile = doc["mobile"],
        email = doc["email"],
        tags = [doc["residence"]],
        profileImage = doc["profileImage"],
        forum = doc["forum"],
        banner = doc["banner"];
// address = Address.fromMap(doc.data()!["address"]),
// employeeTraits = doc.data()?["employeeTraits"] == null
//     ? null
//     : doc.data()?["employeeTraits"].cast<String>();



}

