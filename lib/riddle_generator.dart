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

  bool _satisfiesCondition(List<int> digits, String condition) {
    Map<String, int> nameToIndex = {
      'hundreds': 0,
      'tens': 1,
      'ones': 2,
    };

    // Parsing for "The sum of my digits is" condition
    if (condition.contains("The sum of my digits is")) {
      int expectedSum = int.parse(
          condition.split("is ")[1].trim().split(".")[0]);
      return (digits[0] + digits[1] + digits[2] == expectedSum);
    }

    // Parsing for "The product of all my digits is" condition
    if (condition.contains("The product of all my digits is")) {
      int expectedProduct = int.parse(condition.split("is ")[1].trim().split(".")[0]);
      int actualProduct = digits[0] * digits[1] * digits[2];
      return actualProduct == expectedProduct;
    }

    // Parsing for difference conditions like "My hundreds digit is X more/less than my tens digit."
    RegExp diffRegex = RegExp(
        r"My (\w+) digit is (\d+) (more|less) than my (\w+) digit.");
    Match? diffMatch = diffRegex.firstMatch(condition);
    if (diffMatch != null) {
      Map<String, int> nameToIndex = {
        'hundreds': 0,
        'tens': 1,
        'ones': 2,
      };
      int digit1 = digits[nameToIndex[diffMatch.group(1)!]!];
      int difference = int.parse(diffMatch.group(2)!);
      int digit2 = digits[nameToIndex[diffMatch.group(4)!]!];

      return diffMatch.group(3) == "more"
          ? digit1 - digit2 == difference
          : digit2 - digit1 == difference;
    }

    // Parsing for "My hundreds digit is the same as my tens digit."
    RegExp sameRegex = RegExp(
        r"My (\w+) digit is the same as my (\w+) digit.");
    Match? sameMatch = sameRegex.firstMatch(condition);
    if (sameMatch != null) {
      Map<String, int> nameToIndex = {
        'hundreds': 0,
        'tens': 1,
        'ones': 2,
      };
      int digit1 = digits[nameToIndex[sameMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[sameMatch.group(2)!]!];

      return digit1 == digit2;
    }


    // Parsing for "My hundreds digit is X times bigger than my tens digit."
    RegExp timesBiggerRegex = RegExp(r"My (\w+) digit is (\d+) times bigger than my (\w+) digit.");
    Match? timesBiggerMatch = timesBiggerRegex.firstMatch(condition);
    if (timesBiggerMatch != null) {
      int digit1 = digits[nameToIndex[timesBiggerMatch.group(1)!]!];
      int times = int.parse(timesBiggerMatch.group(2)!);
      int digit2 = digits[nameToIndex[timesBiggerMatch.group(3)!]!];

      return digit1 == times * digit2;
    }

    ///Three Digit Condition checks
    // Parsing for "My digits would make a perfect right triangle."
    if (condition.contains(
        "My digits would make a perfect right triangle.")) {
      return digits[0] * digits[0] + digits[1] * digits[1] ==
          digits[2] * digits[2] ||
          digits[0] * digits[0] + digits[2] * digits[2] ==
              digits[1] * digits[1] ||
          digits[1] * digits[1] + digits[2] * digits[2] ==
              digits[0] * digits[0];
    }

    // Parsing for "The product of my hundreds and tens digits equals the square of my ones digit."
    RegExp productSquareRegex = RegExp(r"The product of my (\w+) and (\w+) digits equals the square of my (\w+) digit.");
    Match? productSquareMatch = productSquareRegex.firstMatch(condition);
    if (productSquareMatch != null) {
      int digit1 = digits[nameToIndex[productSquareMatch.group(1)!]!];
      int digit2 = digits[nameToIndex[productSquareMatch.group(2)!]!];
      int digit3 = digits[nameToIndex[productSquareMatch.group(3)!]!];

      return digit1 * digit2 == digit3 * digit3;
    }

    // Parsing for "My ones digit divided by the sum of my hundreds and tens digits gives X."
    RegExp divisionRegex = RegExp(r"My (\w+) digit divided by the sum of my (\w+) and (\w+) digits gives (\d+).");
    Match? divisionMatch = divisionRegex.firstMatch(condition);
    if (divisionMatch != null) {
      int numerator = digits[nameToIndex[divisionMatch.group(1)!]!];
      int sumDigit1 = digits[nameToIndex[divisionMatch.group(2)!]!];
      int sumDigit2 = digits[nameToIndex[divisionMatch.group(3)!]!];
      int expectedResult = int.parse(divisionMatch.group(4)!);

      return numerator / (sumDigit1 + sumDigit2) == expectedResult;
    }

    // Parsing for "Connecting my hundreds and tens digits and dividing by my ones digit gives X."
    RegExp combiningRegex = RegExp(r"Connecting my (\w+) and (\w+) digits and dividing by my (\w+) digit gives (\d+).");
    Match? combiningMatch = combiningRegex.firstMatch(condition);
    if (combiningMatch != null) {
      String digit1Str = digits[nameToIndex[combiningMatch.group(1)!]!].toString();
      String digit2Str = digits[nameToIndex[combiningMatch.group(2)!]!].toString();
      int divisor = digits[nameToIndex[combiningMatch.group(3)!]!];
      int expectedResult = int.parse(combiningMatch.group(4)!);

      int combinedValue = int.parse(digit1Str + digit2Str);
      return divisor != 0 && combinedValue / divisor == expectedResult;
    }

    // Default return value
    return false;
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
                "My ${digitNames[i]} digit is $difference more than my ${digitNames[j]} digit. ");
          } else if (difference < 0) {
            tempConditions.add(
                "My ${digitNames[i]} digit is ${-difference} less than my ${digitNames[j]} digit. ");
          } else if (difference == 0) {
            tempConditions.add(
                "My ${digitNames[i]} digit is the same as my ${digitNames[j]} digit. ");
          }

          // *,/ Functions for two different digits
          for (int multiple = 2; multiple <= 4; multiple++) {
            if (digits[i] == digits[j] * multiple) {
              tempConditions.add(
                  "My ${digitNames[i]} digit is $multiple times bigger than my ${digitNames[j]} digit. ");
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
                "The product of my ${digitNames[i]} and ${digitNames[j]} digits equals the square of my ${digitNames[k]} digit. ");
          }

          // One digit is divisible by the sum of the other two
          if ((digits[i] + digits[j]) != 0 && digits[k] != 0 &&
              digits[k] % (digits[i] + digits[j]) == 0) {
            int result = digits[k] ~/ (digits[i] + digits[j]);
            conditions.add(
                "My ${digitNames[k]} digit divided by the sum of my ${digitNames[i]} and ${digitNames[j]} digits gives $result. ");
          }

          // Pythagorean triple condition
          if (digits[i] * digits[i] + digits[j] * digits[j] ==
              digits[k] * digits[k] && !conditions.contains(
              "My digits would make a perfect right triangle. ")) {
            conditions.add("My digits would make a perfect right triangle. ");
          }

          // Combining two digits and dividing by the third results in an integer
          int combinedNumber = int.parse('${digits[i]}${digits[j]}');
          if (digits[k] != 0 && digits[k] > 2 &&
              combinedNumber % digits[k] == 0) {
            int result = combinedNumber ~/ digits[k];
            conditions.add(
                "Connecting my ${digitNames[i]} and ${digitNames[j]} digits and dividing by my ${digitNames[k]} digit gives $result. ");
          }
        }
      }
    }

    conditions.add(
        "The sum of my digits is ${digits[0] + digits[1] + digits[2]}. ");
    conditions.add("The product of all my digits is ${digits[0] * digits[1] * digits[2]}. ");

    List<int> possibleNumbers = List.generate(
        900, (index) => index + 100); // 100 to 999
    List<String> tempConditions = conditions +
        conditions2; // merge both conditions

    while (possibleNumbers.length != 1) {
      if (possibleNumbers.isEmpty) {
        print('No possible numbers left.');
        break; // You can also handle this situation more gracefully.
      }

      String selectedCondition = tempConditions[random.nextInt(
          tempConditions.length)];
      print('Selected condition: $selectedCondition');

      // Filter the list of possible numbers based on the selected condition
      List<int> filteredNumbers = possibleNumbers.where((number) {
        List<int> numDigits = [
          (number ~/ 100) % 10,
          (number ~/ 10) % 10,
          number % 10
        ];
        return _satisfiesCondition(numDigits, selectedCondition);
      }).toList();

      if (filteredNumbers.isNotEmpty &&
          filteredNumbers.length < possibleNumbers.length) {
        // Only update possibleNumbers if the filtering is successful and it reduces the number of possibilities.
        possibleNumbers = filteredNumbers;
        print('Numbers that passed this condition: $possibleNumbers');

        finalConditions.add(
            selectedCondition); // Add the successful condition to finalConditions
        tempConditions.remove(
            selectedCondition); // Remove used condition to avoid repetition
      } else {
        // If the condition didn't help in filtering, simply remove it from the tempConditions list so we don't try it again.
        print(
            'Condition didn\'t help in filtering. Numbers remained the same.');
        tempConditions.remove(selectedCondition);
      }

      // Check if there are no more conditions to try
      if (tempConditions.isEmpty) {
        print('No more conditions left to try.');
        break;
      }
    }

    return finalConditions;
  }

  RiddleResult generateRiddle() {
    List<int> digits = _generateNumber();
    int number = digits[0] * 100 + digits[1] * 10 + digits[2];

    List<String> finalConditions = _generalCondition(digits);

    String riddleText = 'I am a three-digit number. ';

    for (int i = 0; i < finalConditions.length; i++) {
      riddleText += (finalConditions[i]);
    }

    return RiddleResult(number: number, riddle: riddleText);
  }
}
