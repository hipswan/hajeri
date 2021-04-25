import 'package:flutter/material.dart';

const kPages = <String, IconData>{
  'Dashboard': Icons.dashboard_outlined,
  'qr_scanner': Icons.qr_code_scanner,
  'Attendance': Icons.list_alt,
};
const kOrgPages = <String, IconData>{
  'Dashboard': Icons.dashboard_outlined,
  'Employee': Icons.people,
  'Attendance': Icons.list_alt,
};

const List<String> kBusinessNatureMenuItems = <String>[
  'Office',
  'Bank',
  'School',
  'Hospital',
  'Shop',
  'Govt. Office',
  'Industry',
  'Other',
];

const List<String> kTypeSelectItems = <String>[
  'All Visitors',
  'All Employee',
];
const kMainQrPointTextStyle = TextStyle(
  color: Colors.white,
);

const kMonthsSelectItems = <String, String>{
  '1': 'January',
  '2': 'February',
  '3': 'March',
  '4': 'April',
  '5': 'May',
  '6': 'June',
  '7': 'July',
  '8': 'August',
  '9': 'September',
  '10': 'October',
  '11': 'November',
  '12': 'December',
};
var kPrimaryColor = Colors.blue[50];

LinearGradient kEmptyBoxGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.35, 0.63, 0.9],
  colors: [
    Colors.white,
    Colors.white70,
    Colors.white60,
  ],
);

LinearGradient kGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.35, 0.63, 0.9],
  colors: [
    Colors.blue[800],
    Colors.blue[700],
    Colors.blue[600],
  ],
);
LinearGradient kGradientTransparent = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.35, 0.63, 0.9],
  colors: [
    Colors.blue.withOpacity(1),
    Colors.blue.withOpacity(0.5),
    Colors.blue.withOpacity(0.2),
  ],
);

TextStyle kTextStyleSignUp = TextStyle(
  fontSize: 22,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
TextStyle kTextStyleEmployeeDetail = TextStyle(
  fontSize: 18,
);
TextStyle kTextStyleAccount = TextStyle(
  fontSize: 22,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
