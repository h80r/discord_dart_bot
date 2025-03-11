## Objectives

- [x] Auto-Fix Twitter Links
  - [x] Include info about the original poster
  - [x] Delete original message
  - [x] Resend with fixed link
  - [x] Remove unnecessary tracking data
  - [x] Keep original references to message
  - [x] Verify if the message is simply a single link. If so, ignore description creation.
  - [x] Mobile twitter support with original link
  - [x] Include option to delete created messages for the author
- [x] Auto-Fix TikTok links
- [x] Auto-Fix Reddit links
- [ ] Reduce embed clutter
  - [ ] Verify if it's possible to include the author message as a new embed after sending the auto-embed message
- [x] Fix message embed still displaying trackers
- [x] Tormenta25 - Helper
  - [x] Acompanhamento básico
  - [x] Refatorar Código
  - [ ] Deletar a mensagem prévia caso exista ao reiniciar
    - Atividade depreciada com o fim da campanha
  - [x] Incluir Error Handling
- [x] Refatorar resto do bot
- [x] Testes
  - [x] Fragmentar as functions em unidades testáveis
  - [x] Incluir testes

## Setup

- Download the latest [Lavalink.jar](https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar) and place it inside `./lavalink/`
- Run a separated process for the audio source with `cd ./lavalink && java -jar Lavalink.jar`
- Create a `./.env` with the valid `DISCORD_TOKEN` and `DEEPSEEK_TOKEN`
- Run the bot with `dart run`
