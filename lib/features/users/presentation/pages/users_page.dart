import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../../../core/database/app_database.dart';
import '../../application/users_controller.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/widgets/seleto_widgets.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppShell(
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
          error: (_, _) => const Text('Não foi possível carregar os usuários.'),
          data: (users) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showCreate(context, ref),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Novo usuário'),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final user = users[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          user.displayName.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      title: Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '@${user.username} · ${user.isActive ? 'Ativo' : 'Inativo'}${user.isSuperuser ? ' · Administrador' : ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Ações do usuário',
                        onSelected: (action) =>
                            _handleUserAction(context, ref, user, action),
                        itemBuilder: (_) => [
                          if (!user.isSuperuser)
                            const PopupMenuItem(
                              value: 'permissions',
                              child: Text('Editar permissões'),
                            ),
                          const PopupMenuItem(
                            value: 'password',
                            child: Text('Redefinir senha'),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              user.isActive
                                  ? 'Desativar usuário'
                                  : 'Ativar usuário',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
  );
  void _showCreate(BuildContext context, WidgetRef ref) => showDialog(
    context: context,
    builder: (_) => _CreateUserDialog(ref: ref),
  );
  Future<void> _handleUserAction(
    BuildContext context,
    WidgetRef ref,
    User user,
    String action,
  ) async {
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

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog({required this.ref});
  final WidgetRef ref;
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
  bool _loading = false;
  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
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
                validator: (value) =>
                    (value?.length ?? 0) < 8 ? 'Mínimo de 8 caracteres.' : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Administrador'),
                subtitle: const Text('Acesso integral ao sistema'),
                value: _admin,
                onChanged: (value) => setState(() => _admin = value),
              ),
              if (!_admin)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('Permissões (${_permissions.length})'),
                  children: [
                    for (final permission in seletoPermissions)
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
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Permissões · ${widget.user.displayName}'),
    content: SizedBox(
      width: 520,
      height: 520,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final group
                    in seletoPermissions.map((p) => p.group).toSet()) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
                    child: Text(
                      group,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  for (final p in seletoPermissions.where(
                    (p) => p.group == group,
                  ))
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
