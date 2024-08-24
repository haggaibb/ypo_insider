import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/widgets.dart';
import 'ctx.dart';
import 'package:get/get.dart';

class Filters extends StatefulWidget {
  final Function()? jumpFunction;
  const Filters(this.jumpFunction, {super.key,});

  @override
  _FiltersState createState() => _FiltersState();
}
class _FiltersState extends State<Filters> {
  final controller = Get.put(Controller());

  // multiple choice value
  late List filtersCategory;
  List<String> tags =[];

  // list of string options

  @override
  void initState() {
    super.initState();
    filtersCategory = controller.filteredTagsList;
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: widget.jumpFunction,
                      icon : Icon(Icons.filter_list_outlined),
                      //color: Colors.blueAccent,
                    ),
                    Expanded(
                      child: ListView(
                        children: List.generate(filtersCategory.length, (index) =>
                            Padding(
                              padding: const EdgeInsets.only(left : 30.0, right: 30.0, top: 10, bottom: 10),
                              child: SizedBox(
                                //height: 200,
                                width: 800,
                                child: Card(
                                  elevation: 5,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title:  Text(filtersCategory[index]['label']),
                                      ),
                                      ChipsChoice<String>.multiple(
                                        value: tags,
                                        onChanged: (val) {
                                          setState(() => tags = val);
                                          controller.fetchFilteredMembers(val);
                                        },
                                        choiceItems: C2Choice.listFrom<String, String>(
                                          source: controller.getFilteredTagsFromCategory(filtersCategory[index]['key']),
                                          value: (i, v) => v,
                                          label: (i, v) => v,
                                          tooltip: (i, v) => v,
                                        ),
                                        choiceCheckmark: true,
                                        textDirection: TextDirection.ltr,
                                        wrapped: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ));
  }
}

