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
  bool allows(String permission) =>
      isSuperuser ||
      permissions.contains('*') ||
      permissions.contains(permission);
}
