import 'package:flutter/material.dart';
import '../components/side_bar.dart';
import '../url.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class ContactUsPage extends StatefulWidget {
  static String id = 'contact_us';
  @override
  ContactUsPageState createState() => ContactUsPageState();
}

class ContactUsPageState extends State<ContactUsPage> {
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
            section: 'contact_us',
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Contact  Us',
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
              initialUrl: kContactUs,
              onProgress: (int progress) {
                print("WebView is loading..");
              },
              onPageFinished: (String value) {
                print('Page finished Loading');
                setState(
                  () {
                    isLoading = false;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
