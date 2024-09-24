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
import './ga.dart';

class MembersController extends GetxController {
  var db = FirebaseFirestore.instance;
  List<String> admins = [];
  RxBool loading = true.obs;
  RxBool saving = false.obs;
  RxBool isAdmin = false.obs;
  RxBool loadingProfileImage = false.obs;
  RxList<Member> allMembers = RxList<Member>();
  RxString currentUserUid = ''.obs;
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
  Rx<String> authErrMsg = ''.obs;
  Rx<String> loadingStatus = 'Loading....'.obs;
  /// storage for profile pics
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef;
  //final box = GetStorage();
  /// settings
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final box = GetStorage();
  /// AUTH
  final user = FirebaseAuth.instance.currentUser;
  ///
  setCurrentByUid(User? user) async {
    if (user != null) currentMember.value = await getMemberByUid(user.uid);
    bool res = ((admins.firstWhere((element) => element==currentMember.value.id, orElse: () =>'') !=''));
    /// print('Member is $res for AdminUx');
    isAdmin.value=res;
    themeMode.value = currentMember.value.settings?['theme_mode'] == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  validateMemberEmail(String email) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot =
        await membersRef.where('email', isEqualTo: email).get();
    return (memberSnapshot.docs.isNotEmpty);
  }

  onRegister(User user) async {
    /// print('Registration');
    /// print('for User ${user.email} uid is ${user.uid}');
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot =
        await membersRef.where('email', isEqualTo: user.email).get();
    var memberId = memberSnapshot.docs.first.id;
    await membersRef.doc(memberId).update({
      'id': memberId,
      'uid': user.uid,
      'onBoarding.registered': true,
      'onBoarding.verified': false,
      'onBoarding.boarded': false,
    });
    DocumentSnapshot refreshedMember = await membersRef.doc(memberId).get();
    setCurrentByMember(Member.fromDocumentSnapshot(refreshedMember));
    /// print('Registration done - member is ${currentMember.value.fullName()}');
    await AnalyticsEngine.logMemberRegistered(currentMember.value.fullName());
    return (memberSnapshot.docs.isNotEmpty);
  }

  onVerify(User user) async {
    /// print('user has just verified his email');
    /// print('update his profile');
    CollectionReference membersRef = db.collection('Members');
    var memberId = currentMember.value.id;
    await membersRef.doc(memberId).update({'onBoarding.verified': true});
  }

  onBoardingFinished(User user) async {
    loadingStatus.value = 'Finished onBoarding.';
    loading.value = true;
    /// print('finished onboarding');
    /// print(
     ///   'update full name to Auth User, this must be done as it acts as a flag for onboarding');
    loadingStatus.value = 'Updating authentication profile...';
    /// print(currentMember.value.fullName());
    await FirebaseAuth.instance.currentUser!.updateDisplayName(currentMember.value.fullName());
    var memberId = currentMember.value.id;
    CollectionReference membersRef = db.collection('Members');
    membersRef.doc(memberId).update({'onBoarding.boarded': true});
    currentMember.value.onBoarding!['boarded']=true;
    await AnalyticsEngine.logOnBoarding(user.email!,'finish');
    loading.value = false;
  }

  addNewMember(String firstName,String lastName,String email) async {
    CollectionReference membersRef = db.collection('Members');
    await membersRef.add({
      'firstName' : firstName,
      'lastName' : lastName,
      'email' : email
    });
  }

  getMemberById(String id) async {
    CollectionReference membersRef = db.collection('Members');
    DocumentSnapshot res = await membersRef.doc(id).get();
    if (res.exists) {
      return Member.fromDocumentSnapshot(res);
    } else {
      /// print('get by id - no user found');
      noUser;
    }
    // Member foundMember = allMembers.firstWhere((element) => element.id == id,
    //     orElse: () => noUser);
    // return foundMember;
  }

  getMemberByUid(String uid) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot res = await membersRef.where("uid" , isEqualTo: uid).get();
    if (res.docs.isNotEmpty) {
      Member member = Member.fromJson(res.docs.first.data() as Map<String,dynamic>);
      return member;
    } else {
      return noUser;
    }
  }

  setCurrentByMember(Member member) async {
    currentMember.value = member;
    var memberId = currentMember.value.id;
    /// check for mail verification
    /// print('verification check');
    if (user!.emailVerified) {
      await db.collection('Members').doc(memberId).update({'onBoarding.verified': true});
      /// print('update email verification for user ${member.fullName()} to ${user?.emailVerified}');
    }
    themeMode.value = currentMember.value.settings?['theme_mode'] == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  logout() async {
    /// print('logout');
    await FirebaseAuth.instance.signOut();
    return;
  }

  Future<String> uploadProfileImage(XFile img, String id) async {
    loadingProfileImage.value = true;
    final fileBytes = await img.readAsBytes();
    final reference = FirebaseStorage.instance.ref();
    final now = DateTime.now();
    final imageRef = reference.child(
        'profile_images/${img.name + now.millisecondsSinceEpoch.toString()}');
    final metadata = SettableMetadata(contentType: img.mimeType);
    final uploadTask = await imageRef.putData(fileBytes, metadata);
    String url = await uploadTask.ref.getDownloadURL();
    tempProfilePicRef = imageRef;

    /// TODO move to save  //await saveProfileImage(url, id);
    update();
    loadingProfileImage.value = false;
    return url;
  }

  deleteTempProfilePic(Reference ref) async {
    await ref.delete();
  }

  updateMemberInfo(Member member) async {
    saving.value = true;
    CollectionReference membersRef = db.collection('Members');
    await membersRef.doc(member.id).update(member.toMap());
    await AnalyticsEngine.logProfileEdit(member.fullName());
    saving.value = false;
  }

  loadAdmins() async {
    DocumentReference settingsRef = db.collection('Settings').doc('Admins');
    settingsRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        admins = data.containsKey('admins')
            ? List<String>.from(data["admins"])
            : [];
        bool res = ((admins.firstWhere((element) => element==currentMember.value.id, orElse: () =>'') !=''));
        /// print('Member is $res for AdminUx');
        isAdmin.value=res;
      },
      onError: (e) =>  print("Error getting document: $e"),
    );
  }

  saveThemeMode(themeMode) {
    box.write('themeMode', themeMode);
    var id = currentMember.value.id;
    db.collection("Members").doc(id).update({'settings.theme_mode': themeMode});
  }

  @override
  onInit() async {
    // //     /// for debugging
    /// Warning!!! use with caution!!!
    // await  db.collection('Members').doc('dHH4COYXO0GGubvPIVua').set(
    //     {
    //       'id' : 'dHH4COYXO0GGubvPIVua',
    //       'uid' : '',
    //       'firstName' : 'Haggai',
    //       'lastName' : 'Barel',
    //       'email' : 'haggaibb@gmail.com',
    //       'birthdate' : Timestamp.now(),
    //       'current_business_name' : 'DEEP IT',
    //       'current_title' : 'Founder & CEO',
    //       'filter_tags' : ['Herzliya','5'],
    //       'forum' : '5',
    //       'join_date' : '2009',
    //       'mobile_country_code' : '972',
    //       'mobile' : '544510999',
    //       'residence' : 'Herzliya',
    //       'profileImage' : '',
    //       'banner' : false,
    //       'linkedin' : '',
    //       'instagram' : '',
    //       'facebook' : '',
    //       'onBoarding' : {
    //         'registered': false,
    //         'verified': false,
    //         'boarded': false,
    //       },
    //       'free_text_tags' : [],
    //       'settings' : {'theme_mode' : 'light'},
    //     }
    // );
    // print('Done!!!!!!!!!!!');
    // return;
    // var membersSnapshot = await db.collection('Members').get();
    // for (var element in membersSnapshot.docs) {
    //   //var data = element.data();
    //     await db.collection('Members').doc(element.id).update({
    //       'children': []
    //       //'profileImage' : 'https://firebasestorage.googleapis.com/v0/b/ypodex.appspot.com/o/profile_images%2Fprofile0.jpg?alt=media'
    //       //'residence' : clean,
    //       // 'instagram' : '',
    //       //S3zQJjBzSyNAUXlFm1uh2rtEgwz1
    //       // 'facebook' : '',
    //       // 'free_text_tags': [],
    //     });
    // }
    // print('Done!!!!!!!!!!!');
    // return;
    await GetStorage.init();
    Get.changeTheme(
        box.read('themeMode') == 'dark' ? ThemeData.dark() : ThemeData.light());
    super.onInit();
    /// print('init - Members Controller...');
    tempProfilePicRef = storageRef.child("");
    await loadAdmins();
    loading.value = false;
    update();
    /// print('end - init Members Controller');
  }
}
