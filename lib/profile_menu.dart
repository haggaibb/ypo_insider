import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';



class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onPress,
    required this.type
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onPress;
  final String type;

  @override
  Widget build(BuildContext context) {

    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? Colors.blue : Colors.greenAccent;


    return Row(
      children: [
        Icon(icon, color: iconColor),
        Text(title),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: iconColor.withOpacity(0.1),
          ),
          child: InkWell(
            child: Text(value, maxLines: type=='textbox'?3:1,),
            onTap: () {},
          ),
        )
      ],
    );

  }
}

/*

      ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Row(
        children: [
          Text(title, style: TextStyle()),
          Text(value, style: TextStyle())
        ],
      ),
      trailing: endIcon? Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: Icon(LineAwesomeIcons.angle_right_solid, size: 18.0, color: Colors.grey)) : null,
    );
 */