import 'package:flutter/material.dart';
import '../models/text_item.dart';

class CanvasState {
  final List<TextItem> textItems;
  final String? selectedItemId;

  CanvasState({required this.textItems, this.selectedItemId});

  CanvasState copyWith({
    List<TextItem>? textItems,
    String? selectedItemId,
    bool clearSelection = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      selectedItemId: clearSelection
          ? null
          : (selectedItemId ?? this.selectedItemId),
    );
  }

  // Create a deep copy for history
  CanvasState clone() {
    return CanvasState(
      textItems: textItems.map((item) => item.copyWith()).toList(),
      selectedItemId: selectedItemId,
    );
  }
}

class CanvasStateManager extends ChangeNotifier {
  CanvasState _currentState = CanvasState(textItems: []);
  final List<CanvasState> _undoStack = [];
  final List<CanvasState> _redoStack = [];
  static const int maxHistorySize = 50;

  // Throttling for drag performance
  Offset? _lastUpdatePosition;
  DateTime? _lastUpdateTime;

  CanvasState get currentState => _currentState;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _saveState() {
    _undoStack.add(_currentState.clone());
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void addTextItem(TextItem item) {
    _saveState();
    final newItems = List<TextItem>.from(_currentState.textItems)..add(item);
    _currentState = _currentState.copyWith(
      textItems: newItems,
      selectedItemId: item.id,
    );
    notifyListeners();
  }

  void updateTextItem(String id, TextItem updatedItem) {
    _saveState();
    final newItems = _currentState.textItems.map((item) {
      return item.id == id ? updatedItem : item;
    }).toList();
    _currentState = _currentState.copyWith(textItems: newItems);
    notifyListeners();
  }

  void deleteTextItem(String id) {
    _saveState();
    final newItems = _currentState.textItems
        .where((item) => item.id != id)
        .toList();
    _currentState = _currentState.copyWith(
      textItems: newItems,
      clearSelection: _currentState.selectedItemId == id,
    );
    notifyListeners();
  }

  void selectTextItem(String? id) {
    _currentState = _currentState.copyWith(
      selectedItemId: id,
      clearSelection: id == null,
    );
    notifyListeners();
  }

  void updateTextPosition(String id, Offset position) {
    final now = DateTime.now();
    // Throttle updates to every 16ms (60fps) for smoother performance
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!).inMilliseconds < 16 &&
        _lastUpdatePosition != null &&
        (position - _lastUpdatePosition!).distance < 2) {
      return; // Skip this update if it's too soon and position barely changed
    }

    _lastUpdateTime = now;
    _lastUpdatePosition = position;

    final item = _currentState.textItems.firstWhere((item) => item.id == id);
    final updatedItem = item.copyWith(position: position);
    final newItems = _currentState.textItems.map((item) {
      return item.id == id ? updatedItem : item;
    }).toList();
    _currentState = _currentState.copyWith(textItems: newItems);
    notifyListeners();
  }

  void savePositionChange(String id) {
    _lastUpdateTime = null;
    _lastUpdatePosition = null;
    _saveState();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(_currentState.clone());
    _currentState = _undoStack.removeLast();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(_currentState.clone());
    _currentState = _redoStack.removeLast();
    notifyListeners();
  }

  TextItem? getSelectedItem() {
    if (_currentState.selectedItemId == null) return null;
    try {
      return _currentState.textItems.firstWhere(
        (item) => item.id == _currentState.selectedItemId,
      );
    } catch (e) {
      return null;
    }
  }
}
