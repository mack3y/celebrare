import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/text_item.dart';
import '../providers/canvas_state_manager.dart';
import '../widgets/draggable_text_widget.dart';
import '../widgets/text_editor_panel.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stateManager = context.watch<CanvasStateManager>();
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Canvas Editor'),
          ],
        ),
        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: stateManager.canUndo ? () => stateManager.undo() : null,
            tooltip: 'Undo',
            color: stateManager.canUndo
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).disabledColor,
          ),
          // Redo button
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: stateManager.canRedo ? () => stateManager.redo() : null,
            tooltip: 'Redo',
            color: stateManager.canRedo
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLargeScreen
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewText(context, stateManager),
        icon: const Icon(Icons.add),
        label: const Text('Add Text'),
        elevation: 4,
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Canvas Area
        Expanded(flex: 2, child: _buildCanvas(context)),
        // Editor Panel (Fixed width on desktop)
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: const TextEditorPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.35; // 35% of screen height, max 240
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Column(
      children: [
        // Canvas Area
        Expanded(child: _buildCanvas(context)),
        // Editor Panel (Bottom sheet on mobile) - Hide when keyboard is open
        if (!isKeyboardOpen)
          SizedBox(
            height: panelHeight.clamp(200, 240),
            child: const TextEditorPanel(),
          ),
      ],
    );
  }

  Widget _buildCanvas(BuildContext context) {
    final stateManager = context.watch<CanvasStateManager>();
    final textItems = stateManager.currentState.textItems;
    final selectedItemId = stateManager.currentState.selectedItemId;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        // Only deselect if we're clicking on the canvas background
        // Check if the tap is not on any text widget
        bool tappedOnText = false;
        for (final item in textItems) {
          // Simple bounds check (could be improved)
          final textRect = Rect.fromLTWH(
            item.position.dx,
            item.position.dy,
            100, // approximate width
            item.fontSize + 16, // approximate height
          );
          if (textRect.contains(details.localPosition)) {
            tappedOnText = true;
            break;
          }
        }
        if (!tappedOnText) {
          stateManager.selectTextItem(null);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Grid background
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(color: Colors.grey[200]!),
              ),

              // Empty state
              if (textItems.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Click "Add Text" to get started',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                ),

              // Text items
              ...textItems.map((textItem) {
                final isSelected = textItem.id == selectedItemId;
                return DraggableTextWidget(
                  key: ValueKey(textItem.id),
                  textItem: textItem,
                  isSelected: isSelected,
                  onTap: () {
                    stateManager.selectTextItem(textItem.id);
                  },
                  onDragUpdate: (position) {
                    stateManager.updateTextPosition(textItem.id, position);
                  },
                  onDragEnd: () {
                    stateManager.savePositionChange(textItem.id);
                  },
                  onTextChanged: (newText) {
                    stateManager.updateTextItem(
                      textItem.id,
                      textItem.copyWith(text: newText),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewText(BuildContext context, CanvasStateManager stateManager) {
    final newItem = TextItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Double tap to edit',
      position: const Offset(100, 100),
    );
    stateManager.addTextItem(newItem);
  }
}

// Custom painter for grid background
class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPainter({required this.color, this.spacing = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.spacing != spacing;
  }
}
