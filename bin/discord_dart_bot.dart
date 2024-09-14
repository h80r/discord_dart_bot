import 'package:discord_dart_bot/banned_words.dart';
import 'package:discord_dart_bot/commands.dart' as commands;
import 'package:discord_dart_bot/daily_games.dart';
import 'package:discord_dart_bot/link_fixers/link_fixers.dart';
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

  final client = await Nyxx.connectGateway(
    env['DISCORD_TOKEN'] ?? 'missing_key',
    GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
    options: GatewayClientOptions(
      plugins: [logging, cliIntegration, botCommands],
    ),
  );

  final botUser = await client.users.fetchCurrentUser();

  // -----------------------
  // Initialization
  // -----------------------
  dailyWordles(client);
  bailaoOtaku(client);

  // -----------------------
  // Events
  // -----------------------
  client.onMessageCreate.listen((event) async {
    if (event.member?.id == botUser.id) return;

    await checkBannedWords(event);
    await twitterAutoFix(event);
  });

  client.onMessageReactionAdd.listen((event) async {
    if (event.member?.id == botUser.id) return;
    final reactedMessage = await event.message.get();

    messageDebugger(event, reactedMessage);
    await messageDeleter(event, reactedMessage, botUser);
  });
}
