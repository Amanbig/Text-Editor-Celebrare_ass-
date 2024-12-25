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
  final List<Color> _backgroundColors = [
    Colors.white,
    Colors.white,
    Colors.white
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<List<DraggableText>> _pages = [[], [], []];
  final List<List<List<DraggableText>>> _undoStack = [[], [], []];
  final List<List<List<DraggableText>>> _redoStack = [[], [], []];
  int _textCounter = 0;
  DraggableText? _selectedText;

  @override
  void initState() {
    super.initState();
    // Initialize undo/redo stacks for each page
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

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
            ElevatedButton(
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
        isSelected: false,
      );
      _pages[_currentPage].add(newText);
      _textCounter++;
      _selectedText = newText;
    });
  }

  void _handleTextSelection(DraggableText text) {
    _saveStateToUndoStack();
    setState(() {
      _selectedText = text;
      _fontFamily = text.fontFamily;
      _fontColor = text.fontColor;
      _fontSize = text.fontSize;
      _isBold = text.isBold;
      _isItalic = text.isItalic;
      _isUnderline = text.isUnderline;

      for (var draggableText in _pages[_currentPage]) {
        draggableText.isSelected = draggableText == text;
      }
    });
  }

  void _updateTextPosition(DraggableText text, Offset newPosition) {
    _saveStateToUndoStack();
    setState(() {
      final index = _pages[_currentPage].indexOf(text);
      if (index != -1) {
        _pages[_currentPage][index] = text.copyWith(position: newPosition);
      }
    });
  }

  void _updateSelectedTextStyle() {
    if (_selectedText != null) {
      _saveStateToUndoStack();
      setState(() {
        final index = _pages[_currentPage].indexOf(_selectedText!);
        if (index != -1) {
          _pages[_currentPage][index] = _selectedText!.copyWith(
            fontFamily: _fontFamily,
            fontColor: _fontColor,
            fontSize: _fontSize,
            isBold: _isBold,
            isItalic: _isItalic,
            isUnderline: _isUnderline,
          );
          _selectedText = _pages[_currentPage][index];
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

  void _changeBackgroundColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Background Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _backgroundColors[_currentPage],
              onColorChanged: (color) {
                setState(() {
                  _backgroundColors[_currentPage] = color;
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

  void _deleteSelectedText() {
    if (_selectedText != null) {
      _saveStateToUndoStack();
      setState(() {
        _pages[_currentPage].remove(_selectedText);
        _selectedText = null;
      });
    }
  }

  void _saveStateToUndoStack() {
    _undoStack[_currentPage]
        .add(List<DraggableText>.from(_pages[_currentPage]));
    _redoStack[_currentPage].clear();
  }

  void _undoAction() {
    if (_undoStack[_currentPage].isNotEmpty) {
      _redoStack[_currentPage].add(List.from(_pages[_currentPage]));
      setState(() {
        _pages[_currentPage].clear();
        _pages[_currentPage].addAll(_undoStack[_currentPage].removeLast());
      });
    }
  }

  void _redoAction() {
    if (_redoStack[_currentPage].isNotEmpty) {
      _undoStack[_currentPage].add(List.from(_pages[_currentPage]));
      setState(() {
        _pages[_currentPage].clear();
        _pages[_currentPage].addAll(_redoStack[_currentPage].removeLast());
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _addPage() {
    _saveStateToUndoStack();
    setState(() {
      _pages.add([]);
      _undoStack.add([]);
      _redoStack.add([]);
      _backgroundColors.add(Colors.white);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Celebrare',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _undoAction,
            icon: const Icon(
              Icons.undo,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _redoAction,
            icon: const Icon(
              Icons.redo,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _deleteSelectedText,
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(color: _backgroundColors[index]),
                      ..._pages[index],
                      Positioned(
                        left: 10,
                        top: MediaQuery.of(context).size.height / 2 - 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _previousPage,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: MediaQuery.of(context).size.height / 2 - 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _nextPage,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
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
                            color:  _backgroundColors[_currentPage],
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
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
  Offset position;
  final Function(DraggableText) onSelected;
  final Function(DraggableText, Offset) updatePosition;
  bool isSelected;

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
    this.isSelected = false,
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
    bool? isSelected,
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
      isSelected: isSelected ?? this.isSelected,
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
            initialPosition = widget.position;
          },
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              widget.position = Offset(
                offset.dx,
                offset.dy -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              );
              widget.updatePosition(widget, widget.position);
            });
          },
          onDragEnd: (details) {
            setState(() {
              widget.position = Offset(
                details.offset.dx,
                details.offset.dy -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              );
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
