import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:hajeri/constant.dart';

import '../model/Employee.dart';
import '../url.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:http/http.dart' as http;

List<dynamic> _attendances = [];
AttendanceDataSource _attendanceDataSource;
Map referenceAttendance = {};
List<GridColumn> _gridColumn;

class AttendanceDataGrid extends StatefulWidget {
  final List<dynamic> attendanceSheet;
  final String type;

  AttendanceDataGrid({
    @required this.attendanceSheet,
    this.type,
  });
  @override
  _AttendanceDataGridState createState() => _AttendanceDataGridState();
}

class _AttendanceDataGridState extends State<AttendanceDataGrid> {
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    _gridColumn = [
      GridTextColumn(
        width: 175,
        columnName: 'name',
        label: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Name',
            style: kDataGridHeaderTextStyle,
          ),
        ),
      )
    ];
    _attendances = widget.attendanceSheet;

    for (int i = 1; i <= 31; i++) {
      _gridColumn.add(GridTextColumn(
        width: 65.0,
        columnName: i.toString(),
        label: Container(
          alignment: Alignment.center,
          child: Text(
            i.toString(),
            style: kDataGridHeaderTextStyle,
          ),
        ),
      ));
    }
    _gridColumn.add(
      GridTextColumn(
        width: 100,
        columnName: 'mobileno',
        label: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mobile',
            style: kDataGridHeaderTextStyle,
          ),
        ),
      ),
    );
    _attendanceDataSource = AttendanceDataSource(attendanceSheet: _attendances);
  }

  Future<List<dynamic>> getStateList() async {
    List<dynamic> data = [
      {'': ''}
    ];
    http.Response response = await http.get(Uri.parse(kStates));

    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      data = [
        {"id": -1, "statename": "error couldn't fetch states details"},
      ];
    }

    return data;
  }

  Future<List<dynamic>> getCityList(String stateId) async {
    List<dynamic> data = [
      {'': ''}
    ];
    // print('In get city');
    http.Response response = await http.get(Uri.parse('$kCity/$stateId'));
    // print(
    //   response.body,
    // );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      data = [
        {"id": -1, "cityname": "error couldn't fetch states details"},
      ];
      // log('$data');
    }

    return data;
  }

  Future<String> deleteEmployee({Employee employee}) async {
    try {
      // log('$kDeleteEmp${employee.number}');
      var response = await http.post(Uri.parse('$kDeleteEmp${employee.number}'),
          headers: {'Content-Type': 'application/json'},
          body:
              '{nameofworker: ${employee.name},departmentname: ${employee.departmentName},addressline1: ${employee.addressLine1},state: ${employee.state},district: ${employee.district},city: ${employee.city}}');
      // log(response.statusCode.toString());
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // log('the delete employee data is $data');

        return data['success_message']
                .toString()
                .trim()
                .toLowerCase()
                .contains('success')
            ? 'success'
            : '';
      } else {
        return 'response not received with ${response.statusCode}';
      }
    } on NoSuchMethodError catch (e) {
      // log(e.stackTrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        gridLineColor: Colors.grey,
        gridLineStrokeWidth: 0.5,
        headerColor: Colors.blue[800],
      ),
      child: SfDataGrid(
        rowHeight: 60,
        gridLinesVisibility: GridLinesVisibility.both,
        allowSorting: true,
        headerGridLinesVisibility: GridLinesVisibility.both,
        controller: _dataGridController,
        source: _attendanceDataSource,
        columns: _gridColumn,
        frozenColumnsCount: 1,
        selectionMode: SelectionMode.none,
        navigationMode: GridNavigationMode.row,
      ),
    );
  }
}

class AttendanceDataSource extends DataGridSource {
  AttendanceDataSource({this.attendanceSheet}) {
    buildAttendanceSheet();
  }

  final List attendanceSheet;

  void buildAttendanceSheet() {
    dataGridRows = attendanceSheet.map<DataGridRow>(
      (dataGridRow) {
        return DataGridRow(
          cells: _gridColumn
              .map<DataGridCell>(
                (employee) => DataGridCell<String>(
                  columnName: employee.columnName.toString(),
                  value: dataGridRow[employee.columnName.toString()].toString(),
                ),
              )
              .toList(),
        );
      },
    ).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        Widget getAttendanceWidget() {
          if (dataGridCell.columnName != 'name' &&
              dataGridCell.columnName != 'mobileno') {
            String currentAttendance = dataGridCell.value.toString();
            return !currentAttendance.contains('A')
                ? Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Scrollbar(
                      key: UniqueKey(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentAttendance
                                  .substring(
                                    currentAttendance.indexOf('[') + 1,
                                    currentAttendance.indexOf(']'),
                                  )
                                  .replaceAll(RegExp(r';'), ' '),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container();
          } else {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Text(
                dataGridCell.value.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }
        }

        return getAttendanceWidget();
      }).toList(),
    );
  }
}
