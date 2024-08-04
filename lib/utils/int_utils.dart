// Dart imports:
import 'dart:math';

extension IntX on int {
  int digitCount({
    double epsilonOffset = 0.0000000001,
  }) {
    if (this == 0) return 1;

    // Adding a small epsilon before flooring
    return (log(abs()) / ln10 + epsilonOffset).floor() + 1;
  }
}

int parseIntSafe(
  dynamic value, {
  int fallback = 0,
}) =>
    switch (value) {
      int i => i,
      double d => d.toInt(),
      String s => int.tryParse(s) ?? fallback,
      _ => fallback,
    };
