import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajeri_demo/Pages/generate_qr.dart';
import 'package:hajeri_demo/Pages/display_qr.dart';
import 'package:hajeri_demo/Pages/qr_code_point.dart';
import 'package:hajeri_demo/components/side_bar.dart';
import 'package:hajeri_demo/main.dart';
import 'package:hajeri_demo/url.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';

class MaintainQr extends StatefulWidget {
  static const id = 'maintain_qr';
  MaintainQr({Key key}) : super(key: key);

  @override
  _MaintainQrState createState() => _MaintainQrState();
}

class _MaintainQrState extends State<MaintainQr> {
  String isPointPresent = "no result";
  List qrCodePointList = [];

  @override
  void initState() {
    super.initState();
    isLatLngPresent().then((value) {
      if (value.contains("success")) {
        isPointPresent = 'present';
      } else if (value.contains('failure')) {
        isPointPresent = 'absent';
      }
      setState(() {});
    });
  }

  Future<String> isLatLngPresent() async {
    String orgId = prefs.getString("worker_id");
    String mobile = prefs.getString("mobile");
    log('$kQRPointList$orgId/$mobile');
    var response = await http.get('$kQRPointList$orgId/$mobile');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        qrCodePointList = data;
      }
      log(data.toString());

      return "success";
    } else {
      return 'failure';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: SideBar(
            section: 'maintain_qr',
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[700],
          onPressed: () {
            // debugger();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return GenerateQR(
                  action: 'add',
                  title: 'Generate Qr',
                );
              }),
            );
          },
          child: Icon(
            Icons.playlist_add,
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Maintain QR',
          ),
          centerTitle: true,
        ),
        body: Container(color: Colors.white, child: getQRCodeView()),
      ),
    );
  }

  getQRCodeView() {
    switch (isPointPresent) {
      case "no result":
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case "present":
        return QrCodePointView(
          pointList: qrCodePointList,
        );
        break;
      case "absent":
        return GenerateQR();
        break;
    }
  }
}
