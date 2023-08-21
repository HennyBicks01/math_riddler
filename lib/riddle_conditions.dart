import 'dart:math';

class RiddleConditions {
  final Random _random = Random();

  List<String> generalCondition(List<int> digits) {
    List<String> conditions = [];

    int numDigits = digits.length;

    if (numDigits < 2 || numDigits > 7) {
      throw ArgumentError('Digits length should be between 2 and 7');
    }

    Map<int, String> indexToName = {
      numDigits - 1: "ones",
      numDigits - 2: "tens",
      numDigits - 3: "hundreds",
      numDigits - 4: "thousands",
      numDigits - 5: "tenThousands",
      numDigits - 6: "hundredThousands",
      numDigits - 7: "millions",
    };

    List<String> digitNames = List.generate(numDigits, (index) {
      return indexToName[index] ?? '${index + 1}th place';
    });

    // Use combinatorics for iterating through variable digit combinations
    for (int i = 0; i < numDigits; i++) {
      for (int j = i + 1; j < numDigits; j++) {

        /// Two-digit conditions
        // temp array
        List<String> tempConditions2 = [];

        // Power Function for two different digits
        int poweredValue = pow(digits[i], digits[j]).toInt();
        int numCharacters = poweredValue.toString().length;
        if(numCharacters <= 10) {  // This is an arbitrary limit you can adjust based on your needs
          tempConditions2.add("If my ${digitNames[i]} digit was raised to the power of my ${digitNames[j]} digit, the result would be $numCharacters digits.");
        }

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

          // The average of two digits is equal to the third
          double average = (digits[i] + digits[j]) / 2;
          if (average == digits[k].toDouble()) {
            tempConditions3.add(
                "The average of my ${digitNames[i]} and ${digitNames[j]} digits is equal to my ${digitNames[k]} digit. ");
          }

          // randomly select one and add it to tempConditions.
          if (tempConditions3.isNotEmpty) {
            int randomIndex = _random.nextInt(tempConditions3.length);
            conditions.add(tempConditions3[randomIndex]);
            tempConditions3.clear(); // Clear the list for the next iteration.
          }

          for (int l = k + 1; l < numDigits; l++) {

            /// Four digit conditions
            // temp array
            List<String> tempConditions4 = [];

            // Product of the first two equals sum of the last two
            if (digits[i] * digits[j] == digits[k] + digits[l]) {
              tempConditions4.add("The product of my ${digitNames[i]} and ${digitNames[j]} digits is equal to the sum of my ${digitNames[k]} and ${digitNames[l]} digits.");
            }

            // The two pairs of digits form numbers that are complements of each other (summing to 90)
            if (int.parse('${digits[i]}${digits[j]}') + int.parse('${digits[k]}${digits[l]}') == 90) {
              tempConditions4.add("If you connect my ${digitNames[i]} and ${digitNames[j]} digits, and then my ${digitNames[k]} and ${digitNames[l]} digits, the two numbers are complementary");
            }

            // randomly select one and add it to tempConditions.
            if (tempConditions4.isNotEmpty) {
              int randomIndex = _random.nextInt(tempConditions4.length);
              conditions.add(tempConditions4[randomIndex]);
              tempConditions4.clear(); // Clear the list for the next iteration.
            }
          }
        }
      }
    }

    ///All Number Conditions

    //Sum of all numbers
    conditions.add(
        "The sum of my digits is ${digits.reduce((a, b) => a + b)}. ");

    //Product of all numbers
    conditions.add(
        "The product of all my digits is ${digits.reduce((a, b) => a * b)}. ");

    // Ascending order check
    if (isSortedAscending(digits)) {
      conditions.add("My digits are in ascending order. ");
    }

    // Descending order check
    if (isSortedDescending(digits)) {
      conditions.add("My digits are in descending order. ");
    }

    // Mirrored number check
    if (isMirroredNumber(digits)) {
      conditions.add("My digits form a mirrored number.");
    }

    // Fibonacci number check
    int numberFormed = int.parse(digits.join());
    if (isFibonacci(numberFormed)) {
      conditions.add("I'm in the Fibonacci sequence.");
    }

    return conditions;
  }

  bool isSortedAscending(List<int> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i] >= list[i + 1]) {
        return false;
      }
    }
    return true;
  }

  bool isSortedDescending(List<int> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i] <= list[i + 1]) {
        return false;
      }
    }
    return true;
  }

  bool isMirroredNumber(List<int> digits) {
    List<int> firstHalf = digits.sublist(0, (digits.length + 1) ~/ 2);
    List<int> secondHalf = digits.sublist(digits.length ~/ 2).reversed.toList();

    for (int m = 0; m < firstHalf.length; m++) {
      if (firstHalf[m] != secondHalf[m]) {
        return false;
      }
    }
    return true;
  }

  bool isFibonacci(int n) {
    if (n <= 1) return true;
    int a = 0, b = 1, c = a + b;
    while (c <= n) {
      if (c == n) return true;
      a = b;
      b = c;
      c = a + b;
    }
    return false;
  }

}