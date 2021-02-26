enum FoodItemType {
  snaks_and_breakfast,
  dosa_delights,
  sandwiches,
  drinks,
  thali,
  punjabi_dishes,
  tandoori_hot,
  raita_and_papad,
  basmati_khazana,
  chinese_soup,
  starters,
  noodles_and_rice,
  juice_and_lassi
}

class FoodItem {
  String id;
  final FoodItemType type;
  final String title;
  final String imgUrl;
  final String price;

  FoodItem(
      {this.id,
      this.type,
      this.title,
      this.imgUrl,
      this.price,});

  FoodItem.fromMap(Map<String, dynamic> data, String id)
      : this(
          id: id,
          type: FoodItemType.values[data['type']],
          title: data['title'],
          imgUrl: data['imgUrl'],
          price: data['price'].toString(),
        );

  Map toMap(FoodItem foodItem){
    Map<dynamic, dynamic> data = Map<dynamic,dynamic>();
    foodItem.id = data['id'];
    return data;
  }
}
