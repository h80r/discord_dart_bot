import 'package:discord_dart_bot/link_fixers/twitter.dart';
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
}
