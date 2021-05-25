import 'package:flutter/material.dart';
import 'package:hajeri/constant.dart';
import 'package:hajeri/url.dart';

import '../model/Employee.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

List<dynamic> _history = [];
LogDataSource _logDataSource;

class HistoryLog extends StatefulWidget {
  final List<dynamic> data;

  HistoryLog({@required this.data});
  @override
  _HistoryLogState createState() => _HistoryLogState();
}

class _HistoryLogState extends State<HistoryLog> {
  Map referenceMap;
  final DataGridController _dataGridController = DataGridController();

  List<GridColumn> _gridColumn = [
    GridTextColumn(
      width: 175.0,
      columnName: 'suborgname',
      label: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: 8.0,
        ),
        child: Text(
          'Organization',
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
    _history = widget.data;
    _logDataSource = LogDataSource(log: _history);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SfDataGridTheme(
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
          source: _logDataSource,
          columns: _gridColumn,
          frozenColumnsCount: 1,
          selectionMode: SelectionMode.none,
          navigationMode: GridNavigationMode.row,
          stackedHeaderRows: <StackedHeaderRow>[
            StackedHeaderRow(cells: [
              StackedHeaderCell(
                columnNames: [
                  'suborgname',
                  'clientmobile',
                  'date',
                  'visitingtime',
                ],
                child: Center(
                  child: Text(
                    'Employee History Logs',
                    style: kDataGridHeaderTextStyle,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class LogDataSource extends DataGridSource {
  LogDataSource({this.log}) {
    buildHistoryLogs();
  }
  final List<dynamic> log;

  void buildHistoryLogs() {
    dataGridRows = log
        .map<DataGridRow>(
          (dataGridRow) => DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'suborgname',
                value: dataGridRow['suborgname'],
              ),
              DataGridCell<String>(
                columnName: 'clientmobile',
                value: dataGridRow['clientmobile'].toString(),
              ),
              DataGridCell<String>(
                columnName: 'date',
                value: DateTime.fromMillisecondsSinceEpoch(dataGridRow['date'])
                    .toString()
                    .split(' ')[0],
              ),
              DataGridCell<String>(
                columnName: 'visitingtime',
                value: DateTime.fromMillisecondsSinceEpoch(dataGridRow['date'])
                    .toString()
                    .split(' ')[1],
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
        alignment: dataGridCell.columnName.toString().contains('suborgname')
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
