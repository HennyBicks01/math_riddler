import 'dart:math';

class RiddleConditions {
  final Random _random = Random();

  List<String> generateDigitNames(int numDigits) {
    List<String> digitNames = [
      'ones',
      'tens',
      'hundreds',
      'thousands',
      'tenThousands',
      'hundredThousands',
      'millions'
    ];
    if (numDigits <= digitNames.length) {
      return digitNames.sublist(0, numDigits);
    }
    for (int i = digitNames.length; i < numDigits; i++) {
      digitNames.add('${i + 1}th place');
    }
    return digitNames;
  }

  List<String> generalCondition(List<int> digits) {
    List<String> conditions = [];
    int numDigits = digits.length;
    List<String> digitNames = generateDigitNames(numDigits);

    // Use combinatorics for iterating through variable digit combinations
    for (int i = 0; i < numDigits; i++) {
      for (int j = i + 1; j < numDigits; j++) {
        /// Two-digit conditions
        // temp array
        List<String> tempConditions2 = [];

        // +,-,= Functions for two different digits
        int difference = digits[i] - digits[j];
        if (difference > 0) {
          tempConditions2.add(
              "My ${digitNames[i]} digit is $difference more than my ${digitNames[j]} digit. ");
        } else if (difference < 0) {
          tempConditions2.add(
              "My ${digitNames[i]} digit is ${-difference} less than my ${digitNames[j]} digit. ");
        } else if (difference == 0) {
          tempConditions2.add(
              "My ${digitNames[i]} digit is the same as my ${digitNames[j]} digit. ");
        }

        // *,/ Functions for two different digits
        for (int multiple = 2; multiple <= 4; multiple++) {
          if (digits[i] == digits[j] * multiple) {
            tempConditions2.add(
                "My ${digitNames[i]} digit is $multiple times bigger than my ${digitNames[j]} digit. ");
          }
        }

        // randomly select one and add it to tempConditions.
        if (tempConditions2.isNotEmpty) {
          int randomIndex = _random.nextInt(tempConditions2.length);
          conditions.add(tempConditions2[randomIndex]);
          tempConditions2.clear(); // Clear the list for the next iteration.
        }

        for (int k = j + 1; k < numDigits; k++) {
          /// Three digit conditions
          // temp array
          List<String> tempConditions3 = [];

          // Product of two digits equals the square of the third
          if (digits[i] * digits[j] == digits[k] * digits[k]) {
            tempConditions3.add(
                "The product of my ${digitNames[i]} and ${digitNames[j]} digits equals the square of my ${digitNames[k]} digit. ");
          }

          // One digit is divisible by the sum of the other two
          if ((digits[i] + digits[j]) != 0 && digits[k] != 0 &&
              digits[k] % (digits[i] + digits[j]) == 0) {
            int result = digits[k] ~/ (digits[i] + digits[j]);
            tempConditions3.add(
                "My ${digitNames[k]} digit divided by the sum of my ${digitNames[i]} and ${digitNames[j]} digits gives $result. ");
          }

          // Combining two digits and dividing by the third results in an integer
          int combinedNumber = int.parse('${digits[i]}${digits[j]}');
          if (digits[k] != 0 && digits[k] > 2 &&
              combinedNumber % digits[k] == 0) {
            int result = combinedNumber ~/ digits[k];
            tempConditions3.add(
                "Connecting my ${digitNames[i]} and ${digitNames[j]} digits and dividing by my ${digitNames[k]} digit gives $result. ");
          }

          // randomly select one and add it to tempConditions.
          if (tempConditions3.isNotEmpty) {
            int randomIndex = _random.nextInt(tempConditions3.length);
            conditions.add(tempConditions3[randomIndex]);
            tempConditions3.clear(); // Clear the list for the next iteration.
          }


        }
      }
    }
    // Move the general sum and product conditions outside the loops.
    conditions.add(
        "The sum of my digits is ${digits.reduce((a, b) => a + b)}. ");
    conditions.add(
        "The product of all my digits is ${digits.reduce((a, b) => a * b)}. ");

    return conditions;
  }
}