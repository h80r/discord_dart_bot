import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final bfCommand = ChatCommand(
  'bf',
  'Quando o mano tá perdidinho na porradaria,'
      ' a mente não consegue formular uma frase direito,'
      ' esquecendo de tudo, é o _brain fog_',
  (ChatContext ctx) async => await ctx.respond(
    MessageBuilder(content: '🧠🌫️'),
  ),
);
