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
  final _controller = TextEditingController();
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
    if (_controller.text == _randomNumber.toString()) {
      _flashBackground(Colors.green);
      _eloScore += 15;
      _riddlesSolved++;
      _generateRiddle();
    } else {
      _flashBackground(Colors.red);
      _eloScore -= 15;
    }
    _controller.clear();
    _guessed = true;
  }

  // Function to flash the background color.
  void _flashBackground(Color color) {
    setState(() {
      _backgroundColor = color;
    });
    Future.delayed(Duration(milliseconds: 500), () {
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
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: _backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_riddlesSolved',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _riddle,
                    style: const TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text( // Displaying the number being input by the user
                    _currentInput,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Custom keypad
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(10, (index) {
                      return ElevatedButton(
                        onPressed: () => _appendToInput(index.toString()),
                        child: Text('$index'),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        child: const Text('Submit'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _clearInput();
                          _skipRiddle();
                        },
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
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
            ],
          ),
        ),
      ),
    );
  }
}

