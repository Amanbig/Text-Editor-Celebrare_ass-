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
              // Correct the position after drag cancellation
              widget.position = Offset(
                offset.dx,
                offset.dy - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
              );
              widget.updatePosition(widget, widget.position);
            });
          },
          onDragEnd: (details) {
            setState(() {
              // Calculate the effective height and width of the draggable area
              double pageHeight = MediaQuery.of(context).size.height;
              double pageWidth = MediaQuery.of(context).size.width;

              // Ensure the position respects the boundaries
              double newX = details.offset.dx.clamp(0.0, pageWidth);
              double newY = details.offset.dy
                  .clamp(AppBar().preferredSize.height + MediaQuery.of(context).padding.top, pageHeight);

              // Update position
              widget.position = Offset(newX, newY);
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
