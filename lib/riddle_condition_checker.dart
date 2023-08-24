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
    // Ascending order check
    if (condition.contains("My digits are in ascending order")) {
      return _isSortedAscending(digits);
    }

    // Descending order check
    if (condition.contains("My digits are in descending order")) {
      return _isSortedDescending(digits);
    }

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

    // Mirrored number check
    if (condition.contains("My digits form a mirrored number")) {
      return isMirrored(digits.join());
    }

    // Fibonacci sequence check
    int numberFormed = int.parse(digits.join());
    if (condition.contains("I'm in the Fibonacci sequence.")) {
      return isFibonacci(numberFormed);
    }

    // Prime number check
    int numberFormed2 = int.parse(digits.join());
    if (condition.contains("I'm a prime number.")) {
      return _isPrime(numberFormed2);
    }

    // Sum of the digits until a single digit remains
    if (condition.contains("If you keep summing my digits together, you'll eventually get the number")) {
      int expectedSum = int.parse(condition.split("get the number ")[1].trim().split(".")[0]);
      return _getReducedSum(digits) == expectedSum;
    }

    // Product of the digits until a single digit remains
    if (condition.contains("If you keep multiplying my digits together, you'll eventually get the number")) {
      int expectedProduct = int.parse(condition.split("get the number ")[1].trim().split(".")[0]);
      return _getReducedProduct(digits) == expectedProduct;
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

    // Average of two digits equals the third
    RegExp averageRegex = RegExp(
        r"The average of my (\w+) and (\w+) digits is equal to my (\w+) digit.");
    Match? averageMatch = averageRegex.firstMatch(condition);
    if (averageMatch != null) {
      int digit1 = digits[nameToIndex[averageMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[averageMatch.group(2)!]!];
      int digit3 = digits[nameToIndex[averageMatch.group(3)!]!];
      double averageValue = (digit1 + digit2) / 2.0;
      return averageValue == digit3.toDouble();
    }

    ///Four Digit Functions
    //The product of the first two equals the sum of the last two
    RegExp prodSumRegex = RegExp(
        r"The product of my (\w+) and (\w+) digits is equal to the sum of my (\w+) and (\w+) digits.");
    Match? prodSumMatch = prodSumRegex.firstMatch(condition);
    if (prodSumMatch != null) {
      int digit1 = digits[nameToIndex[prodSumMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[prodSumMatch.group(2)!]!];
      int digit3 = digits[nameToIndex[prodSumMatch.group(3)!]!];
      int digit4 = digits[nameToIndex[prodSumMatch.group(4)!]!];

      return digit1 * digit2 == digit3 + digit4;
    }

    // Two pairs are compliments
    RegExp complementRegex = RegExp(
        r"If you connect my (\w+) and (\w+) digits, and then my (\w+) and (\w+) digits, the two numbers are complementary\.");
    Match? complementMatch = complementRegex.firstMatch(condition);
    if (complementMatch != null) {
      int digit1 = digits[nameToIndex[complementMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[complementMatch.group(2)!]!];
      int digit3 = digits[nameToIndex[complementMatch.group(3)!]!];
      int digit4 = digits[nameToIndex[complementMatch.group(4)!]!];

      return int.parse('$digit1$digit2') + int.parse('$digit3$digit4') == 90;
    }

    // Quadratic formula
    RegExp quadraticRegex = RegExp(
        r"Using my (\w+), (\w+), and (\w+) digits as coefficients in a quadratic equation, one solution is my (\w+) digit."
    );
    Match? quadraticMatch = quadraticRegex.firstMatch(condition);
    if (quadraticMatch != null) {
      int a = digits[nameToIndex[quadraticMatch.group(1)!]!];
      int b = digits[nameToIndex[quadraticMatch.group(2)!]!];
      int c = digits[nameToIndex[quadraticMatch.group(3)!]!];
      int expectedSolution = digits[nameToIndex[quadraticMatch.group(4)!]!];

      double determinant = (b * b) - (4 * a * c).toDouble();
      if (determinant >= 0) {
        double x1 = (-b + sqrt(determinant)) / (2 * a);
        double x2 = (-b - sqrt(determinant)) / (2 * a);

        if (x1 == expectedSolution.toDouble() || x2 == expectedSolution.toDouble()) {
          return true;
        }
      }
    }



    return false;
  }

  /// Compute the sum of the digits until a single digit remains
  int _getReducedSum(List<int> digits) {
    int sumDigits = digits.reduce((a, b) => a + b);
    while (sumDigits > 9) {
      sumDigits = sumDigits.toString().split('').map((e) => int.parse(e)).reduce((a, b) => a + b);
    }
    return sumDigits;
  }

  /// Compute the product of the digits until a single digit remains
  int _getReducedProduct(List<int> digits) {
    int productDigits = digits.reduce((a, b) => a * b);
    while (productDigits > 9 && productDigits != 0) {
      productDigits = productDigits.toString().split('').map((e) => int.parse(e)).reduce((a, b) => a * b);
    }
    return productDigits;
  }

  /// Checks if the list of digits are in ascending order
  bool _isSortedAscending(List<int> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i] >= list[i + 1]) {
        return false;
      }
    }
    return true;
  }

  /// Checks if the list of digits are in descending order
  bool _isSortedDescending(List<int> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i] <= list[i + 1]) {
        return false;
      }
    }
    return true;
  }

  /// Checks if the list of digits are Mirrored
  bool isMirrored(String number) {
    int n = number.length;

    if (n == 1) return true; // Single digits are always mirrored.

    String pattern;
    if (n % 2 == 0) { // Even number of digits
      pattern = r"^(\d{" + (n ~/ 2).toString() + r"})" +
          r"(?=\1$)";
    } else { // Odd number of digits
      pattern = r"^(\d{" + (n ~/ 2).toString() + r"})" +
          r".(?=\1$)";
    }

    RegExp regex = RegExp(pattern);
    return regex.hasMatch(number);
  }

  /// Checks if number is in fibonacci sequence
  bool isFibonacci(int num) {
    int a = 0, b = 1, temp;
    while (b <= num) {
      if (b == num) {
        return true;
      }
      temp = a;
      a = b;
      b = temp + b;
    }
    return false;
  }

  /// Checks if number is prime
  bool _isPrime(int num) {
    if (num <= 1) return false;
    if (num <= 3) return true;

    if (num % 2 == 0 || num % 3 == 0) return false;

    int i = 5;
    while (i * i <= num) {
      if (num % i == 0 || num % (i + 2) == 0) return false;
      i += 6;
    }

    return true;
  }

}