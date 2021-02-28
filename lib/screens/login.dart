import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_app/login/authentication_bloc/index.dart';
import 'package:restaurant_app/login/login_bloc/index.dart';
import 'package:restaurant_app/user_repository.dart';
import 'package:restaurant_app/widgets/widgets.dart';

enum AuthStatus { SOCIAL_AUTH, PHONE_AUTH, SMS_AUTH }
enum LoginMode { Home, CreateAccount, Login }

class LoginPage extends StatelessWidget {
  final UserRepository _userRepository;

  LoginPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(userRepository: _userRepository),
        child: LoginScreen(userRepository: _userRepository),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final UserRepository _userRepository;
  LoginScreen({Key key, UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Objects
  LoginBloc _loginBloc;
  UserRepository get userRepository => widget._userRepository;

  //Focus Nodes
  var nameField, emailField, passwordField, cpasswordFiled = FocusNode();

  //FormKey
  final formKey = GlobalKey<FormState>();

  //UI States
  LoginMode mode = LoginMode.Home;
  AuthStatus status = AuthStatus.SOCIAL_AUTH;

  //Controllers
  TextEditingController _smsCodeController,
      _phoneNumberController,
      _emailController,
      _passwordController,
      _nameController = TextEditingController();

  //Variables
  String _email,
      _password,
      cpassword,
      name,
      _phoneNumber,
      _smsNumber,
      _errorMessage;

  //init state
  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  //dispose
  @override
  void dispose() {
    userRepository.codeTimer?.cancel();
    super.dispose();
  }

  //Validator
  String emailValid(String value) {
    RegExp _emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (value.isEmpty) {
      return "Please Enter an email";
    } else {
      if (!_emailRegExp.hasMatch(value)) {
        return "Please enter valid email";
      } else {
        return null;
      }
    }
  }

  String passwordValid(String value) {
    RegExp _passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    );
    if (value.isEmpty) {
      return "Please Enter your password";
    } else {
      if (!_passwordRegExp.hasMatch(value)) {
        return "Please enter valid password";
      } else {
        return null;
      }
    }
  }

  //Login Methods
  //Social Login
  //Sign In/Up with Google
  Future<Null> _signIn() async {
    _loginBloc.add(LoginWithGooglePressed());
  }

  //Sign In with Email and password
  FutureOr<Null> _onLoginSubmitted() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      _loginBloc.add(
        LoginWithCredentialsPressed(
          email: _email,
          password: _password,
        ),
      );
    }
  }

  //Sign Up with Email and  Password
  FutureOr<Null> _onSignUp() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      _loginBloc.add(
        SignUpWithCredentialsPressed(
          email: _email,
          password: _password,
          name: name,
        ),
      );
    }
  }

  //Phone Authentication
  //Verify Phone Number
  FutureOr<Null> _loginByPhone() {
    _loginBloc.add(LoginToPhone(phone: _phoneNumber));
  }

  //SMS Authentication
  //Submit Sms Code
  FutureOr<Null> _loginSms() {
    _loginBloc.add(LoginWithSms(
      sms: _smsNumber,
    ));
  }

  //State Changing Methods
  void mtReg() {
    setState(() {
      mode = LoginMode.CreateAccount;
    });
  }

  void mtLogin() {
    setState(() {
      mode = LoginMode.Login;
    });
  }

  void socialSuccess() {
    setState(() {
      status = AuthStatus.PHONE_AUTH;
    });
  }

  void phoneSucces() {
    setState(() {
      status = AuthStatus.SMS_AUTH;
    });
    Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Waiting for OTP Verification'),
            CircularProgressIndicator(),
          ],
        ),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.yellow[800],
      ));
  }

  //UI decorations
  InputDecoration inputDecoration(lbltext) {
    return new InputDecoration(
      labelText: lbltext,
    );
  }

  BoxDecoration _buildBackground() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      image: DecorationImage(
        image: AssetImage("assets/moin.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }

  //Widgets

  //Login Form for Email and Password
  List<Widget> _buildForm() {
    switch (mode) {
      case LoginMode.Home:
        return [
          SizedBox(height: MediaQuery.of(context).size.height / 65),
          SizedBox(
              width: double.infinity,
              child: LoginAndCreateAccountButton(
                  onPressed: mtReg, text: "Create Account")),
          SizedBox(height: MediaQuery.of(context).size.height / 55),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Already have an account?",
                style: TextStyle(fontSize: 18, color: Colors.black)),
            TextSpan(
                text: "Login",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => mtLogin()),
          ])),
          SizedBox(height: MediaQuery.of(context).size.height / 60),
        ];
      case LoginMode.Login:
        return [
          new TextFormField(
            focusNode: emailField,
            decoration: inputDecoration("Email"),
            validator: emailValid,
            onSaved: (String value) => _email = value,
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) {
              return _email = email;
            },
            onFieldSubmitted: (term) {
              FocusScope.of(context).requestFocus(passwordField);
              return _email = term;
            },
          ),
          new TextFormField(
            focusNode: passwordField,
            decoration: inputDecoration("Password"),
            obscureText: true,
            validator: passwordValid,
            onSaved: (String value) => _password = value,
            onChanged: (password) {
              return _password = password;
            },
            onFieldSubmitted: (term) {
              passwordField.unfocus();
              return _password = term;
            },
          ),
          const SizedBox(height: 7),
          SizedBox(
              width: double.infinity,
              child: LoginAndCreateAccountButton(
                  onPressed: () async {
                    return _onLoginSubmitted();
                  },
                  text: "Login")),
          SizedBox(height: 8),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "New here? ",
                style: TextStyle(fontSize: 18, color: Colors.black)),
            TextSpan(
                text: "Create an account",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
                recognizer: new TapGestureRecognizer()..onTap = () => mtReg()),
          ])),
          SizedBox(
            height: 20,
          ),
        ];
      case LoginMode.CreateAccount:
        return [
          TextFormField(
            focusNode: nameField,
            controller: _nameController,
            decoration: inputDecoration("Name"),
            validator: (value) => value.isEmpty ? "Name can\'t be empty" : null,
            onSaved: (value) => name = value,
            onChanged: (value) => name = value,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (term) {
              FocusScope.of(context).requestFocus(emailField);
              return name = term;
            },
          ),
          new TextFormField(
            focusNode: emailField,
            controller: _emailController,
            decoration: inputDecoration("Email"),
            validator: emailValid,
            onChanged: (value) {
              return _email = value;
            },
            onSaved: (value) => _email = value,
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (term) {
              emailField.unfocus();
              FocusScope.of(context).requestFocus(passwordField);
              return _email = term;
            },
          ),
          new TextFormField(
            focusNode: passwordField,
            controller: _passwordController,
            decoration: inputDecoration("Password"),
            obscureText: true,
            validator: passwordValid,
            onSaved: (String value) => _password = value,
            onChanged: (password) {
              return _password = password;
            },
            onFieldSubmitted: (term) {
              FocusScope.of(context).requestFocus(cpasswordFiled);
              passwordField.unfocus();
              return _password = term;
            },
          ),
          new TextFormField(
            focusNode: cpasswordFiled,
            controller: _passwordController,
            decoration: inputDecoration("Confirm Password"),
            validator: (value) => value.isEmpty
                ? "Password can\'t be empty"
                : value != _password
                    ? "Password does not match"
                    : null,
            obscureText: true,
            onSaved: (String value) => cpassword = value,
            onChanged: (password) {
              return _password = password;
            },
            onFieldSubmitted: (term) {
              cpasswordFiled.unfocus();
              return _password = term;
            },
          ),
          const SizedBox(height: 7),
          SizedBox(
              width: double.infinity,
              child: LoginAndCreateAccountButton(
                  onPressed: () async {
                    return _onSignUp();
                  },
                  /*createAndUpdate*/ text: "Create Account")),
          SizedBox(height: 8),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Already have an account?",
                style: TextStyle(fontSize: 18, color: Colors.black)),
            TextSpan(
                text: "Login",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => mtLogin()),
          ])),
          SizedBox(
            height: 20,
          ),
        ];
    }
    return [];
  }

  //Main Body for Social Login
  Widget _buildSocialLoginBody() {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            margin: EdgeInsets.all(55),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  new Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: new Column(children: [
                        Column(
                          children: <Widget>[
                            Icon(
                              Icons.restaurant_menu,
                              size: 55,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: height / 60,
                            ),
                            Text(
                              "Delicious Cake Shop",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Column(
                              children: _buildForm(),
                            ),
                            GoogleSignInButton(
                              onPressed: () {
                                return _signIn();
                              },
                            ),
                          ],
                        )
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //Phone Authentication Body
  Widget _buildPhoneAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            "We'll send an SMS message to verify your identity, please enter your number right below!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 5,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    controller: _phoneNumberController,
                    maxLength: 10,
                    onSubmitted: (text) {
                      _phoneNumber = text;
                      return _loginByPhone();
                    },
                    onChanged: (value) {
                      _phoneNumber = value;
                      if (value.length == 10) {
                        return _loginByPhone();
                      }
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      labelText: "Phone",
                      errorText: _errorMessage,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  //SMS Authentication Body
  Widget _buildSMSAuthBody() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: Text(
              "Verification code",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 2.0, horizontal: 64.0),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 5,
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      controller: _smsCodeController,
                      maxLength: 6,
                      onSubmitted: (text) {
                        if (text.length == 6) {
                          return _loginSms();
                        }
                        return text = _smsNumber;
                      },
                      onChanged: (value) {
                        return _smsNumber = value;
                      },
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildResendSmsWidget(),
          )
        ],
      ),
    );
  }

  Widget _buildResendSmsWidget() {
    return InkWell(
      onTap: () async {
        if (UserRepository.codeTimedOut) {
          await _loginByPhone();
        } else {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("You can't retry yet!")));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "If your code does not arrive in 1 minute, touch",
            style: TextStyle(color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                text: " here",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Body
  Widget _buildBody() {
    Widget body;
    switch (status) {
      case AuthStatus.SOCIAL_AUTH:
        return body = _buildSocialLoginBody();
        break;
      case AuthStatus.PHONE_AUTH:
        return body = _buildPhoneAuthBody();
        break;
      case AuthStatus.SMS_AUTH:
        return body = _buildSMSAuthBody();
        break;
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Login Failure'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logging In...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSocialSuccess) {
          socialSuccess();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Social Login Successful'), Icon(Icons.done)],
            ),
            backgroundColor: Colors.green,
          ));
        }
        if (state.isPhoneSuccess) {
          phoneSucces();
        }
        if (state.isSuccess) {
          print("success");
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Login Success'), Icon(Icons.done)],
                ),
                backgroundColor: Colors.deepOrange,
                duration: Duration(milliseconds: 1500),
              ),
            );
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        return Container(
          decoration: _buildBackground(),
          child: _buildBody(),
        );
      }),
    );
  }
}
