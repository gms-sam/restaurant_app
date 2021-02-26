import 'package:flutter/material.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/screens/detail.dart';
import 'fooditem_image.dart';
import 'fooditem_title.dart';
import 'package:restaurant_app/widgets/fooditem_image.dart';
import 'package:restaurant_app/widgets/fooditem_title.dart';

class FoodItemCard extends StatefulWidget {
  final FoodItem foodItem;
  final bool inFavorites;
  final Function onBuyNow;
  final Function onFavoriteButtonPressed;
  final UserRepository userRepository;
  // final bool leftAligned;

  FoodItemCard(
      {@required this.foodItem,
      @required this.onFavoriteButtonPressed,
      @required this.inFavorites,
      this.userRepository,
      this.onBuyNow
      //   @required this.leftAligned
      });

  @override
  _FoodItemCardState createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  @override
  Widget build(BuildContext context) {
    RawMaterialButton buildFavoriteButton() {
      return RawMaterialButton(
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        onPressed: () {
          widget.inFavorites == true
              ? Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    '${widget.foodItem.title} removed from favorites',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: Colors.deepOrange,
                ))
              : Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    '${widget.foodItem.title} added to favorites',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: Colors.deepOrange,
                ));
          return widget.onFavoriteButtonPressed(widget.foodItem.id);
        },
        child: Icon(
          widget.inFavorites == true ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: 30,
        ),
        elevation: 2.0,
        shape: CircleBorder(),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            widget.foodItem,
            widget.inFavorites,
            changeFavorites: widget.onFavoriteButtonPressed,
            userRepository: widget.userRepository,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Card( 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  FoodItemImage(widget.foodItem.imgUrl),
                  Positioned(
                    child: buildFavoriteButton(),
                    top: 2.0,
                    right: 2.0,
                  ),
                ],
              ),
              FoodItemTitle(widget.foodItem, onbuyNow: widget.onBuyNow),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderPlaced extends StatefulWidget {
  final FoodItem foodItem;
  final bool inFavorites;
  final Function onFavoriteButtonPressed;
  OrderPlaced({this.foodItem, this.inFavorites, this.onFavoriteButtonPressed});
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  RawMaterialButton buildFavoriteButton() {
      return RawMaterialButton(
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        onPressed: () {
          widget.inFavorites == true
              ? Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    '${widget.foodItem.title} removed from favorites',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: Colors.deepOrange,
                ))
              : Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    '${widget.foodItem.title} added to favorites',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: Colors.deepOrange,
                ));
          return widget.onFavoriteButtonPressed(widget.foodItem.id);
        },
        child: Icon(
          widget.inFavorites == true ? Icons.favorite : Icons.favorite_border,
          color: Colors.black,
          size: 30,
        ),
        elevation: 2.0,
        shape: CircleBorder(),
      );
    }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(right: 30.0, bottom: 10.0),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5.0),
                        elevation: 0.0,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 80,
                                child: FoodItemImage(widget.foodItem.imgUrl),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      widget.foodItem.title,
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 23.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            "Price: ",
                                            style: TextStyle(fontSize: 25),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            widget.foodItem.price,
                                            style: TextStyle(fontSize: 25),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              buildFavoriteButton()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
