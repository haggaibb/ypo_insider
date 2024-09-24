import 'dart:js' as js;
import 'package:cloud_firestore/cloud_firestore.dart';



void updateSplashScreenText(String message) {
  js.context.callMethod('updateStatusText', [message]);
}


bool checkIfTodayIsBirthday(Timestamp birthdayTimestamp) {
  print('in birth');
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

bool checkIfNewMember(String joinDate) {
  if (joinDate=='') return false;
  DateTime today = DateTime.now();
  DateTime memberSince = DateTime(int.parse(joinDate));
  // Calculate the total months for each date
  int totalMonths1 = today.year * 12 + today.month;
  int totalMonths2 = memberSince.year * 12 + memberSince.month;
  if ((totalMonths2 - totalMonths1).abs() < 24) {
    return true;
  } else {
    return false;
  }
}