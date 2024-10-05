import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'ga.dart';
import 'utils.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';


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
  Rx<String> loadingStatus = 'Loading....'.obs;
  RxBool isAnd = true.obs;
  RxBool saving = false.obs;
  int numberOfMembers = 1;
  int numberOfRandomMembers =10;
  int newMemberThreshold = 12;
  final user = FirebaseAuth.instance.currentUser;
  late String version;
  late ProfileScore profileScore;
  bool isIOS = true;

  getSettings() async {
    final settingsRef = db.collection("Settings").doc('results_settings');
    final DocumentSnapshot membersQuery = await settingsRef.get();
    var settingsData = membersQuery.data() as Map<String, dynamic>;
    numberOfRandomMembers = settingsData['number_of_random_members'];
    newMemberThreshold  = settingsData['new_member_threshold_in_months'];
    /// load profile score data
    final profileScoreRef = db.collection("Settings").doc('profile_score');
    final DocumentSnapshot profileScoreQuery = await profileScoreRef.get();
    if (profileScoreQuery.exists) {
      profileScore = ProfileScore.fromDocumentSnapshot(profileScoreQuery);
    }
  }

  fetchFilteredMembersOld(List<String> selectedFilters) async {
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

  fetchFilteredMembers(List<String> selectedFilters) async {
    resultsLoading.value = true;
    if (selectedFilters.isEmpty) {
      filteredResults.value = [];

      /// TODO add ref to def result list if we wish
      resultsLoading.value = false;
      return;
    }
    List<QueryDocumentSnapshot> filteredMembers=[];
    final membersRef = db.collection("Members");
    final QuerySnapshot membersQuery = await membersRef.get();
    // Apply local filtering based on the 'filter_tags' field
    print(selectedFilters);
    List<QueryDocumentSnapshot> allMembers = membersQuery.docs;
    filteredMembers = allMembers.where((doc) {
      List<dynamic> memberFilterTags=[];
      memberFilterTags = doc['filter_tags'];
      memberFilterTags.addAll(Member.fromDocumentSnapshot(doc).getChildrenTags());
      //print(memberFilterTags);
      // Check if any of the selectedFilters are in the document's filterTags
      return memberFilterTags.any((tag) => selectedFilters.contains(tag));
    }).toList();
    print(filteredMembers.length);
    if (isAnd.value) {
      filteredMembers = membersQuery.docs.where((doc) {
        List<dynamic> memberFilterTags=[];
        // Safely cast the 'filter_tags' array to List<String>
        memberFilterTags = List<String>.from(doc['filter_tags'] as List<dynamic>);
        memberFilterTags.addAll(Member.fromDocumentSnapshot(doc).getChildrenTags());
        // Check if all the selectedTags are in filterTags
        print(memberFilterTags);
        return selectedFilters.every((tag) => memberFilterTags.contains(tag));
      }).toList();
    } else {
      filteredMembers;
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

  Map<String, dynamic> getFreeTextTagTemplate(templateId) {
    return freeTextTagsList.firstWhere((element) => element['templateId'] == templateId);
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
    if (birthdayTimestamp==null) return false;
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
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.get();
    List<QueryDocumentSnapshot> membersDocs = membersSnapshot.docs;
    filteredResults.value = [];
    for (var member in membersDocs) {
      filteredResults.add(Member.fromDocumentSnapshot(member));
      filteredResults[filteredResults.length-1].newMemberThresholdInMonths = newMemberThreshold;
      filteredResults[filteredResults.length-1].profileScore = profileScore;
    }
    filteredResults.sort((b, a) => a.getProfileScore().compareTo(b.getProfileScore()));
    int startIndex = filteredResults.lastIndexWhere((element) => element.getProfileScore()>profileScore.topThreshold!);
    int endIndex = filteredResults.indexWhere((element) => element.getProfileScore()<profileScore.bottomThreshold!);
    List<Member> birthdayProfiles = filteredResults.sublist(0,startIndex+1);
    List<Member> topProfiles = filteredResults.sublist(startIndex+1,endIndex);
    List<Member> remainingProfiles = filteredResults.sublist(endIndex+1,filteredResults.length);
    topProfiles.shuffle();
    filteredResults.value = [];
    filteredResults.value = birthdayProfiles + topProfiles + remainingProfiles;
    /// add random
    // List randomArr = [];
    // final Random _random = Random();
    // for (int i = 0; i < numberOfRandomMembers; i++) {
    //   int _randomNumber = _random.nextInt(size);
    //   randomArr.add(_randomNumber);
    // };
    // for (var index in randomArr) {
    //   if (filteredResults.indexWhere((element) => element.id==membersDocs[index])<0){
    //     filteredResults.add(Member.fromDocumentSnapshot(membersDocs[index]));
    //   }
    // }
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
    var res = await freeTextTagsRef.add(freeTextData);
    print(res.id);
    await freeTextTagsRef.doc(res.id).update({'templateId' : res.id});
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

  Future<String> fetchVersionFromAssets() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('version.json');
      // Parse the JSON string
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return data['version'] ?? 'unknown';
    } catch (e) {
      // Return 'unknown' in case of error
      return 'unknown';
    }
  }

  addNewFilterTag(String category, String newTag) async {
    saving.value = true;
    CollectionReference filtersRef = db.collection('FilterTags');
    final filtersQuery =
    await filtersRef.where("label", isEqualTo: category).get();
    var id = filtersQuery.docs.first.id;
    filtersRef.doc(id).update({
      "tags_list": FieldValue.arrayUnion([newTag]),
    });
    //await loadTags();
    saving.value = false;
  }

  updateFilterTag(String category, String originalTag, String updatedTag) async {
    Future<void> searchAndReplaceFilterTagInAllMembers(String oldString, String newString) async {
      // Reference to the members collection in Firestore
      CollectionReference membersRef = FirebaseFirestore.instance.collection('Members');
      try {
        // Use `where` clause to fetch only the members whose array contains the oldString
        QuerySnapshot membersSnapshot = await membersRef
            .where('filter_tags', arrayContains: oldString)
            .get();
        // Loop through each member document that contains the oldString
        for (QueryDocumentSnapshot memberDoc in membersSnapshot.docs) {
          // Fetch the array field from the document and safely cast it to List<String>
          List<dynamic> memberArrayDynamic = memberDoc.get('filter_tags');
          List<String> memberArray = memberArrayDynamic.cast<String>();
          // Replace the old string with the new string
          List<String> modifiedArray = memberArray.map((item) {
            return item == oldString ? newString : item;
          }).toList();
          // Update the Firestore document with the modified array
          await membersRef.doc(memberDoc.id).update({
            'filter_tags': modifiedArray,
          });
        }
      } catch (e) {
        print("Error: $e");
      }
    }
    saving.value = true;
    await searchAndReplaceFilterTagInAllMembers(originalTag,updatedTag);
    CollectionReference filtersRef = db.collection('FilterTags');
    final filtersQuery =
    await filtersRef.where("label", isEqualTo: category).get();
    var id = filtersQuery.docs.first.id;
    await filtersRef.doc(id).update({
      "tags_list": FieldValue.arrayRemove([originalTag]),
    });
    await filtersRef.doc(id).update({
      "tags_list": FieldValue.arrayUnion([updatedTag]),
    });
    //await loadTags();
    saving.value = false;
  }

  removeFilterTag(String category, String delTag) async {
    Future<void> removeFilterTagInAllMembers(String delTag) async {
      // Reference to the members collection in Firestore
      CollectionReference membersRef = FirebaseFirestore.instance.collection('Members');
      try {
        // Use `where` clause to fetch only the members whose array contains the stringToRemove
        QuerySnapshot membersSnapshot = await membersRef
            .where('filter_tags', arrayContains: delTag)
            .get();

        // Loop through each member document that contains the stringToRemove
        for (QueryDocumentSnapshot memberDoc in membersSnapshot.docs) {
          // Use FieldValue.arrayRemove to remove the string directly
          await membersRef.doc(memberDoc.id).update({
            'filter_tags': FieldValue.arrayRemove([delTag]),
          });
        }
      } catch (e) {
        //print("Error: $e");
      }
    }
    saving.value = true;
    await removeFilterTagInAllMembers(delTag);
    CollectionReference filtersRef = db.collection('FilterTags');
    final filtersQuery =
    await filtersRef.where("label", isEqualTo: category).get();
    var id = filtersQuery.docs.first.id;
    await filtersRef.doc(id).update({
      "tags_list": FieldValue.arrayRemove([delTag]),
    });
    saving.value = false;
  }

  addNewFilterTagCategory(String category, String? hint) async {
    saving.value = true;
    CollectionReference filtersRef = db.collection('FilterTags');
    var newTagData = {
      'label' : category,
      'key' : labelToKey(category),
      'hint' : hint??'',
      'show_order' : '6',
      'tags_list' : []
    };
    await filtersRef.add(newTagData);
    filteredTagsList.add(newTagData);
    saving.value = false;
  }

  removeFilterTagCategory(String category) async {
    saving.value = true;
    CollectionReference filtersRef = db.collection('FilterTags');
    final filtersQuery = await filtersRef.where("label", isEqualTo: category).get();
    var id = filtersQuery.docs.first.id;
    await filtersRef.doc(id).delete();
    saving.value = false;
  }

  removeFreeTextTag(String label, String templateId) async {
    saving.value = true;
    CollectionReference freeTextTagsRef = db.collection('FreeTextTags');
    await freeTextTagsRef.doc(templateId).delete();
    CollectionReference membersRef = db.collection('Members');
    try {
      // Get all member documents
      QuerySnapshot membersSnapshot = await membersRef.get();
      // Loop through each member document
      for (QueryDocumentSnapshot memberDoc in membersSnapshot.docs) {
        // Fetch the array of maps from the document and safely cast it to List<Map<String, dynamic>>
        List<dynamic> mapsArrayDynamic = memberDoc.get('free_text_tags');
        List<Map<String, dynamic>> mapsArray = mapsArrayDynamic.cast<Map<String, dynamic>>();

        // Remove the map where the 'templateId' key matches the labelToMatch
        mapsArray.removeWhere((map) => map['templateId'] == templateId);

        // Update the document with the modified arrayOfMaps
        await membersRef.doc(memberDoc.id).update({
          'free_text_tags': mapsArray,
        });
        //print("Updated member: ${memberDoc.id}");
      }
      //print("All relevant members have been processed.");
    } catch (e) {
      //print("Error: $e");
    }
    saving.value = false;
  }

  updateProfileScoreSettings({birthdayScore,profileImageScore,newMemberScore,socialScore,topThreshold,bottomThreshold}) async {
    saving.value = true;
    DocumentReference profileScoreRef = db.collection('Settings').doc('profile_score');
    await profileScoreRef.update({
      'birthday_score' : birthdayScore,
      'profile_image_score' : profileImageScore,
      'new_member_score' : newMemberScore,
      'social_score' : socialScore,
      'top_threshold' : topThreshold,
      'bottom_threshold' :bottomThreshold
    });
    saving.value = false;
  }

  updateResultsPageSettings({newMemberThresholdInMonths,numberOfRandomMembers}) async {
    saving.value = true;
    DocumentReference resultsSettingsRef = db.collection('Settings').doc('results_settings');
    await resultsSettingsRef.update({
      'new_member_threshold_in_months' : int.parse(newMemberThresholdInMonths),
      'number_of_random_members' : int.parse(numberOfRandomMembers)
    });
    saving.value = false;
  }

  updateMemberWebDeviceInfo(String memberId) async {
    await getWebDeviceInfo();
    DocumentReference resultsSettingsRef = db.collection('MembersDeviceLogs').doc(memberId);
    Map<String,dynamic> deviceInfo = await getWebDeviceInfo();
    await resultsSettingsRef.set(deviceInfo);
    print(deviceInfo);
    isIOS = await isDeviceIOS(deviceInfo['userAgent']);
  }

  @override
  onInit() async {
    super.onInit();
    /// print('init - main Controller...');
    loadingStatus.value = 'Loading Insider Home';
    mainLoading.value = true;
    js.context.callMethod('hideSplashScreen');
    version = await fetchVersionFromAssets();
    /// loadTags() should be first, it also gets the number of members data
    updateSplashScreenText('Loading Filter Tags...');
    await getSettings();
    loadingStatus.value = 'Loading Tags';
    await loadTags();
    updateSplashScreenText('Loading Random Results...');
    loadingStatus.value = 'Loading Registered Members...';
    await loadRandomResults(numberOfMembers);
    //js.context.callMethod('hideSplashScreen');
    //await logUserLogsIn(user!.displayName??'NA');
    if (user!=null) await logUserOpensApp(user!.displayName ?? 'NA');
    await updateMemberWebDeviceInfo(user!.displayName ?? 'NA');
    mainLoading.value = false;
    update();
    /// print('end - init main Controller');
  }
}

