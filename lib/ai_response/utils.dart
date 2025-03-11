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
    // 'model': 'deepseek-reasoner',
    'model': 'deepseek-chat',
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

Future<Message> sendMessageWithTyping(
  MessageCreateEvent event,
  Future<String?> Function() processMessage,
) async {
  await event.message.channel.triggerTyping();
  final typingState = Timer.periodic(const Duration(seconds: 8), (_) async {
    await event.message.channel.triggerTyping();
  });

  final msg = await processMessage();

  typingState.cancel();

  return await event.message.channel.sendMessage(MessageBuilder(content: msg));
}
