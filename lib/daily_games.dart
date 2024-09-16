import 'package:cron/cron.dart';
import 'package:nyxx/nyxx.dart';

// TODO: Refatorar esse arquivo em scheduledMessages ou algo do tipo

final cron = Cron();
final messagesCronString = "0 9 * * *";
final pollCronString = "0 9 * * MON";

final notasChannel = Snowflake(863813861248991252);
final botChannel = Snowflake(1057647846779781180);
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
  final channel = await client.channels.fetch(botChannel) as TextChannel;
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
    question: PollMediaBuilder(text: "vamos ter duelo de dragões essa semana?"),
    duration: pollDuration,
  );
  await channel.sendMessage(MessageBuilder(poll: dueloPoll));
}
