# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.7] - 04-06-2025

### Added
- Auto-reaction with :pog: emoji when "japão" is mentioned in messages (including variations like "japao" and l33t speak)

## [0.3.6] - 29-05-2025

### Improved
- Enhanced proverb generation system to avoid repetitive patterns and encourage more diverse themes
- Added Mao Tse Tung style to proverb generation while maintaining diversity

## [0.3.5] - 29-05-2025

### Added
- Added "literalmente" to bot's banned words list
- Added Sunday as a voting option in the RPG poll

### Fixed
- Changed TODO system to append new tasks at the end of the list instead of the beginning
- Fixed daily proverb system to only send messages at scheduled time (11:00) instead of on bot startup

## [0.3.4] - 28-05-2025

### Added
- Changelog file to track project changes
- Documentation of version history and improvements

### Improved
- Better project organization and documentation
- Version tracking and change management

## [0.3.3]

### Added
- `/todo` command to add new tasks
- `/todos` command to list all tasks
- `/todo-remove` command to remove tasks by number
- Local TODO storage in `.todo.log`
- Added `.todo.log` to `.gitignore`

### Fixed
- Adjusted TODO removal command to use `/todo-remove` instead of `/todos remove` due to library limitations

## [0.3.2]

### Added
- Reddit link support
- TikTok link support
- Twitter link support
- Social media link auto-fix system
- Option to delete fixed messages by original author

### Improved
- Code refactoring for better organization
- Better error handling
- Unit tests added

## [0.3.1]

### Added
- `/bf` command for brain fog
- `/play` command for music playback
- Lavalink integration for audio streaming
- YouTube music playback support

### Improved
- Optimized Lavalink configuration
- Better visual feedback for music commands

## [0.3.0]

### Added
- Daily proverb system
- Local proverb storage in `.proverb.log`
- Basic bot commands
- Discord integration using nyxx
- AI response system using DeepSeek

## [0.2.4]

### Added
- Audio bot implementation (v1)
- Lavalink integration for audio streaming

## [0.2.3]

### Fixed
- Fixed bug where bot would always echo messages

## [0.2.2]

### Fixed
- Fixed command not available bug

## [0.2.1]

### Added
- Error catcher for logging

## [0.2.0]

### Improved
- Code cleanup and separation into libraries
- Better code organization

## [0.1.3]

### Added
- Brain fog reaction (🧠🌫️)
- Command system implementation

## [0.1.2]

### Added
- Daily wordle implementation
- Cron job support

## [0.1.1]

### Added
- Tormenta25 helper implementation
- HTTP client integration

## [0.1.0]

### Added
- Message logger for reactions
- Iterative message deletion

## [0.0.6]

### Added
- Bot message deletion on custom emoji

## [0.0.5]

### Added
- Reference preservation in messages

## [0.0.4]

### Added
- Mobile support for links

## [0.0.3]

### Improved
- Updated message styling

## [0.0.2]

### Added
- Initial bot permissions
- Discord integration
- Environment variables support

## [0.0.1]

### Added
- Initial project setup
- Basic bot structure 