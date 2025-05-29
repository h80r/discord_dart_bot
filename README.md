# Discord Dart Bot

A Discord bot written in Dart that offers several useful features for the server.

## Features

### Commands
- `/todo <text>` - Adds a new task to the list
- `/todos` - Lists all stored tasks
- `/todo-remove <number>` - Removes a task by its number
- `/bf` - Reacts with 🧠🌫️ when someone has brain fog
- `/play <url>` - Plays YouTube music (only in the music channel)

### Automatic Features
- Daily daoist wisdom proverbs
- Auto-fix for social media links:
  - Twitter
  - TikTok
  - Reddit
- AI responses when mentioned
- Daily games (Wordle, Bandle)

## Setup

### Prerequisites
- Dart SDK ^3.5.0
- Java 17+ (for Lavalink)
- Node.js (optional, for gitmoji)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/discord_dart_bot.git
cd discord_dart_bot
```

2. Install dependencies:
```bash
dart pub get
```

3. Configure Lavalink:
   - Download [Lavalink.jar](https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar)
   - Place the file in `./lavalink/`
   - Run in a separate terminal:
   ```bash
   cd ./lavalink && java -jar Lavalink.jar
   ```

4. Configure environment variables:
   - Create a `.env` file in the project root
   - Add the following variables:
   ```
   DISCORD_TOKEN=your_token_here
   DEEPSEEK_TOKEN=your_token_here
   ```

5. Run the bot:
```bash
dart run
```

## Project Structure

```
discord_dart_bot/
├── bin/                    # Bot entry point
├── lib/                    # Source code
│   ├── ai_response/       # AI response system
│   ├── link_fixers/       # Link fixers
│   └── ...
├── lavalink/              # Audio server
├── .env                   # Environment variables
├── .todo.log             # TODO storage
└── .proverb.log          # Proverb history
```
