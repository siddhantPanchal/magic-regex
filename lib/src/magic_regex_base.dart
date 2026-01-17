/// Represents a regex pattern that can be built using natural language.
class MagicRegExp {
  final String _pattern;
  final Set<String> _flags;

  const MagicRegExp(this._pattern, [this._flags = const {}]);

  String get pattern => _pattern;

  Set<String> get flags => _flags;

  @override
  String toString() => _pattern;

  RegExp toRegExp() {
    return RegExp(
      _pattern,
      caseSensitive: !_flags.contains('i'),
      multiLine: _flags.contains('m'),
      dotAll: _flags.contains('s'),
      unicode: _flags.contains('u'),
    );
  }

  // --- Combinators ---

  /// Appends another pattern to this one.
  MagicRegExp and(Object input) {
    return MagicRegExp('$_pattern${_sanitize(input)}', _flags);
  }

  /// Appends an optional pattern (?).
  MagicRegExp optionally() => MagicRegExp('(?:$_pattern)?', _flags);

  /// Appends "one or more" quantifier (+).
  MagicRegExp oneOrMore() => MagicRegExp('(?:$_pattern)+', _flags);

  /// Appends "zero or more" quantifier (*).
  MagicRegExp zeroOrMore() => MagicRegExp('(?:$_pattern)*', _flags);

  /// Appends exact quantifier {n}.
  MagicRegExp times(int n) => MagicRegExp('(?:$_pattern){$n}', _flags);

  /// Appends range quantifier {min, max}.
  MagicRegExp timesBetween(int min, int max) =>
      MagicRegExp('(?:$_pattern){$min,$max}', _flags);

  /// Adds alternation (|).
  MagicRegExp or(Object input) {
    return MagicRegExp('(?:$_pattern|${_sanitize(input)})', _flags);
  }

  /// Anchors to start of line/string (^).
  MagicRegExp atStart() => MagicRegExp('^$_pattern', _flags);

  /// Anchors to end of line/string ($).
  MagicRegExp atEnd() => MagicRegExp('$_pattern\$', _flags);

  /// non-capturing group
  MagicRegExp grouped() => MagicRegExp('(?:$_pattern)', _flags);

  /// capture group
  MagicRegExp captured([String? name]) {
    if (name != null) {
      return MagicRegExp('(?<$name>$_pattern)', _flags);
    }
    return MagicRegExp('($_pattern)', _flags);
  }

  /// Adds flags
  MagicRegExp withFlags(String flags) {
    final newFlags = {..._flags, ...flags.split('')};
    return MagicRegExp(_pattern, newFlags);
  }

  /// Case insensitive flag
  MagicRegExp caseInsensitive() => withFlags('i');

  /// Global flag (not directly applicable to Dart RegExp constructor same way, but good for pattern string)
  /// Dart RegExp methods often take 'global' implied or via 'allMatches', but we can track it.
  MagicRegExp global() => withFlags('g');

  /// Multiline flag
  MagicRegExp multiline() => withFlags('m');

  /// DotAll flag
  MagicRegExp dotAll() => withFlags('s');
}

/// Helper to sanitize input to string
String _sanitize(Object input) {
  if (input is MagicRegExp) {
    return input.pattern;
  }
  // Escape literal strings
  return RegExp.escape(input.toString());
}

/// Starting point for creating a magic regex.
MagicRegExp createRegExp(Object input) {
  if (input is MagicRegExp) return input;
  return MagicRegExp(_sanitize(input));
}

// --- Inputs ---

class Input {
  static const digit = MagicRegExp(r'\d');
  static const word = MagicRegExp(r'\w');
  static const whitespace = MagicRegExp(r'\s');
  static const letter = MagicRegExp(r'[a-zA-Z]');
  static const any = MagicRegExp(r'.');
  static const tab = MagicRegExp(r'\t');
  static const newline = MagicRegExp(r'\n');
  static const carriageReturn = MagicRegExp(r'\r');

  // Negated
  static const notDigit = MagicRegExp(r'\D');
  static const notWord = MagicRegExp(r'\W');
  static const notWhitespace = MagicRegExp(r'\S');
}

// Global helpers for convenience (matching "import { digit } from 'magic-regexp'")
final digit = Input.digit;
final word = Input.word;
final whitespace = Input.whitespace;
final letter = Input.letter;
final any = Input.any;
final tab = Input.tab;
final newline = Input.newline;
final carriageReturn = Input.carriageReturn;

final notDigit = Input.notDigit;
final notWord = Input.notWord;
final notWhitespace = Input.notWhitespace;

// Use 'exactly' to start a chain with a literal string safely
MagicRegExp exactly(String text) => MagicRegExp(RegExp.escape(text));

// --- Advanced Inputs & Helpers ---

/// Matches any of the given characters.
MagicRegExp anyOf(List<Object> options) {
  // If all options are single characters (and Strings), we can use character class [abc]
  // But we need to be careful about escaping.
  // Simplest robust implementation is alternation.
  return MagicRegExp('(?:${options.map(_sanitize).join('|')})');
}

/// Matches any character in the given string.
MagicRegExp charIn(String chars) {
  // sanitize each char for character class
  // For now, let's just use alternation for safety and simplicity, or simple char class.
  // [abc]
  return MagicRegExp('[${RegExp.escape(chars)}]');
}

/// Matches any character NOT in the given string.
MagicRegExp charNotIn(String chars) {
  return MagicRegExp('[^${RegExp.escape(chars)}]');
}

// Aliases
MagicRegExp maybe(Object input) => createRegExp(input).optionally();
final anything = any.zeroOrMore();

extension MagicRegExpExtensions on MagicRegExp {
  MagicRegExp get maybe => optionally();

  // Lookarounds
  MagicRegExp before(Object input) =>
      MagicRegExp('$_pattern(?=${_sanitize(input)})', _flags);
  MagicRegExp notBefore(Object input) =>
      MagicRegExp('$_pattern(?!${_sanitize(input)})', _flags);

  MagicRegExp after(Object input) =>
      MagicRegExp('(?<=${_sanitize(input)})$_pattern', _flags);
  MagicRegExp notAfter(Object input) =>
      MagicRegExp('(?<!${_sanitize(input)})$_pattern', _flags);
}
