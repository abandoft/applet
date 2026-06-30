# Applet

[Documentation](https://abandoft.github.io/applet) | [中文文档](https://abandoft.github.io/applet/zh)

Applet 是一个基于 Flutter 的 JavaScript 热更新框架。

它让 JavaScript 返回 Flutter 形状的组件树，由 Flutter 宿主
渲染成真实 widget；组件、属性、函数、主题和导入方式尽量贴近 Flutter，
同时提供类似 SwiftUI / Jetpack Compose 的现代化声明式写法。

Applet 不是 WebView，而是用可控的 JS 运行时驱动原生 Flutter UI。

## 项目特色

- 原生渲染：JavaScript 描述 UI，Flutter 渲染真实 widget。
- 热更新友好：支持 asset、源码、bundle 和 import map。
- 低学习成本：组件、属性、主题和事件命名贴近 Flutter。
- 现代写法：默认 ES module，支持模块化和局部状态。
- 可扩展：宿主可以按需绑定业务组件、第三方组件和平台能力。

## 快速开始

添加依赖并声明 JS asset：

```yaml
dependencies:
  applet: ^latest

flutter:
  assets:
    - src/
```

Dart 宿主只需要返回一个 `Applet` widget：

```dart
import 'package:applet/applet.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    const Applet.asset('src/app.js'),
  );
}
```

`src/app.js`：

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

更多Applet的教程和技术细节请[查看文档](https://abandoft.github.io/applet/zh)。
