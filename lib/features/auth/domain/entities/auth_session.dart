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
    if (permissions.contains(permission) || permissions.contains('*')) {
      return true;
    }
    if (_legacyPermissionAliases[permission]?.any(permissions.contains) ==
        true) {
      return true;
    }
    return permissions.contains(permission) ||
        isSuperuser ||
        permissions.contains('*');
  }
}

const _globalPermissions = {'tenant.view_all', 'tenants.create'};

const _legacyPermissionAliases = <String, List<String>>{
  'finance.business.view': ['finance.view'],
  'finance.personal.view': ['finance.view'],
  'hardware.automation.view': ['settings.view'],
  'hardware.lighting.view': ['settings.view', 'lighting.view'],
  'hardware.environment.view': ['settings.view'],
  'hardware.ventilation.view': ['settings.view'],
  'hardware.water.view': ['settings.view'],
  'hardware.cameras.view': ['settings.view'],
};
