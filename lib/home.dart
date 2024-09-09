import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'package:ypo_connect/profile_page.dart';
import 'filters.dart';
import 'main_controller.dart';
import 'results_page.dart';
import 'package:get/get.dart';
import 'widgets.dart';
import 'package:ypo_connect/members_controller.dart';
import 'package:chips_choice/chips_choice.dart';
import 'theme.dart';
import 'admin_pages.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.user});
  final User? user;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List selectedFiltersList = [];
  SheetController sheetController = SheetController();
  final membersController = Get.put(MembersController());
  final mainController = Get.put(MainController());
  var minSheetPos = 20.0;
  var maxSheetPos = 800.0;
  var openSheetPos = 700.0;
  var initSheetPos = 40.0;

  void sheetJumpFunction() {
    sheetController.offset <= initSheetPos
        ? sheetController.animateTo(openSheetPos,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
        : sheetController.animateTo(initSheetPos,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  void initState() {
    print('init home');
    super.initState();
    if (membersController.currentMember.value.id == 'NA') membersController.setCurrentByUid(widget.user);
    mainController.loadRandomResults(membersController.numberOfMembers);
    setState(() {
      mainController.loadTags(membersController.allMembers);
    });
    print('init home end');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => !membersController.loading.value
        ? GetMaterialApp(
            title: 'Insider',
            theme: InsiderTheme.lightThemeData(context),
            darkTheme: InsiderTheme.darkThemeData(),
            themeMode: membersController.themeMode.value,
            home: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: membersController.themeMode.value.name == 'dark'
                          ? SizedBox(width:1)// TODO replace with logo white
                          : Image.network('assets/images/logo.png'),
                    )
                  ],
                  //backgroundColor: Colors.white,
                  title: Column(
                    children: [
                      Image.network(
                          color:
                              membersController.themeMode.value.name == 'dark'
                                  ? Colors.white
                                  : Colors.blue.shade900,
                          colorBlendMode:
                              membersController.themeMode.value.name == 'dark'
                                  ? BlendMode.srcIn
                                  : null,
                          scale: 2,
                          'assets/images/logo-insider.png'),
                      // const Text(
                      //   'Insider',
                      //   style: TextStyle(
                      //       fontSize: 26, fontWeight: FontWeight.bold),
                      // ),
                      // Obx(() => !membersController.loading.value
                      //     ? Text(
                      //         '${membersController.numberOfMembers} registered members',
                      //         style: const TextStyle(
                      //             fontSize: 12, fontWeight: FontWeight.bold),
                      //       )
                      //     : const SizedBox(
                      //         width: 1,
                      //       )),
                    ],
                  ),
                ),
                drawer: SizedBox(
                  height: 500,
                  child: Drawer(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(75),
                        side:
                            BorderSide(color: Colors.blue.shade900, width: 5)),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: EndDrawerButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ButtonStyle(
                                foregroundColor:
                                membersController.themeMode.value.name == 'dark'
                                    ? MaterialStatePropertyAll<Color>(Colors.white)
                                    : MaterialStatePropertyAll<Color>(Colors.blue.shade700)
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        DrawerHeader(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            //color: Colors.blue.shade50,
                          ),
                          child: Obx(() => ProfileAppDrawer(
                              membersController.currentMember.value)),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                          ),
                          title: const Text('Profile'),
                          onTap: () {
                            Get.to(() => ProfilePage(
                                membersController.currentMember.value));
                          },
                        ),
                        ExpansionTile(
                          //textColor: Colors.blue.shade900,
                          //iconColor: Colors.blue.shade900,
                          leading: const Icon(Icons.settings),
                          trailing:
                              membersController.themeMode.value.name == 'dark'
                                  ? const Icon(Icons.dark_mode)
                                  : Icon(Icons.light_mode),
                          title: Text('Settings'),
                          children: <Widget>[
                            ChipsChoice<ThemeMode>.single(
                              //placeholderStyle: TextStyle(color: Colors.blue.shade900),
                              value: membersController.themeMode.value,
                              onChanged: (val) {
                                setState(() {
                                  membersController.saveThemeMode(val.name);
                                  membersController.themeMode.value = val;
                                  print('change theme mode');
                                  Get.changeTheme(val.name == 'dark'
                                      ? ThemeData.dark()
                                      : ThemeData.light());
                                });
                              },
                              choiceItems: C2Choice.listFrom<ThemeMode,
                                  Map<dynamic, dynamic>>(
                                source: [
                                  {'label': 'Light', 'mode': ThemeMode.light},
                                  {'label': 'Dark', 'mode': ThemeMode.dark},
                                ],
                                value: (index, item) => item['mode']!,
                                label: (index, item) => item['label']!,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        /// new member
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                          ),
                          title: const Text('Add a new Member'),
                          onTap: () {
                            Get.to(() => const AddNewMember()
                            );
                          },
                        ),
                        /// new residence
                        ListTile(
                          leading: const Icon(
                            Icons.house_outlined,
                          ),
                          title: const Text('Add a new Residence'),
                          onTap: () {
                            Get.to(() => const AddNewResidence()
                            );
                          },
                        ),
                        /// new forum
                        ListTile(
                          leading: const Icon(
                            Icons.group_add,
                          ),
                          title: const Text('Add a new Forum'),
                          onTap: () {
                            Get.to(() => const AddNewForum()
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                body: Stack(
                  children: [
                    ResultsPage(),
                    Obx(() => mainController.resultsLoading.value
                        ? ResultsLoading()
                        : Sheet(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            controller: sheetController,
                            minExtent: minSheetPos,
                            maxExtent: maxSheetPos,
                            initialExtent: initSheetPos,
                            fit: SheetFit.expand,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Filters(() => sheetJumpFunction()),
                            ),
                          )),
                  ],
                )
                // This trailing comma makes auto-formatting nicer for build methods.

                ))
        : const MainLoading());
  }
}

/*

class Home extends StatefulWidget {
  const Home({super.key, required this.title,this.user});

  final String title;
  final User? user;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;
  List selectedFiltersList = [];
  SheetController sheetController = SheetController();
  final controller = Get.put(Controller());
  var minSheetPos = 20.0;
  var maxSheetPos = 800.0;
  var openSheetPos = 700.0;
  var initSheetPos = 40.0;

  void sheetJumpFunction(){
    sheetController.offset<=initSheetPos
        ? sheetController.animateTo(openSheetPos, duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
        : sheetController.animateTo(initSheetPos, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  void initState()  {
    super.initState();
    controller.setCurrentUser(user).then((response) {
        controller.themeMode.value = controller.currentMember.value.settings?['theme_mode']=='light'?ThemeMode.light:ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=> (controller.loading.value)
        ? MainLoading()
        : Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          appBar: AppBar(
            actions: [Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.network('assets/images/logo.png'),
            )],
            //backgroundColor: Colors.white,
            title: Column(
              children: [
                const Text('YPO Israel Insider', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
                Obx(() =>!controller.loading.value
                    ?Text('${controller.numberOfMembers} registered members', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)
                    :const SizedBox(width: 1,)
                ),
              ],
            ),
          ),
          drawer: SizedBox(
            height: 500,
            child: Drawer(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: EndDrawerButton(
                      onPressed: () {
                       Navigator.pop(context);
                      },
                      style: ButtonStyle(),
                    ),
                  ),
                  SizedBox(height: 8,),
                  //Image.network('assets/images/logo.png' ,width: 130, height: 130,),
                  DrawerHeader(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      //color: Colors.blue.shade50,
                    ),
                    child: Obx(() => ProfileAppDrawer(controller.currentMember.value)),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left:28.0,top:50),
                  //   child: ListTile(
                  //     title: Text('Screen Mode'),
                  //     subtitle: ChipsChoice<ThemeMode>.single(
                  //       value: controller.themeMode.value,
                  //       onChanged: (val) {
                  //           setState(() {
                  //             controller.themeMode.value = val;
                  //           });
                  //       },
                  //       choiceItems: C2Choice.listFrom<ThemeMode,Map<dynamic, dynamic>>(
                  //         source: [
                  //           { 'label' : 'Light'  , 'mode': ThemeMode.light},
                  //           { 'label' : 'Dark'  ,  'mode'  : ThemeMode.dark},
                  //         ],
                  //         value: (index, item) => item['mode']!,
                  //         label: (index, item) => item['label']!,
                  //       ),
                  //     ),
                  //     onTap: () {
                  //       //Navigator.pushNamed(context, '/profile');
                  //     },
                  //   ),
                  // ),
                  ExpansionTile(
                    leading: Icon(Icons.settings),
                    trailing: controller.themeMode.value.name=='dark'?Icon(Icons.dark_mode):Icon(Icons.light_mode),
                    title: Text('Settings'),
                    children: <Widget>[
                      ChipsChoice<ThemeMode>.single(
                        value: controller.themeMode.value,
                        onChanged: (val) {
                          setState(() {
                            controller.saveThemeMode(val.name);
                            controller.themeMode.value = val;
                          });
                        },
                        choiceItems: C2Choice.listFrom<ThemeMode,Map<dynamic, dynamic>>(
                          source: [
                            { 'label' : 'Light'  , 'mode': ThemeMode.light},
                            { 'label' : 'Dark'  ,  'mode'  : ThemeMode.dark},
                          ],
                          value: (index, item) => item['mode']!,
                          label: (index, item) => item['label']!,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          body: Obx(() =>
          !controller.loading.value?
          Stack(
            children: [
              ResultsPage(),
              Sheet(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                controller: sheetController,
                minExtent: minSheetPos,
                maxExtent: maxSheetPos,
                initialExtent: initSheetPos,
                fit: SheetFit.expand,
                child:  Padding(
                  padding: const EdgeInsets.only( left: 20 , right: 20),
                  child: Filters(()=> sheetJumpFunction()),
                ),
              ),
            ],
          ):MainLoading()
            // This trailing comma makes auto-formatting nicer for build methods.
          )),
    )
    );
  }
}


 */
