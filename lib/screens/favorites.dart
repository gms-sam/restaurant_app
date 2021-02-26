import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:restaurant_app/widgets/fooditem_card.dart';

class Favorite extends StatefulWidget {
  final Function drawerFavorits;
  Favorite({this.drawerFavorits});

  @override
  FavoriteState createState() => FavoriteState();
}

class FavoriteState extends State<Favorite> {
  Widget buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Padding buildFavorites({List<String> ids}) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('foodItems');
    Stream<QuerySnapshot> stream;

    stream = collectionReference.snapshots();

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
                  children: snapshot
                      .data
                      .docs
                      .where((d) => ids == null || ids.contains(d.id))
                      .map((doc) {
                    return new FoodItemCard(
                      foodItem: FoodItem.fromMap(doc.data(), doc.id),
                      inFavorites: AppState.favorites.contains(doc.id),
                      onFavoriteButtonPressed: handleFavoritesListChanged,
                      onBuyNow: addToCart,
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

  void addToCart(String foodItemId) {
    setState(() {
      AppState.cart.add(foodItemId);
    });
    print(AppState.cart);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Favorites",
          style: TextStyle(color: Colors.deepOrange),
        ),
        iconTheme: IconThemeData(color: Colors.deepOrange),
        elevation: 0,
      ),
      body: buildFavorites(ids: AppState.favorites),
    );
  }
}
