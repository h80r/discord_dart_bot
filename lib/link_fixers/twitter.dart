import 'package:nyxx/nyxx.dart';

final twitterPattern = RegExp(
  r'https:\/\/(?:x|twitter).com\/([^\s?]*)(?:\?s=.*&t=[^\s]*)?',
);

Future<void> twitterAutoFix(MessageCreateEvent event) async {
  if (twitterPattern.hasMatch(event.message.content)) {
    await event.message.delete();

    final parsedLinks = <String>[];
    final newContent = event.message.content.replaceAllMapped(
      twitterPattern,
      (match) {
        final newLink = 'https://fixupx.com/${match.group(1)}';
        parsedLinks.add(newLink);
        return '~~[Link ${parsedLinks.length}](${newLink.replaceFirst('fixup', '')})~~';
      },
    );

    var lastMessage = await event.message.channel.sendMessage(
      MessageBuilder(
        replyId: event.message.reference?.messageId,
        embeds: [
          EmbedBuilder(
            author: EmbedAuthorBuilder(
              name: event.message.author.username,
              iconUrl: event.message.author.avatar?.url,
            ),
            description: newContent,
            color: DiscordColor.parseHexString('7C6EBB'),
          ),
        ],
      ),
    );

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
