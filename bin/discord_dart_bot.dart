import 'package:discord_dart_bot/ai_response/ai_response.dart';
import 'package:discord_dart_bot/banned_words.dart';
import 'package:discord_dart_bot/commands.dart' as commands;
import 'package:discord_dart_bot/daily_games.dart';
import 'package:discord_dart_bot/link_fixers/link_fixer.dart';
import 'package:discord_dart_bot/onepiece_fetcher.dart';
import 'package:discord_dart_bot/message_helpers.dart';
import 'package:discord_dart_bot/reactions.dart';
// External packages
import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

void main(List<String> arguments) async {
  // -----------------------
  // Setup
  // -----------------------
  final env = DotEnv()..load();

  print('Starting bot...');

  final botCommands = CommandsPlugin(prefix: (_) => '!');
  botCommands.addCommand(commands.bfCommand);
  botCommands.addCommand(commands.playCommand);
  botCommands.addCommand(commands.todoCommand);
  botCommands.addCommand(commands.todosCommand);
  botCommands.addCommand(commands.todoRemoveCommand);
  botCommands.addCommand(commands.testCommand);

  final client = await Nyxx.connectGateway(
    env['DISCORD_TOKEN'] ?? 'missing_key',
    GatewayIntents.allUnprivileged |
        GatewayIntents.messageContent |
        GatewayIntents.guildMembers,
    options: GatewayClientOptions(
      plugins: [logging, cliIntegration, botCommands, commands.lavalink],
    ),
  );

  final guildMembers = <Member>[];
  final botUser = await client.users.fetchCurrentUser();

  print('Bot started');

  // -----------------------
  // Initialization
  // -----------------------
  const linkFixer = LinkFixer(fixers: [
    TwitterFixer(),
    TiktokFixer(),
    RedditFixer(),
  ]);

  print('Starting cron jobs...');
  fetchOnePieceChapter(client);
  dailyWordles(client);
  dailyProverb(client, env);
  dueloDeDragoesPoll(client);
  dueloDeDragoesReminder(client, env);

  // -----------------------
  // Events
  // -----------------------
  client.onReady.listen((event) async {
    final guildID = 812036688683597824;
    final guild = await client.guilds.fetch(Snowflake(guildID));
    final members = await guild.members.list(limit: 20);
    guildMembers.addAll(members);
  });

  client.onMessageCreate.listen((event) async {
    if (event.member?.id == botUser.id) return;

    if (hasBannedWords(event.message.content)) {
      return await blockBannedWords(event);
    }

    if (linkFixer.hasLinksToFix(event.message.content)) {
      return await linkFixer.fixLinks(event);
    }

    final mentionsBot = event.mentions.any((m) => m.id == botUser.id);
    final isLinkFix = isLinkFixerMessage(
        await event.message.reference?.message?.get(), botUser.id);
    if (mentionsBot && !isLinkFix) {
      await aiResponse(event, guildMembers, env);
    }

    final japanPattern = RegExp(
      r'j[4a@][p3][4a@ãÃ][o0]',
      caseSensitive: false,
    );

    if (japanPattern.hasMatch(event.message.content)) {
      await event.message.react(
        ReactionBuilder(name: ':pog', id: Snowflake(942920644335652864)),
      );
    }
  });

  client.onMessageReactionAdd.listen((event) async {
    if (event.member?.id == botUser.id) return;
    final reactedMessage = await event.message.get();

    messageDebugger(event, reactedMessage);
    await messageDeleter(event, reactedMessage, botUser);
  });

}
