// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:io';
// import 'package:flutter/rendering.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:toast/toast.dart';

// import 'consts.dart';

// class qr_code_generator extends StatefulWidget {
//   String qr_data, lat, long, qr_code_name;

//   @override
//   qr_code_generator({this.qr_data, this.lat, this.long, this.qr_code_name});

//   _qr_code_generatorState createState() => _qr_code_generatorState(
//       qr_data: qr_data, lat: lat, long: long, qr_code_name: qr_code_name);
// }

// class _qr_code_generatorState extends State<qr_code_generator> {
//   String qr_data, lat, long, qr_code_name;

//   _qr_code_generatorState(
//       {this.qr_data, this.lat, this.long, this.qr_code_name});

//   String qrData = "Thanks For Downloading Hajeri App";

//   GlobalKey globalKey = new GlobalKey();

//   Future onSelectNotification(String payload) async {
//     print("Payload: $payload");
//     OpenFile.open(payload);
//   }

//   @override
//   void initState() {
//     qrData = qr_data;
//     _dataString = qr_data;
//     print("the qr data is $qrData");

//     var initializationSettingsAndroid =
//         new AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettingsIOS = new IOSInitializationSettings();

//     var initializationSettings = new InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

//     //flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     FlutterLocalNotificationsPlugin().initialize(initializationSettings,
//         onSelectNotification: onSelectNotification);

//     _requestPermission();
//     super.initState();
//   } // already generated qr code when the page opens

//   static const double _topSectionTopPadding = 50.0;
//   static const double _topSectionBottomPadding = 20.0;
//   static const double _topSectionHeight = 50.0;

//   String _dataString;

//   String _inputErrorText;
//   final TextEditingController _textController = TextEditingController();

//   File _imageFile;

//   //Create an instance of ScreenshotController
//   ScreenshotController screenshotController = ScreenshotController();
//   String org_name;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Generate QR-Code',
//           style: TextStyle(
//             color: col_blue,
//           ),
//         ),
//         iconTheme: IconThemeData(color: col_blue),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       body: _contentWidget(),
//     );
//   }

//   // Future<void> _captureAndSharePng() async {
//   //   try {
//   //     RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
//   //     var image = await boundary.toImage();
//   //     ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
//   //     Uint8List pngBytes = byteData.buffer.asUint8List();
//   //
//   //     final tempDir = await getTemporaryDirectory();
//   //     final file = await new File('${tempDir.path}/image.png').create();
//   //     await file.writeAsBytes(pngBytes);
//   //
//   //     final channel = const MethodChannel('channel:me.albie.share/share');
//   //     channel.invokeMethod('shareFile', 'image.png');
//   //
//   //   } catch(e) {
//   //     print(e.toString());
//   //   }
//   // }
//   _requestPermission() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//     ].request();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       org_name = prefs.getString("org_name");
//     });

//     final info = statuses[Permission.storage].toString();
//     print(info);
//     // _toastInfo(info);
//   }

//   _saveScreen() async {
//     RenderRepaintBoundary boundary =
//         globalKey.currentContext.findRenderObject();
//     ui.Image image = await boundary.toImage();
//     ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     final result =
//         await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
//     print(result);
//     //  _toastInfo(result.toString());
//   }

//   _contentWidget() {
//     final bodyHeight = MediaQuery.of(context).size.height -
//         MediaQuery.of(context).viewInsets.bottom;
//     return Container(
//       color: const Color(0xFFFFFFFF),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             RepaintBoundary(
//               key: globalKey,
//               child: Screenshot(
//                 controller: screenshotController,
//                 child: Container(
//                   color: col_blue.withOpacity(0.60),
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 50,
//                         child: Center(
//                           child: Text(
//                             "Hajeri",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 40,
//                         child: Center(
//                           child: Text(
//                             "Contactless Attendence System",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         //height: 50,
//                         margin: EdgeInsets.only(bottom: 4),
//                         child: Center(
//                           child: Text(
//                             org_name,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         //height: 50,
//                         child: Center(
//                           child: Text(
//                             qr_code_name,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         //height: 50,
//                         margin: EdgeInsets.only(bottom: 10),
//                         child: Center(
//                           child: Text(
//                             "SCAN HERE",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 300,
//                         width: 300,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: Colors.black,
//                               width: 1,
//                             )),
//                         child: QrImage(
//                           data: qr_data + "_" + lat + "#" + long,
//                           size: 0.5 * bodyHeight,
//                           // onError: (ex) {
//                           //   print("[QR] ERROR - $ex");
//                           //   setState(() {
//                           //     _inputErrorText =
//                           //     "Error! Maybe your input value is too long?";
//                           //   });
//                           // },
//                         ),
//                       ),
//                       Container(
//                         //height: 50,
//                         margin: EdgeInsets.only(top: 20),
//                         child: Center(
//                           child: Text(
//                             "OR CALL US ON",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         //height: 50,
//                         margin: EdgeInsets.only(top: 10, bottom: 15),
//                         child: Center(
//                           child: Text(
//                             "7877200117",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Card(
//                     child: Container(
//                       height: 50,
//                       width: 160,
//                       child: FlatButton(
//                         color: col_blue,
//                         child: Center(
//                           child: Text(
//                             "Download QR-Code",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         onPressed: () async {
//                           await _createFolder();
//                           final directory =
//                               (await getApplicationDocumentsDirectory())
//                                   .path; //from path_provide package
//                           String fileName = DateTime.now().toIso8601String();
//                           final dir =
//                               (await getExternalStorageDirectory()).path;
//                           var path = '/storage/emulated/0/hajeri/$fileName.png';
//                           screenshotController.capture(
//                               path: path,
//                               pixelRatio: 1.5,
//                               //set path where screenshot will be saved
//                               delay: Duration(milliseconds: 20));
//                           print("the path is $path");
//                           screenshotController
//                               .capture()
//                               .then((File image) async {
//                             //Capture Done
//                             setState(() {
//                               _imageFile = image;
//                               print("inner storage path is " +
//                                   _imageFile.toString());
//                             });

//                             //Create a new PDF document.
//                             final PdfDocument document = PdfDocument();

//                             final Uint8List imageData =
//                                 File(path.toString()).readAsBytesSync();

//                             final PdfBitmap image1 = PdfBitmap(imageData);

//                             document.pages.add().graphics.drawImage(
//                                 image1, const Rect.fromLTWH(0, 0, 500, 700));

//                             var a = File(
//                                     '/storage/emulated/0/Download/$qr_code_name , $_dataString.pdf')
//                                 .writeAsBytes(document.save());
//                             print("the pdf is $a");
//                             document.dispose();

//                             final result = await ImageGallerySaver.saveImage(
//                                 _imageFile
//                                     .readAsBytesSync()); // Save image to gallery,  Needs plugin  https://pub.dev/packages/image_gallery_saver
//                             print("File Saved to Gallery$result");
//                             Toast.show(
//                                 "Qr Code PDF has been sucessfully created",
//                                 context,
//                                 duration: Toast.LENGTH_LONG,
//                                 gravity: Toast.BOTTOM);
//                           }).catchError((onError) {
//                             print(onError);
//                           });

//                           var androidPlatformChannelSpecifics =
//                               new AndroidNotificationDetails(
//                                   'your channel id',
//                                   'your channel name',
//                                   'your channel description',
//                                   importance: Importance.max,
//                                   priority: Priority.high);
//                           var iOSPlatformChannelSpecifics =
//                               new IOSNotificationDetails();
//                           var platformChannelSpecifics =
//                               new NotificationDetails(
//                                   android: androidPlatformChannelSpecifics,
//                                   iOS: iOSPlatformChannelSpecifics);
//                           await FlutterLocalNotificationsPlugin().show(
//                             0,
//                             'Pdf is downloaded',
//                             'Tap To Open',
//                             platformChannelSpecifics,
//                             payload:
//                                 "/storage/emulated/0/Download/$qr_code_name , $_dataString.pdf",
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   Card(
//                     child: Container(
//                       height: 50,
//                       width: 160,
//                       color: col_blue,
//                       child: Center(
//                         child: Text(
//                           "Update QR-Code",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _createFolder() async {
//     final path = Directory("storage/emulated/0/hajeri");
//     if ((await path.exists())) {
//       print("exist");
//     } else {
//       print("not exist");
//       path.create();
//     }
//   }
// }
