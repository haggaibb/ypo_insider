import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:ypo_connect/models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'dart:html' as html;
import 'RayBarFields.dart';

class ResultCard extends StatefulWidget {
  final Member member;

  const ResultCard(
    this.member, {
    super.key,
  });

  @override
  _ResultCardState createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.blue.shade900,
      //color : Colors.white,
      elevation: 10,
      child: Column(
        children: [
          Text(
            widget.member.fullName(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6),
                      child: SizedBox(
                        width: 230,
                        height: 20,
                        child: Text(
                          widget.member.currentTitle,
                          //overflow: TextOverflow.fade,
                          //softWrap: false,
                          maxLines: 2,
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6),
                      child: SizedBox(
                        width: 230,
                        child: Text(
                          widget.member.currentBusinessName,
                          //overflow: TextOverflow.ellipsis,
                          //softWrap: false,
                          maxLines: 2,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 6),
                    child: Text(widget.member.residence),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Forum  ${widget.member.forum}'),
                  ),
                ],
              ),
              Column(
                children: [
                  ProfilePic(widget.member.profileImage ?? ''),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                        width: 90,
                        height: 20,
                        child: SocialBar(
                            linkedin: widget.member.linkedin,
                            instagram: widget.member.instagram,
                            facebook: widget.member.facebook)),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
/////////////////
////////////////

class ProfilePic extends StatelessWidget {
  const ProfilePic(
    this.uri, {
    super.key,
  });

  final String uri;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: uri != ''
                  ? Image.network(uri)
                  : Image(
                      image:
                          AssetImage(uri != '' ? uri : 'images/profile0.jpg'))),
        ),
      ],
    );
  }
}

///
///
///
class ProfileAppDrawer extends StatelessWidget {
  const ProfileAppDrawer(this.member, {super.key});
  final Member member;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  member.fullName(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  member.email,
                  style: TextStyle(fontSize: 14),
                ),
                Text('Forum ' + member.forum.toString() ?? 'Not in a Forum',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          ProfilePic(member.profileImage ?? '')
        ],
      ),
    );
  }
}

class MainLoading extends StatelessWidget {
  const MainLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Image.network('assets/images/logo.png', width: 200, height: 200,),
          ),
          SpinKitRotatingCircle(
            color: Colors.blue.shade900,
            size: 80.0,
          ),
        ],
      ),
    );
  }
}

class ResultsLoading extends StatelessWidget {
  final String statusMsg;
  const ResultsLoading({super.key, this.statusMsg=''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(80.0),
            child: SpinKitThreeInOut(
              color: Colors.blue.shade900,
              size: 80.0,
            ),
          ),
          Text(statusMsg)
        ],
      ),
    );
  }
}

class ProfileImageLoading extends StatelessWidget {
  const ProfileImageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SpinKitThreeInOut(
          color: Colors.blue.shade900,
          size: 30.0,
        ),
      ),
    );
  }
}

///
///
/// open url in browser
Future<void> _launchInBrowser(String url) async {
  print(url);
  final Uri _url = Uri.parse(url);
  if (!await launchUrl(
    webOnlyWindowName: '_blank',
    _url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $_url');
  }
}

/// send email
void _launchMailClient(String targetEmail) async {
  String mailUrl = 'mailto:$targetEmail';
  try {
    await launchUrlString(mailUrl);
  } catch (e) {}
}

///
///
class SocialBar extends StatelessWidget {
  final String? linkedin;
  final String? instagram;
  final String? facebook;
  const SocialBar({Key? key, this.linkedin, this.instagram, this.facebook})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// linkedin
        linkedin != ''
            ? InkWell(
                onTap: () async {
                  html.window.open(linkedin!, 'new tab');
                  //await _launchInBrowser(linkedin!);
                },
                child: Image.asset('images/linkedin.png'),
              )
            : Image.asset('images/linkedin.png', color: Colors.grey,  colorBlendMode: BlendMode.saturation,),

        /// instagram
        instagram != ''
            ? InkWell(
                onTap: () async {
                  html.window.open(instagram!, 'new tab');
                  //await _launchInBrowser(instagram!);
                },
                child: Image.asset('images/instagram.png'),
              )
            : Image.asset('images/instagram.png', color: Colors.grey, colorBlendMode: BlendMode.saturation,),

        /// facebook
        facebook != ''
            ? InkWell(
                onTap: () async {
                  html.window.open(facebook!, 'new tab');
                  //await _launchInBrowser(facebook!);
                },
                child: Image.asset('images/facebook.png'),
              )
            : Image.asset('images/facebook.png', color: Colors.grey, colorBlendMode: BlendMode.saturation,),
      ],
    );
  }
}

///
///
class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.onPress,
      this.type});

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onPress;
  final String? type;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? Colors.blue : Colors.greenAccent;
    return Column(
        children: [
      Row(children: [
        Icon(icon, color: Colors.blue.shade900,),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        type == 'text'
            ? Text(
                value,
                maxLines: 1,
                 style: TextStyle(fontSize: 18),
              )
            : type == 'link'
                ? GestureDetector(
                    onTap: () => html.window.open(value, 'new tab'),//_launchInBrowser(value),
                    child: SizedBox(
                      width: 180,
                      child: Text(value,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: TextStyle(fontSize: 18,color: Colors.blue)),
                    ))
                : type == 'email'
                    ? GestureDetector(
                         onTap: () => {},
                        //onTap: () => _launchMailClient(value),
                        child: Text(
                          value,
                          maxLines: 1,
                          style: TextStyle(fontSize: 18),
                        ))
                    : const SizedBox(width: 1),
      ]),
      type == 'textbox'
          ? SizedBox(
              height: (value.length / 50 * 40)>50?(value.length / 50 * 40):50,
              width: 350,
              child: Text(
                value,
                maxLines: 3, style: TextStyle(fontSize: 18)
              ))
          : SizedBox(width: 1),
    ]);
  }
}
///
class Goodbye extends StatelessWidget {

  const Goodbye({super.key, });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('assets/images/logo-insider.png'),
          Text('Goodbye', style : TextStyle(fontSize: 24, color: Colors.blue.shade900)),
        ],
      ),
    );
  }
}



class TestPage extends StatefulWidget {
  TestPage({super.key, });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TextEditingController controller = TextEditingController();

  final TextEditingController textBoxController = TextEditingController();

  final TextEditingController dropController = TextEditingController();

  bool editMode = true;

  @override
  Widget build(BuildContext context) {
    dropController.text='Tel Aviv';
    controller.text = 'http://www.google.com';
    textBoxController.text = 'Ther is a way to do this this is not the way, I think this is long, not sure, Ther is a way to do this this is not the way, I think this is long, not sure';
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    ElevatedButton(
                        onPressed:() {
                          setState(() {
                            editMode=!editMode;
                          });
                        },
                        child: Text('Toggle')
                    ),
                    SizedBox(height: 20,),
                    RayBarTextField(
                      //padding: EdgeInsets.only(bottom: 20),
                      controller: controller,
                      label: 'Residence',
                      lines: Lines.single,
                      enableIcon: true,
                      icon:  Icons.house_outlined,
                      editMode: editMode,
                      type: FieldType.link,
                      helperText: 'This is a helper text line.',
                      hintText: 'http://...',
                      fieldWidth: 250,
                    ),
                    RayBarTextField(
                      //padding: EdgeInsets.only(bottom: 20),
                      controller: textBoxController,
                      label: 'Overview',
                      lines: Lines.multi,
                      maxLines: 3,
                      editMode: editMode,
                      helperText: 'please feel a few lines...',
                      hintText: 'Enter free text',
                      fieldWidth: 250,
                      enableIcon: true,
                      icon:  Icons.text_snippet_outlined,
                    ),
                    // RayBarMultiChipMenu(
                    //     tags: ['Tel Aviv','Herzliya','Ramat Hasharon'],
                    //     label: 'Residence:',
                    //     selectedTags: [],
                    //     editMode: editMode
                    // ),
                    RayBarTextField(
                      //padding: EdgeInsets.only(bottom: 20),
                      controller: controller,
                      label: 'Residence',
                      lines: Lines.single,
                      enableIcon: true,
                      icon:  Icons.house_outlined,
                      editMode: editMode,
                      type: FieldType.text,
                      fieldWidth: 250,

                    ),
                    RayBarTextField(
                      //padding: EdgeInsets.only(bottom: 20),
                      controller: controller,
                      label: 'Residence',
                      lines: Lines.single,
                      enableIcon: true,
                      icon:  Icons.house_outlined,
                      editMode: editMode,
                      type: FieldType.text,
                      fieldWidth: 250,



                    ),
                    RayBarDropdownMenu(
                      //padding: EdgeInsets.only(bottom: 20),
                      controller: dropController,
                      label: 'Residence',
                      enableIcon: true,
                      icon:  Icons.house_outlined,
                      editMode: editMode,
                      type: FieldType.text,
                      //fieldWidth: 250,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'Tel Aviv', label: 'Tel Aviv'),
                        DropdownMenuEntry(value: 'Ramat Hashron', label: 'Ramat Hashron'),
                        DropdownMenuEntry(value: 'Herzlia', label: 'Herzlia'),
                      ],

                    ),
                    RayBarMultiChipMenu(
                        tags: ['Tel Aviv','Herzliya','Ramat Hasharon'],
                        label: 'Residence:',
                        selectedTags: ['Tel Aviv','Herzliya','Ramat Hasharon'],
                        editMode: editMode,
                      onChange: (selected) {
                          print(selected);
                      },
                    ),
                    RayBarMultiField(
                      keysPerEntry: ['Child Name','Year of Birth'],
                      label: 'Children',
                      editMode: editMode,
                      fieldWidth: 100,
                      icon : Icons.family_restroom_sharp,
                      iconColor : Colors.blue.shade900,
                      onChangeMultiFieldCallback: (data) {
                        print('callback:');
                        print(data);
                      }


                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );


  }
}
