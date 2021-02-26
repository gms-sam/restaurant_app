import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:intl/intl.dart';

class TakeOut extends StatefulWidget {
  final FoodItem foodItem;
  final int quantity;
  const TakeOut({Key key, @required this.foodItem, @required this.quantity})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return TakeOutState();
  }
}

class TakeOutState extends State<TakeOut> {
  final db = FirebaseFirestore.instance;
  String phoneno;
  String address;
  TextEditingController phoneController, addressController;

  var now = DateTime.now();
  get weekDay => DateFormat('EEEE').format(now);
  get day => DateFormat('dd').format(now);
  get month => DateFormat('MMMM').format(now);
  var date = DateTime.now();
  static get current => TimeOfDay.now();
  String get format => DateFormat('jm').format(now);

  @override
  void initState() {
    super.initState();
    User user = getUser();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((ds) {
      setState(() {
        address = ds.data()['address'];
        addressController = TextEditingController(text: address);
      });
      setState(() {
        phoneno = user.phoneNumber;
        phoneController = TextEditingController(text: phoneno);
      });
    });
  }

  User getUser() {
    return FirebaseAuth.instance.currentUser;
  }

  showBottomSheet() {
    showModalBottomSheet(
        isDismissible: false,
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

  void takeOut() async {
    User user = getUser();
    db
        .collection('users')
        .doc(user.uid)
        .update({'address': address, 'All Orders': AppState.orders});
    return await db
        .collection("users")
        .doc(user.uid)
        .collection('Order & Seat Reservation')
        .doc(date.toString())
        .set({
      'Order Name': widget.foodItem.title,
      'Order Id': widget.foodItem.id,
      'Quantity': widget.quantity,
      'phoneno': phoneno,
      'address': address,
      'user-email': user.email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5.0,
        iconTheme: IconThemeData(
          color: Colors.deepOrange,
        ),
        title: Text(
          "Take Out",
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
                    "Food at your doorstep",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  controller: addressController,
                  onChanged: (value) => address = value,
                  decoration: new InputDecoration(
                    labelText: "Address",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 30),
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  onChanged: (value) => phoneno,
                  decoration: new InputDecoration(
                    labelText: "Phone",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.2,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(children: [
                      Text(
                        'Order Name:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Quantity:",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Total Price:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w400),
                      ),
                    ]),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      children: <Widget>[
                        Text(widget.foodItem.title,
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 25,
                                fontWeight: FontWeight.w300)),
                        SizedBox(
                          height: 5,
                        ),
                        Text((widget.quantity).toString(),
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 25,
                                fontWeight: FontWeight.w300)),
                        SizedBox(
                          height: 5,
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
                    SizedBox(
                      width: 40,
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
                              takeOut();
                              AppState.orders.add(widget.foodItem.id);
                              showBottomSheet();
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
