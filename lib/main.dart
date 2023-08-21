import 'package:flutter/material.dart';

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
  Color _backgroundColor = Colors.grey[200]!;  // Changed to a calculator grayish tone.
  String _currentRiddleDisplay = '';

  final riddleGenerator = RiddleGenerator();


  @override
  void initState() {
    super.initState();
    _generateRiddle();
  }

  String _currentInput = ""; // To store the number being input by the user.

  void _appendToInput(String number) {
    setState(() {
      _currentInput += number;
    });
  }

  void _removeLastDigit() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  void _clearInput() {
    setState(() {
      _currentInput = "";
    });
  }

  void _generateRiddle() {
    final RiddleResult result = riddleGenerator.generateRiddle();
    _randomNumber = result.number;
    _riddle = result.riddle;
    print(_randomNumber);
    print(_riddle);

    _currentRiddleDisplay = '';
    // Start typing out animation.
    _typeOutRiddle();

    setState(() {});
  }

  void _typeOutRiddle() async {
    for (int i = 0; i < _riddle.length; i++) {
      await Future.delayed(Duration(milliseconds: 50));  // Delay for 50ms for each character.
      setState(() {
        _currentRiddleDisplay += _riddle[i];
      });
    }
  }

  void _updateDigitsValue(int newValue) {
    riddleGenerator.minDigits = newValue;
    riddleGenerator.maxDigits = newValue;  // If you want to set both the min and max to the same value.
  }

  void _checkAnswer() {
    if (_currentInput == _randomNumber.toString()) {
      _flashBackground(Colors.green);
      _eloScore += 15;
      _generateRiddle();
    } else {
      _flashBackground(Colors.red);
      _eloScore -= 15;
    }
    setState(() {
      _currentInput = ""; // This line clears the input after Submit is clicked.
    });
  }

  // Function to flash the background color.
  void _flashBackground(Color color) {
    setState(() {
      _backgroundColor = color;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _backgroundColor = Colors.white;
      });
    });
  }

  void _skipRiddle() {
    _eloScore -= 10;
    _generateRiddle();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Widget buildKey(int index) {
      Color buttonColor;
      Color textColor = Colors.black;  // Default text color to black for most buttons.

      switch (index) {
        case 3:
          return GridTile(
            footer: Container(color: Colors.transparent),  // Empty transparent container for additional space
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('>', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          );
        case 12:
          buttonColor = Colors.orange;
          return ElevatedButton(
            onPressed: _removeLastDigit,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text('<', style: TextStyle(fontSize: 20, color: textColor)),
          );
        case 13:
          buttonColor = Colors.white;
          return ElevatedButton(
            onPressed: () => _appendToInput('0'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text('0', style: TextStyle(fontSize: 20, color: textColor)),
          );
        case 14:
          buttonColor = Colors.orange;
          return ElevatedButton(
            onPressed: _clearInput,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text('C', style: TextStyle(fontSize: 20, color: textColor)),
          );
        case 15:
          buttonColor = Colors.red;
          textColor = Colors.white;  // For red button, white text may be more legible.
          return ElevatedButton(
            onPressed: () {
              _clearInput();
              _skipRiddle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text('>>', style: TextStyle(fontSize: 20, color: textColor)),
          );
        case 7:
        case 11:
          return Container(color: Colors.transparent); // Empty transparent containers
        default:
          buttonColor = Colors.white;
          textColor = Colors.black;  // Ensuring that number buttons have black text color.
          return ElevatedButton(
            onPressed: () =>
                _appendToInput('${(index % 4) + 1 + (index ~/ 4) * 3}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text('${(index % 4) + 1 + (index ~/ 4) * 3}', style: TextStyle(fontSize: 20, color: textColor)),
          );
      }
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
                          // 1. Move Elo Score here.
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Elo: $_eloScore',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // 2. Current Input (Guess Area) goes here.
                          Text(
                            _currentInput,
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          // 3. Riddle positioned above the keypad.
                          Expanded(
                            flex: 7,
                            child: Center(
                              child: Text(
                                _currentRiddleDisplay,
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              )
                            ),
                          ),
                          // Keypad
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: screenWidth / (screenHeight / 3.75),
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                  ),
                                  itemCount: 16,
                                  itemBuilder: (context, index) {
                                    return buildKey(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SettingsPage(onDigitsChanged: _updateDigitsValue)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700], // Darker button for settings.
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(Icons.settings, color: Colors.white),  // White icon for better visibility.
                        ),
                      ),
                    ]
              )
            )
          )
    );
  }
}

