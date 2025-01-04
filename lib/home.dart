import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'package:ypo_connect/main.dart';
import 'package:ypo_connect/profile_page.dart';
import 'filters.dart';
import 'main_controller.dart';
import 'results_page.dart';
import 'package:get/get.dart';
import 'widgets.dart';
import 'package:ypo_connect/members_controller.dart';
import 'package:chips_choice/chips_choice.dart';
//import 'theme.dart';
import 'admin_pages.dart';
import 'utils.dart';


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
  var minSheetPos =40.0;
  var maxSheetPos = 850.0;
  var openSheetPos = 700.0;
  var initSheetPos = 100.0;
  final user = FirebaseAuth.instance.currentUser;

  void sheetJumpFunction() {
    double fixedInitSheetPos = mainController.isIOS?initSheetPos+50:initSheetPos;
    sheetController.offset <= fixedInitSheetPos
        ? sheetController.animateTo(openSheetPos,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
        : sheetController.animateTo(fixedInitSheetPos,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  Future<void> _handleRefresh() async {
    await mainController.loadRandomResults(
        mainController
            .numberOfMembers);
  }

  @override
  void initState() {
    super.initState();
    updateSplashScreenText('Loading Insider Home...');
    membersController.loadingStatus.value = 'Loading Insider Home';
    /// print('init home end');
  }

  @override
  Widget build(BuildContext context) {
    if (user!=null) {
      return Obx(() => !mainController.mainLoading.value
          ? Directionality(
            textDirection: TextDirection.ltr,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Scaffold(
              appBar: AppBar(
                leading: mainController.isAdmin.value?null:Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: GestureDetector(
                      child: Image.network('assets/images/logo.png'),
                    onTap: () => Get.to(
                            () => About(version: mainController.version, numberOfMembers: mainController.numberOfMembers.toString(),)
                    , transition: Transition.leftToRightWithFade, duration: Duration(milliseconds: 500)
                    )
                  ),
                ),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                              () => ProfilePage(mainController.currentMember.value)
                          , transition: Transition.rightToLeftWithFade, duration: Duration(milliseconds: 750)
                        );
                      },
                      child: Hero(
                        tag : 'profile_image',
                        child: ClipOval(
                          child: Image.network(
                            mainController.currentMember.value.profileImage!,
                            fit: BoxFit.cover,  // Ensure the image covers the entire area
                          ),
                        ),
                      ),
                    ),
                  )
                ],
                //backgroundColor: Colors.white,
                title: Column(
                  children: [
                    Image.network(
                        color: Colors.blue.shade900,
                        scale: 2,
                        'assets/images/logo-insider.png'),
                  ],
                ),
              ),
              drawer: SizedBox(
                height: mainController.isAdmin.value?700:460,
                child: Drawer(
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(75),
                      side:
                      BorderSide(color: Colors.blue.shade900, width: 5)),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: EndDrawerButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ButtonStyle(
                              foregroundColor: MaterialStatePropertyAll<Color>(Colors.blue.shade700)
                          ),
                        ),
                      ),
                      DrawerHeader(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          //color: Colors.blue.shade50,
                        ),
                        child: Obx(() => ProfileAppDrawer(
                            mainController.currentMember.value)),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                        ),
                        title: const Text('My Profile'),
                        onTap: () {
                          Get.to(() => ProfilePage(
                              mainController.currentMember.value),transition: Transition.zoom);
                        },
                      ),
                      mainController.isAdmin.value?ExpansionTile(
                        //textColor: Colors.blue.shade900,
                        //iconColor: Colors.blue.shade900,
                        leading: const Icon(Icons.settings),
                        trailing:
                        mainController.themeMode.value.name == 'dark'
                            ? const Icon(Icons.dark_mode)
                            : const Icon(Icons.light_mode),
                        title: const Text('Display Settings'),
                        children: <Widget>[
                          ChipsChoice<ThemeMode>.single(
                            //placeholderStyle: TextStyle(color: Colors.blue.shade900),
                            value: mainController.themeMode.value,
                            onChanged: (val) {
                              setState(() {
                                membersController.saveThemeMode(val.name);
                                mainController.themeMode.value = val;
                                /// print('change theme mode');
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
                      ):const SizedBox(),
                      const Divider(),
                      /// About
                      /// Admin pages
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                        ),
                        title: const Text('About'),
                        onTap: () {
                          Get.to(() => About(version: mainController.version, numberOfMembers: mainController.numberOfMembers.toString(),));
                        },
                      ):const SizedBox(),
                      /// new member
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.person,
                        ),
                        title: const Text('Add a new Member'),
                        onTap: () {
                          Get.to(() => const AddNewMember()
                          );
                        },
                      ):const SizedBox(),
                      /// new residence
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.house_outlined,
                        ),
                        title: const Text('Add a new Residence'),
                        onTap: () {
                          Get.to(() => const AddNewResidence()
                          );
                        },
                      ):const SizedBox(),
                      /// new forum
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.group_add,
                        ),
                        title: const Text('Add a new Forum'),
                        onTap: () {
                          Get.to(() => const AddNewForum()
                          );
                        },
                      ):const SizedBox(),
                      /// add Filter Tags
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.filter_list_outlined,
                        ),
                        title: const Text('Manage Filter Tags'),
                        onTap: () {
                          Get.to(() => const ManageFilterTags()
                          );
                        },
                      ):const SizedBox(),
                      /// add free text
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.text_fields,
                        ),
                        title: const Text('Manage Free Text Tags'),
                        onTap: () {
                          Get.to(() => const ManageFreeTextTag()
                          );
                        },
                      ):SizedBox(),
                      /// Settings
                      mainController.isAdmin.value?ListTile(
                        leading: const Icon(
                          Icons.settings,
                        ),
                        title: const Text('General Settings'),
                        onTap: () {
                          Get.to(() => SettingsScreen());
                        },
                      ):const SizedBox(),
                    ],
                  ),
                ),
              ),
              body: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width>600?600: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      const ResultsPage(),
                      Obx(() => mainController.mainLoading.value
                          ? const ResultsLoading()
                          : Sheet(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            controller: sheetController,
                            minExtent: mainController.isIOS?minSheetPos:minSheetPos,
                            maxExtent: maxSheetPos,
                            initialExtent: mainController.isIOS?initSheetPos:initSheetPos,
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
              
                    ),
            ),
          )
          : MainLoading());
    }  else {
      return FrontGate(user: user);
    }

  }
}
