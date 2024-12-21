import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _fontFamily = 'Arial';
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  double _fontSize = 16.0;
  Color _fontColor = Colors.black;

  final List<Widget> _draggableTexts = [];
  final List<List<Widget>> _undoStack = [];
  final List<List<Widget>> _redoStack = [];
  int _textCounter = 0;

  void _addText() {
    _saveStateToUndoStack();
    _showTextInputDialog();
  }

  void _showTextInputDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Text"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: "Enter your text",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addDraggableText(textController.text.isNotEmpty
                    ? textController.text
                    : 'Text $_textCounter');
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addDraggableText(String text) {
    setState(() {
      _draggableTexts.add(
        DraggableText(
          key: UniqueKey(),
          text: text,
          fontFamily: _fontFamily,
          fontColor: _fontColor,
          fontSize: _fontSize,
          isBold: _isBold,
          isItalic: _isItalic,
          isUnderline: _isUnderline,
        ),
      );
      _textCounter++;
    });
  }

  void _changeFontColor() {
    _saveStateToUndoStack();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Font Color"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ColorPicker(
                  pickerColor: _fontColor, // Current font color
                  onColorChanged: (color) {
                    setState(() {
                      _fontColor = color;
                    });
                  },
                  showLabel: true, // Show the label for the color value
                  pickerAreaHeightPercent: 0.8, // Adjust the height of the picker area
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _saveStateToUndoStack() {
    _undoStack.add(List.from(_draggableTexts));
    _redoStack.clear();
  }

  void _undoAction() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(List.from(_draggableTexts));
      setState(() {
        _draggableTexts
          ..clear()
          ..addAll(_undoStack.removeLast());
      });
    }
  }

  void _redoAction() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(List.from(_draggableTexts));
      setState(() {
        _draggableTexts
          ..clear()
          ..addAll(_redoStack.removeLast());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Celebrare',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _undoAction,
                        icon: const Icon(Icons.undo),
                      ),
                      IconButton(
                        onPressed: _redoAction,
                        icon: const Icon(Icons.redo),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(color: Colors.green),
                  ..._draggableTexts,
                ],
              ),
            ),
            Row(
              children: [
                const Text("Font Size:"),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8.0,
                    max: 48.0,
                    divisions: 20,
                    label: _fontSize.toStringAsFixed(1),
                    onChanged: (newValue) {
                      _saveStateToUndoStack();
                      setState(() {
                        _fontSize = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _addText,
              child: const Text("Add Text"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<String>(
                  value: _fontFamily,
                  items: const [
                    DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                    DropdownMenuItem(value: 'Times New Roman', child: Text('Times New Roman')),
                    DropdownMenuItem(value: 'Courier New', child: Text('Courier New')),
                    DropdownMenuItem(value: 'Verdana', child: Text('Verdana')),
                    DropdownMenuItem(value: 'Georgia', child: Text('Georgia')),
                    DropdownMenuItem(value: 'Tahoma', child: Text('Tahoma')),
                    DropdownMenuItem(value: 'Comic Sans MS', child: Text('Comic Sans MS')),
                    DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                    DropdownMenuItem(value: 'Lora', child: Text('Lora')),
                    DropdownMenuItem(value: 'Open Sans', child: Text('Open Sans')),
                  ],

                  onChanged: (newValue) {
                    setState(() {
                      _fontFamily = newValue!;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_bold, color: _isBold ? Colors.blue : Colors.black),
                  onPressed: () {
                    setState(() {
                      _isBold = !_isBold;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_italic, color: _isItalic ? Colors.blue : Colors.black),
                  onPressed: () {
                    setState(() {
                      _isItalic = !_isItalic;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_underline, color: _isUnderline ? Colors.blue : Colors.black),
                  onPressed: () {
                    setState(() {
                      _isUnderline = !_isUnderline;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Font Color:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _changeFontColor,
                  child: Container(
                    width: 12,
                    height: 12,
                    color: _fontColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DraggableText extends StatefulWidget {
  final String text;
  final String fontFamily;
  final Color fontColor;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;

  const DraggableText({
    super.key,
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.fontSize,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
  });

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText> {
  Offset position = const Offset(50, 50);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: _buildText(),
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            position = details.offset;
          });
        },
        child: _buildText(),
      ),
    );
  }

  Widget _buildText() {
    return Text(
      widget.text,
      style: TextStyle(
        fontFamily: widget.fontFamily,
        fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: widget.isItalic ? FontStyle.italic : FontStyle.normal,
        decoration: widget.isUnderline ? TextDecoration.underline : null,
        fontSize: widget.fontSize,
        color: widget.fontColor,
      ),
    );
  }
}

class ColorPickerOption extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorPickerOption({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        width: double.infinity,
        height: 40.0,
        color: color,
      ),
    );
  }
}
