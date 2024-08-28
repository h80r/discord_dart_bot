import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final bfCommand = ChatCommand('bf', 'Brainfog command', (context) async {
  await context.respond(MessageBuilder(content: '🧠 🌫️'));
});
