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
  var minSheetPos = 45.0;
  var maxSheetPos = 800.0;
  var openSheetPos = 700.0;
  var initSheetPos = 45.0;

  void sheetJumpFunction() {
    sheetController.offset <= initSheetPos
        ? sheetController.animateTo(openSheetPos,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
        : sheetController.animateTo(initSheetPos,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  void initState() {
    super.initState();
    print('init home');
    membersController.loadingStatus.value = 'Loading Insider Home';
    if (membersController.currentMember.value.id == 'NA') membersController.setCurrentByUid(widget.user);
    setState(() {

    });
    print('init home end');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => !mainController.mainLoading.value
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
                          title: const Text('My Profile'),
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
                        membersController.isAdmin.value?ListTile(
                          leading: const Icon(
                            Icons.person,
                          ),
                          title: const Text('Add a new Member'),
                          onTap: () {
                            Get.to(() => const AddNewMember()
                            );
                          },
                        ):SizedBox(),
                        /// new residence
                        membersController.isAdmin.value?ListTile(
                          leading: const Icon(
                            Icons.house_outlined,
                          ),
                          title: const Text('Add a new Residence'),
                          onTap: () {
                            Get.to(() => const AddNewResidence()
                            );
                          },
                        ):SizedBox(),
                        /// new forum
                        membersController.isAdmin.value?ListTile(
                          leading: const Icon(
                            Icons.group_add,
                          ),
                          title: const Text('Add a new Forum'),
                          onTap: () {
                            Get.to(() => const AddNewForum()
                            );
                          },
                        ):SizedBox(),
                      ],
                    ),
                  ),
                ),
                body: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width>600?600: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        ResultsPage(),
                        Obx(() => mainController.mainLoading.value
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
                    ),
                  ),
                )
                // This trailing comma makes auto-formatting nicer for build methods.

                ))
        : MainLoading());
  }
}
