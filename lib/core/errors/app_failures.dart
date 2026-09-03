sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure(super.message);
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message);
}
