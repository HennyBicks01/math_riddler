import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double _animationSpeed = 50; // Default to 1 second


  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved settings
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentSliderValue = prefs.getDouble('digits_slider') ?? 3;
      _fontSize = prefs.getDouble('font_size') ?? 20;
      _changeRiddleText = prefs.getBool('change_riddle_text') ?? false;
      _animationSpeed = prefs.getDouble('animation_speed') ?? 50.0;

    });
  }

  _saveSettings(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (key == 'animation_speed' && value is double) {
      prefs.setDouble(key, value);
    }
  }

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
              style: TextStyle(fontSize: 15),
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
                _saveSettings('digits_slider', _currentSliderValue);
              },
            ),
            Text('Current selection: ${_currentSliderValue.round()} digits',
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),


            const SizedBox(height: 20),
            const Text(
              'Font Size',
              style: TextStyle(fontSize: 15),
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
                _saveSettings('font_size', _fontSize);
              },
            ),
            Text('Current font size: ${_fontSize.round()}',
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 20),
            const Text(
              'Animation Speed (seconds)',
              style: TextStyle(fontSize: 15),
            ),
            Slider(
              value: _animationSpeed,
              min: 0,
              max: 100,  // max speed is 5 seconds, you can change this
              divisions: 10,
              label: _animationSpeed == 0 ? 'Instant' : _animationSpeed.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _animationSpeed = value;
                });
                // If you have an external callback for this, call it here.
                _saveSettings('animation_speed', _animationSpeed);
              },
            ),
            Text(
              'Current animation speed: ${_animationSpeed == 0 ? "Instant" : _animationSpeed.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),


            // Adding the switch for the riddle text change
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Abbreviated Text:',
                  style: TextStyle( fontFamily:'TI84Font', fontSize: 15)),
              value: _changeRiddleText,
              onChanged: (value) {
                setState(() {
                  _changeRiddleText = value;
                });
                widget.onChangeRiddleTextSetting(value);
                _saveSettings('change_riddle_text', _changeRiddleText);
              },
            )
          ],
        ),
      ),
    );
  }
}
