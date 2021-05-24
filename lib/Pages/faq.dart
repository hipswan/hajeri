import 'package:flutter/material.dart';
import '../components/side_bar.dart';
import '../url.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class FaqPage extends StatefulWidget {
  static String id = 'faq';
  @override
  FaqPageState createState() => FaqPageState();
}

class FaqPageState extends State<FaqPage> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SideBar(
          section: 'FAQ',
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
      body: WebView(
        initialUrl: kFaq,
        onProgress: (int progress) {
          print("WebView is loading..");
        },
      ),
    );
  }
}
