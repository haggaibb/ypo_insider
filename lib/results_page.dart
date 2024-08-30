import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ctx.dart';
import 'package:get/get.dart';
import 'profile_page.dart';
import 'widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'models.dart';
import 'package:chips_choice/chips_choice.dart';


class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
  });

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final controller = Get.put(Controller());
  List<String> activeSuggestionsList=[];
  bool memberSearchIsActive = true;
  bool companySearchIsActive = false;

  List<ResultRecord> filterResult(search) {
    List<ResultRecord> res = controller.suggestionsList.where((element) => element.label.contains(search)).toList();
    return res;
  }

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
            child: Column(
              children: [
                const SizedBox(height: 20,),
                TypeAheadField<ResultRecord>(
                  suggestionsCallback: (search) => filterResult(search),
                  builder: (context, controller, focusNode) {
                    return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        //autofocus: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Search by Name or Company',
                        )
                    );
                  },
                  itemBuilder: (context, result) {
                    return ListTile(
                      title: Text(result.label),
                      //subtitle: Text(result.country),
                    );
                  },
                  onSelected: (result) async {
                    print('result picked');
                    print(result);
                    QueryDocumentSnapshot memberQuery = controller.allMembers.firstWhere((element) => element.id==result.id);
                    var memberData = memberQuery.data() as Map<String, dynamic>;
                    var memberEmail = memberData['email'];
                    Member member = await controller.getMemberByEMail(memberEmail);
                    //Member member = await controller.getMemberById(result.id);
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(member),
                      ),
                    );
                    // Navigator.of(context).push<void>(
                    //   MaterialPageRoute(
                    //     builder: (context) => CityPage(city: city),
                    //   ),
                    // );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(10.0),
                    //   boxShadow: const [
                    //     BoxShadow(
                    //       color: Colors.black,
                    //       offset: Offset(4, 4),
                    //       blurRadius: 10,
                    //     ),
                    //   ],
                    // ),
                    //width: 350,
                    child: Obx(() => controller.resultsLoading.value
                        ? ResultsLoading()
                        : controller.filteredResults.isNotEmpty
                            ? Column(
                              children: [
                                controller.tags.isNotEmpty
                                    ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                      child: Row(
                                                                        children: [ChipsChoice<String>.multiple(
                                      value: controller.tags,
                                      onChanged: (val) {
                                        setState(() => controller.tags.value = val);
                                        controller.fetchFilteredMembers(val);
                                      },
                                      choiceItems: C2Choice.listFrom<String, String>(
                                        source: controller.tags,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceCheckmark: true,
                                      textDirection: TextDirection.ltr,
                                      wrapped: true,
                                                                        )],
                                                                      ),
                                    )
                                    :SizedBox(width: 1,),
                                ListView(
                                                      physics: BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(10.0),
                                    shrinkWrap: true,
                                    //physics: ClampingScrollPhysics(),
                                    children: ListTile.divideTiles(
                                        context: context,
                                        tiles: List.generate(
                                            controller.filteredResults.length,
                                            (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: SizedBox(
                                                    height: 180,
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
                                  ),
                              ],
                            )
                            : Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Text('No results found.'),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Click to shuffle '),
                                        IconButton(
                                            onPressed: () => {
                                                  controller.loadRandomResults(
                                                      controller
                                                          .numberOfMembers)
                                                },
                                            icon: Icon(Icons.shuffle)),
                                      ],
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('You can use the filters below'),
                                        Icon(Icons.filter_list_outlined)
                                      ],
                                    )
                                  ],
                                ),
                              )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
