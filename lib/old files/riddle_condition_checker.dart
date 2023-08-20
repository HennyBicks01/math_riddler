class RiddleConditionChecker {

  Map<String, int> nameToIndex = {
    'hundreds': 0,
    'tens': 1,
    'ones': 2,
  };


  bool satisfiesCondition(List<int> digits, String condition) {
    Map<String, int> nameToIndex = {
      'hundreds': 0,
      'tens': 1,
      'ones': 2,
    };

    // Parsing for "The sum of my digits is" condition
    if (condition.contains("The sum of my digits is")) {
      int expectedSum = int.parse(
          condition.split("is ")[1].trim().split(".")[0]);
      return (digits[0] + digits[1] + digits[2] == expectedSum);
    }

    // Parsing for "The product of all my digits is" condition
    if (condition.contains("The product of all my digits is")) {
      int expectedProduct = int.parse(
          condition.split("is ")[1].trim().split(".")[0]);
      int actualProduct = digits[0] * digits[1] * digits[2];
      return actualProduct == expectedProduct;
    }

    // Parsing for difference conditions like "My hundreds digit is X more/less than my tens digit."
    RegExp diffRegex = RegExp(
        r"My (\w+) digit is (\d+) (more|less) than my (\w+) digit.");
    Match? diffMatch = diffRegex.firstMatch(condition);
    if (diffMatch != null) {
      Map<String, int> nameToIndex = {
        'hundreds': 0,
        'tens': 1,
        'ones': 2,
      };
      int digit1 = digits[nameToIndex[diffMatch.group(1)!]!];
      int difference = int.parse(diffMatch.group(2)!);
      int digit2 = digits[nameToIndex[diffMatch.group(4)!]!];

      return diffMatch.group(3) == "more"
          ? digit1 - digit2 == difference
          : digit2 - digit1 == difference;
    }

    // Parsing for "My hundreds digit is the same as my tens digit."
    RegExp sameRegex = RegExp(
        r"My (\w+) digit is the same as my (\w+) digit.");
    Match? sameMatch = sameRegex.firstMatch(condition);
    if (sameMatch != null) {
      Map<String, int> nameToIndex = {
        'hundreds': 0,
        'tens': 1,
        'ones': 2,
      };
      int digit1 = digits[nameToIndex[sameMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[sameMatch.group(2)!]!];

      return digit1 == digit2;
    }


    // Parsing for "My hundreds digit is X times bigger than my tens digit."
    RegExp timesBiggerRegex = RegExp(
        r"My (\w+) digit is (\d+) times bigger than my (\w+) digit.");
    Match? timesBiggerMatch = timesBiggerRegex.firstMatch(condition);
    if (timesBiggerMatch != null) {
      int digit1 = digits[nameToIndex[timesBiggerMatch.group(1)!]!];
      int times = int.parse(timesBiggerMatch.group(2)!);
      int digit2 = digits[nameToIndex[timesBiggerMatch.group(3)!]!];

      return digit1 == times * digit2;
    }

    ///Three Digit Condition checks
    // Parsing for "My digits would make a perfect right triangle."
    if (condition.contains(
        "My digits would make a perfect right triangle.")) {
      return digits[0] * digits[0] + digits[1] * digits[1] ==
          digits[2] * digits[2] ||
          digits[0] * digits[0] + digits[2] * digits[2] ==
              digits[1] * digits[1] ||
          digits[1] * digits[1] + digits[2] * digits[2] ==
              digits[0] * digits[0];
    }

    // Parsing for "The product of my hundreds and tens digits equals the square of my ones digit."
    RegExp productSquareRegex = RegExp(
        r"The product of my (\w+) and (\w+) digits equals the square of my (\w+) digit.");
    Match? productSquareMatch = productSquareRegex.firstMatch(condition);
    if (productSquareMatch != null) {
      int digit1 = digits[nameToIndex[productSquareMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[productSquareMatch.group(2)!]!];
      int digit3 = digits[nameToIndex[productSquareMatch.group(3)!]!];

      return digit1 * digit2 == digit3 * digit3;
    }

    // Parsing for "My ones digit divided by the sum of my hundreds and tens digits gives X."
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

    // Parsing for "Connecting my hundreds and tens digits and dividing by my ones digit gives X."
    RegExp combiningRegex = RegExp(
        r"Connecting my (\w+) and (\w+) digits and dividing by my (\w+) digit gives (\d+).");
    Match? combiningMatch = combiningRegex.firstMatch(condition);
    if (combiningMatch != null) {
      String digit1Str = digits[nameToIndex[combiningMatch.group(1)!]!]
          .toString();
      String digit2Str = digits[nameToIndex[combiningMatch.group(2)!]!]
          .toString();
      int divisor = digits[nameToIndex[combiningMatch.group(3)!]!];
      int expectedResult = int.parse(combiningMatch.group(4)!);

      int combinedValue = int.parse(digit1Str + digit2Str);
      return divisor != 0 && combinedValue / divisor == expectedResult;
    }

    // Default return value
    return false;
  }
}