import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _currentTime = '';
  String _currentDate = '';
  int _notificationId = 0;

  @override
  void initState() {
    super.initState();
    _checkAndRequestNotificationPermission();
    _initNotifications();
    _updateTimeAndDate();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeAndDate();
    });
    tz.initializeTimeZones();
    _startNotificationChecker();
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

    // Create notification channel
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'program_reminders',
      'Program Reminders',
      description: 'Channel for program notifications',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _updateTimeAndDate() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(now);
      _currentDate = DateFormat('EEEE, MMMM d, y').format(now);
    });
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
        final programName = bookingData['groupName'] as String?;

        if (programDateStr == null || programTimeStr == null || groupId == null) {
          continue;
        }

        // Parse the program date and time
        final programDate = DateFormat('yyyy-MM-dd').parse(programDateStr);
        final timeFormat = DateFormat.jm();
        final programTime = timeFormat.parse(programTimeStr);

        final programDateTime = DateTime(
          programDate.year,
          programDate.month,
          programDate.day,
          programTime.hour,
          programTime.minute,
        );

        // Schedule notifications at different intervals
        await _scheduleGroupNotifications(
          groupId: groupId,
          programDateTime: programDateTime,
          programName: programName ?? 'Upcoming Program',
          bookingId: doc.id,
        );
      }
    } catch (e) {
      debugPrint('Error checking upcoming programs: $e');
    }
  }

  Future<void> _scheduleGroupNotifications({
    required String groupId,
    required DateTime programDateTime,
    required String programName,
    required String bookingId,
  }) async {
    try {
      // Get all users in the group (artists and admins)
      final groupUsers = await _getGroupUsers(groupId);

      if (groupUsers.isEmpty) return;

      // Define notification intervals (1 week, 1 day, 1 hour before, and at event time)
      final notificationIntervals = [
        _NotificationInterval(
          time: programDateTime.subtract(const Duration(days: 7)),
          title: '1 Week Reminder: $programName',
          body: 'The program is coming up in 1 week!',
        ),
        _NotificationInterval(
          time: programDateTime.subtract(const Duration(days: 1)),
          title: '1 Day Reminder: $programName',
          body: 'The program is tomorrow!',
        ),
        _NotificationInterval(
          time: programDateTime.subtract(const Duration(hours: 1)),
          title: 'Starting Soon: $programName',
          body: 'The program starts in 1 hour!',
        ),
        _NotificationInterval(
          time: programDateTime,
          title: 'Program Starting Now: $programName',
          body: 'The program is starting now!',
        ),
      ];

      for (final userId in groupUsers) {
        // Skip the current user if they're the one scheduling
        if (userId == _auth.currentUser?.uid) continue;

        for (final interval in notificationIntervals) {
          // Only schedule if notification is in the future
          if (interval.time.isAfter(DateTime.now())) {
            await _scheduleSingleNotification(
              userId: userId,
              title: interval.title,
              body: interval.body,
              scheduledTime: interval.time,
              bookingId: bookingId,
              interval: interval.title.substring(0, 10), // For unique ID
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
    required String bookingId,
    required String interval,
  }) async {
    try {
      // Create a unique notification ID
      final notificationId = '${bookingId}_$interval'.hashCode;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'program_reminders',
        'Program Reminders',
        channelDescription: 'Channel for program notifications',
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
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<List<String>> _getGroupUsers(String groupId) async {
    final users = <String>[];
    try {
      // Get group document
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return users;

      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return users;

      // Add admin
      if (groupData['admin'] != null) {
        users.add(groupData['admin'] as String);
      }

      // Add artists from requests collection
      final requestsDoc = await _firestore.collection('requests').doc(groupId).get();
      if (requestsDoc.exists) {
        final requestsData = requestsDoc.data();
        final artists = requestsData?['artists'] as List<dynamic>? ?? [];
        for (final artist in artists) {
          if (artist is Map && artist['artistUid'] != null) {
            users.add(artist['artistUid'] as String);
          }
        }
      }

      return users.toSet().toList(); // Remove duplicates
    } catch (e) {
      debugPrint('Error getting group users: $e');
      return users;
    }
  }

  // Helper method to test notifications immediately
  Future<void> _testNotificationNow() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'program_reminders',
      'Program Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      'Test Notification',
      'This is a test notification to verify the system is working',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Notification System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: _testNotificationNow,
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: Column(
        children: [
          // Current time display (like your original UI)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _currentDate,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Notification System Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This system automatically schedules notifications for:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('1 week before each program'),
                ),
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('1 day before each program'),
                ),
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('1 hour before each program'),
                ),
                const ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('At the exact program time'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _checkUpcomingPrograms();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checking for upcoming programs...')),
                    );
                  },
                  child: const Text('Check for Programs Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for notification intervals
class _NotificationInterval {
  final DateTime time;
  final String title;
  final String body;

  _NotificationInterval({
    required this.time,
    required this.title,
    required this.body,
  });
}