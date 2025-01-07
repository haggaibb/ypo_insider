import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ypo_connect/main_controller.dart';
import 'package:ypo_connect/widgets.dart';
import 'models.dart';


class Reports extends StatefulWidget {


  const Reports(
      {Key? key,})
      : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}
class _ReportsState extends State<Reports> {

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
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
          ),
          body: Center(
            child: ListView.builder(
              padding: const EdgeInsets.all(30.0),
              // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //   crossAxisCount: 2, // Two buttons per row
              //   crossAxisSpacing: 20.0, // Spacing between columns
              //   mainAxisSpacing: 20.0, // Spacing between rows
              //   childAspectRatio: 4, // Adjust the aspect ratio for button size
              // ),
              itemCount: 2, // Total number of buttons
              itemBuilder: (context, index) {
                // Determine button properties based on index
                String buttonText;
                Widget targetPage;
                switch (index) {
                  case 0:
                    buttonText = 'Insider Registered Members';
                    targetPage =  BoardedRegisteredMembers();
                    break;
                  case 1:
                    buttonText = 'Future Report -TBD';
                    targetPage =  BoardedRegisteredMembers();
                    break;
                  default:
                    buttonText = '';
                    targetPage = const SizedBox(); // Fallback widget
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: SizedBox(
                    height: 60,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.ltr, // Set RTL
                              child: targetPage, // Navigate to respective page
                            ),
                          ),
                        );
                      },
                      child: Text(buttonText),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
///
///
class BoardedRegisteredMembers extends StatelessWidget {


  BoardedRegisteredMembers({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.put(MainController());
    List<Member> members = mainController.getRegisteredMembers();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.network('assets/images/logo-insider.png' ,height: 50,),
            const Text('Insider Registered Members', style: TextStyle(fontSize: 20),),
            const SizedBox(width: 200, child: Divider(thickness: 2, color: Colors.black,)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () async {
                  await mainController.saveRegisteredMembersCSV(members);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                          'File Saved',
                          style: TextStyle(color: Colors.white),
                        )),
                  );
                },
                child: Container(
                  width: 180,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.table_rows_outlined),
                      Text('Save to CSV'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.close),
                      Text('Close Report'),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              child: DataTable(
                horizontalMargin: 0,
                columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('First Name')),
                  DataColumn(label: Text('Last Name')),
                  DataColumn(label: Text('Profile Score')),
                ],
                rows: List.generate(
                  members.length,
                      (index) => DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')), // Serial number
                      DataCell(Text(members[index].firstName)), // First name
                      DataCell(Text(members[index].lastName)), // Last name
                      DataCell(Text(members[index].getNetProfileScore().toString())), // profile score

                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () async {
                  await mainController.saveRegisteredMembersCSV(members);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                          'File Saved',
                          style: TextStyle(color: Colors.white),
                        )),
                  );
                },
                child: Container(
                  width: 180,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.table_rows_outlined),
                      Text('Save to CSV'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.close),
                      Text('Close Report'),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

