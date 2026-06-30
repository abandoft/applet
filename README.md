# Applet

[Documentation](https://abandoft.github.io/applet) | [中文文档](https://abandoft.github.io/applet/zh)

Applet is a Flutter-based JavaScript hot-update framework.

It lets JavaScript return a Flutter-shaped component tree that the Flutter host
renders as real widgets. Components, properties, functions, themes, and imports
stay close to Flutter while the authoring style feels closer to SwiftUI and
Jetpack Compose.

Applet is not a WebView. It uses a controlled JavaScript runtime to drive
native Flutter UI.

## Highlights

- Native rendering: JavaScript describes UI, Flutter renders real widgets.
- Hot-update friendly: supports assets, source strings, bundles, and import maps.
- Low learning cost: component, property, theme, and event names stay close to Flutter.
- Modern authoring: ES modules, modular files, and local state by default.
- Extensible: hosts can bind business widgets, third-party widgets, and platform capabilities.

## Quick Start

Add the dependency and declare the JavaScript asset:

```yaml
dependencies:
  applet: ^latest

flutter:
  assets:
    - src/
```

The Dart host only needs to return an `Applet` widget:

```dart
import 'package:applet/applet.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    const Applet.asset('src/app.js'),
  );
}
```

`src/app.js`:

```js
import "@app/material";

export default function App() {
  const count = State(0);

  return MaterialApp({
    debugShowCheckedModeBanner: false,
    title: "Applet",
    theme: ThemeData({
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed({ seedColor: "#006a6a" }),
    }),
    home: Scaffold({
      appBar: AppBar({ title: Text("Applet") }),
      body: Center(
        VStack(
          Text("Count: " + count).fontSize(28).bold(),
          FilledButton.icon({
            icon: Icon(Icons.add),
            label: Text("Increment"),
            onPressed: () => count.update((value) => value + 1),
          })
        ).gap(12).min()
      ),
    }),
  });
}
```

For more Applet tutorials and details, see the [documentation](https://abandoft.github.io/applet).
