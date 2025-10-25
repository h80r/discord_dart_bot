import 'dart:async';
import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';

Future<String> getDeepSeekResponse(
  DotEnv env,
  List<Map<String, String>> messages,
) async {
  final body = jsonEncode({
    'model': 'deepseek-reasoner',
    // 'model': 'deepseek-chat',
    'messages': messages,
    'stream': false
  });

  final rawResponse = await post(
    Uri.https('api.deepseek.com', '/chat/completions'),
    body: body,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${env['DEEPSEEK_TOKEN']}',
    },
  );

  final response = utf8.decode(rawResponse.bodyBytes);
  final msg = jsonDecode(response)['choices'][0]['message']['content'];

  return msg;
}

Future<Message?> sendMessageWithTyping(
  PartialTextChannel channel,
  Future<String?> Function() processMessage, [
  List<AttachmentBuilder>? attachments,
]) async {
  await channel.triggerTyping();
  final typingState = Timer.periodic(const Duration(seconds: 8), (_) async {
    await channel.triggerTyping();
  });

  final msg = await processMessage();

  typingState.cancel();

  if (msg == null || msg.isEmpty) {
    return null;
  }

  if (msg.length <= 500) {
    return await channel.sendMessage(MessageBuilder(
      content: msg,
      attachments: attachments,
    ));
  }

  final chunks = <String>[];
  var remaining = msg;

  while (remaining.length > 500) {
    var splitIndex = 500;

    var foundGoodSplit = false;
    for (var i = 500; i >= 400 && i < remaining.length; i--) {
      final char = remaining[i];
      if (char == '\n' ||
          char == ' ' ||
          char == '.' ||
          char == ',' ||
          char == '!' ||
          char == '?') {
        splitIndex = i + 1;
        foundGoodSplit = true;
        break;
      }
    }

    if (!foundGoodSplit) {
      splitIndex = 500;
    }

    chunks.add(remaining.substring(0, splitIndex).trim());
    remaining = remaining.substring(splitIndex).trim();
  }

  if (remaining.isNotEmpty) {
    chunks.add(remaining);
  }

  final firstMessage = await channel.sendMessage(MessageBuilder(
    content: chunks[0],
    attachments: attachments,
  ));

  for (var i = 1; i < chunks.length; i++) {
    await channel.triggerTyping();
    await Future.delayed(const Duration(milliseconds: 500));
    await channel.sendMessage(MessageBuilder(
      content: chunks[i],
    ));
  }

  return firstMessage;
}
