import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  String qrPointStatus = "no result";
  List qrCodePointList = [];

  @override
  void initState() {
    super.initState();
    isLatLngPresent().then((value) {
      if (value.contains("success")) {
        qrCodePointList.isEmpty
            ? qrPointStatus = 'absent'
            : qrPointStatus = 'present';
      } else {
        qrPointStatus = value;
      }
      setState(() {});
    });
  }

  Future<String> isLatLngPresent() async {
    String orgId = prefs.getString("worker_id");
    String mobile = prefs.getString("mobile");
    log('$kQRPointList$orgId/$mobile');
    try {
      var response = await http.get(Uri.parse('$kQRPointList$orgId/$mobile'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        qrCodePointList = data;

        // log(data.toString());

        return "success";
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } on Exception catch (e) {
      return 'error';
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
          heroTag: 'mainQR',
          backgroundColor: Colors.blue[700],
          onPressed: () {
            // debugger();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return GenerateQR(
                    action: 'add',
                    title: 'Generate Qr',
                  );
                },
              ),
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
    switch (qrPointStatus) {
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
        return GenerateQR(
          action: 'add',
          title: 'Generate Qr',
        );
        break;
      case "error":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/vectors/notify.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Error has occured',
              ),
            ],
          ),
        );
        break;
      case "no internet":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/vectors/no_signal.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Device not connected to internet',
              ),
            ],
          ),
        );
        break;
      case "server issue":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/vectors/server_down.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Server error',
              ),
            ],
          ),
        );
        break;
    }
  }
}
