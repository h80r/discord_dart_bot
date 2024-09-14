import 'package:discord_dart_bot/link_fixers/link_fixer.dart';
import 'package:test/test.dart';

void main() {
  group('Twitter Link Fixer', () {
    test('should affirm message needs fixing', () {
      // Arrange
      const fixer = TwitterFixer();
      const message =
          'https://x.com/Baeyonetta/status/1829577251676950864?t=K4WjSL10cHwuIfWox9fCAQ&s=33';

      // Act
      final result = fixer.shouldFix(message);

      // Assert
      expect(result, true);
    });

    test('should affirm message does not need fixing', () {
      // Arrange
      const fixer = TwitterFixer();
      const message = 'a clean message without links to fix';

      // Act
      final result = fixer.shouldFix(message);

      // Assert
      expect(result, false);
    });

    test('should fix link without query string', () {
      // Arrange
      const fixer = TwitterFixer();
      const message = 'https://x.com/LOL_ENGRAcADA/status/1829542264630382635';

      // Act
      final (_, [newLink]) = fixer.fixMessage(message);

      // Assert
      expect(newLink,
          'https://fixupx.com/LOL_ENGRAcADA/status/1829542264630382635');
    });

    test('should fix link with query string', () {
      // Arrange
      const fixer = TwitterFixer();
      const message =
          'https://x.com/Baeyonetta/status/1829577251676950864?t=K4WjSL10cHwuIfWox9fCAQ&s=33';

      // Act
      final (_, [newLink]) = fixer.fixMessage(message);

      // Assert
      expect(
          newLink, 'https://fixupx.com/Baeyonetta/status/1829577251676950864');
    });

    test('should hide link in message as markdown', () {
      // Arrange
      const fixer = TwitterFixer();
      const message = 'https://x.com/LOL_ENGRAcADA/status/1829542264630382635';

      // Act
      final (newMessage, _) = fixer.fixMessage(message);

      // Assert
      expect(newMessage,
          '~~[Link 1](https://x.com/LOL_ENGRAcADA/status/1829542264630382635)~~');
    });

    test('should remove query string in message', () {
      // Arrange
      const fixer = TwitterFixer();
      const message =
          'https://x.com/Baeyonetta/status/1829577251676950864?t=K4WjSL10cHwuIfWox9fCAQ&s=33';

      // Act
      final (newMessage, _) = fixer.fixMessage(message);

      // Assert
      expect(newMessage,
          '~~[Link 1](https://x.com/Baeyonetta/status/1829577251676950864)~~');
    });
  });

  group('Tiktok Link Fixer', () {
    test('should affirm message needs fixing', () {
      // Arrange
      const fixer = TiktokFixer();
      const message = 'https://www.tiktok.com/t/ZMhdw64Jv/';

      // Act
      final result = fixer.shouldFix(message);

      // Assert
      expect(result, true);
    });

    test('should fix link', () {
      // Arrange
      const fixer = TiktokFixer();
      const message = 'https://www.tiktok.com/t/ZMhdw64Jv/';

      // Act
      final (_, [newLink]) = fixer.fixMessage(message);

      // Assert
      expect(newLink, 'https://www.vxtiktok.com/t/ZMhdw64Jv/');
    });
  });

  group('Reddit Link Fixer', () {
    test('should affirm message needs fixing', () {
      // Arrange
      const fixer = RedditFixer();
      const message = 'https://www.reddit.com/r/Twitter_Brasil/s/VvuP5CE8os';

      // Act
      final result = fixer.shouldFix(message);

      // Assert
      expect(result, true);
    });

    test('should fix link', () {
      // Arrange
      const fixer = RedditFixer();
      const message =
          'https://www.reddit.com/r/EASportsFC/comments/126oy4x/this_is_how_to_change_commentary_language_in_fifa/';

      // Act
      final (_, [newLink]) = fixer.fixMessage(message);

      // Assert
      expect(newLink,
          'https://www.vxreddit.com/r/EASportsFC/comments/126oy4x/this_is_how_to_change_commentary_language_in_fifa/');
    });
  });
}
