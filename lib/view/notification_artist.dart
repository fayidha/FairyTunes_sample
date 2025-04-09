import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Moved the NotificationInterval class outside the state class
class NotificationInterval {
  final DateTime time;
  final String title;
  final String body;

  NotificationInterval({
    required this.time,
    required this.title,
    required this.body,
  });
}

class ProgramNotificationSystem extends StatefulWidget {
  const ProgramNotificationSystem({super.key});

  @override
  State<ProgramNotificationSystem> createState() => _ProgramNotificationSystemState();
}

class _ProgramNotificationSystemState extends State<ProgramNotificationSystem> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? _timer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAndRequestNotificationPermission();
    _initNotifications();
    _startNotificationChecker();
    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Notification permission denied');
      }
    }
  }

  Future<void> _initNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _startNotificationChecker() {
    // Check every hour for upcoming programs
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkUpcomingPrograms();
    });
    // Also run immediately on startup
    _checkUpcomingPrograms();
  }

  Future<void> _checkUpcomingPrograms() async {
    final now = DateTime.now();

    try {
      // Query all future bookings
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('programDate', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(now))
          .get();

      for (final doc in querySnapshot.docs) {
        final bookingData = doc.data();
        final programDateStr = bookingData['programDate'] as String?;
        final programTimeStr = bookingData['programTime'] as String?;
        final groupId = bookingData['groupId'] as String?;

        if (programDateStr == null || programTimeStr == null || groupId == null) {
          continue;
        }

        // Parse the program date and time
        final programDate = DateFormat('yyyy-MM-dd').parse(programDateStr);
        final programTimeParts = programTimeStr.split(':');
        final programDateTime = DateTime(
          programDate.year,
          programDate.month,
          programDate.day,
          int.parse(programTimeParts[0]),
          int.parse(programTimeParts[1]),
        );

        // Schedule notifications at different intervals
        await _scheduleMultipleNotifications(
          groupId: groupId,
          programDateTime: programDateTime,
          bookingData: bookingData,
          now: now,
        );
      }
    } catch (e) {
      debugPrint('Error checking upcoming programs: $e');
    }
  }

  Future<void> _scheduleMultipleNotifications({
    required String groupId,
    required DateTime programDateTime,
    required Map<String, dynamic> bookingData,
    required DateTime now,
  }) async {
    try {
      // Get all users in the group (artists and admins)
      final groupUsers = await _getGroupUsers(groupId);

      if (groupUsers.isEmpty) return;

      // Prepare notification details
      final programName = bookingData['programName'] ?? 'Upcoming Program';
      final formattedTime = DateFormat('hh:mm a').format(programDateTime);
      final formattedDate = DateFormat('MMMM d, y').format(programDateTime);

      // Define notification intervals
      final notificationTimes = [
        NotificationInterval(
          time: programDateTime.subtract(const Duration(days: 7)),
          title: '1 Week Reminder: $programName',
          body: 'The program is coming up in 1 week on $formattedDate at $formattedTime',
        ),
        NotificationInterval(
          time: programDateTime.subtract(const Duration(days: 1)),
          title: '1 Day Reminder: $programName',
          body: 'The program is tomorrow at $formattedTime',
        ),
        NotificationInterval(
          time: programDateTime.subtract(const Duration(hours: 1)),
          title: 'Starting Soon: $programName',
          body: 'The program starts in 1 hour at $formattedTime',
        ),
        NotificationInterval(
          time: programDateTime,
          title: 'Program Starting Now: $programName',
          body: 'The program is starting now!',
        ),
      ];

      for (final userId in groupUsers) {
        // Skip the current user if they're the one scheduling
        if (userId == _auth.currentUser?.uid) continue;

        for (final interval in notificationTimes) {
          // Only schedule if notification is in the future
          if (interval.time.isAfter(now)) {
            await _scheduleSingleNotification(
              userId: userId,
              title: interval.title,
              body: interval.body,
              scheduledTime: interval.time,
              programId: bookingData['id'] ?? groupId, // Unique identifier for the program
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling group notifications: $e');
    }
  }

  Future<void> _scheduleSingleNotification({
    required String userId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String programId,
  }) async {
    // Create a unique notification ID combining user ID, program ID, and time
    final notificationId = '${userId}_${programId}_${scheduledTime.millisecondsSinceEpoch}'.hashCode;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'program_reminders',
      'Program Reminders',
      channelDescription: 'Channel for program reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('Scheduled notification: $title for $scheduledTime');
  }

  Future<List<String>> _getGroupUsers(String groupId) async {
    final users = <String>[];

    try {
      // Get group document
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return users;

      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return users;

      // Add admins
      final admins = groupData['admin'] as List<dynamic>? ?? [];
      users.addAll(admins.whereType<String>());

      // Add artists
      final artists = groupData['artists'] as List<dynamic>? ?? [];
      users.addAll(artists.whereType<String>());

      return users.toSet().toList(); // Remove duplicates
    } catch (e) {
      debugPrint('Error getting group users: $e');
      return users;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Notification System'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active, size: 64),
            SizedBox(height: 20),
            Text(
              'Program Notification System is Running',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Notifications will be sent automatically\nat 1 week, 1 day, and 1 hour before programs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}