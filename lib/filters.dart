import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/widgets.dart';
import 'package:ypo_connect/members_controller.dart';
import 'main_controller.dart';
import 'package:get/get.dart';

class Filters extends StatefulWidget {
  final Function()? jumpFunction;
  const Filters(this.jumpFunction, {super.key,});

  @override
  _FiltersState createState() => _FiltersState();
}
class _FiltersState extends State<Filters> {
  final mainController = Get.put(MainController());
  // multiple choice value
  late List filtersCategory;
  List<String> tags =[];

  // list of string options

  @override
  void initState() {
    super.initState();
    filtersCategory = mainController.filteredTagsList;
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
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
          decoration: BoxDecoration(
            border: const Border.fromBorderSide(BorderSide(width: 0.5)),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(200),
                topLeft: Radius.circular(200),
              ),
              color: Color(4281221236),
          ),
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: IconButton(
                        onPressed: widget.jumpFunction,
                        icon : Icon(Icons.filter_list_outlined),
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
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
                                          title:  Text(filtersCategory[index]['label'] ,style: Theme.of(context).textTheme.titleLarge),
                                        ),
                                        Obx(() {
                                          mainController.tags.isNotEmpty;
                                          return ChipsChoice<String>.multiple(
                                          value: mainController.tags,
                                          onChanged: (val) {
                                            setState(()  {tags = val;mainController.tags.value=val;});
                                            mainController.fetchFilteredMembers(val);
                                          },
                                          choiceItems: C2Choice.listFrom<String, String>(
                                            source: mainController.getFilteredTagsFromCategory(filtersCategory[index]['key']),
                                            value: (i, v) => v,
                                            label: (i, v) => v,
                                            tooltip: (i, v) => v,
                                          ),
                                          choiceCheckmark: true,
                                          textDirection: TextDirection.ltr,
                                          wrapped: true,
                                        );}),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50,)
                  ]),
            ),
          ),
        ));
  }
}

