import 'package:cron/cron.dart';
import 'package:nyxx/nyxx.dart';

final cron = Cron();
final cronString = "0 9 * * *";

final notasChannel = Snowflake(863813861248991252);
final sites = ["https://bandle.app/", "https://loldle.net/"];

void bailaoOtaku(NyxxGateway client) {
  cron.schedule(Schedule.parse(cronString), () async {
    final channel = await client.channels.fetch(notasChannel) as TextChannel;
    const brc = '<@237618372353851392>';
    channel.sendMessage(
      MessageBuilder(
        content:
            '$brc R\$ 22.50 no [Sympla](https://www.sympla.com.br/evento/bailao-nerd-edicao-palmas/2607659)',
      ),
    );
  });
}

void dailyWordles(NyxxGateway client) {
  cron.schedule(Schedule.parse(cronString), () async {
    final channel = await client.channels.fetch(notasChannel) as TextChannel;
    final allLinks = sites.join("\n");
    channel.sendMessage(
      MessageBuilder(
        content: 'Joguinhos de hoje: \n$allLinks',
      ),
    );
  });
}
