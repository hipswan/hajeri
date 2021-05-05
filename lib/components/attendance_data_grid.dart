import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:hajeri_demo/model/Employee.dart';
import 'package:hajeri_demo/url.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:http/http.dart' as http;

List<dynamic> _attendances = [];
AttendanceDataSource _attendanceDataSource;

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
  List<GridColumn> _gridColumn = [
    GridTextColumn(
      // columnWidthMode: ColumnWidthMode.auto,
      mappingName: 'name',
      headerText: 'Name',
      width: 175.0,
      softWrap: true,
      headerTextSoftWrap: true,
      headerStyle: DataGridHeaderCellStyle(
        sortIconColor: Colors.redAccent,
      ),
    ),
  ];
  Map referenceAttendance = {};

  @override
  void initState() {
    super.initState();

    _attendances = widget.attendanceSheet;
    // log(_attendances.toString(), name: 'In Attendance Grid Init');

    referenceAttendance = (_attendances.first as Map);
    //TODO: Add list to attendances
    // log(referenceAttendance.length.toString(), name: 'In Attendance Grid Init');

    for (int i = 1; i <= referenceAttendance.length - 2; i++) {
      _gridColumn.add(
        GridWidgetColumn(
          columnWidthMode: ColumnWidthMode.cells,
          mappingName: i.toString(),
          headerText: i.toString(),
          width: 64.0,
          softWrap: true,
          headerTextSoftWrap: true,
          headerStyle: DataGridHeaderCellStyle(
            sortIconColor: Colors.redAccent,
          ),
        ),
      );
    }
    _gridColumn.add(
      GridNumericColumn(
        columnWidthMode: ColumnWidthMode.lastColumnFill,
        mappingName: 'mobileno',
        headerText: 'Mobile',
        softWrap: true,
        headerTextSoftWrap: true,
        headerStyle: DataGridHeaderCellStyle(
          sortIconColor: Colors.redAccent,
        ),
      ),
    );
    _attendanceDataSource = AttendanceDataSource(attendanceSheet: _attendances);
    // debugger();
  }

  Future<List<dynamic>> getStateList() async {
    List<dynamic> data = [
      {'': ''}
    ];
    // print('In get states');
    log(kStates);
    http.Response response = await http.get(kStates);

    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      data = [
        {"id": -1, "statename": "error couldn't fetch states details"},
      ];
      log('$data');
    }

    return data;
  }

  Future<List<dynamic>> getCityList(String stateId) async {
    List<dynamic> data = [
      {'': ''}
    ];
    // print('In get city');
    // log('$kCity/$stateId');
    http.Response response = await http.get('$kCity/$stateId');
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
      var response = await http.post('$kDeleteEmp${employee.number}',
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
        headerStyle: DataGridHeaderCellStyle(
          textStyle: TextStyle(
            // fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue[800],
        ),
        selectionStyle: DataGridCellStyle(
          backgroundColor: Colors.redAccent,
          textStyle: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        currentCellStyle: DataGridCurrentCellStyle(
          borderWidth: 2,
          borderColor: Colors.pinkAccent,
        ),
      ),
      child: SfDataGrid(
        gridLinesVisibility: GridLinesVisibility.both,
        rowHeight: 75.0,
        columnWidthMode: ColumnWidthMode.auto,
        // ignore: missing_return
        cellBuilder: (BuildContext context, GridColumn column, int rowIndex) {
          if (column.mappingName != 'name' &&
              column.mappingName != 'mobileno') {
            String currentAttendance =
                (_attendances[rowIndex] as Map)[column.mappingName];
            return !currentAttendance.contains('A')
                ? Container(
                    height: 75.0,
                    padding: EdgeInsets.only(
                      left: 5.0,
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
                : Text('');
          }
        },
        allowSorting: true,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
        controller: _dataGridController,
        source: _attendanceDataSource,
        // headerCellBuilder:
        //     (BuildContext context, GridColumn column) {
        //   if (column.mappingName == 'number')
        //     return Row(
        //       children: <Widget>[
        //         Icon(Icons.phone_android),
        //         SizedBox(width: 5),
        //         Flexible(
        //             child: Text(
        //           column.headerText,
        //           style: TextStyle(fontWeight: FontWeight.bold),
        //         ))
        //       ],
        //     );
        //   else
        //     return null;
        // },
        columns: _gridColumn,
        frozenColumnsCount: 1,
        selectionMode: SelectionMode.none,

        navigationMode: GridNavigationMode.row,
        onSelectionChanging:
            (List<Object> addedRows, List<Object> removedRows) {
          if (addedRows.isNotEmpty &&
              (addedRows.last as Employee).name == 'Manager') {
            return false;
          }

          return true;
        },

//                       stackedHeaderRows: <StackedHeaderRow>[
//                         StackedHeaderRow(
//                           cells: [
//                             StackedHeaderCell(
//                               columnNames: [
//                                 'name',
//                                 'idCard',
//                                 'number',
//                                 'city',
//                                 'area',
//                                 'district',
//                                 'state',
//                               ],
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     child: Text(widget.view ?? ''),
//                                   ),
//                                   isRowSelected
//                                       ? Row(
//                                           children: [
//                                             IconButton(
//                                                 icon: Icon(
//                                                   Icons.edit,
//                                                   color: Colors.blue,
//                                                 ),
//                                                 onPressed: () async {
//                                                   log('Edit');
//                                                   log((_dataGridController
//                                                               .selectedRow
//                                                           as Employee)
//                                                       .name
//                                                       .toString());

//                                                   Employee
//                                                       selectedEmployeeWithEdit =
//                                                       await Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) {
//                                                       return FormPage(
//                                                         currentEmployee:
//                                                             currentEmployee,
//                                                         action: 'edit',
//                                                       );
//                                                     }),
//                                                   );
//                                                   if (selectedEmployeeWithEdit ==
//                                                       null) {
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       SnackBar(
//                                                         content: const Text(
//                                                             'Error has occured during edit'),
//                                                       ),
//                                                     );
//                                                   } else {
// // / // ignore: unnecessary_statements
//                                                     (_employees.remove(
//                                                             currentEmployee))
//                                                         ? _employees.add(
//                                                             selectedEmployeeWithEdit)
//                                                         : ScaffoldMessenger.of(
//                                                                 context)
//                                                             .showSnackBar(
//                                                             SnackBar(
//                                                               content: const Text(
//                                                                   'Error has occured during save'),
//                                                             ),
//                                                           );
//                                                   }

//                                                   _employeeDataSource
//                                                       .updateDataGridSource();
//                                                 }),
//                                             IconButton(
//                                                 icon: Icon(
//                                                   Icons.delete,
//                                                   color: Colors.redAccent,
//                                                 ),
//                                                 onPressed: () async {
//                                                   log('Delete');
//                                                   log((_dataGridController
//                                                               .selectedRow
//                                                           as Employee)
//                                                       .name
//                                                       .toString());

//                                                   var deleteStatus =
//                                                       await deleteEmployee(
//                                                           employee:
//                                                               currentEmployee);
//                                                   log(deleteStatus);
//                                                   if (deleteStatus
//                                                       ?.toLowerCase()
//                                                       .contains('success')) {
//                                                     if (_employees.remove(
//                                                         currentEmployee)) {
//                                                       log('removed ${currentEmployee.name}');
//                                                     } else {
//                                                       log('not removed removed ${currentEmployee.name}');
//                                                     }
//                                                   } else {
//                                                     log('Error while deleteing');
//                                                   }

// // if(success)

//                                                   //toast if error message

//                                                   // await getEmployeeList();

//                                                   _employeeDataSource
//                                                       .updateDataGridSource();
//                                                 }),
//                                           ],
//                                         )
//                                       : Container(),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         // StackedHeaderCell(
//                         //     columnNames: ['productId', 'product'],
//                         //     child: Container(
//                         //         color: const Color(0xFFF1F1F1),
//                         //         child:
//                         //             Center(child: Text('Product Details'))))
//                       ],
      ),
    );
  }
}

class AttendanceDataSource extends DataGridSource {
  AttendanceDataSource({this.attendanceSheet});

  final List<dynamic> attendanceSheet;

  @override
  List<dynamic> get dataSource => attendanceSheet;

  @override
  getValue(Object attendance, String columnName) {
    // log(columnName, name: 'In attendance data Grid');
    switch (columnName) {
      case 'name':
        return (attendance as Map)[columnName].toString();
        break;
      case 'mobileno':
        return (attendance as Map)[columnName].toString() ?? '';
        break;
      default:
        return Text(
          (attendance as Map)[columnName].toString(),
          style: TextStyle(
            color: Colors.redAccent,
          ),
        );
    }
  }

  @override
  int get rowCount => _attendances.length;

  void updateDataGridSource() {
    notifyListeners();
  }

  // @override
  // Future<bool> handlePageChange(int oldPageIndex, int newPageIndex,
  //     int startRowIndex, int rowsPerPage) async {
  //   log('$oldPageIndex $startRowIndex $newPageIndex $rowsPerPage  ${_attendances.length}');
  //   int endIndex = startRowIndex + rowsPerPage;
  //   if (endIndex > _attendances.length) {
  //     endIndex = _attendances.length - 1;
  //   }

  //   paginatedDataSource = List.from(
  //       _attendances.getRange(startRowIndex, endIndex).toList(growable: false));
  //   notifyListeners();
  //   return true;
  // }
}
