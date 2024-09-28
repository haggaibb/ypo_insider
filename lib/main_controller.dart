import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'ga.dart';
import 'utils.dart';


class MainController extends GetxController {
  var db = FirebaseFirestore.instance;
  List<ResultRecord> allMembersFullName = [];
  List<ResultRecord> allCompanies = [];
  List<ResultRecord> suggestionsList = [];
  List<String> residenceList = [];
  List<String> forumList = [];
  List<Map<String, dynamic>> freeTextTagsList = [];
  List<Map> filteredTagsList = [];
  RxList<String> tags = <String>[].obs;
  List<String> activeFilters = <String>[].obs;
  RxList<Member> filteredResults = RxList<Member>();
  RxBool resultsLoading = true.obs;
  RxBool mainLoading = false.obs;
  RxBool isAnd = true.obs;
  int numberOfMembers = 1;
  int numberOfRandomMembers =10;
  int newMemberThreshold = 12;
  final user = FirebaseAuth.instance.currentUser;

  getSettings() async {
    final settingsRef = db.collection("Settings").doc('results_settings');
    final DocumentSnapshot membersQuery = await settingsRef.get();
    var settingsData = membersQuery.data() as Map<String, dynamic>;
    numberOfRandomMembers = settingsData['number_of_random_members'];
    newMemberThreshold  = settingsData['new_member_threshold_in_months'];
  }

  fetchFilteredMembers(List<String> selectedFilters) async {
    resultsLoading.value = true;
    if (selectedFilters.isEmpty) {
      filteredResults.value = [];

      /// TODO add ref to def result list if we wish
      resultsLoading.value = false;
      return;
    }
    List<QueryDocumentSnapshot> filteredMembers;
    final membersRef = db.collection("Members");
    final QuerySnapshot membersQuery = await membersRef
        .where("filter_tags", arrayContainsAny: selectedFilters)
        .get();
    if (isAnd.value) {
      filteredMembers = membersQuery.docs.where((doc) {
          // Safely cast the 'filter_tags' array to List<String>
        List<String> filterTags =
            List<String>.from(doc['filter_tags'] as List<dynamic>);
        // Check if all the selectedTags are in filterTags
        return selectedFilters.every((tag) => filterTags.contains(tag));
      }).toList();
    } else {
      filteredMembers = membersQuery.docs;
    }
    filteredResults.value = [];
    for (var member in filteredMembers) {
      filteredResults.add(Member.fromDocumentSnapshot(member));
    }
    resultsLoading.value = false;
    await AnalyticsEngine.logFilterTagsSearch(tags.toString());
    update();
  }

  switchAndOrFilter(List<String> selectedFilters) async {
    isAnd.value = !isAnd.value;
    await fetchFilteredMembers(selectedFilters);
  }

  List<String> getFilteredTagsFromCategory(category) {
    List<String> list = [];
    var catIndex = filteredTagsList.indexWhere((cat) => cat['key'] == category);
    List tagsList = filteredTagsList[catIndex]['tags_list'];
    for (var tag in tagsList) {
      list.add(tag);
    }
    if (category != 'forum') list.sort((a, b) => a.compareTo(b));
    return list;
  }

  Map<String, dynamic> newFreeTextTag(key) {
    return freeTextTagsList.firstWhere((element) => element['key'] == key);
  }

  bool checkIfNewMember(String joinDate) {
    if (joinDate=='') return false;
    DateTime today = DateTime.now();
    DateTime memberSince = DateTime(int.parse(joinDate));
    /// Calculate the total months for each date
    int totalMonths1 = today.year * 12 + today.month;
    int totalMonths2 = memberSince.year * 12 + memberSince.month;
    if ((totalMonths2 - totalMonths1).abs() < newMemberThreshold) {
      return true;
    } else {
      return false;
    }
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

  loadRandomResults(size) async {
    resultsLoading.value = true;
    List randomArr = [];
    final Random _random = Random();
    for (int i = 0; i < numberOfRandomMembers; i++) {
      int _randomNumber = _random.nextInt(size);
      randomArr.add(_randomNumber);
    }
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.get();
    List<QueryDocumentSnapshot> membersDocs = membersSnapshot.docs;
    filteredResults.value = [];
    /// add birthdays
    for (var member in membersDocs) {
      var memberData = member.data() as Map<String, dynamic>;
      if (memberData['birthdate']!=null) {
        if (checkIfTodayIsBirthday(memberData['birthdate']))
        filteredResults.add(Member.fromDocumentSnapshot(member));
      }
    }
    /// add random
    for (var index in randomArr) {
      if (filteredResults.indexWhere((element) => element.id==membersDocs[index])<0){
        filteredResults.add(Member.fromDocumentSnapshot(membersDocs[index]));
      }
    }
    resultsLoading.value = false;
  }

  loadTags() async {
    /// print('load tags');
    ///load free text tags
    CollectionReference freeTextTagsRef = db.collection('FreeTextTags');
    QuerySnapshot freeTextTagsSnapshot = await freeTextTagsRef.get();
    List<QueryDocumentSnapshot> freeTextTagsDocList = freeTextTagsSnapshot.docs;
    for (var tag in freeTextTagsDocList) {
      freeTextTagsList.add(tag.data() as Map<String, dynamic>);
    }

    ///load filtered tags
    CollectionReference filteredTagsRef = db.collection('FilterTags');
    QuerySnapshot filteredTagsSnapshot =
        await filteredTagsRef.orderBy('show_order').get();
    List<QueryDocumentSnapshot> filteredTagsQuery = filteredTagsSnapshot.docs;
    for (var tag in filteredTagsQuery) {
      filteredTagsList.add(tag.data() as Map<String, dynamic>);

      /// build residence list for use in dropdown in profile
      var tempTag = tag.data() as Map<String, dynamic>;
      if (tempTag['key'] == 'residence') {
        List list = tempTag['tags_list'];
        list.sort((a, b) => a.compareTo(b));
        residenceList = [];
        for (var element in list) {
          residenceList.add(element);
        }
      }

      /// build forum list for use in dropdown in profile
      if (tempTag['key'] == 'forum') {
        List list = tempTag['tags_list'];
        //list.sort((a, b) => a.compareTo(b));
        forumList = [];
        for (var element in list) {
          forumList.add(element);
        }
      }
    }

    /// App filter tags and free text
    final membersRef = db.collection("Members");
    final membersQuery = await membersRef.get();
    final membersSnapshot = membersQuery.docs;
    numberOfMembers = membersSnapshot.length;
    for (var member in membersSnapshot) {
      Map<String, dynamic>? data = member.data() as Map<String, dynamic>?;
      suggestionsList.add(ResultRecord(
          label: member['firstName'] + ' ' + member['lastName'],
          id: member.id));
      var bizName;
      if (data != null) {
        bizName = data.containsKey('current_business_name')
            ? data['current_business_name'] as String
            : null;
      }
      (bizName != null && bizName != '')
          ? suggestionsList.add(ResultRecord(label: bizName, id: member.id))
          : null;
      suggestionsList.sort((a, b) => a.label.compareTo(b.label));
    }
    //filtersLoading.value=false;
    update();
    /// print('tags loaded');
  }

  addNewResidence(String newResidence) async {
    CollectionReference filtersRef = db.collection('FilterTags');
    final filtersQuery =
        await filtersRef.where("key", isEqualTo: 'residence').get();
    var id = filtersQuery.docs.first.id;
    filtersRef.doc(id).update({
      "tags_list": FieldValue.arrayUnion([newResidence]),
    });
  }

  addNewForum(String newForum) async {
    CollectionReference filtersRef = db.collection('FilterTags');
    final filtersQuery =
        await filtersRef.where("key", isEqualTo: 'forum').get();
    var id = filtersQuery.docs.first.id;
    filtersRef.doc(id).update({
      "tags_list": FieldValue.arrayUnion([newForum]),
    });
  }

  addNewFreeTextField(Map<String,dynamic> freeTextData) async {
    CollectionReference freeTextTagsRef = db.collection('FreeTextTags');
    freeTextTagsRef.add(freeTextData);
  }

  /// GA events
  logUserLogsIn(String fullName) async {
    await AnalyticsEngine.userLogsIn('firebase_auth', fullName);
  }

  logUserOpensApp(String fullName) async {
    await AnalyticsEngine.logUserOpensApp(fullName);
  }

  logProfileView(String fullName) async {
    await AnalyticsEngine.logProfileView(fullName);
  }

  logProfileEdit(String fullName) async {
    await AnalyticsEngine.logProfileEdit(fullName);
  }


  @override
  onInit() async {
    super.onInit();
    /// print('init - main Controller...');
    mainLoading.value = true;

    /// loadTags() should be first, it also gets the number of members data
    updateSplashScreenText('Loading Filter Tags...');
    await getSettings();
    await loadTags();
    updateSplashScreenText('Loading Random Results...');
    await loadRandomResults(numberOfMembers);
    js.context.callMethod('hideSplashScreen');
    //await logUserLogsIn(user!.displayName??'NA');
    await logUserOpensApp(user!.displayName ?? 'NA');
    mainLoading.value = false;
    update();
    /// print('end - init main Controller');
  }
}

