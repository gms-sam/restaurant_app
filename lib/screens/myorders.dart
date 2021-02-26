import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:restaurant_app/widgets/fooditem_card.dart';

class MyOrders extends StatefulWidget {
  final Function myOrders;
  MyOrders({this.myOrders});

  @override
  MyOrdersState createState() => MyOrdersState();
}

class MyOrdersState extends State<MyOrders> {
  void handleFavoritesListChanged(String foodItemID) {
    User user = FirebaseAuth.instance.currentUser;
    updateFavorites(user.uid, foodItemID).then((result) {
      if (result == true) {
        setState(() {
          if (!AppState.favorites.contains(foodItemID)) {
            AppState.favorites.add(foodItemID);
          } else {
            AppState.favorites.remove(foodItemID);
          }
        });
      }
    });
    return print(AppState.favorites);
  }

  Widget buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Padding buildMyOrders({List<String> ids}) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('foodItems');
    Stream<QuerySnapshot> stream = collectionReference.snapshots();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: new StreamBuilder(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return buildLoadingIndicator();
                return new ListView(
                  children: snapshot.data.docs
                      // Check if the argument ids contains doc ID if ids has been passed:
                      .where((d) => ids == null || ids.contains(d.id))
                      .map((doc) {
                    return new OrderPlaced(
                      foodItem: FoodItem.fromMap(doc.data(), doc.id),
                      inFavorites: AppState.favorites.contains(doc.id),
                      onFavoriteButtonPressed: handleFavoritesListChanged,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> getOrders(doc) async {
    DocumentSnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').doc(doc).get();
    if (querySnapshot.exists &&
        querySnapshot.data().containsKey('All Orders') &&
        querySnapshot.data()['All Orders'] is List) {
      // Create a new List<String> from List<dynamic>
      return List<String>.from(querySnapshot.data()['All Orders']);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "My Orders",
          style: TextStyle(color: Colors.deepOrange),
        ),
        iconTheme: IconThemeData(color: Colors.deepOrange),
        elevation: 0,
      ),
      body: buildMyOrders(ids: AppState.orders),
    );
  }
}
