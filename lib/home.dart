
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'filters.dart';
import 'ctx.dart';
import 'results_page.dart';
import 'package:get/get.dart';
import 'widgets.dart';
import 'package:chips_choice/chips_choice.dart';


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
      print('init Home for member');
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
          drawer: Drawer(
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
                    Icons.settings,
                  ),
                  title: const Text('settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
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
                Padding(
                  padding: const EdgeInsets.only(left:28.0,top:50),
                  child: ListTile(
                    title: Text('Screen Mode'),
                    subtitle: ChipsChoice<ThemeMode>.single(
                      value: controller.themeMode.value,
                      onChanged: (val) {
                          setState(() {
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
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                )
              ],
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

/*
Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          appBar: AppBar(
            actions: [Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.network('assets/images/logo.png'),
            )],
            backgroundColor: Colors.white,
            title: Column(
              children: [
                const Text('YPO Israel Insider', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
                Obx(() =>!controller.loading.value
                    ?Text('${controller.numberOfMembers} registered members', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),)
                    :const SizedBox(width: 1,)
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Obx(() => ProfileAppDrawer(controller.loading.value?controller.noUser:controller.currentMember.value)),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                  ),
                  title: const Text('settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                  ),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                )
              ],
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
                elevation: 10,
                backgroundColor: Colors.black,
                controller: sheetController,
                minExtent: minSheetPos,
                initialExtent: initSheetPos,
                fit: SheetFit.expand,
                child:  Filters(()=> sheetJumpFunction()),
              ),
            ],
          ):MainLoading()
            // This trailing comma makes auto-formatting nicer for build methods.
          )),
    )
 */