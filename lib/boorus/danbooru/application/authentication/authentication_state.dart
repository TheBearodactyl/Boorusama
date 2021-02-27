part of 'authentication_state_notifier.dart';

@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    @required @nullable Account account,
    @required AccountState state,
  }) = _AuthenticationState;

  factory AuthenticationState.initial() =>
      AuthenticationState(account: null, state: AccountState.unknown());
}

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState.unknown() = _Unknown;
  const factory AccountState.authenticating() = _Authenticating;
  const factory AccountState.error(ErrorType errorType) = _Error;
  const factory AccountState.loggedIn() = _LoggedIn;
  const factory AccountState.loggedOut() = _LoggedOut;
}

@freezed
abstract class ErrorType with _$ErrorType {
  const factory ErrorType.invalidUsernameOrPassword() =
      _InvalidUsernameOrPassword;
  const factory ErrorType.unknown() = _UnknownError;
}
