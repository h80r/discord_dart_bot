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

// Tudo deu errado nesse código aqui, API paia.
final playCommand = ChatCommand(
  'play',
  'Comando de teste para jogos',
  (MessageChatContext ctx) async {
    final bot = await ctx.client.users.fetchCurrentUser();
    final channels = await ctx.guild!.fetchChannels();
    final channel = channels.firstWhere((c) => c.id.value == 863813930468376656)
        as VoiceChannel;

    // TODO: definir o canal como o canal em que o usuário que rodou o comando tá presente
    // final vc = ctx.guild!.voiceStates;
    // print(vc);
    // final member = ctx.message.author.id;
    // print('======================= author =================');
    // print(member);

    await ctx.respond(
      MessageBuilder(content: 'Comando de teste para rolagem de dados'),
    );
  },
);
