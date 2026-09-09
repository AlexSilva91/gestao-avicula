import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/users_controller.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/widgets/seleto_widgets.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).session;
    final tenants =
        ref.watch(tenantsProvider).asData?.value ?? const <Tenant>[];
    final tenantNames = {for (final tenant in tenants) tenant.id: tenant.name};
    return AppShell(
      title: 'Usuários e acessos',
      child: ref
          .watch(usersProvider)
          .when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) =>
                const Text('Não foi possível carregar os usuários.'),
            data: (users) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      '${users.length} usuário(s) · ${session?.tenantName ?? 'Parceria'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (session?.allows('tenants.create') == true)
                      OutlinedButton.icon(
                        onPressed: () => _showCreateTenant(context, ref),
                        icon: const Icon(Icons.business),
                        label: const Text('Nova parceria'),
                      ),
                    FilledButton.icon(
                      onPressed: () => _showCreate(context, ref, tenants),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Novo usuário'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _UsersGrid(
                  users: users,
                  tenantNames: tenantNames,
                  onAction: (user, action) =>
                      _handleUserAction(context, ref, user, action),
                  onDetails: (user) => _showDetails(context, ref, user),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    final tenants = ref.read(tenantsProvider).asData?.value ?? const <Tenant>[];
    final tenantNames = {for (final tenant in tenants) tenant.id: tenant.name};
    final permissions = await ref
        .read(usersControllerProvider)
        .permissions(user);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _UserDetailsDialog(
        user: user,
        tenantName: tenantNames[user.tenantId] ?? 'Parceria padrão',
        permissions: permissions,
      ),
    );
  }

  void _showCreate(BuildContext context, WidgetRef ref, List<Tenant> tenants) =>
      showDialog(
        context: context,
        builder: (_) => _CreateUserDialog(ref: ref, tenants: tenants),
      );

  void _showCreateTenant(BuildContext context, WidgetRef ref) => showDialog(
    context: context,
    builder: (_) => _CreateTenantDialog(ref: ref),
  );

  Future<void> _handleUserAction(
    BuildContext context,
    WidgetRef ref,
    User user,
    String action,
  ) async {
    if (action == 'details') {
      await _showDetails(context, ref, user);
      return;
    }
    if (action == 'edit') {
      final tenants =
          ref.read(tenantsProvider).asData?.value ?? const <Tenant>[];
      await showDialog<void>(
        context: context,
        builder: (_) => _EditUserDialog(ref: ref, user: user, tenants: tenants),
      );
      return;
    }
    if (action == 'permissions') {
      await showDialog<void>(
        context: context,
        builder: (_) => _PermissionsDialog(ref: ref, user: user),
      );
      return;
    }
    if (action == 'password') {
      await showDialog<void>(
        context: context,
        builder: (_) => _ResetPasswordDialog(ref: ref, user: user),
      );
      return;
    }
    try {
      await ref.read(usersControllerProvider).toggle(user);
    } catch (error) {
      await showOperationError(context, error);
    }
  }
}

class _UsersGrid extends StatelessWidget {
  const _UsersGrid({
    required this.users,
    required this.tenantNames,
    required this.onAction,
    required this.onDetails,
  });

  final List<User> users;
  final Map<String, String> tenantNames;
  final void Function(User user, String action) onAction;
  final void Function(User user) onDetails;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1040
          ? 3
          : constraints.maxWidth >= 680
          ? 2
          : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 178,
        ),
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(
            user: user,
            tenantName: tenantNames[user.tenantId] ?? 'Parceria padrão',
            onAction: onAction,
            onDetails: onDetails,
          );
        },
      );
    },
  );
}

class _UserCard extends ConsumerWidget {
  const _UserCard({
    required this.user,
    required this.tenantName,
    required this.onAction,
    required this.onDetails,
  });

  final User user;
  final String tenantName;
  final void Function(User user, String action) onAction;
  final void Function(User user) onDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final permissions = ref
        .watch(userPermissionsProvider(user.id))
        .asData
        ?.value;
    final isSuperAdmin = permissions?.contains('system.super_admin') ?? false;
    final role = _roleLabel(user, permissions);
    final accent = isSuperAdmin
        ? scheme.tertiary
        : user.isSuperuser
        ? scheme.primary
        : scheme.secondary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onDetails(user),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: accent.withValues(alpha: .16),
                    foregroundColor: accent,
                    child: Text(
                      _initials(user.displayName),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Ações do usuário',
                    onSelected: (action) => onAction(user, action),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: ListTile(
                          leading: Icon(Icons.badge_outlined),
                          title: Text('Ver detalhes'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar usuário'),
                        ),
                      ),
                      if (!user.isSuperuser)
                        const PopupMenuItem(
                          value: 'permissions',
                          child: ListTile(
                            leading: Icon(Icons.tune),
                            title: Text('Editar permissões'),
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'password',
                        child: ListTile(
                          leading: Icon(Icons.lock_reset),
                          title: Text('Redefinir senha'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: ListTile(
                          leading: Icon(
                            user.isActive
                                ? Icons.person_off_outlined
                                : Icons.person_outline,
                          ),
                          title: Text(
                            user.isActive
                                ? 'Desativar usuário'
                                : 'Ativar usuário',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _TinyBadge(
                    icon: user.isActive ? Icons.check_circle : Icons.block,
                    label: user.isActive ? 'Ativo' : 'Inativo',
                    color: user.isActive ? scheme.primary : scheme.error,
                  ),
                  _TinyBadge(
                    icon: _roleIcon(user, isSuperAdmin),
                    label: role,
                    color: accent,
                  ),
                ],
              ),
              const Spacer(),
              _CardInfoLine(icon: Icons.business_outlined, text: tenantName),
              const SizedBox(height: 6),
              _CardInfoLine(
                icon: Icons.schedule,
                text: 'Última vez online: ${_formatDateTime(user.lastLoginAt)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: color.withValues(alpha: .22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _CardInfoLine extends StatelessWidget {
  const _CardInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        icon,
        size: 15,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class _UserDetailsDialog extends StatelessWidget {
  const _UserDetailsDialog({
    required this.user,
    required this.tenantName,
    required this.permissions,
  });

  final User user;
  final String tenantName;
  final List<String> permissions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSuperAdmin = permissions.contains('system.super_admin');
    final role = _roleLabel(user, permissions);
    final labels = {
      for (final permission in seletoPermissions)
        permission.key: permission.label,
    };
    final visiblePermissions =
        permissions
            .where((permission) => permission != 'system.super_admin')
            .toList()
          ..sort();
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text(_initials(user.displayName)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                icon: _roleIcon(user, isSuperAdmin),
                label: 'Perfil',
                value: role,
              ),
              _DetailRow(
                icon: Icons.alternate_email,
                label: 'Usuário',
                value: '@${user.username}',
              ),
              _DetailRow(
                icon: Icons.business_outlined,
                label: 'Parceria',
                value: tenantName,
              ),
              _DetailRow(
                icon: user.isActive ? Icons.check_circle : Icons.block,
                label: 'Status',
                value: user.isActive ? 'Ativo' : 'Inativo',
              ),
              _DetailRow(
                icon: Icons.login,
                label: 'Última vez online',
                value: _formatDateTime(user.lastLoginAt),
              ),
              _DetailRow(
                icon: Icons.event_available,
                label: 'Criado em',
                value: _formatDateTime(user.createdAt),
              ),
              _DetailRow(
                icon: Icons.update,
                label: 'Atualizado em',
                value: _formatDateTime(user.updatedAt),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Permissões',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (user.isSuperuser)
                      _TinyBadge(
                        icon: Icons.all_inclusive,
                        label: isSuperAdmin
                            ? 'Todas as parcerias'
                            : 'Todas da granja',
                        color: scheme.primary,
                      )
                    else if (visiblePermissions.isEmpty)
                      _TinyBadge(
                        icon: Icons.lock_outline,
                        label: 'Nenhuma',
                        color: scheme.outline,
                      )
                    else
                      for (final permission in visiblePermissions)
                        _TinyBadge(
                          icon: Icons.key,
                          label: labels[permission] ?? permission,
                          color: scheme.secondary,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog({required this.ref, required this.tenants});
  final WidgetRef ref;
  final List<Tenant> tenants;
  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _admin = false;
  final Set<String> _permissions = {'dashboard.view'};
  late String? _tenantId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tenantId = widget.ref.read(authControllerProvider).session?.tenantId;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = _grantablePermissions(widget.ref);
    return AlertDialog(
      title: const Text('Novo usuário'),
      content: SizedBox(
        width: 410,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nome de exibição',
                  ),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Informe o nome.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                  validator: (value) => (value?.trim().length ?? 0) < 3
                      ? 'Mínimo de 3 caracteres.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha inicial'),
                  validator: (value) => (value?.length ?? 0) < 8
                      ? 'Mínimo de 8 caracteres.'
                      : null,
                ),
                if (widget.tenants.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue:
                        widget.tenants.any((tenant) => tenant.id == _tenantId)
                        ? _tenantId
                        : widget.tenants.first.id,
                    decoration: const InputDecoration(labelText: 'Parceria'),
                    items: [
                      for (final tenant in widget.tenants)
                        DropdownMenuItem(
                          value: tenant.id,
                          child: Text(tenant.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _tenantId = value),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Administrador'),
                  subtitle: const Text('Gerencia somente a própria granja'),
                  value: _admin,
                  onChanged: (value) => setState(() => _admin = value),
                ),
                if (!_admin)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text('Permissões (${_permissions.length})'),
                    children: [
                      for (final permission in permissions)
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(permission.label),
                          subtitle: Text(permission.group),
                          value: _permissions.contains(permission.key),
                          onChanged: (checked) => setState(
                            () => checked == true
                                ? _permissions.add(permission.key)
                                : _permissions.remove(permission.key),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Criar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await widget.ref
          .read(usersControllerProvider)
          .create(
            username: _username.text,
            displayName: _name.text,
            password: _password.text,
            superuser: _admin,
            permissions: _admin ? ['*'] : _permissions.toList(),
            tenantId: _tenantId,
          );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({
    required this.ref,
    required this.user,
    required this.tenants,
  });
  final WidgetRef ref;
  final User user;
  final List<Tenant> tenants;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late bool _active;
  late String _tenantId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.displayName);
    _username = TextEditingController(text: widget.user.username);
    _active = widget.user.isActive;
    _tenantId = widget.user.tenantId;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Editar usuário · ${widget.user.displayName}'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome de exibição'),
              validator: (value) =>
                  value!.trim().isEmpty ? 'Informe o nome.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Usuário'),
              validator: (value) => (value?.trim().length ?? 0) < 3
                  ? 'Mínimo de 3 caracteres.'
                  : null,
            ),
            if (widget.tenants.isNotEmpty &&
                (widget.ref
                        .read(authControllerProvider)
                        .session
                        ?.allows('tenant.view_all') ??
                    false)) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue:
                    widget.tenants.any((tenant) => tenant.id == _tenantId)
                    ? _tenantId
                    : widget.tenants.first.id,
                decoration: const InputDecoration(labelText: 'Parceria'),
                items: [
                  for (final tenant in widget.tenants)
                    DropdownMenuItem(
                      value: tenant.id,
                      child: Text(tenant.name),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _tenantId = value ?? widget.user.tenantId),
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Conta ativa'),
              subtitle: const Text('Usuários inativos não conseguem entrar'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _loading ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _loading ? null : _save,
        child: _loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Salvar'),
      ),
    ],
  );

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await widget.ref
          .read(usersControllerProvider)
          .update(
            user: widget.user,
            username: _username.text,
            displayName: _name.text,
            isActive: _active,
            tenantId: _tenantId,
          );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _CreateTenantDialog extends StatefulWidget {
  const _CreateTenantDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreateTenantDialog> createState() => _CreateTenantDialogState();
}

class _CreateTenantDialogState extends State<_CreateTenantDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nova parceria'),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'Nome da parceria'),
        validator: (value) =>
            (value?.trim().length ?? 0) < 3 ? 'Mínimo de 3 caracteres.' : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: _loading ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _loading ? null : _save,
        child: _loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Criar'),
      ),
    ],
  );

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await widget.ref.read(usersControllerProvider).createTenant(_name.text);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showOperationError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _PermissionsDialog extends StatefulWidget {
  const _PermissionsDialog({required this.ref, required this.user});
  final WidgetRef ref;
  final User user;
  @override
  State<_PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<_PermissionsDialog> {
  final selected = <String>{};
  bool loading = true;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    widget.ref.read(usersControllerProvider).permissions(widget.user).then((
      items,
    ) {
      if (mounted) {
        setState(() {
          selected.addAll(items);
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissions = _grantablePermissions(widget.ref);
    selected.removeWhere(
      (permission) => !permissions.any((item) => item.key == permission),
    );
    return AlertDialog(
      title: Text('Permissões · ${widget.user.displayName}'),
      content: SizedBox(
        width: 520,
        height: 520,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  for (final group
                      in permissions.map((p) => p.group).toSet()) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
                      child: Text(
                        group,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    for (final p in permissions.where((p) => p.group == group))
                      CheckboxListTile(
                        dense: true,
                        title: Text(p.label),
                        subtitle: Text(p.key),
                        value: selected.contains(p.key),
                        onChanged: (v) => setState(
                          () => v == true
                              ? selected.add(p.key)
                              : selected.remove(p.key),
                        ),
                      ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    await widget.ref
                        .read(usersControllerProvider)
                        .savePermissions(widget.user, selected.toList());
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    await showOperationError(context, e);
                    if (mounted) setState(() => saving = false);
                  }
                },
          child: const Text('Salvar acessos'),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  final first = parts.first.characters.first;
  final second = parts.length > 1 ? parts.last.characters.first : '';
  return (first + second).toUpperCase();
}

String _roleLabel(User user, List<String>? permissions) {
  if (permissions?.contains('system.super_admin') == true) return 'Super Admin';
  if (user.isSuperuser) return 'Admin da granja';
  return 'Usuário';
}

IconData _roleIcon(User user, bool isSuperAdmin) {
  if (isSuperAdmin) return Icons.verified_user;
  if (user.isSuperuser) return Icons.admin_panel_settings;
  return Icons.person_outline;
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'Nunca acessou';
  return '${shortDate.format(value)} às ${shortTime.format(value)}';
}

List<SeletoPermission> _grantablePermissions(WidgetRef ref) {
  final session = ref.read(authControllerProvider).session;
  if (session?.isSuperAdmin == true) return seletoPermissions;
  return seletoPermissions
      .where((permission) => !_globalPermissionKeys.contains(permission.key))
      .toList(growable: false);
}

const _globalPermissionKeys = {'tenant.view_all', 'tenants.create'};

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.ref, required this.user});
  final WidgetRef ref;
  final User user;
  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final password = TextEditingController();
  bool hidden = true;
  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Redefinir senha · ${widget.user.displayName}'),
    content: TextField(
      controller: password,
      obscureText: hidden,
      decoration: InputDecoration(
        labelText: 'Nova senha',
        helperText: 'Mínimo de 8 caracteres',
        suffixIcon: IconButton(
          onPressed: () => setState(() => hidden = !hidden),
          icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          try {
            await widget.ref
                .read(usersControllerProvider)
                .resetPassword(widget.user, password.text);
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            await showOperationError(context, e);
          }
        },
        child: const Text('Redefinir'),
      ),
    ],
  );
}
