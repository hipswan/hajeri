import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hajeri_demo/components/blue_button.dart';
import 'package:hajeri_demo/components/form_page.dart';
import 'package:hajeri_demo/components/transition.dart';
import 'package:hajeri_demo/main.dart';
import 'package:hajeri_demo/model/Employee.dart';
import 'package:hajeri_demo/url.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

List<Employee> _employees = <Employee>[];

EmployeeDataSource _employeeDataSource;

class EmployeeDataGrid extends StatefulWidget {
  final List<Employee> employees;
  final String view;
  final bool selectionModeDisabled;
  final String orgId;
  EmployeeDataGrid({
    @required this.employees,
    this.view,
    this.selectionModeDisabled,
    this.orgId,
  });
  @override
  _EmployeeDataGridState createState() => _EmployeeDataGridState();
}

class _EmployeeDataGridState extends State<EmployeeDataGrid> {
  Employee currentEmployee;
  final DataGridController _dataGridController = DataGridController();
  bool isRowSelected = false;

  @override
  void initState() {
    super.initState();

    _employees = widget.employees;
    // log(_employees.toString(), name: 'In employee grid');
    _employeeDataSource = EmployeeDataSource(employees: _employees);
  }

  Future<List<dynamic>> getStateList() async {
    List<dynamic> data = [
      {'': ''}
    ];
    print('In get states');
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
    print('In get city');
    log('$kCity/$stateId');
    http.Response response = await http.get('$kCity/$stateId');
    print(
      response.body,
    );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      data = [
        {"id": -1, "cityname": "error couldn't fetch states details"},
      ];
      log('$data');
    }

    return data;
  }

  Future<String> deleteEmployee({Employee employee}) async {
    try {
      log('$kDeleteEmp${employee.number}');
      var response = await http.post('$kDeleteEmp${employee.number}',
          headers: {'Content-Type': 'application/json'},
          body:
              '{nameofworker: ${employee.name},departmentname: ${employee.departmentName},addressline1: ${employee.addressLine1},state: ${employee.state},district: ${employee.district},city: ${employee.city}}');
      log(response.statusCode.toString());
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        log('the delete employee data is $data');

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
      log(e.stackTrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _employees.isEmpty
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
                    'No employee data found',
                  ),
                ],
              ),
            )
          : SfDataGridTheme(
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
                columnWidthMode: ColumnWidthMode.auto,

                allowSorting: true,
                headerGridLinesVisibility: GridLinesVisibility.horizontal,
                controller: _dataGridController,
                source: _employeeDataSource,
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
                columns: [
                  GridTextColumn(
                    // columnWidthMode: ColumnWidthMode.auto,
                    mappingName: 'name',
                    headerText: 'Name',
                    width: 175.0,
                    columnWidthMode: ColumnWidthMode.cells,

                    softWrap: true,
                    headerTextSoftWrap: true,
                    headerStyle: DataGridHeaderCellStyle(
                      sortIconColor: Colors.redAccent,
                    ),
                  ),
                  GridNumericColumn(
                    columnWidthMode: ColumnWidthMode.cells,
                    mappingName: 'number',
                    headerText: 'Mobile',
                    allowSorting: false,
                  ),
                  GridTextColumn(
                    mappingName: 'city',
                    headerText: 'City',
                    allowSorting: false,
                  ),
                  GridNumericColumn(
                    mappingName: 'idCard',
                    headerText: 'ID',
                    allowSorting: false,
                    columnWidthMode: ColumnWidthMode.cells,
                  ),
                  GridTextColumn(
                    mappingName: 'area',
                    headerText: 'Area',
                    allowSorting: false,
                  ),
                  GridTextColumn(
                    mappingName: 'department',
                    headerText: 'Department',
                    allowSorting: false,
                  ),
                  GridTextColumn(
                    mappingName: 'district',
                    headerText: 'District',
                    allowSorting: false,
                  ),
                  GridTextColumn(
                    mappingName: 'state',
                    headerText: 'State',
                    allowSorting: false,
                  ),
                ],
                frozenColumnsCount: 1,
                selectionMode: widget.selectionModeDisabled
                    ? SelectionMode.none
                    : SelectionMode.singleDeselect,
                navigationMode: GridNavigationMode.row,
                onSelectionChanging:
                    (List<Object> addedRows, List<Object> removedRows) {
                  if (addedRows.isNotEmpty &&
                      (addedRows.last as Employee).name == 'Manager') {
                    return false;
                  }

                  return true;
                },
                onSelectionChanged:
                    (List<Object> addedRows, List<Object> removedRows) {
                  // // apply your logic
                  // log((addedRows.last as Employee).name.toString());
                  //After First or Subsequent Select
                  if (addedRows.isNotEmpty) {
                    setState(() {
                      isRowSelected = true;
                      currentEmployee = addedRows.last as Employee;
                    });
                  }
                  //After Deselect
                  if (addedRows.isEmpty && removedRows.isNotEmpty) {
                    setState(() {
                      isRowSelected = false;
                    });
                  }
                },
                stackedHeaderRows: <StackedHeaderRow>[
                  StackedHeaderRow(
                    cells: [
                      StackedHeaderCell(
                        columnNames: [
                          'name',
                          'idCard',
                          'number',
                          'city',
                          'area',
                          'department',
                          'district',
                          'state',
                        ],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(widget.view ?? ''),
                            ),
                            isRowSelected
                                ? Row(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            Employee selectedEmployeeWithEdit =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return FormPage(
                                                  orgId: widget.orgId,
                                                  currentEmployee:
                                                      currentEmployee,
                                                  action: 'edit',
                                                  title:
                                                      'Edit ${currentEmployee.name} ',
                                                );
                                              }),
                                            );
                                            if (selectedEmployeeWithEdit ==
                                                null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                      'Error has occured during edit'),
                                                ),
                                              );
                                            } else {
// / // ignore: unnecessary_statements
                                              (_employees
                                                      .remove(currentEmployee))
                                                  ? _employees.add(
                                                      selectedEmployeeWithEdit)
                                                  : ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            'Error has occured during save'),
                                                      ),
                                                    );
                                            }

                                            _employeeDataSource
                                                .updateDataGridSource();
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            log('Delete');
                                            log((_dataGridController.selectedRow
                                                    as Employee)
                                                .name
                                                .toString());

                                            var deleteStatus =
                                                await deleteEmployee(
                                                    employee: currentEmployee);
                                            log(deleteStatus);
                                            if (deleteStatus
                                                ?.toLowerCase()
                                                .contains('success')) {
                                              if (_employees
                                                  .remove(currentEmployee)) {
                                                log('removed ${currentEmployee.name}');
                                              } else {
                                                log('not removed removed ${currentEmployee.name}');
                                              }
                                            } else {
                                              log('Error while deleteing');
                                            }

// if(success)

                                            //toast if error message

                                            // await getEmployeeList();

                                            _employeeDataSource
                                                .updateDataGridSource();
                                          }),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // StackedHeaderCell(
                  //     columnNames: ['productId', 'product'],
                  //     child: Container(
                  //         color: const Color(0xFFF1F1F1),
                  //         child:
                  //             Center(child: Text('Product Details'))))
                ],
              ),
            ),
    );
  }
}

class EmployeeDataSource extends DataGridSource<Employee> {
  EmployeeDataSource({this.employees});
  final List<Employee> employees;

  @override
  List<Employee> get dataSource => employees;

  @override
  getValue(Employee employee, String columnName) {
    switch (columnName) {
      case 'name':
        return employee.name;
        break;
      case 'idCard':
        return employee.idCardNumber;
        break;
      case 'number':
        return employee.number;
        break;
      case 'city':
        return employee.city;
        break;
      case 'area':
        return employee.area;
        break;
      case 'department':
        return employee.departmentName;
        break;
      case 'district':
        return employee.district;
        break;
      case 'state':
        return employee.state;
        break;
      default:
        return ' ';
        break;
    }
  }

  @override
  int get rowCount => _employees.length;

  void updateDataGridSource() {
    notifyListeners();
  }

  // @override
  // Future<bool> handlePageChange(int oldPageIndex, int newPageIndex,
  //     int startRowIndex, int rowsPerPage) async {
  //   log('$oldPageIndex $startRowIndex $newPageIndex $rowsPerPage  ${_employees.length}');
  //   int endIndex = startRowIndex + rowsPerPage;
  //   if (endIndex > _employees.length) {
  //     endIndex = _employees.length - 1;
  //   }

  //   paginatedDataSource = List.from(
  //       _employees.getRange(startRowIndex, endIndex).toList(growable: false));
  //   notifyListeners();
  //   return true;
  // }
}
