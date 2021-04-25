import 'package:flutter/material.dart';
import 'package:hajeri_demo/Pages/about_us.dart';
import 'package:hajeri_demo/Pages/contact_us.dart';
import 'package:hajeri_demo/Pages/privacy_policy.dart';
import 'package:hajeri_demo/Pages/terms_and_conditions.dart';
import 'package:hajeri_demo/components/side_bar.dart';
import 'package:hajeri_demo/main.dart';

import '../constant.dart';

class Profile extends StatelessWidget {
  static const id = 'profile';

  const Profile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: SideBar(
          section: 'profile',
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
        ),
        backgroundColor: Colors.blue[800],
        elevation: 5,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: size.height * 0.27,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  25,
                ),
                bottomRight: Radius.circular(
                  25,
                ),
              ),
              gradient: kGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 5),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: kTextStyleAccount,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Image.asset(
                          'assets/images/hajeri_login.jpg',
                        ),
                        //  Icon(
                        //   Icons.person_outline_rounded,
                        //   color: Colors.white,
                        //   size: 42,
                        // ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            prefs.getString('emp_name'),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            prefs.getString('worker_id'),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person_pin_outlined,
                    ),
                    title: const Text(
                      'About Us',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AboutUsPage.id,
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.format_list_numbered_rounded,
                    ),
                    title: const Text(
                      'Terms & Conditions',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        TermsAndConditions.id,
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                    ),
                    title: const Text(
                      'Privacy Policy',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        PrivacyPolicyPage.id,
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.contact_phone_outlined,
                    ),
                    title: const Text(
                      'Contact Us',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ContactUsPage.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
