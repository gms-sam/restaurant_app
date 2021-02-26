import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:restaurant_app/widgets/fooditem_image.dart';
import 'package:restaurant_app/widgets/fooditem_title.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:restaurant_app/screens/screens.dart';

class DetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  final bool inFavorites;
  final Function changeFavorites;
  final UserRepository userRepository;

  DetailScreen(this.foodItem, this.inFavorites,
      {@required this.changeFavorites, @required this.userRepository});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  Color bgColor = Color(0xffF4F7FA);
//  const Color primaryColor = Colors.green;
  Color primaryColor = Color(0xff44c662);
  Color white = Colors.white;
  Color darkText = Colors.black54;
  Color highlightColor = Colors.green;
  int quantity = 1;
  double rating = 0;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      quantity--;
    });
  }

  void changeRating(double value) {
    setState(() {
      rating = value;
    });
  }

  void handleFavoritesListChanged(String foodItemID) {
    User user = FirebaseAuth.instance.currentUser;
    updateFavorites(user.uid, foodItemID).then((result) {
      if (result == true) {
        setState(() {
          if (!AppState.favorites.contains(foodItemID))
            AppState.favorites.add(foodItemID);
          else
            AppState.favorites.remove(foodItemID);
        });
      }
    });
    return print(AppState.favorites);
  }

  var h3 = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.w800,
      fontFamily: 'Poppins');

  var h4 = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins');

  var h5 = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins');

  var h6 = TextStyle(
      color: Colors.black,
      fontSize: 25,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins');

  OutlineButton froyoOutlineBtn(String text, onPressed) {
    return OutlineButton(
      onPressed: onPressed,
      child: Text(text),
      textColor: Colors.deepOrange,
      highlightedBorderColor: Colors.white,
      borderSide: BorderSide(color: Colors.deepOrange),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  FlatButton froyoFlatBtn(String text, onPressed) {
    return FlatButton(
      onPressed: onPressed,
      child: Text(text),
      textColor: white,
      color: Colors.deepOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton button() {
      return FloatingActionButton(
        onPressed: () {
          AppState.favorites.contains(widget.foodItem.id)
              ? scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    '${widget.foodItem.title} removed from favorites',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: Colors.deepOrange,
                ))
              : scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    '${widget.foodItem.title} added to favorites',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: Colors.deepOrange,
                ));
          return handleFavoritesListChanged(widget.foodItem.id);
        },
        child: Icon(
          AppState.favorites.contains(widget.foodItem.id)
              ? Icons.favorite
              : Icons.favorite_border,
          color: Colors.deepOrange,
        ),
        elevation: 2.0,
        backgroundColor: Colors.white,
      );
    }

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            height: 360,
            // width: 600,
            child: FoodItemImage(widget.foodItem.imgUrl),
          ),
          AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30.0),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(60))
                  /* only(
                      topLeft: Radius.circular(60.0),
                      topRight: Radius.circular(60.0)
                      ) */
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 20),
                      child: SmoothStarRating(
                        allowHalfRating: true,
                        onRatingChanged: (v) {
                          changeRating(v);
                        },
                        starCount: 5,
                        rating: rating,
                        size: 27.0,
                        color: Colors.deepOrange,
                        borderColor: Colors.deepOrange,
                      ),
                    ),
                  ),
                  Center(child: DetailFoodItemTitle(widget.foodItem, 25.0)),
                  //  SizedBox(height: 10.0),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 25),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text('Quantity', style: h6),
                          margin: EdgeInsets.only(bottom: 15),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 55,
                              height: 55,
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.deepOrange),
                                onPressed: () {
                                  if (quantity > 1) {
                                    decrementQuantity();
                                  }
                                },
                                onLongPress: () {
                                  setState(() {
                                    quantity = 1;
                                  });
                                },
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Text(quantity.toString(), style: h3),
                            ),
                            Container(
                              width: 55,
                              height: 55,
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.deepOrange),
                                onPressed: incrementQuantity,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 180,
                      // child: froyoOutlineBtn('Buy Now', () {}),
                      child: froyoOutlineBtn('Eat In', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EatIn(
                                      foodItem: widget.foodItem,
                                      quantity: quantity,
                                    )));
                      }),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 180,
                      child: froyoFlatBtn('Take Out', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TakeOut(
                                      foodItem: widget.foodItem,
                                      quantity: quantity,
                                    )));
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 100.0,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: 40,
            child: button(),
          ),
        ],
      ),
    );
  }
}
