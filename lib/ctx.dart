
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
//import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'dart:async';
import 'dart:math';
import 'models.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  var db = FirebaseFirestore.instance;
  RxList<Member> members = RxList<Member>();
  List<String> activeFilters = <String>[].obs;
  List<Member> filteredResults = <Member>[].obs;
  RxBool loading = true.obs;
  RxBool resultsLoading = true.obs;
  RxString currentUserUid = ''.obs;
  Rx<Member> currentMember = Member(id: 'NA', firstName: 'NAA', lastName: 'NA', title: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', tags: ['NA']).obs;
  Member noUser = Member(id: 'NA', firstName: 'NA', lastName: 'NA', title: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', tags: ['NA']);

  fetchFilteredMembers(List<String> selectedFilters) async {
    resultsLoading.value = true;
    await Future.delayed(const Duration(seconds: 0));
    filteredResults = [MEMBERS[Random().nextInt(1)],MEMBERS[Random().nextInt(1)],MEMBERS[Random().nextInt(1)],MEMBERS[Random().nextInt(1)],MEMBERS[Random().nextInt(1)]];
    //filteredResults = [MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)],MEMBERS[Random().nextInt(7)]];
    resultsLoading.value = false;
    update();

  }

  setCurrentUser(User? user) async {
    if (user!=null) currentMember.value = await getMemberInfo(user.uid);
  }

  getMemberInfo(String uid) async {
    print(uid);
    DocumentReference memberRef = db.collection('Members').doc(uid);
    DocumentSnapshot memberDoc = await memberRef.get();
    return Member.DocumentSnapshot(memberDoc);
  }

  @override
  onInit() async {
    super.onInit();
    await Future.delayed(const Duration(seconds: 0));
    members.value = MEMBERS;
    await fetchFilteredMembers([]);
    loading.value = false;
    update();
    print('done init.');
  }


}




var FILTERS = {
  'מגורים' : ['תל אביב' , 'הרצליה', 'קדימה' , 'רמת השרון'],
  'תעשייה' : ['היי טק','תעשיה כבדה','רכב','בנקאות','פינטק','תיירות', 'פושטי רגל', 'לייף סטייל', 'אבטחה'],
  'ספורט' : ['היי טק','תעשיה כבדה','רכב','בנקאות','פינטק','תיירות', 'פושטי רגל', 'לייף סטייל', 'אבטחה'],
  'לייף סטייל' : ['היי טק','תעשיה כבדה','רכב','בנקאות','פינטק','תיירות', 'פושטי רגל', 'לייף סטייל', 'אבטחה'],
  'פורום' : ['פורום 1','פורום 2','פורום 3','פורום 4','פורום 5','פורום 6', 'פורום 7', 'פורום 8', 'פורום 9'],
  'שונות' : ['היי טק','תעשיה כבדה','רכב','בנקאות','פינטק','תיירות', 'פושטי רגל', 'לייף סטייל', 'אבטחה','קוסמטיקה'],
};

List<Member> MEMBERS = [
    Member(id: 'NA', firstName: 'NA', lastName: 'NA', title: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', tags: ['NA']),
  // Member('0', 'Shani', 'Ankorin','CEO NVIDIA','Tel Aviv' ,'0544-2323453', 'email@gamers.com',['תל אביב','היי טק'],'images/profile5.jpg',1,false),
  // Member('1', 'Gilad', 'Baror','CEO Toyota','Herzliya', '23232323', 'email@gamers.com',['הרצליה','רכב'],'images/profile2.jpg',3,true),
  // Member('2', 'Benny', 'Arbel','CEO Yoga International','Ramat Hasharon','094343443', 'email@gamers.com',['רמת השרון','לייף סטייל'],'images/profile3.jpg',5,false),
  // Member('3', 'Yosi', 'Cohen','CEO Mossad','Kadima','03-9999999', 'email@gamers.com',['קדימה','אבטחה'],'images/profile4.jpg',5,true),
  // Member('4', 'Shuli', 'Buli','Chariman BlaBla Inc.','Tel Aviv','04-434343', 'email@gamers.com',['תל אביב','פושטי רגל'],'images/profile1.jpg',6,true),
  // Member('5', 'Herzi', 'Halevi','Chairman IDF','Even Yehuda','04-43432243', 'email@gamers.com',['אבן יהודה','אבטחה'],'images/profile6.jpg',8,true),
  // Member('6', 'Barbie', 'Cohen','CEO Love Ltd.','Jerusalem','02-2143274', 'email@gamers.com',['ירושלים','קוסמטיקה'],'images/profile7.jpg',10,true),

];