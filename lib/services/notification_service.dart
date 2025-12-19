import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static const String channelId = 'life_planner_channel';
  static const String channelName = 'Life Planner Notifications';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Criar canal de notificação para Android
    await _createNotificationChannel();

    // Solicitar permissões
    await _requestPermissions();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Notificações do Life Planner',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notificações do Life Planner',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notificações do Life Planner',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      // Fallback: mostrar notificação imediata se agendamento falhar
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Lidar com clique na notificação
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Navegar para a tela apropriada baseado no payload
    }
  }

  // Agendar alarme para compromisso
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required DateTime appointmentTime,
    required int minutesBefore,
  }) async {
    final reminderTime = appointmentTime.subtract(Duration(minutes: minutesBefore));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: id,
        title: 'Lembrete: $title',
        body: 'Seu compromisso começa em $minutesBefore minutos',
        scheduledTime: reminderTime,
        payload: 'appointment_$id',
      );
    }
  }

  // Agendar alarme para tarefa agendada
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime taskTime,
  }) async {
    if (taskTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: id,
        title: 'Tarefa: $title',
        body: 'É hora de realizar esta tarefa',
        scheduledTime: taskTime,
        payload: 'task_$id',
      );
    }
  }

  // Agendar alarme para meta
  Future<void> scheduleGoalReminder({
    required int id,
    required String title,
    required DateTime reminderTime,
  }) async {
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: id,
        title: 'Meta: $title',
        body: 'Não esqueça de trabalhar nesta meta',
        scheduledTime: reminderTime,
        payload: 'goal_$id',
      );
    }
  }
}
