# Canvas Text Editor

A beautiful and responsive Flutter application for creating and editing text on a canvas with rich formatting options.

## Features

### ✨ Core Features
- **Interactive Canvas**: Add and drag text elements freely on a beautiful canvas
- **Rich Text Editing**: 
  - 10+ Beautiful font families (Roboto, Montserrat, Poppins, Playfair Display, Dancing Script, etc.)
  - Font size control (12-120px)
  - Font weights (Light, Regular, Medium, Semi Bold, Bold, Extra Bold)
  - Font styles (Bold, Italic, Underline, Strikethrough)
  - 19 color options
- **Undo/Redo**: Full undo/redo support for all operations (up to 50 steps)
- **Responsive Design**: Optimized for both mobile and desktop
  - Desktop: Side-by-side canvas and editor panel
  - Mobile: Bottom sheet editor panel

### 🎨 Beautiful UI
- Material 3 design system
- Smooth animations and transitions
- Grid background for better positioning
- Visual selection indicators
- Custom typography using Google Fonts

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository or navigate to the project directory:
   ```bash
   cd /path/to/celebrare
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

   Or for web:
   ```bash
   flutter run -d chrome
   ```

## How to Use

1. **Add Text**: Click the "Add Text" floating action button to add a new text element
2. **Move Text**: Tap and drag any text element to reposition it
3. **Edit Text**: 
   - Tap on any text element to select it
   - The editor panel will appear (right side on desktop, bottom on mobile)
   - Modify text content, font family, size, weight, style, and color
4. **Delete Text**: Select a text element and click the delete button in the editor panel
5. **Undo/Redo**: Use the undo/redo buttons in the app bar to revert or reapply changes

## Project Structure

```
lib/
├── models/
│   └── text_item.dart          # Text element model
├── providers/
│   └── canvas_state_manager.dart  # State management with undo/redo
├── screens/
│   └── canvas_screen.dart      # Main canvas screen
├── widgets/
│   ├── draggable_text_widget.dart  # Draggable text component
│   └── text_editor_panel.dart  # Text editing panel
└── main.dart                   # App entry point and theme
```

## Architecture

- **State Management**: Provider pattern for reactive state updates
- **History Management**: Stack-based undo/redo implementation
- **Responsive Layout**: MediaQuery-based layout switching
- **Theme**: Material 3 with Google Fonts integration

## Customization

### Adding More Fonts
Edit `lib/widgets/text_editor_panel.dart` and add font names to the `_fontFamilies` list:
```dart
final List<String> _fontFamilies = [
  'Roboto',
  'Your Font Name',
  // ... more fonts
];
```

### Changing Colors
Modify the color palette in `text_editor_panel.dart`:
```dart
[
  Colors.black,
  Colors.yourColor,
  // ... more colors
].map((color) { ... })
```

### Adjusting Canvas Appearance
Edit `GridPainter` in `canvas_screen.dart` to change grid spacing or style.

## Built With

- **Flutter** - UI framework
- **Provider** - State management
- **Google Fonts** - Typography

## Performance Optimizations

- Efficient state updates with ChangeNotifier
- Widget key management for proper rebuilds
- Limited history stack (50 steps) to prevent memory issues
- Optimized custom painter for grid background

## Deployment

### Web
```bash
flutter build web
```

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Desktop
```bash
flutter build macos --release  # macOS
flutter build windows --release  # Windows
flutter build linux --release  # Linux
```

## License

This project is created as an internship assignment.

## Future Enhancements

- Export canvas as image
- Layer management
- Text rotation
- Text alignment options
- Custom font upload
- Collaborative editing
- Templates and presets

