import 'package:discord_dart_bot/link_fixers/link_fixer.dart';

class TwitterFixer implements FixableLink {
  const TwitterFixer();

  @override
  RegExp get linkRegex => RegExp(
        r'https:\/\/(?:x|twitter).com\/([^\s?]*)(?:(?:\?|&)[st]=[^\s]*)?',
      );

  @override
  (String, List<String>) fixMessage(String message) {
    final parsedLinks = <String>[];
    final newMessage = message.replaceAllMapped(
      linkRegex,
      (match) {
        final newLink = 'https://fixupx.com/${match.group(1)}';
        parsedLinks.add(newLink);
        return '~~[Link ${parsedLinks.length}](${newLink.replaceFirst('fixup', '')})~~';
      },
    );

    return (newMessage, parsedLinks);
  }

  @override
  bool shouldFix(String message) => linkRegex.hasMatch(message);
}
