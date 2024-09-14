import 'package:nyxx/nyxx.dart';

export 'package:discord_dart_bot/link_fixers/reddit.dart';
export 'package:discord_dart_bot/link_fixers/tiktok.dart';
export 'package:discord_dart_bot/link_fixers/twitter.dart';

abstract class FixableLink {
  RegExp get linkRegex;

  /// Fixes links in the message, returning a new message and a list of fixed links
  (String, List<String>) fixMessage(String message);
  bool shouldFix(String message);
}

class LinkFixer {
  final List<FixableLink> _fixers;
  const LinkFixer({required List<FixableLink> fixers}) : _fixers = fixers;

  Future<void> fixLinks(MessageCreateEvent event) async {
    var result = event.message.content;
    final parsedLinks = <String>[];

    for (final fixer in _fixers) {
      if (!fixer.shouldFix(result)) continue;
      await event.message.delete();

      final (msg, links) = fixer.fixMessage(result);
      result = msg;
      parsedLinks.addAll(links);
    }

    final fakeUserMessage = await event.message.channel.sendMessage(
      MessageBuilder(
        replyId: event.message.reference?.messageId,
        embeds: [
          EmbedBuilder(
            author: EmbedAuthorBuilder(
              name: event.message.author.username,
              iconUrl: event.message.author.avatar?.url,
            ),
            description: result,
            color: DiscordColor.parseHexString('7C6EBB'),
          ),
        ],
      ),
    );

    var lastMessage = fakeUserMessage;
    for (final link in parsedLinks) {
      lastMessage = await event.message.channel.sendMessage(MessageBuilder(
        replyId: lastMessage.id,
        content:
            '[${parsedLinks.length == 1 ? '.' : 'Link ${parsedLinks.indexOf(link) + 1}'}]($link)',
      ));
    }

    await lastMessage.react(
      ReactionBuilder(name: ':sus', id: Snowflake(941130823514615888)),
    );
  }
}
