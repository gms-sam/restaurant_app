import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/login/authentication_bloc/index.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc(UserRepository userRepository)
      : assert(userRepository != null),
        _userRepository = userRepository, super(null);

  @override
  AuthenticationState get initialState => UnInitializedState();
  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = _userRepository.isSignedIn();
      if (isSignedIn) {
        yield AuthenticatedState();
      } else {
        yield UnAuthenticatedState();
      }
    } catch (_) {
      yield UnAuthenticatedState();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield AuthenticatedState();
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield UnAuthenticatedState();
    _userRepository.signOut();
  }
}
