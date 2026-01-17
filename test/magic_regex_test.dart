import 'package:magic_regex/magic_regex.dart';
import 'package:test/test.dart' hide anyOf;

void main() {
  group('MagicRegExp', () {
    test('Basic chaining', () {
      final regex = digit.and(word);
      expect(regex.toString(), r'\d\w');
      expect(regex.toRegExp().pattern, r'\d\w');
    });

    test('Helper functions', () {
      final regex = createRegExp(digit);
      expect(regex.toString(), r'\d');
    });

    test('Combinators', () {
      expect(digit.oneOrMore().toString(), r'(?:\d)+');
      expect(word.zeroOrMore().toString(), r'(?:\w)*');
      expect(any.optionally().toString(), r'(?:.)?');
      expect(digit.times(3).toString(), r'(?:\d){3}');
      expect(digit.timesBetween(2, 4).toString(), r'(?:\d){2,4}');
    });

    test('Alternation', () {
      expect(digit.or(word).toString(), r'(?:\d|\w)');
    });

    test('Anchors', () {
      expect(digit.atStart().toString(), r'^\d');
      expect(digit.atEnd().toString(), r'\d$');
      expect(digit.atStart().atEnd().toString(), r'^\d$');
    });

    test('Sanitization', () {
      // 'foo' should be escaped if it has regex chars, but basic strings are just literal
      expect(exactly('foo').toString(), 'foo');
      expect(exactly('.').toString(), r'\.');
    });

    test('createRegExp with string', () {
      expect(createRegExp('.').toString(), r'\.');
    });

    test('Advanced Combinators', () {
      expect(anyOf(['a', 'b', 'c']).toString(), r'(?:a|b|c)');
      expect(charIn('abc').toString(), r'[abc]');
      expect(charNotIn('abc').toString(), r'[^abc]');

      expect(maybe('a').toString(), r'(?:a)?');
      expect(digit.maybe.toString(), r'(?:\d)?');
    });

    test('Lookarounds', () {
      expect(digit.before(word).toString(), r'\d(?=\w)');
      expect(digit.notBefore(word).toString(), r'\d(?!\w)');
      expect(digit.after(word).toString(), r'(?<=\w)\d');
      expect(digit.notAfter(word).toString(), r'(?<!\w)\d');
    });

    test('Complex usage', () {
      final regex = exactly('http')
          .optionally()
          .and('s')
          .and('://')
          .and(word.oneOrMore())
          .and('.')
          .and(word.oneOrMore());

      expect(regex.toString(), r'(?:http)?s://(?:\w)+\.(?:\w)+');
    });
  });
  test('URL matching complex usage', () {
    final regex = exactly('http')
        .and(maybe('s'))
        .and('://')
        .maybe
        .and(word.oneOrMore().and('.').maybe)
        .and('google.com');

    final regExp = regex.toRegExp();
    expect(regExp.hasMatch('http://www.google.com'), isTrue);
    expect(regExp.hasMatch('https://ww.google.com'), isTrue);
    expect(regExp.hasMatch('www.google.com'), isTrue);
    expect(regExp.hasMatch('google.com'), isTrue);
  });
}
