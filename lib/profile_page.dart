import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:ypo_connect/models.dart';
import 'profile_menu.dart';
import 'ctx.dart';
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
  final controller = Get.put(Controller());
  bool editModeOn = false;
  TextEditingController currentTitleCtrl = TextEditingController();
  TextEditingController  currentBusinessCtrl = TextEditingController();
  TextEditingController residenceCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();
  TextEditingController mobileCountryCodeCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController memberSinceCtrl = TextEditingController();
  TextEditingController forumCtrl = TextEditingController();
  /// Filter Tags
  late List<String> memberFilterTags;
  List<String> selectedTags = [];
  /// Free Text Tags
  late List<TextEditingController> freeTextControls= [];
  /// Profile Image
  Reference storageRef = FirebaseStorage.instance.ref();
  late Reference tempProfilePicRef;
  String tempProfileImageUrl = '';
  final ImagePicker picker = ImagePicker();
  XFile? profileImage;
  late Member editedMember ;

  cancelEdit() {
    setState(() {
      /// clear Filter Tags
      selectedTags=memberFilterTags;
      /// reset TextFiled Tags
      for (var i=0; i<controller.freeTextTagsList.length ; i++) {
        freeTextControls.add(TextEditingController());
        //init ctrl with member value if pre exists
        freeTextControls[i].text = widget.member.getFreeTextTagValueByKey(controller.freeTextTagsList[i]['key']);
      }
      /// clear temp ProfilePic
      if (tempProfilePicRef.name!='') controller.deleteTempProfilePic(tempProfilePicRef);
      tempProfileImageUrl = controller.currentMember.value.profileImage??'';

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
      selectedTags.add(editedMember.residence);
      selectedTags.add(editedMember.forum);
      editedMember.filterTags = selectedTags;
      /// FreeTextTags
      editedMember.freeTextTags = [];
      for (var i=0; i< freeTextControls.length; i++) {
        if (freeTextControls[i].text!='') {
          editedMember.freeTextTags?.add({controller.freeTextTagsList[i]['key'] : freeTextControls[i].text});
        }
      }
      /// Save to Db
      await controller.updateMemberInfo(editedMember);
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
    /// Filter Tags
    memberFilterTags = widget.member.getMemberFilterTags();
    selectedTags = memberFilterTags;
    /// Free Text Tags
    /// // build controllers for edit mode
    for (var i=0; i<controller.freeTextTagsList.length ; i++) {
      freeTextControls.add(TextEditingController());
      //init ctrl with member value if pre exists
      freeTextControls[i].text = widget.member.getFreeTextTagValueByKey(controller.freeTextTagsList[i]['key']);
    }
    ///ProfileImage
    tempProfilePicRef = storageRef.child("");
    tempProfileImageUrl = widget.member.profileImage??'';
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: editModeOn?SizedBox(width: 5,):IconButton(
              onPressed: () {
                cancelEdit();
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          title: Column(
            children: [
              Text(widget.member.fullName(), style: Theme.of(context).textTheme.bodyMedium!),
              Obx(() => controller.loading.value?LinearProgressIndicator(
                semanticsLabel: 'Linear progress indicator',
              ):SizedBox(height: 10,))
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
                        child: controller.loadingProfileImage.value?ProfileImageLoading():ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: (widget.member.profileImage != null &&  widget.member.profileImage != '')
                                ? Image.network(!editModeOn?widget.member.profileImage!:tempProfileImageUrl)
                                : const Image(
                                    image: AssetImage('images/profile0.jpg'))),
                      ),
                      if (editModeOn)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                              onTap: () async {
                                controller.loadingProfileImage.value=true;
                                profileImage = await picker.pickImage(source: ImageSource.gallery);
                                if (profileImage==null) return;
                                String url = await controller.uploadProfileImage(profileImage!,widget.member.id);
                                setState(() {
                                  if (url!='') tempProfileImageUrl = url;
                                  controller.loadingProfileImage.value=false;
                                });
                              },
                              child:  Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                            child: const Icon(
                              LineAwesomeIcons.edit,
                              //color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        ) //   GestureDetector(
                      //   onTap: () async {
                      //     controller.loadingProfileImage.value=true;
                      //     profileImage = await picker.pickImage(source: ImageSource.gallery);
                      //     if (profileImage==null) return;
                      //     String url = await controller.uploadProfileImage(profileImage!,widget.member.id);
                      //     setState(() {
                      //       controller.loadingProfileImage.value=false;
                      //     });
                      //   },
                      //   child: Positioned(
                      //     bottom: 0,
                      //     right: 0,
                      //     child: Container(
                      //       width: 35,
                      //       height: 35,
                      //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.blue),
                      //       child: const Icon(
                      //         LineAwesomeIcons.edit,
                      //         color: Colors.black,
                      //         size: 20,
                      //       ),
                      //     ),
                      //   ),
                      // ) else SizedBox(),
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
                          helperText: editModeOn?'Please fill your current title.':'',
                          border: editModeOn? OutlineInputBorder() :InputBorder.none
                      ),
                      textAlign: TextAlign.center,
                      controller: currentTitleCtrl,
                      enabled: editModeOn?true:false,
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
                          helperText: editModeOn?'Please fill your current company or business.':'',
                          border: editModeOn? OutlineInputBorder() :InputBorder.none
                      ),
                      textAlign: TextAlign.center,
                      controller: currentBusinessCtrl,
                      enabled: editModeOn?true:false,
                      style: Theme.of(context).textTheme.titleLarge!,
                    ),
                  ),
                  const SizedBox(height: 20),
                  /// -- BUTTON EDIT -- Only when Member.
                  controller.currentMember.value.email==widget.member.email?
                  SizedBox(
                    width: 200,
                    child: !editModeOn?ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editModeOn = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                      child: const Text('Edit'),
                    ):ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          controller.loading.value=true;
                        });
                        await updateMemberInfo();
                        setState(() {
                          editModeOn = false;
                          controller.loading.value=false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                      child: const Text('Save'),
                    ),
                  )
                      :SizedBox(),
                  SizedBox(height: 20,),
                  /// email
                  SizedBox(
                    width: 200,
                    child: editModeOn?ElevatedButton(
                      onPressed: () async {
                        cancelEdit();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                      child: const Text('Cancel'),
                    ):controller.currentMember.value.email==widget.member.email?ElevatedButton(
                    onPressed: () async {
                      print('logout');
                      //await FirebaseAuth.instance.signOut();
                      await controller.logout();
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                    child: const Text('Logout'),
                  ):SizedBox(height: 5,)
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  /// Residence
                  editModeOn ?Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left :60),
                    child: SizedBox(
                      width: 300,
                      child: DropdownMenu(
                        leadingIcon: Icon(Icons.location_city_sharp),
                        label: Text('Residence'),
                        initialSelection: widget.member.residence,
                        inputDecorationTheme: InputDecorationTheme(
                          filled: false,
                          isDense: true,
                          border:  OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                        ),
                        dropdownMenuEntries: controller.residenceList
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
                        enabled: editModeOn?true:false,
                      ),
                    ),
                  ):ProfileMenuWidget(
                      title: "Residence: ",
                      icon: Icons.location_city_sharp,
                      value: widget.member.residence,
                      onPress: () {}
                  ),
                  /// Mobile
                  editModeOn ?Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SizedBox(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 85,
                            child: TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.phone,),
                                  label: Text('Code:'),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 0.0,
                                  ),
                                  isDense: true,
                                  helperText: editModeOn?'e.g.+972':'',
                                  border: editModeOn? OutlineInputBorder() :InputBorder.none
                              ),
                              textAlign: TextAlign.center,
                              controller: mobileCountryCodeCtrl,
                              enabled: editModeOn?true:false,
                              style: TextStyle(fontSize: 20 ),
                            ),
                          ),
                          SizedBox(
                            width: 205,
                            child: TextField(
                              decoration: InputDecoration(
                                  label: Text('Mobile:'),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 0.0,
                                  ),
                                  isDense: true,
                                  helperText: editModeOn?'Please fill your mobile number.':'',
                                  border: editModeOn? OutlineInputBorder() :InputBorder.none
                              ),
                              textAlign: TextAlign.center,
                              controller: mobileCtrl,
                              enabled: editModeOn?true:false,
                              style: TextStyle(fontSize: 20 ,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):ProfileMenuWidget(
                      title: "Mobile: ",
                      icon: Icons.phone,
                      value: widget.member.mobileCountryCode+widget.member.mobile,
                      onPress: () {}
                  ),
                  /// Email
                  editModeOn ?Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.mail,),
                            label: Text('Email:'),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0.0,
                              horizontal: 0.0,
                            ),
                            isDense: true,
                            helperText: editModeOn?'Please fill your current email.':'',
                            border: editModeOn? OutlineInputBorder() :InputBorder.none
                        ),
                        textAlign: TextAlign.center,
                        controller: emailCtrl,
                        enabled: editModeOn?true:false,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ): ProfileMenuWidget(
                      title: "Email: ",
                      icon: Icons.mail,
                      value: widget.member.email,
                      onPress: () {}),
                  /// Member Since
                  editModeOn ?Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.mail,),
                            label: Text('Member Since:'),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0.0,
                              horizontal: 0.0,
                            ),
                            isDense: true,
                            helperText: editModeOn?'Please fill in the year you joined. (e.g. 2021)':'',
                            border: editModeOn? OutlineInputBorder() :InputBorder.none
                        ),
                        textAlign: TextAlign.center,
                        controller: memberSinceCtrl,
                        enabled: editModeOn?true:false,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ):ProfileMenuWidget(
                      title: "Member Since: ",
                      icon: Icons.av_timer_rounded,
                      value: widget.member.joinDate,
                      onPress: () {}),
                  /// Forum
                  editModeOn?Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left :60),
                    child: SizedBox(
                      width: 300,
                      child: DropdownMenu(
                        leadingIcon: Icon(Icons.group),
                        label: Text('Forum:'),
                        initialSelection: widget.member.forum,
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,
                          isDense: true,
                          border:  OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                        ),
                        dropdownMenuEntries: controller.forumList
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
                        enabled: editModeOn?true:false,
                      ),
                    ),
                  ):ProfileMenuWidget(
                      title: "Forum: ",
                      icon: Icons.group,
                      value: widget.member.forum.toString(),
                      onPress: () {}),
                  /// Filtered Tags
                  const Divider(),
                  const SizedBox(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Filter Tags'),
                    ),
                  ),
                  Column(
                    children: List.generate(
                        controller.filteredTagsList.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 10, bottom: 10),
                              child: SizedBox(
                                //height: 200,
                                width: 800,
                                child: (  controller.filteredTagsList[index]['key']!='residence' &&
                                          controller.filteredTagsList[index]['key']!='forum'
                                        )
                                    ?Card(
                                  elevation: 10,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(controller
                                            .filteredTagsList[index]['label'], style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Wrap(
                                            runSpacing: 8,
                                            spacing: 10,
                                            children:
                                             List.generate(controller
                                                 .filteredTagsList[index]['tags_list'].length, (tagIndex) =>
                                                 editModeOn
                                                     ? ChoiceChip(
                                                     onSelected: (val) {
                                                       if (editModeOn) {
                                                         setState(() {
                                                           if (selectedTags.contains(controller.filteredTagsList[index]['tags_list'][tagIndex])){
                                                             selectedTags.remove(controller.filteredTagsList[index]['tags_list'][tagIndex]);
                                                           } else {
                                                             selectedTags.add(controller.filteredTagsList[index]['tags_list'][tagIndex]);
                                                           }

                                                         });
                                                       }
                                                     },
                                                     label: Text(controller
                                                         .filteredTagsList[index]['tags_list'][tagIndex]),
                                                     labelStyle: const TextStyle(
                                                         fontWeight: FontWeight.bold),
                                                     selected: selectedTags.contains(controller.filteredTagsList[index]['tags_list'][tagIndex])
                                                 )
                                                     : selectedTags.contains(controller.filteredTagsList[index]['tags_list'][tagIndex])
                                                       ? ChoiceChip(
                                                   onSelected: (val) {
                                                     if (editModeOn) {
                                                       setState(() {
                                                         if (selectedTags.contains(controller.filteredTagsList[index]['tags_list'][tagIndex])){
                                                           selectedTags.remove(controller.filteredTagsList[index]['tags_list'][tagIndex]);
                                                         } else {
                                                           selectedTags.add(controller.filteredTagsList[index]['tags_list'][tagIndex]);
                                                         }

                                                       });
                                                     }
                                                   },
                                                   label: Text(controller
                                                       .filteredTagsList[index]['tags_list'][tagIndex]),
                                                   labelStyle: const TextStyle(
                                                       fontWeight: FontWeight.bold),
                                                   selected: selectedTags.contains(controller.filteredTagsList[index]['tags_list'][tagIndex])
                                                   ):SizedBox(width: 1,)
                                                 )
                                             ),
                                            ),
                                    ],
                                  ),
                                ):SizedBox(height: 10,),
                              ),
                            )),
                  ),
                  /// Free Text Tags
                  const Divider(),
                  const SizedBox(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Additional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                  ),
                  editModeOn?
                      Column(
                        children: List.generate(controller.freeTextTagsList.length, (index) {
                         return Padding(
                           padding: const EdgeInsets.only(bottom: 20.0),
                           child: TextField(
                             decoration: InputDecoration(
                                 icon: Icon(IconData(int.parse(controller.freeTextTagsList[index]['icon_code']),fontFamily: 'MaterialIcons')),
                                 label: Text(controller.freeTextTagsList[index]['label']),
                                 contentPadding: EdgeInsets.symmetric(
                                   vertical: 0.0,
                                   horizontal: 0.0,
                                 ),
                                 isDense: true,
                                 helperText: controller.freeTextTagsList[index]['hint'],
                                 border: OutlineInputBorder()
                             ),
                             textAlign: TextAlign.center,
                             controller: freeTextControls[index],
                             enabled: true,
                             style: TextStyle(fontSize: 20 ),
                           ),
                         );
                         })
                      )
                      :widget.member.freeTextTags!.isNotEmpty
                      ?Column(
                      children: List.generate(
                          widget.member.freeTextTags!.length, (index) {
                        return ProfileMenuWidget(
                            title: controller.getFreeTextTagLabel(widget.member.freeTextTags![index].keys.single) + ': ',
                            icon: IconData(int.parse(controller.freeTextTagsList[index]['icon_code']),fontFamily: 'MaterialIcons'),
                            value: widget.member.freeTextTags![index].values.single,
                            onPress: () {});
                      }))
                      :Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: const Text('You have not provided any extra information-Please Edit and Update!'),
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


/*
TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.location_city_sharp,),
                          label: Text('Residence:'),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0.0,
                              horizontal: 0.0,
                            ),
                            isDense: true,
                            helperText: editModeOn?'Please fill your current company or business.':'',
                            border: editModeOn? OutlineInputBorder() :InputBorder.none
                        ),
                        textAlign: TextAlign.center,
                        controller: residenceCtrl,
                        enabled: editModeOn?true:false,
                        style: TextStyle(fontSize: 20 , color: Colors.black),
                      ),



ChoiceChip(
                                                   onSelected: (val) {
                                                     setState(() {

                                                     });
                                                   },
                                                   label: Text(controller
                                                       .filteredTagsList[index]['tags_list'][tagIndex]),
                                                   labelStyle: const TextStyle(
                                                       fontWeight: FontWeight.bold, color: Colors.black),
                                                   selected: widget.member.hasFilterTag(controller.filteredTagsList[index]['key'], controller.filteredTagsList[index]['tags_list'][tagIndex]
                                                   )
                                                 )
 */