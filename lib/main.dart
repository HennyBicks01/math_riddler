import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';

import 'package:mathriddles/riddle_generator.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riddle Number Game',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'TI84Font',
            fontSize: 20,
          ),
          bodySmall: TextStyle(
            fontFamily: 'TI84Font',
            fontSize: 15,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Guess the Number Riddle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _randomNumber;
  late String _riddle;
  int _eloScore = 1200;
  Color _backgroundColor = const Color (0xFFe5e9e3); // Changed to a calculator grayish tone.
  String _currentRiddleDisplay = '';
  double _fontSize = 20; // default font size
  final List<String> _wrongGuesses = [];
  bool _changeRiddleText = false;
  double _animationSpeed = 50; // Default to 1 second
  bool _isRiddleBeingDisplayed = false;
  String _currentInput = ""; // To store the number being input by the user.
  final List<String> _lastExpression = [];
  List<String> expressionSymbols =
  ['+', '-', 'x', '/',
    '^','Prm','Len','Fib',
    'Sum','Prod','.','Ops'];
  bool _showOperators = false;
  bool _isSettingsOpen = false;


  final riddleGenerator = RiddleGenerator();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // <-- Load your settings from SharedPreferences
    _generateRiddle();
  }

  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// Settings Page functions and Preferences
  /// --------------------------------------------------------------------------
  // Loads saved preferences from settings page
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _fontSize = prefs.getDouble('font_size') ??
          20;
      _changeRiddleText = prefs.getBool('change_riddle_text') ??
          false;
      _eloScore = prefs.getInt('elo_score') ??
          1200; // Use a default value of 1200 if not found
      _animationSpeed = prefs.getDouble('animation_speed') ??
          50;
    });
  }

  // Updates the font size for riddle display
  void _updateFontSize(double newSize) {
    setState(() {
      _fontSize = newSize;
    });
  }

  // Updates the animation speed for riddle display.
  void _updateAnimationSpeed(double newSpeed) {
    setState(() {
      _animationSpeed = newSpeed;
    });
  }

  // Updates the minimum and maximum digits for the riddle generator.
  void _updateDigitsValue(int newValue) {
    riddleGenerator.minDigits = newValue;
    riddleGenerator.maxDigits = newValue; // If you want to set both the min and max to the same value.
  }

  // Saves Elo
  void _saveEloScore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('elo_score', _eloScore);
  }
  /// --------------------------------------------------------------------------
  /// Button Functions
  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Updates Input on button press
  void _appendToInput(String number) {
    setState(() {
      _currentInput += number;
      _currentRiddleDisplay = _riddle;
    });
  }

  // Removes the last digit from the current input.
  void _removeLastDigit() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _currentRiddleDisplay = _riddle;
      });
    }
  }

  // Clears the current input.
  void _clearInput() {
    setState(() {
      _currentInput = "";
      _currentRiddleDisplay = _riddle;
    });
  }

  // Generates a new riddle.
  void _generateRiddle() {
    final RiddleResult result = riddleGenerator.generateRiddle(
        isShorthandMode: _changeRiddleText);
    _randomNumber = result.number;
    _riddle = result.riddle;

    print(_randomNumber);
    print(_riddle);

    _currentRiddleDisplay = '';
    // Start typing out animation.
    _typeOutRiddle();

    setState(() {});
  }

  // Checks the user's answer against the correct answer, updates the ELO score, and provides feedback.
  void _checkAnswer() {
    if (_currentInput == _randomNumber.toString()) {
      _flashBackground(Colors.green);
      _eloScore += 15;
      _generateRiddle();
      _wrongGuesses.clear();
      _lastExpression.clear();
      _saveEloScore(); // Clear the list of wrong guesses upon correct answer.
    } else {
      _flashBackground(Colors.red);
      _eloScore -= 15;
      _wrongGuesses.add(_currentInput);
      _saveEloScore();
    }
    setState(() {
      _currentInput = ""; // This line clears the input after Submit is clicked.
    });
  }

  // Allows the user to skip the current riddle, with an ELO score penalty.
  void _skipRiddle() {
    _eloScore -= 10;
    _generateRiddle();
    _wrongGuesses.clear();
    _lastExpression.clear();
    _saveEloScore(); // Clear the list of wrong guesses when skipping the riddle.
  }
  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// Animations
  /// **************************************************************************
  // Flashes the app's background color to provide feedback.
  void _flashBackground(Color color) {
    setState(() {
      _backgroundColor = color;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _backgroundColor = const Color (0xFFe5e9e3);
      });
    });
  }

  // Animates the typing out of the riddle.
  void _typeOutRiddle() async {
    if (_animationSpeed == 0.0 || _animationSpeed.toString() ==
        'Instant') { // "0" represents instant in this example
      setState(() {
        _currentRiddleDisplay = _riddle;
        _isRiddleBeingDisplayed = false;
      });
    } else {
      _isRiddleBeingDisplayed = true;
      for (int i = 0; i < _riddle.length; i++) {
        await Future.delayed(Duration(milliseconds: (_animationSpeed)
            .toInt())); // The delay now factors in the _animationSpeedSlider
        setState(() {
          _currentRiddleDisplay += _riddle[i];
        });
      }
      _isRiddleBeingDisplayed = false;
    }
  }
  /// **************************************************************************
  ///  Operations
  /// --------------------------------------------------------------------------
  // Handles the operations performed by the user, including special functions
  void _performOperation(String operation) {
    // Check for special operations. If found, evaluate immediately
    switch (operation) {
      case 'Prm':
        _evaluateIsPrime();
        return;
      case 'Len':
        _evaluateLength();
        return;
      case 'Fib':
        _evaluateIsFibonacci();
        return;
      case 'Sum':
        _evaluateSumOfDigits();
        return;
      case 'Prod':
        _evaluateProductOfDigits();
        return;
      default:
        setState(() {
          _currentInput += operation;
        });
    }
  }

  // Evaluates and checks if the current input number is a prime number.
  void _evaluateIsPrime() {
    int? num = int.tryParse(_currentInput);
    if (num == null) {
      setState(() {
        _currentInput = "Invalid Number";
      });
      return;
    }
    bool prime = _isPrime(num);
    setState(() {
      _lastExpression.add('isPrime($_currentInput) = $prime');
      _currentInput = '';
    });
  }

  // Evaluates the length of the current input.
  void _evaluateLength() {
    setState(() {
      _lastExpression.add('length($_currentInput) = ${_currentInput.length}');
      _currentInput = _currentInput.length.toString();
    });
  }

  // Evaluates and checks if the current input number is part of the Fibonacci sequence.
  void _evaluateIsFibonacci() {
    int? num = int.tryParse(_currentInput);
    if (num == null) {
      setState(() {
        _currentInput = "Invalid Number";
      });
      return;
    }
    bool fib = _isFibonacci(num);
    setState(() {
      _lastExpression.add('isFibonacci($_currentInput) = $fib');
      _currentInput = '';
    });
  }

  // Takes the sum of all of the inputted numbers
  void _evaluateSumOfDigits() {
    int sum = 0;
    for (var digit in _currentInput.split('')) {
      int? num = int.tryParse(digit);
      if (num != null) sum += num;
    }

    setState(() {
      _lastExpression.add('sum($_currentInput) = $sum');
      _currentInput = sum.toString();
    });
  }

  // Takes the product of all of the inputted numbers
  void _evaluateProductOfDigits() {
    int product = 1;
    for (var digit in _currentInput.split('')) {
      int? num = int.tryParse(digit);
      if (num != null) product *= num;
    }

    setState(() {
      _lastExpression.add('product($_currentInput) = $product');
      _currentInput = product.toString();
    });
  }

  // Utility function to check if a given number is prime.
  bool _isPrime(int num) {
    if (num < 2) return false;
    for (int i = 2; i * i <= num; i++) {
      if (num % i == 0) return false;
    }
    return true;
  }

  // Utility function to check if a given number belongs to the Fibonacci sequence.
  bool _isFibonacci(int n) {
    int a = 0, b = 1, c = a + b;
    while (c <= n) {
      if (c == n) return true;
      a = b;
      b = c;
      c = a + b;
    }
    return false;
  }

  // Parses and evaluates mathematical expressions entered by the user.
  void _evaluateExpression() {
    String expression = _currentInput;
    expression = expression.replaceAll('x', '*');
    final parser = Parser();
    double result;
    try {
      Expression exp = parser.parse(expression);
      result = exp.evaluate(EvaluationType.REAL, ContextModel());
      setState(() {
        _lastExpression.add('$_currentInput = ${result.toString()}');
        _currentInput = result.toString();
      });
    } catch (e) {
      print("Error evaluating expression: $e");
      setState(() {
        _currentInput = "Invalid Expression";
      });
    }
  }
  /// --------------------------------------------------------------------------
  /// Main Page Build methods
  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //Main Page
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    Widget buildKey(int index) {
      Color buttonColor = Colors.white; // Default color
      Color textColor = Colors.black; // Default text color


      // Mapping of indexes to their respective symbols or actions
      List<String> symbols = _showOperators ? expressionSymbols : [
        '1', '2', '3', '>',
        '4', '5', '6', '=',
        '7', '8', '9', 'Ops',
        '<', '0', 'C', '>>'
      ];

      if (index >= symbols.length) {
        return Container();
      }

      String symbol = symbols[index];

      switch (symbol) {
        case '>':
          buttonColor = Colors.green;
          textColor = Colors.white;
          break;
        case '=':
          buttonColor = Colors.blue;
          textColor = Colors.white;
          break;
        case 'Ops':
          buttonColor = Colors.purple;
          textColor = Colors.white;
          break;
        case '<':
          buttonColor = Colors.orange;
          break;
        case 'C':
          buttonColor = Colors.orange;
          break;
        case '>>':
          buttonColor = Colors.red;
          textColor = Colors.white;
          break;
        case '+':
        case '-':
        case 'x':
        case '/':
        case '^':
        case 'Prm':
        case 'Len':
        case 'Fib':
        case 'Sum':
        case 'Prod':
        case '.':
          buttonColor = Colors.purple[200]!;


      }

      return ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact(); // This triggers the haptic feedback

          if (_isRiddleBeingDisplayed) return;
          switch (symbol) {
            case '>':
              _checkAnswer();
              break;
            case '<':
              _removeLastDigit();
              break;
            case 'C':
              _clearInput();
              break;
            case '>>':
              _clearInput();
              _skipRiddle();
              break;
            case 'Ops':
              setState(() {
                _showOperators = !_showOperators; // Toggle the _showOperators state
              });
              break;

            case '+':
            case '-':
            case 'x':
            case '/':
            case '^':
            case 'Prm':
            case 'Len':
            case 'Fib':
            case 'Sum':
            case 'Prod':
            case '.':
              setState(() {
                _showOperators = false; // Reset the _showOperators to false
              });
              _performOperation(symbol);
              break;
            case '=':
              _evaluateExpression();
              break;
            default:
              _appendToInput(symbol);
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => buttonColor,
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => textColor,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 20,
              color: textColor,
              fontFamily: 'Sand',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }


      return Scaffold(
          body: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _backgroundColor,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Stack(
                      children: <Widget>[
                        Column(
                          children: [

                            //Riddle and User input
                            Expanded(
                              flex: 7,
                              child: Center(
                                child: Container(
                                  width: screenWidth * 0.85,
                                  height: screenHeight * 0.53,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFA8B6A0),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(width: 20.0, color: const Color(0xFF5a6155)), // Adding 20px border
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5.0,
                                            offset: Offset(2, 2)
                                        ),
                                      ]
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [

                                    //Row for ELO Score and Menu Icon
                                    Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      // Elo Score with no border and smaller font
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          'Elo: $_eloScore',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),

                                      // Menu Icon (Settings) with padding adjusted
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isSettingsOpen = !_isSettingsOpen;
                                            });
                                          },
                                          icon: const Icon(Icons.menu, color: CupertinoColors.black),
                                        ),
                                      ),
                                    ],
                                  ),

                                      if (_isSettingsOpen)
                                        Flexible(
                                          child: SizedBox(
                                            height: screenHeight * 0.5, // or whatever fraction you find suitable
                                            child: SingleChildScrollView(
                                              child: SettingsPage(
                                                onDigitsChanged: _updateDigitsValue,
                                                onFontSizeChanged: _updateFontSize,
                                                onAnimationSpeedChanged: _updateAnimationSpeed,
                                                onChangeRiddleTextSetting: (bool value) {
                                                  setState(() {
                                                    _changeRiddleText = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0), // Add padding to both left and right
                                            child: SingleChildScrollView(
                                              reverse: true, // Makes the content start from the bottom
                                              scrollDirection: Axis.vertical,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _currentRiddleDisplay,
                                                    style: TextStyle(fontSize: _fontSize),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                  ..._wrongGuesses.map((wrongGuess) =>
                                                      Text(
                                                        wrongGuess,
                                                        style: TextStyle(fontSize: _fontSize, color: Colors.red),
                                                        textAlign: TextAlign.right,
                                                      )
                                                  ).toList(),
                                                  // Display the expressions from the history:
                                                  ..._lastExpression.map((expression) =>
                                                      Text(
                                                        expression,
                                                        style: TextStyle(fontSize: _fontSize, color: Colors.grey[700]),
                                                        textAlign: TextAlign.right,
                                                      )
                                                  ).toList(),
                                                  Text(
                                                    _currentInput,
                                                    style: TextStyle(fontSize: _fontSize),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Keypad
                            Expanded(
                              flex: 4,
                              child: Stack(
                                children: [
                                  GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: screenWidth / (screenHeight / 3),
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                    ),
                                    itemCount: _showOperators ? expressionSymbols.length : 20,
                                    itemBuilder: (context, index) {
                                      return buildKey(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]
                  )
              )
          )
      );
    }
  }

