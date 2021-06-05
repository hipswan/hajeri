import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hajeri/constant.dart';
import '../components/form_page.dart';
import '../main.dart';
import '../model/Employee.dart';
import '../url.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:http/http.dart' as http;

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
    _employeeDataSource = EmployeeDataSource();
  }

  Future<String> deleteEmployee({Employee employee}) async {
    try {
      log('$kDeleteEmp${employee.number}');
      var response = await http.post(Uri.parse('$kDeleteEmp${employee.number}'),
          headers: {'Content-Type': 'application/json'},
          body:
              '{nameofworker: ${employee.name},departmentname: ${employee.departmentName},addressline1: ${employee.addressLine1},state: ${employee.state},district: ${employee.district},city: ${employee.city}}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        log('the delete employee data is $data');

        return data['success_message']
                .toString()
                .trim()
                .toLowerCase()
                .contains('success')
            ? 'success'
            : 'failure';
      } else {
        return 'response not received with ${response.statusCode}';
      }
    } on IOException catch (e) {
      log(e.toString());
      return 'internet isssue';
    } catch (e) {
      return 'failure';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          gridLineColor: Colors.grey,
          gridLineStrokeWidth: 0.5,
          headerColor: Colors.blue[800],
          selectionColor: Colors.blue[100],
          frozenPaneElevation: 1,
          sortIconColor: Colors.white,
        ),
        child: SfDataGrid(
          headerGridLinesVisibility: GridLinesVisibility.both,
          gridLinesVisibility: GridLinesVisibility.both,
          controller: _dataGridController,
          allowSorting: true,
          source: _employeeDataSource,
          isScrollbarAlwaysShown: true,
          columnWidthMode: ColumnWidthMode.fill,
          columns: [
            GridTextColumn(
              columnName: 'name',
              label: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Name',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
              width: 175.0,
            ),
            GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              columnName: 'id',
              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'ID',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
            GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              columnName: 'number',
              width: 150,

              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'Number',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
            GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              width: 150,

              columnName: 'address',
              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'Address',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
            GridTextColumn(
              width: 150,
              columnName: 'department',
              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'Department',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
            GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              width: 150,

              columnName: 'city',
              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'City',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
            GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              width: 150,

              columnName: 'district',
              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'District',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
            GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              columnName: 'state',
              width: 150,

              label: Container(
                alignment: Alignment.center,
                child: Text(
                  'State',
                  style: kDataGridHeaderTextStyle,
                ),
              ),
            ),
          ],
          frozenColumnsCount: 1,
          selectionMode: widget.selectionModeDisabled
              ? SelectionMode.none
              : SelectionMode.singleDeselect,
          navigationMode: GridNavigationMode.row,
          onSelectionChanged:
              (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
            // // apply your logic
            //After First or Subsequent Select
            if (addedRows.isNotEmpty) {
              var selectedEmployee = addedRows.first.getCells();

              setState(() {
                isRowSelected = true;
                currentEmployee = Employee(
                  name: selectedEmployee[0].value,
                  idCardNumber: selectedEmployee[1].value,
                  number: selectedEmployee[2].value,
                  addressLine1: selectedEmployee[3].value,
                  departmentName: selectedEmployee[4].value,
                  city: selectedEmployee[5].value,
                  district: selectedEmployee[6].value,
                  state: selectedEmployee[7].value,
                );
              });
            }
            //After Deselect
            if (addedRows.isEmpty) {
              setState(() {
                isRowSelected = false;
              });
            }
          },
          stackedHeaderRows: widget.selectionModeDisabled
              ? []
              : <StackedHeaderRow>[
                  StackedHeaderRow(
                    cells: [
                      StackedHeaderCell(
                        columnNames: [
                          'name',
                          'id',
                          'number',
                          'address',
                          'department',
                          'city',
                          'district',
                          'state',
                        ],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                widget.view ?? '',
                                style: kDataGridHeaderTextStyle,
                              ),
                            ),
                            isRowSelected
                                ? Row(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.white,
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
                                                      'no action taken while editing'),
                                                ),
                                              );
                                            } else if (selectedEmployeeWithEdit
                                                .name.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                      'Error has occured during edit'),
                                                ),
                                              );
                                            } else {
// / // ignore: unnecessary_statements
                                              _employees.removeWhere(
                                                  (employee) =>
                                                      employee.name ==
                                                      currentEmployee.name);

                                              _employees.add(
                                                  selectedEmployeeWithEdit);
                                              // ScaffoldMessenger.of(
                                              //         context)
                                              //     .showSnackBar(
                                              //     SnackBar(
                                              //       content: const Text(
                                              //           'Error has occured during save'),
                                              //     ),
                                              //   );
                                              _employeeDataSource
                                                  .buildDataGridRows();
                                              _employeeDataSource
                                                  .updateDataGridSource();
                                            }
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            var employee = currentEmployee;
                                            bool isMainEmployee = employee
                                                .number
                                                .toString()
                                                .contains(
                                                    prefs.getString('mobile'));
                                            if (!isMainEmployee) {
                                              bool delete = await showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                          child: Text('Yes'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                          child: Text('No'),
                                                        )
                                                      ],
                                                      title: Text(
                                                          'Delete Employee'),
                                                      content: Text(
                                                        'Do you want to delete your employee: ${employee.name} ?',
                                                      ),
                                                    );
                                                  });
                                              if (delete) {
                                                var deleteStatus =
                                                    await deleteEmployee(
                                                        employee:
                                                            currentEmployee);
                                                log(deleteStatus);
                                                if (deleteStatus
                                                    .toLowerCase()
                                                    .contains('success')) {
                                                  // if (_employees.remove(
                                                  //     currentEmployee)) {
                                                  //   log('removed ${currentEmployee.name}');
                                                  // } else {
                                                  //   log('not removed ${currentEmployee.name}');
                                                  // }
                                                  _employees.removeWhere(
                                                      (employee) =>
                                                          employee.name ==
                                                          currentEmployee.name);
                                                  _employeeDataSource
                                                      .buildDataGridRows();
                                                  _employeeDataSource
                                                      .updateDataGridSource();
                                                } else {
                                                  log('Error while deleting');
                                                }

                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('back'),
                                                          )
                                                        ],
                                                        title: Text(
                                                            'Delete Employees'),
                                                        content: Text(
                                                          deleteStatus,
                                                        ),
                                                      );
                                                    });
                                              }
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Back'),
                                                        ),
                                                      ],
                                                      title: Text(
                                                          'Delete Employee'),
                                                      content: Text(
                                                        'You cannot delete yourself',
                                                      ),
                                                    );
                                                  });
                                            }
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

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource() {
    buildDataGridRows();
  }

  void buildDataGridRows() {
    dataGridRows = _employees
        .map<DataGridRow>(
          (dataGridRow) => DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'name',
                value: dataGridRow.name,
              ),
              DataGridCell<int>(
                columnName: 'id',
                value: dataGridRow.idCardNumber,
              ),
              DataGridCell<int>(
                columnName: 'number',
                value: dataGridRow.number,
              ),
              DataGridCell<String>(
                columnName: 'address',
                value: dataGridRow.addressLine1,
              ),
              DataGridCell<String>(
                  columnName: 'department', value: dataGridRow.departmentName),
              DataGridCell<String>(
                columnName: 'city',
                value: dataGridRow.city,
              ),
              DataGridCell<String>(
                columnName: 'district',
                value: dataGridRow.district,
              ),
              DataGridCell<String>(
                columnName: 'state',
                value: dataGridRow.state,
              ),
            ],
          ),
        )
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: dataGridCell.columnName.toString().contains('name')
            ? Alignment.centerLeft
            : Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }).toList());
  }

  @override
  bool shouldRecalculateColumnWidths() {
    return true;
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
