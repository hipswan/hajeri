// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:hajeri_demo/model/Employee.dart';
// import 'package:hajeri_demo/model/EmployeeDataSource.dart';

// class EmployeeTable extends StatefulWidget {
//   final List<dynamic> datasource;
//   EmployeeTable({@required this.datasource});

//   @override
//   _EmployeeTableState createState() => _EmployeeTableState();
// }

// class RestorableEmployeeSelections extends RestorableProperty<Set<int>> {
//   Set<int> _employeeSelections = {};

//   /// Returns whether or not a employee row is selected by index.
//   bool isSelected(int index) => _employeeSelections.contains(index);

//   /// Takes a list of [_Dessert]s and saves the row indices of selected rows
//   /// into a [Set].
//   void setEmployeeSelections(List<Employee> employees) {
//     final updatedSet = <int>{};
//     for (var i = 0; i < employees.length; i += 1) {
//       var employee = employees[i];
//       if (employee.selected) {
//         updatedSet.add(i);
//       }
//     }
//     _employeeSelections = updatedSet;
//     notifyListeners();
//   }

//   @override
//   Set<int> createDefaultValue() => _employeeSelections;

//   @override
//   Set<int> fromPrimitives(Object data) {
//     final selectedItemIndices = data as List<dynamic>;
//     _employeeSelections = {
//       ...selectedItemIndices.map<int>((dynamic id) => id as int),
//     };
//     return _employeeSelections;
//   }

//   @override
//   void initWithValue(Set<int> value) {
//     _employeeSelections = value;
//   }

//   @override
//   Object toPrimitives() => _employeeSelections.toList();
// }

// class _EmployeeTableState extends State<EmployeeTable> with RestorationMixin {
//   final RestorableEmployeeSelections _employeeSelections =
//       RestorableEmployeeSelections();
//   final RestorableInt _rowIndex = RestorableInt(0);
//   final RestorableInt _rowsPerPage =
//       RestorableInt(PaginatedDataTable.defaultRowsPerPage);
//   final RestorableBool _sortAscending = RestorableBool(true);
//   final RestorableIntN _sortColumnIndex = RestorableIntN(null);
//   EmployeeDataSource _employeeDataSource;

//   @override
//   String get restorationId => 'data_table_demo';

//   @override
//   void restoreState(RestorationBucket oldBucket, bool initialRestore) {
//     registerForRestoration(_employeeSelections, 'selected_row_indices');
//     registerForRestoration(_rowIndex, 'current_row_index');
//     registerForRestoration(_rowsPerPage, 'rows_per_page');
//     registerForRestoration(_sortAscending, 'sort_ascending');
//     registerForRestoration(_sortColumnIndex, 'sort_column_index');

//     _employeeDataSource ??=
//         EmployeeDataSource(context, widget.datasource as List<Employee>);
//     switch (_sortColumnIndex.value) {
//       case 0:
//         _employeeDataSource.sort<String>((d) => d.name, _sortAscending.value);
//         break;
//       case 1:
//         _employeeDataSource.sort<num>((d) => d.number, _sortAscending.value);
//         break;
//       case 2:
//         _employeeDataSource.sort<num>(
//             (d) => d.idCardNumber, _sortAscending.value);
//         break;
//       case 3:
//         _employeeDataSource.sort<String>(
//             (d) => d.organizationName, _sortAscending.value);
//         break;
//       case 4:
//         _employeeDataSource.sort<String>((d) => d.city, _sortAscending.value);
//         break;
//       case 5:
//         _employeeDataSource.sort<String>((d) => d.area, _sortAscending.value);
//         break;
//       case 6:
//         _employeeDataSource.sort<String>(
//             (d) => d.district, _sortAscending.value);
//         break;
//       case 7:
//         _employeeDataSource.sort<String>((d) => d.state, _sortAscending.value);
//         break;
//     }
//     _employeeDataSource.updateSelectedDesserts(_employeeSelections);
//     _employeeDataSource.addListener(_updateSelectedEmployeeRowListener);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _employeeDataSource ??=
//         EmployeeDataSource(context, widget.datasource as List<Employee>);
//     _employeeDataSource.addListener(_updateSelectedEmployeeRowListener);
//   }

//   void _updateSelectedEmployeeRowListener() {
//     _employeeSelections.setEmployeeSelections(_employeeDataSource.employees);
//   }

//   void _sort<T>(
//     Comparable<T> Function(Employee d) getField,
//     int columnIndex,
//     bool ascending,
//   ) {
//     _employeeDataSource.sort<T>(getField, ascending);
//     setState(() {
//       _sortColumnIndex.value = columnIndex;
//       _sortAscending.value = ascending;
//     });
//   }

//   @override
//   void dispose() {
//     _rowsPerPage.dispose();
//     _sortColumnIndex.dispose();
//     _sortAscending.dispose();
//     _employeeDataSource.removeListener(_updateSelectedEmployeeRowListener);
//     _employeeDataSource.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final localizations = GalleryLocalizations.of(context);
//     return Scrollbar(
//       child: ListView(
//         restorationId: 'data_table_list_view',
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         children: [
//           //TODO:Drag Start Behavior
//           PaginatedDataTable(
//             showCheckboxColumn: false,
//             columnSpacing: 20,
//             actions: [
//               IconButton(
//                 icon: Icon(
//                   Icons.edit,
//                 ),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.delete,
//                 ),
//                 onPressed: () {},
//               ),
//             ],
//             header: Text(
//               'Employee List',
//             ),
//             rowsPerPage: _rowsPerPage.value,
//             onRowsPerPageChanged: (value) {
//               setState(() {
//                 _rowsPerPage.value = value;
//               });
//             },
//             initialFirstRowIndex: _rowIndex.value,
//             onPageChanged: (rowIndex) {
//               setState(() {
//                 _rowIndex.value = rowIndex;
//               });
//             },
//             sortColumnIndex: _sortColumnIndex.value,
//             sortAscending: _sortAscending.value,
//             onSelectAll: _employeeDataSource.selectAll,
//             columns: [
//               // DataColumn(
//               //   label: Text('Sr.No'),
//               //   onSort: (columnIndex, ascending) =>
//               //       _sort<num>((d) => columnIndex, columnIndex, ascending),
//               // ),
//               DataColumn(
//                 label: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Name',
//                     textAlign: TextAlign.left,
//                   ),
//                 ),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<String>((d) => d.name, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text('Contact'),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<num>((d) => d.number, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text('ID  Card'),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<num>((d) => d.idCardNumber, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text('Org. Name'),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) => _sort<String>(
//                     (d) => d.organizationName, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text('City'),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<String>((d) => d.city, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text(
//                   'Area',
//                 ),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<String>((d) => d.area, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text(
//                   'District',
//                 ),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<String>((d) => d.district, columnIndex, ascending),
//               ),
//               DataColumn(
//                 label: Text(
//                   'State',
//                 ),
//                 numeric: true,
//                 onSort: (columnIndex, ascending) =>
//                     _sort<String>((d) => d.state, columnIndex, ascending),
//               ),
//             ],
//             source: _employeeDataSource,
//           ),
//         ],
//       ),
//     );
//   }
// }
