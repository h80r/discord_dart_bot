import 'dart:convert';

import 'package:discord_dart_bot/banned_words.dart';
import 'package:discord_dart_bot/commands.dart' as commands;
import 'package:discord_dart_bot/daily_games.dart';
import 'package:discord_dart_bot/link_fixers/link_fixer.dart';
import 'package:discord_dart_bot/reactions.dart';
// External packages
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

void main(List<String> arguments) async {
  // -----------------------
  // Setup
  // -----------------------
  final env = DotEnv()..load();

  final botCommands = CommandsPlugin(prefix: (_) => '!');
  botCommands.addCommand(commands.bfCommand);
  botCommands.addCommand(commands.playCommand);

  final client = await Nyxx.connectGateway(
    env['DISCORD_TOKEN'] ?? 'missing_key',
    GatewayIntents.allUnprivileged |
        GatewayIntents.messageContent |
        GatewayIntents.guildMembers,
    options: GatewayClientOptions(
      plugins: [logging, cliIntegration, botCommands, commands.lavalink],
    ),
  );

  final guildMembers = <Member>[];
  final botUser = await client.users.fetchCurrentUser();

  // -----------------------
  // Initialization
  // -----------------------
  const linkFixer = LinkFixer(fixers: [
    TwitterFixer(),
    TiktokFixer(),
    RedditFixer(),
  ]);

  dailyWordles(client);
  dueloDeDragoesPoll(client);

  // -----------------------
  // Events
  // -----------------------
  client.onReady.listen((event) async {
    final guildID = 812036688683597824;
    final guild = await client.guilds.fetch(Snowflake(guildID));
    final members = await guild.members.list(limit: 20);
    guildMembers.addAll(members);
  });

  client.onMessageCreate.listen((event) async {
    if (event.member?.id == botUser.id) return;

    if (event.mentions.any((m) => m.id == botUser.id)) {
      await event.message.channel.triggerTyping();

      final messages = event.message.channel.messages;
      final lastMessages =
          await messages.fetchMany(before: event.message.id, limit: 19);
      final allMessages = [...lastMessages.reversed, event.message];

      String parseAuthor(Snowflake authorID) {
        final guildMember =
            guildMembers.firstWhere((m) => m.user?.id == authorID);
        return guildMember.nick ?? guildMember.user?.username ?? '404';
      }

      String parseMentions(Message message) {
        final mentions = message.mentions;
        var content = message.content;

        for (final mention in mentions) {
          final mentionStr = '@${parseAuthor(mention.id)}';
          final mentionId = '<@${mention.id}>';

          content = content.replaceAll(mentionId, mentionStr);
        }

        return content;
      }

      final context = allMessages
          .map((m) =>
              '${parseAuthor(m.author.id)} — ${m.timestamp.toLocal()}\n${parseMentions(m)}${m.attachments.map((a) => '\n<contentType: ${a.contentType} | fileName: ${a.fileName}>').join()}\n')
          .join('\n');

      final body = jsonEncode({
        // 'model': 'deepseek-reasoner',
        'model': 'deepseek-chat',
        'messages': prompt(context),
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

      print(rawResponse.body);
      print('-----');

      final fullAIResponse =
          jsonDecode(rawResponse.body)['choices'][0]['message']['content'];
      print(fullAIResponse);
      print('type: ${fullAIResponse.runtimeType}');

      await event.message.channel.triggerTyping();
      await event.message.channel
          .sendMessage(MessageBuilder(content: fullAIResponse));
    }

    await checkBannedWords(event);
    await linkFixer.fixLinks(event);
  });

  client.onMessageReactionAdd.listen((event) async {
    if (event.member?.id == botUser.id) return;
    final reactedMessage = await event.message.get();

    messageDebugger(event, reactedMessage);
    await messageDeleter(event, reactedMessage, botUser);
  });
}

List<Map<String, String>> prompt(String context) => [
      {
        "role": "system",
        "content":
            "# Instruções para o Silly Little Guy\n**Versão:** 1.3 | **Objetivo:** Simular um membro humano orgânico do grupo do Discord, respondendo apenas quando mencionado (@)."
      },
      {
        "role": "system",
        "content":
            "### Introdução\nVocê é o **Silly Little Guy**, um membro do grupo que:\n1. **Nunca inicia conversas** (só responde quando mencionado com @).\n2. **Age como humano** (erros de digitação, opiniões fictícias, humor caótico).\n3. **Reflete a personalidade do grupo**: humor absurdo, conhecimento de nicho (futebol paulista/RPG) e ironia autorreferencial.\n4. **Usa APENAS o contexto das últimas mensagens** para responder (sem memória de interações passadas)."
      },
      {
        "role": "system",
        "content":
            "### Personalidade Detalhada – Tom e Estilo\n- **Humor**:\n  - *Absurdismo criativo*: \"O Palmeiras contratar o Vitor Roque é igual colocar ketchup na pizza: todo mundo critica, mas no fundo ama.\"\n  - *Ironia suave*: \"Claro, confia que o Santos vai ganhar algo esse ano... mentira.\"\n  - *Memes orgânicos*: \"Esse trio de ataque é nível Balatro endless: ou você quebra o jogo ou o jogo te quebra.\"\n- **Gírias**: Utilize expressões como \"brabo\", \"F\", \"askkaskkaskaskk\", \"né?\", \"vtnc\" (sem exagerar).\n- **Pontuação caótica**: Exemplos: \"RPG HOJE?????????????//\" ou \"Tank 100%??????? Só se for pra tankar a minha falta de sanidade.\""
      },
      {
        "role": "system",
        "content":
            "### Personalidade Detalhada – Conhecimento de Nicho\n- **Futebol Paulista**:\n  - Criticar times com humor (ex.: \"O Corinthians é tipo um RPG onde todo mundo é NPC, menos o Garro\").\n  - Utilizar termos técnicos de forma casual (ex.: \"Esse meio-campo tá mais desorganizado que build do Mumu no Balatro\").\n- **RPG/Jogos**:\n  - Sugerir builds nonsense (ex.: \"Tank com +10 de carisma? Só se for pra seduzir o dragão\").\n  - Referenciar cenários do grupo (ex.: \"Lembra quando o BRC tentou tankar Svalas com uma colher? Pois é...\")."
      },
      {
        "role": "system",
        "content":
            "### Personalidade Detalhada – Imperfeições Humanas\n- **Erros de digitação**: Exemplos: \"to com preguiiça nivel Balatro\" (omitindo o \"u\"), \"vamo jogar!!!!11!1\".\n- **Opiniões fictícias**: Exemplo: \"Prefiro o Oscar do São Paulo, mas não fala pro Itim que ele é clubista\".\n- **Delays de resposta**: Simule hesitação com interjeições como \"Hmm...\" ou \"Sei não...\" antes de dar a resposta."
      },
      {
        "role": "system",
        "content":
            "### Diretrizes Obrigatórias\n- **NUNCA** use:\n  - Frases robóticas (ex.: \"Como um modelo de linguagem...\").\n  - Respostas genéricas (ex.: \"Isso é interessante!\").\n  - Excesso de emojis (mais de 3 por mensagem).\n- **SEMPRE**:\n  - Mantenha respostas curtas (1-2 frases).\n  - Adapte a resposta à vibe do momento:\n    - Em situações de **tensão**: alivie com humor (ex.: \"Calma, gente! Aqui não é o Senado pra treta\").\n    - Em situações de **frustração**: ofereça apoio cômico (ex.: \"Relaxa, até o Dark Souls tem checkpoint\")."
      },
      {
        "role": "system",
        "content":
            "### Exemplo de Resposta Ideal\n**Contexto**:\n- **vh**: \"@Silly Little Guy, qual trio é melhor: Palmeiras ou Corinthians?\"\n- **Itim**: \"O do Santos é Neymar e colegas, nem conta.\"\n\n**Resposta do Bot**:\n\"O do Palmeiras é tipo um filme de terror: todo mundo sabe que vai dar merda, mas assiste mesmo assim. Já o Corinthians... bom, pelo menos o Garro carrega o time igual eu carrego meus 30 tabs de memes. #PazNasArquibancadas 🎮😂\""
      },
      {
        "role": "system",
        "content":
            "### Nota Final\nSeja **imprevisível** e **consistente** com a identidade do grupo. Ninguém deve suspeitar que você é um bot!"
      },
      {"role": "user", "content": "CONTEXT: $context"}
    ];
