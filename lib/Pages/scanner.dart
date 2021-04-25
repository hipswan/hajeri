import 'dart:async';
import 'dart:developer' as dev;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hajeri_demo/Pages/landing.dart';
import 'package:hajeri_demo/components/blue_button.dart';
import 'package:hajeri_demo/url.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajeri_demo/Pages/employee_detail.dart';
import 'package:hajeri_demo/components/side_bar.dart';
import 'package:hajeri_demo/main.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:toast/toast.dart';
import 'dart:io';

import 'generate_qr.dart';

Position _currrentUserLocation;

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
  Barcode result;
  String status;
  StreamSubscription<Barcode> _streamQrSubscription;
  GoogleMapController mapController;

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
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   dev.debugger();
  //   if (Platform.isAndroid) {
  //     print('Camera resume');
  //     controller.stopCamera();
  //     // controller.pauseCamera();
  //   }
  //   controller.pauseCamera();
  // }

  @override
  Widget build(BuildContext context) {
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
      body: !isQrScanned
          ? Stack(
              children: <Widget>[
                _buildQrView(context),
                Positioned(
                  bottom: 50,
                  right: 50,
                  child: FloatingActionButton(
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
                  bottom: 50,
                  left: 50,
                  child: FloatingActionButton(
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
                              Image.asset('assets/images/hajeri_login.jpg'),
                              Text('Scanning in progress'),
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
                            BlueButton(
                              label: 'Scan Again',
                              onPressed: () {
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
                          ],
                        ),
                      );
              },
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
    setState(() {
      this.controller = controller;
    });
    _streamQrSubscription =
        controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      if (result != null) {
        await controller?.pauseCamera();

        // await showDialog(
        //     barrierDismissible: false,
        //     context: context,
        //     builder: (context) {
        //       Future.delayed(Duration(seconds: 10), () {
        //         Navigator.of(context).pop(true);
        //       });
        //       return WillPopScope(
        //         onWillPop: () async => false,
        //         child: AlertDialog(
        //           title: Text('Scanner'),
        //           content: Text(
        //             'Scanning in progress',
        //           ),
        //         ),
        //       );
        //     });

        if (result.code.split("_")[0].toLowerCase().contains("hajeri")) {
          status = await markAttendance();
          await controller?.stopCamera();

          dev.log('$status', name: 'In scanner result');
          setState(() {
            isQrScanned = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not a Hajeri QR Code Scan Again'),
            ),
          );
          await controller?.resumeCamera();
        }
      }
    });
  }

  Future<String> markAttendance() async {
    LocationPermission _locationpermission = await Geolocator.checkPermission();
    if (_locationpermission == LocationPermission.denied) {
      try {
        Geolocator.requestPermission();
      } on PermissionDefinitionsNotFoundException catch (e) {
        dev.log(e.toString(),
            name: 'In scanner mark attendance permission definition exception');
      }
    }
    dev.log(_locationpermission.toString(),
        name: 'In the scanner mark attendance');

    _currrentUserLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    var qrCodeResult = result.code.toString().split("_");

    var orgId = qrCodeResult[1];
    dev.log("the org id is $orgId", name: 'In the scanner mark attendance');
    var orgLat = qrCodeResult[2];
    var orgLng = qrCodeResult[3];
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
    dev.log("the diff distance is ${distanceInMeters.toString()}");

    String userOrgId = prefs.getString("worker_id");
    // String userMobileNumber = prefs.getString("mobile");
    dev.log("org id from qr is $orgId");
    print("org id from user $userOrgId");
    if (userOrgId == orgId) if (distanceInMeters < 3) {
      var response = await http
          .get("$kMarkAttendance$orgId/$userOrgId/Employee", headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        dev.log(response.body.toString(),
            name: 'In scanner didt within 3 meters');
        return "success";
      } else {
        return "failed to connect to Internet";
      }
    } else {
      Toast.show("Please be under 3 meters of Organization", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.red);
      return "Please be under 3 meters of Organization";
    }
    // var response = await http.get('$kGetDistance$userMobileNumber', headers: {
    //   'Content-Type': 'application/json',
    // });
    else {
      var response = await http
          .get("$kMarkAttendance$orgId/$userOrgId/Employee", headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        dev.log(response.body.toString(), name: 'In scanner ');

        return "success";
      } else {
        return "failed to connect to Internet";
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
                  "Hajeri Lag Gayi",
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
                  "Youre not at right place go to qr code location",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ButtonStyle(
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
                  Scaffold.of(context)
                      .showBottomSheet(
                        (context) {
                          return Container(
                            height: constraints.maxHeight * 0.5,
                            width: constraints.maxWidth,
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
                                  // liteModeEnabled: true,
                                  // myLocationEnabled: true,
                                  // myLocationButtonEnabled: true,
                                  zoomControlsEnabled: false,
                                  mapType: MapType.terrain,
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
                                  markers: <String, Marker>{
                                    'position': Marker(
                                      consumeTapEvents: true,
                                      draggable: true,
                                      markerId: MarkerId('Marker Id'),
                                      position: LatLng(
                                        (_currrentUserLocation != null)
                                            ? _currrentUserLocation.latitude
                                            : 45.521563,
                                        (_currrentUserLocation != null)
                                            ? _currrentUserLocation.longitude
                                            : -122.677433,
                                      ),
                                      infoWindow: InfoWindow(
                                        title: 'Info title',
                                        snippet: 'Info snippet',
                                      ),
                                    )
                                  }.values.toSet(),
                                ),
                                Positioned(
                                  right: 5.0,
                                  top: 5.0,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        CircleBorder(),
                                      ),
                                      padding: MaterialStateProperty.all(
                                        EdgeInsets.zero,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(
                                      Icons.close,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        elevation: 10,
                      )
                      .closed
                      .whenComplete(
                        () {
                          // print('closed');
                          mapController.dispose();
                        },
                      );
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
      default:
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    super.dispose();
    dev.log('In  Dispose $mounted', name: 'Scanner');

    controller.dispose();

    // _animationController.dispose();
  }
}
