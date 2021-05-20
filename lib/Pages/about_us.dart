import 'package:flutter/material.dart';
import '../components/side_bar.dart';
import '../url.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class AboutUsPage extends StatefulWidget {
  static String id = 'about_us';
  final url;

  AboutUsPage({this.url});
  @override
  AboutUsPageState createState() => AboutUsPageState();
}

class AboutUsPageState extends State<AboutUsPage> {
  bool isLoading = true;
  // WebViewController _controller;
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: SideBar(
            section: 'about_us',
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'About  Us',
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.redAccent,
                  )
                : Container(),
            WebView(
              initialUrl: kAboutUs,
              onProgress: (int progress) {
                print("WebView is loading..");
              },
              onPageFinished: (String value) {
                print('Page finished Loading');
                setState(() {
                  isLoading = false;
                });
              },
              // onWebViewCreated: (WebViewController webViewController) {
              //   print('In  web view');
              //   _controller = webViewController;
              //   _loadHtmlFromAssets();
              // },
              // onPageFinished: (String value) async {
              //   await Future.delayed(
              //       Duration(
              //         seconds: 60,
              //       ), () {
              //     print('Page finished Loading');
              //     setState(() {
              //       isLoading = false;
              //     });
              //   });
              // },
            ),
          ],
        ),
      ),
    );
  }

  // _loadHtmlFromAssets() async {
  //   // String fileText = await rootBundle.loadString('assets/help.html');

  //   _controller.loadUrl(Uri.dataFromString(
  //     "<!DOCTYPE html><html><script>var fr = new FileReader();fr.onload = function (evtLoaded) {\$('#pdf').attr('data', evtLoaded.target.result);};fr.readAsDataURL(inFile);</script><body><object data='${widget.url}' type='application/pdf'></object></body></html>",
  //     mimeType: 'text/html',
  //     encoding: Encoding.getByName('utf-8'),
  //   ).toString());
  // }
}
