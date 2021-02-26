import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_app/login/authentication_bloc/index.dart';
import 'login/bloc_delegate.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final UserRepository userRepository = UserRepository();
  User user = userRepository.user;
  BlocSupervisor.delegate = SimpleBlocDelegate(); 
  runApp(BlocProvider(
    create: (context) =>
        AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
    child: MyApp(
      userRepository: userRepository,
      user: user,
    ),
  ));
}

class MyApp extends StatelessWidget {
  final UserRepository _userRepository; 
  MyApp({Key key, @required UserRepository userRepository, User user})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    User fuser = _userRepository.user;
    return MaterialApp(
        title: 'Restaurant App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            accentColor: Colors.deepOrange, primarySwatch: Colors.deepOrange),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticatedState) {
              return HomePage(
                userRepository: _userRepository,
                user: fuser,
              );
            }
            if (state is UnAuthenticatedState) {
              return LoginPage(
                userRepository: _userRepository,
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
