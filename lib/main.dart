import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true,
  );
  prefs = await SharedPreferences.getInstance();
  SharedPreferences.setMockInitialValues({
    'login': false,
    'name': '',
    'number': '',
  });

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
        textTheme: GoogleFonts.comfortaaTextTheme(),
        // rubikTextTheme()
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
              return Signup();
            }
          },
        ),
      ),
    );
  }
}
