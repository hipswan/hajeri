import 'dart:developer';

import 'package:flutter/material.dart';
import '../Pages/branch_landing.dart';
import '../Pages/display_qr.dart';
import '../Pages/maintain_branch.dart';
import '../components/branch_form.dart';
import '../constant.dart';
import '../main.dart';
import '../url.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

var mediaQuery;

class MultipleBranchView extends StatefulWidget {
  final List branchList;
  MultipleBranchView({Key key, this.branchList}) : super(key: key);

  @override
  _MultipleBranchViewState createState() => _MultipleBranchViewState();
}

class _MultipleBranchViewState extends State<MultipleBranchView> {
  Future<String> deleteBranch({String id}) async {
    String orgId = prefs.getString('worker_id');
    // log('$kDeleteBranch$orgId/$id');
    var response = await http.post(Uri.parse('$kDeleteBranch$orgId/$id'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data["success_message"].toString().trim().toLowerCase();
    } else {
      return "failure";
    }
  }

  @override
  Widget build(BuildContext context) {
    var branch = widget.branchList.first;
    log(branch.toString(), name: 'branch ');

    mediaQuery = MediaQuery.of(context);
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: mediaQuery.size.width * 0.08,
            left: mediaQuery.size.width * 0.1,
            right: mediaQuery.size.width * 0.1,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              maxRadius: 22.0,
                              child: Text(
                                prefs
                                    .getString('org_name')
                                    .toString()
                                    .substring(
                                      0,
                                      1,
                                    )
                                    .toUpperCase(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MainBranchDetail(
                                name: 'Name',
                                text: prefs.getString(
                                  'org_name',
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              MainBranchDetail(
                                name: 'Mobile',
                                text: prefs.getString(
                                  'mobile',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BranchForm(
                                        branch: branch,
                                        title: 'Edit Branch',
                                        action: 'edit',
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) {
                                    return AlertDialog(
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('back'),
                                        )
                                      ],
                                      title: Text('Delete Branch'),
                                      content: Text(
                                        'Cannot Delete Main Branch',
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.35,
            maxChildSize: 0.8,
            builder: (BuildContext context, scrollController) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                  8.0,
                  10.0,
                  8.0,
                  10.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      20.0,
                    ),
                    topRight: Radius.circular(
                      20.0,
                    ),
                  ),
                  color: Colors.grey[200],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: widget.branchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var branch = widget.branchList[index];

                          return Slidable(
                            actionPane: SlidableScrollActionPane(),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: SlideAction(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BranchForm(
                                            branch: branch,
                                            title: 'Edit Branch',
                                            action: 'edit',
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: kGradient,
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            secondaryActions: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: SlideAction(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onTap: () async {
                                    bool delete = await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return AlertDialog(
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: Text('Yes'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: Text('No'),
                                              )
                                            ],
                                            title: Text('Delete Branch'),
                                            content: Text(
                                              'Do you want to delete Branch ?',
                                            ),
                                          );
                                        });
                                    if (delete) {
                                      String result = await deleteBranch(
                                        id: branch['id'].toString(),
                                      );

                                      if (result != null) {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ShowCaseBranch()),
                                                      );
                                                    }, //8551913068
                                                    child: Text('back'),
                                                  )
                                                ],
                                                title: Text('Delete Branch'),
                                                content: Text(
                                                  result,
                                                ),
                                              );
                                            });
                                      }
                                    } else {
                                      //do nothing
                                    }
                                  },
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                  6.0,
                                  8.0,
                                  6.0,
                                  8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: kGradient,
                                  borderRadius: BorderRadius.circular(
                                    10.0,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BranchLanding(
                                            orgId: branch["id"].toString(),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blueGrey,
                                      foregroundColor: Colors.white,
                                      child: Center(
                                        child: Text(
                                          branch["nameoforganization"]
                                              .toString()
                                              .substring(
                                                0,
                                                1,
                                              )
                                              .toUpperCase(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    branch["nameoforganization"] ?? '',
                                    style: kBranchTextStyle,
                                  ),
                                  subtitle: Text(
                                    branch['userName'] ?? '',
                                    style: kBranchTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MainBranchDetail extends StatelessWidget {
  final name;
  final text;
  const MainBranchDetail({
    Key key,
    this.name,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: kMainBranchTextStyle,
          ),
          Divider(
            color: Colors.white,
          ),
          Text(
            text,
            style: kMainBranchTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
