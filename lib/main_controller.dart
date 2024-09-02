import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'package:get/get.dart';
import 'dart:math';



class MainController extends GetxController {
  var db = FirebaseFirestore.instance;
  List<ResultRecord> allMembersFullName = [];
  List<ResultRecord> allCompanies =[];
  List<ResultRecord> suggestionsList =[];
  List<String> residenceList=[];
  List<String> forumList=[];
  List< Map<String, dynamic>> freeTextTagsList = [];
  List<Map> filteredTagsList = [];
  RxList<String> tags = <String>[].obs;
  List<String> activeFilters = <String>[].obs;
  RxList<Member> filteredResults = RxList<Member>();
  RxBool resultsLoading = false.obs;

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
  Map<String, dynamic> newFreeTextTag(key){
    return freeTextTagsList.firstWhere((element) => element['key']==key);
  }
  loadRandomResults(size) async {
    //resultsLoading.value = true;
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
      filteredResults.add(Member.DocumentSnapshot(membersDocs[index]));
    }
    //resultsLoading.value = false;
  }
  loadTags(List<Member> members) async {
    resultsLoading.value = true;
    print('load tags');
    ///load free text tags
    //resultsLoading.value = true;
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
      /// build residence list for use in dropdown in profile
      var tempTag = tag.data() as Map<String, dynamic>;
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
    /// App filter tags and free text
    for (var member in members) {
      suggestionsList.add(ResultRecord(label: member.fullName(), id: member.id));
      if (member.currentBusinessName!='') suggestionsList.add(ResultRecord(label: member.currentBusinessName, id: member.id));
      suggestionsList.sort((a, b) => a.label. compareTo(b.label));
    }
    resultsLoading.value = false;
    update();
    print('tags loaded');
  }

  @override
  onInit() async {
    super.onInit();
    print('init - main Controller...');
    update();
    print('end - init main Controller');
  }

}



