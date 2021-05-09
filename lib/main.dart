import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hajeri_demo/Pages/about_us.dart';
import 'package:hajeri_demo/Pages/contact_us.dart';
import 'package:hajeri_demo/Pages/dashboard.dart';
import 'package:hajeri_demo/Pages/generate_qr.dart';
import 'package:hajeri_demo/Pages/landing.dart';
import 'package:hajeri_demo/Pages/maintain_branch.dart';
import 'package:hajeri_demo/Pages/maintain_qr.dart';
import 'package:hajeri_demo/Pages/privacy_policy.dart';
import 'package:hajeri_demo/Pages/sign_up_update.dart';
import 'package:hajeri_demo/Pages/terms_and_conditions.dart';
import 'package:hajeri_demo/Pages/verify_otp.dart';
import 'package:hajeri_demo/Pages/profile.dart';
import 'package:hajeri_demo/Pages/scanner.dart';
import 'package:hajeri_demo/Pages/sign_up.dart';
import 'package:hajeri_demo/Pages/monthly_attendance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/register.dart';
import 'Pages/display_qr.dart';
import 'Pages/employee_detail.dart';

SharedPreferences prefs;
FirebaseMessaging messaging;

Future<void> saveTokenToSharedPreferences(String token) async {
  // Assume user is logged in for this example
  prefs.setString('token', token);
}

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  if (notification != null && android != null) {
    log('In foreground');
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            tag: 'hajeri',
            visibility: NotificationVisibility.public,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@drawable/ic_stat_hajeri',
          ),
        ));
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print('Got a message whilst in the background or terminated!');
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
  print("Handling a background message: ${message.messageId}");
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: false,
  );
  FirebaseApp app = await Firebase.initializeApp();

  prefs = await SharedPreferences.getInstance();
  messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String token = await messaging.getToken();
  log(token, name: 'Firebase notification');
  await saveTokenToSharedPreferences(token);
  // Any time the token refreshes, store this in the database too.
  messaging.onTokenRefresh.listen(saveTokenToSharedPreferences);

  /*SharedPreferences.setMockInitialValues({
    'login': false,
    'name': '',
    'number': '',
  });
*/
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
    MyApp(),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Signup(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      routes: {
        EmployeeDetail.id: (_) => EmployeeDetail(),
        Profile.id: (_) => Profile(),
        Dashboard.id: (_) => Dashboard(),
        MonthlyAttendance.id: (_) => MonthlyAttendance(),
        Scanner.id: (_) => Scanner(),
        VerifyOtp.id: (_) => VerifyOtp(
              number: '',
            ),
        GenerateQR.id: (_) => GenerateQR(),
        SignUp.id: (_) => SignUp(),
        Landing.id: (_) => Landing(
              initialPageIndex: 0,
            ),
        Register.id: (_) => Register(),
        DisplayQr.id: (_) => DisplayQr(),
        AboutUsPage.id: (_) => AboutUsPage(),
        ContactUsPage.id: (_) => ContactUsPage(),
        PrivacyPolicyPage.id: (_) => PrivacyPolicyPage(),
        TermsAndConditions.id: (_) => TermsAndConditions(),
        MaintainQr.id: (_) => MaintainQr(),
        MaintainBranch.id: (_) => MaintainBranch(),
      },
      theme: ThemeData(
        //TODO:Learn Card clip behaviour function
        fontFamily: 'Comfortaa',
        cardTheme: CardTheme(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          elevation: 2,
          shadowColor: Colors.grey,
        ),
        dataTableTheme: DataTableThemeData(
          //Change state<color> of the row depending on the action perform on it
          dataRowColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected))
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            if (states.contains(MaterialState.pressed))
              return Colors.purpleAccent.withOpacity(0.08);

            return null; // Use the default value.
          }),
          dividerThickness: 1.5,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //confortaaTextTheme()
      ),
      home: SafeArea(
        child: Builder(
          builder: (context) {
            // ignore: null_aware_in_logical_operator
            if (prefs != null &&
                prefs.containsKey('login') &&
                prefs.get('login') != null &&
                prefs.get('login')) {
              return Landing(
                initialPageIndex: 1,
              );
            } else {
              return SignUp();
            }
          },
        ),
      ),
    );
  }
}
