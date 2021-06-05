import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:showcaseview/showcaseview.dart';
import '../Pages/generate_qr.dart';
import '../Pages/display_qr.dart';
import '../Pages/qr_code_point.dart';
import '../components/side_bar.dart';
import '../main.dart';
import '../url.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';

class ShowCaseQr extends StatelessWidget {
  const ShowCaseQr({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onStart: (index, key) {
        dev.log('onStart: $index, $key');
      },
      onComplete: (index, key) {
        dev.log('onComplete: $index, $key');
        prefs.setBool('showcase_qr', false);
      },
      builder: Builder(builder: (context) => MaintainQr()),
      autoPlay: false,
      autoPlayDelay: Duration(seconds: 3),
      autoPlayLockEnable: false,
    );
  }
}

class MaintainQr extends StatefulWidget {
  static const id = 'maintain_qr';
  MaintainQr({Key key}) : super(key: key);

  @override
  _MaintainQrState createState() => _MaintainQrState();
}

class _MaintainQrState extends State<MaintainQr> {
  String qrPointStatus = "no result";
  List qrCodePointList = [];
  GlobalKey _addQrKey = GlobalKey();

  startShowCase() {
    if (prefs.getBool('showcase_qr') == null) {
      // dev.log('Inside showcase');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Future.delayed(Duration(milliseconds: 350), () {
          ShowCaseWidget.of(context).startShowCase([_addQrKey]);
        });
      });
    }
  }

  @override
  void initState() {
    startShowCase();
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

    super.initState();
  }

  Future<String> isLatLngPresent() async {
    String orgId = prefs.getString("worker_id");
    String mobile = prefs.getString("mobile");
    dev.log('$kQRPointList$orgId/$mobile');
    try {
      var response = await http.get(Uri.parse('$kQRPointList$orgId/$mobile'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        qrCodePointList = data;

        // dev.log(data.toString());

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
    dev.log('In dispose');
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
        floatingActionButton: Showcase(
          key: _addQrKey,
          description: 'Click on Add Button to generate new Qr code points',
          contentPadding: EdgeInsets.all(8.0),
          showcaseBackgroundColor: Colors.blue,
          textColor: Colors.white,
          shapeBorder: CircleBorder(),
          // 9762540886

          child: FloatingActionButton(
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
                      title: 'Generate QR Code',
                    );
                  },
                ),
              );
            },
            child: Icon(
              Icons.playlist_add,
            ),
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Generate QR Code',
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white,
          child: getQRCodeView(),
        ),
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
                'No Qr Code Available',
              ),
            ],
          ),
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
