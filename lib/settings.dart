import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(int) onDigitsChanged;
  final Function(double) onFontSizeChanged;
  final Function(bool) onChangeRiddleTextSetting; // Added callback for riddle text setting

  const SettingsPage({
    Key? key,
    required this.onDigitsChanged,
    required this.onFontSizeChanged,
    required this.onChangeRiddleTextSetting, // constructor parameter for new callback
  }) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 3;  // Default value set to 3 digits
  double _fontSize = 20; // 1. Default font size
  bool _changeRiddleText = false;  // Setting for riddle text

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

            const SizedBox(height: 20),
            const Text(
              'Font Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _fontSize,
              min: 12,  // minimum font size (adjust as per your needs)
              max: 30,  // maximum font size (adjust as per your needs)
              divisions: 18,
              label: _fontSize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _fontSize = value;
                });
                widget.onFontSizeChanged(_fontSize);
              },
            ),
            Text('Current font size: ${_fontSize.round()}'),

            // Adding the switch for the riddle text change
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Change Riddle Text'),
              value: _changeRiddleText,
              onChanged: (value) {
                setState(() {
                  _changeRiddleText = value;
                });
                widget.onChangeRiddleTextSetting(value); // Inform the parent about the change
              },
            )
          ],
        ),
      ),
    );
  }
}
