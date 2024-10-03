import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'members_controller.dart';
import 'main_controller.dart';
import 'package:get/get.dart';
import 'utils.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class AddNewMember extends StatelessWidget {
  const AddNewMember({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final membersController = Get.put(MembersController());
    final mainController = Get.put(MainController());
    TextEditingController firstNameCtrl = TextEditingController();
    TextEditingController lastNameCtrl = TextEditingController();
    TextEditingController emailCtrl = TextEditingController();
    TextEditingController residenceCtrl = TextEditingController();
    TextEditingController forumCtrl = TextEditingController();
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 125,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Column(
              children: [
                Image.network(scale: 2, 'assets/images/logo-insider.png'),
                Text('Administrator', style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 30, right:30, top: 80, bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100, // Background color
                // border: Border.all(color: Colors.red, width: 1), // Border
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Add a new YPO member', style: TextStyle(fontSize: 30, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Text('First Name:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: SizedBox(
                              width: 200,
                              height: 50,
                              child: TextField(
                                controller: firstNameCtrl,
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Text('Last Name:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: SizedBox(
                              width: 200,
                              height: 50,
                              child: TextField(
                                controller: lastNameCtrl,
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Text(
                          'Email:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: SizedBox(
                              width: 200,
                              height: 50,
                              child: TextField(
                                controller: emailCtrl,
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: DropdownMenu(
                            leadingIcon: Icon(Icons.location_city_sharp),
                            label: Text('Residence'),
                            initialSelection: mainController.residenceList[0],
                            inputDecorationTheme: const InputDecorationTheme(
                              filled: false,
                              isDense: true,
                              border: OutlineInputBorder(
                                  //borderSide: BorderSide(color:  Colors.blue),
                                  ),
                              contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                              //outlineBorder: BorderSide(color:  Colors.blue),
                            ),
                            dropdownMenuEntries: mainController.residenceList
                                .map<DropdownMenuEntry<String>>((String city) {
                              return DropdownMenuEntry<String>(
                                value: city,
                                label: city,
                                style: MenuItemButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ),
                              );
                            }).toList(),
                            controller: residenceCtrl,
                            enabled: true,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: DropdownMenu(
                      leadingIcon: Icon(Icons.group),
                      label: Text('Forum:'),
                      initialSelection: mainController.forumList[0],
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      dropdownMenuEntries: mainController.forumList
                          .map<DropdownMenuEntry<String>>((String city) {
                        return DropdownMenuEntry<String>(
                          value: city,
                          label: city,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                        );
                      }).toList(),
                      controller: forumCtrl,
                      enabled: true,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            /// print('save data');
                            await membersController.addNewMember(
                                firstNameCtrl.text,
                                lastNameCtrl.text,
                                emailCtrl.text);
                            const snackBar = SnackBar(
                              content: Text(
                                'Member Added!',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            Get.back();
                          },
                          child: Text('Save')),
                      ElevatedButton(
                          onPressed: () {
                            /// print('Cancel');
                            Get.back();
                          },
                          child: Text('Cancel')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddNewResidence extends StatelessWidget {
  const AddNewResidence({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mainController = Get.put(MainController());
    TextEditingController residenceCtrl = TextEditingController();
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 125,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Column(
              children: [
                Image.network(scale: 2, 'assets/images/logo-insider.png'),
                Text('Administrator', style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 30, right:30, top: 80, bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100, // Background color
                // border: Border.all(color: Colors.red, width: 1), // Border
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Add a new Residence/City', style: TextStyle(fontSize: 30, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          const Text('Residence name:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                                width: 150,
                                height: 50,
                                child: TextField(
                                  controller: residenceCtrl,
                                )),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await mainController
                                  .addNewResidence(residenceCtrl.text);
                              const snackBar = SnackBar(
                                content: Text(
                                  'Residence Added!',
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              Get.back();
                            },
                            child: const Text('Save')),
                        ElevatedButton(
                            onPressed: () {
                              /// print('Cancel');
                              Get.back();
                            },
                            child: const Text('Cancel')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddNewForum extends StatelessWidget {
  const AddNewForum({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mainController = Get.put(MainController());
    TextEditingController forumCtrl = TextEditingController();
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 125,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Column(
              children: [
                Image.network(scale: 2, 'assets/images/logo-insider.png'),
                Text('Administrator', style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 30, right:30, top: 20, bottom: 20),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100, // Background color
                  // border: Border.all(color: Colors.red, width: 1), // Border
                  borderRadius: BorderRadius.circular(50), // Rounded corners
                ),
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Text('Add a New Forum', style: TextStyle(fontSize: 32, color: Colors.blue.shade900, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Text('Forum number/name:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                                width: 150,
                                height: 50,
                                child: TextField(
                                  controller: forumCtrl,
                                )),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await mainController.addNewForum(forumCtrl.text);
                              const snackBar = SnackBar(
                                content: Text(
                                  'Forum Added!',
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              Get.back();
                            },
                            child: Text('Save')),
                        ElevatedButton(
                            onPressed: () {
                              /// print('Cancel');
                              Get.back();
                            },
                            child: Text('Cancel')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ManageFreeTextTag extends StatefulWidget {
  const ManageFreeTextTag({
    super.key,
  });

  @override
  State<ManageFreeTextTag> createState() => _ManageFreeTextTagState();
}

class _ManageFreeTextTagState extends State<ManageFreeTextTag> {
  TextEditingController labelCtrl = TextEditingController();
  TextEditingController typeCtrl = TextEditingController();
  TextEditingController hintCtrl = TextEditingController();
  TextEditingController iconCodeCtrl = TextEditingController();
  TextEditingController freeTextTagCtrl = TextEditingController();
  String templateId = '';
  final mainController = Get.put(MainController());
  bool addMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 125,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Column(
              children: [
                Image.network(scale: 2, 'assets/images/logo-insider.png'),
                Text('Administrator', style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 30, right:30, top: 20, bottom: 20),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100, // Background color
                  // border: Border.all(color: Colors.red, width: 1), // Border
                  borderRadius: BorderRadius.circular(50), // Rounded corners
                ),
                height: 700,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ///title
                    Center(
                      child: Text('Manage Free Text Tags', style: TextStyle(fontSize: 32, color: Colors.blue.shade900, fontWeight: FontWeight.bold),),
                    ),
                    /// Add and Edit free text tags
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: SizedBox(
                        child: AnimatedToggleSwitch<bool>.dual(
                          current: addMode,
                          first: false,
                          second: true,
                          spacing: 50.0,
                          style: const ToggleStyle(
                            borderColor: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1.5),
                              ),
                            ],
                          ),
                          borderWidth: 5.0,
                          height: 55,
                          onChanged: (b) {
                            if (b) {
                              labelCtrl.text = '';
                              typeCtrl.text = '';
                              hintCtrl.text = '';
                              iconCodeCtrl.text = '';
                            }
                            setState(() => addMode = b);
                            },
                          styleBuilder: (b) => ToggleStyle(
                              indicatorColor: b ? Colors.blue : Colors.green),
                          iconBuilder: (value) => value
                              ? const Icon(Icons.add)
                              : const Icon(Icons.edit),
                          textBuilder: (value) => value
                              ? const Center(child: Text('Add '))
                              : const Center(child: Text('Edit ')),
                        ),
                      ),
                    ),
                    /// Free Text Tags List
                    addMode?SizedBox.shrink():DropdownMenu(
                      leadingIcon: Icon(
                          color: Colors.blue.shade900,
                          Icons.text_fields),
                      label: const Text('Free Text Tags'),
                      //initialSelection: widget.member.residence,
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
                          .freeTextTagsList
                          .map((tag) => tag['label'] as String)
                          .toList()
                          .map<DropdownMenuEntry<String>>(
                              (String tag) {
                            return DropdownMenuEntry<String>(
                              value: tag,
                              label: tag,
                              style: MenuItemButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                            );
                          }).toList(),
                      controller: freeTextTagCtrl,
                      onSelected: (label) {
                        // Find the index of the item where the 'label' key has the target value
                        int index = mainController.freeTextTagsList.indexWhere((tag) => tag['label'] == label);
                        if (index != -1) {
                          var tag = mainController.freeTextTagsList[index];
                          labelCtrl.text = tag['label'];
                          typeCtrl.text = tag['type'];
                          hintCtrl.text = tag['hint'];
                          iconCodeCtrl.text = tag['icon_code'];
                          templateId = tag['templateId'];
                        } else {
                          //print('Label not found');
                        }
                      },
                    ),
                    ///name
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Text('field name:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                                width: 150,
                                height: 50,
                                child: TextField(
                                  controller: labelCtrl,
                                )),
                          ),
                        ],
                      ),
                    ),

                    ///type
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          const Text('field type:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                                width: 150,
                                height: 50,
                                child: DropdownMenu(
                                  controller: typeCtrl,
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(
                                        value: 'text',
                                        label: 'text'),
                                    DropdownMenuEntry(
                                        value: 'link',
                                        label: 'link'),
                                    DropdownMenuEntry(
                                        value: 'textbox',
                                        label: 'textbox')
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),

                    ///hint
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Text('hint:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                                width: 250,
                                height: 50,
                                child: TextField(
                                  controller: hintCtrl,
                                )),
                          ),
                        ],
                      ),
                    ),

                    ///Icon code
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          const Text('icon code:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                                width: 150,
                                height: 50,
                                child: TextField(
                                  controller: iconCodeCtrl,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              if(addMode) {
                                ///add
                                await mainController.addNewFreeTextField({
                                  'key': labelToKey(labelCtrl.text),
                                  'label': labelCtrl.text,
                                  'type': typeCtrl.text,
                                  'hint': hintCtrl.text,
                                  'icon_code': iconCodeCtrl.text
                                });
                                const snackBar = SnackBar(
                                  content: Text(
                                    'Free Text Field Added!',
                                    style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                Get.back();
                              } else {
                                ///update
                              }

                            },
                            child:  Text(addMode?'Add':'Update')),
                        ElevatedButton(
                            onPressed: () {
                              /// print('Cancel');
                              Get.back();
                            },
                            child: const Text('Cancel')),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    !addMode?ElevatedButton(
                        onPressed: () async {
                          /// remove free text tag
                          if (labelCtrl.text=='') return;
                          /// dialog
                          bool? res = await showDialog<bool>(
                              context:
                              context,
                              builder: (BuildContext context) => ConfirmDialog(tag: (labelCtrl.text))
                          );
                          if (res??false) {
                            await mainController.removeFreeTextTag(labelCtrl.text, templateId);
                            setState(() {
                              /// remove local
                              mainController.freeTextTagsList;
                            });
                          }
                        },
                        child:  const Text('Remove Tag', style: TextStyle(color: Colors.red),)):const SizedBox.shrink(),
                    mainController.saving.value?const CircularProgressIndicator():const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final mainController = Get.put(MainController());
  TextEditingController newMemberThresholdInMonthsCtrl = TextEditingController();
  TextEditingController numberOfRandomResultsCtrl = TextEditingController();

  TextEditingController newMemberScoreCtrl = TextEditingController();
  TextEditingController birthdayScoreCtrl = TextEditingController();
  TextEditingController socialScoreCtrl = TextEditingController();
  TextEditingController profileImageScoreCtrl = TextEditingController();
  TextEditingController topThresholdCtrl = TextEditingController();
  TextEditingController bottomThresholdCtrl = TextEditingController();




  bool profileScoreEditModeOn = false;

  @override
  void initState() {
    super.initState();
    newMemberThresholdInMonthsCtrl.text = mainController.newMemberThreshold.toString();
    numberOfRandomResultsCtrl.text = mainController.numberOfRandomMembers.toString();
    newMemberScoreCtrl.text = mainController.profileScore.newMemberScore.toString();
    birthdayScoreCtrl.text =  mainController.profileScore.birthdayScore.toString();
    socialScoreCtrl.text = mainController.profileScore.socialScore.toString();
    profileImageScoreCtrl.text = mainController.profileScore.profileImageScore.toString();
    topThresholdCtrl.text =  mainController.profileScore.topThreshold.toString();
    bottomThresholdCtrl.text = mainController.profileScore.bottomThreshold.toString();
  }
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 125,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Column(
              children: [
                Image.network(scale: 2, 'assets/images/logo-insider.png'),
                Text('Administrator', style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// title
                  Center(child: Text('Settings', style: TextStyle(fontSize: 32, color: Colors.blue.shade900, fontWeight: FontWeight.bold),)),
                  /// Profile Score
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right:30, top: 20, bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100, // Background color
                        // border: Border.all(color: Colors.red, width: 1), // Border
                        borderRadius: BorderRadius.circular(50), // Rounded corners
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              'Profile Score Settings',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          /// profile image score
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 4, bottom: 4),
                            child: Row(
                              children: [
                                const Text('Profile Image Score:',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller: profileImageScoreCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// new member score
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 4 ,bottom: 4),
                            child: Row(
                              children: [
                                const Text('New Member Score:',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller:
                                        newMemberScoreCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// birthday score
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 4 ,bottom: 4),
                            child: Row(
                              children: [
                                const Text('Birthday Score:',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller:
                                        birthdayScoreCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// social score
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 4 ,bottom: 4),
                            child: Row(
                              children: [
                                const Text('social Score:',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller:
                                        socialScoreCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// top threshold
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 4 ,bottom: 4),
                            child: Row(
                              children: [
                                const Text('Top Threshold:',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller: topThresholdCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// bottom threshold
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 4 ,bottom: 4),
                            child: Row(
                              children: [
                                const Text('Bottom Threshold:',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller: bottomThresholdCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// actions
                          profileScoreEditModeOn
                              ? Padding(
                            padding:
                            const EdgeInsets.only(left: 18.0, top: 50, bottom: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      /// print('save data');
                                      setState(() {
                                        mainController.saving.value = true;
                                      });
                                      await mainController.updateProfileScoreSettings(
                                        birthdayScore: int.parse(birthdayScoreCtrl.text),
                                        profileImageScore: int.parse(profileImageScoreCtrl.text),
                                        newMemberScore: int.parse(newMemberScoreCtrl.text),
                                        socialScore: int.parse(socialScoreCtrl.text),
                                        topThreshold: int.parse(topThresholdCtrl.text),
                                        bottomThreshold: int.parse(bottomThresholdCtrl.text)
                                      );
                                      const snackBar = SnackBar(
                                        content: Text(
                                          'Profile Score Settings Saved!',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      setState(() {
                                        mainController.saving.value = false;
                                        profileScoreEditModeOn = false;

                                      });
                                    },
                                    child: const Text('Save')),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        profileScoreEditModeOn = false;
                                      });
                                    },
                                    child: const Text('Cancel')),
                              ],
                            ),
                          )
                              : Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 50, bottom: 50),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    profileScoreEditModeOn = true;
                                  });
                                },
                                child: const Text('Edit')),
                          ),
                          mainController.saving.value
                            ?LinearProgressIndicator(color: Colors.blue.shade900)
                              : SizedBox.shrink()
              
                          /// Save and Cancel
                        ],
                      ),
                    ),
                  ),
                  /// results page
                  Padding(
                    padding:  const EdgeInsets.only(left: 30, right:30, top: 20, bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100, // Background color
                        // border: Border.all(color: Colors.red, width: 1), // Border
                        borderRadius: BorderRadius.circular(50), // Rounded corners
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              'Results Page Settings',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 20),
                            child: Row(
                              children: [
                                const Text('New Member Threshold in Months:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller:
                                            newMemberThresholdInMonthsCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 18.0, top: 20, bottom: 50),
                            child: Row(
                              children: [
                                Text('Number Of Random Results:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        enabled: profileScoreEditModeOn?true:false,
                                        controller: numberOfRandomResultsCtrl,
                                      )),
                                )
                              ],
                            ),
                          ),
                          /// actions
                          profileScoreEditModeOn
                              ? Padding(
                            padding:
                            const EdgeInsets.only(left: 18.0, top: 50, bottom: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      /// print('save data');
                                      // mainController.(firstNameCtrl.text, lastNameCtrl.text, emailCtrl.text);
                                      const snackBar = SnackBar(
                                        content: Text(
                                          'Settings Saved!',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      Get.back();
                                    },
                                    child: const Text('Save')),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        profileScoreEditModeOn = false;
                                      });
                                    },
                                    child: const Text('Cancel')),
                              ],
                            ),
                          )
                              : Padding(
                                padding: const EdgeInsets.only(left: 18.0, top: 50, bottom: 50),
                                child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    profileScoreEditModeOn = true;
                                  });
                                },
                                child: const Text('Edit')),
                              )
              
                          /// Save and Cancel
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ManageFilterTags extends StatefulWidget {
  const ManageFilterTags({
    super.key,
  });

  @override
  _ManageFilterTagsState createState() => _ManageFilterTagsState();
}

class _ManageFilterTagsState extends State<ManageFilterTags> {
  final mainController = Get.put(MainController());
  late List filtersCategory;
  List<String> tags = [];
  bool editMode = false;
  bool delMode = false;
  final ScrollController tagsScrollCtrl = ScrollController();

  // Function to scroll to the end
  void _scrollToEnd() {
    tagsScrollCtrl.animateTo(
      tagsScrollCtrl.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  // Function to scroll immediately to the end
  void _jumpToEnd() {
    tagsScrollCtrl.jumpTo(tagsScrollCtrl.position.maxScrollExtent);
  }

  List<String> getSelectedTagsInCategory(
      tagsInCategory, List<String> selectedTags) {
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
    filtersCategory = mainController.filteredTagsList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(BorderSide(width: 0.5)),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(200),
                topLeft: Radius.circular(200),
              ),
              color: Color(0xff2e4074),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: IconButton(
                        iconSize: 40,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 50),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListView(
                          controller: tagsScrollCtrl,
                          children: List.generate(
                              filtersCategory.length,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                        top: 8,
                                        bottom: 10),
                                    child: SizedBox(
                                      width: 800,
                                      child:
                                          (mainController.filteredTagsList[
                                                          index]['key'] !=
                                                      'residence' &&
                                                  mainController
                                                              .filteredTagsList[
                                                          index]['key'] !=
                                                      'forum')
                                              ? Card(
                                                  color: Colors.blue.shade900,
                                                  elevation: 10,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// actions and Title
                                                      ListTile(
                                                        trailing: SizedBox(
                                                          width: 130,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              /// del tags mode
                                                              Obx(() => mainController
                                                                  .saving
                                                                  .value
                                                                  ? const CircularProgressIndicator()
                                                                  : IconButton(
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                            () {
                                                                          delMode =
                                                                          !delMode;
                                                                        });
                                                                  },
                                                                  icon:
                                                                  Icon(
                                                                    delMode
                                                                        ? null
                                                                        : !editMode
                                                                          ? Icons.delete
                                                                          : null,
                                                                    color: Colors
                                                                        .white,
                                                                  ))
                                                              ),
                                                              /// edit tags
                                                              Obx(() => mainController
                                                                      .saving
                                                                      .value
                                                                  ? const CircularProgressIndicator()
                                                                  : IconButton(
                                                                      onPressed:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          editMode =
                                                                              !editMode;
                                                                        });
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        editMode
                                                                            ? null
                                                                            : !delMode
                                                                              ? Icons.edit
                                                                              : null,
                                                                        color: Colors
                                                                            .white,
                                                                      ))
                                                              ),
                                                              /// add tag
                                                              Obx(() => mainController
                                                                      .saving
                                                                      .value
                                                                  ? CircularProgressIndicator()
                                                                  : IconButton(
                                                                      onPressed:
                                                                          () async {
                                                                        if (editMode || delMode) {
                                                                          setState(() {
                                                                            editMode=false;
                                                                            delMode=false;
                                                                          });
                                                                          return;
                                                                        }
                                                                        String? res = await showDialog<String>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                FilterEntryDialog(category: mainController.filteredTagsList[index]['label']));
                                                                        if (res !=
                                                                            null) {
                                                                          await mainController.addNewFilterTag(
                                                                              mainController.filteredTagsList[index]['label'],
                                                                              res);
                                                                          setState(
                                                                              () {
                                                                            mainController.filteredTagsList[index]['tags_list'].add(res);
                                                                          });
                                                                        }
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                            editMode||delMode
                                                                                ? Icons.close
                                                                                : Icons.add,
                                                                        color: Colors
                                                                            .white,
                                                                      )))
                                                            ],
                                                          ),
                                                        ),
                                                        /// title
                                                        title: Row(
                                                          children: [
                                                            Text(
                                                              mainController
                                                                      .filteredTagsList[
                                                                  index]['label'],
                                                              style: const TextStyle(
                                                                  color:
                                                                      Colors.white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            IconButton(
                                                                onPressed: () async {
                                                                  /// dialog
                                                                  bool? res = await showDialog<bool>(
                                                                      context:
                                                                      context,
                                                                      builder: (BuildContext context) =>
                                                                          ConfirmDialog(tag: mainController.filteredTagsList[index]['label'])
                                                                  );
                                                                  if (res??false) {
                                                                    await mainController.removeFilterTagCategory(mainController.filteredTagsList[index]['label']);
                                                                    setState(() {
                                                                      /// remove the category
                                                                      mainController.filteredTagsList.removeAt(index);
                                                                    });
                                                                  }
                                                                },
                                                                icon:
                                                                Icon(
                                                                  delMode && mainController.filteredTagsList[index]['tags_list'].length<=0
                                                                      ? Icons.delete
                                                                      : null,
                                                                  color: Colors
                                                                      .white,
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Wrap(
                                                          runSpacing: 8,
                                                          spacing: 8,
                                                          children: List.generate(
                                                              mainController.filteredTagsList[index]['tags_list'].length,
                                                              (tagIndex) => ChoiceChip(
                                                                  onSelected: (val) async {
                                                                    if (editMode) {
                                                                      /// dialog
                                                                      String? res = await showDialog<String>(
                                                                          context:
                                                                          context,
                                                                          builder: (BuildContext context) =>
                                                                              EditFilterEntryDialog(tag: mainController.filteredTagsList[index]['tags_list'][tagIndex]));
                                                                      if (res != null) {
                                                                        await mainController.updateFilterTag(mainController
                                                                            .filteredTagsList[
                                                                        index]['label'],
                                                                            mainController.filteredTagsList[index]['tags_list'][tagIndex],
                                                                          res
                                                                        );
                                                                        setState(() {
                                                                          mainController.filteredTagsList[index]['tags_list'][tagIndex]=res;
                                                                        });
                                                                      }
                                                                    }
                                                                    else if (delMode) {
                                                                      /// dialog
                                                                      bool? res = await showDialog<bool>(
                                                                          context:
                                                                          context,
                                                                          builder: (BuildContext context) =>
                                                                              ConfirmDialog(tag: mainController.filteredTagsList[index]['tags_list'][tagIndex])
                                                                      );
                                                                      if (res??false) {
                                                                        await mainController.removeFilterTag(mainController.filteredTagsList[index]['label'],
                                                                            mainController.filteredTagsList[index]['tags_list'][tagIndex]
                                                                        );
                                                                        setState(() {
                                                                          /// remove the tag
                                                                          mainController.filteredTagsList[index]['tags_list'].removeAt(tagIndex);
                                                                        });
                                                                      }
                                                                    }
                                                                  },
                                                                  avatar: editMode
                                                                      ? const Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color:
                                                                              Colors.green,
                                                                        )
                                                                      : delMode
                                                                        ? const Icon(
                                                                    Icons
                                                                        .remove_circle_outline_sharp,
                                                                    color:
                                                                    Colors.red,
                                                                  )
                                                                        : null,
                                                                  selectedColor: Colors.white,
                                                                  showCheckmark: false,
                                                                  label: Text(mainController.filteredTagsList[index]['tags_list'][tagIndex]),
                                                                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, overflow: TextOverflow.clip),
                                                                  selected: true)),
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
                        ),
                      ),
                    ),
                    /// Add new filter category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          //iconSize: 40,
                          onPressed: () async {
                            /// dialog
                            String? res = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => const AddNewFilterCategoryDialog());
                            if (res != null) {
                              /// add Filter Category
                              mainController.addNewFilterTagCategory(res,'');
                              _scrollToEnd();
                              setState(() {

                              });
                            }
                          },
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                        ),
                        Text('Add a new Filter Tag Category' , style: TextStyle(fontSize: 12, color: Colors.white),)
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ]),
            ),
          ),
        ));
  }
}




///
class FilterEntryDialog extends StatelessWidget {
  final String category;
  final double? fieldWidth;
  const FilterEntryDialog(
      {super.key, this.fieldWidth = 200, required this.category});

  @override
  Widget build(BuildContext context) {
    TextEditingController newTagCtrl = TextEditingController();
    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 80.0, top: 20),
      title: const Text('Add Entry'),
      content: SizedBox(
        width: 500,
        height: 100,
        child: Column(
          children: [
            Text('Add a new Tag to the $category category'),
            SizedBox(
              height: 10,
            ),
            TextField(
                controller: newTagCtrl,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 8, right: 8, top: 5, bottom: 8),
                  isCollapsed: true,
                  labelText: 'new $category tag',
                  //helperText: helperText:'',
                  //hintText:   widget.hintText,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ))
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, newTagCtrl.text),
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
///
class EditFilterEntryDialog extends StatelessWidget {
  final String tag;
  final double? fieldWidth;
  const EditFilterEntryDialog(
      {super.key, this.fieldWidth = 200, required this.tag});

  @override
  Widget build(BuildContext context) {
    TextEditingController newTagCtrl = TextEditingController(text: tag);
    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 80.0, top: 20),
      title: const Text('Edit Filter Tag'),
      content: SizedBox(
        width: 500,
        height: 100,
        child: Column(
          children: [
            //Text('Add a new Tag to the $category category'),
            SizedBox(
              height: 10,
            ),
            TextField(
                controller: newTagCtrl,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 8, right: 8, top: 5, bottom: 8),
                  isCollapsed: true,
                  labelText: 'edit tag',
                  //helperText: helperText:'',
                  //hintText:   widget.hintText,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ))
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, newTagCtrl.text),
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
///
class AddNewFilterCategoryDialog extends StatelessWidget {
  const AddNewFilterCategoryDialog(
      {super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController newFilterTagCategoryCtrl = TextEditingController();
    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 80.0, top: 20),
      title: const Text('Add a New Filter Tag Category'),
      content: SizedBox(
        width: 500,
        height: 100,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text('Label/Name of Category:'),
            SizedBox(
              height: 4,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                  controller: newFilterTagCategoryCtrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                        left: 8, right: 8, top: 5, bottom: 8),
                    isCollapsed: true,
                    labelText: 'Category Name',
                    //helperText: helperText:'',
                    //hintText:   widget.hintText,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  )),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, newFilterTagCategoryCtrl.text),
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
///
class ConfirmDialog extends StatelessWidget {
  final String tag;
  const ConfirmDialog(
      {required this.tag, super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController newFilterTagCategoryCtrl = TextEditingController();
    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 80.0, top: 20),
      title: const Text('Approve Removal'),
      content: SizedBox(
        width: 500,
        height: 100,
        child:  Column(
          children: [
            Text('Are you sure you want to delete $tag?'),
            const Text('This will permanently remove this tag from all members!')
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}