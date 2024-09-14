import 'package:discord_dart_bot/link_fixers/link_fixer.dart';

class TiktokFixer implements FixableLink {
  const TiktokFixer();

  @override
  RegExp get linkRegex => RegExp(r'https:\/\/((?:www|vm).)?tiktok.com\/(\S+)');

  @override
  (String, List<String>) fixMessage(String message) {
    final parsedLinks = <String>[];
    final newMessage = message.replaceAllMapped(
      linkRegex,
      (match) {
        final newLink =
            'https://${match.group(1)}vxtiktok.com/${match.group(2)}';
        parsedLinks.add(newLink);
        return '~~[Link ${parsedLinks.length}](${newLink.replaceFirst('vxtiktok', 'tiktok')})~~';
      },
    );

    return (newMessage, parsedLinks);
  }

  @override
  bool shouldFix(String message) => linkRegex.hasMatch(message);
}
