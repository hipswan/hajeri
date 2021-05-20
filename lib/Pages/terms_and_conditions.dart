import 'package:flutter/material.dart';
import '../components/side_bar.dart';
import '../url.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditions extends StatefulWidget {
  static String id = 'terms_and_condition';
  @override
  TermsAndConditionsState createState() => TermsAndConditionsState();
}

class TermsAndConditionsState extends State<TermsAndConditions> {
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
            section: 'terms_and_conditions',
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Terms And Condition',
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
              initialUrl: kTermsAndConditions,
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
