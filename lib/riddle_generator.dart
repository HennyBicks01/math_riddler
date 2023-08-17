import 'dart:math';

class RiddleResult {
  final int number;
  final String riddle;

  RiddleResult({required this.number, required this.riddle});
}

class RiddleGenerator {
  final Random _random = Random();

  List<int> _generateNumber() {
    int hundreds = _random.nextInt(9) + 1;
    int tens = _random.nextInt(10);
    int ones = _random.nextInt(10);
    return [hundreds, tens, ones];
  }

  List<String> _hundredsCondition(List<int> digits) {
    int hundreds = digits[0];
    int tens = digits[1];
    int difference = hundreds - tens;
    List<String> conditions = [];

    if (hundreds == tens) {
      conditions.add("My hundreds and tens digits are the same, ");
    } else {
      if (hundreds == 2 * tens) {
        conditions.add("My hundreds digit is twice my tens digit, ");
      }
      if (tens == 2 * hundreds) {
        conditions.add("My hundreds digit is half my tens digit, ");
      }
      if (difference > 0) {
        conditions.add("My hundreds digit is $difference more than my tens digit, ");
      } else if (difference < 0) {
        conditions.add("My hundreds digit is ${-difference} less than my tens digit, ");
      }
    }

    return conditions;
  }

  List<String> _tensCondition(List<int> digits) {
    int tens = digits[1];
    int ones = digits[2];
    int difference = tens - ones;
    List<String> conditions = [];

    if (tens == ones) {
      conditions.add("and my tens and ones digits are the same. ");
    } else {
      if (tens == 2 * ones) {
        conditions.add("and my tens digit is twice my ones digit. ");
      }
      if (ones == 2 * tens) {
        conditions.add("and my tens digit is half my ones digit. ");
      }
      if (difference > 0) {
        conditions.add("and my tens digit is $difference more than my ones digit. ");
      } else if (difference < 0) {
        conditions.add("and my tens digit is ${-difference} less than my ones digit. ");
      }
    }

    return conditions;
  }

  List<String> _onesCondition(List<int> digits) {
    int hundreds = digits[0];
    int ones = digits[2];
    int difference = hundreds - ones;
    List<String> conditions = [];

    if (hundreds == ones) {
      conditions.add("My hundreds and ones digits are the same, ");
    } else {
      if (hundreds == 2 * ones) {
        conditions.add("My hundreds digit is twice my ones digit, ");
      }
      if (ones == 2 * hundreds) {
        conditions.add("My hundreds digit is half my ones digit, ");
      }
      if (difference > 0) {
        conditions.add("My hundreds digit is $difference more than my ones digit, ");
      } else if (difference < 0) {
        conditions.add("My hundreds digit is ${-difference} less than my ones digit, ");
      }
    }

    return conditions;
  }

  List<String> _generalCondition(List<int> digits) {
    int hundreds = digits[0];
    int tens = digits[1];
    int ones = digits[2];
    List<String> conditions = [];

    if (hundreds * tens == ones * ones) {
      conditions.add("The product of my hundreds and tens digits equals the square of my ones digit.");
    }
    if (hundreds * ones == tens * tens) {
      conditions.add("The product of my hundreds and ones digits equals the square of my tens digit.");
    }
    if (tens * ones == hundreds * hundreds) {
      conditions.add("The product of my tens and ones digits equals the square of my hundreds digit.");
    }
    conditions.add("The sum of my digits is ${hundreds + tens + ones}.");
    conditions.add("The product of all my digits is ${hundreds * tens * ones}.");

    return conditions;
  }


  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = digits[0] * 100 + digits[1] * 10 + digits[2];

    // Randomly select two comparative conditions
    List<List<String> Function(List<int>)> conditionMethods = [
      _hundredsCondition,
      _tensCondition,
      _onesCondition
    ];
    conditionMethods.shuffle();

    // Get the riddle conditions from the first two shuffled methods
    List<String> firstCondition = conditionMethods[0](digits);
    List<String> secondCondition = conditionMethods[1](digits);

    String riddleText = 'I am a three-digit number. ' +
        _randomChoice(firstCondition) +
        _randomChoice(secondCondition) +
        _randomChoice(_generalCondition(digits));

    return RiddleResult(number: number, riddle: riddleText);
  }

  String _randomChoice(List<String> options) {
    return options[_random.nextInt(options.length)];
  }

}
