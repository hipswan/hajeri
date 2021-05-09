import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hajeri_demo/Pages/register.dart';
import 'package:hajeri_demo/Pages/sign_up.dart';
import 'package:hajeri_demo/main.dart';
import 'package:hajeri_demo/url.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import 'landing.dart';

class OtpVerify extends StatefulWidget {
  final number;
  OtpVerify({this.number});
  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  String _code;
  String signature = "{{ app signature }}";
  bool isCodeSent = false;
  String verificationCode;
  String workerId, orgId, orgName, empName, role;

  Future<void> sendCode(String number) async {
    try {
      var response = await http.get(Uri.parse('$kSendOtp$number'), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        setState(() {
          isCodeSent = true;
        });
        var data = json.decode(response.body);
        dev.log("the data is " + data.toString(), name: 'In send otp verify');

        if (data['already_present_status']
            .toString()
            .trim()
            .toLowerCase()
            .contains("not registered")) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Register.id,
            (route) => false,
          );
        } else
        // if (data['already_present_status']
        //     .toString()
        //     .trim()
        //     .toLowerCase()
        //     .contains("yes")
        //     )
        {
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
          role = data['role'];

          setState(() {
            verificationCode = data['id'].toString() ?? "error";

            // otpcode = verificationCode;
          });
        }
      } else {
        dev.log(
          '''Could't fetch otp''',
        );
      }
    } on SocketException catch (e) {
      dev.log(e.message);
    } on Exception catch (e) {
      dev.log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    // dev.debugger();
    SmsAutoFill().listenForCode;
    sendCode(widget.number);
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: mediaQuery.size.height,
          width: mediaQuery.size.width,
          child: Stack(
            children: [
              Positioned(
                child: SizedBox(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Positioned(
                top: mediaQuery.size.height * 0.08,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Enter verification code',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: mediaQuery.size.width - 50,
                        child: Text(
                          'A 4-digit OTP verification code has been sent on your phone number. Enter to verify your details.',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '+91 ${widget.number}',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Change $verificationCode',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '4-digit verification Code',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: mediaQuery.size.width * 0.65 - 50,
                        child: PinFieldAutoFill(
                          codeLength: 4,
                          decoration: UnderlineDecoration(
                            textStyle:
                                TextStyle(fontSize: 20, color: Colors.black),
                            colorBuilder: FixedColorBuilder(Colors.blue[800]),
                          ),
                          currentCode: _code,
                          onCodeSubmitted: (code) {
                            // if (code.length == 4) {
                            //   if (code.compareTo(verificationCode) == 0) {
                            //     prefs.setString(
                            //         "mobile", widget.number.toString());
                            //     prefs.setString("worker_id", workerId);
                            //     prefs.setString("org_id", orgId);
                            //     prefs.setString("org_name", orgName);
                            //     prefs.setString("emp_name", empName);
                            //     prefs.setBool("login", true);
                            //     prefs.setString("role", role);
                            //     Navigator.pushNamed(
                            //       context,
                            //       Landing.id,
                            //     );
                            //   } else {
                            //     Toast.show(
                            //       "Not the proper code".toLowerCase(),
                            //       context,
                            //       duration: Toast.LENGTH_LONG,
                            //       gravity: Toast.BOTTOM,
                            //       textColor: Colors.red,
                            //     );
                            //   }
                            // } else {
                            //   Toast.show(
                            //     "Please Enter All Four Digits".toLowerCase(),
                            //     context,
                            //     duration: Toast.LENGTH_LONG,
                            //     gravity: Toast.BOTTOM,
                            //     textColor: Colors.red,
                            //   );
                            // }
                          },
                          onCodeChanged: (code) {
                            if (code.length == 4) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {
                                _code = code;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      !isCodeSent
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                SizedBox(
                                  height: 15.0,
                                  width: 15.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  'Waiting for otp',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'To Resend Code',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      isCodeSent = false;
                                    });

                                    sendCode(widget.number);
                                  },
                                  child: Text(
                                    'click here',
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: mediaQuery.size.height * 0.065,
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.blue[800],
                      ),
                    ),
                    onPressed: () {
                      dev.log('Code is $_code');
                      if (_code.length == 4) {
                        if (_code.compareTo(verificationCode) == 0) {
                          prefs.setString("mobile", widget.number.toString());
                          prefs.setString("worker_id", workerId);
                          prefs.setString("org_id", orgId);
                          prefs.setString("org_name", orgName);
                          prefs.setString("emp_name", empName);
                          prefs.setBool("login", true);
                          prefs.setBool(
                              "is_org",
                              role
                                  .trim()
                                  .toLowerCase()
                                  .contains('role_organization'));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => Landing(
                                initialPageIndex: 1,
                              ),
                            ),
                            (Route<dynamic> route) => false,
                            // ModalRoute.withName(SignUp.id),
                          );
                          // Navigator.pushNamed(
                          //   context,
                          //   Landing.id,
                          // );
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                        ),
                      ],
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
