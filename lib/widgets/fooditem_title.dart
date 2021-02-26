import 'package:flutter/material.dart';
import 'package:restaurant_app/model/fooditem.dart';

class FoodItemTitle extends StatelessWidget {
  final FoodItem foodItem;
  final Function onbuyNow;

  FoodItemTitle(this.foodItem, {this.onbuyNow});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        // Default value for crossAxisAlignment is CrossAxisAlignment.center.
        // We want to align title and description of foodItems left:
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(children: <Widget>[
              Text(
            foodItem.title,
            // ignore: deprecated_member_use
            style: Theme.of(context).textTheme.title,
          ),
          SizedBox(height: 7.0),
          Text(
                "₹${foodItem.price}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],),
          
          // Empty space:
          
          IconButton(
            icon: Icon(Icons.add_shopping_cart),
            onPressed: () {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  '${foodItem.title} added to cart',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                duration: Duration(milliseconds: 1000),
                backgroundColor: Colors.deepOrange,
              ));
              onbuyNow(foodItem);
            },
          ),
        ],
      ),
    );
  }
}

class DetailFoodItemTitle extends StatelessWidget {
  final FoodItem foodItem;
  final double padding;

  DetailFoodItemTitle(
    this.foodItem,
    this.padding,
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              foodItem.title,
              //style: Theme.of(context).textTheme.title,
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "₹${foodItem.price}",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
