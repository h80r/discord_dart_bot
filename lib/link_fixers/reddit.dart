import 'package:discord_dart_bot/link_fixers/link_fixer.dart';

class RedditFixer implements FixableLink {
  const RedditFixer();

  @override
  RegExp get linkRegex => RegExp(r'https:\/\/www.reddit.com\/(\S+)');

  @override
  (String, List<String>) fixMessage(String message) {
    final parsedLinks = <String>[];
    final newMessage = message.replaceAllMapped(
      linkRegex,
      (match) {
        final newLink = 'https://www.vxreddit.com/${match.group(1)}';
        parsedLinks.add(newLink);
        return '~~[Link ${parsedLinks.length}](${newLink.replaceFirst('vx', '')})~~';
      },
    );

    return (newMessage, parsedLinks);
  }

  @override
  bool shouldFix(String message) => linkRegex.hasMatch(message);
}
