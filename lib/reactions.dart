import 'package:nyxx/nyxx.dart';

void messageDebugger(MessageReactionAddEvent event, Message reactedMessage) {
  if (event.emoji.name != '🔍') return;
  print(reactedMessage);
  print('=============[embeds]=============');
  for (final embed in reactedMessage.embeds) {
    print('Author: ${embed.author}');
    print('Color: ${embed.color}');
    print('Description: ${embed.description}');
    print('Fields: ${embed.fields}');
    print('Footer: ${embed.footer}');
    print('Image: ${embed.image}');
    print('Provider: ${embed.provider}');
    print('Thumbnail: ${embed.thumbnail}');
    print('Timestamp: ${embed.timestamp}');
    print('Title: ${embed.title}');
    print('URL: ${embed.url}');
    print('Video: ${embed.video}');
  }
}

Future<void> messageDeleter(
  MessageReactionAddEvent event,
  Message reactedMessage,
  User botUser,
) async {
  final susEmoji = Snowflake(941130823514615888);
  if (event.emoji.id != susEmoji) return;
  if (event.messageAuthorId != botUser.id) return;

  var currentMessage = reactedMessage;
  final messagesToDelete = [currentMessage];
  while (currentMessage.reference != null) {
    final referencedMessage = (await currentMessage.reference?.message?.get())!;
    if (referencedMessage.author.id == botUser.id) {
      messagesToDelete.insert(0, referencedMessage);
      if (referencedMessage.content == '') {
        break;
      }
      currentMessage = referencedMessage;
    }
  }

  if (messagesToDelete.first.embeds.first.author?.name ==
      event.member?.user?.username) {
    for (final message in messagesToDelete) {
      await message.delete();
    }
  }
}
