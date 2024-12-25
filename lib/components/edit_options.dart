import 'package:flutter/material.dart';

class EditOptions extends StatefulWidget {
  final double fontSize;
  final String fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Color fontColor;
  final Color backgroundColor;
  final Function(double) onFontSizeChanged;
  final Function(String) onFontFamilyChanged;
  final Function(bool) onBoldChanged;
  final Function(bool) onItalicChanged;
  final Function(bool) onUnderlineChanged;
  final Function() onChangeFontColor;
  final Function() onChangeBackgroundColor;
  final Function() onAddText;

  const EditOptions({
    super.key,
    required this.fontSize,
    required this.fontFamily,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.fontColor,
    required this.backgroundColor,
    required this.onFontSizeChanged,
    required this.onFontFamilyChanged,
    required this.onBoldChanged,
    required this.onItalicChanged,
    required this.onUnderlineChanged,
    required this.onChangeFontColor,
    required this.onChangeBackgroundColor,
    required this.onAddText,
  });

  @override
  State<EditOptions> createState() => _EditOptionsState();
}

class _EditOptionsState extends State<EditOptions> {
  late double _fontSize;
  late String _fontFamily;
  late bool _isBold;
  late bool _isItalic;
  late bool _isUnderline;
  late Color _fontColor;
  late Color _backgroundColor;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
    _fontFamily = widget.fontFamily;
    _isBold = widget.isBold;
    _isItalic = widget.isItalic;
    _isUnderline = widget.isUnderline;
    _fontColor = widget.fontColor;
    _backgroundColor = widget.backgroundColor;
  }

  // This method is called whenever the widget's properties are updated
  @override
  void didUpdateWidget(covariant EditOptions oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ensure the widget updates when the parent passes new values
    if (oldWidget.fontColor != widget.fontColor) {
      setState(() {
        _fontColor = widget.fontColor;
      });
    }

    if (oldWidget.backgroundColor != widget.backgroundColor) {
      setState(() {
        _backgroundColor = widget.backgroundColor;
      });
    }
  }

  void _updateSelectedTextStyle() {
    widget.onFontSizeChanged(_fontSize);
    widget.onFontFamilyChanged(_fontFamily);
    widget.onBoldChanged(_isBold);
    widget.onItalicChanged(_isItalic);
    widget.onUnderlineChanged(_isUnderline);
  }

  void _changeFontColor() {
    widget.onChangeFontColor();
  }

  void _changeBackgroundColor() {
    widget.onChangeBackgroundColor();
  }

  void _addText() {
    widget.onAddText();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Font Size:",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 8.0,
                  max: 48.0,
                  divisions: 20,
                  label: _fontSize.toStringAsFixed(1),
                  onChanged: (newValue) {
                    setState(() {
                      _fontSize = newValue;
                      _updateSelectedTextStyle();
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _fontFamily,
                dropdownColor: Colors.black,
                items: const [
                  DropdownMenuItem(
                      value: 'Arial',
                      child: Text(
                        'Arial',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                  DropdownMenuItem(
                      value: 'Times New Roman',
                      child: Text('Times New Roman',
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 'Courier New',
                      child: Text('Courier New',
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 'Verdana',
                      child: Text('Verdana',
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 'Georgia',
                      child: Text('Georgia',
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 'Comic Sans MS',
                      child: Text('Comic Sans MS',
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 'Trebuchet MS',
                      child: Text('Trebuchet MS',
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 'Impact',
                      child: Text('Impact',
                          style: TextStyle(color: Colors.white))),
                ],
                style: const TextStyle(color: Colors.white),
                onChanged: (newValue) {
                  setState(() {
                    _fontFamily = newValue!;
                    _updateSelectedTextStyle();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold,
                    color: _isBold ? Colors.blue : Colors.white),
                onPressed: () {
                  setState(() {
                    _isBold = !_isBold;
                    _updateSelectedTextStyle();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_italic,
                    color: _isItalic ? Colors.blue : Colors.white),
                onPressed: () {
                  setState(() {
                    _isItalic = !_isItalic;
                    _updateSelectedTextStyle();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_underline,
                    color: _isUnderline ? Colors.blue : Colors.white),
                onPressed: () {
                  setState(() {
                    _isUnderline = !_isUnderline;
                    _updateSelectedTextStyle();
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Font Color:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _changeFontColor,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _fontColor,
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
              const Text(
                "Background Color:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _changeBackgroundColor,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.white)),
            onPressed: _addText,
            child: const Text(
              "Add Text",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
