import 'package:flutter/material.dart';
import '../Pages/otp_verify.dart';
import '../components/transition.dart';
import 'dart:developer' as dev;

import 'package:sms_autofill/sms_autofill.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _cNumber;

  var _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _cNumber = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    dev.log(mediaQuery.size.height.toString(), name: 'Sign Up');

    var signUp = SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              top: mediaQuery.size.height * 0.08,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Account Login',
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
                        'Please enter your valid mobile number to access your Hajeri account.',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      'Mobile Number'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      width: mediaQuery.size.width - 50,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          maxLength: 10,
                          controller: _cNumber,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.trim().length == 0) {
                              return "Please Enter Mobile Number";
                            }
                            if (value.trim().length > 10 ||
                                value.trim().length < 10 ||
                                value
                                    .trim()
                                    .contains(new RegExp(r'[A-Za-z/@_-]'))) {
                              return "Please Enter Valid Mobile Number";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.phone_android_rounded,
                            ),
                            prefix: Text('+91'),
                            hintText: 'Enter mobile number',
                            // labelText: 'Enter mobile number',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      'Enter your 10 digit mobile number',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                    ),
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
                    if (_formKey.currentState.validate()) {
                      dev.log('form validation successful', name: 'Sign Up');

                      Navigator.push(
                        context,
                        EnterExitRoute(
                          exitPage: widget,
                          enterPage: OtpVerify(
                            number: _cNumber.text,
                          ),
                        ),
                      );
                    } else {}
                  },
                  child: Container(
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
            ),
          ],
        ),
      ),
    );
    return signUp;
  }

  @override
  void dispose() {
    _cNumber.dispose();
    super.dispose();
  }
}
