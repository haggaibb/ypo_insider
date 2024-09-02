
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String? uid;
  String currentTitle;
  String residence;
  String mobile;
  String mobileCountryCode;
  String email;
  String forum;
  String joinDate;
  String currentBusinessName;
  String? linkedin;
  String? instagram;
  String? facebook;
  Timestamp? birthdate;
  late String? profileImage;
  List<Map<String, dynamic>>? freeTextTags;
  List<String>? filterTags;
  Map? onBoarding;
  Map? settings;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.uid,
    required this.currentTitle,
    required this.residence,
    required this.mobile,
    required this.mobileCountryCode,
    required this.email,
    required this.forum,
    required this.joinDate,
    required this.currentBusinessName,
    required this.birthdate,
    this.linkedin ='',
    this.instagram = '',
    this.facebook = '',
    this.profileImage = '',
    this.freeTextTags = const [],
    this.filterTags = const [],
    this.onBoarding = const {

    },
    this.settings = const {}
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
  List<dynamic> getMemberFreeTextTags() {
    //print('in model get free tags');
    //print(freeTextTags);
    //var freeTextTagsList = freeTextTags?.entries.map( (entry) => entry.value).toList();
    //print(freeTextTagsList);
    //return freeTextTagsList??[];
    return freeTextTags??[];
  }
  String getFreeTextTagValueByKey(key) {
    String value ='';
    freeTextTags?.forEach((element) {
      var foundKey = element['key']==key;
      if (foundKey) value = element['value'];
    });
    return value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'uid' : uid,
      'current_title': currentTitle,
      'residence': residence,
      'mobile' :mobile,
      'mobile_country_code' :mobileCountryCode,
      'email' : email,
      'profileImage' : profileImage,
      'forum' : forum,
      'join_date' : joinDate,
      'current_business_name' : currentBusinessName,
      'linkedin' : linkedin,
      'instagram' : instagram,
      'facebook' : facebook,
      'birthdate' : birthdate,
      'free_text_tags' : freeTextTags,
      'filter_tags' : filterTags,
      'onBoarding' : onBoarding,
      'settings' : settings
    };
  }

  Member.DocumentSnapshot(DocumentSnapshot<Object?> doc):
        id = doc.id,
        firstName = doc["firstName"],
        lastName = doc["lastName"],
        uid =  doc["uid"]??'',
        currentTitle = doc["current_title"],
        residence = doc["residence"].trim()??'NA',
        mobile = doc["mobile"],
        mobileCountryCode = doc['mobile_country_code'],
        email = doc["email"],
        profileImage = doc["profileImage"]??'',
        forum = doc["forum"]??'NA',
        joinDate = doc['join_date'],
        currentBusinessName = doc['current_business_name'],
        linkedin = doc['linkedin']??'',
        instagram = doc['instagram']??'',
        facebook = doc['facebook']??'',
        birthdate = doc['birthdate'],
        freeTextTags = List<Map<String, dynamic>>.from(doc["free_text_tags"]),
        filterTags =  List<String>.from(doc["filter_tags"]),
        onBoarding = doc["onBoarding"],
        settings = doc['settings'];
}

class ResultRecord {
  final String label;
  final String id;

  const ResultRecord({required this.label, required this.id});

}

