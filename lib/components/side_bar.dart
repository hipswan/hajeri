import 'dart:io';
import 'dart:developer' as dev;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hajeri_demo/Pages/about_us.dart';
import 'package:hajeri_demo/Pages/contact_us.dart';
import 'package:hajeri_demo/Pages/dashboard.dart';
import 'package:hajeri_demo/Pages/faq.dart';
import 'package:hajeri_demo/Pages/generate_qr.dart';
import 'package:hajeri_demo/Pages/landing.dart';
import 'package:hajeri_demo/Pages/maintain_branch.dart';
import 'package:hajeri_demo/Pages/maintain_qr.dart';
import 'package:hajeri_demo/Pages/privacy_policy.dart';
import 'package:hajeri_demo/Pages/scanner.dart';
import 'package:hajeri_demo/Pages/terms_and_conditions.dart';
import 'package:hajeri_demo/Pages/employee_detail.dart';
import 'package:hajeri_demo/Pages/monthly_attendance.dart';

import '../main.dart';

class SideBar extends StatefulWidget {
  final String section;

  SideBar({this.section});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isOrg;
  FilePickerResult result;
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
      accountName: Text(
          isOrg ? prefs.getString('org_name') : prefs.getString('emp_name')),
      accountEmail: Text(
        orgId ?? '-',
      ),
      currentAccountPicture: GestureDetector(
        onTap: () async {
          result = await FilePicker.platform.pickFiles(
            type: FileType.image,
          );
          if (result != null) {
            imageFile = File(result.files.single.path);

            prefs.setString('avatar', imageFile.readAsStringSync());

            setState(() {
              imageArrived = true;
            });
            dev.log(result.toString(), name: 'In the sidebar file');
          } else {
            dev.log(result.toString(), name: 'In the sidebar file not found');
          }
        },
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          child: !imageArrived
              ? Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 42,
                )
              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: prefs.containsKey('avatar')
                          ? FileImage(
                              imageFile,
                            )
                          : NetworkImage(
                              prefs.getString('avatar'),
                            ),
                    ),
                  ),
                ),

          // FlutterLogo(
          //   size: 42.0,
          // ),
        ),
      ),
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
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Landing(
                              initialPageIndex: 0,
                            ),
                          ),
                        );
                },
              ),
              ListTile(
                selected: section.contains('maintain_qr') ? true : false,
                leading: Icon(
                  Icons.qr_code_rounded,
                ),
                title: const Text('Maintain Qr Code'),
                onTap: () {
                  section.contains('maintain_qr')
                      ? Navigator.pop(context)
                      : Navigator.pushNamed(
                          context,
                          MaintainQr.id,
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
                            return EmployeeDetail(
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
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Landing(
                              initialPageIndex: 1,
                            ),
                          ),
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
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Landing(
                              initialPageIndex: 2,
                            ),
                          ),
                        );
                },
              ),
              ListTile(
                selected: section.contains('maintain_branch') ? true : false,
                leading: Icon(
                  Icons.people_outline,
                ),
                title: const Text('Maintain Branch'),
                onTap: () {
                  section.contains('maintain_branch')
                      ? Navigator.pop(context)
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MaintainBranch(),
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
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Landing(
                            initialPageIndex: 0,
                          ),
                        ),
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
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Landing(
                            initialPageIndex: 1,
                          ),
                        ),
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
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Landing(
                            initialPageIndex: 2,
                          ),
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
