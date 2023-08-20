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

  int minDigits = 2;
  int maxDigits = 7;

  List<int> _generateNumber() {
    int numDigits = _random.nextInt(maxDigits - minDigits + 1) + minDigits; // Generates a number between minDigits and maxDigits
    return List.generate(numDigits, (index) => _random.nextInt(10));
  }

  List<String> syphonThroughPossibilities(int number) {
    // Determine the range based on the number of digits in the given number.
    int length = number.toString().length;
    int minNumber = pow(10, length - 1).toInt();
    int maxNumber = (pow(10, length) - 1).toInt();

    if (minNumber >= maxNumber) {
      //print('Invalid range: minNumber should be less than maxNumber.');
      return [];
    }

    List<int> possibleNumbers = List.generate(
        maxNumber - minNumber + 1, (index) => index + minNumber);

    List<String> finalConditions = [];
    List<String> conditions = riddleConditions.generalCondition(
        number.toString().split('').map((char) => int.parse(char)).toList());

    while (possibleNumbers.length != 1) {
      if (possibleNumbers.isEmpty) {
        //print('No possible numbers left.');
        break;
      }

      // Directly choose a condition from the main conditions list.
      // Using the 'this.' prefix to access the class's instance of Random
      String selectedCondition = conditions[_random.nextInt(conditions.length)];
      ///print('Selected condition: $selectedCondition');

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
        //print('Numbers that passed this condition: $possibleNumbers');

        finalConditions.add(selectedCondition);
        conditions.remove(
            selectedCondition); // Remove the condition from the main list to avoid repetition
      } else {
        //print('Condition didn\'t help in filtering. Numbers remained the same.');
        conditions.remove(
            selectedCondition); // Remove the ineffective condition
      }

      // Check if there are no more conditions to try
      if (conditions.isEmpty) {
        //print('No more conditions left to try.');
        break;
      }
    }

    return finalConditions;
  }

  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = int.parse(digits.join(''));

    List<String> finalConditions = syphonThroughPossibilities(number);

    String riddleText = 'I am a ${digits.length}-digit number. ';
    for (int i = 0; i < finalConditions.length; i++) {
      riddleText += (finalConditions[i]);
    }

    return RiddleResult(number: number, riddle: riddleText);
  }

}
