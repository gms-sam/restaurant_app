import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import 'package:restaurant_app/model/state.dart';

class UserRepository {
  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  String errorMessage;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  User user;
  Timer codeTimer;
  static bool codeTimedOut = false;
  Duration timeOut = const Duration(seconds: 0);
  bool codeVerified = false;
  bool isSignInComplete = false;
  String verificationId;
  static String displayName;
  bool checkUser;

  Future<void> updateUser(name) async {
    user.updateProfile(displayName: name);
    user.reload();
    _firebaseAuth.currentUser;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      'name': user.displayName,
      'email': user.email,
      'phone': user.phoneNumber,
      'address': null,
      'favorites': [],
      'All Orders': []
    });
  }

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    user = (await _firebaseAuth.signInWithCredential(credential)).user;
    return _firebaseAuth.currentUser;
  }

  Future<void> signInWithCredential(email, password) async {
    try {
      user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      return user;
    } catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "The Email you entered is invalid";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "The password you entered is incorrect";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User not found";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User is disabled";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests! Please try again later";
          break;
        default:
          errorMessage = "Unknown error occured";
      }
    }
    user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signUpWithCredential(email, password, name) async {
    displayName = name;
    try {
      user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      _firebaseAuth.currentUser;
      return user;
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Please enter a correct email address";
          break;
        case "ERROR_WEAK_PASSWORD":
          errorMessage = "The Password is too weak";
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          errorMessage = "Email already in use";
          break;
        default:
          errorMessage = "Unknown error occured";
      }
    }
    return isSignedIn();
  }

  Future<void> signOut() async {
    AppState.cart = [];
    AppState.cartwithName = [];
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'All Orders': AppState.orders});
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      user = null,
    ]);
  }

  bool isSignedIn() {
    user = _firebaseAuth.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  User getUser() {
    user = _firebaseAuth.currentUser;
    return user;
  }

  String getdisplayName() {
    return (_firebaseAuth.currentUser).displayName;
  }

  codeSent(String verificationId, [int forceResendingToken]) async {
    codeTimer = Timer(timeOut, () {
      codeTimedOut = true;
    });
    this.verificationId = verificationId;
  }

  codeAutoRetrievalTimeout(String verificationId) {
    this.verificationId = verificationId;
    codeTimedOut = true;
    user.reload();
    return updateUser(displayName);
  }

  Future<bool> onCodeVerified(User user) async {
    final isUserValid = (user != null &&
        (user.phoneNumber != null && user.phoneNumber.isNotEmpty));
    if (isUserValid) {
      return isUserValid;
    } else {
      print("We couldn't verify your code, please try again!");
    }
    return isUserValid;
  }

  Future<Null> verifyPhoneNumber(number) async {
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91$number",
        timeout: timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: linkWithPhoneNumber,
        verificationFailed: verificationFailed);
    return null;
  }

  Future<void> linkWithPhoneNumber(AuthCredential credential) async {
    final errorMessage = "We couldn't verify your code, please try again!";
    final result =
        await user.linkWithCredential(credential).catchError((error) {
      print(error);
    });
    user.reload();
    user = result.user;
    updateUser(displayName);
    await onCodeVerified(user).then((codeVerified) async {
      this.codeVerified = codeVerified;
      if (this.codeVerified) {
        await finishSignIn(user);
      } else {
        print(errorMessage);
      }
    });
  }

  void submitSmsCode(sms) async {
    if (this.codeVerified) {
      await finishSignIn(_firebaseAuth.currentUser);
    } else {
      await linkWithPhoneNumber(
        PhoneAuthProvider.credential(
          smsCode: sms,
          verificationId: verificationId,
        ),
      );
    }
    return null;
  }

  finishSignIn(User user) async {
    await onCodeVerified(user).then((result) {
      if (result) {
        isSignInComplete = true;
      } else {
        print(
            "We couldn't create your profile for now, please try again later");
      }
    });
  }

  verificationFailed(FirebaseAuthException authException) {
    print("We couldn't verify your code for now, please try again!");
  }
}
