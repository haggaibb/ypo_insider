import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'dart:async';
import 'models.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_storage/get_storage.dart';


class MembersController extends GetxController {
  var db = FirebaseFirestore.instance;
  RxBool loading = true.obs;
  RxBool loadingProfileImage = false.obs;
  RxList<Member> allMembers = RxList<Member>();
  int numberOfMembers =1;
  RxString currentUserUid = ''.obs;
  Rx<Member> currentMember = Member(forum: 'NA', id: 'NA', firstName: 'NAA', lastName: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', birthdate: Timestamp.now(), currentTitle: 'NA', currentBusinessName: 'NA', mobileCountryCode: 'NA',joinDate: 'NA').obs;
  Member noUser = Member(forum: 'NA', id: 'NA', firstName: 'NA', lastName: 'NA', residence: 'NA', mobile: 'NA', email: 'NA' , birthdate: Timestamp.now(), currentTitle: 'NA', currentBusinessName: 'NA', mobileCountryCode: 'NA',joinDate: 'NA');
  Rx<String> authErrMsg = ''.obs;
  /// storage for profile pics
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef ;
  //final box = GetStorage();
  /// settings
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final box = GetStorage();
  /// AUTH
  final user = FirebaseAuth.instance.currentUser;
  setCurrentUser(User? user) {
    if (user!=null) currentMember.value = getMemberByUid(user.uid);
    themeMode.value = currentMember.value.settings?['theme_mode']=='light'?ThemeMode.light:ThemeMode.dark;
  }
  refreshCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null) currentMember.value = getMemberByUid(user.uid);
  }
  validateMemberEmail(String email) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: email).get();
    return (memberSnapshot.docs.isNotEmpty);
  }
  onRegister(User user) async {
    print('Registration');
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
          'linkedin' : '',
          'instagram' : '',
          'facebook' : '',
          'onBoarding.registered' : true,
          'onBoarding.verified' : false,
          'onBoarding.boarded' : false,
          'filtered_tags' : [memberData['residence'],memberData['forum']],
          'free_text_tags' : [],
          'settings' : {'themeMode' : 'light'},
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
  onBoardingFinished(User user) async {
    print('finished onboarding');
    print('update full name to Auth User, this must be done as it acts as a flag for onboarding');
    setCurrentUser(user);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(currentMember.value.fullName());
    var memberId = currentMember.value.id;
    print(memberId);
    CollectionReference membersRef = db.collection('Members');
    //QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: currentMember.value.email).get();
    //var memberId = memberSnapshot.docs.first.id;
    await membersRef.doc(memberId).update(
        {
          'onBoarding.boarded' : true
        }
    );
  }
  // getMemberData(String? email) async {
  //   if (email==null) return noUser;
  //   CollectionReference membersRef = db.collection('Members');
  //   QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
  //   if (membersSnapshot.docs.isEmpty)
  //   {
  //     print('no member found for ${user?.email}');
  //     return noUser;
  //   }
  //   print('Got here');
  //   print(membersSnapshot.docs.first.data());
  //   return Member.DocumentSnapshot(membersSnapshot.docs.first);
  // }
  // getMemberInfo(String? email) async {
  //   if (email==null) return noUser;
  //   CollectionReference membersRef = db.collection('Members');
  //   QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
  //   if (membersSnapshot.docs.isEmpty)
  //   {
  //     print('no member found for ${user?.email}');
  //     return noUser;
  //   }
  //   print('Got here');
  //   print(membersSnapshot.docs.first.data());
  //   return Member.DocumentSnapshot(membersSnapshot.docs.first);
  // }
  getMemberById(String id) {
    if (id=='') return noUser;
    Member foundMember = allMembers.firstWhere((element) => element.id==id, orElse: () => noUser);
    if (foundMember.id!='NA')
    {
      print('no member found for ${user?.email}');
      return noUser;
    }
    return foundMember;
  }
  getMemberByUid(String uid) {
    if (uid=='') return noUser;
    Member foundMember = allMembers.firstWhere((element) => element.uid==uid, orElse: () => noUser);
    return foundMember;
  }
  // Future<Member> getMemberByIdd(String id) async {
  //   if (id=='') return noUser;
  //   CollectionReference membersRef = db.collection('Members');
  //   QuerySnapshot membersSnapshot = await membersRef.where('id', isEqualTo: id).get();
  //   if (membersSnapshot.docs.isEmpty)
  //   {
  //     print('no member found for ${user?.email}');
  //     return noUser;
  //   }
  //   return Member.DocumentSnapshot(membersSnapshot.docs.first);
  // }
  // Future<Member> getMemberByEMail(String email) async {
  //   if (email=='') return noUser;
  //   CollectionReference membersRef = db.collection('Members');
  //   QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
  //   if (membersSnapshot.docs.isEmpty)
  //   {
  //     print('no member found for ${user?.email}');
  //     return noUser;
  //   }
  //   return Member.DocumentSnapshot(membersSnapshot.docs.first);
  // }
  // Future<Member> loadMemberByUid(String uid) async {
  //   if (uid=='') return noUser;
  //   CollectionReference membersRef = db.collection('Members');
  //   QuerySnapshot membersSnapshot = await membersRef.where('uid', isEqualTo: uid).get();
  //   if (membersSnapshot.docs.isEmpty)
  //   {
  //     print('no member found for ${user?.email}');
  //     return noUser;
  //   }
  //   return Member.DocumentSnapshot(membersSnapshot.docs.first);
  // }
  logout() async {
    print('logout'); /// TODO does not work,
    await FirebaseAuth.instance.signOut();
    return;
    // Remove any route in the stack
    //Navigator.of(context).popUntil((route) => false);
    print('logged out');
    //Get.to(FrontGate());
    //Get.to(Email);
  }
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
  updateMemberInfo(Member member) async {
    CollectionReference membersRef = db.collection('Members');
    await membersRef.doc(member.id).update(member.toMap());
  }
  loadAllMembers() async {
    final membersRef = db.collection("Members");
    final membersQuery = await membersRef.get();
    final membersSnapshot = membersQuery.docs;
    for (var member in membersSnapshot) {
      allMembers.add(Member.DocumentSnapshot(member));
      Member memberObj = Member.DocumentSnapshot(member);
      /// TODO Move Logic to search controller
      //suggestionsList.add(ResultRecord(label: memberObj.fullName(), id: memberObj.id));
      // if (memberObj.currentBusinessName!='') suggestionsList.add(ResultRecord(label: memberObj.currentBusinessName, id: memberObj.id));
      // suggestionsList.sort((a, b) => a.label. compareTo(b.label));
    }
    numberOfMembers = membersSnapshot.length;
  }
  saveThemeMode(themeMode) {
    box.write('themeMode', themeMode);
    var id = currentMember.value.id;
    db.collection("Members").doc(id).update({
      'settings.theme_mode' : themeMode
    });
  }

  @override
  onInit() async {
    // //     /// for debugging
    // var membersSnapshot = await db.collection('Members').get();
    // for (var element in membersSnapshot.docs) {
    //   await db.collection('Members').doc(element.id).update({
    //     'uid' : '',
    //     // 'instagram' : '',
    //     //S3zQJjBzSyNAUXlFm1uh2rtEgwz1
    //     // 'facebook' : '',
    //     // 'free_text_tags': [],
    //   });
    // }
    // print('Done!!!!!!!!!!!');
    // return;
    await GetStorage.init();
    Get.changeTheme(box.read('themeMode')=='dark'?ThemeData.dark():ThemeData.light());
    super.onInit();
    print('init - Members Controller...');
    tempProfilePicRef =storageRef.child("");
    print('load members DB');
    await loadAllMembers();
    if (user!=null) setCurrentUser(user);
    print('finished loading members DB');
    loading.value = false;
    update();
    print('end - init Members Controller');
  }

}





