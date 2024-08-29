import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ctx.dart';
import 'package:get/get.dart';
import 'profile_page.dart';
import 'widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'models.dart';


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
                // SearchAnchor(builder:
                //     (BuildContext context, SearchController controller) {
                //   return SearchBar(
                //     controller: controller,
                //     padding: const MaterialStatePropertyAll<EdgeInsets>(
                //         EdgeInsets.symmetric(horizontal: 16.0)),
                //     onTap: () {
                //       controller.openView();
                //     },
                //     onChanged: (_) {
                //       controller.openView();
                //     },
                //     leading: const Icon(Icons.search),
                //     trailing: <Widget>[
                //       Row(
                //         children: [
                //           Tooltip(
                //             message: 'Search by Name',
                //             child: IconButton(
                //               isSelected: memberSearchIsActive,
                //               onPressed: () {
                //                 setState(() {
                //                   memberSearchIsActive = !memberSearchIsActive;
                //                   companySearchIsActive = !companySearchIsActive;
                //                 });
                //               },
                //               icon: const Icon(Icons.person, color: Colors.grey,),
                //               selectedIcon: const Icon(Icons.person),
                //             ),
                //           ),
                //           Tooltip(
                //             message: 'Search by Company',
                //             child: IconButton(
                //               isSelected: companySearchIsActive,
                //               onPressed: () {
                //                 setState(() {
                //                   if (companySearchIsActive) {
                //                     print('already picked');
                //                   } else {
                //                     memberSearchIsActive = false;
                //                     companySearchIsActive = true;
                //                   }
                //                 });
                //               },
                //               icon: const Icon(Icons.work, color: Colors.grey,),
                //               selectedIcon: const Icon(Icons.work),
                //             ),
                //           )
                //         ],
                //       )
                //     ],
                //   );
                // }, suggestionsBuilder:
                //     (BuildContext context, SearchController sController) {
                //   List<String> activeList = memberSearchIsActive?controller.allMembersFullName:controller.allCompanies;
                //   return List<ListTile>.generate(activeList.length, (int index) {
                //     final String item = activeList[index];
                //     return ListTile(
                //       title: Text(item),
                //       onTap: () {
                //         setState(() {
                //           sController.closeView(item);
                //         });
                //       },
                //     );
                //   });
                // }),
                Padding(
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
                      physics: BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(20.0),
                                shrinkWrap: true,
                                //physics: ClampingScrollPhysics(),
                                children: ListTile.divideTiles(
                                    context: context,
                                    tiles: List.generate(
                                        controller.filteredResults.length,
                                        (index) => Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
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
