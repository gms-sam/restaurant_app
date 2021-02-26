import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/user_repository.dart';
import 'oval-right-clipper.dart';
import 'package:restaurant_app/screens/screens.dart';

class CustomAppDrawer extends StatefulWidget {
  final User firebaseUser;
  final VoidCallback logout;
  final UserRepository userRepository;
  CustomAppDrawer({
    User user,
    @required this.logout,
    @required this.userRepository,
  }) : firebaseUser = user;

  @override
  _CustomAppDrawerState createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer> {
  User get user => widget.firebaseUser;
  User fuser;
  String email;
  String photoUrl;
  String displayName;
  String phoneNumber;
  @override
  void initState() {
    super.initState();
    User user = getUser();
    setState(() {
      email = user.email;
      displayName = user.displayName;
      phoneNumber = user.phoneNumber;
    });
  }

  User getUser() {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // final String image = "assets/logo.png";
    return ClipPath(
      clipper: OvalRightBorderClipper(),
      child: Container(
        padding: const EdgeInsets.only(left: 26.0, right: 40),
        decoration: BoxDecoration(
            color: Colors.white, boxShadow: [BoxShadow(color: Colors.black45)]),
        width: 300,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                      return widget.logout();
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 9,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.height / 18,
                      child: photoUrl == null
                          ? Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage("assets/bg.jpg"))),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(photoUrl))),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 30),
                displayName == null
                    ? CircularProgressIndicator()
                    : Text(
                        displayName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600),
                      ),
                email == null
                    ? CircularProgressIndicator()
                    : Text(
                        email,
                        style: TextStyle(color: Colors.black87, fontSize: 16.0),
                      ),
                phoneNumber == null
                    ? CircularProgressIndicator()
                    : Text(
                        phoneNumber,
                        style: TextStyle(color: Colors.black87, fontSize: 16.0),
                      ),
                SizedBox(height: 30.0),
                DrawerRow(
                  icon: Icons.home,
                  text: "Home",
                  widget: HomeScreen(),
                ),
                DrawerRow(
                    icon: Icons.shopping_cart,
                    text: "Cart",
                    widget: CartScreen(userRepo: widget.userRepository)),
                DrawerRow(
                  icon: Icons.favorite,
                  text: "Favorites",
                  widget: Favorite(),
                ),
                DrawerRow(
                  icon: Icons.fastfood,
                  text: "My Orders",
                  widget: MyOrders(),
                ),
                DrawerRow(
                  icon: Icons.email,
                  text: "Contact Us",
                  widget: ContactUsPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerRow extends StatelessWidget {
  final Color primary = Colors.white;
  final Color active = Colors.grey.shade800;
  final Color divider = Colors.grey.shade600;
  final IconData icon;
  final String text;
  final Widget widget;
  DrawerRow({this.icon, this.text, this.widget});
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => this.widget,
              ));
        },
        child: buildRow(this.icon, this.text),
      ),
      SizedBox(
        height: 5.0,
      ),
      buildDivider(),
    ]);
  }

  Divider buildDivider() {
    return Divider(
      color: divider,
    );
  }

  Widget buildRow(IconData icon, String title) {
    final TextStyle tStyle = TextStyle(color: active, fontSize: 16.0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(children: [
        Icon(
          icon,
          color: active,
        ),
        SizedBox(width: 10.0),
        Text(
          title,
          style: tStyle,
        ),
        //Spacer(),
      ]),
    );
  }
}
