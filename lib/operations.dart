import 'package:math_expressions/math_expressions.dart';

class Operations {
  final Function() getCurrentInput; // Function to retrieve the current input
  final Function(String) updateCurrentInput;
  final Function(String) addLastExpression;

  Operations({
    required this.getCurrentInput,
    required this.updateCurrentInput,
    required this.addLastExpression
  });

  // Handles the operations performed by the user, including special functions
  void performOperation(String operation) {
    // Check for special operations. If found, evaluate immediately
    switch (operation) {
      case 'Prm':
        evaluateIsPrime();
        return;
      case 'Len':
        evaluateLength();
        return;
      case 'Fib':
        evaluateIsFibonacci();
        return;
      case 'Sum':
        evaluateSumOfDigits();
        return;
      case 'Prod':
        evaluateProductOfDigits();
        return;
      default:
        updateCurrentInput(operation);
    }
  }

  void evaluateIsPrime() {
    int? num = int.tryParse(getCurrentInput());
    if (num == null) {
      updateCurrentInput("Invalid Number");
      return;
    }
    bool prime = isPrime(num);
    addLastExpression('isPrime($num) = $prime');
    updateCurrentInput('');
  }

  void evaluateLength() {
    String current = getCurrentInput();
    int length = current.length;
    addLastExpression('length($current) = $length');
    updateCurrentInput(length.toString());
  }

  void evaluateIsFibonacci() {
    int? num = int.tryParse(getCurrentInput());
    if (num == null) {
      updateCurrentInput("Invalid Number");
      return;
    }
    bool fib = isFibonacci(num);
    addLastExpression('isFibonacci($num) = $fib');
    updateCurrentInput('');
  }

  void evaluateSumOfDigits() {
    int sum = 0;
    String current = getCurrentInput();
    for (var digit in current.split('')) {
      int? num = int.tryParse(digit);
      if (num != null) sum += num;
    }
    addLastExpression('sum($current) = $sum');
    updateCurrentInput(sum.toString());
  }

  void evaluateProductOfDigits() {
    int product = 1;
    String current = getCurrentInput();
    for (var digit in current.split('')) {
      int? num = int.tryParse(digit);
      if (num != null) product *= num;
    }
    addLastExpression('product($current) = $product');
    updateCurrentInput(product.toString());
  }

  // Utility function to check if a given number is prime.
  bool isPrime(int num) {
    if (num < 2) return false;
    for (int i = 2; i * i <= num; i++) {
      if (num % i == 0) return false;
    }
    return true;
  }

  // Utility function to check if a given number belongs to the Fibonacci sequence.
  bool isFibonacci(int n) {
    int a = 0,
        b = 1,
        c = a + b;
    while (c <= n) {
      if (c == n) return true;
      a = b;
      b = c;
      c = a + b;
    }
    return false;
  }

  // Parses and evaluates mathematical expressions entered by the user.
  void evaluateExpression() {
    String expression = getCurrentInput();
    expression = expression.replaceAll('x', '*');
    final parser = Parser();
    double result;
    try {
      Expression exp = parser.parse(expression);
      result = exp.evaluate(EvaluationType.REAL, ContextModel());

      // Check if result is a whole number.
      String formattedResult = (result % 1 == 0)
          ? result.toInt().toString()
          : result.toString();

      addLastExpression('$expression = $formattedResult');
      updateCurrentInput(formattedResult);
    } catch (e) {
      updateCurrentInput("Invalid Expression");
    }
  }
}
