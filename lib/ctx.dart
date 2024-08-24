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
    await fetchFilteredMembers([]);
    loading.value = false;
    update();
    print('ctx done init.');
  }


}

