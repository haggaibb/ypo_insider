
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Member {
  final String id;
  final String firstName;
  final String lastName;
  String currentTitle;
  String residence;
  String mobile;
  String mobileCountryCode;
  String email;
  String forum;
  String joinDate;
  String currentBusinessName;
  Timestamp birthdate;
  late String? profileImage;
  Map? freeTextTags;
  List<String>? filterTags;
  Map? onBoarding;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.currentTitle,
    required this.residence,
    required this.mobile,
    required this.mobileCountryCode,
    required this.email,
    required this.forum,
    required this.joinDate,
    required this.currentBusinessName,
    required this.birthdate,
    this.profileImage,
    this.freeTextTags,
    this.filterTags = const [],
    this.onBoarding = const {

    }
  });

  String fullName() {
    return ('$firstName $lastName');
  }
  bool hasFilterTag(cat,tag) {
    bool hasTag = false;
    if (filterTags!=null) {
      hasTag =filterTags![cat].contains(tag);
        }
    return hasTag;
  }
  List<String> getMemberFilterTags() {
    List<String> tags =[];
    if (filterTags!=null) {
      for (var v in filterTags!) {
        tags.add(v);
      }
    }
    return tags;
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'current_title': currentTitle,
      'residence': residence,
      'mobile' :mobile,
      'mobile_country_code' :mobileCountryCode,
      'email' : email,
      'profileImage' : profileImage,
      'forum' : forum,
      'join_date' : joinDate,
      'current_business_name' : currentBusinessName,
      'birthdate' : birthdate,
      'free_text_tags' : freeTextTags,
      'filter_tags' : filterTags,
      'onBoarding' : onBoarding
    };
  }

  Member.DocumentSnapshot(DocumentSnapshot<Object?> doc):
        id = doc.id,
        firstName = doc["firstName"],
        lastName = doc["lastName"],
        currentTitle = doc["current_title"],
        residence = doc["residence"]??'NA',
        mobile = doc["mobile"],
        mobileCountryCode = doc['mobile_country_code'],
        email = doc["email"],
        profileImage = doc["profileImage"]??'',
        forum = doc["forum"]??'NA',
        joinDate = doc['join_date'],
        currentBusinessName = doc['current_business_name'],
        birthdate = doc['birthdate'],
        freeTextTags = doc["free_text_tags"]??{},
        filterTags =  List<String>.from(doc["filter_tags"]),
        onBoarding = doc["onBoarding"];
}

