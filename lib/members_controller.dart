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
  RxBool loading = true.obs;
  RxBool saving = false.obs;
  RxBool loadingProfileImage = false.obs;
  Rx<String> authErrMsg = ''.obs;
  Rx<String> loadingStatus = 'Loading....'.obs;
  /// storage for profile pics
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef;
  /// AUTH
  final user = FirebaseAuth.instance.currentUser;

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
    // DocumentSnapshot refreshedMember = await membersRef.doc(memberId).get();
    // currentMember.value = Member.fromDocumentSnapshot(refreshedMember);
    await AnalyticsEngine.logMemberRegistered(user.uid);
    print('Registration done - member is ${user.uid}');
    return (memberSnapshot.docs.isNotEmpty);
  }
  onVerify(User user) async {
    /// print('user has just verified his email');
    /// print('update his profile');
    CollectionReference membersRef = db.collection('Members');
    //var memberId = currentMember.value.id;
    //await membersRef.doc(memberId).update({'onBoarding.verified': true});
  }
  onBoardingFinished(User user) async {
    //loadingStatus.value = 'Finished onBoarding.';
    //loading.value = true;
    print('finished onboarding');

    /// print(
    ///   'update full name to Auth User, this must be done as it acts as a flag for onboarding');
    //loadingStatus.value = 'Updating authentication profile...';
    //print(currentMember.value.fullName());
    // await FirebaseAuth.instance.currentUser!.updateDisplayName(currentMember.value.fullName());
    // var memberId = currentMember.value.id;
    // CollectionReference membersRef = db.collection('Members');
    // await membersRef.doc(memberId).update({'onBoarding.boarded': true});
    // currentMember.value.onBoarding!['boarded'] = true;
    // await AnalyticsEngine.logOnBoarding(
    //     currentMember.value.fullName(), 'finished');
    // //loading.value = false;
  }
  addNewMember(
      String firstName,
      String lastName,
      currentBusinessName,
      currentTitle,
      String mobileCountryCode,
      String mobile,
      String email,
      String forum,
      String residence,
      DateTime birthday,
      String memberSince) async {
    CollectionReference membersRef = db.collection('Members');
    DocumentReference newMemberRef = await membersRef.add({
      'firstName': firstName,
      'lastName': lastName,
      'current_business_name': currentBusinessName,
      'current_title': currentTitle,
      'mobile_country_code': mobileCountryCode,
      'mobile': mobile,
      'email': email,
      'forum': forum,
      'residence' : residence,
      'birthdate': birthday,
      'join_date': memberSince,
      'profileImage':
          'https://firebasestorage.googleapis.com/v0/b/ypodex.appspot.com/o/profile_images%2Fprofile0.jpg?alt=media',
      'filter_tags': [residence,forum],
       'onBoarding' : {
         "boarded": false,
         "registered": false,
         "verified": false
       }
    });
    await membersRef.doc(newMemberRef.id).update({'id' : newMemberRef.id});
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
        'profile_images/pp$id-${img.name}');
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
  saveThemeMode(themeMode) {
    //box.write('themeMode', themeMode);
    //var id = currentMember.value.id;
    //db.collection("Members").doc(id).update({'settings.theme_mode': themeMode});
  }


  @override
  onInit() async {
    await GetStorage.init();
    tempProfilePicRef = storageRef.child("");
    loading.value = false;
    super.onInit();
    /// print('end - init Members Controller');
  }
}

