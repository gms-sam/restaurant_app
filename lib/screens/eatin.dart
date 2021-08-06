import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class EatIn extends StatefulWidget {
  final FoodItem foodItem;
  final int quantity;

  const EatIn({Key key, @required this.foodItem, @required this.quantity})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EatInState();
  }
}

class EatInState extends State<EatIn> {
  int noOfPersons = 1;
  final db = FirebaseFirestore.instance;
  String phoneno;
  String address;
  User user;
  TextEditingController controller;
  var now = DateTime.now();
  get weekDay => DateFormat('EEEE').format(now);
  get day => DateFormat('dd').format(now);
  get month => DateFormat('MMMM').format(now);
  get current => TimeOfDay.now();
  String get format => DateFormat('jm').format(now);
  DateTime seatTime;
  String get seatFormat => DateFormat('jm').format(seatTime);

  User getUser() {
    User user = FirebaseAuth.instance.currentUser;
    return user;
  }

  void eatIn(String seats) async {
    final db = FirebaseFirestore.instance;
    User user = getUser();
    await db
        .collection('users')
        .doc(user.uid)
        .update({"All Orders": AppState.orders});
    return await db
        .collection("users")
        .doc(user.uid)
        .collection('Order & Seat Reservation')
        .doc(now.toString())
        .set({
      'Order Name': widget.foodItem.title,
      'Order id': widget.foodItem.id,
      'Quantity': widget.quantity,
      'Reservation Time': seatFormat,
      'No of Seats': seats,
      'user-email': user.email,
    });
  }

  showBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Container(
                      width: 90,
                      height: 8,
                      decoration: ShapeDecoration(
                          shape: StadiumBorder(), color: Colors.black26),
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 15,
                  ),
                  RichText(
                      text: TextSpan(
                    text: "Your Order for for ",
                    style: TextStyle(color: Colors.black, fontSize: 21),
                    children: [
                      TextSpan(
                          text: '${widget.foodItem.title}',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      TextSpan(
                        text: " has been placed successfully",
                        style: TextStyle(color: Colors.black, fontSize: 21),
                      )
                    ],
                  )),
                  RichText(
                      text: TextSpan(
                    text: "We expect you to arrive at ",
                    style: TextStyle(color: Colors.black, fontSize: 21),
                    children: [
                      TextSpan(
                          text: '$seatFormat ',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                    ],
                  )),
                  Divider(),
                  Center(
                    child: RaisedButton(
                      child: Text('Go Back to Home',
                          style: TextStyle(color: Colors.deepOrange)),
                      onPressed: () {
                        Navigator.popUntil(context,
                            ModalRoute.withName(Navigator.defaultRouteName));
                      },
                      padding:
                          EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                      color: Colors.white,
                      shape: StadiumBorder(
                          side: BorderSide(color: Colors.deepOrange)),
                    ),
                  )
                ])));
  }

  showError() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              content: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Text(
                    "Please Select a Time",
                    style: TextStyle(color: Colors.black),
                  )),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    selectTime();
                  },
                  child: Text("Pick Time"),
                  splashColor: Colors.deepOrange,
                )
              ],
            ));
  }

  selectTime() {
    DatePicker.showTimePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            cancelStyle: TextStyle(color: Colors.black),
            doneStyle: TextStyle(color: Colors.deepOrange)), onConfirm: (time) {
      return seatTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.deepOrange,
        ),
        title: Text(
          "Eat In",
          style: TextStyle(color: Colors.deepOrange),
        ),
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 16, 0, 0),
                child: Text(
                  format,
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w300,
                      fontSize: 40),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '$weekDay, $day $month',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                  ),
                  child: Text(
                    "Arrive at your time,\nGet the Cake ready",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    NumberPicker(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepOrange),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        value: noOfPersons,
                        axis: Axis.horizontal,
                        minValue: 1,
                        maxValue: 8,
                        onChanged: (newValue) =>
                            setState(() => noOfPersons = newValue)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 25,
                    ),
                    Text(
                      "Plase Select the number of seats",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 35,
                    ),
                    Container(
                        width: 200,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepOrange),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: FlatButton(
                            onPressed: () {
                              selectTime();
                            },
                            child: Text(
                              "Pick Time",
                              style: TextStyle(color: Colors.deepOrange),
                            ))),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 4.5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Row(
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Order Name:',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(widget.foodItem.title,
                                    style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w300)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                "Quantity:",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text((widget.quantity).toString(),
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                'Total Price:',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                  "₹${(int.parse(widget.foodItem.price) * widget.quantity)}"
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ),
                        ]),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                            height: 55,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(13))),
                            color: Colors.deepOrange,
                            child: Text(
                              "Place Order",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            onPressed: () {
                              if (seatTime != null) {
                                eatIn(noOfPersons.toString());
                                AppState.orders.add(widget.foodItem.id);
                                showBottomSheet();
                              } else {
                                showError();
                              }
                            }),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
