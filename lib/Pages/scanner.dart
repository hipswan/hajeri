import 'dart:async';
import 'dart:developer' as dev;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../Pages/landing.dart';
import '../components/blue_button.dart';
import '../constant.dart';
import '../url.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../components/side_bar.dart';
import '../main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:toast/toast.dart';
import 'dart:io';

Position _currrentUserLocation;
var orgLng;
var orgLat;

class Scanner extends StatefulWidget {
  static const id = 'scanner';

  const Scanner({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with SingleTickerProviderStateMixin {
  // AnimationController _animationController;
  bool isFlashOn = false;
  bool isQrScanned = false;
  bool isFrontCamera = false;
  bool showAd = true;
  bool isLoading = false;
  bool openStream = true;
  Barcode result;
  String status;
  StreamSubscription<Barcode> _streamQrSubscription;

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void _handleFlashOn() async {
    await controller?.toggleFlash();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  void _handleFrontCamera() async {
    await controller?.flipCamera();
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }

  @override
  void initState() {
    super.initState();
    dev.log('In  Init $mounted', name: 'Scanner');

    // dev.debugger();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(
    //     milliseconds: 450,
    //   ),
    // );
    _checkPermission();
  }

  Future<bool> _checkPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    dev.log('User granted permission: ${settings.authorizationStatus}');
    final status = await Permission.locationWhenInUse.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.locationWhenInUse.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  // // In order to get hot reload to work we need to pause the camera if the platform
  // // is android, or resume the camera if the platform is iOS.
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   // dev.debugger();
  //   if (Platform.isAndroid) {
  //     print('Camera resume');
  //     // controller.stopCamera();
  //     controller.pauseCamera();
  //   }
  //   controller.resumeCamera();
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: SideBar(
          section: 'scan_qr',
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('QR Scanner'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: Container(
          width: size.width * 0.7,
          height: 75,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                5.0,
              )),
          padding: EdgeInsets.all(
            16.0,
          ),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 20,
              ),
              Text(
                'Loading..',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        child: !isQrScanned
            ? Stack(
                children: <Widget>[
                  _buildQrView(context),
                  Positioned(
                    bottom: 30,
                    right: 50,
                    child: FloatingActionButton(
                      heroTag: 'flash',
                      backgroundColor: Colors.white.withAlpha(100),
                      focusColor: Colors.white,
                      splashColor: Colors.blueAccent,
                      tooltip: 'Flash',
                      // focusColor: Colors.amberAccent,
                      // hoverColor: Colors.deepOrange,
                      child: isFlashOn
                          ? Icon(
                              Icons.flash_on,
                              color: Colors.grey[300],
                              size: 35,
                            )
                          : Icon(
                              Icons.flash_off,
                              color: Colors.grey[300],
                              size: 35,
                            ),

                      onPressed: () {
                        _handleFlashOn();
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 50,
                    child: FloatingActionButton(
                      heroTag: 'camera',
                      backgroundColor: isFrontCamera
                          ? Colors.blue
                          : Colors.white.withAlpha(100),
                      focusColor: Colors.white,
                      splashColor: Colors.blueAccent,
                      tooltip: 'Camera',
                      // focusColor: Colors.amberAccent,
                      // hoverColor: Colors.deepOrange,
                      child: Icon(
                        Icons.flip_camera_ios_outlined,
                        color: Colors.white,
                        size: 35,
                      ),

                      onPressed: () {
                        _handleFrontCamera();
                      },
                    ),
                  ),
                  // Expanded(
                  //   flex: 1,
                  //   child: FittedBox(
                  //     fit: BoxFit.contain,
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //       children: <Widget>[
                  //         if (result != null)
                  //           Text(
                  //               'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                  //         else
                  //           Text('Scan a code'),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: <Widget>[
                  //             Container(
                  //               margin: EdgeInsets.all(8),
                  //               child: ElevatedButton(
                  //                   onPressed: () async {
                  //                     await controller?.toggleFlash();
                  //                     setState(() {});
                  //                   },
                  //                   child: FutureBuilder(
                  //                     future: controller?.getFlashStatus(),
                  //                     builder: (context, snapshot) {
                  //                       return Text('Flash: ${snapshot.data}');
                  //                     },
                  //                   )),
                  //             ),
                  //             Container(
                  //               margin: EdgeInsets.all(8),
                  //               child: ElevatedButton(
                  //                   onPressed: () async {
                  //                     await controller?.flipCamera();
                  //                     setState(() {});
                  //                   },
                  //                   child: FutureBuilder(
                  //                     future: controller?.getCameraInfo(),
                  //                     builder: (context, snapshot) {
                  //                       if (snapshot.data != null) {
                  //                         return Text(
                  //                             'Camera facing ${describeEnum(snapshot.data)}');
                  //                       } else {
                  //                         return Text('loading');
                  //                       }
                  //                     },
                  //                   )),
                  //             )
                  //           ],
                  //         ),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: <Widget>[
                  //             Container(
                  //               margin: EdgeInsets.all(8),
                  //               child: ElevatedButton(
                  //                 onPressed: () async {
                  //                   await controller?.pauseCamera();
                  //                 },
                  //                 child: Text('pause', style: TextStyle(fontSize: 20)),
                  //               ),
                  //             ),
                  //             Container(
                  //               margin: EdgeInsets.all(8),
                  //               child: ElevatedButton(
                  //                 onPressed: () async {
                  //                   await controller?.resumeCamera();
                  //                 },
                  //                 child: Text('resume', style: TextStyle(fontSize: 20)),
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  _streamQrSubscription?.cancel();
                  Future.delayed(
                      Duration(
                        seconds: 10,
                      ), () {
                    setState(() {
                      showAd = false;
                    });
                  });
                  return showAd
                      ? Container(
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset('assets/images/hajerilogo.png'),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.blue[800],
                                  highlightColor: Colors.blue[100],
                                  enabled: true,
                                  child: Text(
                                    'Scanning in progress',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 22.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          width: constraints.maxWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              getScanStatusWidget(context, constraints),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: size.width * 0.5,
                                child: BlueButton(
                                  label: 'Scan Again',
                                  onPressed: () {
                                    openStream = true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Landing(
                                          initialPageIndex: 1,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                },
              ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 500.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    _streamQrSubscription =
        controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      dev.log(scanData.code.toString(), name: 'Sanner scanned message');
      // await controller.pauseCamera();

      if (result != null && openStream) {
        openStream = false;
        // showDialog(
        //     barrierDismissible: false,
        //     context: context,
        //     builder: (context) {
        //       // Future.delayed(Duration(seconds: 10), () {
        //       //   Navigator.of(context).pop(true);
        //       // });
        //       return WillPopScope(
        //         onWillPop: () async => false,
        //         child: AlertDialog(
        //           content: Row(
        //             children: [
        //               CircularProgressIndicator(),
        //               SizedBox(
        //                 width: 10.0,
        //               ),
        //               Text(
        //                 'Loading....',
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     });
        setState(() {
          isLoading = true;
        });
        // dev.debugger();
        if (result.code.contains("Hajeri")) {
          status = await markAttendance();

          if (status.isNotEmpty &&
              (status.contains('no internet') ||
                  status.contains('connectivity issue') ||
                  status.contains('error occurred'))) {
            // Navigator.pop(context);

            setState(() {
              isLoading = false;
              openStream = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  status ?? '',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                margin: EdgeInsets.fromLTRB(
                  5.0,
                  0.0,
                  5.0,
                  20.0,
                ),
              ),
            );
          } else {
            // Navigator.pop(context);
            // await controller?.stopCamera();
            dev.log('$status', name: 'In scanner result');

            setState(() {
              isLoading = false;
              isQrScanned = true;
            });
          }
        } else if (result.code.toLowerCase().contains("hjrwebqrcode")) {
          status = await webLogin();
          dev.log('web scanning status is: $status');

          // Navigator.pop(context);

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     backgroundColor: Colors.white,
          //     behavior: SnackBarBehavior.floating,
          //     content: Text(
          //       status,
          //       style: TextStyle(
          //         color: Colors.black,
          //       ),
          //     ),
          //     margin: EdgeInsets.fromLTRB(
          //       5.0,
          //       0.0,
          //       5.0,
          //       20.0,
          //     ),
          //   ),
          // );
          // await controller?.resumeCamera();
          /* await controller?.stopCamera();

          dev.log('$status', name: 'In scanner result');
          setState(() {
            isQrScanned = true;
          });*/
          setState(() {
            isLoading = false;

            isQrScanned = true;
          });
        } else if (result.code.isNotEmpty && !result.code.contains("Hajeri")) {
          // await controller.stopCamera();

          status = "no hajeri";
          setState(() {
            isLoading = false;

            isQrScanned = true;
          });
          // Navigator.pop(context);
          //         await controller.pauseCamera();
          //         await controller.resumeCamera();
          // dev.debugger();
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             backgroundColor: Colors.white,
          //             behavior: SnackBarBehavior.floating,
          //             content: Text(
          //               'Not a Hajeri QR Code Scan Again',
          //               style: TextStyle(
          //                 color: Colors.black,
          //               ),
          //             ),
          //             margin: EdgeInsets.fromLTRB(
          //               5.0,
          //               0.0,
          //               5.0,
          //               20.0,
          //             ),
          //           ),
          //         );

          //await controller.resumeCamera();
        }
      }
    });
  }

  // weblogin code
  Future<String> webLogin() async {
    // var qrCodeResult = result.code.toString().split("_");
    var qrcodeValueforweb = result.code.toString();
    dev.log("allowdistance $qrcodeValueforweb");
    String orgidforweb = prefs.getString("worker_id");

    /* var response =
    await http.get("$kDesktopLogin?qrcodeValue=$qrcodeValueforweb&orgid=$orgidforweb", headers: {
      'Content-Type': 'application/json',
    });*/
    try {
      var response = await http.get(
          Uri.parse(
              "$kDesktopLogin?qrcodeValue=$qrcodeValueforweb&orgid=$orgidforweb"),
          headers: {
            'Content-Type': 'application/json',
          });
      if (response.statusCode == 200) {
        dev.log(response.body.toString());
        String data = response.body.toString();
        if (data.contains("Success")) {
          return 'web success';
        } else {
          return 'web failure';
        }
      } else {
        return "failed to connect to Internet";
      }
    } on IOException catch (e) {
      return 'connectivity issue';
    } catch (e) {
      return 'error occurred';
    }
  }

  Future<String> markAttendance() async {
    LocationPermission _locationpermission = await Geolocator.checkPermission();
    dev.log(_locationpermission.toString(),
        name: 'In the scanner mark attendance');
    if (_locationpermission == LocationPermission.denied) {
      try {
        Geolocator.requestPermission();
      } on PermissionDefinitionsNotFoundException catch (e) {
        dev.log(e.toString(),
            name: 'In scanner mark attendance permission definition exception');
        return 'error occurred : perimission denied';
      } catch (e) {
        dev.log(_locationpermission.toString(),
            name: 'In the scanner mark attendance');
        return 'error occurred : ${e.toString().substring(0, 30)}';
      }
    }

    try {
      _currrentUserLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      return 'error occurred : ${e.toString().substring(0, 30)}';
    }
    var qrCodeResult = result.code.toString().split("_");

    var orgId = qrCodeResult[1];
    var orgmainBankId = qrCodeResult[4];
    dev.log("the org id is $orgId", name: 'In the scanner mark attendance');
    orgLat = qrCodeResult[2];
    orgLng = qrCodeResult[3];
    dev.log("the org lat is $orgLat", name: 'In the scanner mark attendance');
    dev.log("the org lng is $orgLng", name: 'In the scanner mark attendance');
    dev.log("the org lat in double is ${double.parse(orgLat)}",
        name: 'In the scanner mark attendance');
    dev.log("the org lng in double is ${double.parse(orgLng)}",
        name: 'In the scanner mark attendance');
    dev.log("current loc lat is ${_currrentUserLocation.latitude.toString()}");
    dev.log(
        "current loc long is ${_currrentUserLocation.longitude.toString()}");

    var distanceInMeters = Geolocator.distanceBetween(
        double.parse(orgLat),
        double.parse(orgLng),
        _currrentUserLocation.latitude,
        _currrentUserLocation.longitude);

    String userOrgId = prefs.getString("org_id");
    String userId = prefs.getString("worker_id");
    String usermainBankId = prefs.getString("main_bank_id");
    dev.log("main_bank_idfromprefs: $usermainBankId");

    // get allow distance from api
    int allowdistance;
    try {
      var response = await http.get(Uri.parse("$kAllowDistance"), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        String allowdist;
        allowdist = response.body.toString();
        dev.log(response.body.toString(),
            name: 'In scanner didt within 3 meters');
        allowdistance = int.parse(allowdist);
      } else {
        return "failed to connect to Internet";
      }
    } on SocketException catch (e) {
      dev.log(e.message);
      return 'no internet';
    } on IOException catch (e) {
      dev.log(e.toString());
      return 'connectivity issue';
    } on Exception catch (e) {
      dev.log(e.toString());
      return 'error occurred';
    }

    // String userMobileNumber = prefs.getString("mobile");
    dev.log("org id from qr is $orgId");
    dev.log("allowdistance is $allowdistance");
    print("org id of user $userOrgId");
    if (usermainBankId == orgmainBankId) {
      dev.log("the diff distance is ${distanceInMeters.toString()}");
      if (distanceInMeters < allowdistance) {
        try {
          dev.log(
              "$kMarkAttendance$orgId/$userId/Employee?lat=$orgLat&lng=$orgLng");
          var response = await http.get(
              Uri.parse(
                  "$kMarkAttendance$orgId/$userId/Employee?lat=$orgLat&lng=$orgLng"),
              headers: {
                'Content-Type': 'application/json',
              });

          if (response.statusCode == 200) {
            dev.log(response.body.toString(),
                name: 'In scanner didt within 3 meters');
            return "success";
          } else {
            return "failed to connect to Internet";
          }
        } on SocketException catch (e) {
          dev.log(e.message);
          return 'no internet';
        } on IOException catch (e) {
          dev.log(e.toString());
          return 'connectivity issue';
        } on Exception catch (e) {
          dev.log(e.toString());
          return 'error occurred';
        }
      } else {
        // Toast.show("Please be under 3 meters of Organization", context,
        //     duration: Toast.LENGTH_LONG,
        //     gravity: Toast.BOTTOM,
        //     textColor: Colors.red);
        return "Please be under 3 meters of Organization";
      }
    }
    // var response = await http.get('$kGetDistance$userMobileNumber', headers: {
    //   'Content-Type': 'application/json',
    // });
    else {
      try {
        dev.log(
            "$kMarkAttendance$orgId/$userId/Visitor?lat=$orgLat&lng=$orgLng");
        var response = await http.get(
            Uri.parse(
                "$kMarkAttendance$orgId/$userId/Visitor?lat=$orgLat&lng=$orgLng"),
            headers: {
              'Content-Type': 'application/json',
            });

        if (response.statusCode == 200) {
          dev.log(response.body.toString(), name: 'In scanner ');

          return "success";
        } else {
          return "failed to connect to Internet";
        }
      } on Exception catch (e) {
        return 'error occurred : ${e.toString().substring(0, 30)}';
      }
    }
  }

  Widget getScanStatusWidget(BuildContext context, BoxConstraints constraints) {
    switch (status) {
      case "success":
        return Container(
          child: Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.4,
                width: constraints.maxWidth * 0.4,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage(
                //       "assets/images/success.gif",
                //     ),
                //   ),
                // ),
                child: Image(
                  image: AssetImage(
                    'assets/images/success.gif',
                  ),
                ),
              ),
              Container(
                child: Text(
                  "हजेरी लग गयी....!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case "web success":
        return Container(
          child: Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.4,
                width: constraints.maxWidth * 0.4,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage(
                //       "assets/images/success.gif",
                //     ),
                //   ),
                // ),
                child: Image(
                  image: AssetImage(
                    'assets/images/success.gif',
                  ),
                ),
              ),
              Container(
                child: Text(
                  "Logged into Web",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case "web failure":
        return Container(
          padding: EdgeInsets.fromLTRB(
            10.0,
            8.0,
            10.0,
            8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: constraints.maxHeight * 0.4,
                child: Image.asset(
                  "assets/images/fail.gif",
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Container(
                child: Text(
                  "Invalid User, Please scan again",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        );
        break;

      case "failed to connect to Internet":
        return Container(
          child: Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.4,
                child: Image.asset(
                  "assets/images/fail.gif",
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Container(
                child: Text(
                  "Check Your Internet Connections",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case "Please be under 3 meters of Organization":
        return Container(
          padding: EdgeInsets.fromLTRB(
            10.0,
            8.0,
            10.0,
            8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: constraints.maxHeight * 0.4,
                child: Image.asset(
                  "assets/images/fail.gif",
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Container(
                child: Text(
                  "You are not at Workplace...!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.blue[700],
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        50.0,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  print('button pressed');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewLocation()),
                  );
                  // Scaffold.of(context)
                  //     .showBottomSheet(
                  //       (context) {
                  //         return
                  //       },
                  //       elevation: 10,
                  //     )
                  //     .closed
                  //     .whenComplete(
                  //       () {
                  //         // print('closed');
                  //         mapController.dispose();
                  //       },
                  //     );
                },
                icon: Icon(
                  Icons.my_location_outlined,
                ),
                label: Text(
                  'View Your current location',
                ),
              ),
            ],
          ),
        );
        break;
      case "no hajeri":
        return Container(
          padding: EdgeInsets.fromLTRB(
            10.0,
            8.0,
            10.0,
            8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: constraints.maxHeight * 0.4,
                child: Image.asset(
                  "assets/images/fail.gif",
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Container(
                child: Text(
                  "Not a Hajeri QR code...!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        );
        break;

      default:
    }
  }

  @override
  void dispose() {
    super.dispose();
    dev.log('In  Dispose $mounted', name: 'Scanner');

    controller.dispose();

    // _animationController.dispose();
  }
}

class ViewLocation extends StatefulWidget {
  const ViewLocation({Key key}) : super(key: key);

  @override
  _ViewLocationState createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  GoogleMapController mapController;
  bool isRecenterFinished = true;
  Map<String, Marker> _markers = {};

  @override
  void initState() {
    _markers["position"] = Marker(
      consumeTapEvents: true,
      draggable: false,
      markerId: MarkerId('Marker Id'),
      position: LatLng(
        double.parse(orgLat),
        double.parse(orgLng),
      ),
      infoWindow: InfoWindow(
        title: 'Info title',
        snippet: 'Info snippet',
      ),
    );
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<LatLng> getUserLocation() async {
    setState(() {
      isRecenterFinished = false;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return LatLng(
        position.latitude,
        position.longitude,
      );
    } on TimeoutException catch (e) {
      Toast.show(
        "timeout exception",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.redAccent,
      );

      return LatLng(
        _currrentUserLocation.latitude,
        _currrentUserLocation.longitude,
      );
    } on PermissionDeniedException catch (e) {
      Toast.show(
        "permission denied exception",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.redAccent,
      );
      return LatLng(
        _currrentUserLocation.latitude,
        _currrentUserLocation.longitude,
      );
    } on LocationServiceDisabledException catch (e) {
      Toast.show(
        "location service disabled",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.redAccent,
      );

      return LatLng(
        _currrentUserLocation.latitude,
        _currrentUserLocation.longitude,
      );
    } catch (e) {
      Toast.show(
        "error occured",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.redAccent,
      );
      return LatLng(
        _currrentUserLocation.latitude,
        _currrentUserLocation.longitude,
      );
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: Text(
          'Map',
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              10.0,
            ),
            topRight: Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (_currrentUserLocation != null)
                      ? _currrentUserLocation.latitude
                      : 45.521563,
                  (_currrentUserLocation != null)
                      ? _currrentUserLocation.longitude
                      : -122.677433,
                ),
                zoom: 15.0,
              ),
              markers: _markers.values.toSet(),
            ),
            Positioned(
              bottom: 30.0,
              child: Container(
                height: 100,
                width: size.width,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Landing(
                            initialPageIndex: 1,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: kGradient,
                        borderRadius: BorderRadius.circular(
                          50.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Scan Aain |',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 22.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30.0,
              right: 10.0,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  LatLng center = await getUserLocation();
                  mapController.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          center.latitude,
                          center.longitude,
                        ),
                        zoom: 15.0,
                      ),
                    ),
                  );
                  // setState(() {
                  //   _markers['position'] = Marker(
                  //       consumeTapEvents: true,
                  //       draggable: false,
                  //       markerId: MarkerId('Marker Id'),
                  //       position: LatLng(
                  //         center.latitude,
                  //         center.longitude,
                  //       ),
                  //       infoWindow: InfoWindow(
                  //         title: 'Info title',
                  //         snippet: 'Info snippet',
                  //       ),
                  //       onDragEnd: (value) {
                  //         setState(() {});
                  //       });

                  setState(() {
                    isRecenterFinished = true;
                  });
                },
                tooltip: 'Center',
                backgroundColor: Colors.white,
                child: isRecenterFinished
                    ? Icon(
                        Icons.gps_fixed_outlined,
                        color: Colors.blue,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
