import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  GoogleSignInButton({this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    Image _buildLogo() {
      return Image.asset(
        "assets/glogo.png",
        height: 18.0,
        width: 18.0,
      );
    }

    Opacity _buildText() {
      return Opacity(
        opacity: 0.54,
        child: Text(
          "Sign in with Google",
          style: TextStyle(
            fontFamily: 'Roboto-Medium',
            color: Colors.black,
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width/2,
      height: 50,
      child: FlatButton(
        onPressed: this.onPressed,
        child: Column(
          children: <Widget>[
            SizedBox(height: 15,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildLogo(),
                SizedBox(width: MediaQuery.of(context).size.width/25.0),
                _buildText(),
              ],
            ),
            Divider(
              color: Colors.black,
              thickness: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
