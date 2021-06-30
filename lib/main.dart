import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import './Pages/about_us.dart';
import './Pages/contact_us.dart';
import './Pages/dashboard.dart';
import './Pages/generate_qr.dart';
import './Pages/landing.dart';
import './Pages/maintain_branch.dart';
import './Pages/maintain_qr.dart';
import './Pages/privacy_policy.dart';
import './Pages/sign_up_update.dart';
import './Pages/terms_and_conditions.dart';
import './Pages/verify_otp.dart';
import './Pages/profile.dart';
import './Pages/scanner.dart';
import './Pages/sign_up.dart';
import './Pages/monthly_attendance.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/register.dart';
import 'Pages/display_qr.dart';
import 'Pages/employee_details.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';
import 'url.dart';

SharedPreferences prefs;
FirebaseMessaging messaging;

final newVersion = NewVersion(
  iOSId: 'com.hajeri.amventures',
  androidId: 'am.attendance.hajeri',
);
VersionStatus status;
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
    dev.log('In foreground');
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
  await Firebase.initializeApp();

  prefs = await SharedPreferences.getInstance();
  messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String token = await messaging.getToken();
  dev.log(token, name: 'Firebase notification');
  await saveTokenToSharedPreferences(token);
  // Any time the token refreshes, store this in the database too.
  messaging.onTokenRefresh.listen(saveTokenToSharedPreferences);

  // SharedPreferences.setMockInitialValues({
  //   'login': null,
  //   'name': '',
  //   'number': '',
  //   'showcase': null,
  // });
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
      home: SignUp(),
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
        EmployeeDetails.id: (_) => EmployeeDetails(),
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
      home: Home(),
    );
  }

// ignore: missing_return

}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWait = true;
  String userStatusCheck = "no result";
  String hajeriLevel;
  String mainBankId;

  Future<String> checkUserRole() async {
    try {
      dev.log("$kUserDetails${prefs.getString('mobile')}");
      var response = await http.get(
        Uri.parse(
          '$kUserDetails${prefs.getString('mobile')}',
        ),
      );
      // dev.debugger();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        dev.log("$data");
        if (data['hajerilevel'] == null)
          hajeriLevel = "No Data";
        else
          hajeriLevel = data['hajerilevel'];
        if (data['mainbankid'] == null && data['hajerilevel'] == "Hajeri-Head")
          mainBankId = data['id'].toString();
        else
          mainBankId = data['mainbankid'].toString();
        if (data['id'] == null)
          prefs.setString("worker_id", "No Data");
        else
          prefs.setString("worker_id", data["id"].toString());
        if (data['tokenforuser'] == null) {
          try {
            var response = await http.post(Uri.parse(
                '$kSaveToken${prefs.getString('worker_id')}/${prefs.getString('mobile')}?userfirebasetoken=${prefs.getString('token')}'));

            if (response.statusCode == 200) {
              var data = json.decode(response.body);
              dev.log('token ${data.toString()}');
              return "success";
            } else {
              return "server issue";
            }
          } on SocketException catch (e) {
            return "no internet";
          } catch (e) {
            return "error occurred";
          }
        } else {
          dev.log("$data['tokenforuser']");
        }
        // dev.log(data.toString());
        prefs.setBool("is_sub_org", hajeriLevel.contains("Hajeri-Head-1"));
        prefs.setString("hajeri_level", hajeriLevel);
        prefs.setString("main_bank_id", mainBankId);
        String mainBankIdfromPrefs = prefs.getString("main_bank_id");
        dev.log(
            "main_bank_idfromprefs: $mainBankIdfromPrefs, main_bank_id: $mainBankId");
        prefs.setBool("is_org",
            data['roles'].trim().toLowerCase().contains('role_organization'));
        return "success";
      } else {
        return "server issue";
      }
    } on SocketException catch (e) {
      return "no internet";
    } catch (e) {
      dev.log('error occurred: $e');
      return "error occurred";
    }
  }

  // ignore: missing_return
  Widget getAfterRegisterPage() {
    switch (userStatusCheck) {
      case "no result":
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
        break;
      case "success":
        return Landing(
          initialPageIndex: 1,
        );
        break;

      case "error occurred":
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
                'Error has occurred',
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

  @override
  void initState() {
    super.initState();

    if (prefs?.getBool('login') != null) {
      checkUserRole().then((value) {
        dev.log(value.toString());
        setState(() {
          userStatusCheck = value;
        });
      });
    }
    checkVersion();
  }

  checkVersion() async {
    status = await newVersion.getVersionStatus();
    dev.log(status.appStoreLink);
    dev.log(status.localVersion);
    dev.log(status.storeVersion);
    if (status.canUpdate && Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 225,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/vectors/update_app.svg',
                              width: 130,
                              height: 130,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Update "Hajeri"',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10.0,
                                ),
                                child: Text(
                                  'You are using ${status.localVersion}, version ${status.storeVersion} is present on playstore',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 60.0,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        8.0,
                                      ),
                                      child: OutlinedButton(
                                        style: ButtonStyle(),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Center(
                                          child: Text('Ignore'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        8.0,
                                      ),
                                      child: OutlinedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Colors.blue,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (await canLaunch(
                                              status.appStoreLink)) {
                                            await launch(status.appStoreLink);
                                          } else {
                                            throw 'Could not launch appStoreLink';
                                          }
                                        },
                                        child: Center(
                                          child: Text(
                                            'Update',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      newVersion.showAlertIfNecessary(context: context);
    }

    // newVersion.showUpdateDialog(
    //   context: context,
    //   versionStatus: status,
    //   dialogTitle: 'Update!!',
    //   dialogText: 'Custom dialog text',
    //   updateButtonText: 'Update',
    //   dismissButtonText: 'Ignore',
    //   dismissAction: () => functionToRunAfterDialogDismissed(),
    // );

    // newVersion.showAlertIfNecessary(context: context);
  }

  functionToRunAfterDialogDismissed() {
    print('dismissed');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (context) {
          // ignore: null_aware_in_logical_operator
          if (prefs != null &&
              prefs.containsKey('login') &&
              prefs.get('login') != null &&
              prefs.get('login')) {
            // dev.debugger();

            return Material(
              child: getAfterRegisterPage(),
            );
          } else {
            return SignUp();
          }
        },
      ),
    );
  }
}
