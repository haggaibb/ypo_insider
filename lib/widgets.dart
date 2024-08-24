import 'package:flutter/material.dart';
import 'package:ypo_connect/models.dart';
import 'utils.dart';
import 'profile_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResultCard extends StatefulWidget {

  final Member member;

  const ResultCard(this.member, {super.key,});

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
      color : Colors.white,
      elevation: 10,
      child: Column(
        children: [
          Text(widget.member.fullName(),style: TextStyle(fontWeight: FontWeight.bold),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left :8.0),
                    child: Text(widget.member.title),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left :8.0),
                    child: Text(widget.member.residence),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left :8.0),
                    child: Text('Forum  ${widget.member.forum}'),
                  ),
                ],
              ),
              ProfilePic(widget.member.profileImage??'',widget.member.banner??false),
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
  const ProfilePic( this.uri , this.banner , {super.key, });

  final String uri;
  final bool banner;

  @override
  Widget build(BuildContext context) {
    return
      Stack(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100), child: uri!=''
              ? Image.network(uri)
              : Image(image:AssetImage(uri!=''?uri:'images/profile0.jpg'))),
        ),
        banner?Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 35,
            height: 35,
            child: Image(image: AssetImage('images/new.png'))
          ),
        ):SizedBox(),
      ],
    );
  }
}


class ProfileAppDrawer extends StatelessWidget {
  const ProfileAppDrawer( this.member , {super.key});

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.fullName() , style: TextStyle(fontWeight: FontWeight.bold),),
              Text(member.email ,style: TextStyle(fontSize: 12),),
              Text('Forum '+member.forum.toString()??'Not in a Forum',style: TextStyle(fontSize: 12)),
            ],
          ),
          ProfilePic(member.profileImage??'',false)
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
      child: SpinKitRotatingCircle(
        color: Colors.blue,
        size: 80.0,
      ),
    );
  }
}

class ResultsLoading extends StatelessWidget {
  const ResultsLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(80.0),
        child: SpinKitThreeInOut(
          color: Colors.blue,
          size: 80.0,
        ),
      ),
    );
  }
}