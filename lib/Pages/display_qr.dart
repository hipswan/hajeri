import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:hajeri_demo/Pages/about_us.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hajeri_demo/Pages/generate_qr.dart';
import 'package:hajeri_demo/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constant.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
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
  ScreenshotController _screenshotController;
  ReceivePort _port = ReceivePort();
  TargetPlatform platform = TargetPlatform.android;

  String _localPath;
  @override
  void initState() {
    super.initState();
    _screenshotController = ScreenshotController();
    _checkPermission();
    _prepare().then((value) => log(value));
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
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    log(_localPath.toString());
    return "success";
  }

  Future<String> _findLocalPath() async {
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text('Display Qr'),
          centerTitle: true,
        ),
        body: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 12.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
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
                                'Hajeri_${prefs.getString("worker_id")}_${widget.latitude}_${widget.longitude}',

                            // onError: (ex) {
                            //   print("[QR] ERROR - $ex");
                            //   setState(() {
                            //     _inputErrorText =
                            //     "Error! Maybe your input value is too long?";
                            //   });
                            // },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero,
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.transparent,
                    ),
                  ),
                  onPressed: () async {
                    log('Pressed Download Button');
                    // await _createFolder();

                    String fileName = DateTime.now().toIso8601String();

                    // var path = '/storage/emulated/0/hajeri';
                    _screenshotController
                        .capture(
                            pixelRatio: 1.5,
                            //set path where screenshot will be saved
                            delay: Duration(milliseconds: 20))
                        .then((value) async {
                      final PdfDocument document = PdfDocument();
                      PdfPageSettings settings = PdfPageSettings();
                      settings.setMargins(50);
                      document.pageSettings = settings;
                      final PdfBitmap qrImage = PdfBitmap(value);
                      document
                        ..pages.add().graphics.drawImage(
                              qrImage,
                              const Rect.fromLTWH(
                                0,
                                0,
                                10,
                                10,
                              ),
                            )
                        ..compressionLevel = PdfCompressionLevel.best;

                      List<int> bytes = document.save();

                      document.dispose();
                      // var a = File('$_localPath/mpdf.pdf').writeAsBytes(bytes);
                      // log("the pdf is $a");

                      Uri pdfDataUri =
                          UriData.fromBytes(bytes, mimeType: "applicaion/pdf")
                              .uri;

                      var pdfDownloadUri =
                          'data:application/pdf;base64,${base64.encode(bytes)}';
                      // try {
                      //   Uri pdfDataUri = Uri(
                      //     scheme: 'data',
                      //     path: pdfDownloadUri,
                      //   );
                      //   launch(pdfDataUri.toString());

                      log(pdfDataUri.toString());
                      // } on Exception catch (e) {
                      //   e.toString();
                      // }

                      // var response = await http.get(pdfDownloadUri,
                      //     headers: {"Content-type": "application/pdf"});
                      // response.statusCode == 200
                      //     ? log(response.body.toString())
                      //     : log(response.request.url.toString());
                      // log(pdfDownloadUri);

                      // HttpClient httpClient = new HttpClient();

                      // try {
                      //   var request = await httpClient.get('data',pdfDownloadUri);
                      //   var response = await request.close();
                      //   response.statusCode == 200
                      //       ? log(response.statusCode.toString())
                      //       : log(response.statusCode.toString());
                      // } on Exception catch (ex) {}

                      final taskId = await FlutterDownloader.enqueue(
                          url: pdfDownloadUri,
                          savedDir: _localPath,
                          fileName: fileName,
                          showNotification: true,
                          openFileFromNotification: true);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutUsPage(
                            url: pdfDownloadUri,
                          ),
                        ),
                      );
                    });
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
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
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
    );
  }
}
