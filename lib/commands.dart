import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

// Description field must be 100 characters or less
final bfCommand = ChatCommand(
  'bf',
  'Quando a mente do mano não consegue formular uma frase direito, esquecendo de tudo, é o _brain fog_',
  (ChatContext ctx) async => await ctx.respond(
    MessageBuilder(content: '🧠🌫️'),
  ),
);
