import 'dart:math';

class RiddleResult {
  final int number;
  final String riddle;

  RiddleResult({required this.number, required this.riddle});
}

class RiddleGenerator {
  final Random _random = Random();

  // Generates the number and returns its individual digits as a list
  List<int> _generateNumber() {
    int hundreds = _random.nextInt(9) + 1;
    int tens = _random.nextInt(10);
    int ones = _random.nextInt(10);
    return [hundreds, tens, ones];
  }

  String _hundredsCondition(List<int> digits) {
    int hundreds = digits[0];
    int tens = digits[1];

    int difference = hundreds - tens;

    if (hundreds == tens) {
      return "My hundreds and tens digits are the same, ";
    } else if (hundreds == 2 * tens) {
      return "My hundreds digit is twice my tens digit, ";
    } else if (tens == 2 * hundreds) {
      return "My hundreds digit is half my tens digit, ";
    } else {
      return difference > 0
          ? "My hundreds digit is $difference more than my tens digit, "
          : "My hundreds digit is ${-difference} less than my tens digit, ";
    }
  }

  String _tensCondition(List<int> digits) {
    int tens = digits[1];
    int ones = digits[2];

    int difference = tens - ones;

    if (tens == ones) {
      return "and my tens and ones digits are the same. ";
    } else if (tens == 2 * ones) {
      return "and my tens digit is twice my ones digit. ";
    } else if (ones == 2 * tens) {
      return "and my tens digit is half my ones digit. ";
    } else {
      return difference > 0
          ? "and my tens digit is $difference more than my ones digit. "
          : "and my tens digit is ${-difference} less than my ones digit. ";
    }
  }

  String _generalCondition(List<int> digits) {
    int hundreds = digits[0];
    int tens = digits[1];
    int ones = digits[2];

    if (hundreds * tens == ones * ones) {
      return "The product of my hundreds and tens digits equals the square of my ones digit.";
    } else if (hundreds * ones == tens * tens) {
      return "The product of my hundreds and ones digits equals the square of my tens digit.";
    } else if (tens * ones == hundreds * hundreds) {
      return "The product of my tens and ones digits equals the square of my hundreds digit.";
    } else {
      return "The sum of my digits is ${hundreds + tens + ones}.";
    }
  }

  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = digits[0] * 100 + digits[1] * 10 + digits[2];
    String riddleText = 'I am a three-digit number. ' +
        _hundredsCondition(digits) +
        _tensCondition(digits) +
        _generalCondition(digits);

    return RiddleResult(number: number, riddle: riddleText);
  }
}

