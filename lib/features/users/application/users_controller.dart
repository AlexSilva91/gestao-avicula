import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/entities/auth_session.dart';

final usersProvider = StreamProvider<List<User>>((ref) {
  final session = ref.watch(authControllerProvider).session;
  final tenantId = session?.allows('tenant.view_all') == true
      ? null
      : session?.tenantId;
  return ref.watch(databaseProvider).watchUsers(tenantId: tenantId);
});

final tenantsProvider = StreamProvider<List<Tenant>>((ref) {
  final session = ref.watch(authControllerProvider).session;
  final source = ref.watch(databaseProvider).watchTenants();
  if (session?.allows('tenant.view_all') == true) return source;
  return source.map(
    (tenants) => tenants
        .where((tenant) => tenant.id == session?.tenantId)
        .toList(growable: false),
  );
});

const _globalPermissions = {
  'system.super_admin',
  'tenant.view_all',
  'tenants.create',
};

class UsersController {
  UsersController(this.ref);
  final Ref ref;
  Future<void> create({
    required String username,
    required String displayName,
    required String password,
    required bool superuser,
    required List<String> permissions,
    String? tenantId,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.create')) {
      throw StateError('Você não tem permissão para criar usuários.');
    }
    final resolvedTenantId = tenantId ?? session.tenantId;
    if (resolvedTenantId != session.tenantId &&
        !session.allows('tenant.view_all')) {
      throw StateError('Você não pode criar usuários em outra parceria.');
    }
    _assertGrantablePermissions(session, permissions);
    await ref
        .read(databaseProvider)
        .createUser(
          username: username,
          displayName: displayName,
          password: password,
          isSuperuser: superuser,
          permissions: permissions,
          actorId: session.userId,
          tenantId: resolvedTenantId,
        );
  }

  Future<void> createTenant(String name) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('tenants.create')) {
      throw StateError('Você não tem permissão para criar parcerias.');
    }
    await ref
        .read(databaseProvider)
        .createTenant(name: name, actorId: session.userId);
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

  Future<void> update({
    required User user,
    required String username,
    required String displayName,
    required bool isActive,
    String? tenantId,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.update')) {
      throw StateError('Você não tem permissão para alterar usuários.');
    }
    if (user.id == session.userId && !isActive) {
      throw StateError('Não é possível desativar sua própria conta.');
    }
    if (user.tenantId != session.tenantId &&
        !session.allows('tenant.view_all')) {
      throw StateError('Você não pode alterar usuários de outra parceria.');
    }
    if (tenantId != null &&
        tenantId != user.tenantId &&
        !session.allows('tenant.view_all')) {
      throw StateError('Você não pode mover usuários entre parcerias.');
    }
    await ref
        .read(databaseProvider)
        .updateUserProfile(
          userId: user.id,
          username: username,
          displayName: displayName,
          isActive: isActive,
          actorId: session.userId,
          tenantId: tenantId,
        );
  }

  Future<List<String>> permissions(User user) =>
      ref.read(databaseProvider).permissionsOf(user.id);
  Future<void> savePermissions(User user, List<String> permissions) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || !session.allows('users.permissions')) {
      throw StateError('Você não tem permissão para alterar acessos.');
    }
    if (user.tenantId != session.tenantId &&
        !session.allows('tenant.view_all')) {
      throw StateError('Você não pode alterar acessos de outra parceria.');
    }
    _assertGrantablePermissions(session, permissions);
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
    if (user.tenantId != session.tenantId &&
        !session.allows('tenant.view_all')) {
      throw StateError('Você não pode redefinir senha de outra parceria.');
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

void _assertGrantablePermissions(
  AuthSession session,
  List<String> permissions,
) {
  if (session.isSuperAdmin) return;
  if (permissions.any(_globalPermissions.contains)) {
    throw StateError(
      'Apenas o Super Admin pode liberar permissões globais de parceria.',
    );
  }
}
