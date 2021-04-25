import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class AttendanceSheet extends StatelessWidget {
  final attendanceData;
  AttendanceSheet({this.attendanceData});

  final HDTRefreshController _hdtRefreshController = HDTRefreshController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 150,
        rightHandSideColumnWidth: 1000,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: attendanceData.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
        verticalScrollbarStyle: const ScrollbarStyle(
          isAlwaysShown: true,
          thickness: 4.0,
          radius: Radius.circular(5.0),
        ),
        horizontalScrollbarStyle: const ScrollbarStyle(
          isAlwaysShown: true,
          thickness: 4.0,
          radius: Radius.circular(5.0),
        ),
        enablePullToRefresh: true,
        refreshIndicator: const WaterDropHeader(),
        refreshIndicatorHeight: 60,
        onRefresh: () async {
          //Do sth
          // await Future.delayed(const Duration(milliseconds: 500));
          // _hdtRefreshController.refreshCompleted();
        },
        htdRefreshController: _hdtRefreshController,
      ),
      height: MediaQuery.of(context).size.height - 210,
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: _getTitleItemWidget('Name', 150),
        onPressed: () {
          // sortType = sortName;
          // isAscending = !isAscending;
          // user.sortName(isAscending);
          // setState(() {});
        },
      ),
      // TextButton(
      //   style: TextButton.styleFrom(
      //     padding: EdgeInsets.zero,
      //   ),
      //   child: _getTitleItemWidget(
      //       'Status'
      //           // +
      //           // (sortType == sortStatus ? (isAscending ? '↓' : '↑') : '')
      //       ,
      //       100),
      //   onPressed: () {
      //     // sortType = sortStatus;
      //     // isAscending = !isAscending;
      //     // user.sortStatus(isAscending);
      //     // setState(() {});
      //   },
      // ),

      _getTitleItemWidget('1', 30),
      _getTitleItemWidget('2', 30),
      _getTitleItemWidget('3', 30),
      _getTitleItemWidget('4', 30),
      _getTitleItemWidget('5', 30),
      _getTitleItemWidget('6', 30),
      _getTitleItemWidget('7', 30),
      _getTitleItemWidget('8', 30),
      _getTitleItemWidget('9', 30),
      _getTitleItemWidget('10', 30),
      _getTitleItemWidget('11', 30),
      _getTitleItemWidget('12', 30),
      _getTitleItemWidget('13', 30),
      _getTitleItemWidget('14', 30),
      _getTitleItemWidget('15', 30),
      _getTitleItemWidget('16', 30),
      _getTitleItemWidget('17', 30),
      _getTitleItemWidget('18', 30),
      _getTitleItemWidget('19', 30),
      _getTitleItemWidget('20', 30),
      _getTitleItemWidget('21', 30),
      _getTitleItemWidget('22', 30),
      _getTitleItemWidget('23', 30),
      _getTitleItemWidget('24', 30),
      _getTitleItemWidget('25', 30),
      _getTitleItemWidget('26', 30),
      _getTitleItemWidget('27', 30),
      _getTitleItemWidget('28', 30),
      _getTitleItemWidget('19', 30),
      _getTitleItemWidget('30', 30),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text(attendanceData[index]['name']),
      width: 100,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(
              attendanceData[index]["1"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["2"].toString().contains("P") ? "P" : "A"),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["3"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["4"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["5"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["6"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["7"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["8"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["9"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["10"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["12"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["13"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["14"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["15"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["16"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["17"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["18"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["19"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["20"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["21"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["22"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["23"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["24"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["25"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["26"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["27"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["28"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["29"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
              attendanceData[index]["30"].toString().contains("P") ? "P" : "A"),
          width: 30,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }
}
