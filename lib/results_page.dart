import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main_controller.dart';
import 'members_controller.dart';
import 'package:get/get.dart';
import 'profile_page.dart';
import 'widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'models.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
  });

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final mainController = Get.put(MainController());
  final membersController = Get.put(MembersController());
  List<String> activeSuggestionsList=[];
  bool memberSearchIsActive = true;
  bool companySearchIsActive = false;
  List<ResultRecord> filterResult(String search) {
    List<ResultRecord> res = mainController.suggestionsList.where((element) {
      var lowerCaseLabel = element.label.toLowerCase();
      var lowerCaseSearch = search.toLowerCase();
      return lowerCaseLabel.contains(lowerCaseSearch);
    }).toList();
    return res;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      //mainController.resultsLoading.value=true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => !mainController.resultsLoading.value
        ?Directionality(
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
                    );
                  },
                  onSelected: (result) async {
                    Member member = await membersController.getMemberById(result.id);
                    Get.to(
                            () => ProfilePage(member)
                        , transition: Transition.zoom, curve: Curves.easeInOut,



                    );
                  },
                ),
                /// selected Tags & Results
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    child: Obx(() => mainController.resultsLoading.value
                        ? const ResultsLoading()
                        : Column(
                              children: [
                                mainController.tags.isNotEmpty ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                      child: Row(
                                                                        children: [ChipsChoice<String>.multiple(
                                      value: mainController.tags,
                                      onChanged: (val) async {
                                        setState(() => mainController.tags.value = val);
                                        await mainController.fetchFilteredMembers(val);
                                      },
                                      choiceItems: C2Choice.listFrom<String, String>(
                                        source: mainController.tags,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceCheckmark: true,
                                      textDirection: TextDirection.ltr,
                                      wrapped: true,
                                                                        )],
                                                                      ),
                                    ) :SizedBox(width: 1,),
                                mainController.filteredResults.isNotEmpty ? ListView(
                                                      physics: BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(10.0),
                                    shrinkWrap: true,
                                    //physics: ClampingScrollPhysics(),
                                    children: ListTile.divideTiles(
                                        context: context,
                                        tiles: List.generate(
                                            mainController.filteredResults.length,
                                            (index) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(bottom: 6.0),
                                                  child: SizedBox(
                                                    height: 200,
                                                    child: GestureDetector(
                                                      child: ResultCard(
                                                        member: mainController.filteredResults[index],
                                                        newMemberFlag: mainController.checkIfNewMember( mainController.filteredResults[index].joinDate),
                                                        isBirthdayToday:  mainController.checkIfTodayIsBirthday(mainController.filteredResults[index].birthdate??Timestamp.fromMicrosecondsSinceEpoch(0)),
                                                      ),
                                                      onTap: () {
                                                        Get.to(() => ProfilePage(mainController.filteredResults[index]),transition: Transition.zoom, duration: Duration(seconds: 1));
                                                      },
                                                    ),
                                                  ),
                                                ))).toList(),
                                  ) :Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      const Text('No results found.', style: TextStyle(fontWeight: FontWeight.bold),),
                                      Padding(
                                        padding: const EdgeInsets.only(top:20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                                child: const Text('To continue please press the shuffle icon',style: TextStyle(color: Colors.blue,), ),
                                              onTap: () => {
                                                mainController.loadRandomResults(
                                                    mainController
                                                        .numberOfMembers)
                                              },
                                            ),
                                            IconButton(
                                              color: Colors.blue,
                                                onPressed: () => {
                                                  mainController.loadRandomResults(
                                                      mainController
                                                          .numberOfMembers)
                                                },
                                                icon: Icon(Icons.shuffle)),
                                          ],
                                        ),
                                      ),
                                      const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text('or you can also use the filters below'),
                                          //Icon(Icons.filter_list_outlined)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ]
                      ),
                  ),
                ),
                )],
            ),
          ),
        )):ResultsLoading());
  }
}
