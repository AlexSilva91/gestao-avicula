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

  bool get canDeliverCriticalAlerts => false;
  List<String> get missingItems => const ['Abra o app instalado no Android.'];
}

class NotificationService {
  Future<void> initialize() async {}
  bool get nativeSupported => false;
  Future<NotificationReadiness> prepareCriticalAlerts() async => readiness();
  Future<bool> prepareMessages() async => false;
  Future<NotificationReadiness> readiness() async =>
      const NotificationReadiness(
        nativeSupported: false,
        notificationsEnabled: false,
        exactAlarmsAllowed: false,
        notificationPolicyAccess: false,
        batteryOptimizationIgnored: false,
        alarmChannelReady: false,
      );
  Future<void> ensureCriticalAlertsReady() async {}
  Future<void> testCriticalAlert() async {}
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    bool urgent = false,
    Duration? alarmDuration,
  }) async {}
  Future<void> scheduleMessage({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {}
  Future<void> testMessage({
    required String title,
    required String body,
  }) async {}
  Future<void> cancel(int id) async {}
}
