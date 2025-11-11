import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/text_item.dart';

class DraggableTextWidget extends StatefulWidget {
  final TextItem textItem;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Offset) onDragUpdate;
  final VoidCallback onDragEnd;
  final Function(String) onTextChanged;

  const DraggableTextWidget({
    super.key,
    required this.textItem,
    required this.isSelected,
    required this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTextChanged,
  });

  @override
  State<DraggableTextWidget> createState() => _DraggableTextWidgetState();
}

class _DraggableTextWidgetState extends State<DraggableTextWidget> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textItem.text);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setState(() {
          _isEditing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DraggableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textItem.text != oldWidget.textItem.text && !_isEditing) {
      _controller.text = widget.textItem.text;
    }
    // If the widget becomes unselected, exit edit mode
    if (!widget.isSelected && oldWidget.isSelected && _isEditing) {
      setState(() {
        _isEditing = false;
      });
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.textItem.position.dx,
      top: widget.textItem.position.dy,
      child: GestureDetector(
        onTap: () {
          // Always select the text first on tap
          widget.onTap();
        },
        onDoubleTap: () {
          // Only allow editing if already selected
          if (widget.isSelected) {
            setState(() {
              _isEditing = true;
            });
            _focusNode.requestFocus();
          } else {
            // If not selected, just select it
            widget.onTap();
          }
        },
        onPanStart: _isEditing
            ? null
            : (details) {
                _dragStartPosition = widget.textItem.position;
              },
        onPanUpdate: _isEditing
            ? null
            : (details) {
                if (_dragStartPosition != null) {
                  // Update position based on cumulative offset from start
                  widget.onDragUpdate(
                    Offset(
                      _dragStartPosition!.dx + details.localPosition.dx - 8,
                      _dragStartPosition!.dy + details.localPosition.dy - 8,
                    ),
                  );
                }
              },
        onPanEnd: _isEditing
            ? null
            : (_) {
                _dragStartPosition = null;
                widget.onDragEnd();
              },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: widget.isSelected
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: _isEditing ? _buildEditField() : _buildText(),
        ),
      ),
    );
  }

  Widget _buildText() {
    TextStyle textStyle = GoogleFonts.getFont(
      widget.textItem.fontFamily,
      fontSize: widget.textItem.fontSize,
      fontWeight: widget.textItem.fontWeight,
      fontStyle: widget.textItem.fontStyle,
      color: widget.textItem.color,
      decoration: widget.textItem.textDecoration,
    );

    return Text(widget.textItem.text, style: textStyle);
  }

  Widget _buildEditField() {
    TextStyle textStyle = GoogleFonts.getFont(
      widget.textItem.fontFamily,
      fontSize: widget.textItem.fontSize,
      fontWeight: widget.textItem.fontWeight,
      fontStyle: widget.textItem.fontStyle,
      color: widget.textItem.color,
      decoration: widget.textItem.textDecoration,
    );

    return IntrinsicWidth(
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: textStyle,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onTextChanged,
        maxLines: null,
        autofocus: true,
      ),
    );
  }
}
