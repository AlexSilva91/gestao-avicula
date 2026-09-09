class AuthSession {
  const AuthSession({
    required this.userId,
    required this.tenantId,
    required this.tenantName,
    required this.displayName,
    required this.isSuperuser,
    required this.permissions,
  });
  final String userId;
  final String tenantId;
  final String tenantName;
  final String displayName;
  final bool isSuperuser;
  final Set<String> permissions;
  bool get isSuperAdmin => permissions.contains('system.super_admin');

  bool allows(String permission) {
    if (_globalPermissions.contains(permission)) return isSuperAdmin;
    return permissions.contains(permission) ||
        isSuperuser ||
        permissions.contains('*');
  }
}

const _globalPermissions = {'tenant.view_all', 'tenants.create'};
