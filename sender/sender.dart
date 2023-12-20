import 'dart:io';

import 'package:dart_amqp/dart_amqp.dart';

// Run this in terminal to send messages to the queue

void main(List<String> arguments) async {
  final settings = ConnectionSettings(
    host: "164.68.109.159",
    port: 5555,
    authProvider: const PlainAuthenticator("goldenia", "M@r0zoo8AC"),
  );
  Client client = Client(settings: settings);

  Channel channel = await client.channel();

  var queue = await channel.queue("notifications", autoDelete: true);
  while (true) {
    print('Enter your message json e.g {"id":1,"message":"Hello world!"}: ');
    String? message = stdin.readLineSync();
    if (message == null) {
      continue;
    }
    if (message.toLowerCase() == "q" || message.toLowerCase() == "quit") {
      channel.close();
      client.close();
      exit(0);
    }
    queue.publish(message);
  }
}
