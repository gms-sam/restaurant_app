import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  /// Copy object for use in action
  /// if need use deep clone

  @override
  List<Object> get props => [];
}

/// UnInitialized
class UnInitializedState extends AuthenticationState {}


class UnAuthenticatedState extends AuthenticationState {}

/// Initialized
class AuthenticatedState extends AuthenticationState {}

 