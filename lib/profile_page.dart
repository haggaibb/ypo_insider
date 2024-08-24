import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:ypo_connect/models.dart';
import 'profile_menu.dart';
import 'ctx.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:get/get.dart';
import 'utils.dart';

class ProfilePage extends StatelessWidget {
  final Member member;
  ProfilePage(this.member, {super.key});
  final controller = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              icon: Icon(Icons.arrow_back)),
          title: Text(member.fullName(), style: TextStyle(fontSize: 24)),
          //actions: [IconButton(onPressed: () {}, icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode))],
        ),
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// -- IMAGE
                  Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: member.profileImage != null
                                ? Image.network(member.profileImage!)
                                : Image(
                                    image: AssetImage('images/profile0.jpg'))),
                      ),
                      // add logic to add a badge to pic to indicate an issue or something
                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: Container(
                      //     width: 35,
                      //     height: 35,
                      //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.blue),
                      //     child: const Icon(
                      //       LineAwesomeIcons.access_alarms,
                      //       color: Colors.black,
                      //       size: 20,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(member.title, style: TextStyle(fontSize: 20)),
                  Text(member.residence, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),

                  /// -- BUTTON EDIT -- Only when Member.
                  // SizedBox(
                  //   width: 200,
                  //   child: ElevatedButton(
                  //     onPressed: () => (),
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                  //     child: const Text('עריכה', style: TextStyle(color: Colors.black)),
                  //   ),
                  // ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  /// -- MENU
                  ProfileMenuWidget(
                      title: "Mobile: ",
                      icon: Icons.mobile_screen_share,
                      value: member.mobile,
                      onPress: () {}),
                  ProfileMenuWidget(
                      title: "Email: ",
                      icon: Icons.mail,
                      value: member.email,
                      onPress: () {}),
                  ProfileMenuWidget(
                      title: "Forum: ",
                      icon: Icons.group,
                      value: member.forum.toString(),
                      onPress: () {}),
                  const Divider(),
                  const SizedBox(height: 10),
                  Column(
                      children: List.generate(
                          controller.freeTextTagsList.length, (index) {
                    return ProfileMenuWidget(
                        title:
                            controller.freeTextTagsList[index]['label'] + ': ',
                        icon: Icons.info,
                        value: member.freeTextTags!=null
                            ?member.freeTextTags![controller.freeTextTagsList[index]['key']]:'',
                        onPress: () {});
                  })),
                  const Divider(),
                  const SizedBox(height: 10),
                  Column(
                    children: List.generate(
                        controller.filteredTagsList.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 10, bottom: 10),
                              child: SizedBox(
                                //height: 200,
                                width: 800,
                                child: Card(
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
                                                 ChoiceChip(
                                                   label: Text(controller
                                                       .filteredTagsList[index]['tags_list'][tagIndex]),
                                                   labelStyle: TextStyle(
                                                       fontWeight: FontWeight.bold, color: Colors.black),
                                                   selected: member.hasFilteredTag(
                                                       controller
                                                           .filteredTagsList[index]['key'],
                                                       controller
                                                           .filteredTagsList[index]['tags_list'][tagIndex]
                                                   )
                                                 )
                                             ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
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
