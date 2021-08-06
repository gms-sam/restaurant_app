import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurant_app/model/fooditem.dart';

class AppState {
  FoodItem foodItem;
  static List<String> favorites = [];
  static List<String> orders = [];
  static List<String> cart = [];
  static List<String> cartwithName = [];
  AppState({this.foodItem});
}

getValues() async {
  User user = FirebaseAuth.instance.currentUser;
  AppState.favorites = await getFavorites(user.uid);
  AppState.cart = await getOrder(user.uid);
}

Future<List<String>> getOrder(doc) async {
  DocumentSnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('users').doc(doc).get();
  if (querySnapshot.exists &&
      querySnapshot.data().containsKey('favorites') &&
      querySnapshot.data()['favorites'] is List) {
    // Create a new List<String> from List<dynamic>
    return List<String>.from(querySnapshot.data()['favorites']);
  }
  return [];
}

Future<List<String>> getFavorites(doc) async {
  DocumentSnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('users').doc(doc).get();
  if (querySnapshot.exists &&
      querySnapshot.data().containsKey('favorites') &&
      querySnapshot.data()['favorites'] is List) {
    // Create a new List<String> from List<dynamic>
    return List<String>.from(querySnapshot.data()['favorites']);
  }
  return [];
}

Future updateFavorites(String uid, String foodItemId) async {
  getFavorites(uid);
  List<String> favorites = await getFavorites(uid);
  AppState.favorites = favorites;
  DocumentReference favoritesReference =
      FirebaseFirestore.instance.collection('users').doc(uid);
  DocumentSnapshot<Map<String, dynamic>> snapshot = await favoritesReference.get();
  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    if (snapshot.exists) {
      if (!snapshot.data()['favorites'].contains(foodItemId)) {
         tx.update(favoritesReference, <String, dynamic>{
          'favorites': FieldValue.arrayUnion([foodItemId])
        });
      } else {
         tx.update(favoritesReference, <String, dynamic>{
          'favorites': FieldValue.arrayRemove([foodItemId])
        });
      }
    } else {
       tx.set(favoritesReference, {
        'favorites': [foodItemId]
      });
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}
