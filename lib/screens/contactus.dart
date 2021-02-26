import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  _dailer() {
    var url = "tel:7758839488";
    launch(url);
  }

  _gmail() {
    var url1 = "mailto:cth001100@gmail.com";
    launch(url1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.deepOrange),
        title: Text(
          "Contact Us",
          style: TextStyle(color: Colors.deepOrange),
        ),
      ),
      // drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 350.0,
              width: 300.0,
              margin: EdgeInsets.all(00.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.deepOrange,
                      style: BorderStyle.solid,
                      width: 2.0),
                  borderRadius: BorderRadius.circular(40.0)),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  Text("Get in Touch",
                      style: TextStyle(
                          fontSize: 35.0, fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Want ✌ get in touch?",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        color: Colors.deepOrange),
                  ),
                  Text(
                    " We'd love ✌ hear u. Here how u can reach us",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Container(
                    height: 40.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: FlatButton(
                        onPressed: () {
                          _dailer();
                        },
                        child: Icon(
                          Icons.dialer_sip,
                          color: Colors.white,
                        )),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 40.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: FlatButton(
                        onPressed: () {
                          _gmail();
                        },
                        child: Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
