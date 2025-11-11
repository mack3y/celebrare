import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/text_item.dart';
import '../providers/canvas_state_manager.dart';

class TextEditorPanel extends StatefulWidget {
  const TextEditorPanel({super.key});

  @override
  State<TextEditorPanel> createState() => _TextEditorPanelState();
}

class _TextEditorPanelState extends State<TextEditorPanel> {
  final TextEditingController _textController = TextEditingController();

  // Available font families
  final List<String> _fontFamilies = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Raleway',
    'Oswald',
    'Playfair Display',
    'Dancing Script',
    'Pacifico',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateManager = context.watch<CanvasStateManager>();
    final selectedItem = stateManager.getSelectedItem();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (selectedItem != null) {
      _textController.text = selectedItem.text;
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: selectedItem == null
          ? _buildNoSelectionView()
          : _buildEditorView(selectedItem, stateManager),
    );
  }

  Widget _buildNoSelectionView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a text element to edit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorView(TextItem item, CanvasStateManager stateManager) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Properties',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  stateManager.deleteTextItem(item.id);
                },
                tooltip: 'Delete',
                color: Colors.red,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Font Family & Size Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: item.fontFamily,
                  decoration: InputDecoration(
                    labelText: 'Font',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: _fontFamilies.map((font) {
                    return DropdownMenuItem(
                      value: font,
                      child: Text(
                        font,
                        style: GoogleFonts.getFont(font, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      stateManager.updateTextItem(
                        item.id,
                        item.copyWith(fontFamily: value),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Size',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: item.fontSize.round().toString(),
                  ),
                  onChanged: (value) {
                    final size = double.tryParse(value);
                    if (size != null && size >= 12 && size <= 120) {
                      stateManager.updateTextItem(
                        item.id,
                        item.copyWith(fontSize: size),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Text Style Buttons with Color Picker
          Row(
            children: [
              Expanded(
                child: _buildCompactStyleButton(
                  icon: Icons.format_bold,
                  isActive: item.fontWeight.index >= FontWeight.w700.index,
                  onPressed: () {
                    stateManager.updateTextItem(
                      item.id,
                      item.copyWith(
                        fontWeight:
                            item.fontWeight.index >= FontWeight.w700.index
                            ? FontWeight.w400
                            : FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildCompactStyleButton(
                  icon: Icons.format_italic,
                  isActive: item.fontStyle == FontStyle.italic,
                  onPressed: () {
                    stateManager.updateTextItem(
                      item.id,
                      item.copyWith(
                        fontStyle: item.fontStyle == FontStyle.italic
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildCompactStyleButton(
                  icon: Icons.format_underline,
                  isActive: item.underline,
                  onPressed: () {
                    stateManager.updateTextItem(
                      item.id,
                      item.copyWith(underline: !item.underline),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildCompactStyleButton(
                  icon: Icons.format_strikethrough,
                  isActive: item.lineThrough,
                  onPressed: () {
                    stateManager.updateTextItem(
                      item.id,
                      item.copyWith(lineThrough: !item.lineThrough),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildColorPickerButton(
                  context: context,
                  color: item.color,
                  onPressed: () =>
                      _showColorPicker(context, item, stateManager),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Font Weight Chips - Compact
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _buildCompactWeightChip(
                'Light',
                FontWeight.w300,
                item,
                stateManager,
              ),
              _buildCompactWeightChip(
                'Regular',
                FontWeight.w400,
                item,
                stateManager,
              ),
              _buildCompactWeightChip(
                'Medium',
                FontWeight.w500,
                item,
                stateManager,
              ),
              _buildCompactWeightChip(
                'Bold',
                FontWeight.w700,
                item,
                stateManager,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStyleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return IconButton.filled(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isActive
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildColorPickerButton({
    required BuildContext context,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton.filled(
      icon: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildCompactWeightChip(
    String label,
    FontWeight weight,
    TextItem item,
    CanvasStateManager stateManager,
  ) {
    final isSelected = item.fontWeight == weight;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        stateManager.updateTextItem(item.id, item.copyWith(fontWeight: weight));
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showColorPicker(
    BuildContext context,
    TextItem item,
    CanvasStateManager stateManager,
  ) {
    Color pickerColor = item.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
                displayThumbColor: true,
                labelTypes: const [],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              stateManager.updateTextItem(
                item.id,
                item.copyWith(color: pickerColor),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
