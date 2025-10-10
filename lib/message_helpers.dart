import 'package:nyxx/nyxx.dart';

/// Checks if a message is a link fixer message by verifying:
/// 1. The message is from the bot
/// 2. The content matches the link fixer format: [.](url) or [Link N](url)
bool isLinkFixerMessage(Message message, Snowflake botUserId) {
  if (message.author.id != botUserId) return false;

  // Link fixer messages have the format: [.](url) or [Link N](url)
  final linkFixerPattern = RegExp(r'^\[(?:\.|Link \d+)\]\(https?:\/\/.+\)$');
  return linkFixerPattern.hasMatch(message.content);
}
