import 'dart:developer' as dev;
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../Pages/generate_qr.dart';
import '../main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';
import '../constant.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'dart:core';

class DisplayQr extends StatefulWidget {
  static String id = 'display_qr';
  final String latitude;
  final String longitude;
  final String pointName;
  const DisplayQr({
    Key key,
    this.latitude,
    this.longitude,
    this.pointName,
  }) : super(key: key);

  @override
  _DisplayQrState createState() => _DisplayQrState();
}

class _DisplayQrState extends State<DisplayQr> {
  ReceivePort _port = ReceivePort();
  TargetPlatform platform = TargetPlatform.android;
  List<String> _pdfSizeFormatItems = [
    'A4size',
    'A5size',
    'A6size',
  ];
  String pdfSizeDropDownValue = 'A4size';
  static List<DropdownMenuItem<String>> _pdfSizeFormatDropDownItems;

  String _localPath;
  @override
  void initState() {
    super.initState();
    _checkPermission();
    _prepare().then((value) => dev.log(value));
    _pdfSizeFormatDropDownItems = _pdfSizeFormatItems
        .map(
          (pdfSize) => DropdownMenuItem<String>(
            value: pdfSize,
            child: Text(
              pdfSize,
            ),
          ),
        )
        .toList();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  Future<String> _prepare() async {
    _localPath =
        (await _findLocalPath()) + io.Platform.pathSeparator + 'Download';

    final savedDir = io.Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    dev.log(_localPath.toString());
    return "success";
  }

  Future<String> _findLocalPath() async {
    final directory = io.Platform.isAndroid
        ? await path.getExternalStorageDirectory()
        : await path.getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text('Display Qr'),
          centerTitle: true,
        ),
        body: FractionallySizedBox(
          heightFactor: 0.95,
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        5.0,
                        0.0,
                        5.0,
                        0.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan[300],
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Divider(
                              color: Colors.white,
                              thickness: 2.5,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Hajeri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Contactless-Attendance System',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            prefs.getString('org_name'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(
                              20.0,
                              10.0,
                              20.0,
                              10.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                              color: Colors.white,
                            ),
                            child: QrImage(
                              padding: EdgeInsets.all(
                                10.0,
                              ),
                              data:
                                  'Hajeri_${prefs.getString("worker_id")}_${widget.latitude}_${widget.longitude}_${prefs.getString("main_bank_id")}',

                              // onError: (ex) {
                              //   print("[QR] ERROR - $ex");
                              //   setState(() {
                              //     _inputErrorText =
                              //     "Error! Maybe your input value is too long?";
                              //   });
                              // },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Text(
                              widget.pointName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      width: size.width * 0.75,
                      child: DropdownButtonFormField(
                        // disabledHint: const Text(
                        //     'Please Select State First'),
                        value: pdfSizeDropDownValue,
                        // onTap: () {
                        //   FocusScope.of(context).requestFocus(new FocusNode());
                        // },
                        onChanged: (String newValue) {
                          setState(
                            () {
                              pdfSizeDropDownValue = newValue;
                            },
                          );
                        },
                        items: _pdfSizeFormatDropDownItems,
                        // hint: const Text(
                        //   'Select City',
                        // ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                          // log('Pressed Download Button');
                          String fileName =
                              '${prefs.getString('org_id')}_${widget.pointName}_$pdfSizeDropDownValue.pdf';

                          dev.log(
                              "https://hajeri.in/qrcodes/${prefs.getString('org_id')}/${widget.pointName}/$pdfSizeDropDownValue.pdf",
                              name: 'In display qr');
                          try {
                            await FlutterDownloader.enqueue(
                              url:
                                  "https://hajeri.in/qrcodes/${prefs.getString('org_id')}/${widget.pointName}/$pdfSizeDropDownValue.pdf",
                              savedDir: io.Platform.isAndroid
                                  ? '/storage/emulated/0/Download/'
                                  : (await path
                                          .getApplicationDocumentsDirectory())
                                      .path,
                              headers: {'content-type': 'application/pdf'},
                              fileName: fileName,
                              showNotification: true,
                              openFileFromNotification: true,
                            );
                            Toast.show(
                              "file download",
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                              textColor: Colors.green,
                            );
                          } on path
                              .MissingPlatformDirectoryException catch (e1) {
                            dev.log(e1.message, name: 'In flutter downloader');
                            Toast.show(
                              "file not download",
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                              textColor: Colors.redAccent,
                            );
                          } catch (e2) {
                            dev.log(e2.toString(),
                                name: 'In flutter downloader');

                            Toast.show(
                              "file not download",
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                              textColor: Colors.redAccent,
                            );
                          }
                        },
                        child: Container(
                          width: 300,
                          padding: EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                            gradient: kGradient,
                          ),
                          child: Text(
                            'Download QR Code',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return GenerateQR(
                                  latitude: widget.latitude,
                                  longitude: widget.longitude,
                                  pointName: widget.pointName,
                                  action: 'edit',
                                  title: 'Update Qr',
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 300,
                          padding: EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                            gradient: kGradient,
                          ),
                          child: Text(
                            'Update QR Code',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
