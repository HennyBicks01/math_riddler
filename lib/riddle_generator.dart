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

  List<String> digitCondition(List<int> digits, String firstDigit, String secondDigit) {
    int first = 0;
    int second = 0;

    switch (firstDigit) {
      case 'hundreds':
        first = digits[0];
        break;
      case 'tens':
        first = digits[1];
        break;
      case 'ones':
        first = digits[2];
        break;
    }

    switch (secondDigit) {
      case 'hundreds':
        second = digits[0];
        break;
      case 'tens':
        second = digits[1];
        break;
      case 'ones':
        second = digits[2];
        break;
    }

    int difference = first - second;
    List<String> conditions = [];

    if (first == second) {
      conditions.add("My $firstDigit and $secondDigit digits are the same, ");
    } else {
      if (first == 2 * second) {
        conditions.add("My $firstDigit digit is twice my $secondDigit digit, ");
      }
      if (second == 2 * first) {
        conditions.add("My $secondDigit digit is twice my $firstDigit digit, ");
      }
      if (difference > 0) {
        conditions.add("My $firstDigit digit is $difference more than my $secondDigit digit, ");
      } else if (difference < 0) {
        conditions.add("My $firstDigit digit is ${-difference} less than my $secondDigit digit, ");
      }
    }

    return conditions;
  }

  void getRandomConditions(List<int> digits) {
    var random = Random();
    var digitNames = ['hundreds', 'tens', 'ones'];
    digitNames.shuffle(random);

    var randomConditions = digitCondition(digits, digitNames[0], digitNames[1]);
    for (var condition in randomConditions) {
      print(condition);
    }
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
    if ((tens + hundreds) != 0 && ones % (tens + hundreds) == 0) {
      int result = ones ~/ (tens + hundreds);
      conditions.add("My ones digit divided by the sum of my hundreds and tens digits gives $result.");
    }
    if ((hundreds + ones) != 0 && tens % (hundreds + ones) == 0) {
      int result = tens ~/ (hundreds + ones);
      conditions.add("My tens digit divided by the sum of my hundreds and ones digits gives $result.");
    }
    if ((tens + ones) != 0 && hundreds % (tens + ones) == 0) {
      int result = hundreds ~/ (tens + ones);
      conditions.add("My hundreds digit divided by the sum of my tens and ones digits gives $result.");
    }
    conditions.add("The sum of my digits is ${hundreds + tens + ones}.");
    conditions.add("The product of all my digits is ${hundreds * tens * ones}.");

    return conditions;
  }


  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = digits[0] * 100 + digits[1] * 10 + digits[2];

    // Define the pairs for comparative conditions
    List<List<String>> conditionPairs = [
      ['hundreds', 'tens'],
      ['tens', 'ones'],
      ['hundreds', 'ones']
    ];
    conditionPairs.shuffle();

    // Get the riddle conditions from the first two shuffled pairs
    List<String> firstCondition = digitCondition(digits, conditionPairs[0][0], conditionPairs[0][1]);
    List<String> secondCondition = digitCondition(digits, conditionPairs[1][0], conditionPairs[1][1]);

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
