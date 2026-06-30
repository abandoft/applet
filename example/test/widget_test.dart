import 'dart:io';

import 'package:applet/applet.dart';
import 'package:example/main.dart' as demo;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Material 3 Applet host is constructible', () {
    expect(demo.main, isA<Function>());
    expect(const Applet.asset('src/app.js'), isA<Applet>());
  });

  test('Material 3 Applet uses the native adaptive navigation scaffold', () {
    final source = File('src/app.js').readAsStringSync();

    expect(source, contains('AdaptiveNavigationScaffold'));
    expect(source, contains('narrowWidth: 450'));
    expect(source, contains('largeWidth: 1500'));
    expect(source, contains('navigationBar: MainNavigationBar(model)'));
    expect(source, contains('extendedNavigationRail: MainRail(model, true)'));
  });

  test('Material 3 demo screens use upstream layout primitives', () {
    final color = File('src/screens/color.js').readAsStringSync();
    final typography = File('src/screens/typography.js').readAsStringSync();
    final elevation = File('src/screens/elevation.js').readAsStringSync();
    final components = File('src/screens/components.js').readAsStringSync();

    expect(components, contains('SliverCachedList'));
    expect(components, contains('"Common buttons"'));
    expect(components, contains('"Icon buttons"'));
    expect(color, contains('narrowScreenWidthThreshold = 500'));
    expect(color, contains('SchemePreview("Light ColorScheme"'));
    expect(color, contains('SchemeView(lightScheme)'));
    expect(typography, contains('"displayLarge"'));
    expect(typography, contains('"bodySmall"'));
    expect(typography, contains('style: { theme }'));
    expect(elevation, contains('SliverLayoutBuilder'));
    expect(elevation, contains('maxWidth: narrowScreenWidthThreshold'));
    expect(elevation, contains('crossAxisCount'));
  });
}
