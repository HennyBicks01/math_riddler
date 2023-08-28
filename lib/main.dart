import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'operations.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign-in.dart';
import 'package:mathriddles/riddle_generator.dart';
import 'settings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class GoogleSignInModal extends StatefulWidget {
  @override
  _GoogleSignInModalState createState() => _GoogleSignInModalState();
}

class _GoogleSignInModalState extends State<GoogleSignInModal> {
  final GoogleSignInProvider _signInProvider = GoogleSignInProvider();

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Remove the const keyword here
      height: 800,
      child: Center(
        child: ElevatedButton(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/google_logo.png"),
                height: 18.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Sign in'),
              )
            ],
          ),
          onPressed: () async {
            User? user = await _signInProvider.signInWithGoogle();
            if (user != null) {
              print("Successfully signed in with Google: ${user.displayName}");
            } else {
              print("Failed to sign in with Google");
            }
          },
        ),
      ),
    );
  }
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
  late String _riddleShort;
  late String _riddleNormal;
  int _eloScore = 1200;
  Color _backgroundColor = const Color (0xFFe5e9e3); // Changed to a calculator grayish tone.
  String _currentRiddleDisplay = '';
  double _fontSize = 20; // default font size
  final List<String> _wrongGuesses = [];
  double _changeRiddleText = 1.0;
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
  int? currentNumber;
  List<String>? currentConditions;
  bool isShorthandMode = false;
  late Operations operations;

  final riddleGenerator = RiddleGenerator();


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showTopModalSheet(context, GoogleSignInModal());
    });

    _loadSettings(); // <-- Load your settings from SharedPreferences
    _generateRiddle();

    // Initialize operations here
    operations = Operations(
        getCurrentInput: () => _currentInput, // Get the current input
        updateCurrentInput: (input) {
          setState(() {
            _currentInput += input;
          });
        },
        addLastExpression: (expression) {
          setState(() {
            _currentInput = '';
            _lastExpression.add(expression);
          });
        }
    );
  }

  ///***************************************************************************
  /// Sign in
  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(const MyApp());
  }

  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// Settings Page functions and Preferences
  /// --------------------------------------------------------------------------
  // Loads saved preferences from settings page
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 20;
      _changeRiddleText = prefs.getDouble('change_riddle_text') ?? 1.0;
      _eloScore = prefs.getInt('elo_score') ?? 1200;
      _animationSpeed = prefs.getDouble('animation_speed') ?? 3;
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

  // Updates the animation speed for riddle display.
  void _updateRiddleText(double newText) {
    setState(() {
      _changeRiddleText = newText;

      if (_changeRiddleText == 1.0) {
        _currentRiddleDisplay = _riddleNormal;
      } else {
        _currentRiddleDisplay = _riddleShort;
      }
    });
  }

  void _changeRiddleMode() {
    if (_changeRiddleText == 1.0) {
      _currentRiddleDisplay = _riddleShort;
    } else {
      _currentRiddleDisplay = _riddleNormal;
    }
  }

  void _setRiddleMode() {
    if (_changeRiddleText == 1.0) {
      _riddle = _riddleShort;
    } else {
      _riddle = _riddleNormal;
    }
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
    });
  }

  // Removes the last digit from the current input.
  void _removeLastDigit() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  // Clears the current input.
  void _clearInput() {
    setState(() {
      _currentInput = "";
    });
  }

  void _generateRiddle() {
    final RiddleResult result = riddleGenerator.generateRiddle();
    _randomNumber = result.number;
    List<String> parts = result.riddleShort.split('\n');
    if (parts.length > 1) {
      parts[parts.length - 2] = parts[parts.length - 2] + parts[parts.length - 1];
      parts.removeLast();
    }
    _riddleShort = parts.join('\n');
    _riddleNormal = result.riddleNormal;
    _setRiddleMode();
    print(_randomNumber);
    _typeOutRiddle();
    setState(() {});
  }

  // Checks the user's answer against the correct answer, updates the ELO score, and provides feedback.
  void _checkAnswer() {
    if (_currentInput == _randomNumber.toString()) {
      _flashBackground(Colors.green);
      _eloScore += 15;
      _generateRiddle();
      _currentRiddleDisplay = '';
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
    _currentRiddleDisplay = '';
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
        case '>': buttonColor = Colors.green; textColor = Colors.white; break;
        case '=':buttonColor = Colors.blue; textColor = Colors.white; break;
        case 'Ops':buttonColor = Colors.purple; textColor = Colors.white; break;
        case '<':buttonColor = Colors.orange; break;
        case 'C':buttonColor = Colors.orange; break;
        case '>>':buttonColor = Colors.red; textColor = Colors.white; break;
        default:
          buttonColor = Colors.white;
      }

      return ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact(); // This triggers the haptic feedback

          if (_isRiddleBeingDisplayed) return;
          switch (symbol) {
            case '>':_checkAnswer();break;
            case '<':_removeLastDigit();break;
            case 'C':_clearInput();break;
            case '>>':_clearInput();_skipRiddle();break;
            case 'Ops':setState(() {_showOperators = !_showOperators;});break;
            case '=': operations.evaluateExpression(); break;

            case '+': case '-': case 'x': case '/': case '^': case 'Prm':
            case 'Len': case 'Fib': case 'Sum': case 'Prod': case '.':
              setState(() {
                _showOperators = false; // Reset the _showOperators to false
              });
              operations.performOperation(symbol); break;

            default: _appendToInput(symbol);
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
                                                onChangeRiddleTextSetting: (value) {
                                                  _updateRiddleText(value);
                                                  _changeRiddleMode(); // Set the appropriate riddle mode
                                                  setState(() {});
                                                },
                                                onRiddleTextModeChanged: () { // The new callback
                                                  _changeRiddleMode();
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                                    physics: const NeverScrollableScrollPhysics(),  // Added this line to disable scrolling.
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ]
                  )
              )
          )
      );
    }

  }

