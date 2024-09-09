
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
  List<Map<String, dynamic>>? children;
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
    this.children = const [],
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
      'children' : children,
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

  factory Member.fromDocumentSnapshot(DocumentSnapshot<Object?> doc){
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    print(data);
    if (data == null ) {
      throw Exception("Required fields are missing");
    }
    return Member(
        id: doc.id, // Required field, no null check
        firstName : data.containsKey('firstName') ? data['firstName'] as String : '',
        lastName : data.containsKey('lastName') ? data['lastName'] as String : '',
        uid :   data.containsKey('uid') ? data['uid'] as String : '',
        currentTitle :  data.containsKey('current_title') ? data['current_title'] as String : '',
        residence :  data.containsKey('residence') ? data['residence'] as String : '',
        mobile :  data.containsKey('mobile') ? data['mobile'] as String : '',
        mobileCountryCode :data.containsKey('mobile_country_code') ? data['mobile_country_code'] as String : '',
        email :data.containsKey('email') ? data['email'] as String : '',
        profileImage : data.containsKey('profileImage') ? data['profileImage'] as String : '',
        forum : data.containsKey('forum') ? data['forum'] as String : '',
        joinDate : data.containsKey('join_date') ? data['join_date'] as String : '',
        currentBusinessName :  data.containsKey('current_business_name') ? data['current_business_name'] as String : '',
        children : data.containsKey('children') ? (data['children'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList() : [],
        linkedin : data.containsKey('linkedin') ? data['linkedin'] as String : '',
        instagram : data.containsKey('instagram') ? data['instagram'] as String : '',
        facebook : data.containsKey('facebook') ? data['facebook'] as String : '',
        birthdate : data.containsKey('birthdate') ? data['birthdate'] as Timestamp : null,
        freeTextTags : data.containsKey('free_text_tags') ? (data['free_text_tags'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList() : [],
        filterTags :  data.containsKey('filter_tags') ? List<String>.from(data["filter_tags"]) as List<String> : [],
        onBoarding : data.containsKey('onBoarding') ? data['onBoarding'] as Map<String,dynamic> : {},
        settings : data.containsKey('settings') ? data['settings'] as Map<String,dynamic> : {},
    );


        }

}

class ResultRecord {
  final String label;
  final String id;

  const ResultRecord({required this.label, required this.id});

}

