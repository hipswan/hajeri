import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constant.dart';
import '../model/Employee.dart';
import '../url.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'blue_button.dart';

class FormPage extends StatefulWidget {
  final String action;
  final String title;
  final Employee currentEmployee;
  final String orgId;
  FormPage({Key key, this.currentEmployee, this.action, this.title, this.orgId})
      : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  GlobalKey<FormState> _formState;

  TextEditingController _cName, _cNumber, _cAddress, _cIdentity, _cDistrict;
  String stateDropDownValue, cityDropDownValue, departmentDropDownValue;
  List<DropdownMenuItem<String>> _cityDropDownMenuItems,
      _departmentDropDownMenuItems,
      _stateDropDownMenuItems;
  bool stateSelected = false;
  bool departmentSelected = false;
  bool showDialogBoxLoader = true;
  List<dynamic> states;
  List<dynamic> cities;
  String orgId;
  @override
  void initState() {
    super.initState();
    orgId = widget.orgId;
    _formState = GlobalKey<FormState>();
    var employee = widget.currentEmployee;
    _cName = TextEditingController(text: employee.name);
    departmentDropDownValue =
        employee.departmentName.isEmpty ? null : employee.departmentName;
    _cNumber = TextEditingController(
      text: (employee.number == 0) ? '' : employee.number.toString(),
    );
    _cAddress = TextEditingController(text: employee.addressLine1);
    _cIdentity = TextEditingController(
      text:
          (employee.idCardNumber == 0) ? '' : employee.idCardNumber.toString(),
    );
    _cDistrict = TextEditingController(text: employee.district);
    _departmentDropDownMenuItems = kDepartmentMenuItems
        .map(
          (department) => DropdownMenuItem<String>(
            value: department,
            child: Text(
              department,
              overflow: TextOverflow.clip,
            ),
          ),
        )
        .toList();
    setStateAndCity();
  }

  Future<List<dynamic>> getStateList() async {
    List<dynamic> data = [
      {'': ''}
    ];
    // print('In get states');
    // dev.log(kStates);
    http.Response response = await http.get(Uri.parse(kStates));

    if (response.statusCode == 200) {
      data = json.decode(response.body);
      // dev.log(data.toString(), name: 'In get city');
    } else {
      data = [
        {"id": -1, "statename": "error couldn't fetch states details"},
      ];
      // dev.log(data.toString(), name: 'In get city', error: response.headers);
    }

    return data;
  }

  Future<List<dynamic>> getCityList(String stateId) async {
    List<dynamic> data = [
      {'': ''}
    ];
    // dev.log('$kCity/$stateId', name: 'In get city');
    http.Response response = await http.get(Uri.parse('$kCity/$stateId'));

    if (response.statusCode == 200) {
      data = json.decode(response.body);
      // dev.log(data.toString(), name: 'In get city');
    } else {
      data = [
        {"id": -1, "cityname": "error couldn't fetch states details"},
      ];
      // dev.log(data.toString(), name: 'In get city', error: response.headers);
    }

    return data;
  }

  Future<void> setStateAndCity() async {
    states = await getStateList();
    // dev.debugger();
    var employee = widget.currentEmployee;
    var currentState = employee.state;
    if (currentState.isEmpty) {
      stateDropDownValue = null;
      _stateDropDownMenuItems = states.map((state) {
        // log(state[
        //         "statename"]
        //     .toString());
        if (currentState.isNotEmpty &&
            currentState.trim().toLowerCase().compareTo(
                    state["statename"].toString().trim().toLowerCase()) ==
                0) {
          stateDropDownValue = state['id'].toString();
          // log(stateDropDownValue);
        }
        return DropdownMenuItem<String>(
          value: state["id"].toString(),
          child: Text(
            state["statename"],
          ),
        );
      }).toList();

      cityDropDownValue = null;
      stateSelected = false;
    } else {
      // dev.log(currentState, name: 'In set State and City');
      _stateDropDownMenuItems = states.map((state) {
        // log(state[
        //         "statename"]
        //     .toString());
        if (currentState.isNotEmpty &&
            currentState.trim().toLowerCase().compareTo(
                    state["statename"].toString().trim().toLowerCase()) ==
                0) {
          stateDropDownValue = state['id'].toString();
          // log(stateDropDownValue);
        }
        return DropdownMenuItem<String>(
          value: state["id"].toString(),
          child: Text(
            state["statename"],
          ),
        );
      }).toList();

      cities = await getCityList(stateDropDownValue);
      var currentCity = employee.city;
      // dev.log(currentCity);
      _cityDropDownMenuItems = cities.map((city) {
        // dev.log(city[
        //         "cityname"]
        //     .toString());
        if (currentCity
                .trim()
                .toLowerCase()
                .compareTo(city["cityname"].toString().trim().toLowerCase()) ==
            0) {
          cityDropDownValue = city["cityname"].toString();
          // dev.log(cityDropDownValue
          //     .toString());
        }
        return DropdownMenuItem<String>(
          value: city["cityname"].toString(),
          child: Text(
            city["cityname"],
          ),
        );
      }).toList();

      dev.log(cityDropDownValue);
      dev.log(stateDropDownValue);
      stateSelected = true;
    }

    showDialogBoxLoader = false;
    setState(() {});
    // dev.debugger();
  }

  Future<String> editEmployee(String state, String city) async {
    var body = json.encode({
      "nameofworker": _cName.text,
      "departmentname": departmentDropDownValue,
      "addressline1": _cAddress.text,
      "state": state,
      "district": _cDistrict.text,
      "city": city,
    });

    // String orgId = prefs.getString("worker_id");
    dev.log(
      '$kUpdateEmp${_cNumber.text} $body',
      name: 'In update employee',
    );
    try {
      var response = await http
          .post(Uri.parse('$kUpdateEmp${_cNumber.text}'), body: body, headers: {
        'Content-Type': 'application/json',
      });

      print("reponse and status code ${response.body} ${response.statusCode}");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("the reponse data is " + response.body.toString());
        Toast.show(
          data['message'] ?? 'done',
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          textColor: Colors.green,
        );
        return "success";
        // cler_fields();
      } else {
        Toast.show(
          "error occurred while updating employee",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          textColor: Colors.red,
        );
        return "failure";
      }
    } on IOException catch (e) {
      Toast.show(
        "no internet",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
        textColor: Colors.red,
      );
      return "failure";
    } catch (e) {
      Toast.show(
        "error occurred",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
        textColor: Colors.red,
      );
      return "failure";
    }
  }

  Future<String> addEmployee(String state, String city) async {
    var body = json.encode({
      "idcardno": _cIdentity.text.trim(),
      "nameofworker": _cName.text.trim(),
      "departmentname": departmentDropDownValue,
      "addressline1": _cAddress.text.trim(),
      "mobileno": _cNumber.text.trim(),
      "state": state,
      "district": _cDistrict.text.trim(),
      "city": city
    });

    // String orgId = prefs.getString("worker_id");
    dev.log('$kAddEmp$orgId  $body', name: 'In add employee');
    try {
      var response =
          await http.post(Uri.parse('$kAddEmp$orgId'), body: body, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        dev.log(data.toString(), name: 'In add Employee success response');
        Toast.show(data['message'].toString(), context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.green);
        return "success";
        // cler_fields();
      } else {
        Toast.show("your employee is not added", context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.red);
        return "failure";
      }
    } on IOException catch (e) {
      Toast.show("no internet", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          textColor: Colors.red);
      return "failure";
    } catch (e) {
      Toast.show("error occurred", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
          textColor: Colors.red);
      return "failure";
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: showDialogBoxLoader
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formState,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //Id
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.left,
                                controller: _cIdentity,
                                validator: (value) {
                                  if (value.trim().isEmpty) {
                                    return 'Please Enter ID Number';
                                  }
                                  if (value
                                      .trim()
                                      .contains(new RegExp(r'[.@_-]'))) {
                                    return 'Please Enter valid id card number'
                                        .toLowerCase();
                                  }
                                  return null;
                                },
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                  // errorText: null,
                                  hintText: 'enter id card number',
                                  labelText: 'ID Card',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Person Name
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.left,
                                controller: _cName,
                                validator: (value) {
                                  if (value.trim().isEmpty) {
                                    return 'Please Enter Your Name';
                                  }
                                  if (value
                                      .trim()
                                      .contains(new RegExp(r'[.@_-]'))) {
                                    return 'Please Enter Valid Name';
                                  }
                                  return null;
                                },
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                  // errorText: null,
                                  hintText: 'Enter Name',
                                  labelText: 'Contact Person Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Address
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.left,
                                controller: _cAddress,
                                // validator: (value) {
                                //   if (value.trim().isEmpty) {
                                //     return 'Please Enter Your Address';
                                //   }

                                //   return null;
                                // },
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                  // errorText: null,
                                  hintText: 'Enter Address',
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Department drop down
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                width: size.width - 32,
                                child: DropdownButtonFormField(
                                  isExpanded: true,
                                  value: departmentDropDownValue,
                                  onTap: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  onChanged: (String newValue) async {
                                    departmentDropDownValue = newValue;

                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Select Department',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _departmentDropDownMenuItems,
                                  // hint:
                                  //     const Text('Select Department'),
                                ),
                              ),
                            ),
                            //Mobile Number
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                enabled: widget.action.contains('edit')
                                    ? false
                                    : true,
                                maxLength: 10,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: false,
                                  signed: false,
                                ),
                                textAlign: TextAlign.left,
                                controller: _cNumber,
                                validator: (value) {
                                  if (value.trim().isEmpty) {
                                    return 'Please Enter Your Mobile Number';
                                  }
                                  if (value.trim().length > 10 ||
                                      value
                                          .trim()
                                          .contains(new RegExp(r'[A-Za-z]'))) {
                                    return 'Please Enter Valid Number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                  // errorText: null,
                                  hintText: 'Enter Contact Detail',
                                  labelText: 'Mobile Number',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //state drop down
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: DropdownButtonFormField(
                                value: stateDropDownValue,
                                onChanged: (String newValue) async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  stateDropDownValue = newValue;

                                  if (cityDropDownValue != null &&
                                      cityDropDownValue.isNotEmpty) {
                                    cityDropDownValue = null;
                                  }
                                  cities =
                                      await getCityList(stateDropDownValue);
                                  _cityDropDownMenuItems = cities
                                      .map(
                                        (city) => DropdownMenuItem<String>(
                                          value: city["cityname"].toString(),
                                          child: Text(
                                            city["cityname"],
                                          ),
                                        ),
                                      )
                                      .toList();
                                  stateSelected = true;
                                  setState(() {});
                                },
                                items: _stateDropDownMenuItems,

                                decoration: InputDecoration(
                                  labelText: 'Select State',
                                  border: OutlineInputBorder(),
                                ),
                                // hint: const Text('Select State'),
                              ),
                            ),
                            //District
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.left,
                                controller: _cDistrict,
                                validator: (value) {
                                  // if (value.trim().isEmpty) {
                                  //   return 'Please Enter District';
                                  // }

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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: DropdownButtonFormField(
                                // disabledHint: const Text(
                                //     'Please Select State First'),
                                value: cityDropDownValue,
                                onChanged: (String newValue) {
                                  setState(
                                    () {
                                      cityDropDownValue = newValue;
                                    },
                                  );
                                },
                                items: _cityDropDownMenuItems,
                                // hint: const Text(
                                //   'Select City',
                                // ),
                                decoration: InputDecoration(
                                  // errorText: !stateSelected
                                  //     ? 'Please Select State First'
                                  //     : null,
                                  labelText: 'Select City',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            //Submit Button
                            ElevatedButton(
                              onPressed: () async {
                                if (_formState.currentState.validate()) {
                                  Map<String, String> cityAndStateNewValue =
                                      <String, String>{
                                    "city": "",
                                    "state": "",
                                  };

                                  cityAndStateNewValue['city'] =
                                      cityDropDownValue;

                                  states.forEach((state) {
                                    if (stateDropDownValue != null &&
                                        int.parse(state['id']
                                                .toString()
                                                .trim()) ==
                                            int.parse(stateDropDownValue
                                                .toString()
                                                .trim())) {
                                      cityAndStateNewValue['state'] =
                                          state["statename"];
                                    }
                                  });

                                  if (widget.action
                                      .toLowerCase()
                                      .contains('add')) {
                                    var isEmployeeAddedSuccess =
                                        await addEmployee(
                                            cityAndStateNewValue['state'],
                                            cityAndStateNewValue['city']);
                                    // dev.debugger();
                                    Navigator.of(context).pop(
                                      isEmployeeAddedSuccess.contains("success")
                                          ? Employee(
                                              addressLine1:
                                                  _cAddress.text.trim(),
                                              idCardNumber: int.parse(
                                                  _cIdentity.text.trim()),
                                              departmentName:
                                                  departmentDropDownValue,
                                              number: int.parse(
                                                  _cNumber.text.trim()),
                                              name: _cName.text.trim(),
                                              state:
                                                  cityAndStateNewValue['state'],
                                              district: _cDistrict.text.trim(),
                                              city:
                                                  cityAndStateNewValue['city'])
                                          : Employee.empty(),
                                    );
                                  } else {
                                    var isEmployeeEditSuccess =
                                        await editEmployee(
                                      cityAndStateNewValue['state'],
                                      cityAndStateNewValue['city'],
                                    );
                                    Navigator.of(context).pop(
                                        isEmployeeEditSuccess.contains(
                                                "success")
                                            ? Employee(
                                                addressLine1: _cAddress.text
                                                    .trim(),
                                                idCardNumber: int.parse(
                                                    _cIdentity.text.trim()),
                                                departmentName:
                                                    departmentDropDownValue,
                                                number: int.parse(
                                                    _cNumber.text.trim()),
                                                name: _cName.text.trim(),
                                                state: cityAndStateNewValue[
                                                    'state'],
                                                district:
                                                    _cDistrict.text.trim(),
                                                city: cityAndStateNewValue[
                                                    'city'])
                                            : Employee.empty());
                                  }
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
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.blue[700],
                                ),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
