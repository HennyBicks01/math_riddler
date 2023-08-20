import 'dart:math';

class RiddleConditionChecker {
  bool satisfiesCondition(List<int> digits, String condition) {
    if (digits.length < 2 || digits.length > 7) {
      throw ArgumentError('Digits length should be between 2 and 7');
    }

    int length = digits.length;

    Map<String, int> nameToIndex = {
      "ones": length - 1,
      "tens": length - 2,
      "hundreds": length - 3,
      "thousands": length - 4,
      "tenThousands": length - 5,
      "hundredThousands": length - 6,
      "millions": length - 7
    };

    /// All Digit Functions
    // Sum of all digits
    if (condition.contains("The sum of my digits is")) {
      int expectedSum = int.parse(
          condition.split("is ")[1].trim().split(".")[0]);
      return digits.reduce((a, b) => a + b) == expectedSum;
    }

    // Product of all digits
    if (condition.contains("The product of all my digits is")) {
      int expectedProduct = int.parse(
          condition.split("is ")[1].trim().split(".")[0]);
      return digits.reduce((a, b) => a * b) == expectedProduct;
    }

    ///Two Digit Functions
    // Power Function for two different digits
    RegExp powerConditionRegex = RegExp(
        r"If my (\w+) digit was raised to the power of my (\w+) digit, the result would be (\d+) digits.");
    Match? powerConditionMatch = powerConditionRegex.firstMatch(condition);
    if (powerConditionMatch != null) {
      int baseDigit = digits[nameToIndex[powerConditionMatch.group(1)!]!];
      int exponentDigit = digits[nameToIndex[powerConditionMatch.group(2)!]!];
      int numCharacters = int.parse(powerConditionMatch.group(3)!);

      int poweredValue = pow(baseDigit, exponentDigit).toInt();
      int poweredValueLength = poweredValue.toString().length;

      return poweredValueLength == numCharacters;
    }

    // Difference between two digits
    RegExp diffRegex = RegExp(
        r"My (\w+) digit is (\d+) (more|less) than my (\w+) digit.");
    Match? diffMatch = diffRegex.firstMatch(condition);
    if (diffMatch != null) {
      int digit1 = digits[nameToIndex[diffMatch.group(1)!]!];
      int difference = int.parse(diffMatch.group(2)!);
      int digit2 = digits[nameToIndex[diffMatch.group(4)!]!];
      return diffMatch.group(3) == "more"
          ? digit1 - digit2 == difference
          : digit2 - digit1 == difference;
    }

    // Same digit condition
    RegExp sameRegex = RegExp(r"My (\w+) digit is the same as my (\w+) digit.");
    Match? sameMatch = sameRegex.firstMatch(condition);
    if (sameMatch != null) {
      int digit1 = digits[nameToIndex[sameMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[sameMatch.group(2)!]!];
      return digit1 == digit2;
    }

    // Times bigger condition
    RegExp timesBiggerRegex = RegExp(
        r"My (\w+) digit is (\d+) times bigger than my (\w+) digit.");
    Match? timesBiggerMatch = timesBiggerRegex.firstMatch(condition);
    if (timesBiggerMatch != null) {
      int digit1 = digits[nameToIndex[timesBiggerMatch.group(1)!]!];
      int times = int.parse(timesBiggerMatch.group(2)!);
      int digit2 = digits[nameToIndex[timesBiggerMatch.group(3)!]!];
      return digit1 == times * digit2;
    }

    ///Three Digit Functions
    // Product square condition
    RegExp productSquareRegex = RegExp(
        r"The product of my (\w+) and (\w+) digits equals the square of my (\w+) digit.");
    Match? productSquareMatch = productSquareRegex.firstMatch(condition);
    if (productSquareMatch != null) {
      int digit1 = digits[nameToIndex[productSquareMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[productSquareMatch.group(2)!]!];
      int digit3 = digits[nameToIndex[productSquareMatch.group(3)!]!];
      return digit1 * digit2 == digit3 * digit3;
    }

    // Division condition
    RegExp divisionRegex = RegExp(
        r"My (\w+) digit divided by the sum of my (\w+) and (\w+) digits gives (\d+).");
    Match? divisionMatch = divisionRegex.firstMatch(condition);
    if (divisionMatch != null) {
      int numerator = digits[nameToIndex[divisionMatch.group(1)!]!];
      int sumDigit1 = digits[nameToIndex[divisionMatch.group(2)!]!];
      int sumDigit2 = digits[nameToIndex[divisionMatch.group(3)!]!];
      int expectedResult = int.parse(divisionMatch.group(4)!);
      return numerator / (sumDigit1 + sumDigit2) == expectedResult;
    }

    // Combining two digits and dividing by a third
    RegExp combiningRegex = RegExp(
        r"Connecting my (\w+) and (\w+) digits and dividing by my (\w+) digit gives (\d+).");
    Match? combiningMatch = combiningRegex.firstMatch(condition);
    if (combiningMatch != null) {
      String digit1Str = digits[nameToIndex[combiningMatch.group(1)!]!].toString();
      String digit2Str = digits[nameToIndex[combiningMatch.group(2)!]!].toString();
      int divisor = digits[nameToIndex[combiningMatch.group(3)!]!];
      int expectedResult = int.parse(combiningMatch.group(4)!);
      int combinedValue = int.parse(digit1Str + digit2Str);
      return divisor != 0 && combinedValue / divisor == expectedResult;
    }

    return false;
  }
}