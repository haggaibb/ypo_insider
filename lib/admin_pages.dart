import 'package:flutter/material.dart';
import 'members_controller.dart';
import 'main_controller.dart';
import 'package:get/get.dart';
import 'package:chips_choice/chips_choice.dart';

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
          backgroundColor: Colors.white,
          body: SizedBox(
            width: 350,
            height: 750,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.network(
                  'assets/images/logo-insider.png',
                  height: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Add a new YPO member',
                  style: TextStyle(fontSize: 24),
                ),
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
                          Get.back();
                        },
                        child: Text('Save')),
                    ElevatedButton(
                        onPressed: () {
                          /// print('Cancel');
                          Get.back();
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
          backgroundColor: Colors.white,
          body: SizedBox(
            width: 350,
            height: 500,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.network(
                  'assets/images/logo-insider.png',
                  height: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Add a new Residence/City',
                  style: TextStyle(fontSize: 24),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('Residence name:',
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
                          Get.back();
                        },
                        child: const Text('Save')),
                    ElevatedButton(
                        onPressed: () {
                          /// print('Cancel');
                          Get.back();
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
          backgroundColor: Colors.white,
          body: SizedBox(
            width: 350,
            height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.network(
                  'assets/images/logo-insider.png',
                  height: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Add a new Forum',
                  style: TextStyle(fontSize: 24),
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
                          Get.back();
                        },
                        child: Text('Save')),
                    ElevatedButton(
                        onPressed: () {
                          /// print('Cancel');
                          Get.back();
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
    );
  }
}

class AddNewFreeText extends StatelessWidget {
  const AddNewFreeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController fieldNameCtrl = TextEditingController();
    TextEditingController typeCtrl = TextEditingController();
    TextEditingController hintCtrl = TextEditingController();
    TextEditingController iconCodeCtrl = TextEditingController();
    final mainController = Get.put(MainController());

    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: 350,
            height: 800,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.network(
                  'assets/images/logo-insider.png',
                  height: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Add a new Free Text Field',
                  style: TextStyle(fontSize: 24),
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
                              controller: fieldNameCtrl,
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
                                    label: 'Text Field (1-Line)'),
                                DropdownMenuEntry(
                                    value: 'link',
                                    label: 'Link Field (1-Line)'),
                                DropdownMenuEntry(
                                    value: 'textbox',
                                    label: 'Text Box (multi-Line)')
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
                          await mainController.addNewFreeTextField({
                            'key': fieldNameCtrl.text,
                            'label': fieldNameCtrl.text,
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
                          Get.back();
                        },
                        child: const Text('Save')),
                    ElevatedButton(
                        onPressed: () {
                          /// print('Cancel');
                          Get.back();
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
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mainController = Get.put(MainController());
    TextEditingController newMemberThresholdInMonthsCtrl =
        TextEditingController();
    TextEditingController numberOfRandomResultsCtrl = TextEditingController();
    newMemberThresholdInMonthsCtrl.text =
        mainController.newMemberThreshold.toString();
    numberOfRandomResultsCtrl.text =
        mainController.numberOfRandomMembers.toString();
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox(
              width: 350,
              height: 750,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.network(
                    'assets/images/logo-insider.png',
                    height: 70,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.blueGrey.shade100,
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
                              const Text('New Member Thresholds in Months:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: TextField(
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
                                      controller: numberOfRandomResultsCtrl,
                                    )),
                              )
                            ],
                          ),
                        ),

                        /// Save and Cancel
                      ],
                    ),
                  ),
                  Padding(
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
                              Get.back();
                            },
                            child: Text('Save')),
                        ElevatedButton(
                            onPressed: () {
                              /// print('Cancel');
                              Get.back();
                              Get.back();
                            },
                            child: Text('Cancel')),
                      ],
                    ),
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
                          children: List.generate(
                              filtersCategory.length,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        right: 30.0,
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
                                                      ListTile(
                                                        trailing: SizedBox(
                                                          width: 100,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
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
                                                                            ? Icons.close
                                                                            : Icons.edit,
                                                                        color: Colors
                                                                            .white,
                                                                      ))),

                                                              /// add tag
                                                              Obx(() => mainController
                                                                      .saving
                                                                      .value
                                                                  ? CircularProgressIndicator()
                                                                  : IconButton(
                                                                      onPressed:
                                                                          () async {
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
                                                                          const Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Colors
                                                                            .white,
                                                                      )))
                                                            ],
                                                          ),
                                                        ),
                                                        title: Text(
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
                                                                  },
                                                                  avatar: editMode
                                                                      ? const Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color:
                                                                              Colors.green,
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
