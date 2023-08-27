import 'dart:math';
import 'package:mathriddles/riddle_condition_checker.dart';
import 'package:mathriddles/riddle_conditions.dart';
import 'package:mathriddles/shorthand_conditions.dart';
import 'dart:collection';


class RiddleResult {
  final int number;
  final String riddleNormal;
  final String riddleShort;


  RiddleResult({required this.number, required this.riddleNormal, required this.riddleShort});
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
    int length = number.toString().length;
    int minNumber = pow(10, length - 1).toInt();
    int maxNumber = (pow(10, length) - 1).toInt();

    if (minNumber >= maxNumber) {
      //print('Invalid range: minNumber should be less than maxNumber.');
      return [];
    }

    Set<int> possibleNumbers = Set.from(
        List.generate(maxNumber - minNumber + 1, (index) => index + minNumber));

    List<String> finalConditions = [];
    List<String> conditions = riddleConditions.generalCondition(
        number.toString().split('').map((char) => int.parse(char)).toList());
    Queue<String> conditionsQueue = Queue.from(conditions);

    int iterationLimit = 100;  // Set a limit on iterations
    int currentIteration = 0;

    while (possibleNumbers.length != 1 && currentIteration < iterationLimit) {
      currentIteration++;

      if (possibleNumbers.isEmpty) {
       // print('No possible numbers left.');
        break;
      }

      if (conditionsQueue.isEmpty) {
       // print('No more conditions left to try.');
        break;
      }

      String selectedCondition = conditionsQueue.removeFirst();
      //print('Selected condition: $selectedCondition');

      Set<int> filteredNumbers = possibleNumbers.where((number) {
        List<int> numDigits = number.toString().split('').map((char) =>
            int.parse(char)).toList();

        return conditionChecker.satisfiesCondition(numDigits, selectedCondition);
      }).toSet();

      if (filteredNumbers.isNotEmpty &&
          filteredNumbers.length < possibleNumbers.length) {
        possibleNumbers = filteredNumbers;
        finalConditions.add(selectedCondition);
      } else {
        //print('Condition didn\'t help in filtering. Numbers remained the same.');
      }
    }

    return finalConditions;
  }


  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = int.parse(digits.join(''));

    List<String> finalConditions = syphonThroughPossibilities(number);

    String riddleTextNormal = 'I\'m a ${digits.length}-digit number\n';
    String riddleTextShort = 'I\'m a ${digits.length}-digit number\n';

    for (int i = 0; i < finalConditions.length; i++) {
      String condition = finalConditions[i];
      riddleTextNormal += condition;

      // Always generate the shorthand condition for the shorthand version
      ShortHandConditions shorthand = ShortHandConditions();
      String conditionShort = shorthand.getShorthandCondition(condition, digitNames);
      riddleTextShort += conditionShort;
    }

    return RiddleResult(number: number, riddleNormal: riddleTextNormal, riddleShort: riddleTextShort);
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

}
