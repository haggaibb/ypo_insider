import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ypo_connect/main.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'dart:async';
import 'dart:math';
import 'models.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';



class Controller extends GetxController {
  var db = FirebaseFirestore.instance;
  RxBool loading = true.obs;
  RxBool resultsLoading = true.obs;
  RxBool loadingProfileImage = false.obs;

  RxList<Member> members = RxList<Member>();
  List<String> activeFilters = <String>[].obs;
  RxList<Member> filteredResults = RxList<Member>();
  late int numberOfMembers;

  RxString currentUserUid = ''.obs;
  Rx<Member> currentMember = Member(forum: 'NA', id: 'NA', firstName: 'NAA', lastName: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', birthdate: Timestamp.now(), currentTitle: 'NA', currentBusinessName: 'NA', mobileCountryCode: 'NA',joinDate: 'NA').obs;
  Member noUser = Member(forum: 'NA', id: 'NA', firstName: 'NA', lastName: 'NA', residence: 'NA', mobile: 'NA', email: 'NA' , birthdate: Timestamp.now(), currentTitle: 'NA', currentBusinessName: 'NA', mobileCountryCode: 'NA',joinDate: 'NA');
  Rx<String> authErrMsg = ''.obs;
  List<Map> freeTextTagsList = [];
  List<Map> filteredTagsList = [];
  RxList<String> tags = <String>[].obs;
  /// storage for profile pics
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef ;
  /// profile date for dropdowns
  List<String> residenceList=[];
  List<String> forumList=[];
  List<QueryDocumentSnapshot> allMembers = [];
  List<ResultRecord> allMembersFullName = [];
  List<ResultRecord> allCompanies =[];
  List<ResultRecord> suggestionsList =[];
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// AUTH
  final user = FirebaseAuth.instance.currentUser;
  setCurrentUser(User? user) async {
    if (user!=null) currentMember.value = await loadMemberByUid(user.uid);
  }
  validateMemberEmail(String email) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: email).get();
    return (memberSnapshot.docs.isNotEmpty);
  }
  onRegister(User user) async {
    print('Start Registration');
    print('for User ${user.email} uid is ${user.uid}');
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: user.email).get();
    var memberId = memberSnapshot.docs.first.id;
    var memberData = memberSnapshot.docs.first.data() as Map<String, dynamic>;
    var displayName = memberData['firstName']+" "+memberData['lastName'];
    await FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
    membersRef.doc(memberId).update(
      {
        'id' : memberId,
        'uid' : user.uid,
        'profileImage' : '',
        'banner' : false,
        'onBoarding.registered' : true,
        'onBoarding.verified' : false,
        'onBoarding.boarded' : false,
        'filtered_tags' : [memberData['residence'],memberData['forum']],
        'free_text_tags' : []
      }
    );
    return (memberSnapshot.docs.isNotEmpty);
  }
  onVerify(User user) async {
    print('user has just verified his email');
    print('update his profile');
    CollectionReference membersRef = db.collection('Members');
    var memberId = currentMember.value.id;
    // QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: user.email).get();
    // var memberId = memberSnapshot.docs.first.id;
    await membersRef.doc(memberId).update(
        {
          'onBoarding.verified' : true
        }
    );
  }
  onBoardingFinished() async {
    print('finished onboarding');
    print('update full name to Auth User, this must be done as it acts as a flag for onboarding');
    await FirebaseAuth.instance.currentUser!.updateDisplayName(currentMember.value.fullName());
    var memberId = currentMember.value.id;
    CollectionReference membersRef = db.collection('Members');
    //QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: currentMember.value.email).get();
    //var memberId = memberSnapshot.docs.first.id;
    await membersRef.doc(memberId).update(
        {
          'onBoarding.boarded' : true
        }
    );
  }
  getMemberData(String? email) async {
    if (email==null) return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
    if (membersSnapshot.docs.isEmpty)
    {
      print('no member found for ${user?.email}');
      return controller.noUser;
    }
    print('Got here');
    print(membersSnapshot.docs.first.data());
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
  }
  getMemberInfo(String? email) async {
    if (email==null) return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
    if (membersSnapshot.docs.isEmpty)
      {
        print('no member found for ${user?.email}');
        return controller.noUser;
      }
    print('Got here');
    print(membersSnapshot.docs.first.data());
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
  }
  Future<Member> getMemberById(String id) async {

    if (id=='') return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('id', isEqualTo: id).get();
    if (membersSnapshot.docs.isEmpty)
    {
      print('no member found for ${user?.email}');
      return controller.noUser;
    }
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
  }
  Future<Member> getMemberByEMail(String email) async {
    if (email=='') return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
    if (membersSnapshot.docs.isEmpty)
    {
      print('no member found for ${user?.email}');
      return controller.noUser;
    }
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
  }
  /// TODO do this diff, Class of Members., clean get members
  Future<Member> loadMemberByUid(String uid) async {
    if (uid=='') return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('uid', isEqualTo: uid).get();
    if (membersSnapshot.docs.isEmpty)
    {
      print('no member found for ${user?.email}');
      return controller.noUser;
    }
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
  }
  logout() async {
    print('logout'); /// TODO does not work, still see home
    await FirebaseAuth.instance.signOut();
  }
  /// profile image
  Future<String> uploadProfileImage(XFile img, String id) async {
    loadingProfileImage.value = true;
    final fileBytes = await img.readAsBytes();
    final reference = FirebaseStorage.instance.ref();
    final now = DateTime.now();
    final imageRef = reference.child('profile_images/${img.name+now.millisecondsSinceEpoch.toString()}');
    final metadata = SettableMetadata(contentType: img.mimeType);
    final uploadTask = await imageRef.putData(fileBytes,metadata);
    String url = await uploadTask.ref.getDownloadURL();
    tempProfilePicRef  = imageRef;
    /// TODO move to save  //await saveProfileImage(url, id);
    update();
    loadingProfileImage.value = false;
    return url;
  }
  deleteTempProfilePic(Reference ref) async {
    await ref.delete();
  }
  /// update member
  updateMemberInfo(Member member) async {
    CollectionReference membersRef = db.collection('Members');
    await membersRef.doc(member.id).update(member.toMap());
  }
  /// Tags
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
    QuerySnapshot filteredTagsSnapshot = await filteredTagsRef.orderBy('show_order').get();
    List<QueryDocumentSnapshot>  filteredTagsQuery =  filteredTagsSnapshot.docs;
    for (var tag in filteredTagsQuery) {
      filteredTagsList.add(tag.data() as Map<String, dynamic>);
      var tempTag = tag.data() as Map<String, dynamic>;
      /// build residence list for use in dropdown in profile
      if (tempTag['key']=='residence') {
        List list = tempTag['tags_list'];
        list.sort((a, b) => a.compareTo(b));
        residenceList = [];
        for (var element in list) {
          residenceList.add(element);
        }
      }
      /// build forum list for use in dropdown in profile
      if (tempTag['key']=='forum') {
        List list = tempTag['tags_list'];
        //list.sort((a, b) => a.compareTo(b));
        forumList = [];
        for (var element in list) {
          forumList.add(element);
        }
      }
    }
  }
  List<String> getFilteredTagsFromCategory(category) {
    List<String> list = [];
    var catIndex = filteredTagsList.indexWhere((cat) => cat['key']==category);
    List tagsList = filteredTagsList[catIndex]['tags_list'];
    for (var tag in tagsList) {
      list.add(tag);
    }
    if (category!='forum') list.sort((a, b) => a.compareTo(b));

    return list;
  }
  fetchFilteredMembers(List<String> selectedFilters) async {
    if (selectedFilters.isEmpty) {
      //print('no selected tags');
      filteredResults.value = []; /// TODO add ref to def res
      resultsLoading.value = false;
      return;
    }
    resultsLoading.value = true;
    final membersRef = db.collection("Members");
    final membersQuery = await membersRef.where("filter_tags", arrayContainsAny: selectedFilters).get();
    final membersDocs = membersQuery.docs;
    filteredResults.value =[];
    for (var member in membersDocs) {
      filteredResults.add(Member.DocumentSnapshot(member));
    }
    resultsLoading.value = false;
    update();
  }
  String getFreeTextTagLabel(key) {
    String value ='';
    for (var element in freeTextTagsList) {
      var foundKey = element['key']==key;
      if (foundKey) value = element['label'];
    }
    return value;
  }
  /// results and search
  loadRandomResults(size) async {
    resultsLoading.value = true;
    List randomArr =[];
    final Random _random = Random();
    for (int i=0; i<15;i++) {
      int _randomNumber = _random.nextInt(size);
      randomArr.add(_randomNumber);
    }
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.get();
    List<QueryDocumentSnapshot> membersDocs = membersSnapshot.docs;
    filteredResults.value =[];
    for (var index in randomArr) {
      if (membersDocs[index].id != currentMember.value.id) {
        filteredResults.add(Member.DocumentSnapshot(membersDocs[index]));
      }
    }
    resultsLoading.value = false;
  }
  loadAllMembers() async {
    final membersRef = db.collection("Members");
    final membersQuery = await membersRef.get();
    allMembers = membersQuery.docs;
    for (var member in allMembers) {
      Member memberObj = Member.DocumentSnapshot(member);
      suggestionsList.add(ResultRecord(label: memberObj.fullName(), id: memberObj.id));
      if (memberObj.currentBusinessName!='') suggestionsList.add(ResultRecord(label: memberObj.currentBusinessName, id: memberObj.id));
      suggestionsList.sort((a, b) => a.label. compareTo(b.label));
    }

  }

  @override
  onInit() async {
    super.onInit();
    print('start init ctx');
    //print(user);
    /// for debugging
    // for (var element in membersSnapshot.docs) {
    //   var data = element.data() as Map<String, dynamic>;
    //   await db.collection('Members').doc(element.id).update({
    //     //'filter_tags' : [data['residence'],data['forum']],
    //     //'free_text_tags': FieldValue.delete()
    //     'free_text_tags': []
    //   });
    // }
    // print('Done!!!!!!!!!!!');
    // return;
    ///
    tempProfilePicRef =storageRef.child("");
    /// Load Tags and Filters
    await loadTags();
    AggregateQuerySnapshot query = await db.collection('Members').count().get();
    numberOfMembers = query.count??0;
    await loadRandomResults(numberOfMembers);
    await loadAllMembers();
    loading.value = false;
    update();
    print('ctx done init.');
  }

}





