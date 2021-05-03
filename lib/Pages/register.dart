import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hajeri_demo/Pages/sign_up.dart';
import 'package:hajeri_demo/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:shimmer/shimmer.dart';

import '../constant.dart';

class Register extends StatefulWidget {
  static String id = "register";
  @override
  RegisterState createState() => new RegisterState();
}

class RegisterState extends State<Register> {
  GlobalKey<FormState> _formState;
  static TextEditingController _cOrgName,
      _cName,
      _cNumber,
      _cDistrict,
      _cAddress;
  List<dynamic> states;
  static bool submitLoader = false;
  static bool switchControl = false;
  static String textHolder = 'Switch is On';
  static String stateDropDownValue,
      cityDropDownValue,
      departmentDropDownValue,
      businessNatureDropDownValue;
  static bool departmentSelected = false;
  static bool stateSelected = false;
  static List<DropdownMenuItem<String>> _cityDropDownMenuItems,
      _departmentDropDownMenuItems,
      _stateDropDownMenuItems,
      _businessNatureDropDownMenuItems;

  RegisterState() {
    _businessNatureDropDownMenuItems = kBusinessNatureMenuItems
        .map(
          (business) => DropdownMenuItem<String>(
            value: business,
            child: Text(
              business,
            ),
          ),
        )
        .toList();
  }

  Future<List<dynamic>> getStateList() async {
    List<dynamic> data = [
      {'': ''}
    ];
    try {
      http.Response response = await http.get(kStates);

      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        data = [
          {"id": -1, "statename": "error couldn't fetch states details"},
        ];
        dev.log('$data');
      }
    } on SocketException catch (e) {
      dev.log(e.message, name: 'register:getstates()');
      data = [
        {"id": -1, "statename": "no internet"},
      ];
    } on Exception catch (e) {
      dev.log(e.toString(), name: 'register:getstates()');
      data = [
        {"id": -1, "statename": "something went wrong"},
      ];
    }

    return data;
  }

  Future<List<dynamic>> getDepartmentList() async {
    List<dynamic> data = [
      {'': ''}
    ];
    try {
      http.Response response = await http.get(kDepartment);
      print(
        response.body,
      );
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        data = [
          {"id": -1, "personname": "error couldn't fetch states details"},
        ];
      }
    } on SocketException catch (e) {
      dev.log(e.message, name: 'register:getdepartment()');
      data = [
        {"id": -1, "personname": "no internet"},
      ];
    } on Exception catch (e) {
      dev.log(e.toString(), name: 'register:getdepartment()');
      data = [
        {"id": -1, "statename": "something went wrong"},
      ];
    }

    return data;
  }

  Future<List<dynamic>> getCityList(String stateId) async {
    List<dynamic> data = [
      {'': ''}
    ];
    dev.log('$kCity/$stateId');
    http.Response response = await http.get('$kCity/$stateId');
    print(
      response.body,
    );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
    } else {
      data = [
        {"id": -1, "cityname": "error couldn't fetch states details"},
      ];
      dev.log('$data');
    }

    return data;
  }

  @override
  void initState() {
    super.initState();
    _formState = GlobalKey<FormState>();
    _cName = TextEditingController();
    _cOrgName = TextEditingController();
    _cDistrict = TextEditingController();
    _cNumber = TextEditingController();
    _cAddress = TextEditingController();
    departmentDropDownValue = null;
    businessNatureDropDownValue = null;
  }

  void toggleSwitch(bool value) async {
    _formState.currentState?.reset();
    _cAddress.clear();
    _cName.clear();
    _cDistrict.clear();
    _cNumber.clear();
    _cOrgName.clear();
    stateDropDownValue = null;
    cityDropDownValue = null;
    stateSelected = false;

    if (switchControl == false) {
      switchControl = true;

      // textHolder = 'Switch is Off';
      states = await getStateList();
      _stateDropDownMenuItems = states
          .map(
            (state) => DropdownMenuItem<String>(
              value: state["id"].toString(),
              child: Text(
                state["statename"].toString(),
              ),
            ),
          )
          .toList();

      setState(() {});
      print('Switch is On $value');
      // Put your code here which you want to execute on Switch ON event.

    } else {
      setState(() {
        switchControl = false;
        // textHolder = 'Switch is On';
      });
      print('Switch is Off $value');
      // Put your code here which you want to execute on Switch OFF event.
    }
  }

  Future<String> createOrgAccount() async {
    String orgState;
    states.forEach((state) {
      if (state['id']
          .toString()
          .trim()
          .contains(stateDropDownValue.toString().trim())) {
        orgState = state["statename"].toString();
      }
    });
    // var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse(
          '$kAddOrg?nameoforganization=${_cOrgName.text.trim()}&personaname=${_cName.text.trim()}&natureofbusiness=$businessNatureDropDownValue&contactpersondeparmentname=$departmentDropDownValue&address=${_cAddress.text.trim()}&mobile=${_cNumber.text.trim()}&state=$stateDropDownValue&district=${_cDistrict.text.trim()}&city=$cityDropDownValue'),
    );
    // request.body = '''{
    //   "nameoforganization": "${_cOrgName.text.trim()}",
    //   "personaname": "${_cName.text.trim()}",
    //   "natureofbusiness": "$businessNatureDropDownValue",
    //   "contactpersondeparmentname": "$departmentDropDownValue",
    //   "address": "${_cAddress.text.trim()}",
    //   "mobile": "${_cNumber.text.trim()}",
    //   "state": "$orgState",
    //   "district":'${_cDistrict.text.trim()}',
    //   "city": "$cityDropDownValue"
    // }''';
    // dev.log('''{
    //   "nameoforganization": "${_cOrgName.text.trim()}",
    //   "personaname": "${_cName.text.trim()}",
    //   "natureofbusiness": "$businessNatureDropDownValue",
    //   "contactpersondeparmentname": "$departmentDropDownValue",
    //   "address": "${_cAddress.text.trim()}",
    //   "mobile": "${_cNumber.text.trim()}",
    //   "state": "$orgState",
    //   "district":'${_cDistrict.text.trim()}',
    //   "city": "$cityDropDownValue"
    // }''');
    // request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Toast.show(
        "Organization has been successfully added",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.greenAccent,
      );
      return "success";
    } else {
      print(response.reasonPhrase);
      Toast.show(
        "Your account is not created",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.red,
      );
      return "failure";
    }
  }

  Future<dynamic> addUser() async {
    String userState;
    states.forEach((state) {
      if (state['id']
          .toString()
          .trim()
          .toLowerCase()
          .contains(stateDropDownValue.toString().trim().toLowerCase())) {
        userState = state["statename"].toString();
      }
    });

    // Map<String, String> body = {
    //   "personaname": "${_cName.text}",
    //   "address": "${_cAddress.text}",
    //   "mobile": "${_cNumber.text}",
    //   "state": "$userState",
    //   "district": "${_cDistrict.text}",
    //   "city": "$cityDropDownValue",
    // };
    // dev.log('''{
    //   "personaname": "${_cName.text}",
    //   "address": "${_cAddress.text}",
    //   "mobile": "${_cNumber.text}",
    //   "state": "$userState",
    //   "district": "${_cDistrict.text}",
    //   "city": "$cityDropDownValue",
    // }''');
    var response = await http.post(
      '''$kAddUser?personaname: ${_cName.text.trim()}&address: ${_cAddress.text.trim()}&mobile: ${_cNumber.text.trim()}&state: $userState&district: ${_cDistrict.text.trim()}&city: $cityDropDownValue''',
      // body: jsonEncode(body),
      // headers: {
      //   'Content-Type': 'application/json',
      // },
    );

    if (response.statusCode == 200) {
      dev.log(response.body.toString());
      Toast.show(
        "Your account has been sucessfully created",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.greenAccent,
      );
      Future.delayed(
          Duration(
            seconds: 1,
          ), () {
        Navigator.pushNamed(
          context,
          SignUp.id,
        );
      });
    } else {
      Toast.show(
        "Your account is not created",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Registration',
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Text(
                        'Organization',
                        style: TextStyle(
                          fontWeight: switchControl
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Transform.scale(
                      scale: 1.5,
                      child: Switch(
                        onChanged: toggleSwitch,
                        value: switchControl,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.blue,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Text(
                        'User',
                        style: TextStyle(
                          fontWeight: switchControl
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10.0,
            ),

            Expanded(
              child: FutureBuilder(
                  // initialData: <Map<String, dynamic>>[
                  //   {
                  //     "id": -1,
                  //     "statename": "Loading States Info....",
                  //   },
                  // ],
                  future: getDepartmentList(),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasData) {
                      _departmentDropDownMenuItems = snapshot.data
                          .map(
                            (department) => DropdownMenuItem<String>(
                              value: department["personname"].toString(),
                              child: Text(
                                department["personname"],
                              ),
                            ),
                          )
                          .toList();

                      return ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: switchControl
                                    ? Builder(
                                        builder: (context) {
                                          return Form(
                                            key: _formState,
                                            child: Column(
                                              children: [
                                                //Person Name
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: TextFormField(
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    textAlign: TextAlign.left,
                                                    controller: _cName,
                                                    validator: (value) {
                                                      if (value
                                                          .trim()
                                                          .isEmpty) {
                                                        return 'Please Enter Your Name';
                                                      }
                                                      if (value.trim().contains(
                                                          new RegExp(
                                                              r'[.@_-]'))) {
                                                        return 'Please Enter Valid Name';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {},
                                                    decoration: InputDecoration(
                                                      // errorText: null,
                                                      hintText: 'Enter Name',
                                                      labelText:
                                                          'Contact Person Name',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                //Address
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    textAlign: TextAlign.left,
                                                    controller: _cAddress,
                                                    validator: (value) {
                                                      if (value
                                                          .trim()
                                                          .isEmpty) {
                                                        return 'Please Enter Your Address';
                                                      }

                                                      return null;
                                                    },
                                                    onChanged: (value) {},
                                                    decoration: InputDecoration(
                                                      // errorText: null,
                                                      hintText: 'Enter Address',
                                                      labelText: 'Address',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),

                                                //Mobile Number
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: TextFormField(
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                      decimal: false,
                                                      signed: false,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                    controller: _cNumber,
                                                    validator: (value) {
                                                      if (value
                                                          .trim()
                                                          .isEmpty) {
                                                        return 'Please Enter Your Mobile Number';
                                                      }
                                                      if (value.trim().length >
                                                              10 ||
                                                          value.trim().contains(
                                                              new RegExp(
                                                                  r'[A-Za-z]'))) {
                                                        return 'Please Enter Valid Number';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {},
                                                    decoration: InputDecoration(
                                                      // errorText: null,
                                                      hintText:
                                                          'Enter Contact Detail',
                                                      labelText:
                                                          'Mobile Number',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                //state drop down
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child:
                                                      DropdownButtonFormField(
                                                    // disabledHint: Text(
                                                    //   'Please Select Department First',
                                                    // ),
                                                    // onTap: () {
                                                    //   stateSelected = false;
                                                    //   cityDropDownValue = null;
                                                    //   setState(() {});
                                                    // },
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              new FocusNode());
                                                    },
                                                    value: stateDropDownValue,
                                                    onChanged: (String
                                                        newValue) async {
                                                      stateDropDownValue =
                                                          newValue;

                                                      if (cityDropDownValue !=
                                                              null &&
                                                          cityDropDownValue
                                                              .isNotEmpty) {
                                                        cityDropDownValue =
                                                            null;
                                                      }
                                                      List<dynamic> cities =
                                                          await getCityList(
                                                              stateDropDownValue);
                                                      _cityDropDownMenuItems =
                                                          cities
                                                              .map(
                                                                (city) =>
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                  value: city[
                                                                          "cityname"]
                                                                      .toString(),
                                                                  child: Text(
                                                                    city["cityname"]
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              )
                                                              .toList();
                                                      stateSelected = true;
                                                      setState(() {});
                                                    },
                                                    items:
                                                        _stateDropDownMenuItems,

                                                    decoration: InputDecoration(
                                                      labelText: 'Select State',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    // hint: const Text('Select State'),
                                                  ),
                                                ),
                                                //District
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    textAlign: TextAlign.left,
                                                    controller: _cDistrict,
                                                    validator: (value) {
                                                      if (value
                                                          .trim()
                                                          .isEmpty) {
                                                        return 'Please Enter District';
                                                      }

                                                      return null;
                                                    },
                                                    onChanged: (value) {},
                                                    decoration: InputDecoration(
                                                      // errorText: null,
                                                      hintText:
                                                          'Enter District',
                                                      labelText: 'District',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),

                                                //city drop down
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child:
                                                      DropdownButtonFormField(
                                                    // disabledHint: const Text(
                                                    //     'Please Select State First'),
                                                    value: cityDropDownValue,
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              new FocusNode());
                                                    },
                                                    onChanged:
                                                        (String newValue) {
                                                      setState(
                                                        () {
                                                          cityDropDownValue =
                                                              newValue;
                                                        },
                                                      );
                                                    },
                                                    items:
                                                        _cityDropDownMenuItems,
                                                    // hint: const Text(
                                                    //   'Select City',
                                                    // ),
                                                    decoration: InputDecoration(
                                                      errorText: !stateSelected
                                                          ? 'Please Select State First'
                                                          : null,
                                                      labelText: 'Select City',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),

                                                //Submit Button User
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (_formState.currentState
                                                        .validate()) {
                                                      var addUserResult =
                                                          await addUser();
                                                      dev.log(addUserResult
                                                          .toString());
                                                    } else {
                                                      Toast.show(
                                                        "Some details are missing",
                                                        context,
                                                        duration:
                                                            Toast.LENGTH_LONG,
                                                        gravity: Toast.BOTTOM,
                                                        textColor:
                                                            Colors.redAccent,
                                                      );
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      Colors.blue[700],
                                                    ),
                                                    padding:
                                                        MaterialStateProperty.all<
                                                            EdgeInsetsGeometry>(
                                                      EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    heightFactor: 2.0,
                                                    child: Text(
                                                      'Submit',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Form(
                                        key: _formState,
                                        child: Column(
                                          children: [
                                            //Organization  Name
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: TextFormField(
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                textAlign: TextAlign.left,
                                                controller: _cOrgName,
                                                maxLength: kMaxOrganizationName,
                                                validator: (value) {
                                                  if (value.trim().isEmpty) {
                                                    return 'Please Enter Your Organisation Name';
                                                  }
                                                  if (value.trim().contains(
                                                      new RegExp(r'[.@_-]'))) {
                                                    return 'Please Enter Valid Name';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {},
                                                decoration: InputDecoration(
                                                  // errorText: null,
                                                  hintText:
                                                      'Enter Organization Name',
                                                  labelText:
                                                      'Organization Name',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            //Person Name
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                textAlign: TextAlign.left,
                                                controller: _cName,
                                                validator: (value) {
                                                  if (value.trim().isEmpty) {
                                                    return 'Please Enter Your Name';
                                                  }
                                                  if (value.trim().contains(
                                                      new RegExp(r'[.@_-]'))) {
                                                    return 'Please Enter Valid Name';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {},
                                                decoration: InputDecoration(
                                                  // errorText: null,
                                                  hintText: 'Enter Name',
                                                  labelText:
                                                      'Contact Person Name',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            //Address
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                textAlign: TextAlign.left,
                                                controller: _cAddress,
                                                validator: (value) {
                                                  if (value.trim().isEmpty) {
                                                    return 'Please Enter Your Address';
                                                  }

                                                  return null;
                                                },
                                                onChanged: (value) {},
                                                decoration: InputDecoration(
                                                  // errorText: null,
                                                  hintText: 'Enter Address',
                                                  labelText: 'Address',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            //Mobile Number
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: TextFormField(
                                                // autovalidateMode:
                                                //     AutovalidateMode
                                                //         .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.left,
                                                controller: _cNumber,
                                                validator: (value) {
                                                  if (value.trim().length ==
                                                      0) {
                                                    return "Please Enter Mobile Number";
                                                  }
                                                  if (value.trim().length > 10 ||
                                                      value.trim().length <
                                                          10 ||
                                                      value.trim().contains(
                                                          new RegExp(
                                                              r'[A-Za-z/@_-]'))) {
                                                    return "Please Enter Valid Mobile Number";
                                                  }
                                                  // if (value.trim().length ==
                                                  //     10) {
                                                  //   FocusScope.of(context)
                                                  //       .requestFocus(
                                                  //           new FocusNode());
                                                  // }
                                                  return null;
                                                },
                                                onChanged: (value) {},
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter Mobile Number',
                                                  labelText: 'Mobile Number',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            //Business Nature
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: DropdownButtonFormField(
                                                value:
                                                    businessNatureDropDownValue,
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          new FocusNode());
                                                },
                                                onChanged: (String newValue) {
                                                  dev.log('$newValue');
                                                  businessNatureDropDownValue =
                                                      newValue;
                                                  setState(() {});
                                                },
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Select Nature of Business',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items:
                                                    _businessNatureDropDownMenuItems,
                                                // hint:
                                                //     const Text('Select Department'),
                                              ),
                                            ),
                                            //Department drop down
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: DropdownButtonFormField(
                                                value: departmentDropDownValue,
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          new FocusNode());
                                                },
                                                onChanged:
                                                    (String newValue) async {
                                                  departmentDropDownValue =
                                                      newValue;
                                                  if (!stateSelected) {
                                                    states =
                                                        await getStateList();
                                                    _stateDropDownMenuItems =
                                                        states
                                                            .map(
                                                              (state) =>
                                                                  DropdownMenuItem<
                                                                      String>(
                                                                value: state[
                                                                        "id"]
                                                                    .toString(),
                                                                child: Text(
                                                                  state["statename"]
                                                                      .toString(),
                                                                ),
                                                              ),
                                                            )
                                                            .toList();
                                                  }

                                                  departmentSelected = true;
                                                  setState(() {});
                                                },
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Select Department',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items:
                                                    _departmentDropDownMenuItems,
                                                // hint:
                                                //     const Text('Select Department'),
                                              ),
                                            ),
                                            //State drop down
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: DropdownButtonFormField(
                                                // disabledHint: Text(
                                                //   'Please Select Department First',
                                                // ),
                                                // onTap: () {
                                                //   stateSelected = false;
                                                //   cityDropDownValue = null;
                                                //   setState(() {});
                                                // },
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          new FocusNode());
                                                },
                                                value: stateDropDownValue,
                                                onChanged:
                                                    (String newValue) async {
                                                  stateDropDownValue = newValue;

                                                  if (cityDropDownValue !=
                                                          null &&
                                                      cityDropDownValue
                                                          .isNotEmpty) {
                                                    cityDropDownValue = null;
                                                  }
                                                  List<dynamic> cities =
                                                      await getCityList(
                                                          stateDropDownValue);
                                                  _cityDropDownMenuItems =
                                                      cities
                                                          .map(
                                                            (city) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                              value: city[
                                                                      "cityname"]
                                                                  .toString(),
                                                              child: Text(
                                                                city["cityname"]
                                                                    .toString(),
                                                              ),
                                                            ),
                                                          )
                                                          .toList();
                                                  stateSelected = true;
                                                  setState(() {});
                                                },
                                                items: _stateDropDownMenuItems,

                                                decoration: InputDecoration(
                                                  errorText: !departmentSelected
                                                      ? 'Please Select Department First'
                                                      : null,
                                                  labelText: 'Select State',
                                                  border: OutlineInputBorder(),
                                                ),
                                                // hint: const Text('Select State'),
                                              ),
                                            ),
                                            //District
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                textAlign: TextAlign.left,
                                                controller: _cDistrict,
                                                validator: (value) {
                                                  if (value.trim().isEmpty) {
                                                    return 'Please Enter District';
                                                  }

                                                  return null;
                                                },
                                                onChanged: (value) {},
                                                decoration: InputDecoration(
                                                  // errorText: null,
                                                  hintText: 'Enter District',
                                                  labelText: 'District',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),

                                            //city drop down
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: DropdownButtonFormField(
                                                // disabledHint: const Text(
                                                //     'Please Select State First'),
                                                value: cityDropDownValue,
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          new FocusNode());
                                                },
                                                onChanged: (String newValue) {
                                                  setState(
                                                    () {
                                                      cityDropDownValue =
                                                          newValue;
                                                    },
                                                  );
                                                },
                                                items: _cityDropDownMenuItems,
                                                // hint: const Text(
                                                //   'Select City',
                                                // ),
                                                decoration: InputDecoration(
                                                  errorText: !stateSelected
                                                      ? 'Please Select State First'
                                                      : null,
                                                  labelText: 'Select City',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            //Submit Button
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (_formState.currentState
                                                    .validate()) {
                                                  var addOrgResult =
                                                      await createOrgAccount();
                                                  dev.log(
                                                      addOrgResult.toString());
                                                  Future.delayed(
                                                      Duration(
                                                        seconds: 2,
                                                      ), () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      SignUp.id,
                                                    );
                                                  });
                                                } else {
                                                  Toast.show(
                                                    "Some details are missing",
                                                    context,
                                                    duration: Toast.LENGTH_LONG,
                                                    gravity: Toast.BOTTOM,
                                                    textColor: Colors.redAccent,
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                  Colors.blue[700],
                                                ),
                                                padding: MaterialStateProperty
                                                    .all<EdgeInsetsGeometry>(
                                                  EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                  ),
                                                ),
                                              ),
                                              child: Center(
                                                heightFactor: 2.0,
                                                child: Text(
                                                  'Submit',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Card(
                        child: Center(
                          child: Text(
                            snapshot.error.toString(),
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: Container(
                          width: double.maxFinite,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            enabled: true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 10,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                              5.0,
                                            ),
                                          ),
                                          color: Colors.white,
                                        ),
                                        width: 250,
                                        height: 40,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 30.0,
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(
                                              10,
                                              (index) => Container(
                                                margin: EdgeInsets.only(
                                                  right: 16.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                      5.0,
                                                    ),
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                width: 75,
                                                height: 35,
                                              ),
                                            ).toList(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 18.0,
                                      ),
                                      Column(
                                        children: List.generate(10, (index) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  5.0,
                                                ),
                                              ),
                                              color: Colors.white,
                                            ),
                                            width: double.maxFinite,
                                            height: 30,
                                          );
                                        }).toList(),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }),
            ),
            // Text(
            //   '$textHolder',
            //   style: TextStyle(fontSize: 20),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stateDropDownValue = null;
    cityDropDownValue = null;
    _cAddress.dispose();
    _cName.dispose();
    _cOrgName.dispose();
    _cNumber.dispose();
    _formState.currentState.dispose();
    _cDistrict.dispose();
    super.dispose();
  }
}
