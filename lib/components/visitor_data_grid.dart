import 'package:flutter/material.dart';
import '../constant.dart';
import '../model/Employee.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

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
      width: 175.0,

      columnName: 'nameofworker',
      label: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: 8.0,
        ),
        child: Text(
          'Name',
          style: kDataGridHeaderTextStyle,
        ),
      ),
    ),
    GridTextColumn(
      // columnWidthMode: ColumnWidthMode.auto,
      width: 100,
      columnName: 'clientmobile',
      label: Container(
        alignment: Alignment.center,
        child: Text(
          'Mobile',
          style: kDataGridHeaderTextStyle,
        ),
      ),
    ),
    GridTextColumn(
      // columnWidthMode: ColumnWidthMode.auto,
      width: 100,
      columnName: 'date',
      label: Container(
        alignment: Alignment.center,
        child: Text(
          'Date',
          style: kDataGridHeaderTextStyle,
        ),
      ),
    ),
    GridTextColumn(
      // columnWidthMode: ColumnWidthMode.auto,
      width: 100,
      columnName: 'visitingtime',
      label: Container(
        alignment: Alignment.center,
        child: Text(
          'Time',
          style: kDataGridHeaderTextStyle,
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _visitors = widget.attendanceSheet;
    // log(_visitors.toString(), name: 'In visitor init');
    _visitorDataSource = VisitorDataSource(visitors: _visitors);
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
        gridLinesVisibility: GridLinesVisibility.both,
        allowSorting: true,
        headerGridLinesVisibility: GridLinesVisibility.both,
        controller: _dataGridController,
        columns: _gridColumn,
        frozenColumnsCount: 1,
        selectionMode: SelectionMode.none,
        navigationMode: GridNavigationMode.row,
        source: _visitorDataSource,

//
      ),
    );
  }
}

class VisitorDataSource extends DataGridSource {
  VisitorDataSource({this.visitors}) {
    buildVisitorSheet();
  }
  final List<dynamic> visitors;

  void buildVisitorSheet() {
    dataGridRows = visitors
        .map<DataGridRow>(
          (dataGridRow) => DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'nameofworker',
                value: dataGridRow['nameofworker'],
              ),
              DataGridCell<String>(
                columnName: 'clientmobile',
                value: dataGridRow['clientmobile'],
              ),
              DataGridCell<String>(
                columnName: 'date',
                value: DateTime.fromMillisecondsSinceEpoch(
                  dataGridRow['date'],
                ).toString().split(' ')[0],
              ),
              DataGridCell<String>(
                columnName: 'visitingtime',
                value: DateTime.fromMillisecondsSinceEpoch(
                  dataGridRow['date'],
                ).toString().split(' ')[1],
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
        alignment: dataGridCell.columnName.toString().contains('nameofworker')
            ? Alignment.centerLeft
            : Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
