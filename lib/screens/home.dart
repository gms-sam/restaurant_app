import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:restaurant_app/login/authentication_bloc/index.dart';
import 'package:restaurant_app/login/login_bloc/index.dart';
import 'package:restaurant_app/model/fooditem.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:restaurant_app/screens/screens.dart';
import 'package:restaurant_app/widgets/widgets.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/screens/login.dart';
import 'cart.dart';

class HomePage extends StatelessWidget {
  final UserRepository _userRepository;
  final User _user;
  HomePage({Key key, @required UserRepository userRepository, User user})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _user = user,
        super(key: key);

  final key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    void logout() {
      BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
    }

    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(userRepository: _userRepository),
      child: HomeScreen(
        userRepository: _userRepository,
        signOutNow: logout,
        scaffoldKey: key,
        firebaseUser: _user,
      ),
    );
  }
}

final List<String> categaryName = [
  "Cake",
  "Pasteries",
  "Brownie",
  "Cupcake",
  "Ice Cream Cake",
  "Fudge cake"
];

final List<String> images = [
  'https://firebasestorage.googleapis.com/v0/b/hotel-mitali.appspot.com/o/grid%2Fsnacks_and_breakfast.jpg?alt=media&token=153ad2a4-e14f-40d2-a993-64cfccd2a041',
  'https://firebasestorage.googleapis.com/v0/b/hotel-mitali.appspot.com/o/grid%2Fdosa_delights.jpg?alt=media&token=e2c050f6-886e-4953-b9fa-a31e6c93f3bd',
  'https://firebasestorage.googleapis.com/v0/b/hotel-mitali.appspot.com/o/grid%2Fsandwiches.jpg?alt=media&token=bb88620b-4ccd-4b6a-8224-c67a043b455d',
  'https://firebasestorage.googleapis.com/v0/b/hotel-mitali.appspot.com/o/grid%2FDrinks.jpg?alt=media&token=cc06d8b4-c457-44c3-b52a-e3f6b1043c58',
  'https://firebasestorage.googleapis.com/v0/b/hotel-mitali.appspot.com/o/grid%2Fthali.jpg?alt=media&token=d899d1b0-7287-482d-9440-b496d77262fe',
  'https://firebasestorage.googleapis.com/v0/b/hotel-mitali.appspot.com/o/grid%2Fpunjabi%20dishes.jpg?alt=media&token=c37016b0-c4d3-432e-bff5-26e64862710e',
];

class HomeScreen extends StatefulWidget {
  final User firebaseUser;
  final VoidCallback signOutNow;
  final UserRepository repository;
  final scaffoldKey;
  HomeScreen(
      {Key key,
      User firebaseUser,
      this.signOutNow,
      UserRepository userRepository,
      this.scaffoldKey})
      : //assert(firebaseUser != null),
        repository = userRepository,
        firebaseUser = firebaseUser,
        super(key: key);
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  LoginScreen login;
  UserRepository get userRepository => widget.repository;
  FoodItem foodItem;
  User user;
  static bool buildtrue = false;
  @override
  void initState() {
    super.initState();
    user = getUser();
    getDetails();
  }

  getDetails() async {
    List<String> order = await getOrders(user.uid);
    List<String> favs = await getFavorites(user.uid);
    if (mounted)
      setState(() {
        AppState.favorites = favs;
        AppState.orders = order;
      });
  }

  User getUser() {
    user = FirebaseAuth.instance.currentUser;
    return user;
  }

  Future<List<String>> getFavorites(doc) async {
    DocumentSnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').doc(doc).get();
    if (querySnapshot.exists &&
        querySnapshot.data().containsKey('favorites') &&
        querySnapshot.data()['favorites'] is List) {
      // Create a new List<String> from List<dynamic>
      return List<String>.from(querySnapshot.data()['favorites']);
    }
    return [];
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

  Widget _buildItems(int index, BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => _onTapItem(context, index),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(14))),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: FoodNetworkImage(images[index] /*%  images.length] */,
                      fit: BoxFit.cover)),
              SizedBox(
                height: 10.0,
              ),
              Text(
                categaryName[index % categaryName.length],
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onTapItem(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) => BuildFoodItemItems(
              index: index,
              foodItemType: FoodItemType.values[index],
              userRepository: userRepository,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Welcome to Cake Point'),
                background: FoodNetworkImage(
                    'https://picturetherecipe.com/wp-content/uploads/2018/05/Vindaloo-by-PictureTheRecipe.jpg',
                    fit: BoxFit.cover),
              ),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.favorite_border),
                    tooltip: 'Favorites',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => Favorite()),
                      );
                    })
              ]),
          SliverToBoxAdapter(
            child: Container(
                color: Colors.deepOrange,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("        Menu Items".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      MaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartScreen(
                                          userRepo: userRepository,
                                        )));
                          },
                          child: Text("Cart".toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400))),
                    ],
                  ),
                )),
          ),
          SliverPadding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              sliver: SliverStaggeredGrid(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return _buildItems(index, context);
                  }),
                  gridDelegate:
                      SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 30,
                    staggeredTileCount: 6,
                    staggeredTileBuilder: (int index) =>
                        new StaggeredTile.count(2, index.isEven ? 2 : 3),
                  ))),
        ],
      ),
      drawer: CustomAppDrawer(
        userRepository: userRepository,
        user: widget.firebaseUser,
        logout: widget.signOutNow,
      ),
    );
  }
}

class FoodNetworkImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double width, height;
  const FoodNetworkImage(this.image,
      {Key key, this.fit, this.height, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      errorWidget: (context, url, error) => Image.asset(
        'assets/placeholder.jpg',
        fit: BoxFit.cover,
      ),
      fit: BoxFit.cover,
      width: width,
      height: height,
      imageBuilder: (context, image) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
            image: DecorationImage(image: image, fit: BoxFit.cover)),
      ),
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
    );
  }
}

class BuildFoodItemItems extends StatefulWidget {
  final FoodItemType foodItemType;
  final List<String> ids;
  final int index;
  final UserRepository userRepository;

  BuildFoodItemItems({
    this.foodItemType,
    this.ids,
    this.index,
    this.userRepository,
  });
  @override
  State<StatefulWidget> createState() {
    return BuildFoodItemItemsState();
  }
}

class BuildFoodItemItemsState extends State<BuildFoodItemItems> {
  User user;

  @override
  void initState() {
    super.initState();
  }

  AppState appState;
  User getUser() {
    user = FirebaseAuth.instance.currentUser;
    return user;
  }

  Padding buildFoodItems({FoodItemType foodItemType}) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('foodItems');
    Stream<QuerySnapshot> stream;
    stream = collectionReference
        .where("type", isEqualTo: foodItemType.index)
        .snapshots();
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
                  children: snapshot.data.docs.map((doc) {
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

  Center buildLoadingIndicator() {
    return Center(
      child: new CircularProgressIndicator(),
    );
  }

  void addToCart(FoodItem foodItem) {
    setState(() {
      AppState.cart.add(foodItem.id);
      AppState.cartwithName.add(foodItem.title);
    });
    print(AppState.cart);
    print(AppState.cartwithName);
  }

  void handleFavoritesListChanged(String foodItemID) {
    getUser();
    updateFavorites(user.uid, foodItemID).then((value) {
      if (value == true) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(categaryName[widget.index]),
          actions: <Widget>[
            FlatButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  Text(
                    AppState.cart.length.toString(),
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartScreen(
                              userRepo: widget.userRepository,
                            )));
              },
            )
          ],
        ),
        body: buildFoodItems(foodItemType: widget.foodItemType));
  }
}
