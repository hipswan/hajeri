import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toast/toast.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import '../components/attendance_data_grid.dart';
import '../components/visitor_data_grid.dart';

import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter/material.dart';
import '../components/side_bar.dart';
import '../constant.dart';
import '../url.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../main.dart';

class MonthlyAttendance extends StatefulWidget {
  static const id = 'monthly_attendance';
  final String orgId;
  const MonthlyAttendance({
    Key key,
    this.orgId,
  }) : super(key: key);

  @override
  _MonthlyAttendanceState createState() => _MonthlyAttendanceState();
}

class _MonthlyAttendanceState extends State<MonthlyAttendance> {
  bool isAnimationFinished = false;
  bool isTypeSelected = false;
  bool isMonthSelected = false;
  bool showShimmer = true;
  String attendanceStatus = "no result";
  String _localPath;
  TargetPlatform platform = TargetPlatform.android;

  DateTime today = DateTime.now();
  DateTime _fromDate;

  TextEditingController search = new TextEditingController();

  List<DataRow> rows = [];
  int days = 28;
  List empList;
  var attendanceData;

  String orgId;
  @override
  void initState() {
    super.initState();
    _checkPermission();
    // _prepare();

    _fromDate = DateTime.now();
    typeSelectValue = 'All Employee';
    orgId = widget.orgId;

    _getEmployeeList().then(
      (value) => _getAttendanceList().then(
        (value) => setState(
          () {
            isTypeSelected = true;
            attendanceStatus = value;

            showShimmer = false;
          },
        ),
      ),
    );

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();

    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    //flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    // var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    //   'excel_download',
    //   'excel_download',
    //   'download excel',
    //   importance: Importance.max,
    //   priority: Priority.high,
    //   playSound: true,
    //   tag: 'Hajeri',
    //   icon: '@drawable/ic_stat_hajeri',
    // );
    // var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    // var platformChannelSpecifics = new NotificationDetails(
    //     android: androidPlatformChannelSpecifics,
    //     iOS: iOSPlatformChannelSpecifics);

    // flutterLocalNotificationsPlugin.show(
    //   0,
    //   'Excel sheet is downloaded',
    //   'Tap To Open',
    //   platformChannelSpecifics,
    // );
  }

  Future onSelectNotification(String payload) async {
    // print("Payload: $payload");
    OpenFile.open(payload);
  }

  // Future<String> _prepare() async {
  //   _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

  //   final savedDir = Directory(_localPath);
  //   bool hasExisted = await savedDir.exists();
  //   if (!hasExisted) {
  //     savedDir.create();
  //   }
  //   // log('$_localPath', name: 'local path');
  //   return "success";
  // }

  // Future<String> _findLocalPath() async {
  //   final directory = platform == TargetPlatform.android
  //       ? await getExternalStorageDirectory()
  //       : await getApplicationDocumentsDirectory();
  //   return directory.path;
  // }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> _getEmployeeList() async {
    List<dynamic> data;
    // String orgId = prefs.getString("worker_id");
    // log(
    //   '$kDropDownListForAttendance$orgId',
    // );
    try {
      var response = await http.get(Uri.parse(
        '$kDropDownListForAttendance$orgId',
      ));

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        // log('the data is ${data.toString()}');
        List<dynamic> employee = data[1]['Employee List'];
        if (employee.isNotEmpty) {
          // log(employee.toString());
          _dropDownTypeMenuItems.addAll(
            employee
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e['mobileno'].toString(),
                    child: Text(
                      e['nameofworker'],
                      overflow: TextOverflow.clip,
                    ),
                  ),
                )
                .toList(),
          );
          //emp_list.add({"nameofworker":"All Employee","mobileno":"All Employee"});
          // empList = empList[1]['Employee List'];
          // empList.insert(
          //     0, {"nameofworker": "All Employee", "mobileno": "All Employee"});
          // empList.insert(
          //     1, {"nameofworker": "All Visitors", "mobileno": "All Visitors"});

          // print("the emp list is $empList");
          //state_id=data['id'];

        } else {
          _dropDownTypeMenuItems.add(
            DropdownMenuItem<String>(
              value: "-1",
              child: Text(
                "No Employee",
              ),
            ),
          );
        }
        setState(() {});
//      print(data);

      } else {
        _dropDownTypeMenuItems.add(
          DropdownMenuItem<String>(
            value: "-1",
            child: Text(
              "Server issue",
            ),
          ),
        );

        setState(() {});
      }
    } on IOException catch (e) {
      _dropDownTypeMenuItems.add(
        DropdownMenuItem<String>(
          value: "-1",
          child: Text(
            "No Internet",
          ),
        ),
      );

      setState(() {});
    } catch (e) {
      _dropDownTypeMenuItems.add(
        DropdownMenuItem<String>(
          value: "-1",
          child: Text(
            "error occurred",
          ),
        ),
      );

      setState(() {});
    }
  }

  Future<String> _getAttendanceList() async {
    var data;
    // String orgId = prefs.getString("worker_id");
    // await Future.delayed(
    //     Duration(
    //       seconds: 50,
    //     ), () {
    //   attendanceData = kAttendanceMockData;
    // });
    // log('$kMonthlyAttendance$orgId/$typeSelectValue/${_fromDate.toString().substring(0, 7)}');
    try {
      var response = await http.get(Uri.parse(
          '$kMonthlyAttendance$orgId/$typeSelectValue/${_fromDate.toString().substring(0, 7)}'));

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        // log("the data is " + data.toString());

//      print(data);
        if (data is List) {
          attendanceData = data;
        } else {
          attendanceData = data['Visitor List'];
          // log(attendanceData.toString());
        }
        return "success";
      } else {
        attendanceData = null;
        return "server issue";
      }
    } on IOException catch (e) {
      attendanceData = null;

      return "no internet";
    } catch (e) {
      attendanceData = null;

      return "error occurred";
    }
  }

  //Drop Down Section
  String monthSelectValue;
  String typeSelectValue;

  final List<DropdownMenuItem<String>> _dropDownMonthsMenuItems =
      kMonthsSelectItems.entries
          .map(
            (e) => DropdownMenuItem<String>(
              value: e.key,
              child: Text(
                e.value,
              ),
            ),
          )
          .toList();

  final List<DropdownMenuItem<String>> _dropDownTypeMenuItems = kTypeSelectItems
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
          ),
        ),
      )
      .toList();
  Future<void> _showMonthPicker() async {
    final picked = await showMonthPicker(
      context: context,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      initialDate: _fromDate,
    );
    log('${picked.toIso8601String()}  ${_fromDate.toIso8601String()}');
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: widget.orgId.contains(prefs.getString('worker_id'))
          ? Drawer(
              child: SideBar(
                section: 'monthly_attendance',
              ),
            )
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue[800],
        title: Text(
          'Monthly Attendance',
          // 'हाजिरी',
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 10.0,
              ),
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 50.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      child: Container(
                        width: size.width - 120,
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          value: typeSelectValue,
                          onChanged: (String newValue) async {
                            // log('New type selected  $newValue');

                            if (!newValue.contains('-1')) {
                              // setState(() {
                              //   showShimmer = true;
                              //   _fromDate = DateTime.now();
                              //   isTypeSelected = true;
                              //   typeSelectValue = newValue;
                              // });
                              setState(() {
                                typeSelectValue = newValue;
                                showShimmer = true;
                              });
                              attendanceStatus = await _getAttendanceList();

                              setState(() {
                                isTypeSelected = true;
                                showShimmer = false;
                              });
                            }
                          },
                          items: _dropDownTypeMenuItems,
                          decoration: InputDecoration(),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     vertical: 10.0,
                    //   ),
                    //   child: Container(
                    //     width: double.infinity,
                    //     child: OutlineButton(
                    //       onPressed: () async {
                    //         // await _showDatePicker();
                    //         await _showMonthPicker();
                    //         setState(() {
                    //           isMonthSelected = true;

                    //           showShimmer = true;
                    //         });
                    //         _getAttendanceList();
                    //       },
                    //       child: Text(
                    //           '${kMonthsSelectItems[_fromDate.month.toString()]}, ${_fromDate.year}'),
                    //     ),
                    //   ),
                    // ),
                    getPeripheralView(),
                  ],
                ),
              ),
            ),
            Expanded(
                child: Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: showShimmer
                        ? Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : getBottomView()

                    // AttendanceGridTable
                    )

                // AttendanceSheet(
                //     attendanceData: attendanceData,
                //   ),
                ),

            //       Card(
            //           child: DataTable(
            //             sortColumnIndex: null,
            //             sortAscending: true,
            //             columns: <DataColumn>[
            //               DataColumn(
            //                 label: Text(
            //                   'Name',
            //                 ),
            //               ),
            //               DataColumn(
            //                 label: Text(
            //                   'In Time',
            //                 ),
            //               ),
            //               DataColumn(
            //                 label: Text(
            //                   'Out Time',
            //                 ),
            //               ),
            //               DataColumn(
            //                 label: Text(
            //                   'Visiting Date',
            //                 ),
            //               ),
            //               DataColumn(
            //                 label: Text(
            //                   'Current Date',
            //                 ),
            //               ),
            //             ],
            //             rows: rows,
            //           ),
            //         ),
            // ),
            // Expanded(
            //   child: Card(
            //     margin: EdgeInsets.symmetric(
            //       vertical: 10.0,
            //       horizontal: 10.0,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(
            //         10.0,
            //       ),
            //     ),
            //     child: Center(
            //       child: Text(
            //         'Attendance Report',
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget getBottomView() {
    switch (attendanceStatus) {
      case "no result":
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case "error occurred":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/vectors/notify.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Error has occured',
              ),
            ],
          ),
        );
        break;
      case "no internet":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/vectors/no_signal.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Device not connected to internet',
              ),
            ],
          ),
        );
        break;
      case "server issue":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/vectors/server_down.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Server error',
              ),
            ],
          ),
        );
        break;
      case "success":
        return getGridView();
        break;
    }
  }

  Widget getGridView() {
    switch (typeSelectValue) {
      case 'All Employee':
        return (attendanceData as List).isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/vectors/notify.svg',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'No Employee',
                    ),
                  ],
                ),
              )
            : AttendanceDataGrid(
                attendanceSheet: attendanceData,
                type: typeSelectValue,
              );
        break;
      case 'All Visitors':
        return (attendanceData as List).isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/vectors/notify.svg',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'No Visitor',
                    ),
                  ],
                ),
              )
            : VisitorDataGrid(
                attendanceSheet: attendanceData,
                type: typeSelectValue,
              );
        break;
      default:
        return (attendanceData as List).isEmpty
            ? Center(
                child: Text(
                  'no record of attendance',
                ),
              )
            : AttendanceDataGrid(
                attendanceSheet: attendanceData,
                type: typeSelectValue,
              );
      // CalendarApp(
      //   attendanceSheet: attendanceData,
      //   type: typeSelectValue,
      // );
    }
  }

  getPDFExcelView() {
    return Row(
      children: [
        // Container(
        //   width: 50,
        //   child: ElevatedButton(
        //     style: ButtonStyle(
        //       padding: MaterialStateProperty.all(
        //         EdgeInsets.zero,
        //       ),
        //       backgroundColor: MaterialStateProperty.all(
        //         Colors.redAccent,
        //       ),
        //     ),
        //     onPressed: () {},
        //     child: Text(
        //       'PDF',
        //     ),
        //   ),
        // ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                EdgeInsets.zero,
              ),
              backgroundColor: MaterialStateProperty.all(
                Colors.green,
              ),
            ),
            onPressed: () {
              _createExcel();
            },
            child: Text(
              'Excel',
            ),
          ),
        ),
      ],
    );
  }

  getPeripheralView() {
    switch (typeSelectValue) {
      case 'All Employee':
        return Row(
          children: [
            OutlinedButton(
              onPressed: () async {
                // await _showDatePicker();
                await _showMonthPicker();
                setState(() {
                  isMonthSelected = true;

                  showShimmer = true;
                });
                attendanceStatus = await _getAttendanceList();
                setState(() {
                  showShimmer = false;
                });
              },
              child: Text(
                  '${kMonthsSelectItems[_fromDate.month.toString()]}, ${_fromDate.year}'),
            ),
            SizedBox(
              width: 10.0,
            ),
            isTypeSelected ? getPDFExcelView() : Text(''),
          ],
        );
        break;

      case 'All Visitors':
        return Row(
          children: [
            OutlinedButton(
              onPressed: () async {
                // await _showDatePicker();
                await _showMonthPicker();
                setState(() {
                  isMonthSelected = true;

                  showShimmer = true;
                });
                attendanceStatus = await _getAttendanceList();

                setState(() {
                  showShimmer = false;
                });
              },
              child: Text(
                  '${kMonthsSelectItems[_fromDate.month.toString()]}, ${_fromDate.year}'),
            ),
            SizedBox(
              width: 10.0,
            ),
            isTypeSelected ? getPDFExcelView() : Text(''),
          ],
        );
        break;
      default:
        return isTypeSelected
            ? Row(children: [
                OutlinedButton(
                  onPressed: () async {
                    // await _showDatePicker();
                    await _showMonthPicker();
                    setState(() {
                      isMonthSelected = true;

                      showShimmer = true;
                    });
                    attendanceStatus = await _getAttendanceList();

                    setState(() {
                      showShimmer = false;
                    });
                  },
                  child: Text(
                      '${kMonthsSelectItems[_fromDate.month.toString()]}, ${_fromDate.year}'),
                ),
                SizedBox(
                  width: 10.0,
                ),
                isTypeSelected ? getPDFExcelView() : Text('')
              ])
            : Text('');
    }
  }

  Future<void> _createExcel() async {
//Create an Excel document.
    List attendance = attendanceData as List;
    log(attendance.toString());
    if (attendance != null && attendance.isNotEmpty) {
      //Creating a workbook.
      final excel.Workbook workbook = excel.Workbook();
      //Accessing via index
      final excel.Worksheet sheet = workbook.worksheets[0];
      sheet.showGridlines = false;

      // Enable calculation for worksheet.
      sheet.enableSheetCalculations();

      //Set data in the worksheet.

      sheet.getRangeByName('B4:D6').merge();

      sheet.getRangeByName('B4').setText('Hajeri');
      sheet.getRangeByName('B4').cellStyle.fontSize = 32;

      sheet.getRangeByName('B8').setText('Attendance Sheet:');
      sheet.getRangeByName('B8').cellStyle.fontSize = 9;
      sheet.getRangeByName('B8').cellStyle.bold = true;

      sheet.getRangeByName('B9').setText(prefs.getString('org_name'));
      sheet.getRangeByName('B9').cellStyle.fontSize = 12;

      sheet.getRangeByName('B10').setText('Address line 1');
      sheet.getRangeByName('B10').cellStyle.fontSize = 9;

      sheet.getRangeByName('B11').setText('Address line 2,');
      sheet.getRangeByName('B11').cellStyle.fontSize = 9;

      sheet
          .getRangeByName('B12')
          .setNumber(double.parse(prefs.getString('mobile')));
      sheet.getRangeByName('B12').cellStyle.fontSize = 9;
      sheet.getRangeByName('B12').cellStyle.hAlign = excel.HAlignType.left;

      final excel.Range range1 = sheet.getRangeByName('F8:G8');
      final excel.Range range2 = sheet.getRangeByName('F9:G9');
      final excel.Range range3 = sheet.getRangeByName('F10:G10');
      final excel.Range range4 = sheet.getRangeByName('F11:G11');
      final excel.Range range5 = sheet.getRangeByName('F12:G12');

      // range1.merge();
      // range2.merge();
      range3.merge();
      range4.merge();
      range5.merge();
      sheet.getRangeByName('F8').setText('Duration');
      range1.cellStyle.fontSize = 8;
      range1.cellStyle.bold = true;
      range1.cellStyle.hAlign = excel.HAlignType.right;

      sheet.getRangeByName('F10').setText('DATE');
      range3.cellStyle.fontSize = 8;
      range3.cellStyle.bold = true;
      range3.cellStyle.hAlign = excel.HAlignType.right;
      sheet.getRangeByName('F9').dateTime = _fromDate;
      sheet.getRangeByName('F9').numberFormat =
          '[\$-x-sysdate]dddd, mmmm dd, yyyy';
      sheet.getRangeByName('F11').dateTime = DateTime.now();
      sheet.getRangeByName('F11').numberFormat =
          '[\$-x-sysdate]dddd, mmmm dd, yyyy';
      range4.cellStyle.fontSize = 9;
      range4.cellStyle.hAlign = excel.HAlignType.right;

      range5.cellStyle.fontSize = 8;
      range5.cellStyle.bold = true;
      range5.cellStyle.hAlign = excel.HAlignType.right;

      final excel.Range range6 = sheet.getRangeByName('B15:G15');
      range6.cellStyle.fontSize = 10;
      range6.cellStyle.bold = true;

      int firstMapLength = (attendance.first as Map).length;
      sheet.getRangeByIndex(1, 1, 1, firstMapLength + 1).cellStyle.backColor =
          '#333F4F';
      sheet.getRangeByIndex(1, 1, 1, firstMapLength + 1).merge();
      sheet.getRangeByIndex(15, 2)..setText('Name');
      if (typeSelectValue.trim().toLowerCase().contains('all visitors')) {
        Map referenceMap = json.decode(json.encode(attendance.first));
        referenceMap.remove('nameofworker');
        for (int i = 1; i <= referenceMap.length; i++) {
          sheet.getRangeByIndex(15, 2 + i)
            ..setText(referenceMap.entries.elementAt(i - 1).key.toString());
        }
        for (int i = 0; i < attendance.length; i++) {
          sheet.getRangeByIndex(16 + i, 2)
            ..setText(attendance[i]['nameofworker'])
            ..autoFit();

          for (int j = 1; j <= referenceMap.length; j++) {
            sheet.getRangeByIndex(16 + i, 2 + j)
              ..setText(referenceMap.entries.elementAt(j - 1).value.toString())
              ..autoFit();
          }
        }
      } else {
        for (int i = 1; i <= 31; i++) {
          sheet.getRangeByIndex(15, 2 + i)..setText('$i');
        }
        sheet.getRangeByIndex(15, 31 + 3).setText('Mobile');
        // debugger();
        for (int i = 0; i < attendance.length; i++) {
          sheet.getRangeByIndex(16 + i, 2)
            ..setText(attendance[i]['name'])
            ..autoFit();

          for (int j = 1; j <= 31; j++) {
            if (attendance[i][j.toString()]
                .toString()
                .trim()
                .toLowerCase()
                .contains('a')) {
              sheet.getRangeByIndex(16 + i, 2 + j).setText('');
            } else {
              var present = attendance[i][j.toString()].toString();
              sheet.getRangeByIndex(16 + i, 2 + j)
                ..setText(present
                    .substring(
                      present.indexOf('[') + 1,
                      present.indexOf(']'),
                    )
                    .replaceAll(RegExp(r';'), ' '))
                ..autoFit();
            }
          }
          sheet.getRangeByIndex(16 + i, 31 + 3)
            ..setText(attendance[i]['mobileno'].toString())
            ..autoFit();
        }
      }
      sheet.getRangeByIndex(15, 2, 15, 31 + 3)..cellStyle.bold = true;
      sheet
          .getRangeByIndex(15, 2, 15 + attendance.length, 31 + 3)
          .cellStyle
          .borders
          .all
          .lineStyle = excel.LineStyle.thin;
      sheet.getRangeByIndex(16 + attendance.length, 1).text =
          'hajeri , Aurangabad, Maharashtra | admin@amvenures.com';
      sheet.getRangeByIndex(16 + attendance.length, 1).cellStyle.fontSize = 8;

      final excel.Range range9 = sheet.getRangeByIndex(
          16 + attendance.length, 1, 16 + attendance.length, 31 + 3);
      range9.cellStyle.backColor = '#ACB9CA';
      range9.merge();
      range9.cellStyle.hAlign = excel.HAlignType.center;
      range9.cellStyle.vAlign = excel.VAlignType.center;

      var logoAsBytes = await rootBundle.load('assets/images/hajeri_login.jpg');
      final excel.Picture picture = sheet.pictures.addBase64(
        3,
        8,
        base64Encode(
          logoAsBytes.buffer.asUint8List(
            logoAsBytes.offsetInBytes,
            logoAsBytes.lengthInBytes,
          ),
        ),
      );
      picture.lastRow = 13;
      picture.lastColumn = 10;

      //Save and launch the excel.
      final List<int> bytes = workbook.saveAsStream();
      //Dispose the document.
      workbook.dispose();
      //Save and launch file.
      // debugger();
      try {
        String excelPath = Platform.isAndroid
            ? '/storage/emulated/0/Download/excel.xlsx'
            : (await path.getApplicationDocumentsDirectory()).path +
                '/Download/excel.xlsx';
        File result = await File('$excelPath').writeAsBytes(bytes);
        if (result != null) {
          var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'excel_download',
            'excel_download',
            'download excel',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            tag: 'Hajeri',
            icon: '@drawable/ic_stat_hajeri',
          );
          var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
          var platformChannelSpecifics = new NotificationDetails(
              android: androidPlatformChannelSpecifics,
              iOS: iOSPlatformChannelSpecifics);

          await flutterLocalNotificationsPlugin.show(
            0,
            'Excel sheet is downloaded',
            'Tap To Open',
            platformChannelSpecifics,
            payload: excelPath,
          );
          // Platform.isIOS ? OpenFile.open(excelPath) : null;

          // debugger();
          Toast.show(
            "Excel Downloaded".toLowerCase(),
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            textColor: Colors.green,
          );
        } else {
          Toast.show(
            "error occured during excel download".toLowerCase(),
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            textColor: Colors.redAccent,
          );
        }
      } on path.MissingPlatformDirectoryException catch (e1) {
        log(e1.message, name: 'In excel download missing');
        Toast.show(
          "excel file not download",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.redAccent,
        );
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(e.runtimeType.toString()),
                content: Text(
                  e.toString(),
                  maxLines: 50,
                ),
                actions: <Widget>[
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Text("Back"),
                  ),
                ],
              );
            });
      }
    } else {
      Toast.show(
        "No record to create attendance sheet",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.redAccent,
      );
    }
  }
}
