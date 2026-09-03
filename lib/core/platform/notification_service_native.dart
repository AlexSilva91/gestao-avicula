import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationReadiness {
  const NotificationReadiness({
    required this.nativeSupported,
    required this.notificationsEnabled,
    required this.exactAlarmsAllowed,
    required this.notificationPolicyAccess,
    required this.batteryOptimizationIgnored,
    required this.alarmChannelReady,
  });

  final bool nativeSupported;
  final bool notificationsEnabled;
  final bool exactAlarmsAllowed;
  final bool notificationPolicyAccess;
  final bool batteryOptimizationIgnored;
  final bool alarmChannelReady;

  bool get canDeliverCriticalAlerts =>
      nativeSupported &&
      notificationsEnabled &&
      exactAlarmsAllowed &&
      notificationPolicyAccess &&
      batteryOptimizationIgnored &&
      alarmChannelReady;

  List<String> get missingItems => [
    if (!nativeSupported) 'Abra o app instalado no Android.',
    if (!notificationsEnabled) 'Permita notificações para o GRANJA SELETO.',
    if (!exactAlarmsAllowed) 'Permita alarmes e lembretes exatos.',
    if (!notificationPolicyAccess)
      'Permita que o GRANJA SELETO interrompa o modo silencioso/Não perturbe.',
    if (!batteryOptimizationIgnored)
      'Permita que o GRANJA SELETO ignore a otimização de bateria.',
    if (!alarmChannelReady) 'Mantenha o canal de alertas sonoros ativo.',
  ];
}

class NotificationService {
  static const _channelId = 'seleto_alarm';
  static const _messageChannelId = 'seleto_messages';
  static const _criticalChannel = MethodChannel('seleto/critical_alerts');
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  bool get nativeSupported => Platform.isAndroid;

  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Recife'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
    await _createAlarmChannel(recreate: false);
    await _createMessageChannel();
  }

  Future<bool> prepareMessages() async {
    if (!Platform.isAndroid) return false;
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await _createMessageChannel();
    return await android?.areNotificationsEnabled() ?? false;
  }

  Future<NotificationReadiness> prepareCriticalAlerts() async {
    if (!Platform.isAndroid) return readiness();
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    await android?.requestFullScreenIntentPermission();

    final hasPolicyAccess =
        await android?.hasNotificationPolicyAccess() ?? false;
    if (!hasPolicyAccess) {
      await android?.requestNotificationPolicyAccess();
    }
    if (!await _isIgnoringBatteryOptimizations()) {
      await _requestIgnoreBatteryOptimizations();
    }
    await _createAlarmChannel(recreate: false);
    var status = await readiness();
    if (!status.alarmChannelReady) {
      await _createAlarmChannel(recreate: true);
      status = await readiness();
    }
    return status;
  }

  Future<NotificationReadiness> readiness() async {
    if (!Platform.isAndroid) {
      return const NotificationReadiness(
        nativeSupported: false,
        notificationsEnabled: false,
        exactAlarmsAllowed: false,
        notificationPolicyAccess: false,
        batteryOptimizationIgnored: false,
        alarmChannelReady: false,
      );
    }
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final channels = await android?.getNotificationChannels() ?? const [];
    final alarmChannel = channels
        .where((channel) => channel.id == _channelId)
        .firstOrNull;
    return NotificationReadiness(
      nativeSupported: true,
      notificationsEnabled: await android?.areNotificationsEnabled() ?? false,
      exactAlarmsAllowed:
          await android?.canScheduleExactNotifications() ?? false,
      notificationPolicyAccess:
          await android?.hasNotificationPolicyAccess() ?? false,
      batteryOptimizationIgnored: await _isIgnoringBatteryOptimizations(),
      alarmChannelReady:
          alarmChannel != null &&
          (alarmChannel.importance == Importance.max ||
              alarmChannel.importance == Importance.high) &&
          alarmChannel.enableVibration,
    );
  }

  Future<void> ensureCriticalAlertsReady() async {
    final status = await prepareCriticalAlerts();
    if (!status.canDeliverCriticalAlerts) {
      throw StateError(
        'Alertas críticos ainda não estão liberados neste Android: ${status.missingItems.join(' ')}',
      );
    }
  }

  Future<void> _createAlarmChannel({required bool recreate}) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    if (recreate) {
      await android.deleteNotificationChannel(channelId: _channelId);
    }
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        'Alertas sonoros GRANJA SELETO',
        description:
            'Alertas operacionais com som, vibração e prioridade de alarme',
        importance: Importance.max,
        bypassDnd: true,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  Future<void> _createMessageChannel() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _messageChannelId,
        'Mensagens GRANJA SELETO',
        description: 'Mensagens operacionais agendadas',
        importance: Importance.high,
        playSound: true,
        enableVibration: false,
      ),
    );
  }

  Future<void> testCriticalAlert() => schedule(
    id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
    title: 'GRANJA SELETO · Teste de alerta',
    body: 'Se você ouviu som e sentiu vibração, o alerta crítico está pronto.',
    at: DateTime.now().add(const Duration(seconds: 5)),
    urgent: true,
    alarmDuration: const Duration(seconds: 5),
  );

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    bool urgent = false,
    Duration? alarmDuration,
  }) async {
    if (!Platform.isAndroid || !at.isAfter(DateTime.now())) return;
    await initialize();
    if (urgent) {
      final status = await readiness();
      if (!status.canDeliverCriticalAlerts) {
        await ensureCriticalAlertsReady();
      }
    }
    if (urgent) {
      await _scheduleNativeCriticalAlarm(
        id: id,
        title: title,
        body: body,
        at: at,
        alarmDuration: alarmDuration,
      );
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Alertas sonoros GRANJA SELETO',
          channelDescription: 'Fases, iluminação, estoque, pedidos e entregas',
          importance: Importance.max,
          priority: Priority.max,
          channelBypassDnd: true,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'seleto',
    );
  }

  Future<void> scheduleMessage({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    if (!Platform.isAndroid || !at.isAfter(DateTime.now())) return;
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    var scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (await android?.canScheduleExactNotifications() ?? false) {
      scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _messageChannelId,
          'Mensagens GRANJA SELETO',
          channelDescription: 'Mensagens operacionais agendadas',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: false,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
      ),
      androidScheduleMode: scheduleMode,
      payload: 'seleto_message',
    );
  }

  Future<void> testMessage({
    required String title,
    required String body,
  }) async {
    if (!Platform.isAndroid) return;
    if (!await prepareMessages()) {
      throw StateError('Permita notificações para o GRANJA SELETO.');
    }
    await scheduleMessage(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      at: DateTime.now().add(const Duration(seconds: 5)),
    );
  }

  Future<void> _scheduleNativeCriticalAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    Duration? alarmDuration,
  }) async {
    await _criticalChannel.invokeMethod<void>('schedule', {
      'id': id,
      'title': title,
      'body': body,
      'triggerAtMillis': at.millisecondsSinceEpoch,
      if (alarmDuration != null) 'durationMillis': alarmDuration.inMilliseconds,
    });
  }

  Future<bool> _isIgnoringBatteryOptimizations() async =>
      await _criticalChannel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      ) ??
      false;

  Future<void> _requestIgnoreBatteryOptimizations() =>
      _criticalChannel.invokeMethod<void>('requestIgnoreBatteryOptimizations');

  Future<void> cancel(int id) async {
    if (Platform.isAndroid) {
      await _criticalChannel.invokeMethod<void>('cancel', {'id': id});
    }
    await _plugin.cancel(id: id);
  }
}
