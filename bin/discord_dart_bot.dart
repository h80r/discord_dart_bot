import 'package:discord_dart_bot/ai_response/ai_response.dart';
import 'package:discord_dart_bot/banned_words.dart';
import 'package:discord_dart_bot/commands.dart' as commands;
import 'package:discord_dart_bot/daily_games.dart';
import 'package:discord_dart_bot/link_fixers/link_fixer.dart';
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

  final botCommands = CommandsPlugin(prefix: (_) => '!');
  botCommands.addCommand(commands.bfCommand);
  botCommands.addCommand(commands.playCommand);

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

  // -----------------------
  // Initialization
  // -----------------------
  const linkFixer = LinkFixer(fixers: [
    TwitterFixer(),
    TiktokFixer(),
    RedditFixer(),
  ]);

  dailyWordles(client);
  dueloDeDragoesPoll(client);

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

    await checkBannedWords(event);
    await linkFixer.fixLinks(event);

    if (event.mentions.any((m) => m.id == botUser.id)) {
      await aiResponse(event, guildMembers, env);
    }
  });

  client.onMessageReactionAdd.listen((event) async {
    if (event.member?.id == botUser.id) return;
    final reactedMessage = await event.message.get();

    messageDebugger(event, reactedMessage);
    await messageDeleter(event, reactedMessage, botUser);
  });
}
