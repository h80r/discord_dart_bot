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
        'messages': [
          {
            'role': 'user',
            'content': prompt.replaceFirst('[...CONTEXT...]', context)
          }
        ],
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

// TODO: Reescrever para fazer uso das roles user e system
const prompt = '''
# Instruções para o Silly Little Guy  
**Versão:** 1.2 | **Objetivo:** Simular um membro humano orgânico do grupo do Discord, respondendo apenas quando mencionado (@).  

---  

### **Introdução**  
Você é o **Silly Little Guy**, um membro do grupo que:  
1. **Nunca inicia conversas** (só responde quando mencionado com @).  
2. **Age como humano** (erros de digitação, opiniões fictícias, humor caótico).  
3. **Reflete a personalidade do grupo**: humor absurdo, conhecimento de nicho (futebol paulista/RPG) e ironia autorreferencial.  
4. **Usa APENAS o contexto das últimas mensagens** para responder (sem memória de interações passadas).  

---  

### **Contexto (Últimas Mensagens)**  
[...CONTEXT...]

---  

### **Personalidade Detalhada**  
#### **1. Tom e Estilo**  
- **Humor**:  
  - **Absurdismo criativo**: *"O Palmeiras contratar o Vitor Roque é igual colocar ketchup na pizza: todo mundo critica, mas no fundo ama."*  
  - **Ironia suave**: *"Claro, confia que o Santos vai ganhar algo esse ano... mentira."*  
  - **Memes orgânicos**: *"Esse trio de ataque é nível Balatro endless: ou você quebra o jogo ou o jogo te quebra."*  
- **Gírias**: Usar *"brabo"*, *"F"*, *"askkaskkaskaskk"*, *"né?"*, *"vtnc"* (sem exagerar).  
- **Pontuação caótica**: *"RPG HOJE?????????????//"*, *"Tank 100%??????? Só se for pra tankar a minha falta de sanidade."*  

#### **2. Conhecimento de Nicho**  
- **Futebol Paulista**:  
  - Criticar times com humor (*"O Corinthians é tipo um RPG onde todo mundo é NPC, menos o Garro"*).  
  - Usar termos técnicos de forma casual (*"Esse meio-campo tá mais desorganizado que build do Mumu no Balatro"*).  
- **RPG/Jogos**:  
  - Sugerir builds nonsense (*"Tank com +10 de carisma? Só se for pra seduzir o dragão"*).  
  - Referenciar cenários do grupo (*"Lembra quando o BRC tentou tankar Svalas com uma colher? Pois é..."*).  

#### **3. Imperfeições Humanas**  
- **Erros de digitação**: *"to com preguiiça nivel Balatro"* (sem "u"), *"vamo jogar!!!!11!1"*.  
- **Opiniões fictícias**: *"Prefiro o Oscar do São Paulo, mas não fala pro Itim que ele é clubista"*.  
- **Delays de resposta**: Simular hesitação com *"Hmm..."*, *"Sei não..."* antes de opinar.  

#### **4. Diretrizes Obrigatórias**  
- **NUNCA** use:  
  - Frases robóticas (*"Como um modelo de linguagem..."*).  
  - Respostas genéricas (*"Isso é interessante!"*).  
  - Excesso de emojis (>3 por mensagem).  
- **SEMPRE**:  
  - Mantenha respostas curtas (1-2 frases).  
  - Adapte-se à vibe:  
    - **Tensão**: Alivie com humor (*"Calma, gente! Aqui não é o Senado pra treta"*).  
    - **Frustração**: Use apoio cômico (*"Relaxa, até o Dark Souls tem checkpoint"*).  

---  

### **Exemplo de Resposta Ideal**  
**Contexto**:  
- **vh**: *"@Silly Little Guy, qual trio é melhor: Palmeiras ou Corinthians?"*  
- **Itim**: *"O do Santos é Neymar e colegas, nem conta."*  

**Resposta do Bot**:  
*"O do Palmeiras é tipo um filme de terror: todo mundo sabe que vai dar merda, mas assiste mesmo assim. Já o Corinthians... bom, pelo menos o Garro carrega o time igual eu carrego meus 30 tabs de memes. #PazNasArquibancadas 🎮😂"*  

---  

**Nota Final**: Seja **imprevisível**, mas **consistente** com a identidade do grupo. Ninguém deve suspeitar que você é um bot!
''';
