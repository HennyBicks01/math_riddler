class ShortHandConditions{

  String getShorthandCondition(String condition, List<String> digitNames) {
    if (condition.contains("more than")) {
      RegExp exp = RegExp(r"My (\w+) digit is (\d+) more than my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String difference = match.group(2)!;
        String secondDigit = _digitInitial(match.group(3)!);
        return '$firstDigit - $difference = $secondDigit\n';
      }
    }

    else if (condition.contains("less than")) {
      RegExp exp = RegExp(r"My (\w+) digit is (\d+) less than my (\w+) digit");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String firstDigit = _digitInitial(match.group(1)!);
        String difference = match.group(2)!;
        String secondDigit = _digitInitial(match.group(3)!);
        return '$firstDigit + $difference = $secondDigit\n';
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
        return '$firstDigit:$secondDigit / $divisor = $result\n';
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
        return '$firstDigitA:$secondDigitA + $firstDigitB:$secondDigitB = 90\n';
      }
    }

    //Quadratic Formula
    else if (condition.contains("Using my") && condition.contains("coefficients in a quadratic equation")) {
      RegExp exp = RegExp(r"Using my (\w+), (\w+), and (\w+) digits as coefficients in a quadratic equation, one solution is my (\w+) digit.");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String aDigit = _digitInitial(match.group(1)!);
        String bDigit = _digitInitial(match.group(2)!);
        String cDigit = _digitInitial(match.group(3)!);
        String solutionDigit = _digitInitial(match.group(4)!);
        return '$aDigit x^2 + $bDigit x + $cDigit; x = $solutionDigit\n';
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

    // Fibonacci number check
    else if (condition.contains("I am a prime number.")) {
      return 'Prime\n';
    }

    // Sum of the digits until a single digit remains
    else if (condition.contains("If you keep summing my digits together, you'll eventually get the number")) {
      RegExp exp = RegExp(r"If you keep summing my digits together, you'll eventually get the number (\d+)\.");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String resultSum = match.group(1)!;
        return 'Sum^n = $resultSum\n';
      }
    }

    // Product of the digits until a single digit remains
    else if (condition.contains("If you keep multiplying my digits together, you'll eventually get the number")) {
      RegExp exp = RegExp(r"If you keep multiplying my digits together, you'll eventually get the number (\d+)\.");
      Match? match = exp.firstMatch(condition);
      if (match != null) {
        String resultProduct = match.group(1)!;
        return 'Product^n   = $resultProduct\n';
      }
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