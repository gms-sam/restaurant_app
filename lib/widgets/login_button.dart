import 'package:flutter/material.dart';

class LoginAndCreateAccountButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  LoginAndCreateAccountButton({this.onPressed, this.text});

  @override
  Widget build(BuildContext context) {
    return RaisedButton( 
      elevation: 5,
      focusElevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        this.text,
        style: TextStyle(color: Colors.black),
      ),
      onPressed: this.onPressed,
    );
  }
}