import 'package:flutter/material.dart';

import 'package:mathriddles/riddle_generator.dart';

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
    final RiddleGenerator riddleGenerator = RiddleGenerator();
    final RiddleResult result = riddleGenerator.generateRiddle();
    _randomNumber = result.number;
    _riddle = result.riddle;
    _guessed = false;
    print(_randomNumber);
    print(_riddle);
    setState(() {});
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
      switch (index) {
        case 3:
        case 7:
        case 11:
          return Container(color: Colors
              .transparent); // Empty transparent containers for the spots where Submit buttons used to be.
        case 12:
          return ElevatedButton(
            onPressed: _removeLastDigit,
            child: const Text('Back'),
          );
        case 13:
          return ElevatedButton(
            onPressed: () => _appendToInput('0'),
            child: const Text('0'),
          );
        case 14:
          return ElevatedButton(
            onPressed: _clearInput,
            child: const Text('Clear'),
          );
        case 15:
          return ElevatedButton(
            onPressed: () {
              _clearInput();
              _skipRiddle();
            },
            child: const Text('Skip'),
          );
        default:
          return ElevatedButton(
            onPressed: () =>
                _appendToInput('${(index % 4) + 1 + (index ~/ 4) * 3}'),
            child: Text('${(index % 4) + 1 + (index ~/ 4) * 3}'),
          );
      }
    }

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
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
              const SizedBox(height: 10),
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
              const Spacer(),
              Text(
                _currentInput,
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              // This will push the grid (keypad) to the bottom
              // Keypad
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.0,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        return buildKey(index);
                      },
                    ),
                    Positioned(
                      top: 0, // Starting from the 2nd row, plus the spacing.
                      left: (MediaQuery.of(context).size.width / 4) * 3 - 20,  // Starting from the 4th column.
                      child: ElevatedButton(
                        onPressed: _checkAnswer,
                        child: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(
                            (MediaQuery.of(context).size.width / 4) - 15, // Width of 1 column minus some padding.
                            .75 * (MediaQuery.of(context).size.height / 4) -3,  // Height of 3 rows minus some padding.
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
