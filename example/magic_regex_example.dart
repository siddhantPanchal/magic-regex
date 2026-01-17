import 'package:magic_regex/magic_regex.dart';

void main() {
  // Create a regex that matches a standard URL
  final regex = createRegExp(
    exactly('http')
        .optionally()
        .and('s')
        .and('://')
        .and(anyOf([word, '.']).oneOrMore())
        .atStart()
        .atEnd(),
  );

  print(
    'Pattern: $regex',
  ); // ^(?:http)?s://(?:(?:\w|\.))+&  (Wait, I need to check my anyOf logic logic for sanitization)

  final input = 'https://example.com';
  print('Matches: ${regex.toRegExp().hasMatch(input)}');
}
