import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajeri_demo/Pages/generate_qr.dart';
import 'package:hajeri_demo/Pages/display_qr.dart';
import 'package:hajeri_demo/Pages/multiple_branch.dart';
import 'package:hajeri_demo/Pages/qr_code_point.dart';
import 'package:hajeri_demo/components/branch_form.dart';
import 'package:hajeri_demo/components/side_bar.dart';
import 'package:hajeri_demo/main.dart';
import 'package:hajeri_demo/url.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';

class MaintainBranch extends StatefulWidget {
  static const id = 'maintain_branch';
  MaintainBranch({Key key}) : super(key: key);

  @override
  _MaintainBranchState createState() => _MaintainBranchState();
}

class _MaintainBranchState extends State<MaintainBranch> {
  String isBranchPresent = "no result";
  List branchList = [];

  @override
  void initState() {
    super.initState();
    getOrgBranch().then((value) {
      if (value.contains("success")) {
        isBranchPresent = 'present';
      } else if (value.contains('empty')) {
        isBranchPresent = 'absent';
      } else {
        isBranchPresent = 'error';
      }
      setState(() {});
    });
  }

  Future<String> getOrgBranch() async {
    String orgId = prefs.getString("worker_id");
    log('$kBranchList$orgId');
    var response = await http.get(
      '$kBranchList$orgId',
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        branchList = data;
      } else {
        return "empty";
      }
      log(data.toString());

      return "success";
    } else {
      return 'failure';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[700],
          onPressed: () {
            // debugger();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BranchForm(
                    branch: {},
                    title: 'Add Sub Branch',
                    action: 'add',
                  );
                },
              ),
            );
          },
          child: Icon(
            Icons.playlist_add,
          ),
        ),
        drawer: Drawer(
          child: SideBar(
            section: 'maintain_branch',
          ),
        ),
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            'Maintain Branch',
          ),
          centerTitle: true,
        ),
        body: Container(color: Colors.white, child: getBranchView()),
      ),
    );
  }

  getBranchView() {
    switch (isBranchPresent) {
      case "no result":
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case "present":
        return MultipleBranchView(
          branchList: branchList,
        );
        break;
      case "absent":
        return Center(
          child: Text(
            "No Branch Added",
          ),
        );
        break;
      case "error":
        return Container(
          child: Text(
            "Network issue",
          ),
        );
        break;
    }
  }
}
