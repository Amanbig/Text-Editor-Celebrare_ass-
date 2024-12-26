import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:text_editor/components/draggable_text.dart';
import 'package:text_editor/components/edit_options.dart';
import 'package:text_editor/screens/edit_order.dart';
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

  final List<List<DraggableText>> _pages = [];
  final List<List<List<DraggableText>>> _undoStack = [];
  final List<List<List<DraggableText>>> _redoStack = [];
  int _textCounter = 0;
  DraggableText? _selectedText;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore(
      'document_id',
      _handleTextSelection,
      _updateTextPosition,
    );
    setState(() {});
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Future<void> _saveDataToFirestore(
      String documentId,
      List<List<DraggableText>> pages,
    ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Flatten the pages into a list of maps
      List<List<Map<String, dynamic>>> serializedPages = pages
          .map((page) => page.map((text) => text.toMap()).toList())
          .toList();

      // Create a map to hold all data
      Map<String, dynamic> data = {
        'pages': serializedPages,
      };

      // Convert the data map to a JSON string
      String jsonData = jsonEncode(data);

      // Reference to the document
      DocumentReference docRef =
          firestore.collection('your_collection').doc(documentId);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, update it
        await docRef.update({
          'data': jsonData,
        });
        print("Data updated successfully!");
      } else {
        // Document does not exist, create it
        await docRef.set({
          'data': jsonData,
        });
        print("Data saved successfully!");
      }
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> _loadDataFromFirestore(
      String documentId,
      Function(DraggableText) onSelected,
      Function(DraggableText, Offset) updatePosition) async {
    try {
      final firestore = FirebaseFirestore.instance;

      DocumentSnapshot snapshot =
          await firestore.collection('your_collection').doc(documentId).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        // Check if the 'data' field is a string (as it contains the JSON string)
        if (data['data'] is String) {
          // Decode the JSON string into a Map
          final jsonData = jsonDecode(data['data']) as Map<String, dynamic>;

          _pages.clear();
          _undoStack.clear();
          _redoStack.clear();

          // Deserialize pages (ensure pages is a List)
          if (jsonData['pages'] is List) {
            List pagesData = jsonData['pages'];
            for (var page in pagesData) {
              if (page is List) {
                List<DraggableText> pageTexts = [];
                for (var textMap in page) {
                  if (textMap is Map<String, dynamic>) {
                    pageTexts.add(DraggableText.fromMap(
                        textMap, onSelected, updatePosition));
                  }
                }
                _pages.add(pageTexts);
                _undoStack.add([]);
                _redoStack.add([]);
              }
            }
          } else {
            print("Invalid data format for 'pages': $jsonData['pages']");
          }

          print("Data loaded successfully!");
        } else {
          print("Invalid or missing 'data' field in document.");
        }
      } else {
        print("No document found with ID: $documentId");

        // Create empty data structure
        Map<String, dynamic> newData = {
          'pages': [],
        };

        // Convert the data map to a JSON string
        String jsonData = jsonEncode({'data': newData});

        // Optionally create a new document if not found
        await firestore.collection('your_collection').doc(documentId).set({
          'data': jsonData, // Store the JSON string
        });

        print("New document created with ID: $documentId");
      }
    } catch (e) {
      print("Error loading data: $e");
    }
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
            decoration: const InputDecoration(
                hintText: "Enter your text",
                hintStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.white),
              ),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
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
    _saveDataToFirestore('document_id', _pages);
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
    _saveDataToFirestore('document_id', _pages);
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
      _saveDataToFirestore('document_id', _pages);
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

  void _showMainOptions() {
    setState(() {
      _selectedOption = 0;
    });
  }

  void _showPageOrderOptions() {
    setState(() {
      _selectedOption = 2;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditOrderPage(
          pages: _pages,
          backgroundColors: _backgroundColors,
          onReorder: _reorderPages,
          onUpdatePages: _updatePages,
          onAddPage: _addPage,
        ),
      ));
    });
    _saveDataToFirestore('document_id', _pages);
  }

  void _reorderPages(
      List<List<DraggableText>> reorderedPages, List<Color> reorderedColors) {
    setState(() {
      _pages.clear();
      _undoStack.clear();
      _redoStack.clear();
      _pages.addAll(reorderedPages);
      _undoStack.addAll(List.generate(reorderedPages.length, (_) => []));
      _redoStack.addAll(List.generate(reorderedPages.length, (_) => []));
      _backgroundColors.clear();
      _backgroundColors.addAll(reorderedColors);
    });
    _saveDataToFirestore('document_id', _pages);
  }

  void _updatePages(
      List<List<DraggableText>> updatedPages, List<Color> updatedColors) {
    setState(() {
      _pages.clear();
      _undoStack.clear();
      _redoStack.clear();
      _pages.addAll(updatedPages);
      _undoStack.addAll(List.generate(updatedPages.length, (_) => []));
      _redoStack.addAll(List.generate(updatedPages.length, (_) => []));
      _backgroundColors.clear();
      _backgroundColors.addAll(updatedColors);
    });
    _saveDataToFirestore('document_id', _pages);
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
    _saveDataToFirestore('document_id', _pages);
  }

  void _deleteSelectedText() {
    if (_selectedText != null) {
      _saveStateToUndoStack();
      setState(() {
        _pages[_currentPage].remove(_selectedText);
        _selectedText = null;
      });
      _saveDataToFirestore('document_id', _pages);
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
      _saveDataToFirestore('document_id', _pages);
    }
  }

  void _redoAction() {
    if (_redoStack[_currentPage].isNotEmpty) {
      _undoStack[_currentPage].add(List.from(_pages[_currentPage]));
      setState(() {
        _pages[_currentPage].clear();
        _pages[_currentPage].addAll(_redoStack[_currentPage].removeLast());
      });
      _saveDataToFirestore('document_id', _pages);
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
    _saveDataToFirestore('document_id', _pages);
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
        actions: _selectedOption == 1
            ? [
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
              ]
            : null,
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
                        child: AspectRatio(
                            aspectRatio: 9 / 16,
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
                  color: _currentPage > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
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
                  color: _currentPage < _pages.length - 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
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
                    onSelectedState: _showMainOptions,
                  )
                : Options(
                    onEditOptions: _showEditOptions,
                    onEditOrder: _showPageOrderOptions,
                  ),
          ],
        ),
      ),
    );
  }
}
