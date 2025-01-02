
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String? preferredChannel;
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
  bool? banner;
  String? bannerUri;
  int newMemberThresholdInMonths;
  ProfileScore? profileScore;

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
    this.preferredChannel,
    required this.forum,
    required this.joinDate,
    this.currentBusinessName = '',
    this.birthdate,
    this.children = const [],
    this.linkedin ='',
    this.instagram = '',
    this.facebook = '',
    this.profileImage = '',
    this.freeTextTags = const [],
    this.filterTags = const [],
    this.onBoarding = const {

    },
    this.settings = const {},
    this.banner = false,
    this.bannerUri,
    this.newMemberThresholdInMonths = 12,
    this.profileScore
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
  String getFreeTextTagValueByTemplateId(templateId) {
    String value ='';
    freeTextTags?.forEach((element) {
      var foundKey = element['templateId']==templateId;
      if (foundKey) value = element['value'];
    });
    return value;
  }
  bool isVerified() {
    if(onBoarding!=null) {
      return (onBoarding!.containsKey(onBoarding!['verified']) == true);
    } else {
      return false;
    }
  }
  bool isBoarded() {
    return onBoarding!['boarded'];
  }
  int getProfileScore() {
    int score = 0;
    if (!profileImage!.contains('profile0.jpg')) {
      score = score + profileScore!.profileImageScore!;
    }
    if (linkedin!='' || facebook!='' || linkedin!='') score = score + profileScore!.socialScore!;
    score = score + (filterTags!.length>5?5:filterTags!.length);
    score = score + freeTextTags!.length;
    if ((children ?? []).isEmpty) {
    } else {
      score = score + 2;
    }

    if (checkIfTodayIsBirthday(birthdate!)) score = score + profileScore!.birthdayScore!;
    if (checkIfNewMember()) score = score + profileScore!.newMemberScore!;
    return score;
  }
  int getNetProfileScore() {
    int score = 0;
    if (!profileImage!.contains('profile0.jpg')) {
      score = score + profileScore!.profileImageScore!;
    }
    if ((children ?? []).isEmpty) {
    } else {
      score = score + 2;
    }
    if (linkedin!='' || facebook!='' || linkedin!='') score = score + profileScore!.socialScore!;
    score = score + (filterTags!.length>5?5:filterTags!.length);
    if ((freeTextTags! ?? []).isEmpty) {
      score = score - 2;
    } else {
      score = score + freeTextTags!.length;
    }

    print('net score $score');
    return score;
  }
  bool checkIfTodayIsBirthday(Timestamp birthdayTimestamp) {
    DateTime today = DateTime.now();
    DateTime birthday = birthdayTimestamp.toDate();
    // Check if today is the birthday (ignoring the year)
    if (today.month == birthday.month && today.day == birthday.day) {
      //('Today is the birthday!');
      return true;
    } else {
      //print('Today is not the birthday.');
      return false;
    }
  }
  bool checkIfNewMember() {
    if (joinDate=='') return false;
    DateTime today = DateTime.now();
    DateTime memberSince = DateTime(int.parse(joinDate));
    /// Calculate the total months for each date
    int totalMonths1 = today.year * 12 + today.month;
    int totalMonths2 = memberSince.year * 12 + memberSince.month;
    if ((totalMonths2 - totalMonths1).abs() < newMemberThresholdInMonths) {
      return true;
    } else {
      return false;
    }
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
      'preferred_channel' : preferredChannel,
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
      'settings' : settings,
      'banner' : banner,
      'bannerUri' : bannerUri
    };
  }
  List<String> getChildrenTags() {
    int currentYear = DateTime.now().year;
    List<String> tagList = [];
    if (children!=null) {
      for (Map<String,dynamic> child in children!) {
        int childAge = currentYear - int.parse(child['year_of_birth']);
        if (childAge>0 && childAge<=3) tagList.add('Age (0-3)');
        else if (childAge>3 && childAge<=8) tagList.add('Age (4-8)');
        else if (childAge>8 && childAge<=12) tagList.add('Age (9-12)');
        else if (childAge>12 && childAge<=18) tagList.add('Age (13-17)');
        else if (childAge>18 && childAge<=21) tagList.add('Age (18-21)');
        else if (childAge>21 && childAge<=24) tagList.add('Age (21-24)');
        else if (childAge>24 && childAge<=29) tagList.add('Age (25-29)');
        else if (childAge>=30) tagList.add('Age (30+)');
      }
    }
    return tagList;
  }
  factory Member.fromDocumentSnapshot(DocumentSnapshot<Object?> doc){
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
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
        preferredChannel : data.containsKey('preferred_channel') ? data['preferred_channel'] as String : '',
        profileImage : data.containsKey('profileImage') ? data['profileImage'] as String : '',
        forum : data.containsKey('forum') ? data['forum'] as String : '',
        joinDate : data.containsKey('join_date') ? data['join_date'] as String : '',
        currentBusinessName :  data.containsKey('current_business_name') ? data['current_business_name'] as String : '',
        children : data.containsKey('children') ? (data['children'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList() : [],
        linkedin : data.containsKey('linkedin') ? data['linkedin'] as String : '',
        instagram : data.containsKey('instagram') ? data['instagram'] as String : '',
        facebook : data.containsKey('facebook') ? data['facebook'] as String : '',
        birthdate : data.containsKey('birthdate') ? data['birthdate']!=null?data['birthdate'] as Timestamp :Timestamp.fromMicrosecondsSinceEpoch(0):Timestamp.fromMicrosecondsSinceEpoch(0),
        freeTextTags : data.containsKey('free_text_tags') ? (data['free_text_tags'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList() : [],
        filterTags :  data.containsKey('filter_tags') ? List<String>.from(data["filter_tags"]) : [],
        onBoarding : data.containsKey('onBoarding') ? data['onBoarding'] as Map<String,dynamic> : {},
        settings : data.containsKey('settings') ? data['settings'] as Map<String,dynamic> : {},
        banner: data.containsKey('banner') ? data['banner'] as bool : false,
        bannerUri: data.containsKey('bannerUri') ? data['bannerUri'] as String : '',


    );
  }
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      uid: json.containsKey('uid') ? json['uid'] as String : '',
      firstName: json.containsKey('firstName') ? json['firstName'] as String : '',
      lastName: json.containsKey('lastName') ? json['lastName'] as String : '',
      currentTitle: json.containsKey('current_title') ? json['current_title'] as String : '',
      residence: json.containsKey('residence') ? json['residence'] as String : '',
      mobile: json.containsKey('mobile') ? json['mobile'] as String : '',
      mobileCountryCode: json.containsKey('mobile_country_code') ? json['mobile_country_code'] as String : '',
      email: json.containsKey('email') ? json['email'] as String : '',
      preferredChannel: json.containsKey('preferred_channel') ? json['preferred_channel'] as String : '',
      forum: json.containsKey('forum') ? json['forum'] as String : '',
      joinDate: json.containsKey('join_date') ? json['join_date'] as String : '',
      currentBusinessName: json.containsKey('current_business_name') ? json['current_business_name'] as String : '',
      birthdate: json.containsKey('birthdate') ? json['birthdate']??Timestamp.now() : Timestamp.now(),

      // Correctly handle List<Map<String, dynamic>> fields
      children: json.containsKey('children') && json['children'] != null
          ? (json['children'] as List).map((e) => Map<String, dynamic>.from(e)).toList()
          : [],

      // Correctly check the key for each field, not 'currentBusinessName'
      linkedin: json.containsKey('linkedin') ? json['linkedin'] as String : '',
      instagram: json.containsKey('instagram') ? json['instagram'] as String : '',
      facebook: json.containsKey('facebook') ? json['facebook'] as String : '',
      profileImage: json.containsKey('profileImage') ? json['profileImage'] as String : '',

      // Handle List<Map<String, dynamic>> fields
      freeTextTags: json.containsKey('free_text_tags') && json['free_text_tags'] != null
          ? (json['free_text_tags'] as List).map((e) => Map<String, dynamic>.from(e)).toList()
          : [],

      // Handle List<String> fields
      filterTags: json.containsKey('filter_tags') && json['filter_tags'] != null
          ? List<String>.from(json['filter_tags'])
          : [],

      // Handle Map<String, dynamic> fields
      onBoarding: json.containsKey('onBoarding') && json['onBoarding'] != null
          ? Map<String, dynamic>.from(json['onBoarding'])
          : {},

      settings: json.containsKey('settings') && json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'])
          : {},
      banner: json.containsKey('banner') ? json['banner'] as bool : false,
      bannerUri: json.containsKey('bannerUri') ? json['bannerUri'] as String : '',

    );
  }
}

class ResultRecord {
  final String label;
  final String id;

  const ResultRecord({required this.label, required this.id});

}

class ProfileScore {
  final int? profileImageScore;
  final int? birthdayScore;
  final int? newMemberScore;
  final int? socialScore;
  final int? topThreshold;
  final int? bottomThreshold;

  const ProfileScore({
    this.profileImageScore=10,
    this.birthdayScore = 100,
    this.newMemberScore = 5,
    this.socialScore = 5,
    this.topThreshold = 100,
    this.bottomThreshold = 12,
  });

  Map<String, dynamic> toMap() {
    return {
      'profile_image_score': profileImageScore,
      'birthday_score': birthdayScore,
      'new_member': newMemberScore,
      'social_score' : socialScore,
      'top_threshold' : topThreshold,
      'bottom_threshold' : bottomThreshold
    };
  }


  factory ProfileScore.fromDocumentSnapshot(DocumentSnapshot<Object?> doc){
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null ) {
      throw Exception("Required fields are missing");
    }
    return ProfileScore(
      profileImageScore : data.containsKey('profile_image_score') ? data['profile_image_score'] as int : 10,
      birthdayScore : data.containsKey('birthday_score') ? data['birthday_score'] as int : 100,
      newMemberScore : data.containsKey('new_member_score') ? data['new_member_score'] as int : 5,
      socialScore: data.containsKey('social_score') ? data['social_score'] as int : 5,
      topThreshold: data.containsKey('top_threshold') ? data['top_threshold'] as int : 100,
      bottomThreshold: data.containsKey('bottom_threshold') ? data['bottom_threshold'] as int : 12,
    );
  }

}