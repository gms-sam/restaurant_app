import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  User user;
  String email;
  String photo;
  String name;
  String phone;
  String address;

  User currentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    
    super.initState();
   user =  currentUser();
   DocumentReference df = FirebaseFirestore.instance.collection('users').doc(user.uid);
      df.get().then((ds){
        setState(() {
          address=ds.data()['address'];
        });
      });
      setState(() {
        email = user.email;
        phone = user.phoneNumber;
        name = user.displayName;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          photo,
                        ),
                        fit: BoxFit.cover)),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 200.0, 16.0, 16.0),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.only(top: 16.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 96.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    name,
                                    style: TextStyle(
                                        fontSize: 27.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: double.infinity),
                          ],
                        ),
                      ),
                      Container(
                        height: 80.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                image: NetworkImage(
                                  photo,
                                ),
                                fit: BoxFit.cover)),
                        margin: EdgeInsets.only(left: 16.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("User information"),
                        ),
                        Divider(),
                        ListTile(
                          title: Text("UserName"),
                          subtitle: Text(
                            name,
                          ),
                          leading: Icon(Icons.person),
                        ),
                        ListTile(
                          title: Text("Email"),
                          subtitle: Text(
                            email,
                          ),
                          // Text("usergmail@gmail.com"),
                          leading: Icon(Icons.email),
                        ),
                        ListTile(
                          title: Text("Phone"),
                          subtitle: Text(
                            phone,
                          ),
                          leading: Icon(Icons.phone),
                        ),
                        ListTile(
                          title: Text("Adress"),
                          subtitle: address!=null? Text(address) : TextField(
                            onSubmitted: (value){
                              FirebaseFirestore.instance.collection('users').doc(user.uid).update({"address": value});
                              return setState((){
                                address = value;
                              });
                            },
                          ),
                          leading: Icon(Icons.calendar_view_day),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
