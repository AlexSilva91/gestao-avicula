# SELETO — Gestão Avícola

Aplicação Flutter mobile-first para gestão avícola local e offline. O alvo de
produção é Android; Flutter Web é suportado para desenvolvimento e validação
visual no navegador.

## Funcionalidades disponíveis

- Autenticação local com senha com hash, criação da primeira conta administradora e auditoria de login.
- Gestão offline de usuários, ativação/desativação e permissões RBAC.
- Dashboard responsivo com indicadores do plantel.
- Lotes com compra atômica, saldo derivado de movimentações, venda,
  mortalidade e ajustes de saída.
- Cálculo de idade, nascimento estimado e fase alimentar (Cria a Produção III).
- Coleta diária de ovos por lote, perdas, estoque derivado de movimentações e
  indicadores de coleta/estoque no dashboard.

## Executar

Por segurança, rode o app com banco persistente quando estiver testando dados
que não devem ser apagados:

```bash
flutter pub get
flutter run -d chrome --dart-define=SELETO_PERSIST_DB=true
```

Para Android:

```bash
flutter run -d android --dart-define=SELETO_PERSIST_DB=true
```

No primeiro acesso, a tela de login permite criar a conta administradora. Depois
disso, novos usuários devem ser cadastrados pelo módulo `Usuários`.

## Banco Local

O SELETO usa SQLite local via Drift. Em Android, o banco persistente de produção
é `seleto.sqlite`, armazenado no diretório de suporte do aplicativo.

Para evitar perda de dados, use sempre `SELETO_PERSIST_DB=true` ao rodar ou
gerar APK para uso real:

```bash
flutter run -d android --dart-define=SELETO_PERSIST_DB=true
flutter build apk --release --dart-define=SELETO_PERSIST_DB=true
```

Modos de teste:

- `SELETO_RESET_DB=true`: apaga o banco de execução ao iniciar.
- `SELETO_DEMO_DB=true`: abre um banco descartável e popula dados demo.
- `SELETO_TEST_DB=true`: usa o banco `seleto_teste.sqlite`.

Nunca gere APK para uso real com `SELETO_RESET_DB=true` ou `SELETO_DEMO_DB=true`.
Esses modos são apenas para desenvolvimento, validação visual e testes.

## Qualidade

```bash
dart format .
flutter analyze
flutter test
flutter build web
```

O banco usa Drift com índices para as consultas operacionais mais frequentes e
mantém a infraestrutura local independente das regras de domínio.
