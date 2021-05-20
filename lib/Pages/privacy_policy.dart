import 'package:flutter/material.dart';
import '../components/side_bar.dart';
import '../url.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  static String id = 'privacy_policy';
  @override
  PrivacyPolicyPageState createState() => PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool isLoading = true;
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
            section: 'privacy_policy',
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Privacy Policy',
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
              initialUrl: kPrivacyPolicy,
              onProgress: (int progress) {
                print("WebView is loading..");
              },
              onPageFinished: (String value) {
                print('Page finished Loading');
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
