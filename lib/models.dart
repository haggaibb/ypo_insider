
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
  Map? filteredTags;
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
    this.filteredTags = const {},
    this.onBoarding = const {

    }
  });

  String fullName() {
    return ('$firstName $lastName');
  }
  bool hasFilterTag(cat,tag) {
    bool hasTag = false;
    if (filteredTags!=null) {
      if (filteredTags![cat]!=null) {
        hasTag =filteredTags![cat].contains(tag);
      }
    }
    return hasTag;
  }
  List<String> getMemberFilterTags() {
    List<String> tags =[];
    if (filteredTags!=null) {
      for (var v in filteredTags!.values) {
        print("Value: $v");
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
      'title': currentTitle,
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
      'filtered_tags' : filteredTags,
      'onBoarding' : onBoarding
    };
  }

  Member.DocumentSnapshot(DocumentSnapshot<Object?> doc):
        id = doc.id,
        firstName = doc["firstName"],
        lastName = doc["lastName"],
        currentTitle = doc["current_title"],
        residence = doc["residence"],
        mobile = doc["mobile"],
        mobileCountryCode = doc['mobile_country_code'],
        email = doc["email"],
        profileImage = doc["profileImage"],
        forum = doc["forum"],
        joinDate = doc['join_date'],
        currentBusinessName = doc['current_business_name'],
        birthdate = doc['birthdate'],
        freeTextTags = doc["free_text_tags"]??{},
        filteredTags = doc["filtered_tags"]??{},
        onBoarding = doc["onBoarding"];
}

