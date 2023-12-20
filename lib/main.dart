import 'dart:isolate';
import 'dart:math' hide log;
import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localNotifications = FlutterLocalNotificationsPlugin();

  await localNotifications.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ),
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  final receivePort = ReceivePort();
  Isolate.spawn(listenToQueue, receivePort.sendPort);

  runApp(NotificationDemo(receivePort: receivePort));
}

// Listener Isolate
void listenToQueue(SendPort sendPort) async {
  final settings = ConnectionSettings(
    host: "164.68.109.159",
    port: 5555,
    authProvider: const PlainAuthenticator("goldenia", "M@r0zoo8AC"),
  );

  final client = Client(settings: settings);
  final channel = await client.channel();
  final queue = await channel.queue("notifications", autoDelete: true);
  final consumer = await queue.consume();

  consumer.listen((event) {
    sendPort.send(event.payloadAsString);
  });
}


class NotificationDemo extends StatefulWidget {
  final ReceivePort receivePort;

  const NotificationDemo(
      {super.key, required this.receivePort});

  @override
  State<NotificationDemo> createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  List<String> notifications = [];

  @override
  void initState() {
    widget.receivePort.listen((message) {
      message as String;
      setState(() {
        notifications.add(message);
      });

      FlutterLocalNotificationsPlugin().show(
        Random().nextInt(999999),
        "Demo",
        message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "${Random().nextDouble()}",
            "${Random().nextDouble()}",
          ),
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Notifications Demo"),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: notifications.length,
          itemBuilder: (context, index) => Text(notifications[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ),
    );
  }
}
