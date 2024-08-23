
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:ypo_connect/models.dart';
import 'profile_menu.dart';
import 'utils.dart';

class ProfileScreen extends StatelessWidget {
  final Member member;
  const ProfileScreen(this.member, {super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back)),
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
                            borderRadius: BorderRadius.circular(100), child: Image(image: AssetImage(member.profileImage!))),
                      ),
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
                  Text(member.residence,  style: TextStyle(fontSize: 16)),
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
                  ProfileMenuWidget(title: "בן/בת זוג", icon: LineAwesomeIcons.cog_solid, onPress: () {}),
                  ProfileMenuWidget(title: "ילדים", icon: LineAwesomeIcons.wallet_solid, onPress: () {}),
                  ProfileMenuWidget(title: "תחביבים", icon: LineAwesomeIcons.user_check_solid, onPress: () {}),
                  const Divider(),
                  const SizedBox(height: 10),
                  ProfileMenuWidget(title: "ביוגרפיה", icon: Icons.view_timeline_outlined, onPress: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}