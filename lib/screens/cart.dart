import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/screens/home.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import '../model/state.dart';

class CartScreen extends StatefulWidget {
  final UserRepository userRepo;
  const CartScreen({Key key, @required this.userRepo});
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context) => BottomSheet());
  }

  Widget toggle() {
    if (AppState.cart.isEmpty) {
      return FloatingActionButton.extended(
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
          },
          tooltip: 'Back to Home Screen',
          label: Text(
            'Go back to home',
            style: TextStyle(color: Colors.deepOrange),
          ),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.deepOrange),
              borderRadius: BorderRadius.circular(50)),
          icon: Icon(
            Icons.home,
            color: Colors.deepOrange,
          ));
    }

    return FloatingActionButton.extended(
      backgroundColor: Colors.deepOrange,
      onPressed: () {
        showBottomSheet();
      },
      tooltip: 'Toggle',
      label: Text(
        'Order All Items',
        style: TextStyle(color: Colors.white),
      ),
      icon: Icon(Icons.store, color: Colors.white),
    );
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: AppState.cart.length,
      itemBuilder: (context, int index) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('foodItems')
              .doc(AppState.cart[index])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var foodItemData = snapshot.data;
              FoodItem foodItem =
                  FoodItem.fromMap(foodItemData.data(), foodItemData.id);
              return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    //padding: const EdgeInsets.all(0),
                    margin: EdgeInsets.all(10),
                    height: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 130,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image:
                                  CachedNetworkImageProvider(foodItem.imgUrl),
                              fit: BoxFit.cover,
                            )),
                          ),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: <Widget>[
                                  CartItems(
                                    foodItem: foodItem,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Cart",
            style: TextStyle(color: Colors.deepOrange),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.deepOrange),
        ),
        body: AppState.cart.isEmpty
            ? Center(
                child: Container(
                height: MediaQuery.of(context).size.height / 4,
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.remove_shopping_cart,
                      size: 125,
                      color: Colors.black26,
                    ),
                    Text("There is no item in the cart"),
                    FlatButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                      userRepository: widget.userRepo)));
                        },
                        child: Text("Buy"))
                  ],
                ),
              ))
            : buildListView(),
        floatingActionButton: toggle(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.delete_sweep),
                  onPressed: () {
                    setState(() {
                      AppState.cart = [];
                      AppState.cartwithName = [];
                    });
                  }),
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.popUntil(context,
                        ModalRoute.withName(Navigator.defaultRouteName));
                  })
            ],
          ),
        ));
  }
}

class CartItems extends StatefulWidget {
  final FoodItem foodItem;
  CartItems({Key key, this.foodItem}) : super(key: key);

  @override
  _CartItemsState createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                widget.foodItem.title,
                overflow: TextOverflow.fade,
                softWrap: true,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Container(
              width: 50,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    AppState.cart.remove(widget.foodItem.id);
                  });
                },
                color: Colors.red,
                icon: Icon(Icons.delete),
                iconSize: 20,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("Price: "),
            SizedBox(
              width: 5,
            ),
            Text(
              widget.foodItem.price,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ],
    );
  }
}

class BottomSheet extends StatefulWidget {
  BottomSheet({
    Key key,
  }) : super(key: key);

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  String address, phone;
  TextEditingController phoneController;
  TextEditingController addressController;
  DateTime seatTime;
  static int noOfSeats = 1;
  int _currentIndex = 0;
  String get format => DateFormat('jm').format(seatTime);

  User getUser() {
    return FirebaseAuth.instance.currentUser;
  }

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
    });
    setState(() {
      phone = user.phoneNumber;
      phoneController = TextEditingController(text: phone);
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  showBottomSheet() {
    if (_currentIndex == 0) {
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
                            text: '${AppState.cart.length} items',
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
                            text: '$format',
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
    } else {
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
                            text: '${AppState.cart.length} items',
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
  }

  showError() {
    showDialog(
        context: context,
        child: Center(
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
          ),
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

  var date = DateTime.now();
  void addtoDatabase() async {
    AppState.orders.addAll(AppState.cart);
    User user =  getUser();
     if (_currentIndex == 0) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({"All Orders": AppState.orders});
        return FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('Order & Seat Reservation')
            .doc(date.toString())
            .set({
          'Order List': AppState.cart,
          'Order Name': AppState.cartwithName,
          'Number of Seats': noOfSeats,
          'Reservation Time': format,
          'Number of Items': AppState.cart.length
        });
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'address': address, "All Orders": AppState.cart});
        return FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('Order & Seat Reservation')
            .doc(date.toString())
            .set({
          'Order List': AppState.cart,
          'Order Name': AppState.cartwithName,
          'Address': address,
          'Phone': phone,
          'Number of Items': AppState.cart.length
        });
      }
  }

  List<Widget> bottomNav() {
    List<Widget> body;
    if (_currentIndex == 0) {
      return body = [
        Center(
          child: Container(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text("Arrive at your time, Get the Food ready",
                    style: TextStyle(color: Colors.deepOrange, fontSize: 25)),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: NumberPicker.horizontal(
                      initialValue: noOfSeats,
                      minValue: 1,
                      maxValue: 8,
                      onChanged: (value) => setState(() => noOfSeats = value))),
              Container(
                  width: 200,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepOrange),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: FlatButton(
                      onPressed: () {
                        selectTime();
                      },
                      child: Text(
                        "Pick Time",
                        style: TextStyle(color: Colors.deepOrange),
                      ))),
            ],
          )),
        ),
      ];
    } else if (_currentIndex == 1) {
      return body = [
        Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  "Food at your doorstep",
                  style: TextStyle(color: Colors.deepOrange, fontSize: 25),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  onChanged: (value) {
                    return phone = value;
                  },
                  maxLength: 13,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  decoration: new InputDecoration(
                    labelText: "Phone Number",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 3),
                child: TextField(
                  controller: addressController,
                  keyboardType: TextInputType.multiline,
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
            ],
          ),
        )
      ];
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Complete Your Order",
          style: TextStyle(color: Colors.deepOrange),
        ),
        iconTheme: IconThemeData(color: Colors.deepOrange),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(children: bottomNav()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 0) {
            if (seatTime != null) {
              addtoDatabase();
              showBottomSheet();
            } else {
              showError();
            }
          } else {
            showBottomSheet();
            addtoDatabase();
          }
        },
        child: Icon(Icons.done),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.fastfood), title: Text("Eat In")),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), title: Text("TakeOut"))
          ]),
    );
  }
}
