import 'package:cron/cron.dart';
import 'package:nyxx/nyxx.dart';

final cron = Cron();
final cronString = "0 9 * * *";

final notasChannel = Snowflake(863813861248991252);
final sites = ["https://bandle.app/", "https://loldle.net/"];

void dailyWordles(NyxxGateway client) async {
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
