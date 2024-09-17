import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:ypo_connect/RayBarFields.dart';
import 'package:ypo_connect/members_controller.dart';
import 'package:ypo_connect/models.dart';
import 'main_controller.dart';
import 'widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final Member member;
  const ProfilePage(this.member, {super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final memberController = Get.put(MembersController());
  final mainController = Get.put(MainController());
  bool editModeOn = false;
  TextEditingController currentTitleCtrl = TextEditingController();
  TextEditingController currentBusinessCtrl = TextEditingController();
  TextEditingController residenceCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();
  TextEditingController mobileCountryCodeCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController memberSinceCtrl = TextEditingController();
  TextEditingController forumCtrl = TextEditingController();
  List<Map<String, dynamic>> childrenCtrl = [];
  TextEditingController linkedInCtrl = TextEditingController();
  TextEditingController instagramCtrl = TextEditingController();
  TextEditingController facebookCtrl = TextEditingController();

  /// Filter Tags
  late List<String> memberFilterTags;
  List<String> selectedTags = [];

  /// Free Text Tags
  late List<TextEditingController> freeTextControls = [];

  /// Profile Image
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef;
  String tempProfileImageUrl = '';
  final ImagePicker picker = ImagePicker();
  XFile? profileImage;
  late Member editedMember;

  cancelEdit() {
    setState(() {
      /// clear Filter Tags
      selectedTags = memberFilterTags;

      /// reset TextFiled Tags
      for (var i = 0; i < mainController.freeTextTagsList.length; i++) {
        //freeTextControls.add(TextEditingController());
        //init ctrl with member value if pre exists
        freeTextControls[i].text = widget.member.getFreeTextTagValueByKey(
            mainController.freeTextTagsList[i]['key']);
      }

      /// clear temp ProfilePic
      if (tempProfilePicRef.name != '')
        memberController.deleteTempProfilePic(tempProfilePicRef);
      tempProfileImageUrl =
          memberController.currentMember.value.profileImage ?? '';

      editModeOn = false;
    });
  }

  updateMemberInfo() async {
    editedMember.currentTitle = currentTitleCtrl.text;
    editedMember.currentBusinessName = currentBusinessCtrl.text;
    editedMember.residence = residenceCtrl.text;
    editedMember.mobile = mobileCtrl.text;
    editedMember.mobileCountryCode = mobileCountryCodeCtrl.text;
    editedMember.email = emailCtrl.text;
    editedMember.forum = forumCtrl.text;
    editedMember.joinDate = memberSinceCtrl.text;
    editedMember.currentBusinessName = currentBusinessCtrl.text;
    editedMember.profileImage = tempProfileImageUrl;
    editedMember.filterTags = selectedTags;
    editedMember.linkedin = linkedInCtrl.text;
    editedMember.instagram = instagramCtrl.text;
    editedMember.facebook = facebookCtrl.text;
    editedMember.children = childrenCtrl;

    /// FreeTextTags
    editedMember.freeTextTags = [];
    for (var i = 0; i < freeTextControls.length; i++) {
      if (freeTextControls[i].text != '') {
        Map<String, dynamic> freeTextTag = mainController
            .newFreeTextTag(mainController.freeTextTagsList[i]['key']);
        freeTextTag['value'] = freeTextControls[i].text;
        editedMember.freeTextTags?.add(freeTextTag);
      }
    }

    /// Save to Db
    await memberController.updateMemberInfo(editedMember);
    tempProfilePicRef = storageRef.child("");
  }

  @override
  void initState() {
    super.initState();
    editedMember = widget.member;
    currentTitleCtrl.text = widget.member.currentTitle;
    currentBusinessCtrl.text = widget.member.currentBusinessName;
    residenceCtrl.text = widget.member.residence;
    mobileCtrl.text = widget.member.mobile;
    mobileCountryCodeCtrl.text = widget.member.mobileCountryCode;
    emailCtrl.text = widget.member.email;
    memberSinceCtrl.text = widget.member.joinDate;
    forumCtrl.text = widget.member.forum;
    childrenCtrl = widget.member.children ?? [];
    linkedInCtrl.text = widget.member.linkedin ?? '';
    instagramCtrl.text = widget.member.instagram ?? '';
    facebookCtrl.text = widget.member.facebook ?? '';

    /// Filter Tags
    memberFilterTags = widget.member.getMemberFilterTags();
    selectedTags = memberFilterTags;

    /// Free Text Tags
    /// // build controllers for edit mode
    for (var i = 0; i < mainController.freeTextTagsList.length; i++) {
      freeTextControls.add(TextEditingController());
      //init ctrl with member value if pre exists
      freeTextControls[i].text = widget.member
          .getFreeTextTagValueByKey(mainController.freeTextTagsList[i]['key']);
    }

    ///ProfileImage
    tempProfilePicRef = storageRef.child("");
    tempProfileImageUrl =
        widget.member.profileImage ?? '/assets/images/profile0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: memberController.themeMode.value.name == 'dark'
            ? null
            : Colors.blueGrey.shade50,
        appBar: AppBar(
          leading: editModeOn
              ? SizedBox(
                  width: 5,
                )
              : IconButton(
                  onPressed: () {
                    cancelEdit();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back)),
          title: Column(
            children: [
              Text(widget.member.fullName(),
                  style: Theme.of(context).textTheme.titleLarge),
              Obx(() => memberController.saving.value
                  ? LinearProgressIndicator(color: Colors.blue.shade900)
                  : SizedBox(
                      height: 10,
                    ))
            ],
          ),
          //actions: [IconButton(onPressed: () {}, icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode))],
        ),
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Obx(() => Column(
                    children: [
                      /// -- IMAGE
                      Stack(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: memberController.loadingProfileImage.value
                                ? ProfileImageLoading()
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(editModeOn
                                        ? tempProfileImageUrl
                                        : widget.member.profileImage ??
                                            'https://firebasestorage.googleapis.com/v0/b/ypodex.appspot.com/o/profile_images%2Fprofile0.jpg?alt=media'),
                                  ),
                          ),
                          if (editModeOn)
                            Positioned(
                              //top: 0,
                              bottom: 0,
                              right: 0,
                              //left : 0,
                              child: GestureDetector(
                                onTap: () async {
                                  memberController.loadingProfileImage.value =
                                      true;
                                  profileImage = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (profileImage == null) return;
                                  String url =
                                      await memberController.uploadProfileImage(
                                          profileImage!, widget.member.id);
                                  setState(() {
                                    if (url != '') tempProfileImageUrl = url;
                                    print('new tempprofile:');
                                    print(tempProfileImageUrl);
                                    memberController.loadingProfileImage.value =
                                        false;
                                  });
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Icon(
                                    LineAwesomeIcons.edit,
                                    color: Colors.blue.shade900,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ) //   GestureDetector(
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          maxLines: 2,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0,
                                horizontal: 0.0,
                              ),
                              isDense: true,
                              helperText: editModeOn
                                  ? 'Please fill your current title.'
                                  : '',
                              border: editModeOn
                                  ? OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue.shade900,
                                          width: 4))
                                  : InputBorder.none),
                          textAlign:
                              editModeOn ? TextAlign.start : TextAlign.center,
                          controller: currentTitleCtrl,
                          enabled: editModeOn ? true : false,
                          style: Theme.of(context).textTheme.titleLarge!,
                        ),
                      ),
                      SizedBox(
                        width: 350,
                        child: TextField(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0,
                                horizontal: 0.0,
                              ),
                              isDense: true,
                              helperText: editModeOn
                                  ? 'Please fill your current company or business.'
                                  : '',
                              border: editModeOn
                                  ? OutlineInputBorder()
                                  : InputBorder.none),
                          textAlign:
                              editModeOn ? TextAlign.start : TextAlign.center,
                          controller: currentBusinessCtrl,
                          enabled: editModeOn ? true : false,
                          style: Theme.of(context).textTheme.titleLarge!,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// -- BUTTON EDIT and Logout-- Only when Member.
                      memberController.currentMember.value.email ==
                              widget.member.email
                          ? SizedBox(
                              width: 200,
                              child: !editModeOn
                                  ? ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          editModeOn = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                          side: BorderSide.none,
                                          shape: const StadiumBorder()),
                                      child: const Text('Edit',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  : ElevatedButton(
                                      onPressed: () async {
                                        // setState(() {
                                        //   memberController.loading.value=true;
                                        // });
                                        await updateMemberInfo();
                                        setState(() {
                                          editModeOn = false;
                                          //   memberController.loading.value=false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                          side: BorderSide.none,
                                          shape: const StadiumBorder()),
                                      child: const Text('Save',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: 200,
                          child: editModeOn
                              ? ElevatedButton(
                                  onPressed: () async {
                                    cancelEdit();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade900,
                                      side: BorderSide.none,
                                      shape: const StadiumBorder()),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : memberController.currentMember.value.email ==
                                      widget.member.email
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        print('logout');
                                        await memberController.logout();
                                        Get.to(() => const Goodbye());
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                          side: BorderSide.none,
                                          shape: const StadiumBorder()),
                                      child: const Text('Logout',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  : SizedBox(
                                      height: 5,
                                    )),
                      /////////
                      const Divider(),

                      /// Social Bar
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                            child: SizedBox(
                                width: 160,
                                height: 40,
                                child: SocialBar(
                                    linkedin: widget.member.linkedin,
                                    instagram: widget.member.instagram,
                                    facebook: widget.member.facebook))),
                      ),

                      /// Residence
                      editModeOn
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20.0, left: 60),
                              child: SizedBox(
                                width: 300,
                                child: DropdownMenu(
                                  leadingIcon: Icon(
                                      color: Colors.blue.shade900,
                                      Icons.location_city_sharp),
                                  label: Text('Residence'),
                                  initialSelection: widget.member.residence,
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                    filled: false,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        //borderSide: BorderSide(color:  Colors.blue),
                                        ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                    //outlineBorder: BorderSide(color:  Colors.blue),
                                  ),
                                  dropdownMenuEntries: mainController
                                      .residenceList
                                      .map<DropdownMenuEntry<String>>(
                                          (String city) {
                                    return DropdownMenuEntry<String>(
                                      value: city,
                                      label: city,
                                      style: MenuItemButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                    );
                                  }).toList(),
                                  controller: residenceCtrl,
                                  enabled: editModeOn ? true : false,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ProfileMenuWidget(
                                  title: "Residence: ",
                                  icon: Icons.location_city_sharp,
                                  value: widget.member.residence,
                                  type: 'text',
                                  onPress: () {}),
                            ),

                      /// Mobile
                      editModeOn
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: SizedBox(
                                width: 300,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 85,
                                      child: TextField(
                                        decoration: InputDecoration(
                                            iconColor: Colors.blue.shade900,
                                            icon: Icon(
                                              Icons.phone,
                                            ),
                                            label: Text('Code:'),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 0.0,
                                              horizontal: 0.0,
                                            ),
                                            isDense: true,
                                            helperText:
                                                editModeOn ? 'e.g.+972' : '',
                                            border: editModeOn
                                                ? OutlineInputBorder()
                                                : InputBorder.none),
                                        textAlign: TextAlign.start,
                                        controller: mobileCountryCodeCtrl,
                                        enabled: editModeOn ? true : false,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 205,
                                      child: TextField(
                                        decoration: InputDecoration(
                                            iconColor: Colors.blue.shade900,
                                            label: Text('Mobile:'),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 0.0,
                                              horizontal: 0.0,
                                            ),
                                            isDense: true,
                                            helperText: editModeOn
                                                ? 'Please fill your mobile number.'
                                                : '',
                                            border: editModeOn
                                                ? OutlineInputBorder()
                                                : InputBorder.none),
                                        textAlign: TextAlign.start,
                                        controller: mobileCtrl,
                                        enabled: editModeOn ? true : false,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        onChanged: (s) => {
                                          if (GetUtils.isPhoneNumber(s))
                                            {print('legal phone')}
                                          else
                                            {print('illegal phone')}
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ProfileMenuWidget(
                                title: "Mobile: ",
                                icon: Icons.phone,
                                value: widget.member.mobileCountryCode +
                                    widget.member.mobile,
                                type: 'text',
                                onPress: () {},
                              ),
                            ),

                      /// Email
                      editModeOn
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.mail,
                                          color: Colors.blue.shade900),
                                      label: Text('Email:'),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 0.0,
                                      ),
                                      isDense: true,
                                      helperText: editModeOn
                                          ? 'Please fill your current email.'
                                          : '',
                                      border: editModeOn
                                          ? OutlineInputBorder()
                                          : InputBorder.none),
                                  textAlign: TextAlign.start,
                                  controller: emailCtrl,
                                  enabled: editModeOn ? true : false,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ProfileMenuWidget(
                                  title: "Email: ",
                                  icon: Icons.mail,
                                  value: widget.member.email,
                                  type: 'email',
                                  onPress: () {}),
                            ),

                      /// Member Since
                      editModeOn
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                      icon: Icon(
                                        Icons.mail,
                                        color: Colors.blue.shade900,
                                      ),
                                      label: Text('Member Since:'),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 0.0,
                                      ),
                                      isDense: true,
                                      helperText: editModeOn
                                          ? 'Please fill in the year you joined. (e.g. 2021)'
                                          : '',
                                      border: editModeOn
                                          ? OutlineInputBorder()
                                          : InputBorder.none),
                                  textAlign: TextAlign.start,
                                  controller: memberSinceCtrl,
                                  enabled: editModeOn ? true : false,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ProfileMenuWidget(
                                  title: "Member Since: ",
                                  icon: Icons.av_timer_rounded,
                                  value: widget.member.joinDate,
                                  type: 'text',
                                  onPress: () {}),
                            ),

                      /// Forum
                      editModeOn
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20.0, left: 60),
                              child: SizedBox(
                                width: 300,
                                child: DropdownMenu(
                                  leadingIcon: Icon(Icons.group),
                                  label: Text('Forum:'),
                                  initialSelection: widget.member.forum,
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                    filled: false,
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                  ),
                                  dropdownMenuEntries: mainController.forumList
                                      .map<DropdownMenuEntry<String>>(
                                          (String city) {
                                    return DropdownMenuEntry<String>(
                                      value: city,
                                      label: city,
                                      style: MenuItemButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                    );
                                  }).toList(),
                                  controller: forumCtrl,
                                  enabled: editModeOn ? true : false,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ProfileMenuWidget(
                                  title: "Forum: ",
                                  icon: Icons.group,
                                  value: widget.member.forum.toString(),
                                  type: 'text',
                                  onPress: () {}),
                            ),

                      /// linkedin
                      editModeOn
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                      icon: Image.network(
                                        'assets/images/linkedin.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      label: Text('Linkedin:'),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 0.0,
                                      ),
                                      isDense: true,
                                      helperText: editModeOn
                                          ? 'use full link (e.g. http://....)'
                                          : '',
                                      border: editModeOn
                                          ? OutlineInputBorder()
                                          : InputBorder.none),
                                  textAlign: TextAlign.start,
                                  controller: linkedInCtrl,
                                  enabled: editModeOn ? true : false,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 1,
                            ),

                      /// instagram
                      editModeOn
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                      icon: Image.network(
                                        'assets/images/instagram.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      label: Text('Instagram:'),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 0.0,
                                      ),
                                      isDense: true,
                                      helperText: editModeOn
                                          ? 'use full link (e.g. http://....)'
                                          : '',
                                      border: editModeOn
                                          ? OutlineInputBorder()
                                          : InputBorder.none),
                                  textAlign: TextAlign.start,
                                  controller: instagramCtrl,
                                  enabled: editModeOn ? true : false,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 1,
                            ),

                      /// facebook
                      editModeOn
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                      icon: Image.network(
                                        'assets/images/facebook.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      label: Text('Facebook:'),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0.0,
                                        horizontal: 0.0,
                                      ),
                                      isDense: true,
                                      helperText: editModeOn
                                          ? 'use full link (e.g. http://....)'
                                          : '',
                                      border: editModeOn
                                          ? OutlineInputBorder()
                                          : InputBorder.none),
                                  textAlign: TextAlign.start,
                                  controller: facebookCtrl,
                                  enabled: editModeOn ? true : false,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 1,
                            ),

                      /// Children
                      Padding(
                        padding: EdgeInsets.only(
                            left: editModeOn ? 60 : 0, bottom: 16.0),
                        child: RayBarMultiField(
                            keysPerEntry: ['Name', 'Year of Birth'],
                            entries: childrenCtrl,
                            label: 'Children',
                            editMode: editModeOn,
                            icon: Icons.family_restroom_rounded,
                            iconColor: Colors.blue.shade900,
                            onChangeMultiFieldCallback: (updatedChildrenData) {
                              childrenCtrl = [];
                              // Convert to List<Map<String, dynamic>>
                              List list = updatedChildrenData['children'];
                              List<Map<String, dynamic>> mapList = list
                                  .map((e) => Map<String, dynamic>.from(e))
                                  .toList();
                              childrenCtrl = mapList;
                            }),
                      ),

                      /// Filtered Tags
                      const Divider(),
                      const SizedBox(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Filter Tags',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      FilterTagsCards(
                        editModeOn: editModeOn,
                        selectedTags: selectedTags,
                      ),

                      /// Free Text Tags
                      const Divider(),
                      const SizedBox(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Additional Information',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      editModeOn
                          ? Column(
                              children: List.generate(
                                  mainController.freeTextTagsList.length,
                                  (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: TextField(
                                  maxLines:
                                      mainController.freeTextTagsList[index]
                                                  ['type'] ==
                                              'textbox'
                                          ? 3
                                          : 1,
                                  minLines:
                                      mainController.freeTextTagsList[index]
                                                  ['type'] ==
                                              'textbox'
                                          ? 3
                                          : 1,
                                  decoration: InputDecoration(
                                      icon: Icon(
                                          color: Colors.blue.shade900,
                                          IconData(
                                              int.parse(mainController
                                                      .freeTextTagsList[index]
                                                  ['icon_code']),
                                              fontFamily: 'MaterialIcons')),
                                      label: Text(mainController
                                          .freeTextTagsList[index]['label']),
                                      helperText: mainController
                                          .freeTextTagsList[index]['hint'],
                                      border: OutlineInputBorder()),
                                  textAlign: TextAlign.start,
                                  controller: freeTextControls[index],
                                  enabled: true,
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }))
                          : widget.member.freeTextTags!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 50.0),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                          widget.member.freeTextTags!.length,
                                          (index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20.0),
                                          child: ProfileMenuWidget(
                                              title:
                                                  '${widget.member.freeTextTags![index]['label']}: ',
                                              icon: IconData(
                                                  int.parse(widget.member
                                                          .freeTextTags![index]
                                                      ['icon_code']),
                                                  fontFamily: 'MaterialIcons'),
                                              value: widget.member
                                                          .freeTextTags![index]
                                                      ['value'] ??
                                                  '',
                                              type: widget.member
                                                  .freeTextTags![index]['type'],
                                              onPress: () {}),
                                        );
                                      })),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                      'You have not provided any extra information-Please Edit and Update!'),
                                ),
                      editModeOn
                          ? Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await updateMemberInfo();
                                    setState(() {
                                      editModeOn = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade900,
                                      side: BorderSide.none,
                                      shape: const StadiumBorder()),
                                  child: const Text('Save',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 20,
                            )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}



class FilterTagsCards extends StatefulWidget {
  final bool editModeOn;
  final List<String> selectedTags;

  const FilterTagsCards(
       {  required this.editModeOn,
         required this.selectedTags,
        super.key,
      });

  @override
  _FilterTagsCardsState createState() => _FilterTagsCardsState();
}

class _FilterTagsCardsState extends State<FilterTagsCards> {
  final mainController = Get.put(MainController());

 List<String> getSelectedTagsInCategory(tagsInCategory, List<String> selectedTags) {
   List<String> list = [];
   for (String tag in selectedTags) {
     if (tagsInCategory.contains(tag)) {
       list.add(tag);
     }
   }
   return list;
 }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          mainController.filteredTagsList.length,
              (index) => Padding(
            padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                top: 8,
                bottom: 10),
            child: SizedBox(
              width: 800,
              child:
              (mainController.filteredTagsList[index]
              ['key'] !=
                  'residence' &&
                  mainController.filteredTagsList[
                  index]['key'] !=
                      'forum')
                  ? Card(
                color: Colors.blue.shade900,
                elevation: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        mainController
                            .filteredTagsList[
                        index]['label'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight
                                .bold),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.all(8.0),
                      child: Wrap(
                          runSpacing: widget.editModeOn?8:8,
                          spacing: widget.editModeOn?10:8,
                          children: widget.editModeOn
                              ? List.generate(
                              mainController.filteredTagsList[index]['tags_list'].length,
                                  (tagIndex) => ChoiceChip(
                                  onSelected: (val) {
                                    setState(
                                            () {
                                          if (widget.selectedTags.contains(mainController.filteredTagsList[index]['tags_list']
                                          [
                                          tagIndex])) {
                                            widget.selectedTags.remove(mainController.filteredTagsList[index]['tags_list'][tagIndex]);
                                          } else {
                                            widget.selectedTags.add(mainController.filteredTagsList[index]['tags_list'][tagIndex]);
                                          }
                                        });
                                  },
                                  label: Text(mainController.filteredTagsList[index]['tags_list'][tagIndex]),
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  selected: widget.selectedTags.contains(mainController.filteredTagsList[index]['tags_list'][tagIndex]))
                          )
                              : List.generate(
                                  getSelectedTagsInCategory(mainController.filteredTagsList[index]['tags_list'],widget.selectedTags).length,
                              (tagIndex) =>
                                  ChoiceChip(
                              label: Text(getSelectedTagsInCategory(mainController.filteredTagsList[index]['tags_list'],widget.selectedTags)[tagIndex]),
                              labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                              selected: true
                                  )
                              ),
                    ),
                    )
                  ],
                ),
              )
                  : const SizedBox(
                height: 10,
              ),
            ),
          )),
    );
  }
}
