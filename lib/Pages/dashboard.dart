import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:hajeri_demo/components/employee_data_grid.dart';
import 'package:hajeri_demo/components/box_tile.dart';
import 'package:hajeri_demo/components/side_bar.dart';
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
  String totalEmployeeCount = "-";
  String todayAttendance = "-";
  String todayVisitorCount = "-";
  String totalVisitorCount = "-";
  bool showShimmer = true;
  // ignore: avoid_init_to_null
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

  Future<List<Employee>> _getEmployeeList() async {
    // String orgId = prefs.getString("worker_id");
    List<Employee> employeeList = [];
    log("$kEmployeeList$orgId");
    var response = await http.get(Uri.parse("$kEmployeeList$orgId"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // log("the _getEmployeeList data is " + data.toString());
      employeeList = data
          .map<Employee>(
            (e) => Employee(
                name: e["nameofworker"],
                number: e["mobileno"] == null ? 0 : int.parse(e["mobileno"]),
                idCardNumber: int.parse('0'),
                organizationName: e["organizationname"],
                departmentName: e["departmentname"],
                city: e["city"],
                area: e["area"],
                district: e["district"],
                state: e["state"]),
          )
          .toList();
    } else {
      employeeList.add(Employee.empty());
    }

    return employeeList;
  }

  Future<List<Employee>> _getTodayPresentEmployeeList() async {
    // String orgId = prefs.getString("worker_id");
    List<Employee> employeeList = [];
    log("$kTodayVisitor$orgId");
    var response = await http.get(Uri.parse("$kTodayPresentEmpList$orgId"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // print("the _getTodayPresentEmployeeList data is " + data.toString());
      bool emptyData = data.isEmpty;

      if (!emptyData) {
        employeeList = data
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
      } else {
        employeeList.add(Employee.empty());
      }
    } else {
      employeeList.add(Employee.error());
    }

    return employeeList;
  }

  Future<List<Employee>> _getTodayVisitorList() async {
    // String orgId = prefs.getString("worker_id");
    List<Employee> employeeList = [];
    log("$kTodayVisitor$orgId");
    var response = await http.get(Uri.parse("$kTodayVisitor$orgId"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // print("the _getTodayVisitorList data is " + data.toString());
      bool emptyData = data.isEmpty;

      if (!emptyData) {
        employeeList = data
            .map<Employee>(
              (e) => Employee(
                  name: e["nameofworker"],
                  number: int.parse(e["mobileno"] ?? 0),
                  idCardNumber: int.parse('0'),
                  organizationName: e["organizationname"],
                  city: e["city"],
                  area: e["area"],
                  district: e["district"],
                  state: e["state"]),
            )
            .toList();
      } else {
        employeeList.add(Employee.empty());
      }
    } else {
      employeeList.add(Employee.error());
    }

    return employeeList;
  }

  Future<List<Employee>> _getOneMonthVisitorList() async {
    // String orgId = prefs.getString("worker_id");
    List<Employee> employeeList = [];
    log("$kVisitorOneMonthList$orgId");
    var response = await http.get(
      Uri.parse("$kVisitorOneMonthList$orgId"),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print("the _getTodayOneMonthVisitorList data is " + data.toString());
      bool emptyData = data.isEmpty;

      if (!emptyData) {
        employeeList = data
            .map<Employee>(
              (e) => Employee(
                name: e["nameofworker"],
                number: int.parse(e["clientmobno"]),
                idCardNumber: int.parse('0'),
                organizationName: e["shopkeeperid"],
                // city: e["city"],
                // area: e["area"],
                departmentName: e["departmentname"],
                // district: e["district"],
                // state: e["state"],
              ),
            )
            .toList();
      } else {
        employeeList.add(Employee.empty());
      }
    } else {
      employeeList.add(Employee.error());
    }

    return employeeList;
  }

  @override
  void initState() {
    super.initState();
    orgId = widget.orgId;
    isOrg = prefs.getBool('is_org');
    log('condition is ${widget.orgId.contains(prefs.getString('worker_id'))}');
    if (isOrg) {
      _getData();

      _getEmployeeList().then((employeelist) {
        showShimmer = false;
        employees = employeelist;
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
      body: isOrg
          ? Container(
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
                  Row(
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
                            employees = await _getEmployeeList();
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
                            employees = await _getTodayPresentEmployeeList();
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
                  ),
                  Row(
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
                            employees = await _getTodayVisitorList();
                            if (employees.first.name.isEmpty) {
                              employees = [];
                            }
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
                            employees = await _getOneMonthVisitorList();
                            if (employees.first.name.isEmpty) {
                              employees = [];
                            }
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
                  ),
                  SizedBox(
                    height: 18,
                  ),
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
                                            children:
                                                List.generate(10, (index) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  bottom: 12.0,
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
                            employees: employees,
                            view: selectedView,
                            selectionModeDisabled: true,
                          ),
                    // EmployeeTable(datasource: employees),
                  ),
                ],
              ),
            )
          : Center(
              child: Text(
                'Employee History',
              ),
            ),
    );
  }
}
