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
  RxList<Member> filteredResults = RxList<Member>();
  RxBool loading = true.obs;
  RxBool resultsLoading = true.obs;
  RxString currentUserUid = ''.obs;
  Rx<Member> currentMember = Member(memberSince: 0,forum: 0, id: 'NA', firstName: 'NAA', lastName: 'NA', title: 'NA', residence: 'NA', mobile: 'NA', email: 'NA').obs;
  Member noUser = Member(memberSince: 0,forum: 0, id: 'NA', firstName: 'NA', lastName: 'NA', title: 'NA', residence: 'NA', mobile: 'NA', email: 'NA');
  Rx<String> authErrMsg = ''.obs;
  List<Map> freeTextTagsList = [];
  List<Map> filteredTagsList = [];
  /// AUTH
  final user = FirebaseAuth.instance.currentUser;
  setCurrentUser(User? user) async {
    if (user!=null) currentMember.value = await getMemberInfo(user.email);
  }
  fetchFilteredMembers(List<String> selectedFilters) async {
    if (selectedFilters.isEmpty) {
      filteredResults.value = [];
      resultsLoading.value = false;
      return;
    }
    resultsLoading.value = true;
    final membersRef = db.collection("Members");
    final membersQuery = await membersRef.where("tags", arrayContainsAny: selectedFilters).get();
    final membersDocs = membersQuery.docs;
    filteredResults.value =[];
    for (var member in membersDocs) {
      filteredResults.add(Member.DocumentSnapshot(member));
    }
    resultsLoading.value = false;
    update();
  }
  validateMemberEmail(String email) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: email).get();
    return (memberSnapshot.docs.isNotEmpty);
  }
  getMemberInfo(String? email) async {
    if (email==null) return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
  }
  onRegister(User user) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: user.email).get();
    var memberId = memberSnapshot.docs.first.id;
    var memberData = memberSnapshot.docs.first.data() as Map<String, dynamic>;
    var displayName = memberData['firstName']+" "+memberData['lastname'];
    await FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
    membersRef.doc(memberId).update(
      {
        'uid' : user.uid,
        'onBoarding.registered' : true
      }
    );
    return (memberSnapshot.docs.isNotEmpty);
  }
  onVerify(User user) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: user.email).get();
    var memberId = memberSnapshot.docs.first.id;
    await membersRef.doc(memberId).update(
        {
          'onBoarding.verified' : true
        }
    );
    return (memberSnapshot.docs.isNotEmpty);
  }
  /////
  loadTags() async {
    ///load free text tags
    CollectionReference freeTextTagsRef = db.collection('FreeTextTags');
    QuerySnapshot freeTextTagsSnapshot = await freeTextTagsRef.get();
    List<QueryDocumentSnapshot>  freeTextTagsDocList =  freeTextTagsSnapshot.docs;
    for (var tag in freeTextTagsDocList) {
      freeTextTagsList.add(tag.data() as Map<String, dynamic>);
    }
    ///load filtered tags
    CollectionReference filteredTagsRef = db.collection('FilterTags');
    QuerySnapshot filteredTagsSnapshot = await filteredTagsRef.get();
    List<QueryDocumentSnapshot>  filteredTagsQuery =  filteredTagsSnapshot.docs;
    for (var tag in filteredTagsQuery) {
      filteredTagsList.add(tag.data() as Map<String, dynamic>);
    }
  }
  List<String> getFilteredTagsFromCategory(category) {
    List<String> list = [];
    var catIndex = filteredTagsList.indexWhere((cat) => cat['key']==category);
    List tagsList = filteredTagsList[catIndex]['tags_list'];
    for (var tag in tagsList) {
      list.add(tag);
    }
    return list;
  }

  @override
  onInit() async {
    super.onInit();
    currentMember.value = await getMemberInfo(user?.email);
    filteredResults.add(currentMember.value);

    ///
    /// Load Tags and Filters
    await loadTags();
    members.value = MEMBERS;
    await fetchFilteredMembers([]);
    loading.value = false;
    update();
    print('ctx done init.');
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
    Member(id: 'NA', firstName: 'NA', lastName: 'NA', title: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', forum: 0, memberSince: 0),
  // Member('0', 'Shani', 'Ankorin','CEO NVIDIA','Tel Aviv' ,'0544-2323453', 'email@gamers.com',['תל אביב','היי טק'],'images/profile5.jpg',1,false),
  // Member('1', 'Gilad', 'Baror','CEO Toyota','Herzliya', '23232323', 'email@gamers.com',['הרצליה','רכב'],'images/profile2.jpg',3,true),
  // Member('2', 'Benny', 'Arbel','CEO Yoga International','Ramat Hasharon','094343443', 'email@gamers.com',['רמת השרון','לייף סטייל'],'images/profile3.jpg',5,false),
  // Member('3', 'Yosi', 'Cohen','CEO Mossad','Kadima','03-9999999', 'email@gamers.com',['קדימה','אבטחה'],'images/profile4.jpg',5,true),
  // Member('4', 'Shuli', 'Buli','Chariman BlaBla Inc.','Tel Aviv','04-434343', 'email@gamers.com',['תל אביב','פושטי רגל'],'images/profile1.jpg',6,true),
  // Member('5', 'Herzi', 'Halevi','Chairman IDF','Even Yehuda','04-43432243', 'email@gamers.com',['אבן יהודה','אבטחה'],'images/profile6.jpg',8,true),
  // Member('6', 'Barbie', 'Cohen','CEO Love Ltd.','Jerusalem','02-2143274', 'email@gamers.com',['ירושלים','קוסמטיקה'],'images/profile7.jpg',10,true),

];

/*
{title: Chariman at  2Two, email: haggaibb@gmail.com, member_since: 2009, firstName: Haggai, free_text_tags: {favorite_food: Sushi, favorite_pet: Dog}, forum: 5, residence: Herzliya, filtered_tags: {industry: [Hi Tech]}, profileImage: https://media.licdn.com/dms/image/C4D03AQFXuPK5twkpJA/profile-displayphoto-shrink_200_200/0/1604828273946?e=2147483647&v=beta&t=xzlsaXyeFnu3TZpFE-e1thz2F6vPKUCTCfOFjbK4U2s, lastName: Barel, banner: false, mobile: 972544510999, uid: bbcssvVuF0Pa99zizafm2Mb4eC93, onBoarding: {borded: false, verified: true, uid: , registered: true}}
 */