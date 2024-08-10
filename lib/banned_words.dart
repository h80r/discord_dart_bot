import 'package:nyxx/nyxx.dart';

final bannedWords = [
  "imagine dragons",
  "mog",
  "churrascamento",
  "trotskismo",
  "mirandous",
  "ciro gomes",
  "marçal"
].join("|");

final allowBannedWordsPattern = RegExp("morra", caseSensitive: false);

Future<void> checkBannedWords(MessageCreateEvent event) async {
  final bannedWordsPattern = RegExp(bannedWords, caseSensitive: false);

  final bannedWordMatch =
      bannedWordsPattern.firstMatch(event.message.content)?[0];

  if (bannedWordMatch != null) {
    if (allowBannedWordsPattern.hasMatch(event.message.content)) {
      await event.message.react(
        ReactionBuilder(name: ":chad", id: Snowflake(941434881991393300)),
      );
    } else {
      await event.message.delete();

      await event.message.channel.sendMessage(MessageBuilder(embeds: [
        EmbedBuilder(
          description:
              'Infelizmente "$bannedWordMatch" e derivados estão banidos(as) do servidor...',
        ),
        EmbedBuilder(
          author: EmbedAuthorBuilder(
            name: event.message.author.username,
            iconUrl: event.message.author.avatar?.url,
          ),
          description: event.message.content,
          color: DiscordColor.fromRgb(255, 0, 0),
        ),
      ]));
    }
  }
}
