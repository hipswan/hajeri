import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toast/toast.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'package:hajeri_demo/components/attendance_data_grid.dart';
import 'package:hajeri_demo/components/visitor_data_grid.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hajeri_demo/components/attendance.dart';
import 'package:hajeri_demo/components/side_bar.dart';
import 'package:hajeri_demo/constant.dart';
import 'package:hajeri_demo/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
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
    _prepare();

    _fromDate = DateTime.now();
    typeSelectValue = 'All Employee';
    orgId = widget.orgId;

    _getEmployeeList().then(
      (value) => _getAttendanceList().then(
        (value) => setState(
          () {
            isTypeSelected = true;
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

    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    // print("Payload: $payload");
    OpenFile.open(payload);
  }

  Future<String> _prepare() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    // log('$_localPath', name: 'local path');
    return "success";
  }

  Future<String> _findLocalPath() async {
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

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

  Future<void> _getEmployeeList() async {
    List<dynamic> data;
    // String orgId = prefs.getString("worker_id");
    // log(
    //   '$kDropDownListForAttendance$orgId',
    // );
    var response = await http.get(
      '$kDropDownListForAttendance$orgId',
    );

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

    } else {}
  }

  Future<List> _getAttendanceList() async {
    var data;
    // String orgId = prefs.getString("worker_id");
    // await Future.delayed(
    //     Duration(
    //       seconds: 50,
    //     ), () {
    //   attendanceData = kAttendanceMockData;
    // });
    // log('$kMonthlyAttendance$orgId/$typeSelectValue/${_fromDate.toString().substring(0, 7)}');
    var response = await http.get(
        '$kMonthlyAttendance$orgId/$typeSelectValue/${_fromDate.toString().substring(0, 7)}');

    if (response.statusCode == 200) {
      data = json.decode(response.body);
      // print("the data is " + data.toString());

//      print(data);
      if (data is List) {
        attendanceData = data;
      } else {
        attendanceData = data['Visitor List'];
        // log(attendanceData.toString());
      }

      // rows = data
      //     .map<DataRow>((e) => DataRow(
      //           cells: [
      //             DataCell(
      //               Text(
      //                 '${e["name"]}',
      //               ),
      //             ),
      //             DataCell(
      //               Text(
      //                 '${e["intime"]}',
      //               ),
      //             ),
      //             DataCell(
      //               Text(
      //                 '${e["outtime"]}',
      //               ),
      //             ),
      //             DataCell(
      //               Text(
      //                 '${e["visitingdatetime"]}',
      //               ),
      //             ),
      //             DataCell(
      //               Text(
      //                 '${e["currentdate"]}',
      //               ),
      //             ),
      //           ],
      //         ))
      //     .toList();

      // if (attendanceData.length <= 0 || attendanceData == null)
      //   _case = 2;
      // else
      //   _case = 1;

      // print("the attendence list is $attendanceData");

      //state_id=data['id'];
      return attendanceData;
    } else {}
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
        title:
            //  !isAnimationFinished
            //     ? RotateAnimatedTextKit(
            //         totalRepeatCount: 1,
            //         // repeatForever: true,
            //         displayFullTextOnTap: true,
            //         // stopPauseOnTap: true,
            //         onTap: () {
            //           print("Tap Event");
            //         },
            //         text: ["Monthly Attendance", "Hajeri", "हाजिरी"],
            //         textStyle: TextStyle(
            //           fontSize: 20,
            //         ),
            //         onFinished: () {
            //           setState(() {
            //             isAnimationFinished = true;
            //           });
            //         },
            //         // textAlign: TextAlign.center,
            //       )
            //     :
            Text(
          'Attendance',
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
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(
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
                        child: DropdownButtonFormField(
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
                              attendanceData = await _getAttendanceList();

                              setState(() {
                                isTypeSelected = true;
                                showShimmer = false;
                              });
                            }
                          },
                          items: _dropDownTypeMenuItems,
                          hint: const Text(
                            'Select Type',
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
                        : getGridView()

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

  Widget getGridView() {
    switch (typeSelectValue) {
      case 'All Employee':
        return (attendanceData as List).isEmpty
            ? Center(
                child: Text(
                  'No Employee',
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
                child: Text(
                  'No Visitor',
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
            OutlineButton(
              onPressed: () async {
                // await _showDatePicker();
                await _showMonthPicker();
                setState(() {
                  isMonthSelected = true;

                  showShimmer = true;
                });
                attendanceData = await _getAttendanceList();
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
            OutlineButton(
              onPressed: () async {
                // await _showDatePicker();
                await _showMonthPicker();
                setState(() {
                  isMonthSelected = true;

                  showShimmer = true;
                });
                attendanceData = await _getAttendanceList();
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
                OutlineButton(
                  onPressed: () async {
                    // await _showDatePicker();
                    await _showMonthPicker();
                    setState(() {
                      isMonthSelected = true;

                      showShimmer = true;
                    });
                    attendanceData = await _getAttendanceList();
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

    // final excel.Range range1 = sheet.getRangeByName('F8:G8');
    // final excel.Range range2 = sheet.getRangeByName('F9:G9');
    final excel.Range range3 = sheet.getRangeByName('F10:G10');
    final excel.Range range4 = sheet.getRangeByName('F11:G11');
    final excel.Range range5 = sheet.getRangeByName('F12:G12');

    // range1.merge();
    // range2.merge();
    range3.merge();
    range4.merge();
    range5.merge();

    sheet.getRangeByName('F10').setText('DATE');
    range3.cellStyle.fontSize = 8;
    range3.cellStyle.bold = true;
    range3.cellStyle.hAlign = excel.HAlignType.right;

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

    List attendance = attendanceData as List;
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
      for (int i = 1; i <= firstMapLength - 2; i++) {
        sheet.getRangeByIndex(15, 2 + i)..setText('$i');
      }
      sheet.getRangeByIndex(15, 2 + firstMapLength - 1).setText('Mobile');
      // debugger();
      for (int i = 0; i < attendance.length; i++) {
        sheet.getRangeByIndex(16 + i, 2)
          ..setText(attendance[i]['name'])
          ..autoFit();

        for (int j = 1; j < firstMapLength - 2; j++) {
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
        sheet.getRangeByIndex(16 + i, 2 + firstMapLength - 1)
          ..setText(attendance[i]['mobileno'].toString())
          ..autoFit();
      }
    }
    sheet.getRangeByIndex(15, 2, 15, firstMapLength + 1)..cellStyle.bold = true;
    sheet
        .getRangeByIndex(15, 2, 15 + attendance.length, firstMapLength + 1)
        .cellStyle
        .borders
        .all
        .lineStyle = excel.LineStyle.thin;
    sheet.getRangeByIndex(16 + attendance.length, 1).text =
        'hajeri , Aurangabad, Maharashtra | admin@amvenures.com';
    sheet.getRangeByIndex(16 + attendance.length, 1).cellStyle.fontSize = 8;

    final excel.Range range9 = sheet.getRangeByIndex(
        16 + attendance.length, 1, 16 + attendance.length, firstMapLength + 1);
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

    File result = await File('/storage/emulated/0/Download/excel.xlsx')
        .writeAsBytes(bytes);
    if (result != null) {
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max, priority: Priority.high);
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await FlutterLocalNotificationsPlugin().show(
        0,
        'Excel sheet is downloaded',
        'Tap To Open',
        platformChannelSpecifics,
        payload: "/storage/emulated/0/Download/excel.xlsx",
      );
      // OpenFile.open(result.path);
    }
    // debugger();
    Toast.show(
      "Excel Downloaded".toLowerCase(),
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      textColor: Colors.green,
    );
  }
}
