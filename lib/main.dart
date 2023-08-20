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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
  int _riddlesSolved = 0;
  bool _guessed = false;
  Color _backgroundColor = Colors.white; // The default background color.
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
    _guessed = false;
    print(_randomNumber);
    print(_riddle);
    setState(() {});
  }

  void _updateDigitsValue(int newValue) {
    riddleGenerator.minDigits = newValue;
    riddleGenerator.maxDigits = newValue;  // If you want to set both the min and max to the same value.
  }

  void _checkAnswer() {
    if (_currentInput == _randomNumber.toString()) {
      _flashBackground(Colors.green);
      _eloScore += 15;
      _riddlesSolved++;
      _generateRiddle();
    } else {
      _flashBackground(Colors.red);
      _eloScore -= 15;
    }
    setState(() {
      _currentInput = ""; // This line clears the input after Submit is clicked.
    });
    _guessed = true;
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
    if (!_guessed) {
      _eloScore -= 10;
      _generateRiddle();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildKey(int index) {
      Color buttonColor;
      Color textColor = Colors.black;  // Default text color to black for most buttons.

      switch (index) {
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
        case 3:
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
        duration: const Duration(milliseconds: 500),
        color: _backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Stack(  // Wrap your main content in a Stack
            children: <Widget>[
              Column(
              children: [
              // Elo Score at the top-right corner
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
                // Riddles Solved Counter
                Text(
                  '$_riddlesSolved',
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // Riddle
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      _riddle,
                      style: const TextStyle(fontSize: 23),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Text(
                  _currentInput,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Keypad
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          return buildKey(index);
                        },
                      ),
                    Positioned(
                      top: 0,
                      left: (MediaQuery.of(context).size.width / 4) * 3 - 20,
                      child: ElevatedButton(
                        onPressed: _checkAnswer,

                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(
                            (MediaQuery.of(context).size.width / 4) - 15,
                            .75 * (MediaQuery.of(context).size.height / 4) -3,
                          ),
                          shape: RoundedRectangleBorder(  // This line squares off the button
                            borderRadius: BorderRadius.circular(20), // Setting the borderRadius to 0 will make it completely square
                          ),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('>', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
                Positioned( // This widget will position the settings button in the top-left corner
                  top: 10,
                  left: 0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SettingsPage(onDigitsChanged: _updateDigitsValue)),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400], // button color
                    foregroundColor: Colors.black, // icon color
                    shape: const CircleBorder(), ),

                    child: const Icon(Icons.settings),
          ),
        ),
    ]
    )
    )
    )
    );
  }
}
