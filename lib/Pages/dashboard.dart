import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform, SocketException;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hajeri_demo/components/employee_data_grid.dart';
import 'package:hajeri_demo/components/box_tile.dart';
import 'package:hajeri_demo/components/history_log.dart';
import 'package:hajeri_demo/components/side_bar.dart';
import 'package:hajeri_demo/components/visitor_data_grid.dart';
import 'package:hajeri_demo/main.dart';
import 'package:hajeri_demo/model/Employee.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

import '../url.dart';

class Dashboard extends StatefulWidget {
  static const id = 'dashboard';
  final String orgId;
  const Dashboard({Key key, this.orgId}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String dashboardView;
  String totalEmployeeCount = "-";
  String todayAttendance = "-";
  String todayVisitorCount = "-";
  String totalVisitorCount = "-";
  bool showShimmer = true;
  // ignore: avoid_init_to_null
  List<dynamic> visitors;
  List<dynamic> history;

  List<Employee> employees;
  String orgId;
  bool isOrg;
  String selectedView = 'Employee List';

  var selected = <String, bool>{
    '1': true,
    '2': false,
    '3': false,
    '4': false,
  };

  Future<void> _getData() async {
    // String orgId = prefs.getString("worker_id");
    var response = await http.get(
      Uri.parse("https://www.hajeri.in/apidev/org/dashboard/$orgId"),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("the _getData  data is " + data.toString());

//      print(data);
      setState(() {
        //department_list = data;

        print("the map is " + data["total_emp_count"].toString());
        totalEmployeeCount = data["total_emp_count"].toString();
        todayAttendance = data["total_attendance_count"].toString();
        todayVisitorCount = data["total_today_visitor_count"].toString();
        totalVisitorCount = data["total_visitor_count"].toString();
        //state_id=data['id'];
      });
    }
  }

  Future<String> _getEmployeeList() async {
    // String orgId = prefs.getString("worker_id");

    log("$kEmployeeList$orgId");
    try {
      var response = await http.get(Uri.parse("$kEmployeeList$orgId"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // log("the _getEmployeeList data is " + data.toString());
        if (data.isNotEmpty) {
          employees = data
              .map<Employee>(
                (e) => Employee(
                    name: e["nameofworker"],
                    number:
                        e["mobileno"] == null ? 0 : int.parse(e["mobileno"]),
                    idCardNumber: int.parse('0'),
                    organizationName: e["organizationname"],
                    departmentName: e["departmentname"],
                    city: e["city"],
                    area: e["area"],
                    district: e["district"],
                    state: e["state"]),
              )
              .toList();
          return 'employee';
        } else {
          return 'absent';
        }
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } catch (e) {
      return 'error occurred';
    }
  }

  Future<String> _getTodayPresentEmployeeList() async {
    // String orgId = prefs.getString("worker_id");

    log("$kTodayPresentEmpList$orgId");
    try {
      var response = await http.get(Uri.parse("$kTodayPresentEmpList$orgId"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // print("the _getTodayPresentEmployeeList data is " + data.toString());
        bool emptyData = data.isEmpty;

        if (!emptyData) {
          employees = data
              .map<Employee>(
                (e) => Employee(
                    name: e["nameofworker"],
                    number: int.parse(e["clientmobno"]),
                    idCardNumber: int.parse(e["clientid"]),
                    organizationName: e["organizationname"],
                    city: e["visitingcity"],
                    area: e["visitingcityto"],
                    district: e["passavailableornot"],
                    state: e["passavailableornot"]),
              )
              .toList();
          return 'employee';
        } else {
          return 'absent';
        }
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } catch (e) {
      return 'error occurred';
    }
  }

  // ignore: missing_return
  Widget getDashboardView() {
    switch (dashboardView) {
      case "employee":
        return EmployeeDataGrid(
          employees: employees,
          view: selectedView,
          selectionModeDisabled: true,
        );
        break;
      case "visitor":
        return VisitorDataGrid(
          attendanceSheet: visitors,
        );
        break;
      case "history":
        return HistoryLog(
          data: history,
        );
        break;
      case "absent":
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
    }
  }

  Future<String> _getTodayVisitorList() async {
    log("$kTodayVisitor$orgId");
    try {
      var response = await http.get(Uri.parse("$kTodayVisitor$orgId"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        log("the _getTodayVisitorList data is " + data.toString());
        if (data.isEmpty) {
          return 'absent';
        } else {
          visitors = data;
          return 'visitor';
        }
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } catch (e) {
      return 'error occurred';
    }
  }

  Future<String> _getEmployeeHistory() async {
    log("$kEmployeeHistory");
    try {
      var response = await http.get(Uri.parse("$kEmployeeHistory"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // log("the _getTodayVisitorList data is " + data.toString());
        if (data.isEmpty) {
          return 'absent';
        } else {
          history = data;
          return 'history';
        }
      } else {
        //   history = <Map>[
        //     {
        //       "suborgname": "Am ventures",
        //       "date": DateTime.now().millisecondsSinceEpoch,
        //       "clientmobno": "8898287538"
        //     },
        //     {
        //       "suborgname": "Am ventures",
        //       "date": DateTime.now().millisecondsSinceEpoch,
        //       "clientmobno": "8898287538"
        //     },
        //     {
        //       "suborgname": "Am ventures",
        //       "date": DateTime.now().millisecondsSinceEpoch,
        //       "clientmobno": "8898287538"
        //     }
        //   ];
        //   return 'history';
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } catch (e) {
      return 'error occurred';
    }
  }

  Future<String> _getOneMonthVisitorList() async {
    // String orgId = prefs.getString("worker_id");
    log("$kVisitorOneMonthList$orgId");
    try {
      var response = await http.get(Uri.parse("$kVisitorOneMonthList$orgId"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        log("the _getTotal VisitorList data is " + data.toString());
        if (data.isEmpty) {
          return 'absent';
        } else {
          visitors = data;
          return 'visitor';
        }
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } catch (e) {
      return 'error occurred';
    }
  }

  @override
  void initState() {
    super.initState();
    orgId = widget.orgId;
    isOrg = prefs.getBool('is_org');
    if (isOrg) {
      dashboardView = "employee";

      _getData();
      _getEmployeeList().then((value) {
        showShimmer = false;
        dashboardView = value;
        setState(() {});
      });
    } else {
      dashboardView = "history";
      _getEmployeeHistory().then((value) {
        showShimmer = false;
        dashboardView = value;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

//Drawer

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //Drawer

      drawer: widget.orgId.contains(prefs.getString('worker_id'))
          ? Drawer(
              child: SideBar(
                section: 'dashboard',
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          'Dashboard',
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),

      //body
      body: Container(
        padding: EdgeInsets.only(
          top: 8.0,
          left: 5,
          right: 5,
          bottom: 0.0,
        ),
        height: size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            isOrg
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BoxTile(
                        size: Size(
                          size.width * 0.5 * 0.75,
                          Platform.isIOS ? 64 : size.height * 0.5 * 0.30,
                        ),
                        color: Color(0xff17a2b8),
                        onPressed: () async {
                          if (!selected['1']) {
                            selected = <String, bool>{
                              '1': false,
                              '2': false,
                              '3': false,
                              '4': false,
                            };
                            selected['1'] = true;
                            selectedView = 'Employee List';
                            showShimmer = true;
                            setState(() {});
                            dashboardView = await _getEmployeeList();
                            showShimmer = false;
                            setState(() {});
                          }
                        },
                        selected: selected['1'],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Employee',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              totalEmployeeCount,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BoxTile(
                        size: Size(
                          size.width * 0.5 * 0.75,
                          Platform.isIOS ? 64 : size.height * 0.5 * 0.30,
                        ),
                        color: Color(0xff28a745),
                        onPressed: () async {
                          if (!selected['2']) {
                            selected = <String, bool>{
                              '1': false,
                              '2': false,
                              '3': false,
                              '4': false,
                            };
                            selected['2'] = true;
                            selectedView = '''Today's Attendance''';

                            showShimmer = true;
                            setState(() {});
                            dashboardView =
                                await _getTodayPresentEmployeeList();
                            if (employees.first.name.isEmpty) {
                              employees = [];
                            }
                            showShimmer = false;
                            setState(() {});
                          }
                        },
                        selected: selected['2'],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '''Today's Attendance''',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              todayAttendance,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
            isOrg
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BoxTile(
                        size: Size(
                          size.width * 0.5 * 0.75,
                          Platform.isIOS ? 64 : size.height * 0.5 * 0.30,
                        ),
                        color: Color(0xffffc107),
                        onPressed: () async {
                          if (!selected['3']) {
                            selected = <String, bool>{
                              '1': false,
                              '2': false,
                              '3': false,
                              '4': false,
                            };
                            selected['3'] = true;
                            selectedView = '''Today's Visitor''';

                            showShimmer = true;
                            setState(() {});
                            dashboardView = await _getTodayVisitorList();

                            showShimmer = false;
                            setState(() {});
                          }
                        },
                        selected: selected['3'],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '''Today's Visitor''',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              todayVisitorCount,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BoxTile(
                        size: Size(
                          size.width * 0.5 * 0.75,
                          Platform.isIOS ? 64 : size.height * 0.5 * 0.30,
                        ),
                        color: Color(0xffdc3545),
                        selected: selected['4'],
                        onPressed: () async {
                          if (!selected['4']) {
                            selected = <String, bool>{
                              '1': false,
                              '2': false,
                              '3': false,
                              '4': false,
                            };
                            selected['4'] = true;
                            selectedView = '''Total Visitor''';

                            showShimmer = true;
                            setState(() {});
                            dashboardView = await _getOneMonthVisitorList();

                            showShimmer = false;
                            setState(() {});
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Visitor',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              totalVisitorCount,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
            isOrg
                ? SizedBox(
                    height: 18,
                  )
                : Container(),
            Expanded(
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
                  : getDashboardView(),
              // EmployeeTable(datasource: employees),
            ),
          ],
        ),
      ),
    );
  }
}
