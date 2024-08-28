import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';

const rpgChannel = Snowflake(1026722770333204511);

const _campaignTargets = {
  790000: '+5 Distinções de Heróis (25)',
  925000: 'Novas Ameaças: Gênios',
  1115000: 'Mundos dos Deuses em Cartelas (4)',
  1150000: 'Tokens das Novas Ameaças',
  1205000: 'Mais Poderes de Classes 1/2',
  1260000: '+5 Distinções de Devotos (15)',
  1350000: '+4 Cartelas de Mundos (8)',
  1375000: 'Trilhas Sonoras Artonianas',
  1415000: '+5 Distinções de Heróis (30)',
  1455000: 'Novas Ameaças: Fadas',
  1495000: '+4 Cartelas de Mundos (12)',
  1530000: 'Anúncio Surpresa + Brinde Digital',
  1560000: 'Culinária Avançada',
  1595000: '+5 Distinções de Devotos (20)',
  1635000: '+4 Cartelas de Mundos (16)',
  1725000: 'Guia de Deuses Menores (Digital)',
  1760000: 'Mais Poderes de Classes 2/2',
  1795000: 'Nova Linhagem de Feiticeiro: Abençoado',
  1815000: 'Cartelas Digitais',
  1855000: '+5 Distinções de Heróis (35)',
  1900000: 'Novas Ameaças: Gigantes',
  1990000: '+4 Cartelas de Mundos (20)',
  2326485: 'Guia de Deuses Menores (Físico)',
};

late int _nextGoal;

final _projectEndpoint =
    Uri.parse('https://api.catarse.me/project_details?project_id=eq.178796');

Future<List<String>> getAchievedGoals() async {
  final pledged = await getPledged();
  final achievedGoals = _campaignTargets.entries
      .where((t) => t.key <= pledged)
      .map((t) => t.value);
  _nextGoal = achievedGoals.length;
  return achievedGoals.toList();
}

MapEntry<int, String> getNextTarget() {
  return _campaignTargets.entries.elementAt(_nextGoal);
}

Future<double> getPledged() async {
  final response = await get(_projectEndpoint);
  try {
    final [{'pledged': pledged}] = jsonDecode(response.body) as List;
    return pledged;
  } on Exception catch (e) {
    print(e);
    print(response.body);
    rethrow; // TODO: Handle after discovering what is the issue
  }
}

Future<void> initialTormenta25Check(NyxxGateway client) async {
  final achievedGoals = await getAchievedGoals();

  final message = 'Iniciando acompanhamento da Campanha :dragon_face:\n'
      '${achievedGoals.map((t) => ':white_check_mark: $t').join('\n')}';

  final channel = await client.channels.fetch(rpgChannel) as TextChannel;
  await channel.sendMessage(MessageBuilder(content: message));
}

void periodicTormenta25Check(NyxxGateway client) async {
  Timer.periodic(const Duration(minutes: 5), (_) async {
    final nextEntry = getNextTarget();
    final pledged = await getPledged();
    if (pledged < nextEntry.key) return;

    _nextGoal++;
    final channel = await client.channels.fetch(rpgChannel) as TextChannel;
    channel.sendMessage(
      MessageBuilder(
        content: 'Nova meta alcançada! :tada:\n'
            ':white_check_mark: ${nextEntry.value}',
      ),
    );
  });
}
