import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurant_app/login/login_bloc/index.dart';
import 'package:restaurant_app/model/state.dart';
import 'package:meta/meta.dart';
import 'package:restaurant_app/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;
  AppState appState;
  LoginBloc({
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  LoginState get initialState => LoginState.empty();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    } else if (event is SignUpWithCredentialsPressed) {
      yield* _mapSignUpWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
        name: event.name,
      );
    } else if (event is LoginToPhone) {
      yield* _mapLoginWithPhone(phone: event.phone);
    } else if (event is LoginWithSms) {
      yield* _mapLoginWithSms(sms: event.sms);
    }
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInWithGoogle();
      User user =  FirebaseAuth.instance.currentUser;
      if (user.phoneNumber != null) {
        yield LoginState.success();
      } else {
        yield LoginState.socialSuccess();
      }
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithPhone({String phone}) async* {
    yield LoginState.loading();
    try {
      await _userRepository.verifyPhoneNumber(phone);
      yield LoginState.phoneSuccess();
    } catch (_) {
      yield LoginState.failure();
    }
  }


  Stream<LoginState> _mapLoginWithSms({String sms}) async* {
    yield LoginState.loading();
    try {
      if (sms != null) {
         _userRepository.submitSmsCode(sms);
        if (_userRepository.isSignInComplete) {
          yield LoginState.success();
        } else {
          yield LoginState.failure();
        }
      } else {
        yield LoginState.failure();
      }
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInWithCredential(email, password);
      if (_userRepository.user.phoneNumber != null) {
        yield LoginState.success();
      } else {
        yield LoginState.failure();
      }
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapSignUpWithCredentialsPressedToState(
      {String email, String password, String name}) async* {
    yield LoginState.loading();
    try {
      await _userRepository.signUpWithCredential(email, password, name);
      yield LoginState.socialSuccess();
    } catch (_) {
      yield LoginState.failure();
    }
  }
}
