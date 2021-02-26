import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends LoginEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class Submitted extends LoginEvent {
  final String email;
  final String password;

  const Submitted({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}

class LoginWithGooglePressed extends LoginEvent {}

class LoginWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginWithCredentialsPressed({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginWithCredentialsPressed { email: $email, password: $password }';
  }
}

class LoginToPhone extends LoginEvent {
  final String phone;
  LoginToPhone({this.phone});

  List<Object> get props {
    return [phone];
  }
}

class LoginWithSms extends LoginEvent {
  final String sms;

  LoginWithSms({this.sms});

  List<Object> get props => [sms];
}

class SignUpWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;
  final String name;

  SignUpWithCredentialsPressed({
      this.email, this.password, this.name});

  @override
  List<Object> get props => [email, password, name];

  String toString() {
    return 'LoginWithCredentialsPressed { email: $email, password: $password , displayName: $name}';
  }
}
