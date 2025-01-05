import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'package:get/get.dart';
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'ga.dart';
import 'utils.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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
  List<Member> allMembers = [];
  RxList<Member> filteredResults = RxList<Member>();
  RxBool resultsLoading = true.obs;
  RxBool mainLoading = false.obs;
  RxBool filtersLoading = false.obs;
  Rx<String> loadingStatus = 'Loading....'.obs;
  RxBool isAnd = true.obs;
  RxBool saving = false.obs;
  int numberOfMembers = 1;
  int numberOfRandomMembers =10;
  int newMemberThreshold = 12;
  late User? user;
  late String version;
  late ProfileScore profileScore;
  bool isIOS = true;
  int lastMember = -1; // Track the last document fetched
  DocumentSnapshot? lastDocument; // Track the last document fetched
  final int pageSize = 20; // Number of documents to fetch per page
  final ScrollController scrollController = ScrollController();
  final isLoadingMore = false.obs;
  ///
  Rx<Member> currentMember = Member(
      forum: 'NA',
      id: 'NA',
      firstName: 'NAA',
      lastName: 'NA',
      residence: 'NA',
      mobile: 'NA',
      email: 'NA',
      birthdate: Timestamp.now(),
      currentTitle: 'NA',
      currentBusinessName: 'NA',
      mobileCountryCode: 'NA',
      joinDate: 'NA').obs;
  List<String> admins = [];
  RxBool isAdmin = false.obs;
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  Member noUser = Member(
      forum: 'NA',
      id: 'NA',
      firstName: 'NA',
      lastName: 'NA',
      residence: 'NA',
      mobile: 'NA',
      email: 'NA',
      birthdate: Timestamp.now(),
      currentTitle: 'NA',
      currentBusinessName: 'NA',
      mobileCountryCode: 'NA',
      joinDate: 'NA');
  int maxSizeInMB = 3; // 3 MB limit
  int maxSizeInBytes = 3 * 1024 * 1024; // 3 MB limit


  ///
  Future<void> loadMoreResults() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;

    try {
      await loadRandomResults(20); // Load next batch of 20 results
    } finally {
      isLoadingMore.value = false;
    }
  }

// Attach listener to ScrollController
  void initScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent &&
          !resultsLoading.value &&
          !isLoadingMore.value && !tags.isNotEmpty) {
        loadMoreResults();
      }
    });
  }

  getSettings() async {
    final settingsRef = db.collection("Settings");
    final QuerySnapshot settingsQuery = await settingsRef.get();
    /// load Results Settings
    QueryDocumentSnapshot resultsSettingsSnapshot= settingsQuery.docs.firstWhere((element) => element.id == 'results_settings');
    var settingsData = resultsSettingsSnapshot.data() as Map<String, dynamic>;
    numberOfRandomMembers = settingsData['number_of_random_members'];
    newMemberThreshold  = settingsData['new_member_threshold_in_months'];
    /// load profile score data
    QueryDocumentSnapshot profileScoreSnapshot= settingsQuery.docs.firstWhere((element) => element.id == 'profile_score');
    if (profileScoreSnapshot.exists) {
      profileScore = ProfileScore.fromDocumentSnapshot(profileScoreSnapshot);
    }
    QueryDocumentSnapshot systemSnapshot = settingsQuery.docs.firstWhere((element) => element.id == 'system');
    final systemData = systemSnapshot.data() as Map<String, dynamic>;
    admins = systemData.containsKey('admins') ? List<String>.from(systemData["admins"]) : [];
    maxSizeInMB = systemData.containsKey('img_max_size') ? systemData["img_max_size"]:3;
    maxSizeInBytes = maxSizeInMB * 1024 * 1024;
  }

  loadAllMembers() async {
    final membersRef = db.collection("Members");
    final QuerySnapshot membersSnapshot = await membersRef.get();
    // Apply local filtering based on the 'filter_tags' field
    List<Member> loadedAllMembers = membersSnapshot.docs.map((doc) {
      var member = Member.fromDocumentSnapshot(doc);
      member.newMemberThresholdInMonths = newMemberThreshold;
      member.profileScore = profileScore;
      return member;
    }).toList();
    loadedAllMembers.sort((b, a) => a.getProfileScore().compareTo(b.getProfileScore()));
    int startIndex = loadedAllMembers.lastIndexWhere((element) => element.getProfileScore() > profileScore.topThreshold!);
    int endIndex = loadedAllMembers.indexWhere((element) => element.getProfileScore() < profileScore.bottomThreshold!);
    List<Member> birthdayProfiles = loadedAllMembers.sublist(0, startIndex + 1);
    List<Member> topProfiles = loadedAllMembers.sublist(startIndex + 1, endIndex);
    List<Member> remainingProfiles = loadedAllMembers.sublist(endIndex, loadedAllMembers.length);
    topProfiles.shuffle();
    allMembers =[];
    allMembers.addAll(birthdayProfiles + topProfiles + remainingProfiles);
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentMember.value = allMembers.firstWhere((element) => element.uid == user!.uid);
    } else {
      currentMember.value = noUser;
    }
    /// check if Admin
    bool res = ((admins.firstWhere(
              (element) => element == currentMember.value.id,
              orElse: () => '') !=
          ''));
    /// print('Member is $res for AdminUx');
    isAdmin.value = res;
    themeMode.value = currentMember.value.settings?['theme_mode'] == 'light'
          ? ThemeMode.light
          : ThemeMode.dark;

  }

  fetchFilteredMembers(List<String> selectedFilters) async {
    resultsLoading.value = true;
    if (selectedFilters.isEmpty) {
      filteredResults.value = [];
      resultsLoading.value = false;
      return;
    }
    // Apply local filtering based on 'filter_tags'
    List<Member> filteredMembers = allMembers.where((member) {
      List<String> memberFilterTags = [];
      try {
        // Assuming 'filter_tags' exists in the Member object
        if (member.filterTags != null) {
          memberFilterTags = List<String>.from(member.filterTags!);
        }
        // Add children tags for additional filtering
        memberFilterTags.addAll(member.getChildrenTags());
      } catch (e) {
        print("Member ${member.id} does not contain 'filter_tags': $e");
      }
      // Check if any of the selectedFilters match the member's tags
      return memberFilterTags.any((tag) => selectedFilters.contains(tag));
    }).toList();
    // Apply AND logic if isAnd.value is true
    if (isAnd.value) {
      filteredMembers = allMembers.where((member) {
        List<String> memberFilterTags = [];
        try {
          if (member.filterTags != null) {
            memberFilterTags = List<String>.from(member.filterTags!);
          }
          memberFilterTags.addAll(member.getChildrenTags());
        } catch (e) {
          print("Member ${member.id} does not contain 'filter_tags': $e");
        }
        // Check if all selectedFilters are in the member's tags
        return selectedFilters.every((tag) => memberFilterTags.contains(tag));
      }).toList();
    }
    // Update the filtered results
    filteredResults.value = filteredMembers;
    resultsLoading.value = false;

    // Log the filter tags search
    await AnalyticsEngine.logFilterTagsSearch(selectedFilters.toString());
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
      return false;
    }
  }

  Future<void> loadRandomResults(int size) async {
    filteredResults.addAll(allMembers.sublist(lastMember+1,lastMember+size));
    lastMember = lastMember+size;
    resultsLoading.value = false;
  }

  loadTags() async {
    filtersLoading.value = true;
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
    ///
    /// build lists for typehahead
    for (Member member in allMembers) {
      suggestionsList.add(ResultRecord(
          label: '${member.firstName} ${member.lastName}',
          id: member.id));
      suggestionsList.add(ResultRecord(label: member.currentBusinessName??'', id: member.id));
    }
    ///
    // final membersRef = db.collection("Members");
    // final membersQuery = await membersRef.get();
    // final membersSnapshot = membersQuery.docs;
    // for (var member in membersSnapshot) {
    //   Map<String, dynamic>? data = member.data() as Map<String, dynamic>?;
    //   suggestionsList.add(ResultRecord(
    //       label: member['firstName'] + ' ' + member['lastName'],
    //       id: member.id));
    //   var bizName;
    //   if (data != null) {
    //     bizName = data.containsKey('current_business_name')
    //         ? data['current_business_name'] as String
    //         : null;
    //   }
    //   (bizName != null && bizName != '')
    //       ? suggestionsList.add(ResultRecord(label: bizName, id: member.id))
    //       : null;
    //   suggestionsList.sort((a, b) => a.label.compareTo(b.label));
    // }
    filtersLoading.value=false;
    update();
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
    await freeTextTagsRef.doc(res.id).update({'templateId' : res.id});
  }

  updateFreeTextField(Map<String,dynamic> freeTextData) async {
    saving.value = true;
    CollectionReference freeTextTagsRef = db.collection('FreeTextTags');
    await freeTextTagsRef.doc(freeTextData['templateId']).update(freeTextData);
    saving.value = false;
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
        print("Error: $e");
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
      print("Error: $e");
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

  updateMaxFileSizePageSettings({maxFileSize}) async {
    saving.value = true;
    DocumentReference maxFileSizeSettingsRef = db.collection('Settings').doc('system');
    await maxFileSizeSettingsRef.update({
      'img_max_size' : int.parse(maxFileSize)
    });
    saving.value = false;
  }

  updateMemberWebDeviceInfo(String memberId) async {
    CollectionReference resultsSettingsRef = db.collection('MembersDeviceLogs');
    Map<String,dynamic> deviceInfo = await getWebDeviceInfo();
    await resultsSettingsRef.doc(memberId).set(deviceInfo);
    isIOS = await isDeviceIOS(deviceInfo['userAgent']);
  }

  getMemberById(String id) async {
    return allMembers.firstWhere((element) => element.id== id, orElse: () => noUser);
  }


  @override
  onInit() async {
    super.onInit();
    //print('init - main Controller...');
    loadingStatus.value = 'Loading Insider Home';
    mainLoading.value = true;
    js.context.callMethod('hideSplashScreen');
    version = await fetchVersionFromAssets();
    /// loadTags() should be first, it also gets the number of members data
    updateSplashScreenText('Loading Settings...');
    await getSettings();
    loadingStatus.value = 'Loading Registered Members...';
    await loadAllMembers();
    loadingStatus.value = 'Loading Tags';
    loadTags();
    updateSplashScreenText('Loading Random Results...');
    initScrollController();
    await loadRandomResults(pageSize);
    if (user!=null) await logUserOpensApp(user!.displayName ?? 'NA');
    if (user!=null) await updateMemberWebDeviceInfo(user!.displayName ?? 'NA');
    mainLoading.value = false;
    update();
    /// print('end - init main Controller');
  }
}

