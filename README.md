# magic_regex 🪄

A readable, natural language API for building regular expressions in Dart. Inspired by [magic-regexp](https://github.com/unjs/magic-regexp).

[![Pub Version](https://img.shields.io/pub/v/magic_regex)](https://pub.dev/packages/magic_regex)
[![License: BSD-3](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

## Why Magic Regex?

Regular expressions are powerful but often cryptic and hard to maintain. `magic_regex` allows you to write regex patterns that read like plain English, making them easier to understand, debug, and maintain.

- **Human Readable**: Patterns describe *what* they match, not just *how*.
- **Type-Safe**: Use Dart constants and methods instead of string manipulation.
- **Chainable API**: Compose complex patterns step-by-step.
- **Standard RegExp Output**: Compiles into a native Dart `RegExp` object.

## Installation

Add `magic_regex` to your `pubspec.yaml`:

```yaml
dependencies:
  magic_regex: ^1.0.0
```

## Quick Start

```dart
import 'package:magic_regex/magic_regex.dart';

void main() {
  // Create a regex for a simple URL
  final regex = createRegExp(
    exactly('http')
    .and(maybe('s')) // Optionally add 's'
    .and('://')
    .and(word.oneOrMore().and('.').maybe)
    .and('google.com')
  );

  print(regex.toString()); // (?:http)(?:s)?://(?:\w)+\.(?:google\.com)
  
  final regExp = regex.toRegExp();
  print(regExp.hasMatch('https://www.google.com')); // true
}
```

## Features

### Inputs
Atomic building blocks for your patterns:
- `digit`, `word`, `whitespace`, `any`, `letter`, `tab`, `newline`.
- Negated versions: `notDigit`, `notWord`, `notWhitespace`.
- `exactly('string')`: Matches a literal string (auto-escaped).

### Combinators
Chaining methods to build logic:
- `.and(input)`: Sequence.
- `.or(input)`: Alternation (`|`).
- `.optionally()`: Optional match (`?`).
- `.oneOrMore()`: One or more (`+`).
- `.zeroOrMore()`: Zero or more (`*`).
- `.times(n)`, `.timesBetween(min, max)`: Custom quantifiers.

### Anchors & Groups
- `.atStart()`, `.atEnd()`: `^` and `$`.
- `.grouped()`: Non-capturing group `(?:...)`.
- `.captured([name])`: Capturing group `(...)` or named group `(?<name>...)`.

### Advanced 
- `anyOf([a, b, c])`: Matches any of the provided patterns.
- `charIn('abc')`: Matches any character in the string `[abc]`.
- `look.ahead`, `look.behind`: Lookaround support (via `.before()`, `.after()`, etc.).

## Examples

### URL Parsing (Complex)
```dart
final regex = exactly('http')
    .and(maybe('s'))
    .and('://')
    .maybe
    .and(word.oneOrMore().and('.').maybe)
    .and('google.com');

// matches: http://google.com, https://www.google.com, google.com, etc.
```

### Password Validation
```dart
final passwordRegex = createRegExp(
    letter.oneOrMore()
    .and(digit.oneOrMore())
    .and(anyOf(['!', '@', '#', '$']).oneOrMore())
    .atStart()
    .atEnd()
);
```

## License

BSD-3-Clause license
