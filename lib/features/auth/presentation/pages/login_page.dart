import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../application/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _displayName = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  late final Future<bool> _hasUsers = ref
      .read(authControllerProvider)
      .hasUsers();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _creatingFirstAccount = false;
  bool _rememberLogin = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  @override
  void dispose() {
    _username.dispose();
    _displayName.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final form = FutureBuilder<bool>(
      future: _hasUsers,
      builder: (context, snapshot) {
        return _LoginForm(
          formKey: _formKey,
          username: _username,
          displayName: _displayName,
          password: _password,
          confirmPassword: _confirmPassword,
          creatingFirstAccount: _creatingFirstAccount,
          checkingAccounts: snapshot.connectionState != ConnectionState.done,
          obscure: _obscure,
          obscureConfirm: _obscureConfirm,
          loading: auth.isLoading,
          error: auth.error,
          notice: auth.notice,
          rememberLogin: _rememberLogin,
          onVisibility: () => setState(() => _obscure = !_obscure),
          onConfirmVisibility: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onRememberLoginChanged: (value) =>
              setState(() => _rememberLogin = value),
          onCreateAccount: _openCreateAccount,
          onBackToLogin: _backToLogin,
          onSubmit: _submit,
        );
      },
    );
    return Scaffold(
      body: SeletoAppBackground(
        imagePath: 'assets/images/backgrounds/bg_caipira_orange_yolk.png',
        alignment: Alignment.centerRight,
        topOpacity: .64,
        bottomOpacity: .84,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(SeletoTokens.spacingLg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SeletoTokens.formMaxWidth,
                  ),
                  child: _LoginFormSurface(child: form),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(authControllerProvider);
    final authenticated = _creatingFirstAccount
        ? await controller.createAccount(
            username: _username.text,
            displayName: _displayName.text,
            password: _password.text,
            rememberLogin: _rememberLogin,
          )
        : await controller.signIn(
            _username.text,
            _password.text,
            rememberLogin: _rememberLogin,
          );
    if (authenticated && mounted) context.go('/dashboard');
  }

  Future<void> _loadRememberedLogin() async {
    final username = await ref
        .read(authControllerProvider)
        .rememberedUsername();
    if (!mounted || username == null || username.isEmpty) return;
    setState(() {
      if (_username.text.trim().isEmpty) _username.text = username;
      _rememberLogin = true;
    });
  }

  Future<void> _openCreateAccount() async {
    await _hasUsers;
    if (!mounted) return;
    setState(() {
      _creatingFirstAccount = true;
      _password.clear();
      _confirmPassword.clear();
    });
  }

  void _backToLogin() {
    setState(() {
      _creatingFirstAccount = false;
      _displayName.clear();
      _confirmPassword.clear();
    });
  }
}

class _LoginFormSurface extends StatelessWidget {
  const _LoginFormSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: .72),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(SeletoTokens.spacingLg),
      child: child,
    ),
  );
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.username,
    required this.displayName,
    required this.password,
    required this.confirmPassword,
    required this.creatingFirstAccount,
    required this.checkingAccounts,
    required this.obscure,
    required this.obscureConfirm,
    required this.loading,
    required this.error,
    required this.notice,
    required this.rememberLogin,
    required this.onVisibility,
    required this.onConfirmVisibility,
    required this.onRememberLoginChanged,
    required this.onCreateAccount,
    required this.onBackToLogin,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController displayName;
  final TextEditingController password;
  final TextEditingController confirmPassword;
  final bool creatingFirstAccount, checkingAccounts;
  final bool obscure, obscureConfirm, loading;
  final bool rememberLogin;
  final String? error;
  final String? notice;
  final VoidCallback onVisibility;
  final VoidCallback onConfirmVisibility;
  final ValueChanged<bool> onRememberLoginChanged;
  final Future<void> Function() onCreateAccount;
  final VoidCallback onBackToLogin;
  final Future<void> Function() onSubmit;
  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BrandMark(),
        const SizedBox(height: 38),
        Text(
          creatingFirstAccount ? 'Criar conta' : 'Bem-vindo de volta',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          creatingFirstAccount
              ? 'Informe seus dados. A primeira conta entra como administradora; as próximas aguardam ativação.'
              : 'Acesse sua operação e mantenha cada etapa sob controle.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: username,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Usuário',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) =>
              (value?.trim().isEmpty ?? true) ? 'Informe o usuário.' : null,
        ),
        if (creatingFirstAccount) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: displayName,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nome do administrador',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? 'Informe o nome do administrador.'
                : null,
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: password,
          obscureText: obscure,
          textInputAction: creatingFirstAccount
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (!creatingFirstAccount) onSubmit();
          },
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: onVisibility,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
            ),
          ),
          validator: (value) => (value?.isEmpty ?? true)
              ? 'Informe a senha.'
              : creatingFirstAccount && value!.length < 8
              ? 'Use uma senha de ao menos 8 caracteres.'
              : null,
        ),
        if (creatingFirstAccount) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmPassword,
            obscureText: obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(
                onPressed: onConfirmVisibility,
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: obscureConfirm ? 'Mostrar senha' : 'Ocultar senha',
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Confirme a senha.';
              if (value != password.text) return 'As senhas não conferem.';
              return null;
            },
          ),
        ],
        const SizedBox(height: 8),
        Material(
          type: MaterialType.transparency,
          child: CheckboxListTile(
            value: rememberLogin,
            onChanged: loading
                ? null
                : (value) => onRememberLoginChanged(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Manter conectado neste dispositivo'),
            subtitle: Text(
              'Na próxima abertura, o app entra direto se este usuário ainda estiver ativo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _AuthMessage(
              message: error!,
              icon: Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              background: Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: .28),
            ),
          ),
        if (notice != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _AuthMessage(
              message: notice!,
              icon: Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              background: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: .34),
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: loading || checkingAccounts ? null : onSubmit,
          icon: loading || checkingAccounts
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  creatingFirstAccount
                      ? Icons.person_add_alt_1_rounded
                      : Icons.login_rounded,
                ),
          label: Text(
            checkingAccounts
                ? 'Verificando...'
                : loading
                ? creatingFirstAccount
                      ? 'Criando...'
                      : 'Entrando...'
                : creatingFirstAccount
                ? 'Criar conta'
                : 'Entrar',
          ),
        ),
        const SizedBox(height: 18),
        if (creatingFirstAccount)
          TextButton(
            onPressed: loading ? null : onBackToLogin,
            child: const Text('Já tenho conta. Voltar para o login'),
          )
        else
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(
                'Ainda não tem conta?',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: loading || checkingAccounts ? null : onCreateAccount,
                child: const Text('Criar conta'),
              ),
            ],
          ),
        if (creatingFirstAccount) ...[
          const SizedBox(height: 8),
          Text(
            'Depois de criar, use o login normalmente quando sua conta estiver ativa.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    ),
  );
}

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
  });
  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: .28)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}
