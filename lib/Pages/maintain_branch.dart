import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:showcaseview/showcaseview.dart';
import '../Pages/generate_qr.dart';
import '../Pages/display_qr.dart';
import '../Pages/multiple_branch.dart';
import '../Pages/qr_code_point.dart';
import '../components/branch_form.dart';
import '../components/side_bar.dart';
import '../main.dart';
import '../url.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';

class ShowCaseBranch extends StatelessWidget {
  const ShowCaseBranch({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onStart: (index, key) {
        dev.log('onStart: $index, $key');
      },
      onComplete: (index, key) {
        dev.log('onComplete: $index, $key');
        prefs.setBool('showcase_branch', false);
      },
      builder: Builder(builder: (context) => MaintainBranch()),
      autoPlay: false,
      autoPlayDelay: Duration(seconds: 3),
      autoPlayLockEnable: false,
    );
  }
}

class MaintainBranch extends StatefulWidget {
  static const id = 'maintain_branch';
  MaintainBranch({Key key}) : super(key: key);

  @override
  _MaintainBranchState createState() => _MaintainBranchState();
}

class _MaintainBranchState extends State<MaintainBranch> {
  String branchStatus = "no result";
  List branchList = [];
  GlobalKey _addBranchKey = GlobalKey();

  startShowCase() {
    dev.log('Inside showcase');
    if (prefs.getBool('showcase_branch') == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Future.delayed(Duration(milliseconds: 350), () {
          ShowCaseWidget.of(context).startShowCase([_addBranchKey]);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startShowCase();
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
        dev.log(
          branchList.toString(),
          name: 'In branch list',
        );

        return "success";
      } else {
        return 'server issue';
      }
    } on SocketException catch (e) {
      return 'no internet';
    } on Exception catch (e) {
      return 'error occurred';
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
        floatingActionButton: Showcase(
          key: _addBranchKey,
          description: 'Click on Add Button to create new Branch',
          contentPadding: EdgeInsets.all(8.0),
          showcaseBackgroundColor: Colors.blue,
          textColor: Colors.white,
          shapeBorder: CircleBorder(),
          child: FloatingActionButton(
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
                      title: 'Add Branch',
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
            'Branch Management',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white,
          child: getBranchView(),
        ),
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
                'No Sub Branch Exist Yet',
              ),
            ],
          ),
        );
        break;
      case "error occurred":
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
