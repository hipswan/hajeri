import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Pages/landing.dart';
import '../Pages/otp_verify.dart';
import '../Pages/register.dart';
import '../Pages/verify_otp.dart';
import '../components/transition.dart';
import '../url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';

class SignUp extends StatefulWidget {
  static String id = "sign_up";
  const SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _cNumber;

  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cNumber = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: Text(
          'Hajeri',
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: LimitedBox(
                  maxHeight: height * 0.33,
                  child: FractionallySizedBox(
                    widthFactor: 0.70,
                    heightFactor: 1,
                    child: Card(
                      child: Image(
                        // color: Colors.blue[50],
                        // colorBlendMode: BlendMode.hue,
                        image: AssetImage(
                          'assets/images/hajeri_login.jpg',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),

                    // Placeholder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: kTextStyleSignUp,
                  ),
                ),
              ),
            ],
          ),
          // SizedBox(
          //   height: 15,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _cNumber,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.trim().length == 10) {
                    FocusScope.of(context).requestFocus(
                      new FocusNode(),
                    );
                  }
                },
                validator: (value) {
                  if (value.trim().length == 0) {
                    return "Please Enter Mobile Number";
                  }
                  if (value.trim().length > 10 ||
                      value.trim().length < 10 ||
                      value.trim().contains(new RegExp(r'[A-Za-z/@_-]'))) {
                    return "Please Enter Valid Mobile Number";
                  }
                  if (value.trim().length == 10) {
                    FocusScope.of(context).requestFocus(
                      new FocusNode(),
                    );
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixText: '+91',
                  border: OutlineInputBorder(),
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(
                    Icons.phone_android_rounded,
                  ),
                  hintText: 'Can I have your number?',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
              ),
              onPressed: () async {
                // ignore: null_aware_in_condition
                if (_formKey.currentState.validate()) {
                  log('form validation successful');
                  FocusScope.of(context).requestFocus(new FocusNode());
                  await SystemChannels.textInput.invokeMethod('TextInput.hide');
                  Navigator.push(
                    context,
                    EnterExitRoute(
                      exitPage: widget,
                      enterPage: OtpVerify(
                        number: _cNumber.text,
                      ),
                    ),
                  );
                } else {
                  log('Error');
                }
              },
              child: Container(
                width: width * 0.5,
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    5.0,
                  ),
                  gradient: kGradient,
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: kSignUpTextStyle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: Text(
              'if you are an employee, directly sign in',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Not Registered yet?'),

                  SizedBox(
                    height: 15,
                  ),

                  //Register Now Button
                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.white,
                      ),
                      side: MaterialStateProperty.all(
                        BorderSide(
                          color: Colors.blue[800],
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              8.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        EnterExitRoute(
                          exitPage: widget,
                          enterPage: Register(),
                        ),
                      );
                    },
                    child: Container(
                      width: width * 0.80,
                      padding: EdgeInsets.symmetric(
                        vertical: 20.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        // gradient: kGradient,
                      ),
                      child: Center(
                        child: Text(
                          'Register Now',
                          style: kRegisterButtonStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
