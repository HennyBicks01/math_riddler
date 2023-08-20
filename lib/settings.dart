import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(int) onDigitsChanged;

  const SettingsPage({Key? key, required this.onDigitsChanged}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 3;  // Default value set to 3 digits

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Number of Digits for Riddles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _currentSliderValue,
              min: 2,
              max: 7,
              divisions: 5,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
                widget.onDigitsChanged(_currentSliderValue.round());
              },
            ),
            Text('Current selection: ${_currentSliderValue.round()} digits'),
          ],
        ),
      ),
    );
  }
}
