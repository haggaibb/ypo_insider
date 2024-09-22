
import 'package:flutter/material.dart';
import 'members_controller.dart';
import 'main_controller.dart';
import 'package:get/get.dart';


class AddNewMember extends StatelessWidget {

  const AddNewMember({super.key, });


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
                Image.network('assets/images/logo-insider.png' , height: 100,),
                SizedBox(height: 20,),
                Text('Add a new YPO member' , style: TextStyle(fontSize: 24),),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('First Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 200, height: 50, child: TextField(controller: firstNameCtrl,)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('Last Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 200, height: 50, child: TextField(controller: lastNameCtrl,)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('Email:' , style: TextStyle(fontWeight: FontWeight.bold),),
                      Padding(
                        padding: const EdgeInsets.only(left :30.0),
                        child: SizedBox(width: 200, height: 50, child: TextField(controller: emailCtrl,)),
                      )

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left :30.0),
                        child: DropdownMenu(
                          leadingIcon: Icon( Icons.location_city_sharp),
                          label: Text('Residence'),
                          initialSelection: mainController.residenceList[0],
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: false,
                            isDense: true,
                            border:  OutlineInputBorder(
                              //borderSide: BorderSide(color:  Colors.blue),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                            //outlineBorder: BorderSide(color:  Colors.blue),
                          ),
                          dropdownMenuEntries: mainController.residenceList
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
                      border:  OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
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
                    enabled: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          print('save data');
                          await membersController.addNewMember(firstNameCtrl.text, lastNameCtrl.text, emailCtrl.text);
                          const snackBar = SnackBar(
                            content: Text('Member Added!' ,  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Get.back();
                          Get.back();
                        },
                        child: Text('Save')
                    ),
                    ElevatedButton(
                        onPressed: ()  {
                          print('Cancel');
                          Get.back();
                          Get.back();
                        },
                        child: Text('Cancel')
                    ),
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

  const AddNewResidence({super.key, });

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
                Image.network('assets/images/logo-insider.png' , height: 100,),
                SizedBox(height: 20,),
                Text('Add a new Residence/City' , style: TextStyle(fontSize: 24),),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('Residence name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 150, height: 50, child: TextField(controller: residenceCtrl,)),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await mainController.addNewResidence(residenceCtrl.text);
                          const snackBar = SnackBar(
                            content: Text('Residence Added!' ,  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Get.back();
                          Get.back();
                        },
                        child: const Text('Save')
                    ),
                    ElevatedButton(
                        onPressed: ()  {
                          print('Cancel');
                          Get.back();
                          Get.back();
                        },
                        child: const Text('Cancel')
                    ),
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

  const AddNewForum({super.key, });

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
                Image.network('assets/images/logo-insider.png' , height: 100,),
                SizedBox(height: 20,),
                Text('Add a new Forum' , style: TextStyle(fontSize: 24),),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('Forum number/name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 150, height: 50, child: TextField(controller: forumCtrl,)),
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
                            content: Text('Forum Added!' ,  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Get.back();
                          Get.back();
                        },
                        child: Text('Save')
                    ),
                    ElevatedButton(
                        onPressed: ()  {
                          print('Cancel');
                          Get.back();
                          Get.back();
                        },
                        child: Text('Cancel')
                    ),
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

  const AddNewFreeText({super.key, });

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
                Image.network('assets/images/logo-insider.png' , height: 100,),
                SizedBox(height: 20,),
                Text('Add a new Free Text Field' , style: TextStyle(fontSize: 24),),
                ///name
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('field name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 150, height: 50, child: TextField(controller: fieldNameCtrl,)),
                      ),
                    ],
                  ),
                ),
                ///type
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      const Text('field type:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 150, height: 50,
                            child: DropdownMenu(
                              controller: typeCtrl,
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(
                                    value: 'text',
                                    label: 'Text Field (1-Line)'
                                ),
                                DropdownMenuEntry(
                                    value: 'link',
                                    label: 'Link Field (1-Line)'
                                ),
                                DropdownMenuEntry(
                                    value: 'textbox',
                                    label: 'Text Box (multi-Line)'
                                )
                              ],
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                ///hint
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text('hint:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 250, height: 50, child: TextField(controller: hintCtrl,)),
                      ),
                    ],
                  ),
                ),
                ///Icon code
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      const Text('icon code:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(left :12.0),
                        child: SizedBox(width: 150, height: 50, child: TextField(controller: iconCodeCtrl,)),
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
                            'key' : fieldNameCtrl.text,
                            'label' : fieldNameCtrl.text,
                            'type' : typeCtrl.text,
                            'hint' : hintCtrl.text,
                            'icon_code' : iconCodeCtrl.text
                          });
                          const snackBar = SnackBar(
                            content: Text('Free Text Field Added!' ,  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Get.back();
                          Get.back();
                        },
                        child: const Text('Save')
                    ),
                    ElevatedButton(
                        onPressed: ()  {
                          print('Cancel');
                          Get.back();
                          Get.back();
                        },
                        child: const Text('Cancel')
                    ),
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
