import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';

import 'onepiece_fetcher.dart';

// Description field must be 100 characters or less
final bfCommand = ChatCommand(
  'bf',
  'Quando a mente do mano não consegue formular uma frase direito, esquecendo de tudo, é o _brain fog_',
  (ChatContext ctx) async => await ctx.respond(
    MessageBuilder(content: '🧠🌫️'),
  ),
);



final testCommand = ChatCommand('test', 'to test', (ChatContext ctx) async  {

  print("Test command executed by ${ctx.user.username} (${ctx.user.id}) in channel ${ctx.channel.id}");
  fetchOnePieceChapter(ctx.client);
  await ctx.respond(
    MessageBuilder(content: 'Test command executed successfully!'),
  );
});

final lavalink = LavalinkPlugin(
  base: Uri.http('localhost:2333'),
  password: 'bardomudo',
);

final playCommand = ChatCommand(
  'play',
  'Comando para rodar músicas do youtube que o outro bot não roda',
  (
    InteractionChatContext ctx,
    @Description('Link da música') String url,
  ) async {
    final channel = ctx.interaction.channelId;
    if (channel == null || channel != Snowflake(863813976005541938)) {
      final warning = await ctx.respond(
        MessageBuilder(content: 'Apenas no canal <#863813976005541938>'),
      );

      await Future.delayed(Duration(seconds: 5));
      await warning.delete();
      return;
    }

    final voiceStates = ctx.guild?.voiceStates;
    final voiceChannel = (await voiceStates?.entries
        .firstWhere((vs) => vs.key == ctx.user.id)
        .value
        .channel
        ?.fetch()) as VoiceChannel?;

    final player = await voiceChannel?.connectLavalink();
    final result = await lavalink.loadTrack(url);
    final track = result.data as Track;
    await player?.play(track);

    Timer(
      track.info.length + Duration(seconds: 5),
      () async => await player?.disconnect(),
    );

    String shortenName(String name) =>
        name.length > 40 ? '${name.substring(0, 37)}...' : name;

    await ctx.respond(
      MessageBuilder(
        embeds: [
          EmbedBuilder(
            author: EmbedAuthorBuilder(
              name: 'Started playing ${shortenName(track.info.title)}',
              iconUrl: Uri.parse(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Youtube_Music_icon.svg/240px-Youtube_Music_icon.svg.png'),
              url: track.info.uri,
            ),
            color: DiscordColor.parseHexString('FF0000'),
            fields: [
              EmbedFieldBuilder(
                name: 'Title',
                value: track.info.title,
                isInline: false,
              ),
              EmbedFieldBuilder(
                name: 'Author',
                value: track.info.author,
                isInline: true,
              ),
              EmbedFieldBuilder(
                name: 'Length',
                value:
                    '${track.info.length.inMinutes}:${track.info.length.inSeconds % 60}',
                isInline: true,
              )
            ],
            image: track.info.artworkUrl == null
                ? null
                : EmbedImageBuilder(url: track.info.artworkUrl!),
          )
        ],
      ),
    );
  },
);

final todoCommand = ChatCommand(
  'todo',
  'Adiciona uma nova tarefa à lista de TODOs',
  (
    InteractionChatContext ctx,
    @Description('Texto da tarefa') String text,
  ) async {
    final todoLogFile = File('./.todo.log');
    if (!await todoLogFile.exists()) {
      await todoLogFile.writeAsString('[]');
    }

    final todos = (jsonDecode(await todoLogFile.readAsString()) as List)
        .map((e) => e as String)
        .toList();

    todos.add(text);
    await todoLogFile.writeAsString(jsonEncode(todos));

    await ctx.respond(
      MessageBuilder(
        content: '✅ Tarefa adicionada: $text',
      ),
    );
  },
);

final todosCommand = ChatCommand(
  'todos',
  'Lista todas as tarefas armazenadas',
  (InteractionChatContext ctx) async {
    final todoLogFile = File('./.todo.log');
    if (!await todoLogFile.exists()) {
      await ctx.respond(
        MessageBuilder(
          content: '📝 Nenhuma tarefa armazenada ainda.',
        ),
      );
      return;
    }

    final todos = (jsonDecode(await todoLogFile.readAsString()) as List)
        .map((e) => e as String)
        .toList();

    if (todos.isEmpty) {
      await ctx.respond(
        MessageBuilder(
          content: '📝 Nenhuma tarefa armazenada ainda.',
        ),
      );
      return;
    }

    final todosList = todos.asMap().entries.map((e) {
      final index = e.key + 1;
      final text = e.value;
      return '$index. $text';
    }).join('\n');

    await ctx.respond(
      MessageBuilder(
        content: '📝 Lista de tarefas:\n$todosList',
      ),
    );
  },
);

final todoRemoveCommand = ChatCommand(
  'todo-remove',
  'Remove uma tarefa da lista pelo seu número',
  (
    InteractionChatContext ctx,
    @Description('Número da tarefa') int number,
  ) async {
    final todoLogFile = File('./.todo.log');
    if (!await todoLogFile.exists()) {
      await ctx.respond(
        MessageBuilder(
          content: '❌ Nenhuma tarefa armazenada ainda.',
        ),
      );
      return;
    }

    final todos = (jsonDecode(await todoLogFile.readAsString()) as List)
        .map((e) => e as String)
        .toList();

    if (number < 1 || number > todos.length) {
      await ctx.respond(
        MessageBuilder(
          content:
              '❌ Número de tarefa inválido. Use `/todos` para ver a lista.',
        ),
      );
      return;
    }

    final removedTodo = todos.removeAt(number - 1);
    await todoLogFile.writeAsString(jsonEncode(todos));

    await ctx.respond(
      MessageBuilder(
        content: '✅ Tarefa removida: $removedTodo',
      ),
    );
  },
);
