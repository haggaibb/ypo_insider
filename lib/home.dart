
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';
import 'filters.dart';
import 'ctx.dart';
import 'results_page.dart';
import 'package:get/get.dart';
import 'widgets.dart';


class Home extends StatefulWidget {
  const Home({super.key, required this.title,this.user});

  final String title;
  final User? user;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //final user = FirebaseAuth.instance.currentUser;
  List selectedFiltersList = [];
  SheetController sheetController = SheetController();
  final controller = Get.put(Controller());
  var minSheetPos = 85.0;
  var openSheetPos = 600.0;
  var initSheetPos = 85.0;

  void sheetJumpFunction(){
    sheetController.offset<=initSheetPos
        ? sheetController.animateTo(openSheetPos, duration: const Duration(milliseconds: 500), curve: Curves.easeIn)
        : sheetController.animateTo(initSheetPos, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Obx(()=> (controller.currentMember.value.id == 'NA')
        ? Center(child: Text('Invalid Access!!!'))
        : Directionality(
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
    );
    return Directionality(
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
    );
  }
}

