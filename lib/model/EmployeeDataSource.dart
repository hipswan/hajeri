// import 'package:flutter/material.dart';
// import 'package:hajeri_demo/components/employee_table.dart';
// import 'Employee.dart';

// class EmployeeDataSource extends DataTableSource {
//   EmployeeDataSource(this.context, this.employees) {
//     employees = this.employees;
//   }

//   final BuildContext context;
//   List<Employee> employees;

//   void sort<T>(Comparable<T> Function(Employee d) getField, bool ascending) {
//     employees.sort((a, b) {
//       final aValue = getField(a);
//       final bValue = getField(b);
//       return ascending
//           ? Comparable.compare(aValue, bValue)
//           : Comparable.compare(bValue, aValue);
//     });
//     notifyListeners();
//   }

//   int _selectedCount = 0;
//   void updateSelectedDesserts(RestorableEmployeeSelections selectedRows) {
//     _selectedCount = 0;
//     for (var i = 0; i < employees.length; i += 1) {
//       var dessert = employees[i];
//       if (selectedRows.isSelected(i)) {
//         dessert.selected = true;
//         _selectedCount += 1;
//       } else {
//         dessert.selected = false;
//       }
//     }
//     notifyListeners();
//   }

//   @override
//   DataRow getRow(int index) {
//     // final format = NumberFormat.decimalPercentPattern(
//     //   locale: GalleryOptions.of(context).locale.toString(),
//     //   decimalDigits: 0,
//     // );
//     assert(index >= 0);
//     if (index >= employees.length) return null;
//     final employee = employees[index];
//     return DataRow.byIndex(
//       index: index,
//       selected: employee.selected,
//       onSelectChanged: (value) {
//         if (employee.selected != value) {
//           _selectedCount += value ? 1 : -1;
//           assert(_selectedCount >= 0);
//           employee.selected = value;
//           notifyListeners();
//         }
//       },
//       cells: [
//         DataCell(
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               employee.name,
//               textAlign: TextAlign.left,
//             ),
//           ),
//           showEditIcon: false,
//         ),
//         DataCell(Text('${employee.number}')),
//         DataCell(Text('${employee.idCardNumber}')),
//         DataCell(Text('${employee.organizationName}')),
//         DataCell(Text(employee.city)),
//         DataCell(Text('${employee.area}')),
//         DataCell(Text('${(employee.district)}')),
//         DataCell(Text('${(employee.state)}')),
//       ],
//     );
//   }

//   @override
//   int get rowCount => employees.length;

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get selectedRowCount => _selectedCount;

//   void selectAll(bool checked) {
//     for (final dessert in employees) {
//       dessert.selected = checked;
//     }
//     _selectedCount = checked ? employees.length : 0;
//     notifyListeners();
//   }
// }
