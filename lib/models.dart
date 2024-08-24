
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
  final int memberSince;
  final int forum;
  final Map? onBoarding;
  final Map? freeTextTags;
  final Map? filteredTags;
  final String? profileImage;
  final bool? banner;

  String fullName() {
    return ('$firstName $lastName');
  }

  // String getFreeTextTagVale(tag) {
  //   final freeTextTags = this.freeTextTags;
  //   if (freeTextTags!=null) {
  //     for (var element in freeTextTags) {
  //       element.keys
  //     }
  //   } else return ''; /// todo? send back hint?
  // }

  bool hasFilteredTag(cat,tag) {
    bool hasTag = false;
    if (filteredTags!=null) {
      if (filteredTags![cat]!=null) {
        hasTag =filteredTags![cat].contains(tag);
      }
    }
    return hasTag;
  }

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.residence,
    required this.mobile,
    required this.email,
    required this.forum,
    required this.memberSince,
    this.freeTextTags,
    this.filteredTags,
    this.profileImage,
    this.banner,
    this.onBoarding

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
        profileImage = doc["profileImage"],
        forum = doc["forum"],
        banner = doc["banner"],
        onBoarding = doc["onBoarding"],
        memberSince = doc['member_since'],
        freeTextTags = doc["free_text_tags"],
        filteredTags = doc["filtered_tags"];


}

