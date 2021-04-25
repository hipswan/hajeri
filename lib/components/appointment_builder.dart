// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:intl/intl.dart';

// Widget appointmentBuilder(BuildContext context,
//     CalendarAppointmentDetails calendarAppointmentDetails) {
//   final Appointment appointment = calendarAppointmentDetails.appointments.first;
//   return Column(
//     children: [
//       Container(
//           width: calendarAppointmentDetails.bounds.width,
//           height: calendarAppointmentDetails.bounds.height / 2,
//           color: appointment.color,
//           child: Center(
//             child: Icon(
//               Icons.group,
//               color: Colors.black,
//             ),
//           )),
//       Container(
//         width: calendarAppointmentDetails.bounds.width,
//         height: calendarAppointmentDetails.bounds.height / 2,
//         color: appointment.color,
//         child: Text(
//           appointment.subject +
//               DateFormat(' (hh:mm a').format(appointment.startTime) +
//               '-' +
//               DateFormat('hh:mm a)').format(appointment.endTime),
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 10),
//         ),
//       )
//     ],
//   );
// }
