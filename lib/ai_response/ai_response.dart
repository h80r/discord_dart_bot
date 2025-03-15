import 'dart:async';

import 'package:discord_dart_bot/ai_response/prompts.dart';
import 'package:discord_dart_bot/ai_response/utils.dart';
import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';

Future<void> aiResponse(
  MessageCreateEvent event,
  List<Member> guildMembers,
  DotEnv env,
) async {
  await sendMessageWithTyping(event.message.channel, () async {
    final messages = event.message.channel.messages;
    final lastMessages = await messages.fetchMany(
      before: event.message.id,
      limit: 19,
    );
    final allMessages = [...lastMessages.reversed, event.message];

    final context = allMessages
        .map((m) =>
            '${parseAuthor(guildMembers, m.author.id, m.author.username)} — ${m.timestamp.toLocal()}\n${parseMentions(guildMembers, m)}${m.attachments.map((a) => '\n<contentType: ${a.contentType} | fileName: ${a.fileName}>').join()}\n')
        .join('\n');

    return await getDeepSeekResponse(env, egoPrompt(context));
  });
}

String parseAuthor(
  List<Member> guildMembers,
  Snowflake authorID, [
  String fallbackName = '404',
]) {
  try {
    final guildMember = guildMembers.firstWhere((m) => m.user?.id == authorID);
    return guildMember.nick ?? guildMember.user?.username ?? fallbackName;
  } on StateError {
    return fallbackName;
  }
}

String parseMentions(List<Member> guildMembers, Message message) {
  final mentions = message.mentions;
  var content = message.content;

  for (final mention in mentions) {
    final mentionStr =
        '@${parseAuthor(guildMembers, mention.id, mention.username)}';
    final mentionId = '<@${mention.id}>';

    content = content.replaceAll(mentionId, mentionStr);
  }

  return content;
}
