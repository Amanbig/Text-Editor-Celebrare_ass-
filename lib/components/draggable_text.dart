import 'package:flutter/material.dart';

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

  Map<String, dynamic> toMap() {
  return {
    'text': text,
    'fontFamily': fontFamily,
    'fontColor': fontColor.value, // Store color as an int value
    'fontSize': fontSize,
    'isBold': isBold,
    'isItalic': isItalic,
    'isUnderline': isUnderline,
    'position': {'dx': position.dx, 'dy': position.dy}, // Offset as a Map
  };
}

static DraggableText fromMap(Map<String, dynamic> map, Function(DraggableText) onSelected, Function(DraggableText, Offset) updatePosition) {
  return DraggableText(
    text: map['text'],
    fontFamily: map['fontFamily'],
    fontColor: Color(map['fontColor']),
    fontSize: map['fontSize'],
    isBold: map['isBold'],
    isItalic: map['isItalic'],
    isUnderline: map['isUnderline'],
    position: Offset(map['position']['dx'], map['position']['dy']),
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