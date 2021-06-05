import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../components/blue_button.dart';
import '../components/employee_data_grid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/form_page.dart';
import '../components/side_bar.dart';
import '../model/Employee.dart';
import '../url.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EmployeeDetails extends StatefulWidget {
  static const id = 'employee_detail';
  final String orgId;
  EmployeeDetails({
    this.orgId,
  });
  @override
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
//Drop Down Section
  String btnValue;
  bool showShimmer = true;
  TargetPlatform platform = TargetPlatform.android;
  String orgId;
  // ignore: avoid_init_to_null
  List<Employee> employees;
  String _localPath;
  String excelFilePath = "//excel_path";
  Future<String> _prepare() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    dev.log(_localPath.toString());
    return "success";
  }

  Future<String> _findLocalPath() async {
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> uploadExcelAsBytes() async {
    // String orgId = prefs.getString('worker_id');

    List<int> bytes = File(excelFilePath).readAsBytesSync();

    // dev.log(bytes.toString());
    var request =
        http.MultipartRequest('POST', Uri.parse('$kUploadEmpExcel$orgId'));
    request.files.add(
      await http.MultipartFile.fromPath(
        'employeedetails',
        excelFilePath,
      ),
    );
    dev.log('$kUploadEmpExcel$orgId');

    http.StreamedResponse response = await request.send();
    // var response = await http.post(
    //   '$kUploadEmpExcel$orgId',
    //   body: File(excelFilePath),
    //   headers: {
    //     'Content-Type': 'text/csv',
    //   },
    // );
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      dev.log(
        'reason phrase ${data.toString()}',
        name: 'Upload excel as a bytes',
      );
    }
  }

  // Future<String> excelToJson() async {
  //   var bytes = File(excelFilePath).readAsBytesSync();
  //   var excel = Excel.decodeBytes(bytes);
  //   int i = 0;
  //   List<dynamic> keys = [];
  //   var jsonMap = [];

  //   for (var table in excel.tables.keys) {
  //     // dev.log(table.toString());
  //     for (var row in excel.tables[table].rows) {
  //       // dev.log(row.toString());
  //       if (i == 0) {
  //         // dev.log(row.toString());
  //         keys = [
  //           "idcardno",
  //           "nameofworker",
  //           "addressline1",
  //           "state",
  //           "district",
  //           "city",
  //           "mobileno",
  //           "departmentname"
  //         ];
  //         i++;
  //       } else {
  //         var temp = {};
  //         int j = 0;
  //         String tk = '';
  //         for (var key in keys) {
  //           tk = '\"${key.toString()}\"';
  //           temp[tk] = (row[j].runtimeType == String)
  //               ? '\"${row[j].toString()}\"'
  //               : row[j];
  //           j++;
  //         }

  //         jsonMap.add(temp);
  //       }
  //     }
  //   }
  //   // dev.log(
  //   //   jsonMap.length.toString(),
  //   //   name: 'excel to json',
  //   // );
  //   // dev.log(jsonMap.toString(), name: 'excel to json');
  //   // String fullJson =
  //   //     jsonMap.toString().substring(1, jsonMap.toString().length - 1);
  //   // dev.log(
  //   //   fullJson.toString(),
  //   //   name: 'excel to json',
  //   // );
  //   return jsonMap.toString();
  // }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  // Future<String> createBulkEmployee() async {
  //   // String orgId = prefs.getString("worker_id");
  //   var body = await excelToJson();

  //   var response = await http
  //       .post(Uri.parse('$kUploadEmpExcel /$orgId'), body: body, headers: {
  //     'Content-Type': 'application/json',
  //   });

  //   print("reponse is " + response.statusCode.toString());
  //   if (response.statusCode == 200) {
  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(builder: (context) => Login()),
  //     // );
  //     Toast.show("Your Emplyees added", context,
  //         duration: Toast.LENGTH_LONG,
  //         gravity: Toast.BOTTOM,
  //         textColor: Colors.blue);

  //     Navigator.of(context, rootNavigator: true).pop();
  //   } else {
  //     Toast.show("Your Emplyees not added", context,
  //         duration: Toast.LENGTH_LONG,
  //         gravity: Toast.BOTTOM,
  //         textColor: Colors.red);
  //     Navigator.of(context, rootNavigator: true).pop();
  //   }
  // }

  Future<List<Employee>> _getEmployeeList() async {
    // String orgId = prefs.getString("worker_id");
    List<Employee> employeeList = [];

    var response = await http.get(Uri.parse("$kEmployeeList$orgId"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // print("the _getEmployeeList data is " + data.toString());
      employeeList = data.map<Employee>((e) {
        // dev.log(e["idcardno"].toString());
        return Employee(
            name: e["nameofworker"],
            number: e["mobileno"] == null ? 0 : int.parse(e["mobileno"]),
            idCardNumber: (e["idcardno"] == null ||
                    e["idcardno"].toString().trim().isEmpty ||
                    e["idcardno"]
                        .toString()
                        .trim()
                        .contains(new RegExp(r'[a-zA-Z]')))
                ? 0
                : int.parse(e["idcardno"]),
            organizationName: e["organizationname"],
            departmentName: e['departmentname'],
            city: e["city"],
            addressLine1: e["addressline1"],
            district: e["district"],
            state: e["state"]);
      }).toList();
    } else {
      employeeList.add(Employee.empty());
    }

    return employeeList;
  }

  static const menuItems = <String>[
    'General',
    'First',
    'Second',
    'Third',
  ];
  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
          ),
        ),
      )
      .toList();
  @override
  void initState() {
    super.initState();
    orgId = widget.orgId;
    _getEmployeeList().then((employeelist) {
      showShimmer = false;
      employees = employeelist;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: widget.orgId.contains(prefs.getString('worker_id'))
            ? Drawer(
                child: SideBar(
                  section: 'employee_details',
                ),
              )
            : null,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Employee Details',
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 50.0,
                      width: mediaQuery.size.width * 0.5 * 0.8,
                      child: BlueButton(
                        label: 'Add Employee',
                        onPressed: () async {
                          Employee addedEmployee = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return FormPage(
                                orgId: orgId,
                                currentEmployee: Employee.empty(),
                                action: 'add',
                                title: 'Add Employee',
                              );
                            }),
                          );
                          if (addedEmployee == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('no action taken while adding'),
                              ),
                            );
                          } else if (addedEmployee.name.isNotEmpty) {
                            setState(() {
                              showShimmer = true;
                            });
                            _getEmployeeList().then((employeelist) {
                              showShimmer = false;
                              employees = employeelist;
                              setState(() {});
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'error has occurred during add employee'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 50,
                      width: mediaQuery.size.width * 0.5 * 0.8,
                      child: BlueButton(
                        label: 'Upload Excel',
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              title: new Text('Upload Excel'),
                              content: new Text(
                                'Please use this feature on web for seamless user-experience',
                              ),
                              actions: <Widget>[
                                new TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text("Back"),
                                ),
                              ],
                            ),
                          );
                          // List<dynamic> employeesData = await showDialog(
                          //   useRootNavigator: true,
                          //   context: context,
                          //   barrierColor: Colors.blue[800].withAlpha(100),
                          //   builder: (context) {
                          //     excelFilePath = '';

                          //     return StatefulBuilder(
                          //         builder: (context, setState) {
                          //       return Center(
                          //         child: Card(
                          //           child: Container(
                          //             padding: EdgeInsets.fromLTRB(
                          //               0,
                          //               8.0,
                          //               0,
                          //               8.0,
                          //             ),
                          //             width: mediaQuery.size.width - 36,
                          //             child: SingleChildScrollView(
                          //               child: Column(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.center,
                          //                 children: [
                          //                   Row(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment.center,
                          //                     children: [
                          //                       Container(
                          //                         height: 50,
                          //                         width: 150,
                          //                         margin: EdgeInsets.fromLTRB(
                          //                           5,
                          //                           10.0,
                          //                           5,
                          //                           10.0,
                          //                         ),
                          //                         decoration: BoxDecoration(
                          //                           color: Colors.grey[200],
                          //                           borderRadius:
                          //                               BorderRadius.circular(
                          //                             10.0,
                          //                           ),
                          //                           boxShadow: [
                          //                             BoxShadow(
                          //                               color: Colors.blue[800],
                          //                             ),
                          //                             BoxShadow(
                          //                               color: Colors.blue[800],
                          //                               spreadRadius: -12.0,
                          //                               blurRadius: 12.0,
                          //                             ),
                          //                           ],
                          //                         ),
                          //                         child: SingleChildScrollView(
                          //                           child: Column(
                          //                             children: [
                          //                               Text(excelFilePath),
                          //                             ],
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       ElevatedButton(
                          //                         style: ButtonStyle(
                          //                           backgroundColor:
                          //                               MaterialStateProperty.all(
                          //                             Colors.white,
                          //                           ),
                          //                         ),
                          //                         onPressed: () async {
                          //                           FilePickerResult result =
                          //                               await FilePicker.platform
                          //                                   .pickFiles(
                          //                                       type: FileType
                          //                                           .custom,
                          //                                       allowedExtensions: [
                          //                                 'xls',
                          //                                 'xlsx',
                          //                                 'csv'
                          //                               ]);
                          //                           if (result != null) {
                          //                             File excelFile = File(result
                          //                                 .files.single.path);
                          //                             setState(() {
                          //                               excelFilePath =
                          //                                   excelFile.path;
                          //                             });
                          //                           } else {
                          //                             Toast.show(
                          //                               "cannot proceed without file"
                          //                                   .toLowerCase(),
                          //                               context,
                          //                               duration:
                          //                                   Toast.LENGTH_LONG,
                          //                               gravity: Toast.BOTTOM,
                          //                               textColor: Colors.red,
                          //                             );
                          //                           }
                          //                         },
                          //                         child: Text(
                          //                           'Browse',
                          //                           style: TextStyle(
                          //                             color: Colors.black,
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                   Container(
                          //                     child: BlueButton(
                          //                       label: 'Upload Excel',
                          //                       onPressed: () async {
                          //                         if (excelFilePath.isNotEmpty) {
                          //                           var jsonString =
                          //                               await excelToJson();
                          //                           // dev.log(json.toString(),
                          //                           //     name: 'In Upload');
                          //                           // await uploadExcelAsBytes();
                          //                           // context.visitAncestorElements(
                          //                           //                           (element) {
                          //                           //                         dev.log(
                          //                           // element.widget
                          //                           //   if (element.widget
                          //                           //       .toString()
                          //                           //       .contains('Builder')) {
                          //                           //     return false;
                          //                           //   }
                          //                           //   return true;
                          //                           // });
                          //                           Navigator.of(context,
                          //                               rootNavigator: true)
                          //                             ..pop(json
                          //                                 .decode(jsonString));
                          //                         } else {
                          //                           Toast.show(
                          //                             "cannot proceed without file"
                          //                                 .toLowerCase(),
                          //                             context,
                          //                             duration: Toast.LENGTH_LONG,
                          //                             gravity: Toast.BOTTOM,
                          //                             textColor: Colors.red,
                          //                           );
                          //                         }
                          //                       },
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: mediaQuery.size.width - 52,
                          //                     child: Divider(
                          //                       thickness: 1.0,
                          //                     ),
                          //                   ),
                          //                   Container(
                          //                     child: BlueButton(
                          //                       label: 'Download Excel',
                          //                       onPressed: () async {
                          //                         // dev.debugger();

                          //                         await _checkPermission();
                          //                         await _prepare();

                          //                         final taskId =
                          //                             await FlutterDownloader.enqueue(
                          //                                 url:
                          //                                     "https://www.hajeri.in/empdetailsexcel/Add-Employee.xlsx",
                          //                                 savedDir: _localPath,
                          //                                 fileName:
                          //                                     "Add - Employee.xlsx",
                          //                                 showNotification: true,
                          //                                 openFileFromNotification:
                          //                                     true);

                          //                         Toast.show(
                          //                           "Downloaded Successfully"
                          //                               .toLowerCase(),
                          //                           context,
                          //                           duration: Toast.LENGTH_LONG,
                          //                           gravity: Toast.BOTTOM,
                          //                           textColor: Colors.green,
                          //                         );
                          //                       },
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       );
                          //     });
                          //   },
                          // );

                          // // dev.debugger();
                          // // dev.log(
                          // //     employeesData[0]["Name of employee"]
                          // //         .toString(),
                          // //     name: 'In upload ');

                          // // employeesData.forEach((employee) {

                          // //   employees.add(
                          // //     Employee(
                          // //       name: employee["Name of employee"],
                          // //       addressLine1:
                          // //           employee["Address of employee"],
                          // //       state: employee["MH"],
                          // //       district: employee["District"],
                          // //       number:
                          // //           (employee["Mobile Number"] as double)
                          // //               .toInt(),
                          // //       city: employee["City"],
                          // //       departmentName:
                          // //           employee["Select Department"],
                          // //     ),
                          // //   );
                          // // });

                          // // dev.log('  employees ${employees.toString()}',
                          // //     name: 'Employee');
                          // setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: Center(
            //     child: Text(
            //       'In case of bulk employees,\n Kindly use upload excel option',
            //       textAlign: TextAlign.center,
            //       style: kTextStyleEmployeeDetail,
            //     ),
            //   ),
            // ),

            // Expanded(
            //   flex: 2,
            //   child: Card(
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(
            //         10.0,
            //       ),
            //     ),
            //     elevation: 5,
            //     margin: EdgeInsets.symmetric(
            //       // vertical: 10.0,
            //       horizontal: 10.0,
            //     ),
            //     child: Container(
            //       width: double.maxFinite,
            //       padding: EdgeInsets.symmetric(
            //         vertical: 5.0,
            //       ),
            //       child: SingleChildScrollView(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Text(
            //               'Shift  Detail',
            //               textAlign: TextAlign.center,
            //             ),
            //             Container(
            //               margin: EdgeInsets.symmetric(
            //                 vertical: 10.0,
            //                 horizontal: 50.0,
            //               ),
            //               child: DropdownButtonFormField(
            //                 value: btnValue,
            //                 onChanged: (String newValue) {
            //                   setState(() {
            //                     btnValue = newValue;
            //                   });
            //                 },
            //                 items: _dropDownMenuItems,
            //                 hint: const Text(
            //                   'Choose Shift',
            //                 ),
            //               ),
            //             ),
            //             BlueButton(
            //               label: 'Update Shift',
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            Expanded(
              flex: 6,
              child: showShimmer
                  ? Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Container(
                        width: double.maxFinite,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          enabled: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            5.0,
                                          ),
                                        ),
                                        color: Colors.white,
                                      ),
                                      width: 250,
                                      height: 40,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 30.0,
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                            10,
                                            (index) => Container(
                                              margin: EdgeInsets.only(
                                                right: 16.0,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    5.0,
                                                  ),
                                                ),
                                                color: Colors.white,
                                              ),
                                              width: 75,
                                              height: 35,
                                            ),
                                          ).toList(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 18.0,
                                    ),
                                    Column(
                                      children: List.generate(10, (index) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                5.0,
                                              ),
                                            ),
                                            color: Colors.white,
                                          ),
                                          width: double.maxFinite,
                                          height: 30,
                                        );
                                      }).toList(),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    )
                  : EmployeeDataGrid(
                      orgId: orgId,
                      employees: employees,
                      view: 'Employee List',
                      selectionModeDisabled: false,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
