import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../auth/application/auth_controller.dart';

final usersProvider = StreamProvider<List<User>>(
  (ref) => ref.watch(databaseProvider).watchUsers(),
);

class UsersController {
  UsersController(this.ref);
  final Ref ref;
  Future<void> create({
    required String username,
    required String displayName,
    required String password,
    required bool superuser,
    required List<String> permissions,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.create')) {
      throw StateError('Você não tem permissão para criar usuários.');
    }
    await ref
        .read(databaseProvider)
        .createUser(
          username: username,
          displayName: displayName,
          password: password,
          isSuperuser: superuser,
          permissions: permissions,
          actorId: session.userId,
        );
  }

  Future<void> toggle(User user) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.update')) {
      throw StateError('Você não tem permissão para alterar usuários.');
    }
    if (user.id == session.userId) {
      throw StateError('Não é possível desativar sua própria conta.');
    }
    await ref
        .read(databaseProvider)
        .setUserActive(
          userId: user.id,
          isActive: !user.isActive,
          actorId: session.userId,
        );
  }

  Future<List<String>> permissions(User user) =>
      ref.read(databaseProvider).permissionsOf(user.id);
  Future<void> savePermissions(User user, List<String> permissions) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.permissions')) {
      throw StateError('Você não tem permissão para alterar acessos.');
    }
    await ref
        .read(databaseProvider)
        .replaceUserPermissions(
          userId: user.id,
          permissions: permissions,
          actorId: session.userId,
        );
  }

  Future<void> resetPassword(User user, String password) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.update')) {
      throw StateError('Você não tem permissão para redefinir senhas.');
    }
    await ref
        .read(databaseProvider)
        .resetUserPassword(
          userId: user.id,
          password: password,
          actorId: session.userId,
        );
  }
}

final usersControllerProvider = Provider(UsersController.new);
