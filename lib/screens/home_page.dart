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

  final List<DraggableText> _draggableTexts = [];
  final List<List<DraggableText>> _undoStack = [];
  final List<List<DraggableText>> _redoStack = [];
  int _textCounter = 0;
  DraggableText? _selectedText;

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
            decoration: const InputDecoration(hintText: "Enter your text"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
    _saveStateToUndoStack();
    setState(() {
      final newText = DraggableText(
        key: UniqueKey(),
        text: text,
        fontFamily: _fontFamily,
        fontColor: _fontColor,
        fontSize: _fontSize,
        isBold: _isBold,
        isItalic: _isItalic,
        isUnderline: _isUnderline,
        onSelected: _handleTextSelection,
        updatePosition: _updateTextPosition,
      );
      _draggableTexts.add(newText);
      _textCounter++;
      _selectedText = newText;
    });
  }

  void _handleTextSelection(DraggableText text) {
    setState(() {
      _selectedText = text;
      // Update the controls to match selected text
      _fontFamily = text.fontFamily;
      _fontColor = text.fontColor;
      _fontSize = text.fontSize;
      _isBold = text.isBold;
      _isItalic = text.isItalic;
      _isUnderline = text.isUnderline;
    });
  }

  void _updateTextPosition(DraggableText text, Offset newPosition) {
    _saveStateToUndoStack();
    setState(() {
      final index = _draggableTexts.indexOf(text);
      if (index != -1) {
        _draggableTexts[index] = text.copyWith(position: newPosition);
      }
    });
  }

  void _updateSelectedTextStyle() {
    if (_selectedText != null) {
      _saveStateToUndoStack();
      setState(() {
        final index = _draggableTexts.indexOf(_selectedText!);
        if (index != -1) {
          _draggableTexts[index] = _selectedText!.copyWith(
            fontFamily: _fontFamily,
            fontColor: _fontColor,
            fontSize: _fontSize,
            isBold: _isBold,
            isItalic: _isItalic,
            isUnderline: _isUnderline,
          );
          _selectedText = _draggableTexts[index];
        }
      });
    }
  }

  void _changeFontColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Font Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _fontColor,
              onColorChanged: (color) {
                setState(() {
                  _fontColor = color;
                  _updateSelectedTextStyle();
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
        _draggableTexts.clear();
        _draggableTexts.addAll(_undoStack.removeLast());
      });
    }
  }

  void _redoAction() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(List.from(_draggableTexts));
      setState(() {
        _draggableTexts.clear();
        _draggableTexts.addAll(_redoStack.removeLast());
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
                Container(color: Colors.grey),
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
                    setState(() {
                      _fontSize = newValue;
                      _updateSelectedTextStyle();
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
                  DropdownMenuItem(value: 'Comic Sans MS', child: Text('Comic Sans MS')),
                  DropdownMenuItem(value: 'Trebuchet MS', child: Text('Trebuchet MS')),
                  DropdownMenuItem(value: 'Impact', child: Text('Impact')),
                ],
                onChanged: (newValue) {
                  setState(() {
                    _fontFamily = newValue!;
                    _updateSelectedTextStyle();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold,
                    color: _isBold ? Colors.blue : Colors.black),
                onPressed: () {
                  setState(() {
                    _isBold = !_isBold;
                    _updateSelectedTextStyle();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_italic,
                    color: _isItalic ? Colors.blue : Colors.black),
                onPressed: () {
                  setState(() {
                    _isItalic = !_isItalic;
                    _updateSelectedTextStyle();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_underline,
                    color: _isUnderline ? Colors.blue : Colors.black),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _changeFontColor,
                child: Container(
                  width: 24,
                  height: 24,
                  color: _fontColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
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
  Offset position;
  final Function(DraggableText) onSelected;
  final Function(DraggableText, Offset) updatePosition;

  DraggableText({
    super.key,
    required this.text,
    required this.fontFamily,
    required this.fontColor,
    required this.fontSize,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.onSelected,
    required this.updatePosition,
    this.position = const Offset(50, 50),
  });

  DraggableText copyWith({
    String? text,
    String? fontFamily,
    Color? fontColor,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    Offset? position,
  }) {
    return DraggableText(
      key: key,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontColor: fontColor ?? this.fontColor,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      position: position ?? this.position,
      onSelected: onSelected,
      updatePosition: updatePosition,
    );
  }

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText> {
  Offset? initialPosition;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTap: () => widget.onSelected(widget),
        child: Draggable(
          feedback: Material(
            color: Colors.transparent,
            child: _buildText(),
          ),
          childWhenDragging: Container(),
          onDragStarted: () {
            // Store the initial position when the drag starts
            initialPosition = widget.position;
          },
          onDraggableCanceled: (velocity, offset) {
            // Update the final position after the drag ends
            setState(() {
              widget.position = initialPosition!;
            });
          },
          onDragEnd: (details) {
            // Update the final position after the drag ends
            setState(() {
              widget.position = details.offset;
              widget.updatePosition(widget, widget.position);
            });
          },
          child: _buildText(),
        ),
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