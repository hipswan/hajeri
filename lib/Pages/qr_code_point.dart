import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hajeri_demo/Pages/display_qr.dart';
import 'package:hajeri_demo/Pages/generate_qr.dart';
import 'package:hajeri_demo/Pages/maintain_qr.dart';
import 'package:hajeri_demo/constant.dart';
import 'package:hajeri_demo/main.dart';
import 'package:hajeri_demo/url.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class QrCodePointView extends StatefulWidget {
  final List pointList;
  QrCodePointView({Key key, this.pointList}) : super(key: key);

  @override
  _QrCodePointViewState createState() => _QrCodePointViewState();
}

class _QrCodePointViewState extends State<QrCodePointView> {
  deleteQrCodePoint({
    String mobile,
    String point,
  }) async {
    String orgId = prefs.getString('worker_id');
    dev.log('$kDeleteQRCodePoint$orgId/$mobile/$point');
    var response = await http.get(
      '$kDeleteQRCodePoint$orgId/$mobile/$point',
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      dev.log(data['success_message'].toString().trim().toLowerCase());

      return data['success_message'].toString().trim().toLowerCase();
    } else {
      return 'failure';
    }
  }

  @override
  Widget build(BuildContext context) {
    var qrCodePoint = widget.pointList.first;

    var position = qrCodePoint["latlong"].toString().split(',');
    var mediaQuery = MediaQuery.of(context);
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: mediaQuery.size.width * 0.08,
            left: mediaQuery.size.width * 0.1,
            right: mediaQuery.size.width * 0.1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DisplayQr(
                        latitude: position[0],
                        longitude: position[1],
                        pointName: qrCodePoint['nameofqrcodepoint'],
                      );
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(
                                3.0,
                              ),
                            ),
                            child: QrImage(
                              padding: EdgeInsets.all(
                                5.0,
                              ),
                              size: mediaQuery.size.width * 0.25,
                              foregroundColor: Colors.white,
                              data:
                                  'Hajeri_${prefs.getString("worker_id")}_${position[0]}_${position[1]}',

                              // onError: (ex) {
                              //   print("[QR] ERROR - $ex");
                              //   setState(() {
                              //     _inputErrorText =
                              //     "Error! Maybe your input value is too long?";
                              //   });
                              // },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MainQrDetail(
                                name: 'Name:',
                                mobile: 'Mobile:',
                                latitude: 'Lat:',
                                longitude: 'Long:',
                                status: 'Status:',
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Expanded(
                                child: MainQrDetail(
                                  name: qrCodePoint["nameofqrcodepoint"],
                                  mobile: qrCodePoint["mobile"],
                                  latitude: qrCodePoint["latlong"]
                                      .toString()
                                      .split(',')[0],
                                  longitude: qrCodePoint["latlong"]
                                      .toString()
                                      .split(',')[1],
                                  status: qrCodePoint["status"],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: Divider(
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return GenerateQR(
                                          latitude: position[0],
                                          longitude: position[1],
                                          pointName:
                                              qrCodePoint["nameofqrcodepoint"],
                                          action: 'edit',
                                          title: 'Update Qr');
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                String result = await deleteQrCodePoint(
                                  mobile: qrCodePoint['mobile'],
                                  point: qrCodePoint['nameofqrcodepoint'],
                                );

                                if (result != null) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                MaintainQr.id,
                                              );
                                            },
                                            child: Text('back'),
                                          )
                                        ],
                                        content: Text(
                                          result,
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.6,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                  8.0,
                  10.0,
                  8.0,
                  10.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      20.0,
                    ),
                    topRight: Radius.circular(
                      20.0,
                    ),
                  ),
                  color: Colors.grey[100],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: widget.pointList.length - 1,
                        itemBuilder: (BuildContext context, int index) {
                          var qrCodePoint = widget.pointList[index + 1];

                          var position =
                              qrCodePoint["latlong"].toString().split(',');

                          return Slidable(
                            actionPane: SlidableScrollActionPane(),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: SlideAction(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return GenerateQR(
                                              latitude: position[0],
                                              longitude: position[1],
                                              pointName: qrCodePoint[
                                                  "nameofqrcodepoint"],
                                              action: 'edit',
                                              title: 'Update Qr');
                                        },
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: kGradient,
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            secondaryActions: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: SlideAction(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onTap: () async {
                                    String result = await deleteQrCodePoint(
                                      mobile: qrCodePoint['mobile'],
                                      point: qrCodePoint['nameofqrcodepoint'],
                                    );

                                    if (result != null) {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      MaintainQr.id,
                                                    );
                                                  },
                                                  child: Text('back'),
                                                )
                                              ],
                                              content: Text(
                                                result,
                                              ),
                                            );
                                          });
                                    }
                                  },
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                  6.0,
                                  8.0,
                                  6.0,
                                  8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: kGradient,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return DisplayQr(
                                            latitude: position[0],
                                            longitude: position[1],
                                            pointName: qrCodePoint[
                                                'nameofqrcodepoint'],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        3.0,
                                      ),
                                    ),
                                    child: QrImage(
                                      padding: EdgeInsets.all(
                                        5.0,
                                      ),
                                      foregroundColor: Colors.white,
                                      data:
                                          'Hajeri_${prefs.getString("worker_id")}_${position[0]}_${position[1]}',

                                      // onError: (ex) {
                                      //   print("[QR] ERROR - $ex");
                                      //   setState(() {
                                      //     _inputErrorText =
                                      //     "Error! Maybe your input value is too long?";
                                      //   });
                                      // },
                                    ),
                                  ),
                                  title: Text(
                                    qrCodePoint['nameofqrcodepoint'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '',
                                  ),
                                  // Text(
                                  //   qrCodePoint['latlong'] ?? '',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                ),
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
        ],
      ),
    );
  }
}

class MainQrDetail extends StatelessWidget {
  final name;
  final mobile;
  final latitude;

  final longitude;

  final status;

  const MainQrDetail({
    Key key,
    this.name,
    this.mobile,
    this.latitude,
    this.longitude,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
            ),
            child: Text(
              name,
              style: kMainQrPointTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
            ),
            child: Text(
              mobile,
              style: kMainQrPointTextStyle,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(
          //     bottom: 8.0,
          //   ),
          //   child: Text(
          //     latitude,
          //     style: kMainQrPointTextStyle,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(
          //     bottom: 8.0,
          //   ),
          //   child: Text(
          //     longitude,
          //     style: kMainQrPointTextStyle,
          //   ),
          // ),
          // Text(
          //   status,
          //   style: kMainQrPointTextStyle,
          // ),
        ],
      ),
    );
  }
}
