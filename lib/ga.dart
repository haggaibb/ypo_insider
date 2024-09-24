import 'package:firebase_analytics/firebase_analytics.dart';



class AnalyticsEngine {
  static final _instance = FirebaseAnalytics.instance;

  static Future<void> userLogsIn(String loginMethod, String fullName) async {
    ///print('log -- user log in --');
    try {
      await _instance.logLogin(
          loginMethod: 'firebase_auth',
          parameters: <String, Object>{"user": fullName});
    } catch (err) {
      ///print('log to GA err:  user log in');
      ///print(err);
    }
  }

  static Future<void> logUserOpensApp(String fullName) async {
    print('log -- user opens app --');
    try {
      await _instance
          .logEvent(name: 'open_app', parameters: <String, Object>{
        "user" : fullName
      });
    } catch (err) {
      print('log to GA err:  user opens app');
      print(err);
    }
  }

  static Future<void> logProfileView(String fullName) async {
    //print('log -- Profile View --');
    try {
      await _instance
          .logEvent(name: 'profile_view', parameters: <String, Object>{
        //"profile_viewed" : fullName
      });
    } catch (err) {
      //print('log to GA err:  Profile View');
      //print(err);
    }
  }

  static Future<void> logProfileEdit(String fullName) async {
    //print('log -- Profile Edit --');
    try {
      await _instance
          .logEvent(name: 'profile_edit', parameters: <String, Object>{
        "profile_edited" : fullName
      });
    } catch (err) {
      //print('log to GA err:  Profile Edit');
      //print(err);
    }
  }

  static Future<void> logFilterTagsSearch(String tags) async {
    //print('log -- Filter Tags Search --');
    try {
      await _instance
          .logEvent(name: 'filter_tags_search', parameters: <String, Object>{
        "tags" : tags
      });
    } catch (err) {
      //print('log to GA err:  Filter Tags Search');
      print(err);
    }
  }

  static Future<void> logOnBoarding(String name, String status) async {
    //print('log --Onboarding --');
    try {
      await _instance
          .logEvent(name: 'on_boarding', parameters: <String, Object>{
        'status' : status,
        'email' : name,
      });
    } catch (err) {
      //print('log to GA err: Onboarding');
      //print(err);
    }
  }

  static Future<void> logMemberRegistered(String name) async {
    print('log --Member Registered --');
    try {
      await _instance
          .logEvent(name: 'member_registered', parameters: <String, Object>{
        "name" : name
      });
    } catch (err) {
      print('log to GA err: Member Registered');
      print(err);
    }
  }


}
