import 'dart:convert';
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:discord_dart_bot/ai_response/prompts.dart';
import 'package:discord_dart_bot/ai_response/utils.dart';
import 'package:discord_dart_bot/audio_sender.dart';
import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';

// TODO: Refatorar esse arquivo em scheduledMessages ou algo do tipo

final cron = Cron();
final dueloChannel = Snowflake(1234227582715822102);
final messagesCronString = "0 9 * * *";

final notasChannel = Snowflake(863813861248991252);
final pollCronString = "0 9 * * 1";
final sites = ["https://bandle.app/", "https://loldle.net/"];

void bailaoOtaku(NyxxGateway client) {
  cron.schedule(Schedule.parse(messagesCronString), () async {
    final channel = await client.channels.fetch(notasChannel) as TextChannel;
    const brc = '<@237618372353851392>';
    channel.sendMessage(
      MessageBuilder(
        content:
            '$brc R\$ 27.50 no [Sympla](https://www.sympla.com.br/evento/bailao-nerd-edicao-palmas/2607659)',
      ),
    );
  });
}

void dailyProverb(NyxxGateway client, DotEnv env) async {
  const frequency = '0 11 * * *';
  void logic() async {
    final channel = await client.channels.fetch(notasChannel) as TextChannel;

    await sendMessageWithTyping(channel, () async {
      final proverbLogFile = File('./.proverb.log');
      if (!await proverbLogFile.exists()) {
        await proverbLogFile.writeAsString('[]');
      }

      final proverbHistory =
          (jsonDecode(await proverbLogFile.readAsString()) as List)
              .map((e) => e as String)
              .toList();

      final response = await getDeepSeekResponse(
        env,
        proverbPrompt(proverbHistory.join('\n')),
      );

      await proverbLogFile
          .writeAsString(jsonEncode([response, ...proverbHistory.take(6)]));

      await sendAudio(env, channel.id.toString(), File('./sfx.ogg'));

      final today = DateTime.now().weekday;
      final headers =
          '> 笨人永远学不会，聪明人从自己的经验中学习，智者从他人的经验中学习。\n\n**Para est${today - 6 >= 0 ? 'e' : 'a'} ${[
        'null',
        'segunda-feira',
        'terca-feira',
        'quarta-feira',
        'quinta-feira',
        'sexta-feira',
        'sábado',
        'domingo'
      ][today]}, reflita!**';

      return '$headers\n*$response*';
    });
  }

  logic();

  cron.schedule(Schedule.parse(frequency), logic);
}

void dailyWordles(NyxxGateway client) {
  cron.schedule(Schedule.parse(messagesCronString), () async {
    final channel = await client.channels.fetch(notasChannel) as TextChannel;
    final allLinks = sites.join("\n");
    channel.sendMessage(
      MessageBuilder(
        content: 'Joguinhos de hoje: \n$allLinks',
      ),
    );
  });
}

void dueloDeDragoesPoll(NyxxGateway client) async {
  cron.schedule(Schedule.parse(pollCronString), () async {
    final channel = await client.channels.fetch(dueloChannel) as TextChannel;
    final dueloAnswers = [
      PollAnswerBuilder(pollMedia: PollMediaBuilder(text: "sexta")),
      PollAnswerBuilder(pollMedia: PollMediaBuilder(text: "sábado")),
      PollAnswerBuilder(pollMedia: PollMediaBuilder(text: "não sei ainda")),
      PollAnswerBuilder(pollMedia: PollMediaBuilder(text: "pula"))
    ];
    final pollDuration = Duration(days: 3);
    final dueloPoll = PollBuilder(
      answers: dueloAnswers,
      allowMultiselect: true,
      question:
          PollMediaBuilder(text: "vamos ter duelo de dragões essa semana?"),
      duration: pollDuration,
    );
    await channel.sendMessage(MessageBuilder(
      content: "chegou a hora de votar <@&1026726127143747644>",
      poll: dueloPoll,
    ));
  });
}
