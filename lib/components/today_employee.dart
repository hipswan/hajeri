// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../components/blue_button.dart';
// import '../components/form_page.dart';
// import '../components/transition.dart';
// import '../main.dart';
// import '../model/Employee.dart';
// import '../url.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
// import 'package:http/http.dart' as http;
// import 'package:toast/toast.dart';

// List<dynamic> _todayEmployee = [];
// TodayEmployeeDataSource _todayEmployeeDataSource;

// class TodayEmployee extends StatefulWidget {
//   final List<dynamic> data;

//   TodayEmployee({@required this.data});
//   @override
//   _TodayEmployeeState createState() => _TodayEmployeeState();
// }

// class _TodayEmployeeState extends State<TodayEmployee> {
//   Map referenceMap;
//   final DataGridController _dataGridController = DataGridController();

//   List<GridColumn> _gridColumn = [
//     GridTextColumn(
//       // columnWidthMode: ColumnWidthMode.auto,
//       mappingName: 'nameofworker',
//       headerText: 'Name',
//       width: 175.0,
//       softWrap: true,
//       headerTextSoftWrap: true,
//       headerStyle: DataGridHeaderCellStyle(
//         sortIconColor: Colors.redAccent,
//       ),
//     ),
//     GridTextColumn(
//       // columnWidthMode: ColumnWidthMode.auto,
//       mappingName: 'clientmobile',
//       headerText: 'Mobile',
//       softWrap: true,
//       headerTextSoftWrap: true,
//       headerStyle: DataGridHeaderCellStyle(
//         sortIconColor: Colors.redAccent,
//       ),
//     ),
//     GridTextColumn(
//       // columnWidthMode: ColumnWidthMode.auto,
//       mappingName: 'date',
//       headerText: 'Date',
//       softWrap: true,
//       headerTextSoftWrap: true,
//       headerStyle: DataGridHeaderCellStyle(
//         sortIconColor: Colors.redAccent,
//       ),
//     ),
//     GridTextColumn(
//       // columnWidthMode: ColumnWidthMode.auto,
//       mappingName: 'visitingtime',
//       headerText: 'Time',
//       softWrap: true,
//       headerTextSoftWrap: true,
//       headerStyle: DataGridHeaderCellStyle(
//         sortIconColor: Colors.redAccent,
//       ),
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _todayEmployee = widget.data;
//     // log(_visitors.toString(), name: 'In visitor init');
//     _todayEmployeeDataSource = TodayEmployeeDataSource(log: _todayEmployee);
//     // // debugger();
//     // referenceMap = json.decode(json.encode(_visitors.first));
//     // referenceMap.remove('nameofworker');
//     // // log(_visitors.toString(), name: 'In visitor init');

//     // //First element of reference map has been altered
//     // // ignore: missing_return
//     // _gridColumn.addAll(referenceMap.entries.map<GridColumn>((visitor) {
//     //   return visitor.key.toString().trim().toLowerCase().contains('date')
//     //       ? GridDateTimeColumn(
//     //           columnWidthMode: ColumnWidthMode.cells,
//     //           mappingName: visitor.key,
//     //           headerText: visitor.key,
//     //           softWrap: true,
//     //           headerTextSoftWrap: true,
//     //           headerStyle: DataGridHeaderCellStyle(
//     //             sortIconColor: Colors.redAccent,
//     //           ),
//     //         )
//     //       : GridTextColumn(
//     //           // columnWidthMode: ColumnWidthMode.auto,
//     //           mappingName: visitor.key,
//     //           headerText: visitor.key,

//     //           softWrap: true,
//     //           headerTextSoftWrap: true,
//     //           headerStyle: DataGridHeaderCellStyle(
//     //             sortIconColor: Colors.redAccent,
//     //           ),
//     //         );
//     // }).toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: SfDataGridTheme(
//         data: SfDataGridThemeData(
//           gridLineColor: Colors.grey,
//           gridLineStrokeWidth: 0.5,
//           headerStyle: DataGridHeaderCellStyle(
//             textStyle: TextStyle(
//               // fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//             backgroundColor: Colors.blue[800],
//           ),
//           selectionStyle: DataGridCellStyle(
//             backgroundColor: Colors.redAccent,
//             textStyle: TextStyle(
//               fontWeight: FontWeight.w300,
//               color: Colors.white,
//             ),
//           ),
//           currentCellStyle: DataGridCurrentCellStyle(
//             borderWidth: 2,
//             borderColor: Colors.pinkAccent,
//           ),
//         ),
//         child: SfDataGrid(
//           columnWidthMode: ColumnWidthMode.auto,

//           allowSorting: true,
//           headerGridLinesVisibility: GridLinesVisibility.horizontal,
//           controller: _dataGridController,
//           source: _todayEmployeeDataSource,

//           columns: _gridColumn,
//           frozenColumnsCount: 1,
//           selectionMode: SelectionMode.none,

//           navigationMode: GridNavigationMode.row,
//           onSelectionChanging:
//               (List<Object> addedRows, List<Object> removedRows) {
//             if (addedRows.isNotEmpty &&
//                 (addedRows.last as Employee).name == 'Manager') {
//               return false;
//             }

//             return true;
//           },

// //
//         ),
//       ),
//     );
//   }
// }

// class TodayEmployeeDataSource extends DataGridSource {
//   TodayEmployeeDataSource({this.log});
//   final List<dynamic> log;

//   @override
//   List<dynamic> get dataSource => log;

//   @override
//   getValue(Object visitor, String columnName) {
//     // log(visitor.toString(), name: ' in viitor getvalue');
//     switch (columnName) {
//       case 'date':
//         return DateTime.fromMillisecondsSinceEpoch((visitor as Map)[columnName])
//             .toString()
//             .split(' ')[0];
//         break;
//       case 'visitingtime':
//         return DateTime.fromMillisecondsSinceEpoch((visitor as Map)['date'])
//             .toString()
//             .split(' ')[1];
//         break;
//       default:
//         return (visitor as Map)[columnName];
//     }
//   }

//   @override
//   int get rowCount => log.length;

//   void updateDataGridSource() {
//     notifyListeners();
//   }

//   // @override
//   // Future<bool> handlePageChange(int oldPageIndex, int newPageIndex,
//   //     int startRowIndex, int rowsPerPage) async {
//   //   log('$oldPageIndex $startRowIndex $newPageIndex $rowsPerPage  ${_visitors.length}');
//   //   int endIndex = startRowIndex + rowsPerPage;
//   //   if (endIndex > _visitors.length) {
//   //     endIndex = _visitors.length - 1;
//   //   }

//   //   paginatedDataSource = List.from(
//   //       _visitors.getRange(startRowIndex, endIndex).toList(growable: false));
//   //   notifyListeners();
//   //   return true;
//   // }
// }
