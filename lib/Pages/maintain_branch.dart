import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  String branchStatus = "no result";
  List branchList = [];

  @override
  void initState() {
    super.initState();
    getOrgBranch().then((value) {
      if (value.contains("success")) {
        branchList.isEmpty ? branchStatus = 'absent' : branchStatus = 'present';
      } else {
        branchStatus = value;
      }
      setState(() {});
    });
  }

  Future<String> getOrgBranch() async {
    String orgId = prefs.getString("worker_id");
    // log('$kBranchList$orgId');
    try {
      var response = await http.get(
        Uri.parse(
          '$kBranchList$orgId',
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        branchList = data;
        // log(
        //   branchList.toString(),
        //   name: 'In branch list',
        // );

        return "success";
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } on Exception catch (e) {
      return 'error';
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
          heroTag: 'mainBranch',
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
    switch (branchStatus) {
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
        return BranchForm(
          branch: {},
          title: 'Add Sub Branch',
          action: 'add',
        );
        break;
      case "error":
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
                'Error has occured',
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
}
