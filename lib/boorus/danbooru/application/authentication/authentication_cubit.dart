// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/profile/profile_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.accountRepository,
    required this.profileRepository,
  }) : super(AuthenticationInitial());

  final IAccountRepository accountRepository;
  final IProfileRepository profileRepository;

  void logIn([String username = '', String password = '']) async {
    if (state is AuthenticationInitial) {
      final account = await accountRepository.get();
      if (account != Account.empty) {
        emit(Authenticated(account: account));
      } else {
        emit(Unauthenticated());
      }
    } else if (state is Authenticated) {
      // Do nothing
    } else if (state is AuthenticationInProgress) {
      // Do nothing
    } else {
      try {
        emit(AuthenticationInProgress());
        var profile = await profileRepository.getProfile(
            username: username, apiKey: password);
        var account = new Account.create(username, password, profile!.id);

        emit(Authenticated(account: account));
      } on InvalidUsernameOrPassword catch (ex, stack) {
        emit(AuthenticationError(exception: ex, stackTrace: stack));
      } on Exception catch (ex, stack) {
        emit(AuthenticationError(exception: ex, stackTrace: stack));
      }
    }
  }

  void logOut() async {
    emit(Unauthenticated());
  }
}
