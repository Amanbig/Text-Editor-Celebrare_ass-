import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:text_editor/screens/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   List<TextSpan> _texts = [];
//   List<List<TextSpan>> _undoStack = [];
//   List<List<TextSpan>> _redoStack = [];
//   int? _selectedTextIndex; // Tracks the selected text index
//   Offset _currentPosition = Offset(50, 50); // Default position
//   double _fontSize = 16.0;
//   Color _textColor = Colors.black;
//   String _fontFamily = 'Arial';
//   bool _isBold = false;
//   bool _isItalic = false;
//   bool _isUnderline = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: GestureDetector(
//               onTapDown: (details) {
//                 setState(() {
//                   _currentPosition = details.localPosition;
//                 });
//               },
//               child: CustomPaint(
//                 size: Size.infinite,
//                 painter: TextCanvasPainter(
//                   texts: _texts,
//                   textDirection: TextDirection.ltr,
//                   onSelectText: (index) {
//                     setState(() {
//                       _selectedTextIndex = index;
//                       if (index != null) {
//                         _loadSelectedTextStyle(_texts[index]);
//                       }
//                     });
//                   },
//                   selectedTextIndex: _selectedTextIndex,
//                 ),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.add),
//                 onPressed: _addToCanvas,
//               ),
//               IconButton(
//                 icon: Icon(Icons.undo),
//                 onPressed: _undo,
//               ),
//               IconButton(
//                 icon: Icon(Icons.redo),
//                 onPressed: _redo,
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text('Font Size:'),
//               Slider(
//                 value: _fontSize,
//                 min: 10.0,
//                 max: 50.0,
//                 onChanged: (value) {
//                   setState(() {
//                     _fontSize = value;
//                     _updateSelectedTextStyle();
//                   });
//                 },
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text('Font Color:'),
//               ElevatedButton(
//                 onPressed: () => _pickColor(context),
//                 child: Text('Pick Color'),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               DropdownButton<String>(
//                 value: _fontFamily,
//                 items: [
//                   DropdownMenuItem(value: 'Arial', child: Text('Arial')),
//                   DropdownMenuItem(
//                       value: 'Times New Roman', child: Text('Times New Roman')),
//                 ],
//                 onChanged: (newValue) {
//                   setState(() {
//                     _fontFamily = newValue!;
//                     _updateSelectedTextStyle();
//                   });
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.format_bold),
//                 color: _isBold ? Colors.blue : Colors.black,
//                 onPressed: () {
//                   setState(() {
//                     _isBold = !_isBold;
//                     _updateSelectedTextStyle();
//                   });
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.format_italic),
//                 color: _isItalic ? Colors.blue : Colors.black,
//                 onPressed: () {
//                   setState(() {
//                     _isItalic = !_isItalic;
//                     _updateSelectedTextStyle();
//                   });
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.format_underline),
//                 color: _isUnderline ? Colors.blue : Colors.black,
//                 onPressed: () {
//                   setState(() {
//                     _isUnderline = !_isUnderline;
//                     _updateSelectedTextStyle();
//                   });
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addToCanvas() {
//     setState(() {
//       _undoStack.add([..._texts]);
//       _redoStack.clear();
//
//       _texts.add(
//         TextSpan(
//           text: 'Sample Text',
//           style: TextStyle(
//             fontSize: _fontSize,
//             color: _textColor,
//             fontFamily: _fontFamily,
//             fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
//             fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
//             decoration:
//             _isUnderline ? TextDecoration.underline : TextDecoration.none,
//           ),
//         ),
//       );
//     });
//   }
//
//   void _undo() {
//     if (_undoStack.isNotEmpty) {
//       setState(() {
//         _redoStack.add([..._texts]);
//         _texts = List.from(_undoStack.removeLast());
//       });
//     }
//   }
//
//   void _redo() {
//     if (_redoStack.isNotEmpty) {
//       setState(() {
//         _undoStack.add([..._texts]);
//         _texts = List.from(_redoStack.removeLast());
//       });
//     }
//   }
//
//   void _pickColor(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         Color tempColor = _textColor;
//         return AlertDialog(
//           title: Text('Pick a color'),
//           content: SingleChildScrollView(
//             child: ColorPicker(
//               pickerColor: tempColor,
//               onColorChanged: (color) {
//                 tempColor = color;
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text('Select'),
//               onPressed: () {
//                 setState(() {
//                   _textColor = tempColor;
//                   _updateSelectedTextStyle();
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _updateSelectedTextStyle() {
//     if (_selectedTextIndex != null) {
//       _texts[_selectedTextIndex!] = TextSpan(
//         text: _texts[_selectedTextIndex!].text,
//         style: TextStyle(
//           fontSize: _fontSize,
//           color: _textColor,
//           fontFamily: _fontFamily,
//           fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
//           fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
//           decoration:
//           _isUnderline ? TextDecoration.underline : TextDecoration.none,
//         ),
//       );
//     }
//   }
//
//   void _loadSelectedTextStyle(TextSpan textSpan) {
//     setState(() {
//       _fontSize = textSpan.style?.fontSize ?? 16.0;
//       _textColor = textSpan.style?.color ?? Colors.black;
//       _fontFamily = textSpan.style?.fontFamily ?? 'Arial';
//       _isBold = textSpan.style?.fontWeight == FontWeight.bold;
//       _isItalic = textSpan.style?.fontStyle == FontStyle.italic;
//       _isUnderline = textSpan.style?.decoration == TextDecoration.underline;
//     });
//   }
// }
//
// class TextCanvasPainter extends CustomPainter {
//   final List<TextSpan> texts;
//   final TextDirection textDirection;
//   final void Function(int?) onSelectText;
//   final int? selectedTextIndex;
//
//   TextCanvasPainter({
//     required this.texts,
//     required this.textDirection,
//     required this.onSelectText,
//     this.selectedTextIndex,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     double yOffset = 50;
//
//     for (int i = 0; i < texts.length; i++) {
//       final textSpan = texts[i];
//       final textPainter = TextPainter(
//         text: textSpan,
//         textDirection: textDirection,
//       );
//       textPainter.layout();
//       final textOffset = Offset(50, yOffset);
//       final backgroundPaint = Paint()
//         ..color = selectedTextIndex == i ? Colors.yellow.withOpacity(0.5) : Colors.transparent;
//       canvas.drawRect(
//         Rect.fromLTWH(
//           textOffset.dx,
//           textOffset.dy,
//           textPainter.width,
//           textPainter.height,
//         ),
//         backgroundPaint,
//       );
//       textPainter.paint(canvas, textOffset);
//       yOffset += textPainter.size.height + 10; // Line spacing
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
