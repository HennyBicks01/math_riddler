import 'dart:math';
import 'package:mathriddles/riddle_condition_checker.dart';
import 'package:mathriddles/riddle_conditions.dart';

class RiddleResult {
  final int number;
  final String riddle;

  RiddleResult({required this.number, required this.riddle});
}

class RiddleGenerator {
  final Random _random = Random();
  final RiddleConditionChecker conditionChecker = RiddleConditionChecker();
  final RiddleConditions riddleConditions = RiddleConditions();

  int minDigits = 3;
  int maxDigits = 3;

  List<int> _generateNumber() {
    int numDigits = _random.nextInt(maxDigits - minDigits + 1) + minDigits; // Generates a number between minDigits and maxDigits
    List<int> number = [];
    // Ensure the first digit is never zero
    number.add(_random.nextInt(9) + 1);
    // For the remaining digits
    for (int i = 1; i < numDigits; i++) {
      number.add(_random.nextInt(10));
    }
    return number;
  }

  List<String> syphonThroughPossibilities(int number) {
    // Determine the range based on the number of digits in the given number.
    int length = number.toString().length;
    int minNumber = pow(10, length - 1).toInt();
    int maxNumber = (pow(10, length) - 1).toInt();

    if (minNumber >= maxNumber) {
      print('Invalid range: minNumber should be less than maxNumber.');
      return [];
    }

    List<int> possibleNumbers = List.generate(
        maxNumber - minNumber + 1, (index) => index + minNumber);

    List<String> finalConditions = [];
    List<String> conditions = riddleConditions.generalCondition(
        number.toString().split('').map((char) => int.parse(char)).toList());

    while (possibleNumbers.length != 1) {
      if (possibleNumbers.isEmpty) {
        print('No possible numbers left.');
        break;
      }

      // Directly choose a condition from the main conditions list.
      // Using the 'this.' prefix to access the class's instance of Random
      String selectedCondition = conditions[_random.nextInt(conditions.length)];
      print('Selected condition: $selectedCondition');

      // Filter the list of possible numbers based on the selected condition
      List<int> filteredNumbers = possibleNumbers.where((number) {
        // Convert the current number to a list of digits.
        List<int> numDigits = number.toString().split('').map((char) =>
            int.parse(char)).toList();

        return conditionChecker.satisfiesCondition(
            numDigits, selectedCondition);
      }).toList();

      if (filteredNumbers.isNotEmpty &&
          filteredNumbers.length < possibleNumbers.length) {
        // Update possibleNumbers if the filtering is successful.
        possibleNumbers = filteredNumbers;
        print('Numbers that passed this condition: $possibleNumbers');

        finalConditions.add(selectedCondition);
        conditions.remove(
            selectedCondition); // Remove the condition from the main list to avoid repetition
      } else {
        print('Condition didn\'t help in filtering. Numbers remained the same.');
        conditions.remove(
            selectedCondition); // Remove the ineffective condition
      }

      // Check if there are no more conditions to try
      if (conditions.isEmpty) {
        print('No more conditions left to try.');
        break;
      }
    }

    return finalConditions;
  }

  RiddleResult generateRiddle({required bool isShorthandMode}) {
    List<int> digits = _generateNumber();
    int number = int.parse(digits.join(''));

    List<String> finalConditions = syphonThroughPossibilities(number);

    String riddleText = 'I am a ${digits.length}-digit number.\n';
    for (int i = 0; i < finalConditions.length; i++) {
      String condition = finalConditions[i];

      // Modify the condition if shorthand mode is ON
      if (isShorthandMode) {
        condition = _getShorthandCondition(condition, digitNames);
      }

      riddleText += condition;
    }

    return RiddleResult(number: number, riddle: riddleText);
  }

  String _getShorthandCondition(String condition, List<String> digitNames) {
    if (condition.contains("more than")) {
      RegExp exp = RegExp(r"My (\w+) digit is (\d+) more than my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String difference = match.group(2)!;
        String secondDigit = _digitInitial(match.group(3)!);
        return '$firstDigit + $difference = $secondDigit\n';
      }
    }

    else if (condition.contains("less than")) {
      RegExp exp = RegExp(r"My (\w+) digit is (\d+) less than my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String difference = match.group(2)!;
        String secondDigit = _digitInitial(match.group(3)!);
        return '$firstDigit - $difference = $secondDigit\n';
      }
    }

    else if (condition.contains("is the same as")) {
      RegExp exp = RegExp(r"My (\w+) digit is the same as my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String secondDigit = _digitInitial(match.group(2)!);
        return '$firstDigit = $secondDigit\n';
      }
    }

    else if (condition.contains("times bigger than")) {
      RegExp exp = RegExp(r"My (\w+) digit is (\d+) times bigger than my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String times = match.group(2)!;
        String secondDigit = _digitInitial(match.group(3)!);
        return '$firstDigit = $times x $secondDigit\n';
      }
    }

    else if (condition.contains("product of my") && condition.contains("equals the square of my")) {
      RegExp exp = RegExp(r"The product of my (\w+) and (\w+) digits equals the square of my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String secondDigit = _digitInitial(match.group(2)!);
        String thirdDigit = _digitInitial(match.group(3)!);
        return '$firstDigit x $secondDigit = $thirdDigit^2\n';
      }
    }

    else if (condition.contains("digit divided by the sum of my")) {
      RegExp exp = RegExp(r"My (\w+) digit divided by the sum of my (\w+) and (\w+) digits gives (\d+)");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String dividendDigit = _digitInitial(match.group(1)!);
        String firstSummand = _digitInitial(match.group(2)!);
        String secondSummand = _digitInitial(match.group(3)!);
        String quotient = match.group(4)!;
        return '$dividendDigit / ($firstSummand + $secondSummand) = $quotient\n';
      }
    }

    else if (condition.contains("Connecting my") && condition.contains("dividing by my")) {
      RegExp exp = RegExp(r"Connecting my (\w+) and (\w+) digits and dividing by my (\w+) digit gives (\d+)");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String secondDigit = _digitInitial(match.group(2)!);
        String divisor = _digitInitial(match.group(3)!);
        String result = match.group(4)!;
        return '((10*$firstDigit)+($secondDigit)) / $divisor = $result\n';
      }
    }

    else if (condition.contains("average of my") && condition.contains("is equal to my")) {
      RegExp exp = RegExp(r"The average of my (\w+) and (\w+) digits is equal to my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String secondDigit = _digitInitial(match.group(2)!);
        String averageDigit = _digitInitial(match.group(3)!);
        return 'avg($firstDigit, $secondDigit) = $averageDigit\n';
      }
    }

    else if (condition.contains("product of my") && condition.contains("is equal to the sum of my")) {
      RegExp exp = RegExp(r"The product of my (\w+) and (\w+) digits is equal to the sum of my (\w+) and (\w+) digits");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstMultiplier = _digitInitial(match.group(1)!);
        String secondMultiplier = _digitInitial(match.group(2)!);
        String firstAddend = _digitInitial(match.group(3)!);
        String secondAddend = _digitInitial(match.group(4)!);
        return '$firstMultiplier x $secondMultiplier = $firstAddend + $secondAddend\n';
      }
    }

    else if (condition.contains("two numbers are complementary")) {
      RegExp exp = RegExp(r"If you connect my (\w+) and (\w+) digits, and then my (\w+) and (\w+) digits, the two numbers are complementary");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigitA = _digitInitial(match.group(1)!);
        String secondDigitA = _digitInitial(match.group(2)!);
        String firstDigitB = _digitInitial(match.group(3)!);
        String secondDigitB = _digitInitial(match.group(4)!);
        return '((10*$firstDigitA)+($secondDigitA)) + ((10*$firstDigitB)+($secondDigitB)) = 90\n';
      }
    }

    // Sum of all numbers
    else if (condition.contains("The sum of my digits")) {
      RegExp exp = RegExp(r'The sum of my digits is (\d+)\.');
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String sum = match.group(1)!;
        return 'Sum = $sum\n';
      }
    }

    // Product of all numbers
    else if (condition.contains("The product of all my digits")) {
      RegExp exp = RegExp(r'The product of all my digits is (\d+)\.');
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String product = match.group(1)!;
        return 'Product = $product\n';
      }
    }

    // Ascending order check
    else if (condition.contains("My digits are in ascending order")) {
      return 'Ascending\n';
    }

    // Descending order check
    else if (condition.contains("My digits are in descending order")) {
      return 'Descending\n';
    }

    // Mirrored number check
    else if (condition.contains("My digits form a mirrored number")) {
      return 'Mirrored\n';
    }

    // Fibonacci number check
    else if (condition.contains("I'm in the Fibonacci sequence")) {
      return 'Fibonacci\n';
    }

    else if (condition.contains("If my") && condition.contains("raised to the power of my")) {
      RegExp exp = RegExp(r'If my (\w+) digit was raised to the power of my (\w+) digit, the result would be (\d+) digits\.');
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String baseDigit = _digitInitial(match.group(1)!);
        String exponentDigit = _digitInitial(match.group(2)!);
        String digitsCount = match.group(3)!;
        return '$baseDigit^$exponentDigit = $digitsCount digits\n';
      }
    }

    // If the condition is not recognized by any pattern, return it unchanged
    return condition;
  }

  // Usage
  List<String> digitNames = [
    "ones",
    "tens",
    "hundreds",
    "thousands",
    "tenThousands",
    "hundredThousands",
    "millions"
  ];

  String _digitInitial(String digitName) {
    switch (digitName) {
      case 'ones':
        return 'o';
      case 'tens':
        return 't';
      case 'hundreds':
        return 'h';
      case 'thousands':
        return 'T';
      case 'tenThousands':
        return 'tT';
      case 'hundredThousands':
        return 'hT';
      case 'millions':
        return 'm';
      default:
        return digitName[0];  // Return the first letter as default
    }
  }
}
