import 'package:flutter/material.dart';

class FoodItemImage extends StatelessWidget {
  final String imageURL;

  FoodItemImage(this.imageURL);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Image.network(
        imageURL,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : Center(child: CircularProgressIndicator(),);
        }
      ),
    );
  }
}
