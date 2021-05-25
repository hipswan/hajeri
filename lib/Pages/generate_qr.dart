import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../Pages/maintain_qr.dart';
import '../main.dart';
import '../url.dart';
import 'package:toast/toast.dart';

import '../constant.dart';

class GenerateQR extends StatefulWidget {
  static const id = 'generate_qr';
  final String latitude;
  final String longitude;
  final String pointName;
  final action;
  final title;
  GenerateQR(
      {Key key,
      this.latitude,
      this.longitude,
      this.pointName,
      this.action,
      this.title})
      : super(key: key);

  @override
  _GenerateQRState createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  GoogleMapController mapController;
  TextEditingController _cqrPointController;
  bool _displayBanner = true;
  bool isLocationUpdated = false;
  bool isRecenterFinished = true;
  // LatLng _center = const LatLng(45.521563, -122.677433);
  GlobalKey<FormState> _qrName = GlobalKey();
  final Map<String, Marker> _markers = {};
  LatLng currentPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    setUserLocationAndMarker();
    dev.log('${widget.pointName}');
    _cqrPointController = TextEditingController(
      text: widget.pointName ?? '',
    );
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
        currentPosition.latitude,
        currentPosition.longitude,
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
        currentPosition.latitude,
        currentPosition.longitude,
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
        currentPosition.latitude,
        currentPosition.longitude,
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
        currentPosition.latitude,
        currentPosition.longitude,
      );
    }
  }

  Future<void> updateQrCodePoint() async {
    String orgId = prefs.getString("worker_id");
    String mobile = prefs.getString("mobile");
    dev.log(
      '$kGenerateQrCodePoint?latlong=${currentPosition.latitude.toString()}, ${currentPosition.longitude.toString()}&qrpointname=${_cqrPointController.text}&id=$orgId&mobile=$mobile&fromapp=Yes',
    );
    var response = await http.get(Uri.parse(
      '$kGenerateQrCodePoint?latlong=${currentPosition.latitude.toString()}, ${currentPosition.longitude.toString()}&qrpointname=${_cqrPointController.text}&id=$orgId&mobile=$mobile&fromapp=Yes',
    ));

    if (response.statusCode == 200) {
      var data = response.body;
      dev.log(
        data.toString(),
      );
    }
  }

  Future<void> setUserLocationAndMarker() async {
    double lat;
    double lng;
    if (widget.latitude == null) {
      dev.log(
        'Null in latitude',
        name: ' In set location',
      );
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        lat = position.latitude;
        lng = position.longitude;
      } on TimeoutException catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'TimeoutException',
                ),
                content: new Text(
                  e.message,
                ),
                actions: <Widget>[
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Text("Back"),
                  ),
                ],
              );
            });
      } on PermissionDeniedException catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'PermissionDeniedException',
                ),
                content: new Text(
                  e.message,
                ),
                actions: <Widget>[
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Text("Back"),
                  ),
                ],
              );
            });
      } on LocationServiceDisabledException catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'LocationServiceDisabledException',
                ),
                content: new Text(
                  e.toString().substring(0, 15),
                ),
                actions: <Widget>[
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Text("Back"),
                  ),
                ],
              );
            });
      } on Exception catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Exception',
                ),
                content: new Text(
                  e.toString().substring(0, 15),
                ),
                actions: <Widget>[
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Text("Back"),
                  ),
                ],
              );
            });
        dev.log(e.toString(), name: 'In set location');
      }
      // print(position);

    } else {
      lat = double.parse(
        widget.latitude,
      );
      lng = double.parse(
        widget.longitude,
      );
      setState(() {
        currentPosition = LatLng(
          lat,
          lng,
        );
      });
    }

    setState(() {
      _markers['position'] = Marker(
          consumeTapEvents: true,
          draggable: true,
          markerId: MarkerId('Marker Id'),
          position: LatLng(
            lat,
            lng,
          ),
          infoWindow: InfoWindow(
            title: 'Info title',
            snippet: 'Info snippet',
          ),
          onDragEnd: (value) {
            setState(() {
              currentPosition = LatLng(value.latitude, value.longitude);
            });
            dev.log(value.toString());
          });

      currentPosition = LatLng(lat, lng);
      isLocationUpdated = true;
    });

    // List<Placemark> placemarks = await Geolocator.placemarkFromCoordinates(position.latitude, position.longitude);
    // Placemark placemark = placemarks[0];
    // String completeAddress =
    //     '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    // print(completeAddress);
    // String formattedAddress = "${placemark.locality}, ${placemark.country}";
    // locationController.text = formattedAddress;
  }

  addQrCodePoint() async {
    String orgId = prefs.getString("worker_id");
    String mobile = prefs.getString("mobile");
    dev.log(
        '$kGenerateQrCodePoint?latlong=${currentPosition.latitude.toString()}, ${currentPosition.longitude.toString()}&qrpointname=${_cqrPointController.text}&id=$orgId&mobile=$mobile&fromapp=Yes');
    var response = await http.get(
      Uri.parse(
        '$kGenerateQrCodePoint?latlong=${currentPosition.latitude.toString()}, ${currentPosition.longitude.toString()}&qrpointname=${_cqrPointController.text}&id=$orgId&mobile=$mobile&fromapp=Yes',
      ),
    );
    if (response.statusCode == 200) {
      var data = response.body;
      dev.log(data.toString(), name: 'In add qr code point');
    }
  }

  @override
  void dispose() {
    _cqrPointController.dispose();

    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            widget.title,
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              //Google Map
              Container(
                height: deviceSize.height * 0.55,
                width: deviceSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      10.0,
                    ),
                    bottomRight: Radius.circular(
                      10.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0.0, 5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Builder(
                  builder: (BuildContext context) {
                    if (!isLocationUpdated) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Stack(
                        children: [
                          //googlemap
                          GoogleMap(
                            // liteModeEnabled: true,
                            // myLocationEnabled: true,
                            // myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            mapType: MapType.terrain,
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                currentPosition.latitude,
                                currentPosition.longitude,
                              ),
                              zoom: 15.0,
                            ),
                            markers: _markers.values.toSet(),
                          ),
                          //recenter button
                          Platform.isAndroid
                              ? Positioned(
                                  right: 18,
                                  bottom: 18,
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
                                      setState(() {
                                        currentPosition = LatLng(
                                            center.latitude, center.longitude);
                                        _markers['position'] = Marker(
                                            consumeTapEvents: true,
                                            draggable: true,
                                            markerId: MarkerId('Marker Id'),
                                            position: LatLng(
                                              center.latitude,
                                              center.longitude,
                                            ),
                                            infoWindow: InfoWindow(
                                              title: 'Info title',
                                              snippet: 'Info snippet',
                                            ),
                                            onDragEnd: (value) {
                                              setState(() {
                                                currentPosition = LatLng(
                                                    value.latitude,
                                                    value.longitude);
                                                dev.log(value.toString());
                                              });
                                            });

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
                                )
                              : Container(),
                        ],
                      );
                    }
                  },
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: deviceSize.height * 0.32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(6, 0.0),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: ListView(children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Center(
                        child: Text('QR Point Name'),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //     vertical: 8.0,
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       Text('Latitude : ${currentPositionLatLng?.latitude}'),
                    //       SizedBox(
                    //         height: 10.0,
                    //       ),
                    //       Text(
                    //           'Longitude : ${currentPositionLatLng?.longitude}'),
                    //     ],
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Form(
                        key: _qrName,
                        child: TextFormField(
                          maxLength: kMaxQrCodePointName,
                          controller: _cqrPointController,
                          validator: (value) {
                            if (value.trim().isEmpty)
                              return 'please enter qr code name';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'QR Point Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.zero,
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () async {
                            // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     backgroundColor: Colors.amberAccent,
                            //     content: ListTile(
                            //       leading: Icon(
                            //         Icons.warning_amber_outlined,
                            //         color: Colors.black,
                            //         size: 50,
                            //       ),
                            //       title: Text(
                            //         'You should be present at exact location where you want to stick it.',
                            //       ),
                            //     ),
                            //     action: SnackBarAction(
                            //       textColor: Colors.orange[900],
                            //       label: 'Dismiss',
                            //       onPressed: () {
                            //         ScaffoldMessenger.of(context)
                            //             .hideCurrentSnackBar();
                            //       },
                            //     ),
                            //   ),
                            // );
                            // prefs.setString(
                            //   'latitude',
                            //   currentPositionLatLng.latitude.toString(),
                            // );
                            // prefs.setString(
                            //   'longitude',
                            //   currentPositionLatLng.longitude.toString(),
                            // );
                            if (_qrName.currentState.validate()) {
                              if (widget.action.contains('edit')) {
                                dev.log(
                                  'edit',
                                  name: 'update() generate qr code',
                                );
                                await updateQrCodePoint();
                              } else {
                                dev.log(
                                  'add',
                                  name: 'add() generate qr code',
                                );
                                await addQrCodePoint();
                              }
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              await SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowCaseQr(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 100,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                              gradient: kGradient,
                            ),
                            child: Text('Submit'),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _displayBanner
                    ? MaterialBanner(
                        padding: EdgeInsets.all(10.0),
                        forceActionsBelow: false,
                        backgroundColor: Colors.white,
                        content: Text(
                          'Hold & Drag the marker at the correct organization location.',
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: 30,
                          child: Center(
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                        actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _displayBanner = false;
                                });
                              },
                              child: Text(
                                'Dismiss',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ])
                    : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
