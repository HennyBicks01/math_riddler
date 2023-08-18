import 'dart:math';

class RiddleResult {
  final int number;
  final String riddle;

  RiddleResult({required this.number, required this.riddle});
}

class RiddleGenerator {
  final Random _random = Random();

  Set<String> processedCombinations = {};

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

    // Finding the excluded digit
    List<String> allDigits = ['hundreds', 'tens', 'ones'];
    allDigits.remove(firstDigit);
    allDigits.remove(secondDigit);
    String excludedDigit = allDigits[0];

    // Constructing the resulting two-digit number
    int resultingNumber;
    if (firstDigit == 'hundreds' || secondDigit == 'hundreds') {
      resultingNumber = first * 10 + second;
    } else {
      resultingNumber = first * 10 + second;
    }

    // Calculate the number of factors
    int factors = 0;
    for (int i = 1; i <= resultingNumber; i++) {
      if (resultingNumber % i == 0) {
        factors++;
      }
    }

    int difference = first - second;
    List<String> conditions = [];

    if (first == second) {
      conditions.add("My $firstDigit and $secondDigit digits are the same, ");
    } else {
      for (int i = 2; i <= 4; i++) {
        if (first == i * second) {
          conditions.add("My $firstDigit digit is $i times my $secondDigit digit, ");
          conditions.add("My $firstDigit digit divided by my $secondDigit digit is $i, ");
        }
        if (second == i * first) {
          conditions.add("My $secondDigit digit is $i times my $firstDigit digit, ");
          conditions.add("My $secondDigit digit divided by my $firstDigit digit is $i, ");
        }
      }

      String combinationKey = "$first-$second";

      if (!processedCombinations.contains(combinationKey)&& (pow(first, second)).toString().length != (pow(second, first)).toString().length) {
        int powerLengthFirst = (pow(first, second)).toString().length;
        conditions.add("My $firstDigit digit to the power of my $secondDigit digit results in a number with $powerLengthFirst characters, ");

        int powerLengthSecond = (pow(second, first)).toString().length;
        conditions.add("My $secondDigit digit to the power of my $firstDigit digit results in a number with $powerLengthSecond characters, ");

        processedCombinations.add(combinationKey);  // Mark this combination as processed
      }

      if (difference > 0) {
        conditions.add("My $firstDigit digit is $difference more than my $secondDigit digit, ");
      } else if (difference < 0) {
        conditions.add("My $firstDigit digit is ${-difference} less than my $secondDigit digit, ");
      }

      conditions.add("Excluding my $excludedDigit digit, my number has $factors factors, ");
    }

    return conditions;
  }


  List<String> _generalCondition(List<int> digits) {
    List<String> conditions = [];
    List<String> digitNames = ['hundreds', 'tens', 'ones'];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int k = 3 - i - j;
        if (i != j) {
          // Product of two digits equals the square of the third
          if (digits[i] * digits[j] == digits[k] * digits[k]) {
            conditions.add(
                "The product of my ${digitNames[i]} and ${digitNames[j]} digits equals the square of my ${digitNames[k]} digit.");
          }

          // One digit is divisible by the sum of the other two
          if ((digits[i] + digits[j]) != 0 && digits[k] != 0 &&
              digits[k] % (digits[i] + digits[j]) == 0) {
            int result = digits[k] ~/ (digits[i] + digits[j]);
            conditions.add(
                "My ${digitNames[k]} digit divided by the sum of my ${digitNames[i]} and ${digitNames[j]} digits gives $result.");
          }

          // Pythagorean triple condition
          if (digits[i] * digits[i] + digits[j] * digits[j] ==
              digits[k] * digits[k] && !conditions.contains(
              "My digits would make a perfect right triangle.")) {
            conditions.add("My digits would make a perfect right triangle.");
          }

          // Combining two digits and dividing by the third results in an integer
          int combinedNumber = int.parse('${digits[i]}${digits[j]}');
          if (digits[k] != 0 && digits[k] > 2 && combinedNumber % digits[k] == 0) {
            int result = combinedNumber ~/ digits[k];
            conditions.add("Connecting my ${digitNames[i]} and ${digitNames[j]} digits and dividing by my ${digitNames[k]} digit gives $result.");
          }
        }
      }
    }

    conditions.add("The sum of my digits is ${digits[0] + digits[1] + digits[2]}.");
    conditions.add("The product of all my digits is ${digits[0] * digits[1] * digits[2]}.");

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

    String riddleText = 'I am a three-digit number. '
        '${_randomChoice(firstCondition)}'
        '${_randomChoice(secondCondition)}'
        '${_randomChoice(_generalCondition(digits))}';


    return RiddleResult(number: number, riddle: riddleText);
  }


  String _randomChoice(List<String> options) {
    return options[_random.nextInt(options.length)];
  }

}
