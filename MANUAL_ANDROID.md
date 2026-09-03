# Manual Android - SELETO

Este manual mostra como testar o SELETO em um celular Android, gerar APK instalável, validar a logo oficial, importar dados iniciais e testar backup e alertas locais.

## 1. Requisitos

Na raiz do projeto:

```bash
cd /home/alex-da-silva-alves/Python/GRANJA_SELETO
flutter doctor -v
flutter pub get
```

Confirme no `flutter doctor -v` que estão funcionando:

- Flutter
- Android toolchain / Android SDK
- Android Studio ou SDK configurado
- Connected device, quando o celular estiver conectado

Se o Drift precisar regenerar arquivos depois de mudanças no banco:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 2. Logo oficial

A logo oficial do app é:

```text
SELETO_LOGO.png
```

Ela já está declarada em `pubspec.yaml` e é usada na tela inicial, login, shell do app e ícone Android. Sempre que trocar essa imagem, regenere os ícones Android antes de gerar APK:

```bash
python3 scripts/generate_android_icons.py
```

Depois confira se os arquivos abaixo foram atualizados:

```text
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

## 3. Preparar o celular para depuração

No celular Android:

1. Abra `Configurações`.
2. Entre em `Sobre o telefone`.
3. Toque várias vezes em `Número da versão` até ativar o modo desenvolvedor.
4. Volte para `Configurações`.
5. Entre em `Opções do desenvolvedor`.
6. Ative `Depuração USB`.
7. Conecte o celular no computador por cabo USB.
8. Autorize a depuração USB quando o Android pedir.

No computador:

```bash
flutter devices
adb devices
```

Se aparecer `unauthorized`, desbloqueie a tela do celular e aceite a chave de depuração.

## 4. Rodar no celular para testar

Use a flag de banco persistente para os dados continuarem no aparelho:

```bash
flutter run -d android --dart-define=SELETO_PERSIST_DB=true
```

Se houver mais de um dispositivo:

```bash
flutter devices
flutter run -d ID_DO_DISPOSITIVO --dart-define=SELETO_PERSIST_DB=true
```

Durante o teste:

- `r`: hot reload
- `R`: hot restart
- `q`: sair

Para testar próximo do APK final:

```bash
flutter run --release -d android --dart-define=SELETO_PERSIST_DB=true
```

## 5. Banco local

O SELETO usa SQLite local no aparelho. Para uso real ou teste persistente, rode e gere APK sempre com:

```bash
--dart-define=SELETO_PERSIST_DB=true
```

Evite em APK real:

- `SELETO_RESET_DB=true`: apaga o banco ao iniciar.
- `SELETO_DEMO_DB=true`: usa banco descartável e dados de demonstração.
- `SELETO_TEST_DB=true`: usa banco separado de teste.

## 6. Primeiro acesso

Ao abrir pela primeira vez, toque em `Criar conta` e cadastre a conta administradora.

A primeira conta recebe acesso total. Depois disso, novos usuários devem ser criados ou ativados pelo módulo `Usuários`.

## 7. Importar dados iniciais

A importação só fica disponível depois do login, em:

```text
Configurações > Backup e exportação > Importar dados iniciais
```

Formatos aceitos:

- JSON
- CSV
- XML
- XLSX
- XLSL, caso o arquivo tenha essa extensão

A importação preserva:

- usuários
- senhas
- permissões
- auditoria

Mesmo que um arquivo JSON tente enviar `users`, `userPermissions` ou `auditLogs`, essas seções são removidas antes de restaurar os dados operacionais.

As seções operacionais aceitas incluem, entre outras:

```text
lots, birdMovements, eggCollections, eggStockMovements,
ingredients, prices, formulas, formulaItems,
feedBatches, feedBatchItems, feedStock, feedings,
customers, orders, orderItems, sales, finance,
investments, lightingPrograms, lightingSteps,
lotLighting, calendarEvents, notificationSettings, appSettings
```

CSV pode ter uma coluna `section`, `table` ou `tabela`. Sem essa coluna, o nome do arquivo deve indicar a seção, por exemplo:

```text
lotes.csv
financeiro.csv
eventos.csv
programas_luz.csv
```

XML deve agrupar linhas por seção:

```xml
<seleto>
  <lotes>
    <item name="Lote A" initialQuantity="100" receivedAt="2026-09-01" arrivalAgeDays="1" createdBy="admin" />
  </lotes>
</seleto>
```

## 8. Backup após login

O backup também fica disponível após login:

```text
Configurações > Backup e exportação
```

Opções:

- `Salvar backup`: grava um JSON no armazenamento do device.
- `Enviar backup`: abre o compartilhamento Android para enviar por WhatsApp, Drive, e-mail ou outro app.
- `Exportar financeiro CSV`: gera uma planilha CSV dos lançamentos financeiros.
- `Restaurar backup JSON`: cola e restaura um backup `SELETO_BACKUP_V1`.

No Android, o arquivo salvo fica na área externa do app quando disponível; caso contrário, fica no diretório de documentos do app.

## 9. Alertas de luz, alimentação e fases

Os alertas podem ser configurados após login em:

```text
Alertas
```

Também é possível criar eventos com alerta em:

```text
Calendário e luz > Novo evento
```

Tipos úteis:

- `Fase de criação`
- `Iluminação`
- `Ração`
- `Pedido`
- `Entrega`
- `Alerta`

Cada alerta pode definir:

- hora
- mensagem
- dias de antecedência
- data do evento
- repetição uma vez, diária, semanal ou mensal
- dias da semana, quando a repetição for semanal
- data final de repetição

No Android, os alertas usam canal nativo de alarme com som, vibração, prioridade máxima e `bypassDnd`. Para tocar mesmo com o aparelho no silencioso ou em Não Perturbe, aceite as permissões de notificação, alarmes exatos e acesso à política de notificações quando o sistema pedir.

## 10. Gerar APK release

Antes de gerar:

```bash
flutter analyze
flutter test
```

Gerar APK:

```bash
flutter build apk --release --dart-define=SELETO_PERSIST_DB=true
```

Arquivo gerado:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Caminho completo:

```text
/home/alex-da-silva-alves/Python/GRANJA_SELETO/build/app/outputs/flutter-apk/app-release.apk
```

## 11. Instalar o APK via cabo

Com o celular conectado:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Para desinstalar antes:

```bash
adb uninstall com.seleto.seleto
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 12. APK debug

Gerar APK de debug:

```bash
flutter build apk --debug --dart-define=SELETO_PERSIST_DB=true
```

Instalar:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Use debug apenas para teste local; ele é maior e mais lento.

## 13. Problemas comuns

### O celular não aparece

```bash
adb devices
flutter devices
```

Tente também:

- trocar cabo USB
- trocar porta USB
- desbloquear o celular
- mudar o modo USB para transferência de arquivos
- revogar e autorizar novamente a depuração USB

### Licenças Android

```bash
flutter doctor --android-licenses
```

Aceite as licenças e rode o build novamente.

### Dados somem ao fechar

Confira se o app foi rodado ou gerado com:

```bash
--dart-define=SELETO_PERSIST_DB=true
```

### Limpar banco local

Desinstale o app ou limpe os dados em:

```text
Configurações > Apps > SELETO > Armazenamento > Limpar dados
```

## 14. Comandos rápidos

```bash
cd /home/alex-da-silva-alves/Python/GRANJA_SELETO
python3 scripts/generate_android_icons.py
flutter pub get
flutter analyze
flutter test
flutter run -d android --dart-define=SELETO_PERSIST_DB=true
flutter build apk --release --dart-define=SELETO_PERSIST_DB=true
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
