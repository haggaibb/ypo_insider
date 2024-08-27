import 'package:flutter/material.dart';
import 'package:ypo_connect/models.dart';
import 'ctx.dart';
import 'package:get/get.dart';
import 'profile_page.dart';
import 'widgets.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
  });

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final controller = Get.put(Controller());
  // multiple choice value
  //List<String> tags = ['Education'];

  // list of string options

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
    return Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                //width: 350,
                child: Obx(() => controller.resultsLoading.value
                    ? ResultsLoading()
                    : controller.filteredResults.isNotEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(20.0),
                            shrinkWrap: true,
                            //physics: ClampingScrollPhysics(),
                            children: ListTile.divideTiles(
                                context: context,
                                tiles: List.generate(
                                    controller.filteredResults.length,
                                    (index) => Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: SizedBox(
                                            height: 160,
                                            child: GestureDetector(
                                              child: ResultCard(controller
                                                  .filteredResults[index]),
                                              onTap: () => {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfilePage(controller
                                                                  .filteredResults[
                                                              index])),
                                                )
                                              },
                                            ),
                                          ),
                                        ))).toList(),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('No Results Found'),
                          )),
              ),
            ),
          ),
        ));
  }
}
