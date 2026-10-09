# Build release e instalacao do APK com sincronizacao pre-configurada

Este documento descreve como gerar um APK **release**, sem usar versao debug,
ja com o servidor de sincronizacao e token embutidos no app. Assim, ao instalar
em um novo device Android, o app ja nasce apontando para o servidor remoto e nao
precisa configurar manualmente a sincronizacao.

Data de referencia: 09/10/2026.

## Configuracao atual de sincronizacao

- Servidor de sync: `http://131.221.236.34:5005`
- IP do servidor: `131.221.236.34`
- Porta do sync: `5005`
- Token de sync:

```text
fd7a297f87be74c7064f1937c32dc3a99f90b54e297acdc3578d4dfa0bb86776
```

O app le esses valores no build atraves de:

- `SELETO_SYNC_BASE_URL`
- `SELETO_SYNC_TOKEN`

No codigo atual, isso fica em:

```text
lib/core/sync/seleto_sync_service.dart
```

## Quando isso funciona automaticamente

Funciona direto quando:

- o APK foi gerado com `--dart-define=SELETO_SYNC_BASE_URL=...`;
- o APK foi gerado com `--dart-define=SELETO_SYNC_TOKEN=...`;
- o device esta instalando o app pela primeira vez; ou
- o device ja tem o app, mas nao tem outra URL/token salvos manualmente nas configuracoes internas.

Importante: se um device ja tiver uma URL/token diferente salvo localmente no app,
o valor salvo no banco/configuracoes locais pode prevalecer. Para device novo, o
valor embutido no APK deve funcionar diretamente.

## Cuidados para nao apagar o banco local

Para atualizar um device que ja tem o app instalado e preservar o banco local:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Nunca use estes comandos se a intencao for preservar o banco local:

```bash
adb uninstall com.seleto.seleto
adb shell pm clear com.seleto.seleto
flutter run
flutter install --debug
adb install -r -d algum-apk-debug.apk
```

O comando `adb install -r` atualiza o APK mantendo os dados do app, incluindo o
banco local e o caminho do banco.

## Conferir device conectado

Antes do build/instalacao, conecte o Android via USB e confira:

```bash
adb devices -l
```

Deve aparecer algo parecido com:

```text
List of devices attached
RXCX2044YZD    device ...
```

Se aparecer `unauthorized`, desbloqueie o celular e aceite a autorizacao USB.

## Build release com sync embutido

Execute na raiz do projeto:

```bash
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=SELETO_SYNC_BASE_URL=http://131.221.236.34:5005 \
  --dart-define=SELETO_SYNC_TOKEN=fd7a297f87be74c7064f1937c32dc3a99f90b54e297acdc3578d4dfa0bb86776
```

O APK final sera gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Instalacao em device novo

Para instalar em um device que ainda nao tem o app:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Atualizacao em device que ja tem banco local

Para atualizar sem remover, alterar, corromper ou mudar o caminho do banco local:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Depois confirme que o app foi atualizado sem apagar dados:

```bash
adb shell dumpsys package com.seleto.seleto | \
  rg "firstInstallTime|lastUpdateTime|dataDir|versionName|versionCode"
```

O esperado:

- `firstInstallTime` deve continuar com a data antiga;
- `lastUpdateTime` deve mudar para a data/hora da atualizacao;
- `dataDir` deve continuar em `/data/user/0/com.seleto.seleto`.

Exemplo:

```text
lastUpdateTime=2026-10-09 13:48:45
dataDir=/data/user/0/com.seleto.seleto
firstInstallTime=2026-10-02 23:25:45
```

## Abrir o app apos instalar

```bash
adb shell monkey -p com.seleto.seleto 1
```

## Validar se o sync esta pre-configurado

No app:

1. Abra `Configuracoes`.
2. Entre na area de sincronizacao.
3. Verifique se o servidor aparece como:

```text
http://131.221.236.34:5005
```

4. O campo de token deve aparecer preenchido/oculto, se houver token salvo ou embutido.
5. Use a validacao de sincronizacao para confirmar conexao com o servidor.

Tambem e possivel validar o servidor por terminal:

```bash
curl -s http://131.221.236.34:5005/health
```

E validar endpoint autenticado:

```bash
SELETO_SYNC_TOKEN='fd7a297f87be74c7064f1937c32dc3a99f90b54e297acdc3578d4dfa0bb86776'

curl -s http://131.221.236.34:5005/sync/v1/health \
  -H "Authorization: Bearer ${SELETO_SYNC_TOKEN}"
```

## Gerar APK e instalar em um unico comando

Para atualizar o device conectado preservando dados:

```bash
flutter build apk --release \
  --dart-define=SELETO_SYNC_BASE_URL=http://131.221.236.34:5005 \
  --dart-define=SELETO_SYNC_TOKEN=fd7a297f87be74c7064f1937c32dc3a99f90b54e297acdc3578d4dfa0bb86776 \
&& adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Sobre a assinatura release atual

O comando acima gera `app-release.apk`, ou seja, build Android do tipo
`release`. No Gradle atual do projeto, o bloco `release` assina usando a
keystore local:

```text
android/signing/seleto-preserve-data-debug.keystore
```

Mesmo com esse nome, o APK gerado por `flutter build apk --release` nao e APK
debug. Ele e build release. Essa keystore foi configurada para preservar a
compatibilidade de assinatura entre instalacoes locais.

Para distribuicao publica, Play Store ou ambiente de producao formal, o ideal e
trocar para uma keystore release propria e protegida. Para instalacao direta nos
devices atuais, mantenha a mesma assinatura para nao quebrar atualizacoes e nao
precisar desinstalar o app.

## Comandos que devem ser evitados

Nao use:

```bash
flutter run
flutter run --debug
flutter build apk --debug
adb uninstall com.seleto.seleto
adb shell pm clear com.seleto.seleto
```

Esses fluxos podem instalar versao debug ou apagar dados locais, dependendo do
comando usado.

## Checklist final

Antes de enviar o APK para outro device:

- Build feito com `flutter build apk --release`.
- Comando incluiu `SELETO_SYNC_BASE_URL`.
- Comando incluiu `SELETO_SYNC_TOKEN`.
- APK usado foi `build/app/outputs/flutter-apk/app-release.apk`.
- Nao foi usado `adb uninstall`.
- Nao foi usado `adb shell pm clear`.
- Em device existente, instalacao feita com `adb install -r`.
- A sincronizacao foi validada dentro do app.

