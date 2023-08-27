import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(int) onDigitsChanged;
  final Function(double) onFontSizeChanged;
  final Function(bool) onChangeRiddleTextSetting;
  final Function(double) onAnimationSpeedChanged;// Added callback for riddle text setting

  const SettingsPage({
    Key? key,
    required this.onDigitsChanged,
    required this.onFontSizeChanged,
    required this.onChangeRiddleTextSetting,
    required this.onAnimationSpeedChanged,// constructor parameter for new callback
  }) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 3; // Default value set to 3 digits
  double _fontSize = 20; // 1. Default font size
  bool _changeRiddleText = false; // Setting for riddle text
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
    }
  }

  double _getDynamicFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * .0395;
  }

  List<Widget> _buildNumberOptions() {
    double dynamicFontSize = _getDynamicFontSize(context);

    return [
      Row(
        children: <Widget>[
          Text(
            "DIGITS:",
            style: TextStyle(fontSize: dynamicFontSize),
          ),
          ...List<Widget>.generate(6, (index) {
            int value = index + 2;
            bool isSelected = value == _currentSliderValue.round();
            return InkWell(
              onTap: () {
                setState(() {
                  _currentSliderValue = value.toDouble();
                  widget.onDigitsChanged(_currentSliderValue.round());
                  _saveSettings('digits_slider', _currentSliderValue);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: isSelected ? Colors.black : Colors.transparent,
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: dynamicFontSize,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ];
  }

  List<Widget> _buildFontSizeOptions() {
    double dynamicFontSize = _getDynamicFontSize(context);

    List<Map<String, dynamic>> options = [
      {"label": "SMALL", "value": 10.0},
      {"label": "MEDIUM", "value": 15.0},
      {"label": "LARGE", "value": 20.0},
    ];

    return [
      Row(
        children: <Widget>[
          Text(
            "SIZE:",
            style: TextStyle(fontSize: dynamicFontSize),
          ),
          ...options.map((option) {
            bool isSelected = option["value"] == _fontSize;
            return InkWell(
              onTap: () {
                setState(() {
                  _fontSize = option["value"];
                  widget.onFontSizeChanged(_fontSize);
                  _saveSettings('font_size', _fontSize);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: isSelected ? Colors.black : Colors.transparent,
                child: Text(
                  option["label"],
                  style: TextStyle(
                    fontSize: dynamicFontSize,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ];
  }

  List<Widget> _buildAnimationSpeedOptions() {
    double dynamicFontSize = _getDynamicFontSize(context);

    List<Map<String, dynamic>> options = [
      {"label": "INSTANT", "value": 0.0},
      {"label": "3", "value": 5.0},
      {"label": "2", "value": 40.0},
      {"label": "1", "value": 100.0},
    ];

    return [
      Row(
        children: <Widget>[
          Text(
            "SPEED:",
            style: TextStyle(fontSize: dynamicFontSize),
          ),
          ...options.map((option) {
            bool isSelected = option["value"] == _animationSpeed;
            return InkWell(
              onTap: () {
                setState(() {
                  _animationSpeed = option["value"];
                  widget.onAnimationSpeedChanged(_animationSpeed);
                  _saveSettings('animation_speed', _animationSpeed);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: isSelected ? Colors.black : Colors.transparent,
                child: Text(
                  option["label"],
                  style: TextStyle(
                    fontSize: dynamicFontSize,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ];
  }


  List<Widget> _buildTextOptions() {
    double dynamicFontSize = _getDynamicFontSize(context);

    List<Map<String, dynamic>> options = [
      {"label": "ABBREVIATE", "value": true},
      {"label": "NORMAL", "value": false},
    ];

    return [
      Row(
        children: <Widget>[
          Text(
            "TEXT:",
            style: TextStyle(
              fontSize: dynamicFontSize,),
          ),
          ...options.map((option) {
            bool isSelected = option["value"] == _changeRiddleText;
            return InkWell(
              onTap: () {
                setState(() {
                  _changeRiddleText = option["value"];
                  widget.onChangeRiddleTextSetting(_changeRiddleText);
                  _saveSettings('change_riddle_text', _changeRiddleText);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),  // Add padding for better appearance
                color: isSelected ? Colors.black : Colors.transparent,
                child: Text(
                  option["label"],
                  style: TextStyle(
                    fontSize: dynamicFontSize,  // <-- Set font size to 12
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    double dynamicFontSize = _getDynamicFontSize(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('SETTINGS',style: TextStyle(fontSize: dynamicFontSize)),
            ..._buildNumberOptions(),
            ..._buildFontSizeOptions(),
            ..._buildAnimationSpeedOptions(),
            ..._buildTextOptions(),
          ],
        ),
      ),
    );
  }
}
