import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hajeri_demo/Pages/maintain_branch.dart';
import 'package:hajeri_demo/components/blue_button.dart';
import 'package:hajeri_demo/constant.dart';
import 'package:hajeri_demo/main.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:hajeri_demo/url.dart';
import 'package:toast/toast.dart';

class BranchForm extends StatefulWidget {
  final Map branch;
  final action;
  final title;
  BranchForm({
    Key key,
    this.branch,
    this.action,
    this.title,
  }) : super(key: key);

  @override
  _BranchFormState createState() => _BranchFormState();
}

class _BranchFormState extends State<BranchForm> {
  GlobalKey<FormState> _formState;

  TextEditingController _cOrgName,
      _cName,
      _cBusiness,
      _cNumber,
      _cAddress,
      _cId,
      _cDepartment;
  String stateDropDownValue, cityDropDownValue, departmentDropDownValue;
  List<DropdownMenuItem<String>> _cityDropDownMenuItems,
      _departmentDropDownMenuItems,
      _stateDropDownMenuItems;
  bool stateSelected = false;
  List<dynamic> states;
  List<dynamic> cities;

  @override
  void initState() {
    super.initState();

    _formState = GlobalKey<FormState>();

    Map branch = widget.branch;
    _cName = TextEditingController(
        text: branch.isEmpty ? '' : branch["personaname"]);
    _cOrgName = TextEditingController(
        text: branch.isEmpty ? '' : branch["nameoforganization"]);

    _cBusiness = TextEditingController(
        text: branch.isEmpty ? '' : branch["natureofbusiness"]);
    _cNumber = TextEditingController(
      text: branch.isEmpty ? '' : branch["mobile"],
    );
    _cAddress =
        TextEditingController(text: branch.isEmpty ? '' : branch["address"]);
    _cId = TextEditingController(
      text: branch.isEmpty ? '' : branch["id"].toString(),
    );
    // _cDepartment = TextEditingController(
    //   text:  branch.isEmpty ? '': branch[""],
    // );
    _departmentDropDownMenuItems = kDepartmentMenuItems
        .map(
          (department) => DropdownMenuItem<String>(
            value: department,
            child: Text(
              department,
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
    print('In get states');
    dev.log(kStates);
    http.Response response = await http.get(kStates);

    if (response.statusCode == 200) {
      data = json.decode(response.body);
      dev.log(data.toString(), name: 'In get city');
    } else {
      data = [
        {"id": -1, "statename": "error couldn't fetch states details"},
      ];
      dev.log(data.toString(), name: 'In get city', error: response.headers);
    }

    return data;
  }

  Future<List<dynamic>> getCityList(String stateId) async {
    List<dynamic> data = [
      {'': ''}
    ];
    dev.log('$kCity/$stateId', name: 'In get city');
    http.Response response = await http.get('$kCity/$stateId');

    if (response.statusCode == 200) {
      data = json.decode(response.body);
      dev.log(data.toString(), name: 'In get city');
    } else {
      data = [
        {"id": -1, "cityname": "error couldn't fetch states details"},
      ];
      dev.log(data.toString(), name: 'In get city', error: response.headers);
    }

    return data;
  }

  Future<void> setStateAndCity() async {
    states = await getStateList();
    // dev.debugger();
    var currentState = widget.branch.isEmpty ? '' : widget.branch["state"];

    if (currentState.isEmpty) {
      stateDropDownValue = null;
      _stateDropDownMenuItems = states.map((state) {
        // log(state[
        //         "statename"]
        //     .toString());

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
      dev.log(currentState, name: 'In set State and City');
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
      var currentCity = widget.branch["city"];
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
          cityDropDownValue = city["id"].toString();
          // dev.log(cityDropDownValue
          //     .toString());
        }
        return DropdownMenuItem<String>(
          value: city["id"].toString(),
          child: Text(
            city["cityname"],
          ),
        );
      }).toList();

      dev.log(cityDropDownValue);
      dev.log(stateDropDownValue);
      stateSelected = true;
    }

    setState(() {});
    // dev.debugger();
  }

  Future<String> addSubBranch() async {
    String orgId = prefs.getString("worker_id");
    var currentState;
    states.forEach((state) {
      if (state['id']
          .toString()
          .trim()
          .toLowerCase()
          .contains(stateDropDownValue.toString().trim().toLowerCase())) {
        states.forEach((state) {
          if (state['id']
              .toString()
              .trim()
              .toLowerCase()
              .contains(stateDropDownValue.toString().trim().toLowerCase())) {
            currentState = state["statename"];
          }
        });
      }
    });
    var currentCity;
    cities.forEach((city) {
      if (city['id']
          .toString()
          .trim()
          .toLowerCase()
          .contains(cityDropDownValue.toString().trim().toLowerCase())) {
        currentCity = city["cityname"];
      }
    });
    dev.log(
        '$kAddBranch$orgId?nameoforganization=${_cOrgName.text}&personaname=${_cName.text}&natureofbusiness=${_cBusiness.text}&contactpersondepartmentname=$departmentDropDownValue&address=${_cAddress.text}&mobile=${_cNumber.text}&state=$currentState&district=$currentCity&city=$currentCity');
    var response = await http.post(
      '$kAddBranch$orgId?nameoforganization=${_cOrgName.text}&personaname=${_cName.text}&natureofbusiness=${_cBusiness.text}&contactpersondepartmentname=$departmentDropDownValue&address=${_cAddress.text}&mobile=${_cNumber.text}&state=$currentState&district=$currentCity&city=$currentCity',
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      dev.log(data.toString(), name: 'In add Branch success response');

      Toast.show("Your Branch is added sucessfully", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.blue);
      return "success";
      // cler_fields();
    } else {
      Toast.show("Your Branch is not added", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.red);
      return "failure";
    }
  }

  Future<String> updateBranch() async {
    String orgId = prefs.getString("worker_id");
    var currentState;
    states.forEach((state) {
      if (state['id']
          .toString()
          .trim()
          .toLowerCase()
          .contains(stateDropDownValue.toString().trim().toLowerCase())) {
        states.forEach((state) {
          if (state['id']
              .toString()
              .trim()
              .toLowerCase()
              .contains(stateDropDownValue.toString().trim().toLowerCase())) {
            currentState = state["statename"];
          }
        });
      }
    });
    var currentCity;
    cities.forEach((city) {
      if (city['id']
          .toString()
          .trim()
          .toLowerCase()
          .contains(cityDropDownValue.toString().trim().toLowerCase())) {
        currentCity = city["cityname"];
      }
    });

    var response = await http.post(
      '$kUpdateBranch$orgId/${_cId.text}?nameoforganization=${_cOrgName.text}&personaname=${_cName.text}&natureofbusiness=${_cBusiness.text}&contactpersondepartmentname=$departmentDropDownValue&address=${_cAddress.text}&mobile=${_cNumber.text}&state=$currentState&district=$currentCity&city=$currentCity',
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      dev.log(data.toString(), name: 'In update Branch success response');

      Toast.show("Your Branch is updated sucessfully", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.blue);
      return "success";
      // cler_fields();
    } else {
      Toast.show("Your Branch is not updated", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
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
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formState,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
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
                              if (value.trim().contains(new RegExp(r'[.@_-]'))) {
                                return 'Please Enter Valid Name';
                              }
                              return null;
                            },
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              // errorText: null,
                              hintText: 'Enter Contact',
                              labelText: 'Person Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                        //Organization Name
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.left,
                            controller: _cOrgName,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Please Enter Your Name';
                              }
                              if (value.trim().contains(new RegExp(r'[.@_-]'))) {
                                return 'Please Enter Valid Name';
                              }
                              return null;
                            },
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              // errorText: null,
                              hintText: 'Enter Org Name',
                              labelText: 'Organization Name',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              stateDropDownValue = newValue;

                              if (cityDropDownValue != null &&
                                  cityDropDownValue.isNotEmpty) {
                                cityDropDownValue = null;
                              }

                              cities = await getCityList(stateDropDownValue);
                              _cityDropDownMenuItems = cities
                                  .map(
                                    (city) => DropdownMenuItem<String>(
                                      value: city["id"].toString(),
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
                              errorText: !stateSelected
                                  ? 'Please Select State First'
                                  : null,
                              labelText: 'Select City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        //Submit Button User
                        BlueButton(
                          onPressed: () async {
                            if (_formState.currentState.validate()) {
                              if (widget.action.contains('add')) {
                                var isBranchAddedSuccess = await addSubBranch();
                                Navigator.pushNamed(context, MaintainBranch.id);
                              } else {
                                var isBranchEditSuccess = await updateBranch();
                                Navigator.pushNamed(context, MaintainBranch.id);
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
                          label: 'Submit',
                        ),
                      ],
                    ),
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
