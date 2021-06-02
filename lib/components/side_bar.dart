import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Pages/about_us.dart';
import '../Pages/contact_us.dart';
import '../Pages/dashboard.dart';
import '../Pages/faq.dart';
import '../Pages/generate_qr.dart';
import '../Pages/landing.dart';
import '../Pages/maintain_branch.dart';
import '../Pages/maintain_qr.dart';
import '../Pages/privacy_policy.dart';
import '../Pages/scanner.dart';
import '../Pages/terms_and_conditions.dart';
import '../Pages/employee_details.dart';
import '../Pages/monthly_attendance.dart';

import '../main.dart';

class SideBar extends StatefulWidget {
  final String section;

  SideBar({this.section});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isOrg;
  // ignore: avoid_init_to_null
  File imageFile;
  var orgId = prefs.getString('worker_id');
  bool imageArrived = false;

  @override
  void initState() {
    super.initState();
    isOrg = prefs.getBool('is_org');
  }

  @override
  Widget build(BuildContext context) {
    final Widget drawerHeader = UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue[800],
      ),
      accountName: Container(
        child: Text(
          isOrg
              ? '${prefs.getString('org_name').substring(0, 1).toUpperCase()}${prefs.getString('org_name').substring(1).toLowerCase()}'
              : '${prefs.getString('emp_name').substring(0, 1).toUpperCase()}${prefs.getString('emp_name').substring(1).toLowerCase()}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
        ),
      ),
      accountEmail: Text(
        prefs.getString('mobile') ?? '-',
      ),
      currentAccountPicture: Container(
        height: 75,
        width: 75,

        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage(
              'assets/images/hajeri_login.jpg',
            ),
          ),
        ),

        //  Icon(
        //   Icons.person_outline_rounded,
        //   color: Colors.white,
        //   size: 42,
        // ),
      ),
      // GestureDetector(
      //   onTap: () async {
      //     result = await FilePicker.platform.pickFiles(
      //       type: FileType.image,
      //     );
      //     if (result != null) {
      //       imageFile = File(result.files.single.path);

      //       prefs.setString('avatar', imageFile.readAsStringSync());

      //       setState(() {
      //         imageArrived = true;
      //       });
      //       dev.log(result.toString(), name: 'In the sidebar file');
      //     } else {
      //       dev.log(result.toString(), name: 'In the sidebar file not found');
      //     }
      //   },
      //   child: CircleAvatar(
      //     backgroundColor: Colors.grey,
      //     child: !imageArrived
      //         ? Icon(
      //             Icons.person_outline_rounded,
      //             color: Colors.white,
      //             size: 42,
      //           )
      //         : Container(
      //             decoration: BoxDecoration(
      //               shape: BoxShape.circle,
      //               image: DecorationImage(
      //                 fit: BoxFit.fill,
      //                 image: prefs.containsKey('avatar')
      //                     ? FileImage(
      //                         imageFile,
      //                       )
      //                     : NetworkImage(
      //                         prefs.getString('avatar'),
      //                       ),
      //               ),
      //             ),
      //           ),

      //     // FlutterLogo(
      //     //   size: 42.0,
      //     // ),
      //   ),
      // ),
      // otherAccountsPictures: [],
    );
    final String section = widget.section;

    return isOrg
        ? ListView(
            children: [
              drawerHeader,
              ListTile(
                selected: section.contains('dashboard') ? true : false,
                leading: Icon(
                  Icons.dashboard_outlined,
                ),
                title: const Text('Dashboard'),
                onTap: () {
                  section.contains('dashboard')
                      ? Navigator.pop(context)
                      : Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => Landing(
                              initialPageIndex: 0,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                          // ModalRoute.withName(SignUp.id),
                        );
                },
              ),
              ListTile(
                selected: section.contains('maintain_qr') ? true : false,
                leading: Icon(
                  Icons.qr_code_rounded,
                ),
                title: const Text('Generate QR Code'),
                onTap: () {
                  section.contains('maintain_qr')
                      ? Navigator.pop(context)
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowCaseQr(),
                          ),
                        );
                },
              ),
              ListTile(
                selected: section.contains('employee_details') ? true : false,
                leading: Icon(
                  Icons.people_alt_outlined,
                ),
                title: const Text('Employee  Details'),
                onTap: () {
                  section.contains('employee_details')
                      ? Navigator.pop(context)
                      : Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return EmployeeDetails(
                              orgId: prefs.getString(
                                'worker_id',
                              ),
                            );
                          }),
                        );
                },
              ),
              ListTile(
                selected: section.contains('scan_qr') ? true : false,
                leading: Icon(
                  Icons.qr_code_scanner_rounded,
                ),
                title: const Text('Scan QR'),
                onTap: () {
                  section.contains('scan_qr')
                      ? Navigator.pop(context)
                      : Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => Landing(
                              initialPageIndex: 1,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                          // ModalRoute.withName(SignUp.id),
                        );
                },
              ),
              ListTile(
                selected: section.contains('monthly_attendance') ? true : false,
                leading: Icon(
                  Icons.event_outlined,
                ),
                title: const Text('Monthly Attendance'),
                onTap: () {
                  section.contains('monthly_attendance')
                      ? Navigator.pop(context)
                      : Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => Landing(
                              initialPageIndex: 2,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                          // ModalRoute.withName(SignUp.id),
                        );
                },
              ),
              prefs.getBool('is_sub_org')
                  ? Container()
                  : ListTile(
                      selected:
                          section.contains('maintain_branch') ? true : false,
                      leading: Icon(
                        Icons.people_outline,
                      ),
                      title: const Text('Branch Management'),
                      onTap: () {
                        section.contains('maintain_branch')
                            ? Navigator.pop(context)
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowCaseBranch(),
                                ),
                              );
                      },
                    ),
              ListTile(
                selected: section.contains('about_us') ? true : false,
                leading: Icon(
                  Icons.person_pin_outlined,
                ),
                title: const Text(
                  'About Us',
                ),
                onTap: () {
                  section.contains('about_us')
                      ? Navigator.pop(context)
                      : Navigator.pushNamed(
                          context,
                          AboutUsPage.id,
                        );
                },
              ),
              ListTile(
                selected:
                    section.contains('terms_and_conditions') ? true : false,
                leading: Icon(
                  Icons.format_list_numbered_rounded,
                ),
                title: const Text(
                  'Terms & Conditions',
                ),
                onTap: () {
                  section.contains('terms_and_conditions')
                      ? Navigator.pop(context)
                      : Navigator.pushNamed(
                          context,
                          TermsAndConditions.id,
                        );
                },
              ),
              ListTile(
                selected: section.contains('privacy_policy') ? true : false,
                leading: Icon(
                  Icons.privacy_tip_outlined,
                ),
                title: const Text(
                  'Privacy Policy',
                ),
                onTap: () {
                  section.contains('privacy_policy')
                      ? Navigator.pop(context)
                      : Navigator.pushNamed(
                          context,
                          PrivacyPolicyPage.id,
                        );
                },
              ),
              ListTile(
                selected: section.contains('contact_us') ? true : false,
                leading: Icon(
                  Icons.contact_phone_outlined,
                ),
                title: const Text(
                  'Contact Us',
                ),
                onTap: () {
                  section.contains('contact_us')
                      ? Navigator.pop(context)
                      : Navigator.pushNamed(
                          context,
                          ContactUsPage.id,
                        );
                },
              ),
            ],
          )
        : ListView(children: [
            drawerHeader,
            ListTile(
              selected: section.contains('dashboard') ? true : false,
              leading: Icon(
                Icons.dashboard_outlined,
              ),
              title: const Text('Dashboard'),
              onTap: () {
                section.contains('dashboard')
                    ? Navigator.pop(context)
                    : Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Landing(
                            initialPageIndex: 0,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                        // ModalRoute.withName(SignUp.id),
                      );
              },
            ),
            ListTile(
              selected: section.contains('scan_qr') ? true : false,
              leading: Icon(
                Icons.qr_code_scanner_rounded,
              ),
              title: const Text('Scan QR'),
              onTap: () {
                section.contains('scan_qr')
                    ? Navigator.pop(context)
                    : Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Landing(
                            initialPageIndex: 1,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                        // ModalRoute.withName(SignUp.id),
                      );
              },
            ),
            ListTile(
              selected: section.contains('profile') ? true : false,
              leading: Icon(
                Icons.person_outline_rounded,
              ),
              title: const Text('Profile'),
              onTap: () {
                section.contains('profile')
                    ? Navigator.pop(context)
                    : Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Landing(
                            initialPageIndex: 2,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                        // ModalRoute.withName(SignUp.id),
                      );
              },
            ),
            ListTile(
              selected: section.contains('about_us') ? true : false,
              leading: Icon(
                Icons.person_pin_outlined,
              ),
              title: const Text(
                'About Us',
              ),
              onTap: () {
                section.contains('about_us')
                    ? Navigator.pop(context)
                    : Navigator.pushNamed(
                        context,
                        AboutUsPage.id,
                      );
              },
            ),
            ListTile(
              selected: section.contains('terms_and_conditions') ? true : false,
              leading: Icon(
                Icons.format_list_numbered_rounded,
              ),
              title: const Text(
                'Terms & Conditions',
              ),
              onTap: () {
                section.contains('terms_and_conditions')
                    ? Navigator.pop(context)
                    : Navigator.pushNamed(
                        context,
                        TermsAndConditions.id,
                      );
              },
            ),
            ListTile(
              selected: section.contains('privacy_policy') ? true : false,
              leading: Icon(
                Icons.privacy_tip_outlined,
              ),
              title: const Text(
                'Privacy Policy',
              ),
              onTap: () {
                section.contains('privacy_policy')
                    ? Navigator.pop(context)
                    : Navigator.pushNamed(
                        context,
                        PrivacyPolicyPage.id,
                      );
              },
            ),
            ListTile(
              selected: section.contains('contact_us') ? true : false,
              leading: Icon(
                Icons.contact_phone_outlined,
              ),
              title: const Text(
                'Contact Us',
              ),
              onTap: () {
                section.contains('contact_us')
                    ? Navigator.pop(context)
                    : Navigator.pushNamed(
                        context,
                        ContactUsPage.id,
                      );
              },
            ),
          ]);
  }
}
