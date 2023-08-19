import 'dart:math';

class RiddleResult {
  final int number;
  final String riddle;

  RiddleResult({required this.number, required this.riddle});
}

class RiddleGenerator {
  final Random _random = Random();
  bool hasAddedFactorCondition = false;
  Set<String> processedCombinations = {};

  List<int> _generateNumber() {
    int hundreds = _random.nextInt(9) + 1;
    int tens = _random.nextInt(10);
    int ones = _random.nextInt(10);
    return [hundreds, tens, ones];
  }

  List<String> _generalCondition(List<int> digits) {
    List<String> conditions = [];
    List<String> conditions2 = [];
    List<String> finalConditions = [];
    List<String> digitNames = ['hundreds', 'tens', 'ones'];
    Random random = Random();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int k = 3 - i - j;
        if (i != j) {
          /// Two digit conditions
          // Temporary array
          List<String> tempConditions = [];

          // +,-,= Functions for two different digits
          int difference = digits[i] - digits[j];
          if (difference > 0) {
            tempConditions.add(
                "My ${digitNames[i]} digit is $difference more than my ${digitNames[j]} digit.");
          } else if (difference < 0) {
            tempConditions.add(
                "My ${digitNames[i]} digit is ${-difference} less than my ${digitNames[j]} digit.");
          } else if (difference == 0) {
            tempConditions.add(
                "My ${digitNames[i]} digit is the same as my ${digitNames[j]} digit.");
          }

          // *,/ Functions for two different digits
          for (int multiple = 2; multiple <= 4; multiple++) {
            if (digits[i] == digits[j] * multiple) {
              tempConditions.add(
                  "My ${digitNames[i]} digit is $multiple times bigger than my ${digitNames[j]} digit.");
            }
          }

          // Randomly add a temp condition to the array
          if (tempConditions.isNotEmpty) {
            int randomIndex = random.nextInt(tempConditions.length);
            conditions2.add(tempConditions[randomIndex]);
          }

          /// Three digit conditions
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
          if (digits[k] != 0 && digits[k] > 2 &&
              combinedNumber % digits[k] == 0) {
            int result = combinedNumber ~/ digits[k];
            conditions.add(
                "Connecting my ${digitNames[i]} and ${digitNames[j]} digits and dividing by my ${digitNames[k]} digit gives $result.");
          }
        }
      }
    }

    conditions.add(
        "The sum of my digits is ${digits[0] + digits[1] + digits[2]}.");
    conditions.add("The product of all my digits is ${digits[0] * digits[1] *
        digits[2]}.");

    // Add two random entries from conditions2 ensuring they're different
    String firstCondition = conditions2[_random.nextInt(conditions2.length)];
    String secondCondition;
    do {
      secondCondition = conditions2[_random.nextInt(conditions2.length)];
    } while (secondCondition == firstCondition);
    finalConditions.add(firstCondition);
    finalConditions.add(secondCondition);

    // Add one random entry from conditions
    finalConditions.add(conditions[_random.nextInt(conditions.length)]);

    return finalConditions;
  }



  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = digits[0] * 100 + digits[1] * 10 + digits[2];

    List<String> finalConditions = _generalCondition(digits);

    String riddleText = 'I am a three-digit number. '
        '${finalConditions[0]} '
        '${finalConditions[1]} '
        '${finalConditions[2]}';

    return RiddleResult(number: number, riddle: riddleText);
  }
}
