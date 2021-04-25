// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:hajeri_demo/constant.dart';
// import 'package:hajeri_demo/url.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:http/http.dart' as http;
// import '../main.dart';
// import 'package:intl/intl.dart';

// /// The app which hosts the home page which contains the calendar on it.

// /// The hove page which hosts the calendar
// class CalendarApp extends StatefulWidget {
//   final List<dynamic> attendanceSheet;
//   final String type;

//   /// Creates the home page to display the calendar widget.

//   CalendarApp({
//     this.attendanceSheet,
//     this.type,
//   });
//   @override
//   _CalendarAppState createState() => _CalendarAppState();
// }

// class _CalendarAppState extends State<CalendarApp> {
//   int currentYear = DateTime.now().year;
//   int currentMonth = DateTime.now().month;
//   bool monthAndYearUpdated = true;
//   List<dynamic> rawAttendanceData;
//   CalendarController calendarController = CalendarController();
//   Future<List> _getRawAttendanceData(String type, DateTime monthYear) async {
//     List<dynamic> data = [];
//     String orgId = prefs.getString("worker_id");
//     // await Future.delayed(
//     //     Duration(
//     //       seconds: 50,
//     //     ), () {
//     //   attendanceData = kAttendanceMockData;
//     // });
//     log('$kMonthlyAttendance$orgId/$type/${monthYear.toString().substring(0, 7)}');
//     var response = await http.get(
//         '$kMonthlyAttendance$orgId/$type/${monthYear.toString().substring(0, 7)}');

//     if (response.statusCode == 200) {
//       data = json.decode(response.body);
//       print("the data is " + data.toString());

// //      print(data);

//       rawAttendanceData = data;

//       print("the attendence list is $rawAttendanceData");

//       //state_id=data['id'];
//       return rawAttendanceData;
//     } else {}
//   }

//   @override
//   void initState() {
//     super.initState();
//     rawAttendanceData = widget.attendanceSheet;
//   }

//   Widget appointmentBuilder(BuildContext context,
//       CalendarAppointmentDetails calendarAppointmentDetails) {
//     final Appointment appointment =
//         calendarAppointmentDetails.appointments.first;
//     return Column(
//       children: [
//         // Container(
//         //     width: calendarAppointmentDetails.bounds.width,
//         //     height: calendarAppointmentDetails.bounds.height / 2,
//         //     color: appointment.color,
//         //     child: Center(
//         //       child: Icon(
//         //         Icons.group,
//         //         color: Colors.black,
//         //       ),
//         //     )),
//         Container(
//           width: calendarAppointmentDetails.bounds.width,
//           height: 9,
//           color: appointment.color,
//           child: Text(
//             appointment.subject +
//                 DateFormat(' (hh:mm a').format(appointment.startTime) +
//                 '-' +
//                 DateFormat('hh:mm a)').format(appointment.endTime),
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 10),
//           ),
//         )
//       ],
//     );
//   }

//   Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
//     bool isToday = false;
//     if (details.appointments.isNotEmpty) {
//       Appointment appointment = details.appointments[0];

//       log("${details.date}");
//       if (details.date.toString().split(" ")[0] ==
//           DateTime.now().toString().split(" ")[0]) {
//         isToday = true;
//       } else {
//         isToday = false;
//       }
//       return Container(
//         margin: EdgeInsets.symmetric(
//           horizontal: 2.0,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(
//                   3.0,
//                 ),
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey,
//                       blurRadius: 0.5,
//                       offset: Offset(
//                         1,
//                         1,
//                       ),
//                     )
//                   ],
//                   // shape: BoxShape.circle,
//                   border: Border.all(
//                       width: 1,
//                       color:
//                           appointment.subject.toLowerCase().contains("present")
//                               ? Colors.green[800]
//                               : Colors.red[800]),
//                   borderRadius: BorderRadius.circular(
//                     5.0,
//                   ),
//                   color: appointment.subject.toLowerCase().contains("present")
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//                 child: Center(
//                   child: Text(
//                     details.date.day.toString(),
//                     style: TextStyle(
//                       color: isToday ? Colors.yellowAccent : Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               // Container(
//               //   // color: appointment.color,
//               //   decoration: BoxDecoration(color: Colors.transparent),
//               //   child: Text(
//               //     appointment.subject,
//               //     style: TextStyle(
//               //       fontSize: 12.0,
//               //     ),
//               //   ),
//               // ),
//               Container(
//                 // color: appointment.color,
//                 decoration: BoxDecoration(color: Colors.transparent),
//                 child: Text(
//                   '${appointment.startTime.hour.toString()}:${appointment.startTime.minute.toString()}-',
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               Container(
//                 // color: appointment.color,
//                 decoration: BoxDecoration(color: Colors.transparent),
//                 child: Text(
//                     '${appointment.endTime.hour.toString()}:${appointment.endTime.minute.toString()}'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return Container(
//       color: Colors.blueGrey,
//       child: Text(details.date.day.toString()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return monthAndYearUpdated
//         ? SfCalendar(
//             showDatePickerButton: true,

//             onViewChanged: (value) async {
//               // print(value.visibleDates.toString());
//               // value.visibleDates.forEach((element) {
//               //   print(element);
//               // });
//               //  ' 2021-03-22 00:00:00.000'
//               if (mounted) {
//                 if (currentMonth != value.visibleDates.first.month ||
//                     currentYear != value.visibleDates.first.year) {
//                   currentMonth = value.visibleDates.first.month;
//                   currentYear = value.visibleDates.first.year;
//                   rawAttendanceData = await _getRawAttendanceData(
//                       widget.type, value.visibleDates.first);

//                   setState(() {});
//                 }
//               }
//             },

//             view: CalendarView.month,
//             controller: calendarController,
//             dataSource:
//                 // _getCalendarDataSource(),

//                 // AttendanceDataSource(
//                 _getDataSource(
//               attendanceData: rawAttendanceData,
//             ),
//             // ),
//             // by default the month appointment display mode set as Indicator, we can
//             // change the display mode as appointment using the appointment display
//             // mode property
//             appointmentTextStyle: TextStyle(
//               fontSize: 30.0,
//             ),
//             // appointmentBuilder: appointmentBuilder,
//             monthCellBuilder: monthCellBuilder,
//             appointmentTimeTextFormat: 'HH:mm',
//             monthViewSettings: MonthViewSettings(
//               appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
//               navigationDirection: null,
//               showAgenda: false,
//               showTrailingAndLeadingDates: false,
//               // agendaItemHeight: 70,
//             ),
//             scheduleViewSettings: ScheduleViewSettings(
//               appointmentItemHeight: 70,
//               monthHeaderSettings: MonthHeaderSettings(
//                 monthFormat: 'MMMM, yyyy',
//                 height: 100,
//                 textAlign: TextAlign.left,
//                 backgroundColor: Colors.green,
//                 monthTextStyle: TextStyle(
//                   color: Colors.red,
//                   fontSize: 25,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//           )
//         : Center(
//             child: CircularProgressIndicator(),
//           );
//   }

//   AttendanceDataSource _getDataSource({List<dynamic> attendanceData}) {
//     List attendances = <Appointment>[];
//     // final DateTime today = DateTime(2021, 3, 1);

//     // final DateTime startTime =
//     //     DateTime(today.year, today.month, today.day, 9, 0, 0);
//     // final DateTime endTime = startTime.add(const Duration(hours: 2));
//     // Attendances
//     //     .add(Attendance('Absent', startTime, endTime, Colors.redAccent, false));

//     (widget.attendanceSheet.first as Map).forEach((key, value) {
//       if (key.toString().trim().length <= 2) {
//         bool present = value.toString().trim().toLowerCase().contains('p');
//         log(present.toString());
//         log('       ${key.toString()}         ${value.toString()}');
//         int firstHourScan = 0;
//         int firstMinuteScan = 0;
//         int lastHourScan = 0;
//         int lastMinuteScan = 0;
//         String _value = value.toString();
//         if (present) {
//           if (_value.contains(';')) {
//             firstHourScan = int.parse(_value
//                 .split(';')
//                 .first
//                 .split('[')
//                 .last
//                 .split(':')
//                 .first
//                 .trim());
//             firstMinuteScan = int.parse(
//               value
//                   .toString()
//                   .split(';')
//                   .first
//                   .split('[')
//                   .last
//                   .split(':')
//                   .last
//                   .trim(),
//             );
//             lastHourScan = int.parse(
//                 _value.split(';').last.split(']').first.split(':').first);
//             lastMinuteScan = int.parse(
//                 _value.split(';').last.split(']').first.split(':').last);
//           } else {
//             firstHourScan =
//                 int.parse(_value.split('[').last.split(':').first.trim());
//             firstMinuteScan = int.parse(
//               _value
//                   .toString()
//                   .split('[')
//                   .last
//                   .split(':')
//                   .last
//                   .split(']')
//                   .first
//                   .trim(),
//             );
//           }
//         }

//         int startHour = present ? firstHourScan : 0;
//         int startMinute = present ? firstMinuteScan : 0;
//         int lastHour = present ? lastHourScan : 0;
//         int lastMinute = present ? lastMinuteScan : 0;

//         log('$startHour $startMinute $lastHour $lastMinute');
//         DateTime startTime = DateTime(currentYear, currentMonth,
//             int.parse(key.toString().trim()), startHour, startMinute, 0);
//         DateTime endTime = DateTime(currentYear, currentMonth,
//             int.parse(key.toString().trim()), 6, 3, 0);
//         Color color = present ? Colors.green : Colors.redAccent;

//         attendances.add(
//           Appointment(
//               subject: present ? 'Present' : 'Absent',
//               startTime: startTime,
//               endTime: endTime,
//               color: color,
//               isAllDay: false),
//         );
//       }
//     });

//     // Attendances.add(Attendance(
//     //     'Present',
//     //     DateTime(today.year, today.month, today.day, 9, 0, 0)
//     //         .add(const Duration(
//     //       days: 5,
//     //     )),
//     //     endTime,
//     //     Colors.green,
//     //     false));
//     return AttendanceDataSource(
//       source: attendances,
//     );
//   }
// }

// class DataSource extends CalendarDataSource {
//   DataSource(List<Appointment> source) {
//     appointments = source;
//   }
// }

// DataSource _getCalendarDataSource() {
//   List<Appointment> appointments = <Appointment>[];
//   appointments.add(Appointment(
//       startTime: DateTime.now(),
//       endTime: DateTime.now().add(Duration(hours: 2)),
//       isAllDay: true,
//       subject: 'Meeting',
//       color: Colors.blue,
//       startTimeZone: '',
//       endTimeZone: ''));

//   return DataSource(appointments);
// }

// /// An object to set the appointment collection data source to calendar, which
// /// used to map the custom appointment data to the calendar appointment, and
// /// allows to add, remove or reset the appointment collection.
// class AttendanceDataSource extends CalendarDataSource {
//   /// Creates a Attendance data source, which used to set the appointment
//   /// collection to the calendar
//   AttendanceDataSource({List<Appointment> source}) {
//     appointments = source;
//   }

//   @override
//   DateTime getStartTime(int index) {
//     return appointments[index].from;
//   }

//   @override
//   DateTime getEndTime(int index) {
//     return appointments[index].to;
//   }

//   @override
//   String getSubject(int index) {
//     return appointments[index].eventName;
//   }

//   @override
//   Color getColor(int index) {
//     return appointments[index].background;
//   }

//   @override
//   bool isAllDay(int index) {
//     return appointments[index].isAllDay;
//   }
// }

// /// Custom business object class which contains properties to hold the detailed
// /// information about the event data which will be rendered in calendar.
// class Attendance {
//   /// Creates a Attendance class with required details.
//   Attendance(
//       this.eventName, this.from, this.to, this.background, this.isAllDay);

//   /// Event name which is equivalent to subject property of [Appointment].
//   String eventName;

//   /// From which is equivalent to start time property of [Appointment].
//   DateTime from;

//   /// To which is equivalent to end time property of [Appointment].
//   DateTime to;

//   /// Background which is equivalent to color property of [Appointment].
//   Color background;

//   /// IsAllDay which is equivalent to isAllDay property of [Appointment].
//   bool isAllDay;
// }
