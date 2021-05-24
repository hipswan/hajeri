import 'package:flutter/material.dart';
import '../Pages/about_us.dart';
import '../Pages/contact_us.dart';
import '../Pages/privacy_policy.dart';
import '../Pages/terms_and_conditions.dart';
import '../components/side_bar.dart';
import '../main.dart';

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
                      Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          shape: BoxShape.circle,
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
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${prefs.getString('emp_name').substring(0, 1).toUpperCase()}${prefs.getString('emp_name').substring(1).toLowerCase()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              prefs.getString('mobile'),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
