import 'dart:convert';
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:html/parser.dart' as html;

import 'daily_games.dart';

final notasChannel = Snowflake(1057647846779781180);

final _onepieceEndpoint =
    Uri.parse('https://kakuseiproject.com/manga/one-piece/oo/');

final opFile = File('.last_op_chapter');

Future<int> getLastSeenOnePieceChapter() async {
  if (!opFile.existsSync()) {
    return 0;
  }

  final content = await opFile.readAsString();
  return int.parse(content.trim());
}

void updateLastOnePieceChapter(int chapter) {
  opFile.writeAsString(chapter.toString());
}

// Back to every minute for debugging
// After debugging, change to run every friday and Friday every 45 minutes
const frequency = '* * * * *';

final cron = Cron();

void fetchOnePieceChapter(NyxxGateway client) {
  print('[One Piece Fetcher] Starting cron job with frequency: $frequency');
  
  cron.schedule(Schedule.parse(frequency), () async {
    try {
      final response = await get(_onepieceEndpoint);

      if (response.statusCode != 200) {
        print('[One Piece Fetcher] HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        return;
      }

      final document = html.parse(response.body);
      final readingContentDiv = document.querySelector('div.reading-content');

      if (readingContentDiv == null) {
        print('[One Piece Fetcher] Could not find reading-content div');
        return;
      }

      final paragraphs = readingContentDiv.querySelectorAll('p');
      if (paragraphs.isEmpty) {
        print('[One Piece Fetcher] No paragraphs found in reading-content div');
        return;
      }

      final lastChapter = paragraphs.last;
      final chapterText = lastChapter.text.trim();

      final RegExp chapterRegex = RegExp(r'Capítulo (\d+): (https?://[^\s]+)');
      final match = chapterRegex.firstMatch(chapterText);
      
      if (match != null) {
        final chapterNumber = int.parse(match.group(1)!);
        final chapterLink = match.group(2)!;
        final lastChapterSeen = await getLastSeenOnePieceChapter();

        if (chapterNumber > lastChapterSeen) {
          print('[One Piece Fetcher] New chapter found! Chapter $chapterNumber');
          
          try {
            final channel = await client.channels.fetch(notasChannel) as TextChannel;
            
            final message = await channel.sendMessage(MessageBuilder(
              content: '**🏴‍☠️ Novo Capítulo de One Piece!**\n'
                      'Capítulo $chapterNumber está disponível!\n'
                      '**Link:** $chapterLink',
              embeds: [
                EmbedBuilder(
                  title: '🏴‍☠️ Novo Capítulo de One Piece!',
                  description: 'Capítulo $chapterNumber está disponível!\n[**Clique aqui para ler**]($chapterLink)',
                  color: DiscordColor.parseHexString('FF6B35'),
                  thumbnail: EmbedThumbnailBuilder(
                    url: Uri.parse('https://tenor.com/view/one-piece-luffy-sparkling-eyes-one-piece-luffy-sparkling-eyes-gif-4713473544283803636'),
                  ),
                  fields: [
                    EmbedFieldBuilder(
                      name: 'Capítulo',
                      value: chapterNumber.toString(),
                      isInline: true,
                    ),
                    EmbedFieldBuilder(
                      name: 'Link',
                      value: '[Ler Capítulo]($chapterLink)',
                      isInline: true,
                    ),
                  ],
                  timestamp: DateTime.now(),
                ),
              ],
            ));
            
            print('[One Piece Fetcher] ✅ Message sent successfully!');
            
            // COMMENTED OUT for debugging - so it keeps trying to send
            // updateLastOnePieceChapter(chapterNumber);
          } catch (discordError) {
            print('[One Piece Fetcher] ❌ Discord API Error: $discordError');
          }
        }
      } else {
        print('[One Piece Fetcher] ❌ Could not parse chapter number from text: "$chapterText"');
      }
    } catch (e) {
      print('[One Piece Fetcher] ❌ Error occurred: $e');
    }
  });
}