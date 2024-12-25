import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:text_editor/components/draggable_text.dart';
import 'package:text_editor/components/edit_options.dart';
import 'package:text_editor/components/options.dart';

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
  int _selectedOption = 0;

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
        backgroundColor: Colors.black,
        title: const Text("Add Text", style: TextStyle(color: Colors.white)),
        content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: "Enter your text", hintStyle: TextStyle(color: Colors.white)),
        style: const TextStyle(color: Colors.white),
        ),
        actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.white),
          ),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _addDraggableText(textController.text.isNotEmpty
          ? textController.text
          : 'Text $_textCounter');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.white),
          ),
          child: const Text("Add", style: TextStyle(color: Colors.white)),
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
  
  void _showEditOptions() {
    setState(() {
      _selectedOption = 1;
    });
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
                  Center(
                    child: AspectRatio(aspectRatio: 9 / 16,
                    child: Container(color: _backgroundColors[index])),
                  ),
                  ..._pages[index],
                  ],
                );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
                color: _currentPage > 0?Colors.white:Colors.white.withOpacity(0.5),
              ),
              Row(
                children: List<Widget>.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                  ),
                ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextPage,
                color:_currentPage < _pages.length - 1? Colors.white:Colors.white.withOpacity(0.5),
              ),
              ],
            ),
            _selectedOption == 1
              ? EditOptions(
                fontSize: _fontSize,
                fontFamily: _fontFamily,
                isBold: _isBold,
                isItalic: _isItalic,
                isUnderline: _isUnderline,
                fontColor: _fontColor,
                backgroundColor: _backgroundColors[_currentPage],
                onFontSizeChanged: (value) {
                  setState(() {
                  _fontSize = value;
                  _updateSelectedTextStyle();
                  });
                },
                onFontFamilyChanged: (value) {
                  setState(() {
                  _fontFamily = value;
                  _updateSelectedTextStyle();
                  });
                },
                onBoldChanged: (value) {
                  setState(() {
                  _isBold = value;
                  _updateSelectedTextStyle();
                  });
                },
                onItalicChanged: (value) {
                  setState(() {
                  _isItalic = value;
                  _updateSelectedTextStyle();
                  });
                },
                onUnderlineChanged: (value) {
                  setState(() {
                  _isUnderline = value;
                  _updateSelectedTextStyle();
                  });
                },
                onChangeFontColor: _changeFontColor,
                onChangeBackgroundColor: _changeBackgroundColor,
                onAddText: _addText,
                
                )
              : Options(onEditOptions: _showEditOptions),
          ],
        ),
      ),
    );
  }
}


