import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
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

List<dynamic> _visitors = [];
VisitorDataSource _visitorDataSource;

class VisitorDataGrid extends StatefulWidget {
  final List<dynamic> attendanceSheet;
  final String type;

  VisitorDataGrid({
    @required this.attendanceSheet,
    this.type,
  });
  @override
  _VisitorDataGridState createState() => _VisitorDataGridState();
}

class _VisitorDataGridState extends State<VisitorDataGrid> {
  Map referenceMap;
  final DataGridController _dataGridController = DataGridController();

  List<GridColumn> _gridColumn = [
    GridTextColumn(
      // columnWidthMode: ColumnWidthMode.auto,
      mappingName: 'nameofworker',
      headerText: 'Name',
      width: 175.0,
      softWrap: true,
      headerTextSoftWrap: true,
      headerStyle: DataGridHeaderCellStyle(
        sortIconColor: Colors.redAccent,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _visitors = widget.attendanceSheet.sublist(0);
    // log(_visitors.toString(), name: 'In visitor init');
    _visitorDataSource = VisitorDataSource(visitors: _visitors);
    // debugger();
    referenceMap = json.decode(json.encode(_visitors.first));
    referenceMap.remove('nameofworker');
    // log(_visitors.toString(), name: 'In visitor init');

    //First element of reference map has been altered
    // ignore: missing_return
    _gridColumn.addAll(referenceMap.entries.map<GridColumn>((visitor) {
      return visitor.key.toString().trim().toLowerCase().contains('date')
          ? GridDateTimeColumn(
              columnWidthMode: ColumnWidthMode.cells,
              mappingName: visitor.key,
              headerText: visitor.key,
              softWrap: true,
              headerTextSoftWrap: true,
              headerStyle: DataGridHeaderCellStyle(
                sortIconColor: Colors.redAccent,
              ),
            )
          : GridTextColumn(
              // columnWidthMode: ColumnWidthMode.auto,
              mappingName: visitor.key,
              headerText: visitor.key,

              softWrap: true,
              headerTextSoftWrap: true,
              headerStyle: DataGridHeaderCellStyle(
                sortIconColor: Colors.redAccent,
              ),
            );
    }).toList());
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
        columnWidthMode: ColumnWidthMode.auto,

        allowSorting: true,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
        controller: _dataGridController,
        source: _visitorDataSource,

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

//
      ),
    );
  }
}

class VisitorDataSource extends DataGridSource {
  VisitorDataSource({this.visitors});
  final List<dynamic> visitors;

  @override
  List<dynamic> get dataSource => visitors;

  @override
  getValue(Object visitor, String columnName) {
    // log(visitor.toString(), name: ' in viitor getvalue');
    switch (columnName) {
      case 'date':
        return DateTime.fromMillisecondsSinceEpoch(
            (visitor as Map)[columnName]);
        break;
      default:
        return (visitor as Map)[columnName];
    }
  }

  @override
  int get rowCount => visitors.length;

  void updateDataGridSource() {
    notifyListeners();
  }

  // @override
  // Future<bool> handlePageChange(int oldPageIndex, int newPageIndex,
  //     int startRowIndex, int rowsPerPage) async {
  //   log('$oldPageIndex $startRowIndex $newPageIndex $rowsPerPage  ${_visitors.length}');
  //   int endIndex = startRowIndex + rowsPerPage;
  //   if (endIndex > _visitors.length) {
  //     endIndex = _visitors.length - 1;
  //   }

  //   paginatedDataSource = List.from(
  //       _visitors.getRange(startRowIndex, endIndex).toList(growable: false));
  //   notifyListeners();
  //   return true;
  // }
}
