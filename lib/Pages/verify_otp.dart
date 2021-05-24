import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../Pages/landing.dart';
import '../Pages/register.dart';
import '../url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../constant.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';

import '../main.dart';

class VerifyOtp extends StatefulWidget {
  static const id = 'verify_otp';

  final String number;
  VerifyOtp({
    @required this.number,
  });

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with CodeAutoFill {
  String otpcode;
  bool isCodeSent = false;
  String verificationCode;

  Future<void> sendCode(String number) async {
    // number = '7030515696';

    print("phone no is " + number);
    var response = await http.get(Uri.parse('$kSendOtp$number'), headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      setState(() {
        isCodeSent = true;
      });
      var data = json.decode(response.body);
      log("the data is " + data.toString(), name: 'In send otp verify');

      if (data['already_present_status']
          .toString()
          .trim()
          .toLowerCase()
          .contains("not registered")) {
        Navigator.pushNamed(
          context,
          Register.id,
        );
      } else
      // if (data['already_present_status']
      //     .toString()
      //     .trim()
      //     .toLowerCase()
      //     .contains("yes")
      //     )
      {
        String workerId, orgId, orgName, empName;

        if (data['worker_id'] == null)
          workerId = "No Data";
        else
          workerId = data['worker_id'];
        if (data['org_id'] == null)
          orgId = "No Data";
        else
          orgId = data['org_id'];
        if (data['org_name'] == null)
          orgName = "No Data";
        else
          orgName = data['org_name'];
        if (data['emp_name'] == null)
          empName = "No Data";
        else
          empName = data['emp_name'];
        prefs.setString("mobile", number.toString());
        prefs.setString("worker_id", workerId);
        prefs.setString("org_id", orgId);
        prefs.setString("org_name", orgName);
        prefs.setString("emp_name", empName);
        prefs.setBool("login", true);
        prefs.setString("role", data['role']);
        setState(() {
          verificationCode = data['id'].toString() ?? "error";
          print(verificationCode);

          // otpcode = verificationCode;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    listenForCode();
    otpcode = "";
    verificationCode = "";

    sendCode(widget.number);
    SmsAutoFill().getAppSignature.then((signature) {
      log(signature);
    });
    // _listOtp();
  }

  @override
  void codeUpdated() {
    log(code);
    setState(() {
      otpcode = code;
    });
  }

//   sendCode() async {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: '+91${widget.phoneNumber}',
//       timeout: const Duration(seconds: 60),
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // ANDROID ONLY!
//         log('Sms-code: ${credential.smsCode} , Verification-code: ${credential.verificationId}');

//         //Show Success Animation from Flare-Rive
//         // await showDialog(
//         //   context: context,
//         //   builder: (context) => AlertDialog(
//         //     title: Text(
//         //       'Successful',
//         //       textAlign: TextAlign.center,
//         //     ),
//         //     content: Container(
//         //       width: 300,
//         //       height: 300,
//         //       child: FlareActor(
//         //         'assets/animation/success.flr',
//         //         animation: 'success',
//         //         fit: BoxFit.contain,
//         //         alignment: Alignment.center,
//         //       ),
//         //     ),
//         //   ),
//         // );
//         // Sign the user in (or link) with the auto-generated credential

//         try {
//           UserCredential userCredential =
//               await auth.signInWithCredential(credential);
//           Navigator.push(
//             context,
//             EnterExitRoute(
//               exitPage: widget,
//               enterPage: LandingPage(
//                 user: userCredential.user,
//               ),
//             ),
//           );
//         } on FirebaseAuthException catch (e) {
//           if (e.code == '') {
//             log('Session Expired');
//           }
//         } catch (e) {}
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         if (e.code == 'invalid-phone-number') {
//           print('The provided phone number is not valid.');
//         }

//         // Handle other errors
//       },
//       codeSent: (String verificationId, int resendToken) async {
//         // Update the UI - wait for the user to enter the SMS code
//         // String smsCode = 'xxxx';

//         setState(() {
//           verificationCode = verificationId;
//           isCodeSent = true;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
// //AutoResolution timeout
//       },
//     );
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
        title: Text(
          "Verify phone",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 5,
        centerTitle: true,
        textTheme: Theme.of(context).textTheme,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              color: Colors.white,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      height: 20,
                      child: isCodeSent
                          ? Text(
                              "Code is sent to " + widget.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF818181),
                              ),
                            )
                          : FractionallySizedBox(
                              heightFactor: 0.3,
                              child: LinearProgressIndicator(),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 50.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        otpcode.length > 0
                            ? buildCodeNumberBox(
                                otpcode.substring(0, 1),
                                textColor: Colors.white,
                                boxGradient: kGradient,
                              )
                            : buildCodeNumberBox(
                                "",
                                textColor: Color(0xFF1F1F1F),
                                boxGradient: kEmptyBoxGradient,
                              ),
                        otpcode.length > 1
                            ? buildCodeNumberBox(
                                otpcode.substring(1, 2),
                                textColor: Colors.white,
                                boxGradient: kGradient,
                              )
                            : buildCodeNumberBox(
                                "",
                                textColor: Color(0xFF1F1F1F),
                                boxGradient: kEmptyBoxGradient,
                              ),
                        otpcode.length > 2
                            ? buildCodeNumberBox(
                                otpcode.substring(2, 3),
                                textColor: Colors.white,
                                boxGradient: kGradient,
                              )
                            : buildCodeNumberBox(
                                "",
                                textColor: Color(0xFF1F1F1F),
                                boxGradient: kEmptyBoxGradient,
                              ),
                        otpcode.length > 3
                            ? buildCodeNumberBox(
                                otpcode.substring(3, 4),
                                textColor: Colors.white,
                                boxGradient: kGradient,
                              )
                            : buildCodeNumberBox(
                                "",
                                textColor: Color(0xFF1F1F1F),
                                boxGradient: kEmptyBoxGradient,
                              ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Didn't recieve code? ",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF818181),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            print("Resend the code to the user");

                            Toast.show(
                              "Resending the code".toLowerCase(),
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                              textColor: Colors.red,
                            );
                            if (isCodeSent) {
                              setState(() {
                                isCodeSent = false;
                              });
                            }
                            sendCode(widget.number);
                          },
                          child: Text(
                            "Request again",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.13,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    if (otpcode.length == 4) {
                      log(otpcode);
                      log(verificationCode);
                      if (otpcode.compareTo(verificationCode) == 0) {
                        Navigator.pushNamed(
                          context,
                          Landing.id,
                        );
                      } else {
                        Toast.show(
                          "Not the proper code".toLowerCase(),
                          context,
                          duration: Toast.LENGTH_LONG,
                          gravity: Toast.BOTTOM,
                          textColor: Colors.red,
                        );
                      }
                    } else {
                      Toast.show(
                        "Please Enter All Four Digits".toLowerCase(),
                        context,
                        duration: Toast.LENGTH_LONG,
                        gravity: Toast.BOTTOM,
                        textColor: Colors.red,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: kGradient,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Verify and Create Account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: NumericPad(
                onNumberSelected: (value) {
                  print(value);
                  setState(() {
                    if (value != -1) {
                      if (otpcode.length < 4) {
                        otpcode = otpcode + value.toString();
                      }
                    } else {
                      if (otpcode.length > 0)
                        otpcode = otpcode.substring(0, otpcode.length - 1);
                    }
                    print(otpcode);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCodeNumberBox(String codeNumber,
      {Color textColor, LinearGradient boxGradient}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            gradient: boxGradient,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 25.0,
                  spreadRadius: 1,
                  offset: Offset(0.0, 0.75))
            ],
          ),
          child: Center(
            child: Text(
              codeNumber,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NumericPad extends StatelessWidget {
  final Function(int) onNumberSelected;

  NumericPad({@required this.onNumberSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildNumber(1),
                buildNumber(2),
                buildNumber(3),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildNumber(4),
                buildNumber(5),
                buildNumber(6),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildNumber(7),
                buildNumber(8),
                buildNumber(9),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildEmptySpace(),
                buildNumber(0),
                buildBackspace(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumber(int number) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onNumberSelected(number);
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackspace() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onNumberSelected(-1);
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.backspace,
                size: 28,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptySpace() {
    return Expanded(
      child: Container(),
    );
  }
}
