import 'dart:io';

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
  RxList<Member> members = RxList<Member>();
  List<String> activeFilters = <String>[].obs;
  RxList<Member> filteredResults = RxList<Member>();
  RxBool loading = true.obs;
  RxBool resultsLoading = true.obs;
  RxBool loadingProfileImage = false.obs;
  RxString currentUserUid = ''.obs;
  Rx<Member> currentMember = Member(forum: 'NA', id: 'NA', firstName: 'NAA', lastName: 'NA', residence: 'NA', mobile: 'NA', email: 'NA', birthdate: Timestamp.now(), currentTitle: 'NA', currentBusinessName: 'NA', mobileCountryCode: 'NA',joinDate: 'NA').obs;
  Member noUser = Member(forum: 'NA', id: 'NA', firstName: 'NA', lastName: 'NA', residence: 'NA', mobile: 'NA', email: 'NA' , birthdate: Timestamp.now(), currentTitle: 'NA', currentBusinessName: 'NA', mobileCountryCode: 'NA',joinDate: 'NA');
  Rx<String> authErrMsg = ''.obs;
  List<Map> freeTextTagsList = [];
  List<Map> filteredTagsList = [];
  /// storage for profile pics
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef ;

  /// TODO for debuggin
  List<String> residenceList = ['Tel Aviv','Kiryat Ono','Ramot' 'Hashavim', 'Be\'er Sheva' ,'Ramat Gan', 'Savyon', 'Rishon LeTsiyon', 'Hod Hasharon'];



  /// AUTH
  final user = FirebaseAuth.instance.currentUser;
  setCurrentUser(User? user) async {
    if (user!=null) currentMember.value = await getMemberInfo(user.email);
  }
  validateMemberEmail(String email) async {
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot memberSnapshot = await membersRef.where('email', isEqualTo: email).get();
    return (memberSnapshot.docs.isNotEmpty);
  }
  onRegister(User user) async {
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
        'filtered_tags' : {},
        'free_text_tags' : {}
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
  getMemberInfo(String? email) async {
    if (email==null) return noUser;
    CollectionReference membersRef = db.collection('Members');
    QuerySnapshot membersSnapshot = await membersRef.where('email', isEqualTo: email).get();
    if (membersSnapshot.docs.isEmpty)
      {
        print('no member found for ${user?.email}');
        return controller.noUser;
      }
    return Member.DocumentSnapshot(membersSnapshot.docs.first);
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
  deleteTempProfilePic() async {
    await tempProfilePicRef.delete();
  }
  // saveProfileImage(String url, String memberId) async {
  //   CollectionReference membersRef = db.collection('Members');
  //   membersRef.doc(currentMember.value.id).update({'profileImage' : url});
  // }
  /// update member
  updateMemberInfo(Member member) async {
    CollectionReference membersRef = db.collection('Members');
    await membersRef.doc(member.id).update(member.toMap());
  }
  /// Tags
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
    print(user);
    currentMember.value = await getMemberInfo(user?.email);
    //appDocDir = await getApplicationDocumentsDirectory();
    //profilePicsRef = storageRef.child("profile_pics/");
    ///
    /// Load Tags and Filters
    await loadTags();
    await fetchFilteredMembers([]);
    loading.value = false;
    update();
    print('ctx done init.');
  }

}













/*

Herzliya
Binyamina
Jerusalem
Ben Shemen
Bat Hefer
Modi'in-Maccabim-Re'ut
Ramat Raziel
Haifa
Ganei Yehuda
Ra'anana
Rishpon
Even Yehuda
Petah Tikva
Yehud-Monosson
Ramat Hasharon
Kefar Sava
Mishmeret
USA
SOUTH AFRICA
Ness Ziona
Caesarea
Bnei Zion
Be'er Ya'akov
UK
Ganei Tikva
Kadima Zoran
Bnei Dror
Bnei Atarot
Kochav Yair
{
  "banner": false,
  "email": "haggaibb@gmail.com",
  "filtered_tags": {
    "industry": [
      "Hi Tech"
    ]
  },
  "firstName": "Haggai",
  "forum": 5,
  "free_text_tags": {
    "favorite_food": "Sushi",
    "favorite_pet": "Dog"
  },
  "lastName": "Barel",
  "member_since": 2009,
  "mobile": "972544510999",
  "onBoarding": {
    "boarded": false,
    "registered": true,
    "uid": "",
    "verified": true
  },
  "profileImage": "https://media.licdn.com/dms/image/C4D03AQFXuPK5twkpJA/profile-displayphoto-shrink_200_200/0/1604828273946?e=2147483647&v=beta&t=xzlsaXyeFnu3TZpFE-e1thz2F6vPKUCTCfOFjbK4U2s",
  "residence": "Herzliya",
  "tags": [
    "Hi Tech",
    "Herzliya"
  ],
  "title": "Chariman at  2Two",
  "uid": "bbcssvVuF0Pa99zizafm2Mb4eC93"
}
 */