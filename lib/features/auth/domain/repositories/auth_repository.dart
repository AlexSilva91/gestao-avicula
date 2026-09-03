import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signIn(String username, String password);
  Future<void> signOut();
}
