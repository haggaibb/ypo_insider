import 'package:flutter/material.dart';
import 'main_controller.dart';
import 'package:get/get.dart';
import 'profile_page.dart';
import 'widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'models.dart';
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
  List<String> activeSuggestionsList = [];
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
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() => !mainController.resultsLoading.value
        ? Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Ensure bounded height
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                        Member member = await mainController.getMemberById(result.id);
                        Get.to(
                              () => ProfilePage(member),
                          transition: Transition.zoom,
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    /// Selected Tags & Results
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Obx(
                            () => mainController.resultsLoading.value
                            ? const ResultsLoading()
                            : Column(
                          children: [
                            mainController.tags.isNotEmpty
                                ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: MultiSelectChip(
                                 tags:  mainController.tags,
                                onSelectionChanged: (tags) async  {
                                   setState(() {
                                     mainController.tags.value = tags;
                                   });
                                   mainController.tags.value = tags;
                                   await mainController.fetchFilteredMembers(tags);
                                },
                              ),
                            )
                                : const SizedBox(width: 1),
                            mainController.filteredResults.isNotEmpty
                                ? SizedBox(
                              height: constraints.maxHeight -
                                  150, // Set height for ListView
                              child: ListView.builder(
                                controller: mainController.scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(10.0),
                                itemCount: mainController.filteredResults.length +
                                    (mainController.isLoadingMore.value ? 1 : 0), // Add loading indicator
                                itemBuilder: (context, index) {
                                  if (index == mainController.filteredResults.length &&
                                      mainController.isLoadingMore.value) {
                                    return const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: SizedBox(
                                      height: 200,
                                      child: GestureDetector(
                                        child: ResultCard(
                                          member: mainController.filteredResults[index],
                                          newMemberFlag: mainController.checkIfNewMember(
                                              mainController.filteredResults[index].joinDate),
                                          isBirthdayToday: mainController.checkIfTodayIsBirthday(
                                            mainController.filteredResults[index].birthdate ??
                                                Timestamp.fromMicrosecondsSinceEpoch(0),
                                          ),
                                        ),
                                        onTap: () {
                                          Get.to(
                                                () => ProfilePage(mainController.filteredResults[index]),
                                            transition: Transition.zoom,
                                            duration: const Duration(seconds: 1),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'No results found.',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          child: const Text(
                                            'To continue please press the shuffle icon',
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                          onTap: ()  {
                                            setState(() {
                                              mainController.lastMember = 0 ;
                                              mainController.allMembers.shuffle();
                                              mainController.loadRandomResults(mainController.pageSize);
                                            });
                                          },
                                        ),
                                        IconButton(
                                          color: Colors.blue,
                                          onPressed: ()  {
                                            setState(() {
                                              mainController.lastMember = 0 ;
                                              mainController.allMembers.shuffle();
                                              mainController.loadRandomResults(mainController.pageSize);
                                            });
                                          },
                                          icon: const Icon(Icons.shuffle),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('or you can also use the filters below'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    )
        : const ResultsLoading());
  }
}
