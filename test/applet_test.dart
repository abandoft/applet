import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:applet/applet.dart';
import 'package:applet/src/applet_bootstrap.dart';
import 'package:applet/src/applet_modules.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/gestures.dart'
    show
        DragStartBehavior,
        PointerDeviceKind,
        PointerDownEvent,
        PointerUpEvent,
        ScaleEndDetails,
        ScaleStartDetails,
        ScaleUpdateDetails,
        Velocity,
        kDefaultMouseScrollToScaleFactor;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent, SelectedContent;
import 'package:flutter/services.dart'
    show
        LogicalKeyboardKey,
        SelectionChangedCause,
        SystemMouseCursors,
        TextSelection;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses action descriptors', () {
    final action = AppletAction.maybeFrom({
      'type': 'Action',
      'props': {
        'name': 'open',
        'payload': {'id': 7},
      },
    });

    expect(action, isNotNull);
    expect(action!.name, 'open');
    expect(action.payload, {'id': 7});
  });

  testWidgets('renders specs and dispatches actions', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'Center',
                'props': {
                  'child': {
                    'type': 'FilledButton',
                    'props': {
                      'label': 'Run',
                      'onPressed': {
                        'type': 'Action',
                        'props': {
                          'name': 'run',
                          'payload': {'source': 'test'},
                        },
                      },
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('Run'), findsOneWidget);
    await tester.tap(find.text('Run'));
    await tester.pump();

    expect(actions, hasLength(1));
    expect(actions.single.name, 'run');
    expect(actions.single.payload, {'source': 'test'});
  });

  testWidgets('opens scaffold drawers and dispatches drawer callbacks', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'appBar': {
                'type': 'AppBar',
                'props': {
                  'title': {
                    'type': 'Text',
                    'props': {'data': 'Drawer shell'},
                  },
                },
              },
              'drawerEnableOpenDragGesture': false,
              'endDrawerEnableOpenDragGesture': false,
              'drawerEdgeDragWidth': 24,
              'onDrawerChanged': {
                'type': 'Action',
                'props': {'name': 'drawerChanged'},
              },
              'drawer': {
                'type': 'Drawer',
                'props': {
                  'child': {
                    'type': 'ListView',
                    'props': {
                      'children': [
                        {
                          'type': 'DrawerHeader',
                          'props': {
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Drawer header'},
                            },
                          },
                        },
                        {
                          'type': 'ListTile',
                          'props': {
                            'title': {
                              'type': 'Text',
                              'props': {'data': 'Inbox'},
                            },
                            'onTap': {
                              'type': 'Action',
                              'props': {'name': 'drawerItem'},
                            },
                          },
                        },
                      ],
                    },
                  },
                },
              },
              'body': {
                'type': 'Center',
                'props': {
                  'child': {
                    'type': 'Text',
                    'props': {'data': 'Body'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.drawerEnableOpenDragGesture, isFalse);
    expect(scaffold.endDrawerEnableOpenDragGesture, isFalse);
    expect(scaffold.drawerEdgeDragWidth, 24);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Drawer header'), findsOneWidget);
    expect(actions.map((action) => action.name), contains('drawerChanged'));
    expect(
      actions.lastWhere((action) => action.name == 'drawerChanged').payload,
      isTrue,
    );

    await tester.tap(find.text('Inbox'));
    await tester.pump();

    expect(actions.last.name, 'drawerItem');
  });

  test('registers Flutter-shaped built-in JS modules', () {
    expect(appletBuiltinModules, contains('@app/material'));
    expect(appletBuiltinModules, contains('@app/cupertino'));
    expect(appletBuiltinModules['@app/material'], contains('MaterialApp'));
    expect(
      appletBuiltinModules['@app/material'],
      contains('export * from "@app/widgets";'),
    );
    expect(
      appletBuiltinModules['@app/material'],
      contains('export * from "@app/layout";'),
    );
    expect(
      appletBuiltinModules['@app/material'],
      contains('ScaffoldMessenger'),
    );
    expect(appletBuiltinModules['@app/material'], contains('Autocomplete'));
    expect(appletBuiltinModules['@app/material'], contains('ButtonStyle'));
    expect(appletBuiltinModules['@app/material'], contains('SearchAnchor'));
    expect(appletBuiltinModules['@app/material'], contains('State'));
    expect(appletBuiltinModules['@app/cupertino'], contains('CupertinoApp'));
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoAlertDialog'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoSegmentedControl'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoSearchTextField'),
    );
    final moduleGlobals = appletBuiltinModules.values
        .expand(
          (source) => RegExp(
            r'globalThis\.([A-Za-z_]\w*)',
          ).allMatches(source).map((match) => match.group(1)!),
        )
        .toSet();
    final missingBootstrapSymbols = moduleGlobals.where((symbol) {
      if (symbol == 'Applet') {
        return !appletBootstrapScript.contains('globalThis.Applet = Applet');
      }
      return !appletBootstrapScript.contains('define("$symbol"');
    }).toList()..sort();
    expect(missingBootstrapSymbols, isEmpty);
    expect(appletBuiltinModules, contains('@applet/material'));
    expect(appletBuiltinModules, contains('@applet/cupertino'));
  });

  test('material adaptive JS factories are exposed by bootstrap', () {
    for (final type in const [
      'Switch',
      'SwitchListTile',
      'Checkbox',
      'CheckboxListTile',
      'Radio',
      'RadioListTile',
      'Slider',
      'CircularProgressIndicator',
      'AlertDialog',
    ]) {
      expect(
        appletBootstrapScript,
        contains('define("$type", adaptiveNode("$type"))'),
        reason: type,
      );
    }
    expect(
      appletBootstrapScript,
      contains(
        'define("RefreshIndicator", adaptiveChildNode("RefreshIndicator"))',
      ),
    );
    expect(appletBootstrapScript, contains('factory.adaptive'));
  });

  test('node JS factories merge injected constructor props', () {
    expect(
      appletBootstrapScript,
      contains('return node(type, { ...first, ...second });'),
    );
    expect(
      appletBootstrapScript,
      contains(
        'if (isPlainObject(first)) {\n      return node(type, { ...first, ...second });\n    }',
      ),
    );
    expect(
      appletBootstrapScript,
      contains(
        'filledButton.tonal = (first = {}, second = {}) => childNode("FilledButton", first, { ...second, tonal: true })',
      ),
    );
    expect(
      appletBootstrapScript,
      contains(
        'card.filled = (first = {}, second = {}) => childNode("Card", first, { ...second, variant: "filled" })',
      ),
    );
    expect(
      appletBootstrapScript,
      contains(
        'card.outlined = (first = {}, second = {}) => childNode("Card", first, { ...second, variant: "outlined" })',
      ),
    );
    expect(
      appletBootstrapScript,
      contains(
        'floatingActionButton.small = (first = {}, second = {}) => childNode("FloatingActionButton", first, { ...second, variant: "small" })',
      ),
    );
    expect(
      appletBootstrapScript,
      contains(
        'dialog.fullscreen = (first = {}, second = {}) => childNode("Dialog", first, { ...second, fullscreen: true })',
      ),
    );
    expect(
      appletBootstrapScript,
      contains(
        'childrenNode("ExpansionPanelListRadio", first, { ...second, radio: true })',
      ),
    );
    expect(
      appletBootstrapScript,
      contains('badge.count = (first = {}, second = {}) => {'),
    );
    expect(appletBootstrapScript, contains('define("Badge", badge)'));
  });

  testWidgets('dispatches card taps', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Card',
            'props': {
              'onTap': {
                'type': 'Action',
                'props': {'name': 'openDemo', 'payload': 'buttons'},
              },
              'child': {
                'type': 'Padding',
                'props': {
                  'padding': {'all': 16},
                  'child': {
                    'type': 'Text',
                    'props': {'data': 'Buttons'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    await tester.tap(find.text('Buttons'));
    await tester.pump();

    expect(actions.single.name, 'openDemo');
    expect(actions.single.payload, 'buttons');
  });

  testWidgets('resolves current theme color tokens in widget styles', (
    tester,
  ) async {
    final renderer = AppletRenderer();
    late Color expectedSurface;
    late Color expectedOutline;
    late Color expectedOnSurfaceVariant;
    late Color expectedPrimary;
    late Color expectedPrimaryContainer;
    late Color expectedOnPrimaryContainer;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: Builder(
          builder: (context) {
            final scheme = Theme.of(context).colorScheme;
            expectedSurface = scheme.surfaceContainerHighest.withAlpha(77);
            expectedOutline = scheme.outlineVariant;
            expectedOnSurfaceVariant = scheme.onSurfaceVariant;
            expectedPrimary = scheme.primary;
            expectedPrimaryContainer = scheme.primaryContainer;
            expectedOnPrimaryContainer = scheme.onPrimaryContainer;
            return Center(
              child: renderer.buildWidget(context, {
                'type': 'Column',
                'props': {
                  'mainAxisSize': 'min',
                  'children': [
                    {
                      'type': 'Container',
                      'props': {
                        'decoration': {
                          'color': {
                            'theme': 'surfaceContainerHighest',
                            'alpha': 77,
                          },
                          'border': {
                            'color': {'theme': 'outlineVariant'},
                            'width': 2,
                          },
                          'borderRadius': 12,
                        },
                        'padding': {'all': 8},
                        'child': {
                          'type': 'Text',
                          'props': {
                            'data': 'Theme token',
                            'style': {
                              'theme': 'bodyMedium',
                              'color': {'theme': 'onSurfaceVariant'},
                            },
                          },
                        },
                      },
                    },
                    {
                      'type': 'Icon',
                      'props': {
                        'icon': 'info',
                        'color': {'theme': 'primary'},
                      },
                    },
                    {
                      'type': 'FilledButton',
                      'props': {
                        'label': 'Token button',
                        'style': {
                          'backgroundColor': {'theme': 'primaryContainer'},
                          'foregroundColor': {'theme': 'onPrimaryContainer'},
                          'side': {
                            'color': {'theme': 'outlineVariant'},
                            'width': 2,
                          },
                        },
                      },
                    },
                  ],
                },
              }),
            );
          },
        ),
      ),
    );

    final decoratedContainer = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Theme token'),
            matching: find.byType(Container),
          )
          .last,
    );
    final decoration = decoratedContainer.decoration as BoxDecoration;
    expect(decoration.color, expectedSurface);
    expect((decoration.border as Border).top.color, expectedOutline);
    expect((decoration.border as Border).top.width, 2);

    final text = tester.widget<Text>(find.text('Theme token'));
    expect(text.style?.color, expectedOnSurfaceVariant);
    final icon = tester.widget<Icon>(find.byIcon(Icons.info));
    expect(icon.color, expectedPrimary);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      expectedPrimaryContainer,
    );
    expect(
      button.style?.foregroundColor?.resolve(<WidgetState>{}),
      expectedOnPrimaryContainer,
    );
    expect(
      button.style?.side?.resolve(<WidgetState>{})?.color,
      expectedOutline,
    );
  });

  testWidgets('maps rich material shell and surface props safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );
    const png =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

    Future<T> pumpSpec<T extends Widget>(Map<String, Object?> spec) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) =>
                Center(child: renderer.buildWidget(context, spec)),
          ),
        ),
      );
      await tester.pump();
      return tester.widget<T>(find.byType(T).first);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'backgroundColor': '#fff8e1',
              'extendBody': true,
              'drawerEdgeDragWidth': 28,
              'drawerEnableOpenDragGesture': false,
              'appBar': {
                'type': 'AppBar',
                'props': {
                  'title': {
                    'type': 'Text',
                    'props': {'data': 'Shell'},
                  },
                  'backgroundColor': '#006a6a',
                  'foregroundColor': '#ffffff',
                  'elevation': -4,
                  'scrolledUnderElevation': -2,
                  'toolbarOpacity': 1.4,
                  'bottomOpacity': -0.5,
                  'toolbarHeight': -8,
                  'leadingWidth': -12,
                  'actionsPadding': {'horizontal': 6},
                  'animateColor': true,
                },
              },
              'body': {
                'type': 'Text',
                'props': {'data': 'Body'},
              },
            },
          }),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xfffff8e1));
    expect(scaffold.extendBody, isTrue);
    expect(scaffold.drawerEdgeDragWidth, 28);
    expect(scaffold.drawerEnableOpenDragGesture, isFalse);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, const Color(0xff006a6a));
    expect(appBar.foregroundColor, const Color(0xffffffff));
    expect(appBar.elevation, 0);
    expect(appBar.scrolledUnderElevation, 0);
    expect(appBar.toolbarOpacity, 1);
    expect(appBar.bottomOpacity, 0);
    expect(appBar.toolbarHeight, 0);
    expect(appBar.leadingWidth, 0);
    expect(appBar.actionsPadding, const EdgeInsets.symmetric(horizontal: 6));
    expect(appBar.animateColor, isTrue);

    final card = await pumpSpec<Card>({
      'type': 'Card',
      'props': {
        'variant': 'outlined',
        'color': '#fafafa',
        'shadowColor': '#111111',
        'surfaceTintColor': '#222222',
        'elevation': -6,
        'outlineColor': '#123456',
        'outlineWidth': 2,
        'borderRadius': 14,
        'borderOnForeground': false,
        'semanticContainer': false,
        'margin': {'all': 7},
        'clipBehavior': 'antiAlias',
        'child': {
          'type': 'Text',
          'props': {'data': 'Card body'},
        },
      },
    });
    expect(card.color, const Color(0xfffafafa));
    expect(card.shadowColor, const Color(0xff111111));
    expect(card.surfaceTintColor, const Color(0xff222222));
    expect(card.elevation, 0);
    expect(card.margin, const EdgeInsets.all(7));
    expect(card.clipBehavior, Clip.antiAlias);
    expect(card.borderOnForeground, isFalse);
    expect(card.semanticContainer, isFalse);
    final cardShape = card.shape as RoundedRectangleBorder;
    expect(cardShape.borderRadius, BorderRadius.circular(14));
    expect(cardShape.side.color, const Color(0xff123456));
    expect(cardShape.side.width, 2);

    final material = await pumpSpec<Material>({
      'type': 'Material',
      'props': {
        'materialType': 'circle',
        'color': '#eeeeee',
        'shadowColor': '#010101',
        'surfaceTintColor': '#020202',
        'textStyle': {'fontSize': 17, 'color': '#030303'},
        'elevation': -3,
        'borderRadius': 24,
        'shape': {'borderRadius': 8},
        'borderOnForeground': false,
        'clipBehavior': 'antiAlias',
        'animationDuration': {'milliseconds': 120},
        'animateColor': true,
        'child': {
          'type': 'Text',
          'props': {'data': 'Material body'},
        },
      },
    });
    expect(material.type, MaterialType.circle);
    expect(material.color, const Color(0xffeeeeee));
    expect(material.shadowColor, const Color(0xff010101));
    expect(material.surfaceTintColor, const Color(0xff020202));
    expect(material.textStyle?.fontSize, 17);
    expect(material.textStyle?.color, const Color(0xff030303));
    expect(material.elevation, 0);
    expect(material.borderRadius, isNull);
    expect(material.shape, isNull);
    expect(material.borderOnForeground, isFalse);
    expect(material.clipBehavior, Clip.antiAlias);
    expect(material.animationDuration, const Duration(milliseconds: 120));
    expect(material.animateColor, isTrue);

    await pumpSpec<Material>({
      'type': 'Material',
      'props': {
        'child': {
          'type': 'InkWell',
          'props': {
            'onTap': {
              'type': 'Action',
              'props': {'name': 'inkTap'},
            },
            'onTapDown': {
              'type': 'Action',
              'props': {'name': 'inkTapDown'},
            },
            'onTapUp': {
              'type': 'Action',
              'props': {'name': 'inkTapUp'},
            },
            'onSecondaryTapDown': {
              'type': 'Action',
              'props': {'name': 'inkSecondaryTapDown'},
            },
            'onSecondaryTapUp': {
              'type': 'Action',
              'props': {'name': 'inkSecondaryTapUp'},
            },
            'onHighlightChanged': {
              'type': 'Action',
              'props': {'name': 'inkHighlight'},
            },
            'onHover': {
              'type': 'Action',
              'props': {'name': 'inkHover'},
            },
            'onFocusChange': {
              'type': 'Action',
              'props': {'name': 'inkFocus'},
            },
            'mouseCursor': 'click',
            'focusColor': '#010203',
            'hoverColor': '#040506',
            'highlightColor': '#070809',
            'overlayColor': {'pressed': '#111111', 'default': '#222222'},
            'splashColor': '#333333',
            'radius': -6,
            'borderRadius': 12,
            'customBorder': 'stadium',
            'enableFeedback': false,
            'excludeFromSemantics': true,
            'canRequestFocus': false,
            'autofocus': true,
            'hoverDuration': -50,
            'child': {
              'type': 'Text',
              'props': {'data': 'Ink target'},
            },
          },
        },
      },
    });
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.mouseCursor, SystemMouseCursors.click);
    expect(inkWell.focusColor, const Color(0xff010203));
    expect(inkWell.hoverColor, const Color(0xff040506));
    expect(inkWell.highlightColor, const Color(0xff070809));
    expect(
      inkWell.overlayColor?.resolve({WidgetState.pressed}),
      const Color(0xff111111),
    );
    expect(inkWell.splashColor, const Color(0xff333333));
    expect(inkWell.radius, 0);
    expect(inkWell.borderRadius, BorderRadius.circular(12));
    expect(inkWell.customBorder, isA<StadiumBorder>());
    expect(inkWell.enableFeedback, isFalse);
    expect(inkWell.excludeFromSemantics, isTrue);
    expect(inkWell.canRequestFocus, isFalse);
    expect(inkWell.autofocus, isTrue);
    expect(inkWell.hoverDuration, Duration.zero);

    inkWell.onTap!();
    inkWell.onTapDown!(
      TapDownDetails(
        globalPosition: const Offset(10, 20),
        localPosition: const Offset(1, 2),
        kind: PointerDeviceKind.touch,
      ),
    );
    inkWell.onTapUp!(
      TapUpDetails(
        globalPosition: const Offset(30, 40),
        localPosition: const Offset(3, 4),
        kind: PointerDeviceKind.mouse,
      ),
    );
    inkWell.onSecondaryTapDown!(
      TapDownDetails(
        globalPosition: const Offset(50, 60),
        localPosition: const Offset(5, 6),
        kind: PointerDeviceKind.mouse,
      ),
    );
    inkWell.onSecondaryTapUp!(
      TapUpDetails(
        globalPosition: const Offset(70, 80),
        localPosition: const Offset(7, 8),
        kind: PointerDeviceKind.mouse,
      ),
    );
    inkWell.onHighlightChanged!(true);
    inkWell.onHover!(false);
    inkWell.onFocusChange!(true);
    expect(actions.map((action) => action.name), [
      'inkTap',
      'inkTapDown',
      'inkTapUp',
      'inkSecondaryTapDown',
      'inkSecondaryTapUp',
      'inkHighlight',
      'inkHover',
      'inkFocus',
    ]);
    expect(actions[1].payload, {
      'x': 10.0,
      'y': 20.0,
      'localX': 1.0,
      'localY': 2.0,
      'kind': 'touch',
    });
    expect(actions[2].payload, {
      'x': 30.0,
      'y': 40.0,
      'localX': 3.0,
      'localY': 4.0,
      'kind': 'mouse',
    });
    actions.clear();

    final avatar = await pumpSpec<CircleAvatar>({
      'type': 'CircleAvatar',
      'props': {
        'radius': -10,
        'minRadius': 16,
        'maxRadius': 8,
        'backgroundColor': '#eeeeee',
        'foregroundColor': '#111111',
        'backgroundImage': {'base64': png, 'cacheWidth': 8, 'cacheHeight': 8},
        'foregroundImage': {'base64': png},
        'onBackgroundImageError': {
          'type': 'Action',
          'props': {'name': 'avatarBackgroundError'},
        },
        'onForegroundImageError': {
          'type': 'Action',
          'props': {'name': 'avatarForegroundError'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'AB'},
        },
      },
    });
    expect(avatar.radius, 0);
    expect(avatar.minRadius, isNull);
    expect(avatar.maxRadius, isNull);
    expect(avatar.backgroundColor, const Color(0xffeeeeee));
    expect(avatar.foregroundColor, const Color(0xff111111));
    expect(avatar.backgroundImage, isA<ResizeImage>());
    expect(avatar.foregroundImage, isA<MemoryImage>());
    expect(avatar.onBackgroundImageError, isNotNull);
    expect(avatar.onForegroundImageError, isNotNull);
    avatar.onBackgroundImageError!(Exception('background failed'), null);
    avatar.onForegroundImageError!(Exception('foreground failed'), null);
    expect(actions.map((action) => action.name), [
      'avatarBackgroundError',
      'avatarForegroundError',
    ]);
    expect(actions[0].payload, {
      'source': 'background',
      'error': 'Exception: background failed',
    });
    expect(actions[1].payload, {
      'source': 'foreground',
      'error': 'Exception: foreground failed',
    });

    final constrainedAvatar = await pumpSpec<CircleAvatar>({
      'type': 'CircleAvatar',
      'props': {
        'minRadius': 24,
        'maxRadius': 12,
        'onImageError': {
          'type': 'Action',
          'props': {'name': 'unusedAvatarImageError'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'CD'},
        },
      },
    });
    expect(constrainedAvatar.radius, isNull);
    expect(constrainedAvatar.minRadius, 24);
    expect(constrainedAvatar.maxRadius, 24);
    expect(constrainedAvatar.backgroundImage, isNull);
    expect(constrainedAvatar.foregroundImage, isNull);
    expect(constrainedAvatar.onBackgroundImageError, isNull);
    expect(constrainedAvatar.onForegroundImageError, isNull);

    final badge = await pumpSpec<Badge>({
      'type': 'Badge',
      'props': {
        'label': {
          'type': 'Text',
          'props': {'data': '9'},
        },
        'backgroundColor': '#ff0000',
        'textColor': '#ffffff',
        'smallSize': -8,
        'largeSize': 18,
        'textStyle': {'fontSize': 11},
        'padding': {'horizontal': 5, 'vertical': 2},
        'alignment': 'topRight',
        'offset': {'x': 3, 'y': 4},
        'child': {
          'type': 'Text',
          'props': {'data': 'Inbox'},
        },
      },
    });
    expect(badge.backgroundColor, const Color(0xffff0000));
    expect(badge.textColor, const Color(0xffffffff));
    expect(badge.smallSize, 0);
    expect(badge.largeSize, 18);
    expect(badge.textStyle?.fontSize, 11);
    expect(
      badge.padding,
      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    );
    expect(badge.alignment, Alignment.topRight);
    expect(badge.offset, const Offset(3, 4));

    final countBadge = await pumpSpec<Badge>({
      'type': 'Badge',
      'props': {
        'count': 120,
        'maxCount': 12,
        'isLabelVisible': false,
        'backgroundColor': '#006a6a',
        'textColor': '#ffffff',
        'child': {
          'type': 'Text',
          'props': {'data': 'Notifications'},
        },
      },
    });
    expect((countBadge.label as Text).data, '12+');
    expect(countBadge.isLabelVisible, isFalse);
    expect(countBadge.backgroundColor, const Color(0xff006a6a));
    expect(countBadge.textColor, const Color(0xffffffff));

    await pumpSpec<Banner>({
      'type': 'Banner',
      'props': {
        'message': 'Preview',
        'location': 'bottomStart',
        'textDirection': 'rtl',
        'layoutDirection': 'rtl',
        'color': '#aabbcc',
        'textStyle': {'fontSize': 13, 'fontWeight': 'w700'},
        'shadow': {
          'color': '#44000000',
          'offset': [2, 3],
          'blurRadius': 4,
          'spreadRadius': 1,
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'Banner child'},
        },
      },
    });
    final ribbon = tester.widget<Banner>(
      find.byWidgetPredicate(
        (widget) => widget is Banner && widget.message == 'Preview',
      ),
    );
    expect(ribbon.message, 'Preview');
    expect(ribbon.location, BannerLocation.bottomStart);
    expect(ribbon.textDirection, TextDirection.rtl);
    expect(ribbon.layoutDirection, TextDirection.rtl);
    expect(ribbon.color, const Color(0xffaabbcc));
    expect(ribbon.textStyle.fontSize, 13);
    expect(ribbon.textStyle.fontWeight, FontWeight.w700);
    expect(ribbon.shadow.color, const Color(0x44000000));
    expect(ribbon.shadow.offset, const Offset(2, 3));
    expect(ribbon.shadow.blurRadius, 4);
    expect(ribbon.shadow.spreadRadius, 1);

    final banner = await pumpSpec<MaterialBanner>({
      'type': 'MaterialBanner',
      'props': {
        'content': {
          'type': 'Text',
          'props': {'data': 'Connectivity lost'},
        },
        'contentTextStyle': {'fontSize': 15},
        'leading': {
          'type': 'Icon',
          'props': {'icon': 'info'},
        },
        'backgroundColor': '#fff8e1',
        'surfaceTintColor': '#ffee58',
        'shadowColor': '#222222',
        'dividerColor': '#333333',
        'elevation': -7,
        'padding': {'all': 12},
        'margin': {'horizontal': 4},
        'leadingPadding': {'right': 10},
        'forceActionsBelow': true,
        'overflowAlignment': 'center',
        'minActionBarHeight': -5,
        'actions': [
          {
            'type': 'TextButton',
            'props': {'label': 'Retry'},
          },
        ],
      },
    });
    expect(banner.contentTextStyle?.fontSize, 15);
    expect(banner.backgroundColor, const Color(0xfffff8e1));
    expect(banner.surfaceTintColor, const Color(0xffffee58));
    expect(banner.shadowColor, const Color(0xff222222));
    expect(banner.dividerColor, const Color(0xff333333));
    expect(banner.elevation, 0);
    expect(banner.padding, const EdgeInsets.all(12));
    expect(banner.margin, const EdgeInsets.symmetric(horizontal: 4));
    expect(banner.leadingPadding, const EdgeInsets.only(right: 10));
    expect(banner.forceActionsBelow, isTrue);
    expect(banner.overflowAlignment, OverflowBarAlignment.center);
    expect(banner.minActionBarHeight, 0);
    expect(banner.actions, hasLength(1));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'MaterialBanner',
            'props': {
              'content': {
                'type': 'Text',
                'props': {'data': 'No actions'},
              },
              'actions': <Object?>[],
            },
          }),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialBanner), findsNothing);

    final drawer = await pumpSpec<Drawer>({
      'type': 'Drawer',
      'props': {
        'backgroundColor': '#fafafa',
        'elevation': -9,
        'shadowColor': '#111111',
        'surfaceTintColor': '#222222',
        'shape': {'borderRadius': 20},
        'width': -10,
        'clipBehavior': 'antiAlias',
        'semanticLabel': 'Navigation drawer',
        'child': {
          'type': 'Text',
          'props': {'data': 'Drawer body'},
        },
      },
    });
    expect(drawer.backgroundColor, const Color(0xfffafafa));
    expect(drawer.elevation, 0);
    expect(drawer.shadowColor, const Color(0xff111111));
    expect(drawer.surfaceTintColor, const Color(0xff222222));
    expect(drawer.shape, isA<RoundedRectangleBorder>());
    expect(drawer.width, isNull);
    expect(drawer.clipBehavior, Clip.antiAlias);
    expect(drawer.semanticLabel, 'Navigation drawer');

    final divider = await pumpSpec<Divider>({
      'type': 'Divider',
      'props': {
        'height': -4,
        'thickness': -1,
        'indent': -2,
        'endIndent': -3,
        'color': '#444444',
        'radius': 3,
      },
    });
    expect(divider.height, 0);
    expect(divider.thickness, 0);
    expect(divider.indent, 0);
    expect(divider.endIndent, 0);
    expect(divider.color, const Color(0xff444444));
    expect(divider.radius, isNull);

    final verticalDivider = await pumpSpec<VerticalDivider>({
      'type': 'VerticalDivider',
      'props': {
        'width': -4,
        'thickness': -1,
        'indent': -2,
        'endIndent': -3,
        'color': '#555555',
        'radius': 4,
      },
    });
    expect(verticalDivider.width, 0);
    expect(verticalDivider.thickness, 0);
    expect(verticalDivider.indent, 0);
    expect(verticalDivider.endIndent, 0);
    expect(verticalDivider.color, const Color(0xff555555));
    expect(verticalDivider.radius, isNull);
  });

  testWidgets('dispatches pointer, hover, and dismiss interactions', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    var showDismissible = true;
    late StateSetter hostSetState;
    late final AppletRenderer renderer;
    renderer = AppletRenderer(
      dispatchAction: (action) {
        actions.add(action);
        if (action.name == 'dismissed') {
          hostSetState(() => showDismissible = false);
        }
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            hostSetState = setState;
            return renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'Listener',
                    'props': {
                      'behavior': 'opaque',
                      'onPointerDown': {
                        'type': 'Action',
                        'props': {'name': 'pointerDown'},
                      },
                      'onPointerUp': {
                        'type': 'Action',
                        'props': {'name': 'pointerUp'},
                      },
                      'child': {
                        'type': 'SizedBox',
                        'props': {
                          'width': 180,
                          'height': 48,
                          'child': {
                            'type': 'Center',
                            'props': {
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'Tap area'},
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                  {
                    'type': 'MouseRegion',
                    'props': {
                      'onEnter': {
                        'type': 'Action',
                        'props': {'name': 'hoverEnter'},
                      },
                      'onExit': {
                        'type': 'Action',
                        'props': {'name': 'hoverExit'},
                      },
                      'child': {
                        'type': 'SizedBox',
                        'props': {
                          'width': 180,
                          'height': 48,
                          'child': {
                            'type': 'Center',
                            'props': {
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'Hover me'},
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                  if (showDismissible)
                    {
                      'type': 'Dismissible',
                      'props': {
                        'key': 'row-1',
                        'direction': 'startToEnd',
                        'movementDuration': 1,
                        'onDismissed': {
                          'type': 'Action',
                          'props': {'name': 'dismissed'},
                        },
                        'child': {
                          'type': 'SizedBox',
                          'props': {
                            'width': 240,
                            'height': 56,
                            'child': {
                              'type': 'Center',
                              'props': {
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Swipe me'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                ],
              },
            });
          },
        ),
      ),
    );

    await tester.tap(find.text('Tap area'));
    await tester.pump();

    final pointerDown = actions.firstWhere(
      (action) => action.name == 'pointerDown',
    );
    expect(pointerDown.payload, isA<Map>());
    expect((pointerDown.payload as Map)['kind'], isNotEmpty);
    expect(actions.map((action) => action.name), contains('pointerUp'));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(500, 500));
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Hover me')));
    await tester.pump();
    await gesture.moveTo(const Offset(500, 500));
    await tester.pump();

    expect(actions.map((action) => action.name), contains('hoverEnter'));
    expect(actions.map((action) => action.name), contains('hoverExit'));

    await tester.drag(find.text('Swipe me'), const Offset(500, 0));
    await tester.pumpAndSettle();

    final dismissed = actions.firstWhere(
      (action) => action.name == 'dismissed',
    );
    expect(dismissed.payload, 'startToEnd');
    expect(find.text('Swipe me'), findsNothing);
  });

  testWidgets('maps interactive viewer props and interaction payloads safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'InteractiveViewer',
            'props': {
              'panAxis': 'vertical',
              'boundaryMargin': {
                'left': double.infinity,
                'top': 8,
                'right': 8,
                'bottom': 8,
              },
              'minScale': -1,
              'maxScale': 0.4,
              'interactionEndFrictionCoefficient': double.nan,
              'scaleFactor': double.infinity,
              'panEnabled': false,
              'scaleEnabled': true,
              'trackpadScrollCausesScale': true,
              'onInteractionStart': {
                'type': 'Action',
                'props': {'name': 'start'},
              },
              'onInteractionUpdate': {
                'type': 'Action',
                'props': {'name': 'update'},
              },
              'onInteractionEnd': {
                'type': 'Action',
                'props': {'name': 'end'},
              },
              'child': {
                'type': 'SizedBox',
                'props': {
                  'width': 120,
                  'height': 80,
                  'child': {
                    'type': 'Text',
                    'props': {'data': 'Zoomable'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.panAxis, PanAxis.vertical);
    expect(viewer.boundaryMargin, EdgeInsets.zero);
    expect(viewer.minScale, 0.8);
    expect(viewer.maxScale, 0.8);
    expect(viewer.interactionEndFrictionCoefficient, 0.0000135);
    expect(viewer.scaleFactor, kDefaultMouseScrollToScaleFactor);
    expect(viewer.panEnabled, isFalse);
    expect(viewer.scaleEnabled, isTrue);
    expect(viewer.trackpadScrollCausesScale, isTrue);

    viewer.onInteractionStart!(
      ScaleStartDetails(
        focalPoint: const Offset(10, 20),
        localFocalPoint: const Offset(3, 4),
        pointerCount: 2,
      ),
    );
    viewer.onInteractionUpdate!(
      ScaleUpdateDetails(
        focalPoint: const Offset(11, 21),
        localFocalPoint: const Offset(5, 6),
        scale: 1.25,
        horizontalScale: 1.5,
        verticalScale: 1.1,
        rotation: 0.3,
        pointerCount: 2,
      ),
    );
    viewer.onInteractionEnd!(
      ScaleEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(7, 8)),
        scaleVelocity: 1.2,
        pointerCount: 0,
      ),
    );

    expect(actions.map((action) => action.name), ['start', 'update', 'end']);
    expect(actions[0].payload, {
      'x': 10.0,
      'y': 20.0,
      'localX': 3.0,
      'localY': 4.0,
      'pointerCount': 2,
    });
    expect((actions[1].payload as Map)['scale'], 1.25);
    expect((actions[1].payload as Map)['horizontalScale'], 1.5);
    expect((actions[1].payload as Map)['verticalScale'], 1.1);
    expect((actions[1].payload as Map)['rotation'], 0.3);
    expect(actions[2].payload, {
      'velocityX': 7.0,
      'velocityY': 8.0,
      'scaleVelocity': 1.2,
      'pointerCount': 0,
    });
  });

  testWidgets('dispatches draggable and drag target interactions', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Column',
            'props': {
              'children': [
                {
                  'type': 'Draggable',
                  'props': {
                    'data': 'card-1',
                    'onDragStarted': {
                      'type': 'Action',
                      'props': {'name': 'dragStarted'},
                    },
                    'onDragUpdate': {
                      'type': 'Action',
                      'props': {'name': 'dragUpdate'},
                    },
                    'onDragEnd': {
                      'type': 'Action',
                      'props': {'name': 'dragEnd'},
                    },
                    'onDragCompleted': {
                      'type': 'Action',
                      'props': {'name': 'dragCompleted'},
                    },
                    'feedback': {
                      'type': 'Material',
                      'props': {
                        'child': {
                          'type': 'Text',
                          'props': {'data': 'Dragging item'},
                        },
                      },
                    },
                    'child': {
                      'type': 'SizedBox',
                      'props': {
                        'width': 180,
                        'height': 56,
                        'child': {
                          'type': 'Center',
                          'props': {
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Drag item'},
                            },
                          },
                        },
                      },
                    },
                  },
                },
                {
                  'type': 'LongPressDraggable',
                  'props': {
                    'data': 'long-card',
                    'feedback': {
                      'type': 'Text',
                      'props': {'data': 'Long feedback'},
                    },
                    'child': {
                      'type': 'Text',
                      'props': {'data': 'Long drag item'},
                    },
                  },
                },
                {
                  'type': 'DragTarget',
                  'props': {
                    'accepts': ['card-1'],
                    'onWillAccept': {
                      'type': 'Action',
                      'props': {'name': 'willAccept'},
                    },
                    'onMove': {
                      'type': 'Action',
                      'props': {'name': 'dragMove'},
                    },
                    'onAcceptWithDetails': {
                      'type': 'Action',
                      'props': {'name': 'accepted'},
                    },
                    'child': {
                      'type': 'SizedBox',
                      'props': {
                        'width': 220,
                        'height': 96,
                        'child': {
                          'type': 'Center',
                          'props': {
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Drop zone'},
                            },
                          },
                        },
                      },
                    },
                    'activeChild': {
                      'type': 'SizedBox',
                      'props': {
                        'width': 220,
                        'height': 96,
                        'child': {
                          'type': 'Center',
                          'props': {
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Drop now'},
                            },
                          },
                        },
                      },
                    },
                  },
                },
              ],
            },
          }),
        ),
      ),
    );

    expect(find.text('Long drag item'), findsOneWidget);

    final start = tester.getCenter(find.text('Drag item'));
    final end = tester.getCenter(find.text('Drop zone'));
    await tester.dragFrom(start, end - start);
    await tester.pumpAndSettle();

    final names = actions.map((action) => action.name).toList();
    expect(names, contains('dragStarted'));
    expect(names, contains('dragUpdate'));
    expect(names, contains('willAccept'));
    expect(names, contains('dragMove'));
    expect(names, contains('accepted'));
    expect(names, contains('dragCompleted'));
    expect(names, contains('dragEnd'));

    final accepted = actions.firstWhere((action) => action.name == 'accepted');
    expect((accepted.payload as Map)['data'], 'card-1');
    expect((accepted.payload as Map)['x'], isA<double>());

    final dragEnd = actions.firstWhere((action) => action.name == 'dragEnd');
    expect((dragEnd.payload as Map)['wasAccepted'], true);
  });

  testWidgets('maps pointer, drag, dismiss, and tap region props safely', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    Future<void> pumpSpec(Map<String, Object?> spec) {
      return tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => renderer.buildWidget(context, spec),
          ),
        ),
      );
    }

    await pumpSpec({
      'type': 'Listener',
      'props': {
        'behavior': 'translucent',
        'child': {
          'type': 'Text',
          'props': {'data': 'listener props'},
        },
      },
    });
    expect(
      tester
          .widget<Listener>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Listener &&
                  widget.behavior == HitTestBehavior.translucent,
            ),
          )
          .behavior,
      HitTestBehavior.translucent,
    );

    await pumpSpec({
      'type': 'MouseRegion',
      'props': {
        'opaque': false,
        'hitTestBehavior': 'opaque',
        'child': {
          'type': 'Text',
          'props': {'data': 'mouse props'},
        },
      },
    });
    final mouseRegion = tester.widget<MouseRegion>(
      find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion &&
            widget.opaque == false &&
            widget.hitTestBehavior == HitTestBehavior.opaque,
      ),
    );
    expect(mouseRegion.opaque, isFalse);
    expect(mouseRegion.hitTestBehavior, HitTestBehavior.opaque);

    await pumpSpec({
      'type': 'Dismissible',
      'props': {
        'key': 'dismiss-props',
        'direction': 'up',
        'resizeDuration': -12,
        'movementDuration': -20,
        'crossAxisEndOffset': 0.25,
        'behavior': 'translucent',
        'background': {
          'type': 'Text',
          'props': {'data': 'dismiss background'},
        },
        'secondaryBackground': {
          'type': 'Text',
          'props': {'data': 'dismiss secondary'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'dismiss props'},
        },
      },
    });
    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.direction, DismissDirection.up);
    expect(dismissible.resizeDuration, Duration.zero);
    expect(dismissible.movementDuration, Duration.zero);
    expect(dismissible.crossAxisEndOffset, .25);
    expect(dismissible.behavior, HitTestBehavior.translucent);
    expect(dismissible.background, isNotNull);
    expect(dismissible.secondaryBackground, isNotNull);

    await pumpSpec({
      'type': 'Draggable',
      'props': {
        'data': 'drag-props',
        'axis': 'horizontal',
        'feedbackOffset': {'dx': 4, 'dy': 5},
        'maxSimultaneousDrags': -3,
        'ignoringFeedbackSemantics': false,
        'ignoringFeedbackPointer': false,
        'rootOverlay': true,
        'hitTestBehavior': 'opaque',
        'feedback': {
          'type': 'Text',
          'props': {'data': 'drag feedback'},
        },
        'childWhenDragging': {
          'type': 'Text',
          'props': {'data': 'drag placeholder'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'drag props'},
        },
      },
    });
    final draggable = tester.widget<Draggable<Object>>(
      find.byType(Draggable<Object>),
    );
    expect(draggable.data, 'drag-props');
    expect(draggable.axis, Axis.horizontal);
    expect(draggable.feedbackOffset, const Offset(4, 5));
    expect(draggable.maxSimultaneousDrags, 0);
    expect(draggable.ignoringFeedbackSemantics, isFalse);
    expect(draggable.ignoringFeedbackPointer, isFalse);
    expect(draggable.rootOverlay, isTrue);
    expect(draggable.hitTestBehavior, HitTestBehavior.opaque);
    expect(draggable.childWhenDragging, isNotNull);

    await pumpSpec({
      'type': 'LongPressDraggable',
      'props': {
        'delay': -30,
        'hapticFeedbackOnStart': false,
        'feedback': {
          'type': 'Text',
          'props': {'data': 'long feedback'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'long props'},
        },
      },
    });
    final longPress = tester.widget<LongPressDraggable<Object>>(
      find.byType(LongPressDraggable<Object>),
    );
    expect(longPress.delay, Duration.zero);
    expect(longPress.hapticFeedbackOnStart, isFalse);

    await pumpSpec({
      'type': 'DragTarget',
      'props': {
        'accepts': ['accepted'],
        'hitTestBehavior': 'opaque',
        'activeChild': {
          'type': 'Text',
          'props': {'data': 'active target'},
        },
        'rejectedChild': {
          'type': 'Text',
          'props': {'data': 'rejected target'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'drag target props'},
        },
      },
    });
    final dragTarget = tester.widget<DragTarget<Object>>(
      find.byType(DragTarget<Object>),
    );
    expect(dragTarget.hitTestBehavior, HitTestBehavior.opaque);

    await pumpSpec({
      'type': 'TapRegion',
      'props': {
        'enabled': false,
        'behavior': 'opaque',
        'groupId': 'tap-group',
        'consumeOutsideTaps': true,
        'debugLabel': 'tap-region-props',
        'child': {
          'type': 'Text',
          'props': {'data': 'tap props'},
        },
      },
    });
    final tapRegion = tester.widget<TapRegion>(find.byType(TapRegion));
    expect(tapRegion.enabled, isFalse);
    expect(tapRegion.behavior, HitTestBehavior.opaque);
    expect(tapRegion.groupId, 'tap-group');
    expect(tapRegion.consumeOutsideTaps, isTrue);
    expect(tapRegion.debugLabel, 'tap-region-props');
  });

  testWidgets('dispatches reorderable list interactions', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'SizedBox',
            'props': {
              'width': 320,
              'height': 260,
              'child': {
                'type': 'ReorderableListView',
                'props': {
                  'buildDefaultDragHandles': false,
                  'onReorderItem': {
                    'type': 'Action',
                    'props': {'name': 'reorder'},
                  },
                  'onReorderStart': {
                    'type': 'Action',
                    'props': {'name': 'reorderStart'},
                  },
                  'onReorderEnd': {
                    'type': 'Action',
                    'props': {'name': 'reorderEnd'},
                  },
                  'children': [
                    {
                      'type': 'ReorderableDragStartListener',
                      'props': {
                        'key': 'alpha',
                        'index': 0,
                        'child': {
                          'type': 'SizedBox',
                          'props': {
                            'height': 72,
                            'child': {
                              'type': 'Center',
                              'props': {
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Alpha'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    {
                      'type': 'ReorderableDragStartListener',
                      'props': {
                        'key': 'beta',
                        'index': 1,
                        'child': {
                          'type': 'SizedBox',
                          'props': {
                            'height': 72,
                            'child': {
                              'type': 'Center',
                              'props': {
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Beta'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    {
                      'type': 'ReorderableDelayedDragStartListener',
                      'props': {
                        'key': 'gamma',
                        'index': 2,
                        'child': {
                          'type': 'SizedBox',
                          'props': {
                            'height': 72,
                            'child': {
                              'type': 'Center',
                              'props': {
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Gamma'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  ],
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('Gamma'), findsOneWidget);

    final start = tester.getCenter(find.text('Alpha'));
    await tester.dragFrom(start, const Offset(0, 145));
    await tester.pumpAndSettle();

    final names = actions.map((action) => action.name);
    expect(names, contains('reorderStart'));
    expect(names, contains('reorder'));
    expect(names, contains('reorderEnd'));

    final reorder = actions.firstWhere((action) => action.name == 'reorder');
    expect(reorder.payload, {'oldIndex': 0, 'newIndex': 1});
    expect(
      actions.firstWhere((action) => action.name == 'reorderStart').payload,
      0,
    );
  });

  testWidgets('dispatches tap region and focusable action detector events', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );
    final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousHighlightStrategy;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Stack',
            'props': {
              'children': [
                {
                  'type': 'Positioned',
                  'props': {
                    'left': 20,
                    'top': 20,
                    'child': {
                      'type': 'TapRegion',
                      'props': {
                        'behavior': 'opaque',
                        'onTapInside': {
                          'type': 'Action',
                          'props': {'name': 'tapInside'},
                        },
                        'onTapOutside': {
                          'type': 'Action',
                          'props': {'name': 'tapOutside'},
                        },
                        'onTapUpInside': {
                          'type': 'Action',
                          'props': {'name': 'tapUpInside'},
                        },
                        'onTapUpOutside': {
                          'type': 'Action',
                          'props': {'name': 'tapUpOutside'},
                        },
                        'child': {
                          'type': 'SizedBox',
                          'props': {
                            'width': 160,
                            'height': 64,
                            'child': {
                              'type': 'Center',
                              'props': {
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Region'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
                {
                  'type': 'Positioned',
                  'props': {
                    'left': 240,
                    'top': 20,
                    'child': {
                      'type': 'SizedBox',
                      'props': {
                        'width': 160,
                        'height': 64,
                        'child': {
                          'type': 'Center',
                          'props': {
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Outside'},
                            },
                          },
                        },
                      },
                    },
                  },
                },
                {
                  'type': 'Positioned',
                  'props': {
                    'left': 20,
                    'top': 120,
                    'child': {
                      'type': 'FocusableActionDetector',
                      'props': {
                        'autofocus': true,
                        'mouseCursor': 'click',
                        'onFocusChange': {
                          'type': 'Action',
                          'props': {'name': 'focusChanged'},
                        },
                        'onShowHoverHighlight': {
                          'type': 'Action',
                          'props': {'name': 'hoverHighlight'},
                        },
                        'child': {
                          'type': 'SizedBox',
                          'props': {
                            'width': 180,
                            'height': 64,
                            'child': {
                              'type': 'Center',
                              'props': {
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Focusable'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              ],
            },
          }),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Region'));
    await tester.pump();
    await tester.tap(find.text('Outside'));
    await tester.pump();

    final names = actions.map((action) => action.name);
    expect(names, contains('tapInside'));
    expect(names, contains('tapOutside'));
    expect(names, contains('tapUpInside'));
    expect(names, contains('tapUpOutside'));

    final inside = actions.firstWhere((action) => action.name == 'tapInside');
    expect((inside.payload as Map)['kind'], isNotEmpty);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(500, 500));
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Focusable')));
    await tester.pump();
    await gesture.moveTo(const Offset(500, 500));
    await tester.pump();

    expect(actions.map((action) => action.name), contains('focusChanged'));
    expect(actions.map((action) => action.name), contains('hoverHighlight'));
    expect(
      actions
          .where((action) => action.name == 'hoverHighlight')
          .map((action) => action.payload),
      containsAll(<bool>[true, false]),
    );
  });

  testWidgets('dispatches keyboard listener and focus key events', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'KeyboardListener',
            'props': {
              'autofocus': true,
              'onKeyEvent': {
                'type': 'Action',
                'props': {'name': 'keyboard'},
              },
              'child': {
                'type': 'Text',
                'props': {'data': 'Keyboard target'},
              },
            },
          }),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);

    final keyboard = actions.single;
    expect(keyboard.name, 'keyboard');
    expect((keyboard.payload as Map)['logicalKey'], contains('Enter'));

    actions.clear();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Focus',
            'props': {
              'autofocus': true,
              'onKeyEvent': {
                'type': 'Action',
                'props': {'name': 'focusKey'},
              },
              'child': {
                'type': 'Text',
                'props': {'data': 'Focus target'},
              },
            },
          }),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);

    final focusKey = actions.single;
    expect(focusKey.name, 'focusKey');
    expect((focusKey.payload as Map)['logicalKeyLabel'], 'A');
  });

  testWidgets('dispatches callback shortcuts', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'CallbackShortcuts',
            'props': {
              'bindings': {
                'ctrl+s': {
                  'type': 'Action',
                  'props': {'name': 'save'},
                },
              },
              'child': {
                'type': 'Focus',
                'props': {
                  'autofocus': true,
                  'child': {
                    'type': 'Text',
                    'props': {'data': 'Shortcut target'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(actions.single.name, 'save');
  });

  testWidgets('maps focus, autofill, and reorderable props safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    Future<void> pumpSpec(Map<String, Object?> spec) {
      return tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => renderer.buildWidget(context, spec),
          ),
        ),
      );
    }

    await pumpSpec({
      'type': 'AutofillGroup',
      'props': {
        'onDisposeAction': 'cancel',
        'child': {
          'type': 'Text',
          'props': {'data': 'autofill'},
        },
      },
    });
    final autofillGroup = tester.widget<AutofillGroup>(
      find.byType(AutofillGroup),
    );
    expect(autofillGroup.onDisposeAction, AutofillContextAction.cancel);

    await pumpSpec({
      'type': 'Focus',
      'props': {
        'autofocus': true,
        'canRequestFocus': false,
        'skipTraversal': true,
        'descendantsAreFocusable': false,
        'descendantsAreTraversable': false,
        'includeSemantics': false,
        'debugLabel': 'focus-shell',
        'onFocusChange': {
          'type': 'Action',
          'props': {'name': 'focusChanged'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'focus props'},
        },
      },
    });
    final focus = tester.widget<Focus>(
      find.byWidgetPredicate(
        (widget) => widget is Focus && widget.debugLabel == 'focus-shell',
      ),
    );
    expect(focus.autofocus, isTrue);
    expect(focus.canRequestFocus, isFalse);
    expect(focus.skipTraversal, isTrue);
    expect(focus.descendantsAreFocusable, isFalse);
    expect(focus.descendantsAreTraversable, isFalse);
    expect(focus.includeSemantics, isFalse);
    expect(focus.debugLabel, 'focus-shell');
    actions.clear();
    focus.onFocusChange!(true);
    expect(actions.single.name, 'focusChanged');
    expect(actions.single.payload, isTrue);

    await pumpSpec({
      'type': 'FocusTraversalGroup',
      'props': {
        'policy': 'widgetOrder',
        'descendantsAreFocusable': false,
        'descendantsAreTraversable': false,
        'child': {
          'type': 'Text',
          'props': {'data': 'traversal props'},
        },
      },
    });
    final traversalGroup = tester.widget<FocusTraversalGroup>(
      find.byWidgetPredicate(
        (widget) =>
            widget is FocusTraversalGroup &&
            widget.policy is WidgetOrderTraversalPolicy &&
            !widget.descendantsAreFocusable,
      ),
    );
    expect(traversalGroup.policy, isA<WidgetOrderTraversalPolicy>());
    expect(traversalGroup.descendantsAreFocusable, isFalse);
    expect(traversalGroup.descendantsAreTraversable, isFalse);

    await pumpSpec({
      'type': 'SizedBox',
      'props': {
        'width': 320,
        'height': 220,
        'child': {
          'type': 'ReorderableListView',
          'props': {
            'itemExtent': -12,
            'buildDefaultDragHandles': false,
            'scrollDirection': 'vertical',
            'reverse': true,
            'shrinkWrap': true,
            'anchor': 4,
            'scrollCacheExtent': {'viewport': 1.5},
            'dragStartBehavior': 'down',
            'keyboardDismissBehavior': 'onDrag',
            'restorationId': 'reorder-restoration',
            'clipBehavior': 'none',
            'autoScrollerVelocityScalar': -4,
            'mouseCursor': 'click',
            'children': [
              {
                'type': 'ReorderableDragStartListener',
                'props': {
                  'key': 'safe-start',
                  'index': -5,
                  'enabled': false,
                  'child': {
                    'type': 'SizedBox',
                    'props': {
                      'height': 56,
                      'child': {
                        'type': 'Text',
                        'props': {'data': 'safe start'},
                      },
                    },
                  },
                },
              },
              {
                'type': 'ReorderableDelayedDragStartListener',
                'props': {
                  'key': 'safe-delayed',
                  'index': -6,
                  'enabled': false,
                  'child': {
                    'type': 'SizedBox',
                    'props': {
                      'height': 56,
                      'child': {
                        'type': 'Text',
                        'props': {'data': 'safe delayed'},
                      },
                    },
                  },
                },
              },
            ],
          },
        },
      },
    });
    final reorderableList = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    expect(reorderableList.itemExtent, isNull);
    expect(reorderableList.buildDefaultDragHandles, isFalse);
    expect(reorderableList.reverse, isTrue);
    expect(reorderableList.shrinkWrap, isTrue);
    expect(reorderableList.anchor, 1);
    expect(
      reorderableList.scrollCacheExtent,
      const ScrollCacheExtent.viewport(1.5),
    );
    expect(reorderableList.dragStartBehavior, DragStartBehavior.down);
    expect(
      reorderableList.keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
    expect(reorderableList.restorationId, 'reorder-restoration');
    expect(reorderableList.clipBehavior, Clip.none);
    expect(reorderableList.autoScrollerVelocityScalar, isNull);
    expect(reorderableList.mouseCursor, SystemMouseCursors.click);

    final dragStart = tester.widget<ReorderableDragStartListener>(
      find.byType(ReorderableDragStartListener),
    );
    expect(dragStart.index, 0);
    expect(dragStart.enabled, isFalse);

    final delayedDragStart = tester.widget<ReorderableDelayedDragStartListener>(
      find.byType(ReorderableDelayedDragStartListener),
    );
    expect(delayedDragStart.index, 0);
    expect(delayedDragStart.enabled, isFalse);
  });

  testWidgets('dispatches navigation rail index changes', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'NavigationRail',
                'props': {
                  'selectedIndex': 0,
                  'extended': true,
                  'onDestinationSelected': {
                    'type': 'Action',
                    'props': {'name': 'selectSection'},
                  },
                  'destinations': [
                    {
                      'type': 'NavigationRailDestination',
                      'props': {
                        'icon': {
                          'type': 'Icon',
                          'props': {'icon': 'home'},
                        },
                        'label': {
                          'type': 'Text',
                          'props': {'data': 'Home'},
                        },
                      },
                    },
                    {
                      'type': 'NavigationRailDestination',
                      'props': {
                        'icon': {
                          'type': 'Icon',
                          'props': {'icon': 'widgets'},
                        },
                        'label': {
                          'type': 'Text',
                          'props': {'data': 'Material'},
                        },
                      },
                    },
                  ],
                },
              },
            },
          }),
        ),
      ),
    );

    await tester.tap(find.text('Material'));
    await tester.pump();

    expect(actions.single.name, 'selectSection');
    expect(actions.single.payload, 1);
  });

  testWidgets('dispatches text input changes', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'TextField',
                'props': {
                  'labelText': 'Name',
                  'onChanged': {
                    'type': 'Action',
                    'props': {'name': 'nameChanged'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Applet');
    await tester.pump();

    expect(actions.last.name, 'nameChanged');
    expect(actions.last.payload, 'Applet');
  });

  testWidgets('maps Material autocomplete options safely', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Autocomplete',
              'props': {
                'initialValue': 'alp',
                'labelText': 'Pick item',
                'optionsMaxHeight': 144,
                'openDirection': 'up',
                'filter': 'startsWith',
                'optionsLimit': 1,
                'showAllOnEmpty': false,
                'selectedPayload': 'full',
                'onInput': {
                  'type': 'Action',
                  'props': {'name': 'autocompleteInput'},
                },
                'onSelected': {
                  'type': 'Action',
                  'props': {'name': 'autocompleteSelected'},
                },
                'options': [
                  'Alpha',
                  {
                    'label': 'Beta',
                    'value': {'id': 2},
                    'search': ['beta', 'second'],
                  },
                  'Gamma',
                ],
              },
            }),
          ),
        ),
      ),
    );

    final autocomplete =
        tester.widget(
              find.byWidgetPredicate((widget) => widget is Autocomplete),
            )
            as dynamic;
    Future<List<dynamic>> optionsFor(String text) async {
      final result = await Future<Iterable<dynamic>>.value(
        autocomplete.optionsBuilder(TextEditingValue(text: text))
            as FutureOr<Iterable<dynamic>>,
      );
      return result.toList();
    }

    expect(autocomplete.initialValue?.text, 'alp');
    expect(autocomplete.optionsMaxHeight, 144);
    expect(autocomplete.optionsViewOpenDirection, OptionsViewOpenDirection.up);
    expect(await optionsFor(''), isEmpty);

    final alphaOptions = await optionsFor('a');
    expect(alphaOptions, hasLength(1));
    expect(autocomplete.displayStringForOption(alphaOptions.single), 'Alpha');

    final betaOptions = await optionsFor('b');
    expect(betaOptions, hasLength(1));
    expect(autocomplete.displayStringForOption(betaOptions.single), 'Beta');
    autocomplete.onSelected(betaOptions.single);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, 'alp');
    expect(field.decoration?.labelText, 'Pick item');
    field.onChanged!('Ga');

    expect(actions.map((action) => action.name), [
      'autocompleteSelected',
      'autocompleteInput',
    ]);
    expect(actions.first.payload, {
      'label': 'Beta',
      'value': {'id': 2},
    });
    expect(actions.last.payload, 'Ga');
  });

  testWidgets('maps rich material text input behavior props safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'TextField',
              'props': {
                'value': 'secret',
                'obscureText': true,
                'obscuringCharacter': '**',
                'showCursor': false,
                'minLines': -2,
                'maxLines': 5,
                'maxLength': 'none',
                'textDirection': 'rtl',
                'strutStyle': {'fontSize': 16, 'height': 1.2},
                'cursorWidth': -4,
                'cursorHeight': -8,
                'cursorRadius': {'x': 4, 'y': -2},
                'cursorColor': '#ff0000',
                'cursorErrorColor': '#ba1a1a',
                'cursorOpacityAnimates': true,
                'selectionHeightStyle': 'bottom',
                'selectionWidthStyle': 'max',
                'scrollPadding': {'all': 9},
                'dragStartBehavior': 'down',
                'enableInteractiveSelection': false,
                'selectAllOnFocus': true,
                'selectionControls': 'material',
                'scrollPhysics': 'never',
                'restorationId': 'login-field',
                'enableIMEPersonalizedLearning': false,
                'mouseCursor': 'text',
                'contextMenu': false,
                'magnifier': false,
                'clipBehavior': 'none',
                'stylusHandwritingEnabled': false,
                'canRequestFocus': false,
                'onTap': {
                  'type': 'Action',
                  'props': {'name': 'inputTap'},
                },
                'onTapOutside': {
                  'type': 'Action',
                  'props': {'name': 'inputTapOutside'},
                },
                'onTapUpOutside': {
                  'type': 'Action',
                  'props': {'name': 'inputTapUpOutside'},
                },
                'onEditingComplete': {
                  'type': 'Action',
                  'props': {'name': 'inputEditingComplete'},
                },
              },
            }),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, isTrue);
    expect(textField.obscuringCharacter, '•');
    expect(textField.showCursor, isFalse);
    expect(textField.minLines, isNull);
    expect(textField.maxLines, 1);
    expect(textField.maxLength, TextField.noMaxLength);
    expect(textField.textDirection, TextDirection.rtl);
    expect(textField.strutStyle?.fontSize, 16);
    expect(textField.cursorWidth, 2);
    expect(textField.cursorHeight, isNull);
    expect(textField.cursorRadius, const Radius.elliptical(4, 0));
    expect(textField.cursorColor, const Color(0xffff0000));
    expect(textField.cursorErrorColor, const Color(0xffba1a1a));
    expect(textField.cursorOpacityAnimates, isTrue);
    expect(
      textField.selectionHeightStyle,
      ui.BoxHeightStyle.includeLineSpacingBottom,
    );
    expect(textField.selectionWidthStyle, ui.BoxWidthStyle.max);
    expect(textField.scrollPadding, const EdgeInsets.all(9));
    expect(textField.dragStartBehavior, DragStartBehavior.down);
    expect(textField.enableInteractiveSelection, isFalse);
    expect(textField.selectAllOnFocus, isTrue);
    expect(
      textField.selectionControls,
      same(materialTextSelectionHandleControls),
    );
    expect(textField.scrollPhysics, isA<NeverScrollableScrollPhysics>());
    expect(textField.restorationId, 'login-field');
    expect(textField.enableIMEPersonalizedLearning, isFalse);
    expect(textField.mouseCursor, SystemMouseCursors.text);
    expect(textField.contextMenuBuilder, isNull);
    expect(
      textField.magnifierConfiguration,
      TextMagnifierConfiguration.disabled,
    );
    expect(textField.clipBehavior, Clip.none);
    expect(textField.stylusHandwritingEnabled, isFalse);
    expect(textField.canRequestFocus, isFalse);

    textField.onTap!();
    textField.onTapOutside!(const PointerDownEvent(position: Offset(4, 5)));
    textField.onTapUpOutside!(const PointerUpEvent(position: Offset(6, 7)));
    textField.onEditingComplete!();

    expect(actions.map((action) => action.name), [
      'inputTap',
      'inputTapOutside',
      'inputTapUpOutside',
      'inputEditingComplete',
    ]);
    expect(actions[1].payload, containsPair('x', 4.0));
    expect(actions[2].payload, containsPair('x', 6.0));
  });

  testWidgets('maps rich material input decorations', (tester) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'TextField',
              'props': {
                'decoration': {
                  'labelWidget': {
                    'type': 'Text',
                    'props': {'data': 'Label widget'},
                  },
                  'labelText': 'Ignored label text',
                  'labelStyle': {'color': '#111111', 'fontWeight': 'w700'},
                  'floatingLabelStyle': {'color': '#006a6a'},
                  'helperText': 'Helper text',
                  'helperStyle': {'color': '#666666'},
                  'helperMaxLines': 2,
                  'hintText': 'Hint text',
                  'hintStyle': {'fontStyle': 'italic'},
                  'hintTextDirection': 'rtl',
                  'hintMaxLines': 3,
                  'hintFadeDuration': 150,
                  'maintainHintSize': false,
                  'maintainLabelSize': true,
                  'errorText': 'Error text',
                  'errorStyle': {'color': '#ba1a1a'},
                  'errorMaxLines': 4,
                  'floatingLabelBehavior': 'always',
                  'floatingLabelAlignment': 'center',
                  'isDense': true,
                  'contentPadding': {'horizontal': 12, 'vertical': 8},
                  'prefixText': 'https://',
                  'prefixStyle': {'color': '#00639b'},
                  'prefixIcon': {
                    'type': 'Icon',
                    'props': {'icon': 'search'},
                  },
                  'prefixIconColor': '#006a6a',
                  'prefixIconConstraints': {'minWidth': 36, 'minHeight': 32},
                  'suffixText': '.com',
                  'suffixStyle': {'color': '#6750a4'},
                  'suffixIcon': {
                    'type': 'Icon',
                    'props': {'icon': 'check'},
                  },
                  'suffixIconColor': '#386a20',
                  'suffixIconConstraints': {'minWidth': 40, 'minHeight': 34},
                  'counterText': '0/20',
                  'counterStyle': {'color': '#444444'},
                  'filled': true,
                  'fillColor': '#f4eff4',
                  'focusColor': '#d0bcff',
                  'hoverColor': '#e7e0ec',
                  'border': {
                    'type': 'outline',
                    'borderRadius': 16,
                    'gapPadding': 6,
                    'borderSide': {'color': '#79747e', 'width': 1.5},
                  },
                  'focusedBorder': {
                    'type': 'underline',
                    'borderSide': {'color': '#006a6a', 'width': 2},
                  },
                  'enabled': false,
                  'semanticCounterText': 'zero of twenty',
                  'alignLabelWithHint': true,
                  'constraints': {'minWidth': 120, 'maxWidth': 240},
                  'visualDensity': {'horizontal': -1, 'vertical': 2},
                },
              },
            }),
          ),
        ),
      ),
    );

    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;

    expect(decoration.label, isA<Text>());
    expect((decoration.label! as Text).data, 'Label widget');
    expect(decoration.labelText, isNull);
    expect(decoration.labelStyle?.color, const Color(0xff111111));
    expect(decoration.labelStyle?.fontWeight, FontWeight.w700);
    expect(decoration.floatingLabelStyle?.color, const Color(0xff006a6a));
    expect(decoration.helperText, 'Helper text');
    expect(decoration.helperStyle?.color, const Color(0xff666666));
    expect(decoration.helperMaxLines, 2);
    expect(decoration.hintText, 'Hint text');
    expect(decoration.hintStyle?.fontStyle, FontStyle.italic);
    expect(decoration.hintTextDirection, TextDirection.rtl);
    expect(decoration.hintMaxLines, 3);
    expect(decoration.hintFadeDuration, const Duration(milliseconds: 150));
    expect(decoration.maintainHintSize, isFalse);
    expect(decoration.maintainLabelSize, isTrue);
    expect(decoration.errorText, 'Error text');
    expect(decoration.errorStyle?.color, const Color(0xffba1a1a));
    expect(decoration.errorMaxLines, 4);
    expect(decoration.floatingLabelBehavior, FloatingLabelBehavior.always);
    expect(decoration.floatingLabelAlignment, FloatingLabelAlignment.center);
    expect(decoration.isDense, isTrue);
    expect(
      decoration.contentPadding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
    expect(decoration.prefixText, 'https://');
    expect(decoration.prefixStyle?.color, const Color(0xff00639b));
    expect(decoration.prefixIcon, isA<Icon>());
    expect(decoration.prefixIconColor, const Color(0xff006a6a));
    expect(
      decoration.prefixIconConstraints,
      const BoxConstraints(minWidth: 36, minHeight: 32),
    );
    expect(decoration.suffixText, '.com');
    expect(decoration.suffixStyle?.color, const Color(0xff6750a4));
    expect(decoration.suffixIcon, isA<Icon>());
    expect(decoration.suffixIconColor, const Color(0xff386a20));
    expect(
      decoration.suffixIconConstraints,
      const BoxConstraints(minWidth: 40, minHeight: 34),
    );
    expect(decoration.counterText, '0/20');
    expect(decoration.counterStyle?.color, const Color(0xff444444));
    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, const Color(0xfff4eff4));
    expect(decoration.focusColor, const Color(0xffd0bcff));
    expect(decoration.hoverColor, const Color(0xffe7e0ec));
    expect(decoration.border, isA<OutlineInputBorder>());
    final border = decoration.border! as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(16));
    expect(border.borderSide.color, const Color(0xff79747e));
    expect(border.borderSide.width, 1.5);
    expect(border.gapPadding, 6);
    expect(decoration.focusedBorder, isA<UnderlineInputBorder>());
    final focusedBorder = decoration.focusedBorder! as UnderlineInputBorder;
    expect(focusedBorder.borderSide.color, const Color(0xff006a6a));
    expect(focusedBorder.borderSide.width, 2);
    expect(decoration.enabled, isFalse);
    expect(decoration.semanticCounterText, 'zero of twenty');
    expect(decoration.alignLabelWithHint, isTrue);
    expect(
      decoration.constraints,
      const BoxConstraints(minWidth: 120, maxWidth: 240),
    );
    expect(
      decoration.visualDensity,
      const VisualDensity(horizontal: -1, vertical: 2),
    );
  });

  testWidgets('maps extended material button styles', (tester) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'FilledButton',
                    'props': {
                      'tonal': true,
                      'icon': 'check',
                      'label': 'Save',
                      'onLongPress': {
                        'type': 'Action',
                        'props': {'name': 'hold'},
                      },
                      'style': {
                        'textStyle': {'fontSize': 18, 'fontWeight': 'w700'},
                        'backgroundColor': '#006a6a',
                        'foregroundColor': '#ffffff',
                        'overlayColor': '#33000000',
                        'surfaceTintColor': '#d0bcff',
                        'shadowColor': '#55000000',
                        'elevation': 3,
                        'padding': {'horizontal': 18, 'vertical': 10},
                        'minimumSize': [96, 44],
                        'fixedSize': [128, 48],
                        'maximumSize': [200, 56],
                        'iconColor': '#ffcc00',
                        'iconSize': 22,
                        'iconAlignment': 'end',
                        'side': {'color': '#003737', 'width': 1.5},
                        'shape': {'borderRadius': 20},
                        'visualDensity': 'compact',
                        'tapTargetSize': 'shrinkWrap',
                        'animationDuration': 250,
                        'enableFeedback': false,
                        'alignment': 'centerLeft',
                      },
                    },
                  },
                  {
                    'type': 'IconButton',
                    'props': {
                      'icon': 'settings',
                      'style': {
                        'backgroundColor': '#f4eff4',
                        'iconColor': '#6750a4',
                        'iconSize': 28,
                        'visualDensity': {'horizontal': -1, 'vertical': -2},
                        'tapTargetSize': 'padded',
                      },
                    },
                  },
                  {
                    'type': 'TextButton',
                    'props': {
                      'label': 'Safe',
                      'style': {
                        'elevation': -3,
                        'minimumSize': [-96, -44],
                        'fixedSize': [-128, -48],
                        'maximumSize': [-200, -56],
                        'iconSize': -22,
                      },
                    },
                  },
                  {
                    'type': 'IconButton',
                    'props': {
                      'icon': 'favorite',
                      'variant': 'filled',
                      'tooltip': 'Favorite',
                      'color': '#b3261e',
                      'iconSize': -12,
                      'splashRadius': -4,
                      'padding': {'all': 6},
                      'alignment': 'centerRight',
                      'constraints': {'minWidth': -10, 'maxWidth': -20},
                      'enableFeedback': false,
                    },
                  },
                  {
                    'type': 'FloatingActionButton',
                    'props': {
                      'variant': 'extended',
                      'heroTag': 'save-fab',
                      'icon': {
                        'type': 'Icon',
                        'props': {'icon': 'save'},
                      },
                      'label': {
                        'type': 'Text',
                        'props': {'data': 'Create'},
                      },
                      'tooltip': 'Create item',
                      'foregroundColor': '#ffffff',
                      'backgroundColor': '#006a6a',
                      'focusColor': '#111111',
                      'hoverColor': '#222222',
                      'splashColor': '#333333',
                      'elevation': -6,
                      'focusElevation': -7,
                      'hoverElevation': -8,
                      'highlightElevation': -9,
                      'disabledElevation': -10,
                      'mouseCursor': 'click',
                      'shape': {'borderRadius': 18},
                      'clipBehavior': 'antiAlias',
                      'autofocus': true,
                      'tapTargetSize': 'shrinkWrap',
                      'enableFeedback': false,
                      'extendedIconLabelSpacing': -2,
                      'extendedPadding': {'horizontal': 14},
                      'extendedTextStyle': {'fontSize': 15},
                    },
                  },
                  {
                    'type': 'FloatingActionButton',
                    'props': {
                      'variant': 'small',
                      'heroTag': 'small-fab',
                      'tooltip': 'Small action',
                      'child': {
                        'type': 'Icon',
                        'props': {'icon': 'add'},
                      },
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final style = button.style!;
    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(style.textStyle?.resolve({})?.fontSize, 18);
    expect(style.textStyle?.resolve({})?.fontWeight, FontWeight.w700);
    expect(style.backgroundColor?.resolve({}), const Color(0xff006a6a));
    expect(style.foregroundColor?.resolve({}), const Color(0xffffffff));
    expect(style.overlayColor?.resolve({}), const Color(0x33000000));
    expect(style.surfaceTintColor?.resolve({}), const Color(0xffd0bcff));
    expect(style.shadowColor?.resolve({}), const Color(0x55000000));
    expect(style.elevation?.resolve({}), 3);
    expect(
      style.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    );
    expect(style.minimumSize?.resolve({}), const Size(96, 44));
    expect(style.fixedSize?.resolve({}), const Size(128, 48));
    expect(style.maximumSize?.resolve({}), const Size(200, 56));
    expect(style.iconColor?.resolve({}), const Color(0xffffcc00));
    expect(style.iconSize?.resolve({}), 22);
    expect(style.iconAlignment, IconAlignment.end);
    expect(style.side?.resolve({})?.color, const Color(0xff003737));
    expect(style.side?.resolve({})?.width, 1.5);
    expect(style.shape?.resolve({}), isA<RoundedRectangleBorder>());
    expect(style.visualDensity, VisualDensity.compact);
    expect(style.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(style.animationDuration, const Duration(milliseconds: 250));
    expect(style.enableFeedback, isFalse);
    expect(style.alignment, Alignment.centerLeft);

    final iconButton = tester
        .widgetList<IconButton>(find.byType(IconButton))
        .first;
    final iconStyle = iconButton.style!;
    expect(iconStyle.backgroundColor?.resolve({}), const Color(0xfff4eff4));
    expect(iconStyle.iconColor?.resolve({}), const Color(0xff6750a4));
    expect(iconStyle.iconSize?.resolve({}), 28);
    expect(
      iconStyle.visualDensity,
      const VisualDensity(horizontal: -1, vertical: -2),
    );
    expect(iconStyle.tapTargetSize, MaterialTapTargetSize.padded);

    final safeButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Safe'),
    );
    final safeStyle = safeButton.style!;
    expect(safeStyle.elevation?.resolve({}), 0);
    expect(safeStyle.minimumSize?.resolve({}), Size.zero);
    expect(safeStyle.fixedSize?.resolve({}), Size.zero);
    expect(safeStyle.maximumSize?.resolve({}), Size.zero);
    expect(safeStyle.iconSize?.resolve({}), 0);

    final directIconButton = tester
        .widgetList<IconButton>(find.byType(IconButton))
        .last;
    expect(directIconButton.tooltip, 'Favorite');
    expect(directIconButton.color, const Color(0xffb3261e));
    expect(directIconButton.iconSize, 0);
    expect(directIconButton.splashRadius, isNull);
    expect(directIconButton.padding, const EdgeInsets.all(6));
    expect(directIconButton.alignment, Alignment.centerRight);
    expect(directIconButton.constraints?.minWidth, 0);
    expect(directIconButton.constraints?.maxWidth, 0);
    expect(directIconButton.enableFeedback, isFalse);

    final fabs = tester
        .widgetList<FloatingActionButton>(find.byType(FloatingActionButton))
        .toList();
    expect(fabs, hasLength(2));
    final fab = fabs.first;
    expect(fab.tooltip, 'Create item');
    expect(fab.foregroundColor, const Color(0xffffffff));
    expect(fab.backgroundColor, const Color(0xff006a6a));
    expect(fab.focusColor, const Color(0xff111111));
    expect(fab.hoverColor, const Color(0xff222222));
    expect(fab.splashColor, const Color(0xff333333));
    expect(fab.heroTag, 'save-fab');
    expect(fab.elevation, 0);
    expect(fab.focusElevation, 0);
    expect(fab.hoverElevation, 0);
    expect(fab.highlightElevation, 0);
    expect(fab.disabledElevation, 0);
    expect(fab.mouseCursor, SystemMouseCursors.click);
    expect(fab.shape, isA<RoundedRectangleBorder>());
    expect(fab.clipBehavior, Clip.antiAlias);
    expect(fab.autofocus, isTrue);
    expect(fab.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(fab.enableFeedback, isFalse);
    expect(fab.extendedIconLabelSpacing, 0);
    expect(fab.extendedPadding, const EdgeInsets.symmetric(horizontal: 14));
    expect(fab.extendedTextStyle?.fontSize, 15);

    final smallFab = fabs.last;
    expect(smallFab.tooltip, 'Small action');
    expect(smallFab.heroTag, 'small-fab');
    expect(smallFab.mini, isTrue);
    expect(smallFab.isExtended, isFalse);
  });

  testWidgets('maps rich material list tiles and expansion tiles', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'ListView',
              'props': {
                'children': [
                  {
                    'type': 'ListTile',
                    'props': {
                      'leading': {
                        'type': 'Icon',
                        'props': {'icon': 'menu'},
                      },
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Primary'},
                      },
                      'subtitle': {
                        'type': 'Text',
                        'props': {'data': 'Secondary'},
                      },
                      'trailing': {
                        'type': 'Icon',
                        'props': {'icon': 'chevron_right'},
                      },
                      'selected': true,
                      'enabled': true,
                      'dense': true,
                      'isThreeLine': false,
                      'contentPadding': {'horizontal': 18, 'vertical': 6},
                      'tileColor': '#fffbfe',
                      'selectedTileColor': '#e6fffb',
                      'textColor': '#1d1b20',
                      'iconColor': '#006a6a',
                      'selectedColor': '#6750a4',
                      'focusColor': '#d0bcff',
                      'hoverColor': '#e7e0ec',
                      'splashColor': '#33006a6a',
                      'shape': {'borderRadius': 14},
                      'style': 'drawer',
                      'titleTextStyle': {'fontSize': 16, 'fontWeight': 'w700'},
                      'subtitleTextStyle': {'fontSize': 13},
                      'leadingAndTrailingTextStyle': {'fontSize': 12},
                      'visualDensity': {'horizontal': -1, 'vertical': -2},
                      'horizontalTitleGap': 12,
                      'minVerticalPadding': 4,
                      'minLeadingWidth': 32,
                      'minTileHeight': 48,
                      'enableFeedback': false,
                      'titleAlignment': 'top',
                      'autofocus': true,
                      'mouseCursor': 'click',
                      'onTap': {
                        'type': 'Action',
                        'props': {'name': 'tileTap'},
                      },
                      'onLongPress': {
                        'type': 'Action',
                        'props': {'name': 'tileLongPress'},
                      },
                      'onFocusChange': {
                        'type': 'Action',
                        'props': {'name': 'tileFocus'},
                      },
                    },
                  },
                  {
                    'type': 'ExpansionTile',
                    'props': {
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Group'},
                      },
                      'subtitle': {
                        'type': 'Text',
                        'props': {'data': 'Expanded details'},
                      },
                      'showTrailingIcon': false,
                      'initiallyExpanded': true,
                      'maintainState': true,
                      'tilePadding': {'horizontal': 20},
                      'expandedCrossAxisAlignment': 'start',
                      'expandedAlignment': 'centerLeft',
                      'childrenPadding': {'left': 20, 'bottom': 8},
                      'backgroundColor': '#f4eff4',
                      'collapsedBackgroundColor': '#fffbfe',
                      'textColor': '#1d1b20',
                      'collapsedTextColor': '#49454f',
                      'iconColor': '#006a6a',
                      'collapsedIconColor': '#79747e',
                      'shape': {'borderRadius': 16},
                      'collapsedShape': {'borderRadius': 8},
                      'clipBehavior': 'antiAlias',
                      'controlAffinity': 'leading',
                      'dense': true,
                      'splashColor': '#33006a6a',
                      'visualDensity': 'compact',
                      'minTileHeight': 52,
                      'enableFeedback': false,
                      'enabled': true,
                      'animationStyle': {
                        'duration': 220,
                        'reverseDuration': 140,
                        'curve': 'easeIn',
                        'reverseCurve': 'easeOut',
                      },
                      'onExpansionChanged': {
                        'type': 'Action',
                        'props': {'name': 'expanded'},
                      },
                      'children': [
                        {
                          'type': 'Text',
                          'props': {'data': 'Child row'},
                        },
                      ],
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final tile = tester.widget<ListTile>(find.byType(ListTile).first);
    expect(tile.selected, isTrue);
    expect(tile.dense, isTrue);
    expect(
      tile.contentPadding,
      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    );
    expect(tile.tileColor, const Color(0xfffffbfe));
    expect(tile.selectedTileColor, const Color(0xffe6fffb));
    expect(tile.textColor, const Color(0xff1d1b20));
    expect(tile.iconColor, const Color(0xff006a6a));
    expect(tile.selectedColor, const Color(0xff6750a4));
    expect(tile.focusColor, const Color(0xffd0bcff));
    expect(tile.hoverColor, const Color(0xffe7e0ec));
    expect(tile.splashColor, const Color(0x33006a6a));
    expect(tile.shape, isA<RoundedRectangleBorder>());
    expect(tile.style, ListTileStyle.drawer);
    expect(tile.titleTextStyle?.fontSize, 16);
    expect(tile.titleTextStyle?.fontWeight, FontWeight.w700);
    expect(tile.subtitleTextStyle?.fontSize, 13);
    expect(tile.leadingAndTrailingTextStyle?.fontSize, 12);
    expect(
      tile.visualDensity,
      const VisualDensity(horizontal: -1, vertical: -2),
    );
    expect(tile.horizontalTitleGap, 12);
    expect(tile.minVerticalPadding, 4);
    expect(tile.minLeadingWidth, 32);
    expect(tile.minTileHeight, 48);
    expect(tile.enableFeedback, isFalse);
    expect(tile.titleAlignment, ListTileTitleAlignment.top);
    expect(tile.autofocus, isTrue);
    expect(tile.mouseCursor, SystemMouseCursors.click);

    actions.clear();
    tile.onTap!();
    tile.onLongPress!();
    tile.onFocusChange!(true);

    final expansion = tester.widget<ExpansionTile>(find.byType(ExpansionTile));
    expect(expansion.showTrailingIcon, isFalse);
    expect(expansion.initiallyExpanded, isTrue);
    expect(expansion.maintainState, isTrue);
    expect(expansion.tilePadding, const EdgeInsets.symmetric(horizontal: 20));
    expect(expansion.expandedCrossAxisAlignment, CrossAxisAlignment.start);
    expect(expansion.expandedAlignment, Alignment.centerLeft);
    expect(
      expansion.childrenPadding,
      const EdgeInsets.only(left: 20, bottom: 8),
    );
    expect(expansion.backgroundColor, const Color(0xfff4eff4));
    expect(expansion.collapsedBackgroundColor, const Color(0xfffffbfe));
    expect(expansion.textColor, const Color(0xff1d1b20));
    expect(expansion.collapsedTextColor, const Color(0xff49454f));
    expect(expansion.iconColor, const Color(0xff006a6a));
    expect(expansion.collapsedIconColor, const Color(0xff79747e));
    expect(expansion.shape, isA<RoundedRectangleBorder>());
    expect(expansion.collapsedShape, isA<RoundedRectangleBorder>());
    expect(expansion.clipBehavior, Clip.antiAlias);
    expect(expansion.controlAffinity, ListTileControlAffinity.leading);
    expect(expansion.dense, isTrue);
    expect(expansion.splashColor, const Color(0x33006a6a));
    expect(expansion.visualDensity, VisualDensity.compact);
    expect(expansion.minTileHeight, 52);
    expect(expansion.enableFeedback, isFalse);
    expect(expansion.enabled, isTrue);
    expect(
      expansion.expansionAnimationStyle?.duration,
      const Duration(milliseconds: 220),
    );
    expect(
      expansion.expansionAnimationStyle?.reverseDuration,
      const Duration(milliseconds: 140),
    );

    expansion.onExpansionChanged!(false);

    expect(actions.map((action) => action.name), [
      'tileTap',
      'tileLongPress',
      'tileFocus',
      'expanded',
    ]);
    expect(actions[2].payload, isTrue);
    expect(actions[3].payload, isFalse);
  });

  testWidgets('maps material expansion panel lists safely', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'ListView',
              'props': {
                'children': [
                  {
                    'type': 'ExpansionPanelList',
                    'props': {
                      'animationDuration': 180,
                      'expandedHeaderPadding': {
                        'left': 4,
                        'top': 6,
                        'right': 8,
                        'bottom': 10,
                      },
                      'dividerColor': '#123456',
                      'elevation': 5.7,
                      'expandIconColor': '#006a6a',
                      'materialGapSize': -4,
                      'onExpansionChanged': {
                        'type': 'Action',
                        'props': {'name': 'panelChanged'},
                      },
                      'children': [
                        {
                          'type': 'ExpansionPanel',
                          'props': {
                            'header': {
                              'type': 'Text',
                              'props': {'data': 'Panel A'},
                            },
                            'expandedHeader': {
                              'type': 'Text',
                              'props': {'data': 'Panel A open'},
                            },
                            'body': {
                              'type': 'Text',
                              'props': {'data': 'Panel A body'},
                            },
                            'isExpanded': true,
                            'canTapOnHeader': true,
                            'backgroundColor': '#ffffff',
                            'splashColor': '#33006a6a',
                            'highlightColor': '#22006a6a',
                          },
                        },
                        {
                          'type': 'ExpansionPanel',
                          'props': {
                            'title': {
                              'type': 'Text',
                              'props': {'data': 'Panel B'},
                            },
                            'content': {
                              'type': 'Text',
                              'props': {'data': 'Panel B body'},
                            },
                          },
                        },
                      ],
                    },
                  },
                  {
                    'type': 'ExpansionPanelListRadio',
                    'props': {
                      'initialOpenPanelValue': 'basic',
                      'elevation': -2,
                      'materialGapSize': 8,
                      'expansionCallback': {
                        'type': 'Action',
                        'props': {'name': 'radioPanelChanged'},
                      },
                      'children': [
                        {
                          'type': 'ExpansionPanelRadio',
                          'props': {
                            'value': 'basic',
                            'header': {
                              'type': 'Text',
                              'props': {'data': 'Basic'},
                            },
                            'body': {
                              'type': 'Text',
                              'props': {'data': 'Basic body'},
                            },
                          },
                        },
                        {
                          'type': 'ExpansionPanelRadio',
                          'props': {
                            'value': 'basic',
                            'header': {
                              'type': 'Text',
                              'props': {'data': 'Duplicate'},
                            },
                            'body': {
                              'type': 'Text',
                              'props': {'data': 'Duplicate body'},
                            },
                          },
                        },
                      ],
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    expect(find.text('Panel A open'), findsOneWidget);
    expect(find.text('Panel A body'), findsOneWidget);
    expect(find.text('Panel B'), findsOneWidget);
    expect(find.text('Basic body'), findsOneWidget);

    final lists = tester
        .widgetList<ExpansionPanelList>(find.byType(ExpansionPanelList))
        .toList();
    expect(lists, hasLength(2));

    final normalList = lists[0];
    expect(normalList.children, hasLength(2));
    expect(normalList.animationDuration, const Duration(milliseconds: 180));
    expect(
      normalList.expandedHeaderPadding,
      const EdgeInsets.fromLTRB(4, 6, 8, 10),
    );
    expect(normalList.dividerColor, const Color(0xff123456));
    expect(normalList.elevation, 6);
    expect(normalList.expandIconColor, const Color(0xff006a6a));
    expect(normalList.materialGapSize, 0);
    final firstPanel = normalList.children.first;
    expect(firstPanel.isExpanded, isTrue);
    expect(firstPanel.canTapOnHeader, isTrue);
    expect(firstPanel.backgroundColor, const Color(0xffffffff));
    expect(firstPanel.splashColor, const Color(0x33006a6a));
    expect(firstPanel.highlightColor, const Color(0x22006a6a));

    final radioList = lists[1];
    expect(radioList.children, hasLength(2));
    expect(radioList.initialOpenPanelValue, 'basic');
    expect(radioList.elevation, 0);
    expect(radioList.materialGapSize, 8);
    final radioPanels = radioList.children.cast<ExpansionPanelRadio>();
    expect(radioPanels.first.value, 'basic');
    expect(radioPanels.last.value, 'basic_1');

    normalList.expansionCallback!(0, false);
    radioList.expansionCallback!(1, true);

    expect(actions.map((action) => action.name), [
      'panelChanged',
      'radioPanelChanged',
    ]);
    expect(actions[0].payload, containsPair('index', 0));
    expect(actions[0].payload, containsPair('panelIndex', 0));
    expect(actions[0].payload, containsPair('isExpanded', false));
    expect(actions[0].payload, containsPair('expanded', false));
    expect(actions[0].payload, containsPair('value', null));
    expect(actions[1].payload, containsPair('index', 1));
    expect(actions[1].payload, containsPair('isExpanded', true));
    expect(actions[1].payload, containsPair('value', 'basic_1'));
  });

  testWidgets('maps rich material chip variants and callbacks', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Wrap',
              'props': {
                'children': [
                  {
                    'type': 'Chip',
                    'props': {
                      'label': {
                        'type': 'Text',
                        'props': {'data': 'Static'},
                      },
                      'avatar': {
                        'type': 'Icon',
                        'props': {'icon': 'tag'},
                      },
                      'labelStyle': {'fontSize': 14, 'fontWeight': 'w600'},
                      'labelPadding': {'horizontal': 6},
                      'deleteIcon': {
                        'type': 'Icon',
                        'props': {'icon': 'close'},
                      },
                      'deleteIconColor': '#6750a4',
                      'deleteButtonTooltipMessage': 'Remove static',
                      'side': {'color': '#79747e', 'width': 1.5},
                      'shape': 'stadium',
                      'clipBehavior': 'antiAlias',
                      'autofocus': true,
                      'color': '#f4eff4',
                      'backgroundColor': '#fffbfe',
                      'padding': {'horizontal': 10, 'vertical': 4},
                      'visualDensity': 'compact',
                      'tapTargetSize': 'shrinkWrap',
                      'elevation': -2,
                      'shadowColor': '#55000000',
                      'surfaceTintColor': '#d0bcff',
                      'iconTheme': {'color': '#006a6a', 'size': 18},
                      'avatarBoxConstraints': {'minWidth': 24, 'minHeight': 24},
                      'deleteIconBoxConstraints': {
                        'minWidth': 20,
                        'minHeight': 20,
                      },
                      'animationStyle': {
                        'enable': {'duration': 90},
                        'deleteDrawer': {'duration': 120},
                      },
                      'mouseCursor': 'click',
                      'onDeleted': {
                        'type': 'Action',
                        'props': {'name': 'deleteStatic'},
                      },
                    },
                  },
                  {
                    'type': 'ActionChip',
                    'props': {
                      'elevated': true,
                      'label': {
                        'type': 'Text',
                        'props': {'data': 'Action'},
                      },
                      'pressElevation': 6,
                      'tooltip': 'Run action',
                      'disabledColor': '#f4eff4',
                      'backgroundColor': '#e6fffb',
                      'onPressed': {
                        'type': 'Action',
                        'props': {'name': 'actionPressed'},
                      },
                    },
                  },
                  {
                    'type': 'FilterChip',
                    'props': {
                      'variant': 'elevated',
                      'label': {
                        'type': 'Text',
                        'props': {'data': 'Filter'},
                      },
                      'selected': true,
                      'selectedColor': '#d0bcff',
                      'selectedShadowColor': '#33000000',
                      'showCheckmark': true,
                      'checkmarkColor': '#1d1b20',
                      'avatarBorder': 'stadium',
                      'deleteIcon': {
                        'type': 'Icon',
                        'props': {'icon': 'close'},
                      },
                      'deleteTooltip': 'Remove filter',
                      'onSelected': {
                        'type': 'Action',
                        'props': {'name': 'filterSelected'},
                      },
                      'onDeleted': {
                        'type': 'Action',
                        'props': {'name': 'filterDeleted'},
                      },
                    },
                  },
                  {
                    'type': 'ChoiceChip',
                    'props': {
                      'elevated': true,
                      'label': {
                        'type': 'Text',
                        'props': {'data': 'Choice'},
                      },
                      'selected': false,
                      'disabledColor': '#eeeeee',
                      'onSelected': {
                        'type': 'Action',
                        'props': {'name': 'choiceSelected'},
                      },
                    },
                  },
                  {
                    'type': 'InputChip',
                    'props': {
                      'label': {
                        'type': 'Text',
                        'props': {'data': 'Input'},
                      },
                      'selected': true,
                      'enabled': true,
                      'onSelected': {
                        'type': 'Action',
                        'props': {'name': 'inputSelected'},
                      },
                      'onPressed': {
                        'type': 'Action',
                        'props': {'name': 'inputPressed'},
                      },
                      'onDeleted': {
                        'type': 'Action',
                        'props': {'name': 'inputDeleted'},
                      },
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final chip = tester.widgetList<Chip>(find.byType(Chip)).first;
    expect(chip.labelStyle?.fontSize, 14);
    expect(chip.labelStyle?.fontWeight, FontWeight.w600);
    expect(chip.labelPadding, const EdgeInsets.symmetric(horizontal: 6));
    expect(chip.deleteIconColor, const Color(0xff6750a4));
    expect(chip.deleteButtonTooltipMessage, 'Remove static');
    expect(chip.side?.color, const Color(0xff79747e));
    expect(chip.side?.width, 1.5);
    expect(chip.shape, isA<StadiumBorder>());
    expect(chip.clipBehavior, Clip.antiAlias);
    expect(chip.autofocus, isTrue);
    expect(chip.color?.resolve({}), const Color(0xfff4eff4));
    expect(chip.backgroundColor, const Color(0xfffffbfe));
    expect(
      chip.padding,
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
    expect(chip.visualDensity, VisualDensity.compact);
    expect(chip.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(chip.elevation, 0);
    expect(chip.shadowColor, const Color(0x55000000));
    expect(chip.surfaceTintColor, const Color(0xffd0bcff));
    expect(chip.iconTheme?.color, const Color(0xff006a6a));
    expect(chip.iconTheme?.size, 18);
    expect(
      chip.avatarBoxConstraints,
      const BoxConstraints(minWidth: 24, minHeight: 24),
    );
    expect(
      chip.deleteIconBoxConstraints,
      const BoxConstraints(minWidth: 20, minHeight: 20),
    );
    expect(
      chip.chipAnimationStyle?.enableAnimation?.duration,
      const Duration(milliseconds: 90),
    );
    expect(
      chip.chipAnimationStyle?.deleteDrawerAnimation?.duration,
      const Duration(milliseconds: 120),
    );
    expect(chip.mouseCursor, SystemMouseCursors.click);

    RawChip rawChip(String label) {
      return tester.widgetList<RawChip>(find.byType(RawChip)).singleWhere((
        chip,
      ) {
        final child = chip.label;
        return child is Text && child.data == label;
      });
    }

    final actionChip = rawChip('Action');
    expect(actionChip.onPressed, isNotNull);

    final filterChip = rawChip('Filter');
    expect(filterChip.selected, isTrue);
    expect(filterChip.selectedColor, const Color(0xffd0bcff));
    expect(filterChip.selectedShadowColor, const Color(0x33000000));
    expect(filterChip.showCheckmark, isTrue);
    expect(filterChip.checkmarkColor, const Color(0xff1d1b20));
    expect(filterChip.avatarBorder, isA<StadiumBorder>());
    expect(filterChip.deleteButtonTooltipMessage, 'Remove filter');

    final choiceChip = rawChip('Choice');
    expect(choiceChip.selected, isFalse);
    expect(choiceChip.disabledColor, const Color(0xffeeeeee));

    final inputChip = rawChip('Input');
    expect(inputChip.selected, isTrue);
    expect(inputChip.isEnabled, isTrue);
    expect(inputChip.onPressed, isNull);
    expect(inputChip.onSelected, isNotNull);

    chip.onDeleted!();
    actionChip.onPressed!();
    filterChip.onSelected!(false);
    filterChip.onDeleted!();
    choiceChip.onSelected!(true);
    inputChip.onSelected!(false);
    inputChip.onDeleted!();

    expect(actions.map((action) => action.name), [
      'deleteStatic',
      'actionPressed',
      'filterSelected',
      'filterDeleted',
      'choiceSelected',
      'inputSelected',
      'inputDeleted',
    ]);
    expect(actions[2].payload, isFalse);
    expect(actions[4].payload, isTrue);
    expect(actions[5].payload, isFalse);
  });

  testWidgets('maps rich material selection controls and callbacks', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'ListView',
              'props': {
                'children': [
                  {
                    'type': 'Switch',
                    'props': {
                      'value': true,
                      'adaptive': true,
                      'activeColor': '#006a6a',
                      'activeTrackColor': '#80cbc4',
                      'thumbColor': {
                        'selected': '#006a6a',
                        'default': '#49454f',
                      },
                      'trackOutlineWidth': {'default': 2},
                      'thumbIcon': {
                        'selected': {'icon': 'check', 'size': 16},
                      },
                      'tapTargetSize': 'shrinkWrap',
                      'dragStartBehavior': 'down',
                      'mouseCursor': 'click',
                      'overlayColor': '#33006a6a',
                      'splashRadius': 18,
                      'padding': {'horizontal': 8},
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'switchChanged'},
                      },
                      'onFocusChange': {
                        'type': 'Action',
                        'props': {'name': 'switchFocus'},
                      },
                    },
                  },
                  {
                    'type': 'Checkbox',
                    'props': {
                      'value': null,
                      'adaptive': true,
                      'tristate': true,
                      'fillColor': {'selected': '#006a6a'},
                      'checkColor': '#ffffff',
                      'tapTargetSize': 'shrinkWrap',
                      'visualDensity': 'compact',
                      'mouseCursor': 'click',
                      'shape': {'borderRadius': 4},
                      'side': {'color': '#79747e', 'width': 1.5},
                      'isError': true,
                      'semanticLabel': 'Accept terms',
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'checkboxChanged'},
                      },
                    },
                  },
                  {
                    'type': 'Radio',
                    'props': {
                      'value': 'a',
                      'groupValue': 'a',
                      'adaptive': true,
                      'toggleable': true,
                      'fillColor': {'selected': '#006a6a'},
                      'backgroundColor': {'default': '#fffbfe'},
                      'innerRadius': {'default': 5},
                      'side': {'color': '#79747e', 'width': 1.2},
                      'tapTargetSize': 'shrinkWrap',
                      'visualDensity': 'compact',
                      'mouseCursor': 'click',
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'radioChanged'},
                      },
                    },
                  },
                  {
                    'type': 'SwitchListTile',
                    'props': {
                      'adaptive': true,
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Wi-Fi'},
                      },
                      'value': false,
                      'selected': true,
                      'controlAffinity': 'leading',
                      'contentPadding': {'horizontal': 20},
                      'shape': {'borderRadius': 12},
                      'selectedTileColor': '#e6fffb',
                      'visualDensity': 'compact',
                      'enableFeedback': false,
                      'minTileHeight': 56,
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'switchTileChanged'},
                      },
                    },
                  },
                  {
                    'type': 'CheckboxListTile',
                    'props': {
                      'adaptive': true,
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Remember me'},
                      },
                      'value': true,
                      'selected': true,
                      'controlAffinity': 'trailing',
                      'checkboxShape': {'borderRadius': 3},
                      'checkboxScaleFactor': 1.2,
                      'titleAlignment': 'center',
                      'checkboxSemanticLabel': 'Remember checkbox',
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'checkboxTileChanged'},
                      },
                      'onFocusChange': {
                        'type': 'Action',
                        'props': {'name': 'checkboxTileFocus'},
                      },
                    },
                  },
                  {
                    'type': 'RadioListTile',
                    'props': {
                      'adaptive': true,
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Option B'},
                      },
                      'value': 'b',
                      'groupValue': 'a',
                      'toggleable': true,
                      'controlAffinity': 'leading',
                      'radioScaleFactor': 1.15,
                      'radioBackgroundColor': {'default': '#fffbfe'},
                      'radioInnerRadius': {'default': 4.5},
                      'radioSide': {'color': '#79747e', 'width': 1},
                      'titleAlignment': 'top',
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'radioTileChanged'},
                      },
                      'onFocusChange': {
                        'type': 'Action',
                        'props': {'name': 'radioTileFocus'},
                      },
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final switchWidget = tester.widgetList<Switch>(find.byType(Switch)).first;
    expect(switchWidget.value, isTrue);
    expect(switchWidget.activeThumbColor, const Color(0xff006a6a));
    expect(switchWidget.activeTrackColor, const Color(0xff80cbc4));
    expect(
      switchWidget.thumbColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(switchWidget.trackOutlineWidth?.resolve({}), 2);
    expect(
      switchWidget.thumbIcon?.resolve({WidgetState.selected})?.icon,
      Icons.check,
    );
    expect(
      switchWidget.materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(switchWidget.dragStartBehavior, DragStartBehavior.down);
    expect(switchWidget.mouseCursor, SystemMouseCursors.click);
    expect(switchWidget.splashRadius, 18);
    expect(switchWidget.padding, const EdgeInsets.symmetric(horizontal: 8));

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isNull);
    expect(checkbox.tristate, isTrue);
    expect(
      checkbox.fillColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(checkbox.checkColor, const Color(0xffffffff));
    expect(checkbox.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(checkbox.visualDensity, VisualDensity.compact);
    expect(checkbox.shape, isA<RoundedRectangleBorder>());
    expect(checkbox.side?.color, const Color(0xff79747e));
    expect(checkbox.isError, isTrue);
    expect(checkbox.semanticLabel, 'Accept terms');

    final radio = tester
        .widgetList<Radio<Object?>>(
          find.byWidgetPredicate((widget) => widget is Radio<Object?>),
        )
        .first;
    expect(radio.value, 'a');
    expect(radio.toggleable, isTrue);
    expect(
      radio.fillColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(radio.backgroundColor?.resolve({}), const Color(0xfffffbfe));
    expect(radio.innerRadius?.resolve({}), 5);
    expect(radio.side?.color, const Color(0xff79747e));

    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.selected, isTrue);
    expect(switchTile.controlAffinity, ListTileControlAffinity.leading);
    expect(
      switchTile.contentPadding,
      const EdgeInsets.symmetric(horizontal: 20),
    );
    expect(switchTile.shape, isA<RoundedRectangleBorder>());
    expect(switchTile.selectedTileColor, const Color(0xffe6fffb));
    expect(switchTile.visualDensity, VisualDensity.compact);
    expect(switchTile.enableFeedback, isFalse);
    expect(switchTile.minTileHeight, 56);

    final checkboxTile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(checkboxTile.selected, isTrue);
    expect(checkboxTile.controlAffinity, ListTileControlAffinity.trailing);
    expect(checkboxTile.checkboxShape, isA<RoundedRectangleBorder>());
    expect(checkboxTile.checkboxScaleFactor, 1.2);
    expect(checkboxTile.titleAlignment, ListTileTitleAlignment.center);
    expect(checkboxTile.checkboxSemanticLabel, 'Remember checkbox');

    final radioTile = tester.widget<RadioListTile<Object?>>(
      find.byWidgetPredicate((widget) => widget is RadioListTile<Object?>),
    );
    expect(radioTile.value, 'b');
    expect(radioTile.toggleable, isTrue);
    expect(radioTile.controlAffinity, ListTileControlAffinity.leading);
    expect(radioTile.radioScaleFactor, 1.15);
    expect(
      radioTile.radioBackgroundColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(radioTile.radioInnerRadius?.resolve({}), 4.5);
    expect(radioTile.radioSide?.color, const Color(0xff79747e));
    expect(radioTile.titleAlignment, ListTileTitleAlignment.top);

    actions.clear();
    switchWidget.onChanged!(false);
    switchWidget.onFocusChange!(true);
    checkbox.onChanged!(true);
    switchTile.onChanged!(true);
    checkboxTile.onChanged!(false);
    checkboxTile.onFocusChange!(true);
    final groups = tester
        .widgetList<RadioGroup<Object?>>(
          find.byWidgetPredicate((widget) => widget is RadioGroup<Object?>),
        )
        .toList();
    groups[0].onChanged('c');
    groups[1].onChanged('b');
    radioTile.onFocusChange!(true);

    expect(actions.map((action) => action.name), [
      'switchChanged',
      'switchFocus',
      'checkboxChanged',
      'switchTileChanged',
      'checkboxTileChanged',
      'checkboxTileFocus',
      'radioChanged',
      'radioTileChanged',
      'radioTileFocus',
    ]);
    expect(actions[0].payload, isFalse);
    expect(actions[1].payload, isTrue);
    expect(actions[2].payload, isTrue);
    expect(actions[6].payload, 'c');
    expect(actions[7].payload, 'b');
  });

  testWidgets('maps rich material sliders and callbacks safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'Slider',
                    'props': {
                      'value': 150,
                      'secondaryTrackValue': -10,
                      'min': 0,
                      'max': 100,
                      'divisions': 20,
                      'label': '100',
                      'activeColor': '#006a6a',
                      'inactiveColor': '#e7e0ec',
                      'secondaryActiveColor': '#80cbc4',
                      'thumbColor': '#006a6a',
                      'overlayColor': '#33006a6a',
                      'mouseCursor': 'click',
                      'semanticFormatter': {
                        'prefix': 'Value ',
                        'suffix': '%',
                        'decimals': 1,
                      },
                      'autofocus': true,
                      'allowedInteraction': 'tapOnly',
                      'padding': {'horizontal': 12},
                      'showValueIndicator': 'alwaysVisible',
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'sliderChanged'},
                      },
                      'onChangeStart': {
                        'type': 'Action',
                        'props': {'name': 'sliderStart'},
                      },
                      'onChangeEnd': {
                        'type': 'Action',
                        'props': {'name': 'sliderEnd'},
                      },
                    },
                  },
                  {
                    'type': 'Slider',
                    'props': {'adaptive': true, 'value': 0.25},
                  },
                  {
                    'type': 'RangeSlider',
                    'props': {
                      'values': [-25, 125],
                      'min': 0,
                      'max': 100,
                      'divisions': 10,
                      'labels': ['Low', 'High'],
                      'activeColor': '#6750a4',
                      'inactiveColor': '#e7e0ec',
                      'overlayColor': '#336750a4',
                      'mouseCursor': {'default': 'click'},
                      'semanticFormatter': 'Range {round}',
                      'padding': {'vertical': 4},
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'rangeChanged'},
                      },
                      'onChangeStart': {
                        'type': 'Action',
                        'props': {'name': 'rangeStart'},
                      },
                      'onChangeEnd': {
                        'type': 'Action',
                        'props': {'name': 'rangeEnd'},
                      },
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final slider = tester.widget<Slider>(find.byType(Slider).first);
    expect(slider.value, 100);
    expect(slider.secondaryTrackValue, 0);
    expect(slider.min, 0);
    expect(slider.max, 100);
    expect(slider.divisions, 20);
    expect(slider.label, '100');
    expect(slider.activeColor, const Color(0xff006a6a));
    expect(slider.inactiveColor, const Color(0xffe7e0ec));
    expect(slider.secondaryActiveColor, const Color(0xff80cbc4));
    expect(slider.thumbColor, const Color(0xff006a6a));
    expect(slider.overlayColor?.resolve({}), const Color(0x33006a6a));
    expect(slider.mouseCursor, SystemMouseCursors.click);
    expect(slider.semanticFormatterCallback!(42), 'Value 42.0%');
    expect(slider.allowedInteraction, SliderInteraction.tapOnly);
    expect(slider.padding, const EdgeInsets.symmetric(horizontal: 12));
    expect(slider.showValueIndicator, ShowValueIndicator.alwaysVisible);

    final range = tester.widget<RangeSlider>(find.byType(RangeSlider));
    expect(range.values, const RangeValues(0, 100));
    expect(range.divisions, 10);
    expect(range.labels, const RangeLabels('Low', 'High'));
    expect(range.activeColor, const Color(0xff6750a4));
    expect(range.inactiveColor, const Color(0xffe7e0ec));
    expect(range.overlayColor?.resolve({}), const Color(0x336750a4));
    expect(range.mouseCursor?.resolve({}), SystemMouseCursors.click);
    expect(range.semanticFormatterCallback!(42), 'Range 42');
    expect(range.padding, const EdgeInsets.symmetric(vertical: 4));

    slider.onChangeStart!(12);
    slider.onChanged!(34);
    slider.onChangeEnd!(56);
    range.onChangeStart!(const RangeValues(1, 2));
    range.onChanged!(const RangeValues(3, 4));
    range.onChangeEnd!(const RangeValues(5, 6));

    expect(actions.map((action) => action.name), [
      'sliderStart',
      'sliderChanged',
      'sliderEnd',
      'rangeStart',
      'rangeChanged',
      'rangeEnd',
    ]);
    expect(actions[1].payload, 34);
    expect(actions[4].payload, {'start': 3.0, 'end': 4.0});
  });

  testWidgets('maps rich material segmented buttons and callbacks safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'SegmentedButton',
                    'props': {
                      'segments': [
                        {
                          'value': 'day',
                          'icon': {
                            'type': 'Icon',
                            'props': {'icon': 'today'},
                          },
                          'label': {
                            'type': 'Text',
                            'props': {'data': 'Day'},
                          },
                          'tooltip': 'Day view',
                        },
                        {
                          'value': 'week',
                          'label': {
                            'type': 'Text',
                            'props': {'data': 'Week'},
                          },
                        },
                        {
                          'value': 'month',
                          'label': {
                            'type': 'Text',
                            'props': {'data': 'Month'},
                          },
                          'enabled': false,
                        },
                      ],
                      'selected': ['week', 'missing'],
                      'multiSelectionEnabled': false,
                      'showSelectedIcon': true,
                      'selectedIcon': {
                        'type': 'Icon',
                        'props': {'icon': 'check_circle'},
                      },
                      'direction': 'vertical',
                      'expandedInsets': {'horizontal': 12, 'vertical': 4},
                      'style': {
                        'backgroundColor': '#f4eff4',
                        'foregroundColor': '#1d1b20',
                        'padding': {'horizontal': 14, 'vertical': 8},
                        'shape': {'borderRadius': 12},
                      },
                      'onSelectionChanged': {
                        'type': 'Action',
                        'props': {'name': 'segmentChanged'},
                      },
                    },
                  },
                  {
                    'type': 'SegmentedButton',
                    'props': {
                      'segments': [
                        {'value': 'a', 'label': 'A'},
                        {'value': 'b', 'label': 'B'},
                      ],
                      'selected': ['a', 'b'],
                      'multi': true,
                      'emptySelectionAllowed': true,
                      'showSelectedIcon': false,
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'multiSegmentChanged'},
                      },
                    },
                  },
                  {
                    'type': 'SegmentedButton',
                    'props': {'segments': []},
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final buttons = tester
        .widgetList<SegmentedButton<Object>>(
          find.byType(SegmentedButton<Object>),
        )
        .toList();
    expect(buttons, hasLength(2));

    final single = buttons.first;
    expect(single.segments, hasLength(3));
    expect(single.segments.first.value, 'day');
    expect(single.segments.first.tooltip, 'Day view');
    expect(single.segments.last.enabled, isFalse);
    expect(single.selected, {'week'});
    expect(single.multiSelectionEnabled, isFalse);
    expect(single.emptySelectionAllowed, isFalse);
    expect(single.showSelectedIcon, isTrue);
    expect(single.selectedIcon, isA<Icon>());
    expect((single.selectedIcon! as Icon).icon, Icons.check_circle);
    expect(single.direction, Axis.vertical);
    expect(
      single.expandedInsets,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
    expect(single.style?.backgroundColor?.resolve({}), const Color(0xfff4eff4));
    expect(single.style?.foregroundColor?.resolve({}), const Color(0xff1d1b20));
    expect(single.style?.shape?.resolve({}), isA<RoundedRectangleBorder>());

    final multi = buttons.last;
    expect(multi.selected, {'a', 'b'});
    expect(multi.multiSelectionEnabled, isTrue);
    expect(multi.emptySelectionAllowed, isTrue);
    expect(multi.showSelectedIcon, isFalse);

    single.onSelectionChanged!({'day'});
    multi.onSelectionChanged!(<Object>{});

    expect(actions.map((action) => action.name), [
      'segmentChanged',
      'multiSegmentChanged',
    ]);
    expect(actions[0].payload, ['day']);
    expect(actions[1].payload, isEmpty);
  });

  testWidgets('maps material toggle buttons and callbacks safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'ToggleButtons',
                    'props': {
                      'children': [
                        {
                          'type': 'Icon',
                          'props': {'icon': 'settings'},
                        },
                        {
                          'type': 'Icon',
                          'props': {'icon': 'grid_view'},
                        },
                        {
                          'type': 'Text',
                          'props': {'data': 'More'},
                        },
                      ],
                      'isSelected': [true, false],
                      'mouseCursor': 'click',
                      'tapTargetSize': 'shrinkWrap',
                      'textStyle': {'fontSize': 13, 'fontWeight': 'w600'},
                      'constraints': {'minWidth': 44, 'minHeight': 40},
                      'color': '#1d1b20',
                      'selectedColor': '#006a6a',
                      'disabledColor': '#cac4d0',
                      'fillColor': '#11006a6a',
                      'focusColor': '#22006a6a',
                      'highlightColor': '#11006a6a',
                      'hoverColor': '#11006a6a',
                      'splashColor': '#22006a6a',
                      'borderColor': '#79747e',
                      'selectedBorderColor': '#006a6a',
                      'disabledBorderColor': '#cac4d0',
                      'borderRadius': 18,
                      'borderWidth': -2,
                      'onPressed': {
                        'type': 'Action',
                        'props': {'name': 'togglePressed'},
                      },
                    },
                  },
                  {
                    'type': 'ToggleButtons',
                    'props': {
                      'children': [
                        {
                          'type': 'Text',
                          'props': {'data': 'A'},
                        },
                        {
                          'type': 'Text',
                          'props': {'data': 'B'},
                        },
                      ],
                      'selected': [1],
                      'direction': 'vertical',
                      'verticalDirection': 'up',
                      'renderBorder': false,
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'verticalToggle'},
                      },
                    },
                  },
                  {
                    'type': 'ToggleButtons',
                    'props': {'children': []},
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final toggles = tester
        .widgetList<ToggleButtons>(find.byType(ToggleButtons))
        .toList();
    expect(toggles, hasLength(2));

    final first = toggles.first;
    expect(first.children, hasLength(3));
    expect(first.isSelected, [true, false, false]);
    expect(first.mouseCursor, SystemMouseCursors.click);
    expect(first.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(first.textStyle?.fontSize, 13);
    expect(first.textStyle?.fontWeight, FontWeight.w600);
    expect(
      first.constraints,
      const BoxConstraints(minWidth: 44, minHeight: 40),
    );
    expect(first.color, const Color(0xff1d1b20));
    expect(first.selectedColor, const Color(0xff006a6a));
    expect(first.disabledColor, const Color(0xffcac4d0));
    expect(first.fillColor, const Color(0x11006a6a));
    expect(first.focusColor, const Color(0x22006a6a));
    expect(first.highlightColor, const Color(0x11006a6a));
    expect(first.hoverColor, const Color(0x11006a6a));
    expect(first.splashColor, const Color(0x22006a6a));
    expect(first.borderColor, const Color(0xff79747e));
    expect(first.selectedBorderColor, const Color(0xff006a6a));
    expect(first.disabledBorderColor, const Color(0xffcac4d0));
    expect(first.borderRadius, BorderRadius.circular(18));
    expect(first.borderWidth, 0);
    expect(first.direction, Axis.horizontal);
    expect(first.verticalDirection, VerticalDirection.down);

    final second = toggles.last;
    expect(second.isSelected, [false, true]);
    expect(second.direction, Axis.vertical);
    expect(second.verticalDirection, VerticalDirection.up);
    expect(second.renderBorder, isFalse);

    first.onPressed!(1);
    second.onPressed!(0);

    expect(actions.map((action) => action.name), [
      'togglePressed',
      'verticalToggle',
    ]);
    expect(actions.first.payload, {
      'index': 1,
      'selected': true,
      'isSelected': [true, true, false],
      'selectedIndexes': [0, 1],
    });
    expect(actions.last.payload, {
      'index': 0,
      'selected': true,
      'isSelected': [true, true],
      'selectedIndexes': [0, 1],
    });
  });

  testWidgets('maps rich material menus and dropdowns safely', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'DropdownButton',
                    'props': {
                      'value': 'missing',
                      'hint': 'Choose',
                      'disabledHint': 'Disabled',
                      'isExpanded': true,
                      'isDense': true,
                      'itemHeight': 12,
                      'menuWidth': 220,
                      'menuMaxHeight': 260,
                      'elevation': 6,
                      'style': {'fontSize': 14, 'color': '#1d1b20'},
                      'icon': {
                        'type': 'Icon',
                        'props': {'icon': 'expand_more'},
                      },
                      'iconEnabledColor': '#006a6a',
                      'iconDisabledColor': '#79747e',
                      'iconSize': 20,
                      'focusColor': '#e7e0ec',
                      'autofocus': true,
                      'dropdownColor': '#fffbfe',
                      'enableFeedback': false,
                      'alignment': 'centerRight',
                      'borderRadius': 12,
                      'padding': {'horizontal': 8},
                      'barrierDismissible': false,
                      'mouseCursor': 'click',
                      'dropdownMenuItemMouseCursor': 'basic',
                      'onTap': {
                        'type': 'Action',
                        'props': {'name': 'dropdownTap'},
                      },
                      'onChanged': {
                        'type': 'Action',
                        'props': {'name': 'dropdownChanged'},
                      },
                      'items': [
                        {
                          'value': 'one',
                          'label': 'One',
                          'alignment': 'centerLeft',
                          'onTap': {
                            'type': 'Action',
                            'props': {'name': 'dropdownItemTap'},
                          },
                        },
                        {'value': 'one', 'label': 'Duplicate'},
                        {'value': 'two', 'label': 'Two', 'enabled': false},
                      ],
                    },
                  },
                  {
                    'type': 'DropdownMenu',
                    'props': {
                      'initialSelection': 'compact',
                      'width': 240,
                      'menuHeight': 220,
                      'leadingIcon': {
                        'type': 'Icon',
                        'props': {'icon': 'tune'},
                      },
                      'trailingIcon': {
                        'type': 'Icon',
                        'props': {'icon': 'arrow_drop_down'},
                      },
                      'selectedTrailingIcon': {
                        'type': 'Icon',
                        'props': {'icon': 'arrow_drop_up'},
                      },
                      'label': 'Density',
                      'hintText': 'Select density',
                      'helperText': 'Affects list density',
                      'enableFilter': true,
                      'enableSearch': false,
                      'keyboardType': 'text',
                      'textStyle': {'fontSize': 13},
                      'textAlign': 'center',
                      'inputDecorationTheme': {
                        'filled': true,
                        'fillColor': '#f4eff4',
                      },
                      'menuStyle': {
                        'backgroundColor': '#fffbfe',
                        'padding': {'vertical': 4},
                        'shape': {'borderRadius': 16},
                        'alignment': 'bottomLeft',
                      },
                      'requestFocusOnTap': false,
                      'selectOnly': true,
                      'expandedInsets': {'horizontal': 6},
                      'alignmentOffset': [4, 8],
                      'closeBehavior': 'self',
                      'maxLines': 2,
                      'textInputAction': 'done',
                      'cursorHeight': 18,
                      'restorationId': 'density-menu',
                      'scrollPadding': {
                        'left': 1,
                        'top': 2,
                        'right': 3,
                        'bottom': 4,
                      },
                      'onSelected': {
                        'type': 'Action',
                        'props': {'name': 'densitySelected'},
                      },
                      'dropdownMenuEntries': [
                        {
                          'value': 'compact',
                          'label': 'Compact',
                          'leadingIcon': {
                            'type': 'Icon',
                            'props': {'icon': 'view_headline'},
                          },
                          'trailingIcon': {
                            'type': 'Icon',
                            'props': {'icon': 'check'},
                          },
                          'style': {'foregroundColor': '#006a6a'},
                        },
                        {
                          'value': 'comfortable',
                          'labelWidget': {
                            'type': 'Text',
                            'props': {'data': 'Comfortable'},
                          },
                          'label': 'Comfortable',
                          'enabled': false,
                        },
                      ],
                    },
                  },
                  {
                    'type': 'PopupMenuButton',
                    'props': {
                      'child': {
                        'type': 'Text',
                        'props': {'data': 'Popup'},
                      },
                      'initialValue': 'copy',
                      'tooltip': 'More actions',
                      'elevation': 5,
                      'shadowColor': '#33000000',
                      'surfaceTintColor': '#fffbfe',
                      'padding': {'horizontal': 6, 'vertical': 4},
                      'menuPadding': {'vertical': 2},
                      'borderRadius': 10,
                      'splashRadius': 18,
                      'offset': [3, 7],
                      'shape': {'borderRadius': 14},
                      'color': '#fffbfe',
                      'iconColor': '#006a6a',
                      'enableFeedback': false,
                      'constraints': {'minWidth': 120, 'maxWidth': 240},
                      'position': 'under',
                      'clipBehavior': 'antiAlias',
                      'useRootNavigator': true,
                      'animationStyle': {'duration': 120, 'curve': 'easeOut'},
                      'style': {
                        'backgroundColor': '#f4eff4',
                        'foregroundColor': '#1d1b20',
                      },
                      'requestFocus': false,
                      'onOpened': {
                        'type': 'Action',
                        'props': {'name': 'popupOpened'},
                      },
                      'onSelected': {
                        'type': 'Action',
                        'props': {'name': 'popupSelected'},
                      },
                      'onCanceled': {
                        'type': 'Action',
                        'props': {'name': 'popupCanceled'},
                      },
                      'items': [
                        {
                          'value': 'copy',
                          'label': 'Copy',
                          'checked': true,
                          'padding': {'horizontal': 12},
                        },
                        {'divider': true, 'height': 18, 'color': '#79747e'},
                        {
                          'value': 'delete',
                          'label': 'Delete',
                          'height': 52,
                          'textStyle': {'fontWeight': 'w600'},
                          'labelTextStyle': {
                            'disabled': {'color': '#79747e'},
                            'default': {'color': '#b3261e'},
                          },
                          'mouseCursor': 'click',
                          'onTap': {
                            'type': 'Action',
                            'props': {'name': 'popupItemTap'},
                          },
                        },
                      ],
                    },
                  },
                  {
                    'type': 'MenuBar',
                    'props': {
                      'style': {
                        'backgroundColor': '#f4eff4',
                        'padding': {'horizontal': 4},
                      },
                      'children': [
                        {
                          'type': 'SubmenuButton',
                          'props': {
                            'child': 'More',
                            'menuStyle': {
                              'backgroundColor': '#fffbfe',
                              'shape': {'borderRadius': 12},
                            },
                            'alignmentOffset': [1, 2],
                            'hoverOpenDelay': 90,
                            'animated': true,
                            'onOpen': {
                              'type': 'Action',
                              'props': {'name': 'submenuOpen'},
                            },
                            'onClose': {
                              'type': 'Action',
                              'props': {'name': 'submenuClose'},
                            },
                            'onHover': {
                              'type': 'Action',
                              'props': {'name': 'submenuHover'},
                            },
                            'onFocusChange': {
                              'type': 'Action',
                              'props': {'name': 'submenuFocus'},
                            },
                            'menuChildren': [
                              {
                                'type': 'MenuItemButton',
                                'props': {
                                  'label': 'Save',
                                  'requestFocusOnHover': false,
                                  'autofocus': true,
                                  'semanticsLabel': 'Save file',
                                  'overflowAxis': 'vertical',
                                  'onHover': {
                                    'type': 'Action',
                                    'props': {'name': 'menuHover'},
                                  },
                                  'onFocusChange': {
                                    'type': 'Action',
                                    'props': {'name': 'menuFocus'},
                                  },
                                  'onPressed': {
                                    'type': 'Action',
                                    'props': {'name': 'menuPressed'},
                                  },
                                },
                              },
                              {
                                'type': 'CheckboxMenuButton',
                                'props': {
                                  'value': true,
                                  'label': 'Enabled',
                                  'onHover': {
                                    'type': 'Action',
                                    'props': {'name': 'checkboxMenuHover'},
                                  },
                                  'onFocusChange': {
                                    'type': 'Action',
                                    'props': {'name': 'checkboxMenuFocus'},
                                  },
                                  'onChanged': {
                                    'type': 'Action',
                                    'props': {'name': 'checkboxMenuChanged'},
                                  },
                                },
                              },
                              {
                                'type': 'RadioMenuButton',
                                'props': {
                                  'value': 'a',
                                  'groupValue': 'b',
                                  'label': 'Choice A',
                                  'onHover': {
                                    'type': 'Action',
                                    'props': {'name': 'radioMenuHover'},
                                  },
                                  'onFocusChange': {
                                    'type': 'Action',
                                    'props': {'name': 'radioMenuFocus'},
                                  },
                                  'onChanged': {
                                    'type': 'Action',
                                    'props': {'name': 'radioMenuChanged'},
                                  },
                                },
                              },
                            ],
                          },
                        },
                      ],
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    final dropdownButton = tester.widget<DropdownButton<Object?>>(
      find.byType(DropdownButton<Object?>),
    );
    expect(dropdownButton.value, isNull);
    expect(dropdownButton.hint, isA<Text>());
    expect(dropdownButton.disabledHint, isA<Text>());
    expect(dropdownButton.isExpanded, isTrue);
    expect(dropdownButton.isDense, isTrue);
    expect(dropdownButton.itemHeight, kMinInteractiveDimension);
    expect(dropdownButton.menuWidth, 220);
    expect(dropdownButton.menuMaxHeight, 260);
    expect(dropdownButton.elevation, 6);
    expect(dropdownButton.style?.fontSize, 14);
    expect(dropdownButton.icon, isA<Icon>());
    expect(dropdownButton.iconEnabledColor, const Color(0xff006a6a));
    expect(dropdownButton.iconDisabledColor, const Color(0xff79747e));
    expect(dropdownButton.iconSize, 20);
    expect(dropdownButton.focusColor, const Color(0xffe7e0ec));
    expect(dropdownButton.autofocus, isTrue);
    expect(dropdownButton.dropdownColor, const Color(0xfffffbfe));
    expect(dropdownButton.enableFeedback, isFalse);
    expect(dropdownButton.alignment, Alignment.centerRight);
    expect(dropdownButton.borderRadius, BorderRadius.circular(12));
    expect(dropdownButton.padding, const EdgeInsets.symmetric(horizontal: 8));
    expect(dropdownButton.barrierDismissible, isFalse);
    expect(dropdownButton.mouseCursor, SystemMouseCursors.click);
    expect(
      dropdownButton.dropdownMenuItemMouseCursor,
      SystemMouseCursors.basic,
    );
    expect(dropdownButton.items, hasLength(2));
    expect(dropdownButton.items!.last.enabled, isFalse);

    dropdownButton.onTap!();
    dropdownButton.items!.first.onTap!();
    dropdownButton.onChanged!('one');

    final dropdownMenu = tester.widget<DropdownMenu<Object?>>(
      find.byType(DropdownMenu<Object?>),
    );
    expect(dropdownMenu.initialSelection, 'compact');
    expect(dropdownMenu.width, 240);
    expect(dropdownMenu.menuHeight, 220);
    expect(dropdownMenu.leadingIcon, isA<Icon>());
    expect(dropdownMenu.trailingIcon, isA<Icon>());
    expect(dropdownMenu.selectedTrailingIcon, isA<Icon>());
    expect(dropdownMenu.label, isA<Text>());
    expect(dropdownMenu.hintText, 'Select density');
    expect(dropdownMenu.helperText, 'Affects list density');
    expect(dropdownMenu.enableFilter, isTrue);
    expect(dropdownMenu.enableSearch, isFalse);
    expect(dropdownMenu.keyboardType, TextInputType.text);
    expect(dropdownMenu.textStyle?.fontSize, 13);
    expect(dropdownMenu.textAlign, TextAlign.center);
    expect(dropdownMenu.inputDecorationTheme?.filled, isTrue);
    expect(
      dropdownMenu.menuStyle?.backgroundColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(dropdownMenu.requestFocusOnTap, isFalse);
    expect(dropdownMenu.selectOnly, isTrue);
    expect(
      dropdownMenu.expandedInsets,
      const EdgeInsets.symmetric(horizontal: 6),
    );
    expect(dropdownMenu.alignmentOffset, const Offset(4, 8));
    expect(dropdownMenu.closeBehavior, DropdownMenuCloseBehavior.self);
    expect(dropdownMenu.maxLines, 2);
    expect(dropdownMenu.textInputAction, TextInputAction.done);
    expect(dropdownMenu.cursorHeight, 18);
    expect(dropdownMenu.restorationId, 'density-menu');
    expect(dropdownMenu.scrollPadding, const EdgeInsets.fromLTRB(1, 2, 3, 4));
    expect(dropdownMenu.dropdownMenuEntries, hasLength(2));
    expect(dropdownMenu.dropdownMenuEntries.first.label, 'Compact');
    expect(dropdownMenu.dropdownMenuEntries.first.leadingIcon, isA<Icon>());
    expect(dropdownMenu.dropdownMenuEntries.first.trailingIcon, isA<Icon>());
    expect(dropdownMenu.dropdownMenuEntries.last.enabled, isFalse);
    expect(dropdownMenu.dropdownMenuEntries.last.labelWidget, isA<Text>());
    dropdownMenu.onSelected!('comfortable');

    final popup = tester.widget<PopupMenuButton<Object?>>(
      find.byType(PopupMenuButton<Object?>),
    );
    expect(popup.initialValue, 'copy');
    expect(popup.tooltip, 'More actions');
    expect(popup.elevation, 5);
    expect(popup.shadowColor, const Color(0x33000000));
    expect(popup.surfaceTintColor, const Color(0xfffffbfe));
    expect(
      popup.padding,
      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
    expect(popup.menuPadding, const EdgeInsets.symmetric(vertical: 2));
    expect(popup.borderRadius, BorderRadius.circular(10));
    expect(popup.splashRadius, 18);
    expect(popup.offset, const Offset(3, 7));
    expect(popup.shape, isA<RoundedRectangleBorder>());
    expect(popup.color, const Color(0xfffffbfe));
    expect(popup.iconColor, const Color(0xff006a6a));
    expect(popup.enableFeedback, isFalse);
    expect(popup.constraints?.minWidth, 120);
    expect(popup.position, PopupMenuPosition.under);
    expect(popup.clipBehavior, Clip.antiAlias);
    expect(popup.useRootNavigator, isTrue);
    expect(
      popup.popUpAnimationStyle?.duration,
      const Duration(milliseconds: 120),
    );
    expect(popup.style?.backgroundColor?.resolve({}), const Color(0xfff4eff4));
    expect(popup.requestFocus, isFalse);

    final entries = popup.itemBuilder(
      tester.element(find.byType(PopupMenuButton<Object?>)),
    );
    expect(entries, hasLength(3));
    expect(entries[0], isA<CheckedPopupMenuItem<Object?>>());
    expect(entries[1], isA<PopupMenuDivider>());
    expect(entries[2], isA<PopupMenuItem<Object?>>());
    final checked = entries[0] as CheckedPopupMenuItem<Object?>;
    expect(checked.checked, isTrue);
    expect(checked.padding, const EdgeInsets.symmetric(horizontal: 12));
    final divider = entries[1] as PopupMenuDivider;
    expect(divider.height, 18);
    expect(divider.color, const Color(0xff79747e));
    final deleteItem = entries[2] as PopupMenuItem<Object?>;
    expect(deleteItem.value, 'delete');
    expect(deleteItem.height, 52);
    expect(deleteItem.textStyle?.fontWeight, FontWeight.w600);
    expect(
      deleteItem.labelTextStyle?.resolve({WidgetState.disabled})?.color,
      const Color(0xff79747e),
    );
    expect(deleteItem.mouseCursor, SystemMouseCursors.click);
    popup.onOpened!();
    popup.onSelected!('copy');
    popup.onCanceled!();
    deleteItem.onTap!();

    final menuBar = tester.widget<MenuBar>(find.byType(MenuBar));
    expect(
      menuBar.style?.backgroundColor?.resolve({}),
      const Color(0xfff4eff4),
    );
    final submenu = tester.widget<SubmenuButton>(find.byType(SubmenuButton));
    expect(
      submenu.menuStyle?.backgroundColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(submenu.alignmentOffset, const Offset(1, 2));
    expect(submenu.hoverOpenDelay, Duration.zero);
    expect(submenu.animated, isTrue);
    submenu.onOpen!();
    submenu.onClose!();
    submenu.onHover!(true);
    submenu.onFocusChange!(false);

    final menuItem = submenu.menuChildren[0] as MenuItemButton;
    expect(menuItem.requestFocusOnHover, isFalse);
    expect(menuItem.autofocus, isTrue);
    expect(menuItem.semanticsLabel, 'Save file');
    expect(menuItem.overflowAxis, Axis.vertical);
    menuItem.onHover!(true);
    menuItem.onFocusChange!(false);
    menuItem.onPressed!();

    final checkboxMenu = submenu.menuChildren[1] as CheckboxMenuButton;
    checkboxMenu.onHover!(true);
    checkboxMenu.onFocusChange!(false);
    checkboxMenu.onChanged!(false);

    final radioMenu = submenu.menuChildren[2] as RadioMenuButton<Object?>;
    radioMenu.onHover!(true);
    radioMenu.onFocusChange!(false);
    radioMenu.onChanged!('a');

    expect(actions.map((action) => action.name), [
      'dropdownTap',
      'dropdownItemTap',
      'dropdownChanged',
      'densitySelected',
      'popupOpened',
      'popupSelected',
      'popupCanceled',
      'popupItemTap',
      'submenuOpen',
      'submenuClose',
      'submenuHover',
      'submenuFocus',
      'menuHover',
      'menuFocus',
      'menuPressed',
      'checkboxMenuHover',
      'checkboxMenuFocus',
      'checkboxMenuChanged',
      'radioMenuHover',
      'radioMenuFocus',
      'radioMenuChanged',
    ]);
    expect(actions[2].payload, 'one');
    expect(actions[3].payload, 'comfortable');
    expect(actions[5].payload, 'copy');
    expect(actions[10].payload, isTrue);
    expect(actions[17].payload, isFalse);
    expect(actions[20].payload, 'a');
  });

  testWidgets('maps material progress and refresh indicators safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final completer = Completer<void>();
    final renderer = AppletRenderer(
      dispatchAction: (action) {
        actions.add(action);
        if (action.name == 'refresh') {
          return completer.future;
        }
      },
    );

    Map<String, Object?> refreshSpec(String label, Map<String, Object?> props) {
      return {
        'type': 'SizedBox',
        'props': {
          'height': 100,
          'child': {
            'type': 'RefreshIndicator',
            'props': {
              ...props,
              'child': {
                'type': 'ListView',
                'props': {
                  'children': [
                    {
                      'type': 'Text',
                      'props': {'data': label},
                    },
                  ],
                },
              },
            },
          },
        },
      };
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Column',
              'props': {
                'children': [
                  {
                    'type': 'LinearProgressIndicator',
                    'props': {
                      'value': -0.2,
                      'backgroundColor': '#e7e0ec',
                      'color': '#006a6a',
                      'valueColor': '#6750a4',
                      'minHeight': -4,
                      'semanticsLabel': 'Loading line',
                      'semanticsValue': '0 percent',
                      'borderRadius': 6,
                      'stopIndicatorColor': '#b3261e',
                      'stopIndicatorRadius': -2,
                      'trackGap': 3,
                    },
                  },
                  {
                    'type': 'CircularProgressIndicator',
                    'props': {
                      'value': 1.4,
                      'backgroundColor': '#f4eff4',
                      'color': '#386a20',
                      'valueColor': '#00639b',
                      'strokeWidth': 6,
                      'strokeAlign': -1,
                      'semanticsLabel': 'Loading circle',
                      'semanticsValue': 'complete',
                      'strokeCap': 'round',
                      'constraints': {'width': 48, 'height': 48},
                      'trackGap': 2,
                      'padding': {'all': 4},
                    },
                  },
                  {
                    'type': 'CircularProgressIndicator',
                    'props': {'adaptive': true, 'value': 0.25},
                  },
                  refreshSpec('Refresh A', {
                    'adaptive': true,
                    'displacement': 32,
                    'edgeOffset': 8,
                    'color': '#006a6a',
                    'backgroundColor': '#fffbfe',
                    'notificationDepth': 1,
                    'semanticsLabel': 'Pull to refresh',
                    'semanticsValue': 'ready',
                    'strokeWidth': 5,
                    'triggerMode': 'anywhere',
                    'elevation': -1,
                    'onRefresh': {
                      'type': 'Action',
                      'props': {'name': 'refresh'},
                    },
                  }),
                  refreshSpec('Refresh B', {
                    'variant': 'noSpinner',
                    'notificationPredicate': 'any',
                    'triggerMode': 'onEdge',
                    'elevation': 4,
                    'onRefresh': {
                      'type': 'Action',
                      'props': {'name': 'refreshNoSpinner'},
                    },
                    'onStatusChange': {
                      'type': 'Action',
                      'props': {'name': 'refreshStatus'},
                    },
                  }),
                ],
              },
            }),
          ),
        ),
      ),
    );

    final linear = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(linear.value, 0);
    expect(linear.backgroundColor, const Color(0xffe7e0ec));
    expect(linear.color, const Color(0xff006a6a));
    expect(linear.valueColor?.value, const Color(0xff6750a4));
    expect(linear.minHeight, isNull);
    expect(linear.semanticsLabel, 'Loading line');
    expect(linear.semanticsValue, '0');
    expect(linear.borderRadius, BorderRadius.circular(6));
    expect(linear.stopIndicatorColor, const Color(0xffb3261e));
    expect(linear.stopIndicatorRadius, 0);
    expect(linear.trackGap, 3);

    final circular = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator).first,
    );
    expect(circular.value, 1);
    expect(circular.backgroundColor, const Color(0xfff4eff4));
    expect(circular.color, const Color(0xff386a20));
    expect(circular.valueColor?.value, const Color(0xff00639b));
    expect(circular.strokeWidth, 6);
    expect(circular.strokeAlign, -1);
    expect(circular.semanticsLabel, 'Loading circle');
    expect(circular.semanticsValue, isNull);
    expect(circular.strokeCap, ui.StrokeCap.round);
    expect(
      circular.constraints,
      const BoxConstraints.tightFor(width: 48, height: 48),
    );
    expect(circular.trackGap, 2);
    expect(circular.padding, const EdgeInsets.all(4));

    final refreshes = tester
        .widgetList<RefreshIndicator>(find.byType(RefreshIndicator))
        .toList();
    expect(refreshes, hasLength(2));
    final refresh = refreshes.first;
    expect(refresh.displacement, 32);
    expect(refresh.edgeOffset, 8);
    expect(refresh.color, const Color(0xff006a6a));
    expect(refresh.backgroundColor, const Color(0xfffffbfe));
    expect(refresh.semanticsLabel, 'Pull to refresh');
    expect(refresh.semanticsValue, 'ready');
    expect(refresh.strokeWidth, 5);
    expect(refresh.triggerMode, RefreshIndicatorTriggerMode.anywhere);
    expect(refresh.elevation, 0);
    expect(
      refresh.notificationPredicate(
        ScrollUpdateNotification(
          context: tester.element(find.text('Refresh A')),
          depth: 1,
          metrics: FixedScrollMetrics(
            minScrollExtent: 0,
            maxScrollExtent: 100,
            pixels: 0,
            viewportDimension: 100,
            axisDirection: AxisDirection.down,
            devicePixelRatio: 1,
          ),
        ),
      ),
      isTrue,
    );

    var completed = false;
    final future = refresh.onRefresh().then((_) => completed = true);
    await tester.pump();
    expect(completed, isFalse);
    completer.complete();
    await future;
    expect(completed, isTrue);

    final noSpinner = refreshes.last;
    expect(noSpinner.displacement, 0);
    expect(noSpinner.edgeOffset, 0);
    expect(noSpinner.triggerMode, RefreshIndicatorTriggerMode.onEdge);
    expect(noSpinner.elevation, 4);
    expect(
      noSpinner.notificationPredicate(
        ScrollUpdateNotification(
          context: tester.element(find.text('Refresh B')),
          depth: 7,
          metrics: FixedScrollMetrics(
            minScrollExtent: 0,
            maxScrollExtent: 100,
            pixels: 0,
            viewportDimension: 100,
            axisDirection: AxisDirection.down,
            devicePixelRatio: 1,
          ),
        ),
      ),
      isTrue,
    );
    noSpinner.onStatusChange!(RefreshIndicatorStatus.refresh);
    await noSpinner.onRefresh();

    expect(actions.map((action) => action.name), [
      'refresh',
      'refreshStatus',
      'refreshNoSpinner',
    ]);
    expect(actions[1].payload, 'refresh');
  });

  testWidgets('selects layout builder variants declaratively', (tester) async {
    final renderer = AppletRenderer();

    Future<void> pumpLayout(double width, Object spec, {double height = 96}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: Builder(
                builder: (context) => renderer.buildWidget(context, spec),
              ),
            ),
          ),
        ),
      );
    }

    final variants = {
      'type': 'LayoutBuilder',
      'props': {
        'compact': {
          'type': 'Text',
          'props': {'data': 'Compact layout'},
        },
        'medium': {
          'type': 'Text',
          'props': {'data': 'Medium layout'},
        },
        'expanded': {
          'type': 'Text',
          'props': {'data': 'Expanded layout'},
        },
      },
    };

    await pumpLayout(320, variants);
    expect(find.text('Compact layout'), findsOneWidget);
    expect(find.text('Medium layout'), findsNothing);

    await pumpLayout(640, variants);
    expect(find.text('Medium layout'), findsOneWidget);

    final breakpoints = {
      'type': 'LayoutBuilder',
      'props': {
        'breakpoints': [
          {
            'maxWidth': 400,
            'child': {
              'type': 'Text',
              'props': {'data': 'Narrow breakpoint'},
            },
          },
          {
            'minWidth': 400,
            'child': {
              'type': 'Text',
              'props': {'data': 'Wide breakpoint'},
            },
          },
        ],
      },
    };

    await pumpLayout(360, breakpoints);
    expect(find.text('Narrow breakpoint'), findsOneWidget);

    await pumpLayout(480, breakpoints);
    expect(find.text('Wide breakpoint'), findsOneWidget);

    final orientation = {
      'type': 'OrientationBuilder',
      'props': {
        'portrait': {
          'type': 'Text',
          'props': {'data': 'Portrait layout'},
        },
        'landscape': {
          'type': 'Text',
          'props': {'data': 'Landscape layout'},
        },
      },
    };

    await pumpLayout(80, orientation, height: 160);
    expect(find.text('Portrait layout'), findsOneWidget);
    expect(find.text('Landscape layout'), findsNothing);

    await pumpLayout(200, orientation, height: 100);
    expect(find.text('Landscape layout'), findsOneWidget);

    final orientationVariants = {
      'type': 'OrientationBuilder',
      'props': {
        'variants': {
          'portrait': {
            'type': 'Text',
            'props': {'data': 'Portrait variant'},
          },
          'horizontal': {
            'type': 'Text',
            'props': {'data': 'Horizontal variant'},
          },
        },
      },
    };

    await pumpLayout(70, orientationVariants, height: 140);
    expect(find.text('Portrait variant'), findsOneWidget);

    await pumpLayout(180, orientationVariants, height: 90);
    expect(find.text('Horizontal variant'), findsOneWidget);

    final orientationList = {
      'type': 'OrientationBuilder',
      'props': {
        'variants': [
          {
            'orientation': 'landscape',
            'child': {
              'type': 'Text',
              'props': {'data': 'Landscape list variant'},
            },
          },
          {
            'default': true,
            'child': {
              'type': 'Text',
              'props': {'data': 'Orientation default'},
            },
          },
        ],
      },
    };

    await pumpLayout(80, orientationList, height: 160);
    expect(find.text('Orientation default'), findsOneWidget);

    await pumpLayout(180, orientationList, height: 90);
    expect(find.text('Landscape list variant'), findsOneWidget);
  });

  testWidgets('selects sliver layout builder breakpoints declaratively', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    Map<String, Object?> grid(int crossAxisCount) => {
      'type': 'SliverGrid',
      'props': {
        'crossAxisCount': crossAxisCount,
        'children': List.generate(
          6,
          (index) => {
            'type': 'Text',
            'props': {'data': 'Tile $index'},
          },
        ),
      },
    };

    Future<void> pumpGrid(double width) {
      return tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: 320,
              child: Builder(
                builder: (context) => renderer.buildWidget(context, {
                  'type': 'CustomScrollView',
                  'props': {
                    'slivers': [
                      {
                        'type': 'SliverPadding',
                        'props': {
                          'padding': {'all': 8},
                          'child': {
                            'type': 'SliverLayoutBuilder',
                            'props': {
                              'breakpoints': [
                                {'maxWidth': 450, 'child': grid(3)},
                                {'minWidth': 450, 'child': grid(6)},
                              ],
                            },
                          },
                        },
                      },
                    ],
                  },
                }),
              ),
            ),
          ),
        ),
      );
    }

    await pumpGrid(420);
    var gridWidget = tester.widget<SliverGrid>(find.byType(SliverGrid));
    var delegate =
        gridWidget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);

    await pumpGrid(720);
    gridWidget = tester.widget<SliverGrid>(find.byType(SliverGrid));
    delegate =
        gridWidget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 6);
  });

  testWidgets('renders cached sliver lists with estimated scroll extents', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 240,
          child: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'CustomScrollView',
              'props': {
                'slivers': [
                  {
                    'type': 'SliverCachedList',
                    'props': {
                      'children': List.generate(
                        6,
                        (index) => {
                          'type': 'SizedBox',
                          'props': {
                            'height': 48.0 + index,
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Cached $index'},
                            },
                          },
                        },
                      ),
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Cached 0'), findsOneWidget);
    final sliver = tester.widget<SliverList>(find.byType(SliverList));
    expect(
      sliver.delegate.estimateMaxScrollOffset(0, 5, 0, 240),
      greaterThan(0),
    );
  });

  testWidgets('maps TextStyle theme tokens from the current Theme', (
    tester,
  ) async {
    final renderer = AppletRenderer();
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    );
    late TextStyle expected;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            final resolvedTheme = Theme.of(context);
            expected = resolvedTheme.textTheme
                .apply(displayColor: resolvedTheme.colorScheme.onSurface)
                .displayLarge!;
            return renderer.buildWidget(context, {
              'type': 'Text',
              'props': {
                'data': 'Display Large',
                'style': {'theme': 'displayLarge'},
              },
            });
          },
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Display Large'));
    expect(text.style?.fontSize, expected.fontSize);
    expect(text.style?.color, expected.color);
  });

  testWidgets('maps Image memory sources and rendering options', (
    tester,
  ) async {
    final renderer = AppletRenderer();
    const png =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Image',
            'props': {
              'base64': png,
              'width': 48,
              'height': 32,
              'cacheWidth': 24,
              'cacheHeight': 16,
              'fit': 'cover',
              'alignment': 'topRight',
              'repeat': 'repeatX',
              'color': '#ff0000',
              'opacity': 0.42,
              'colorBlendMode': 'srcIn',
              'semanticLabel': 'Preview image',
              'matchTextDirection': true,
              'gaplessPlayback': true,
              'isAntiAlias': true,
              'filterQuality': 'high',
            },
          }),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 48);
    expect(image.height, 32);
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, Alignment.topRight);
    expect(image.repeat, ImageRepeat.repeatX);
    expect(image.color, const Color(0xffff0000));
    expect(image.colorBlendMode, BlendMode.srcIn);
    expect(image.semanticLabel, 'Preview image');
    expect(image.matchTextDirection, isTrue);
    expect(image.gaplessPlayback, isTrue);
    expect(image.isAntiAlias, isTrue);
    expect(image.filterQuality, FilterQuality.high);
    expect(image.opacity, isA<AlwaysStoppedAnimation<double>>());
    expect(
      (image.opacity! as AlwaysStoppedAnimation<double>).value,
      closeTo(0.42, 0.001),
    );

    final provider = image.image;
    expect(provider, isA<ResizeImage>());
    final resizeImage = provider as ResizeImage;
    expect(resizeImage.width, 24);
    expect(resizeImage.height, 16);
    expect(resizeImage.imageProvider, isA<MemoryImage>());
  });

  testWidgets('maps rich text style options from JavaScript specs', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Column',
            'props': {
              'children': [
                {
                  'type': 'Text',
                  'props': {
                    'data': 'Styled',
                    'style': {
                      'inherit': false,
                      'color': '#111111',
                      'backgroundColor': '#eeeeee',
                      'fontFamily': 'Inter',
                      'fontFamilyFallback': ['Noto Sans', 'Arial'],
                      'fontSize': 18,
                      'fontWeight': 'w800',
                      'fontStyle': 'italic',
                      'height': 1.4,
                      'letterSpacing': 0.2,
                      'wordSpacing': 2.5,
                      'textBaseline': 'ideographic',
                      'leadingDistribution': 'even',
                      'locale': 'en-US',
                      'shadows': [
                        {
                          'color': '#55000000',
                          'offset': [1, 2],
                          'blurRadius': 3,
                        },
                      ],
                      'fontFeatures': [
                        {'tag': 'tnum', 'value': 1},
                        {'feature': 'liga', 'enabled': false},
                        {'tag': 'bad'},
                      ],
                      'fontVariations': [
                        {'axis': 'wght', 'value': 650},
                        {'axis': 'bad', 'value': 10},
                      ],
                      'decoration': ['underline', 'overline'],
                      'decorationColor': '#ff00ff',
                      'decorationStyle': 'dashed',
                      'decorationThickness': 2,
                      'overflow': 'ellipsis',
                      'debugLabel': 'applet-style',
                    },
                  },
                },
                {
                  'type': 'Text',
                  'props': {
                    'data': 'Painted',
                    'style': {
                      'foreground': {
                        'color': '#123456',
                        'style': 'stroke',
                        'strokeWidth': 1.5,
                      },
                      'background': '#abcdef',
                    },
                  },
                },
              ],
            },
          }),
        ),
      ),
    );

    final style = tester.widget<Text>(find.text('Styled')).style!;
    expect(style.inherit, isFalse);
    expect(style.color, const Color(0xff111111));
    expect(style.backgroundColor, const Color(0xffeeeeee));
    expect(style.fontFamily, 'Inter');
    expect(style.fontFamilyFallback, ['Noto Sans', 'Arial']);
    expect(style.fontSize, 18);
    expect(style.fontWeight, FontWeight.w800);
    expect(style.fontStyle, FontStyle.italic);
    expect(style.height, 1.4);
    expect(style.letterSpacing, 0.2);
    expect(style.wordSpacing, 2.5);
    expect(style.textBaseline, TextBaseline.ideographic);
    expect(style.leadingDistribution, TextLeadingDistribution.even);
    expect(style.locale, const Locale('en', 'US'));
    expect(style.overflow, TextOverflow.ellipsis);
    expect(style.debugLabel, 'applet-style');
    expect(style.decoration!.contains(TextDecoration.underline), isTrue);
    expect(style.decoration!.contains(TextDecoration.overline), isTrue);
    expect(style.decorationColor, const Color(0xffff00ff));
    expect(style.decorationStyle, TextDecorationStyle.dashed);
    expect(style.decorationThickness, 2);
    expect(style.shadows, hasLength(1));
    expect(style.shadows!.single.color, const Color(0x55000000));
    expect(style.shadows!.single.offset, const Offset(1, 2));
    expect(style.shadows!.single.blurRadius, 3);
    expect(style.fontFeatures, hasLength(2));
    expect(style.fontFeatures![0].feature, 'tnum');
    expect(style.fontFeatures![0].value, 1);
    expect(style.fontFeatures![1].feature, 'liga');
    expect(style.fontFeatures![1].value, 0);
    expect(style.fontVariations, hasLength(1));
    expect(style.fontVariations!.single.axis, 'wght');
    expect(style.fontVariations!.single.value, 650);

    final paintedStyle = tester.widget<Text>(find.text('Painted')).style!;
    expect(paintedStyle.color, isNull);
    expect(paintedStyle.foreground, isNotNull);
    expect(paintedStyle.foreground!.color.toARGB32(), 0xff123456);
    expect(paintedStyle.foreground!.style, PaintingStyle.stroke);
    expect(paintedStyle.foreground!.strokeWidth, 1.5);
    expect(paintedStyle.backgroundColor, isNull);
    expect(paintedStyle.background, isNotNull);
    expect(paintedStyle.background!.color.toARGB32(), 0xffabcdef);
  });

  testWidgets('maps text layout props and clamps unsafe line values', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Column',
            'props': {
              'children': [
                {
                  'type': 'Text',
                  'props': {
                    'data': 'Text props',
                    'strutStyle': {
                      'fontFamily': 'Inter',
                      'fontSize': -4,
                      'height': 1.2,
                      'leading': -2,
                      'forceStrutHeight': true,
                    },
                    'textAlign': 'center',
                    'textDirection': 'rtl',
                    'locale': 'zh-Hans-CN',
                    'textScaler': 1.25,
                    'overflow': 'ellipsis',
                    'maxLines': -2,
                    'softWrap': false,
                    'semanticsLabel': 'Readable text',
                    'semanticsIdentifier': 'text-id',
                    'textWidthBasis': 'longestLine',
                    'textHeightBehavior': {
                      'applyHeightToFirstAscent': false,
                      'applyHeightToLastDescent': false,
                      'leadingDistribution': 'even',
                    },
                    'selectionColor': '#3300ff00',
                  },
                },
                {
                  'type': 'SelectableText',
                  'props': {
                    'data': 'Selectable props',
                    'textScaler': {'scale': 1.5},
                    'minLines': 4,
                    'maxLines': 2,
                    'showCursor': true,
                    'cursorWidth': -1,
                    'cursorHeight': -8,
                    'cursorRadius': {'x': 3, 'y': -5},
                    'cursorColor': '#ff0000',
                    'selectionColor': '#220000ff',
                    'selectionHeightStyle': 'includeLineSpacingTop',
                    'selectionWidthStyle': 'max',
                    'enableInteractiveSelection': false,
                    'selectionControls': 'desktop',
                    'contextMenu': false,
                    'magnifier': 'disabled',
                    'dragStartBehavior': 'down',
                    'scrollPhysics': 'never',
                    'semanticsLabel': 'Selectable semantics',
                    'textWidthBasis': 'parent',
                    'textHeightBehavior': 'trim',
                    'onSelectionChanged': {
                      'type': 'Action',
                      'props': {'name': 'selectableSelection'},
                    },
                    'onTap': {
                      'type': 'Action',
                      'props': {'name': 'selectableTap'},
                    },
                  },
                },
                {
                  'type': 'RichText',
                  'props': {
                    'text': {
                      'text': 'Hello ',
                      'style': {'fontWeight': 'w600'},
                      'semanticsLabel': 'Greeting',
                      'semanticsIdentifier': 'span-id',
                      'locale': {'languageCode': 'en', 'countryCode': 'US'},
                      'spellOut': true,
                      'children': [
                        {
                          'text': 'world',
                          'style': {'color': '#123456'},
                        },
                      ],
                    },
                    'textAlign': 'end',
                    'textDirection': 'rtl',
                    'softWrap': false,
                    'overflow': 'ellipsis',
                    'textScaler': 'none',
                    'maxLines': -5,
                    'locale': 'en-US',
                    'strutStyle': 'disabled',
                    'textWidthBasis': 'longest_line',
                    'textHeightBehavior': 'trim',
                    'selectionColor': '#2200ff00',
                  },
                },
              ],
            },
          }),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Text props'));
    expect(text.textAlign, TextAlign.center);
    expect(text.textDirection, TextDirection.rtl);
    expect(
      text.locale,
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      ),
    );
    expect(text.textScaler!.scale(10), 12.5);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.maxLines, isNull);
    expect(text.softWrap, isFalse);
    expect(text.semanticsLabel, 'Readable text');
    expect(text.semanticsIdentifier, 'text-id');
    expect(text.textWidthBasis, TextWidthBasis.longestLine);
    expect(text.selectionColor, const Color(0x3300ff00));
    expect(text.strutStyle!.fontFamily, 'Inter');
    expect(text.strutStyle!.fontSize, isNull);
    expect(text.strutStyle!.height, 1.2);
    expect(text.strutStyle!.leading, 0);
    expect(text.strutStyle!.forceStrutHeight, isTrue);
    expect(text.textHeightBehavior!.applyHeightToFirstAscent, isFalse);
    expect(text.textHeightBehavior!.applyHeightToLastDescent, isFalse);
    expect(
      text.textHeightBehavior!.leadingDistribution,
      TextLeadingDistribution.even,
    );

    final selectable = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    expect(selectable.data, 'Selectable props');
    expect(selectable.textScaler!.scale(10), 15);
    expect(selectable.minLines, 4);
    expect(selectable.maxLines, 4);
    expect(selectable.showCursor, isTrue);
    expect(selectable.cursorWidth, 2);
    expect(selectable.cursorHeight, isNull);
    expect(selectable.cursorRadius, const Radius.elliptical(3, 0));
    expect(selectable.cursorColor, const Color(0xffff0000));
    expect(selectable.selectionColor, const Color(0x220000ff));
    expect(
      selectable.selectionHeightStyle,
      ui.BoxHeightStyle.includeLineSpacingTop,
    );
    expect(selectable.selectionWidthStyle, ui.BoxWidthStyle.max);
    expect(selectable.enableInteractiveSelection, isFalse);
    expect(
      selectable.selectionControls,
      same(desktopTextSelectionHandleControls),
    );
    expect(selectable.contextMenuBuilder, isNull);
    expect(
      selectable.magnifierConfiguration,
      TextMagnifierConfiguration.disabled,
    );
    expect(selectable.dragStartBehavior, DragStartBehavior.down);
    expect(selectable.scrollPhysics, isA<NeverScrollableScrollPhysics>());
    expect(selectable.semanticsLabel, 'Selectable semantics');
    expect(selectable.textWidthBasis, TextWidthBasis.parent);
    expect(selectable.textHeightBehavior!.applyHeightToFirstAscent, isFalse);
    expect(selectable.textHeightBehavior!.applyHeightToLastDescent, isFalse);

    expect(selectable.onSelectionChanged, isNotNull);
    selectable.onSelectionChanged!(
      const TextSelection(baseOffset: 2, extentOffset: 8),
      SelectionChangedCause.drag,
    );
    expect(selectable.onTap, isNotNull);
    selectable.onTap!();
    expect(actions.map((action) => action.name), [
      'selectableSelection',
      'selectableTap',
    ]);
    expect(actions.first.payload, {
      'baseOffset': 2,
      'extentOffset': 8,
      'start': 2,
      'end': 8,
      'isCollapsed': false,
      'isValid': true,
      'isNormalized': true,
      'isDirectional': false,
      'affinity': 'downstream',
      'cause': 'drag',
    });

    final rich = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text is TextSpan &&
            (widget.text as TextSpan).text == 'Hello ',
      ),
    );
    expect(rich.textAlign, TextAlign.end);
    expect(rich.textDirection, TextDirection.rtl);
    expect(rich.softWrap, isFalse);
    expect(rich.overflow, TextOverflow.ellipsis);
    expect(rich.textScaler.scale(10), 10);
    expect(rich.maxLines, isNull);
    expect(rich.locale, const Locale('en', 'US'));
    expect(rich.strutStyle, StrutStyle.disabled);
    expect(rich.textWidthBasis, TextWidthBasis.longestLine);
    expect(rich.textHeightBehavior!.applyHeightToFirstAscent, isFalse);
    expect(rich.textHeightBehavior!.applyHeightToLastDescent, isFalse);
    expect(rich.selectionColor, const Color(0x2200ff00));

    final span = rich.text as TextSpan;
    expect(span.text, 'Hello ');
    expect(span.style!.fontWeight, FontWeight.w600);
    expect(span.semanticsLabel, 'Greeting');
    expect(span.semanticsIdentifier, 'span-id');
    expect(span.locale, const Locale('en', 'US'));
    expect(span.spellOut, isTrue);
    final childSpan = span.children!.single as TextSpan;
    expect(childSpan.text, 'world');
    expect(childSpan.style!.color, const Color(0xff123456));
  });

  testWidgets('maps box decoration images, shadows, and blend options', (
    tester,
  ) async {
    final renderer = AppletRenderer();
    const png =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Container',
            'props': {
              'width': 96,
              'height': 64,
              'decoration': {
                'color': '#ffffff',
                'backgroundBlendMode': 'multiply',
                'borderRadius': 18,
                'gradient': {
                  'type': 'radial',
                  'colors': ['#ffffff', '#000000'],
                  'stops': [0, 1],
                  'tileMode': 'mirror',
                  'radius': 0.75,
                },
                'image': {
                  'base64': png,
                  'cacheWidth': 12,
                  'cacheHeight': 8,
                  'fit': 'cover',
                  'alignment': 'bottomRight',
                  'repeat': 'repeatY',
                  'opacity': 0.5,
                  'color': '#00ff00',
                  'colorBlendMode': 'srcIn',
                  'filterQuality': 'low',
                  'invertColors': true,
                  'isAntiAlias': true,
                },
                'boxShadow': [
                  {
                    'color': '#33000000',
                    'offset': [2, 4],
                    'blurRadius': 12,
                    'spreadRadius': 3,
                    'blurStyle': 'outer',
                  },
                ],
              },
            },
          }),
        ),
      ),
    );

    final container = tester
        .widgetList<Container>(find.byType(Container))
        .singleWhere((widget) {
          final decoration = widget.decoration;
          return decoration is BoxDecoration && decoration.image != null;
        });
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, const Color(0xffffffff));
    expect(decoration.backgroundBlendMode, BlendMode.multiply);
    expect(decoration.borderRadius, BorderRadius.circular(18));
    expect(decoration.gradient, isA<RadialGradient>());
    final gradient = decoration.gradient! as RadialGradient;
    expect(gradient.radius, 0.75);
    expect(gradient.tileMode, TileMode.mirror);
    expect(gradient.stops, [0, 1]);

    expect(decoration.boxShadow, hasLength(1));
    final shadow = decoration.boxShadow!.single;
    expect(shadow.color, const Color(0x33000000));
    expect(shadow.offset, const Offset(2, 4));
    expect(shadow.blurRadius, 12);
    expect(shadow.spreadRadius, 3);
    expect(shadow.blurStyle, BlurStyle.outer);

    final image = decoration.image!;
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, Alignment.bottomRight);
    expect(image.repeat, ImageRepeat.repeatY);
    expect(image.opacity, 0.5);
    expect(image.filterQuality, FilterQuality.low);
    expect(image.invertColors, isTrue);
    expect(image.isAntiAlias, isTrue);
    expect(image.colorFilter, isNotNull);
    expect(image.image, isA<ResizeImage>());
    final provider = image.image as ResizeImage;
    expect(provider.width, 12);
    expect(provider.height, 8);
    expect(provider.imageProvider, isA<MemoryImage>());
  });

  testWidgets('drops border radius for circular box decorations safely', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Container',
            'props': {
              'width': 48,
              'height': 48,
              'decoration': {
                'shape': 'circle',
                'borderRadius': 24,
                'color': '#00ff00',
              },
            },
          }),
        ),
      ),
    );

    final container = tester
        .widgetList<Container>(find.byType(Container))
        .singleWhere((widget) {
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.shape == BoxShape.circle;
        });
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.shape, BoxShape.circle);
    expect(decoration.borderRadius, isNull);
    expect(decoration.color, const Color(0xff00ff00));
  });

  testWidgets('renders visible material scrollbars safely', (tester) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => SizedBox(
            height: 96,
            child: renderer.buildWidget(context, {
              'type': 'Scrollbar',
              'props': {
                'thumbVisibility': true,
                'trackVisibility': true,
                'thickness': -8,
                'radius': -4,
                'interactive': false,
                'orientation': 'right',
                'child': {
                  'type': 'ListView',
                  'props': {
                    'children': [
                      for (var index = 0; index < 12; index++)
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 32,
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Row $index'},
                            },
                          },
                        },
                    ],
                  },
                },
              },
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
    expect(scrollbar.trackVisibility, isTrue);
    expect(scrollbar.thickness, 0);
    expect(scrollbar.radius, Radius.zero);
    expect(scrollbar.interactive, isFalse);
    expect(scrollbar.scrollbarOrientation, ScrollbarOrientation.right);
    expect(find.text('Row 0'), findsOneWidget);
  });

  testWidgets('maps scroll views safely', (tester) async {
    final renderer = AppletRenderer();

    Future<T> pumpBounded<T extends Widget>(Map<String, Object?> spec) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => SizedBox(
              width: 240,
              height: 120,
              child: renderer.buildWidget(context, spec),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.widget<T>(find.byType(T).first);
    }

    final single = await pumpBounded<SingleChildScrollView>({
      'type': 'SingleChildScrollView',
      'props': {
        'scrollDirection': 'horizontal',
        'reverse': true,
        'padding': {'all': 8},
        'physics': 'never',
        'dragStartBehavior': 'down',
        'clipBehavior': 'antiAlias',
        'hitTestBehavior': 'translucent',
        'restorationId': 'single-scroll',
        'child': {
          'type': 'SizedBox',
          'props': {'width': 500, 'height': 40},
        },
      },
    });
    expect(single.scrollDirection, Axis.horizontal);
    expect(single.reverse, isTrue);
    expect(single.padding, const EdgeInsets.all(8));
    expect(single.physics, isA<NeverScrollableScrollPhysics>());
    expect(single.dragStartBehavior, DragStartBehavior.down);
    expect(single.clipBehavior, Clip.antiAlias);
    expect(single.hitTestBehavior, HitTestBehavior.translucent);
    expect(single.restorationId, 'single-scroll');

    final custom = await pumpBounded<CustomScrollView>({
      'type': 'CustomScrollView',
      'props': {
        'scrollDirection': 'horizontal',
        'reverse': true,
        'shrinkWrap': true,
        'anchor': 1.4,
        'dragStartBehavior': 'down',
        'clipBehavior': 'antiAlias',
        'hitTestBehavior': 'deferToChild',
        'restorationId': 'custom-scroll',
        'slivers': [
          {
            'type': 'SliverToBoxAdapter',
            'props': {
              'child': {
                'type': 'SizedBox',
                'props': {'width': 500, 'height': 40},
              },
            },
          },
        ],
      },
    });
    expect(custom.scrollDirection, Axis.horizontal);
    expect(custom.reverse, isTrue);
    expect(custom.shrinkWrap, isTrue);
    expect(custom.anchor, 1);
    expect(custom.dragStartBehavior, DragStartBehavior.down);
    expect(custom.clipBehavior, Clip.antiAlias);
    expect(custom.hitTestBehavior, HitTestBehavior.deferToChild);
    expect(custom.restorationId, 'custom-scroll');

    final list = await pumpBounded<ListView>({
      'type': 'ListView',
      'props': {
        'scrollDirection': 'horizontal',
        'reverse': true,
        'shrinkWrap': true,
        'itemExtent': -20,
        'spacing': 4,
        'dragStartBehavior': 'down',
        'clipBehavior': 'antiAlias',
        'hitTestBehavior': 'opaque',
        'restorationId': 'list-scroll',
        'children': [
          {
            'type': 'Text',
            'props': {'data': 'A'},
          },
          {
            'type': 'Text',
            'props': {'data': 'B'},
          },
        ],
      },
    });
    expect(list.scrollDirection, Axis.horizontal);
    expect(list.reverse, isTrue);
    expect(list.shrinkWrap, isTrue);
    expect(list.itemExtent, isNull);
    expect(list.dragStartBehavior, DragStartBehavior.down);
    expect(list.clipBehavior, Clip.antiAlias);
    expect(list.hitTestBehavior, HitTestBehavior.opaque);
    expect(list.restorationId, 'list-scroll');

    final grid = await pumpBounded<GridView>({
      'type': 'GridView',
      'props': {
        'crossAxisCount': -3,
        'childAspectRatio': -1,
        'mainAxisSpacing': -4,
        'crossAxisSpacing': -5,
        'mainAxisExtent': -6,
        'reverse': true,
        'clipBehavior': 'antiAlias',
        'hitTestBehavior': 'translucent',
        'restorationId': 'grid-scroll',
        'children': [
          {
            'type': 'Text',
            'props': {'data': 'Cell'},
          },
        ],
      },
    });
    final gridDelegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(gridDelegate.crossAxisCount, 1);
    expect(gridDelegate.childAspectRatio, 1);
    expect(gridDelegate.mainAxisSpacing, 0);
    expect(gridDelegate.crossAxisSpacing, 0);
    expect(gridDelegate.mainAxisExtent, isNull);
    expect(grid.reverse, isTrue);
    expect(grid.clipBehavior, Clip.antiAlias);
    expect(grid.hitTestBehavior, HitTestBehavior.translucent);
    expect(grid.restorationId, 'grid-scroll');

    final page = await pumpBounded<PageView>({
      'type': 'PageView',
      'props': {
        'scrollDirection': 'vertical',
        'reverse': true,
        'physics': 'clamping',
        'pageSnapping': false,
        'dragStartBehavior': 'down',
        'allowImplicitScrolling': true,
        'clipBehavior': 'antiAlias',
        'hitTestBehavior': 'deferToChild',
        'restorationId': 'page-scroll',
        'padEnds': false,
        'children': [
          {
            'type': 'Text',
            'props': {'data': 'Page'},
          },
        ],
      },
    });
    expect(page.scrollDirection, Axis.vertical);
    expect(page.reverse, isTrue);
    expect(page.physics, isA<ClampingScrollPhysics>());
    expect(page.pageSnapping, isFalse);
    expect(page.dragStartBehavior, DragStartBehavior.down);
    expect(page.allowImplicitScrolling, isTrue);
    expect(page.clipBehavior, Clip.antiAlias);
    expect(page.hitTestBehavior, HitTestBehavior.deferToChild);
    expect(page.restorationId, 'page-scroll');
    expect(page.padEnds, isFalse);
  });

  testWidgets('maps material grid tiles and bars safely', (tester) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => SizedBox(
            width: 240,
            height: 180,
            child: renderer.buildWidget(context, {
              'type': 'GridView',
              'props': {
                'crossAxisCount': 2,
                'children': [
                  {
                    'type': 'GridTile',
                    'props': {
                      'child': {
                        'type': 'Container',
                        'props': {'color': '#6750a4'},
                      },
                      'header': {
                        'type': 'GridTileBar',
                        'props': {
                          'backgroundColor': '#99000000',
                          'title': 'Header',
                          'trailing': {
                            'type': 'Icon',
                            'props': {'icon': 'more_vert'},
                          },
                        },
                      },
                      'footer': {
                        'type': 'GridTileBar',
                        'props': {
                          'backgroundColor': '#cc000000',
                          'leading': {
                            'type': 'Icon',
                            'props': {'icon': 'image'},
                          },
                          'title': {
                            'type': 'Text',
                            'props': {'data': 'Footer'},
                          },
                          'subtitle': 'Subtitle',
                        },
                      },
                    },
                  },
                ],
              },
            }),
          ),
        ),
      ),
    );
    await tester.pump();

    final tile = tester.widget<GridTile>(find.byType(GridTile));
    expect(tile.child, isA<Container>());
    expect(tile.header, isA<GridTileBar>());
    expect(tile.footer, isA<GridTileBar>());

    final bars = tester
        .widgetList<GridTileBar>(find.byType(GridTileBar))
        .toList();
    expect(bars, hasLength(2));
    expect(bars.first.backgroundColor, const Color(0x99000000));
    expect(bars.first.title, isA<Text>());
    expect(bars.first.trailing, isA<Icon>());
    expect(bars.last.backgroundColor, const Color(0xcc000000));
    expect(bars.last.leading, isA<Icon>());
    expect(bars.last.title, isA<Text>());
    expect(bars.last.subtitle, isA<Text>());
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
  });

  testWidgets('maps material theme subthemes from JavaScript specs', (
    tester,
  ) async {
    late ThemeData capturedTheme;
    late BuildContext capturedContext;
    final renderer = AppletRenderer(
      builders: {
        'CaptureTheme': (context, props) {
          return Builder(
            builder: (context) {
              capturedContext = context;
              capturedTheme = Theme.of(context);
              return const SizedBox.shrink();
            },
          );
        },
      },
    );

    await tester.pumpWidget(
      Builder(
        builder: (context) => renderer.buildWidget(context, {
          'type': 'MaterialApp',
          'props': {
            'theme': {
              'useMaterial3': true,
              'useSystemColors': false,
              'applyElevationOverlayColor': true,
              'materialTapTargetSize': 'shrinkWrap',
              'platform': 'macos',
              'visualDensity': 'comfortable',
              'brightness': 'light',
              'seedColor': '#006a6a',
              'primaryColorDark': '#003737',
              'primaryColorLight': '#80cbc4',
              'secondaryHeaderColor': '#d0bcff',
              'unselectedWidgetColor': '#79747e',
              'fontFamilyFallback': ['Noto Sans', 'Arial'],
              'scaffoldBackgroundColor': '#fafafa',
              'actionIconTheme': {
                'backButtonIcon': {'icon': 'arrow_back', 'color': '#006a6a'},
                'closeButtonIcon': {'icon': 'close', 'size': 20},
                'drawerButtonIcon': 'menu',
                'endDrawerButtonIcon': {'icon': 'menu', 'color': '#984061'},
              },
              'textTheme': {
                'titleLarge': {'fontSize': 24, 'fontWeight': 'w600'},
              },
              'appBarTheme': {
                'backgroundColor': '#111111',
                'foregroundColor': '#eeeeee',
                'elevation': 3,
                'centerTitle': true,
              },
              'cardTheme': {
                'color': '#fef7ff',
                'elevation': 4,
                'margin': {'all': 12},
                'shape': {'borderRadius': 18},
              },
              'badgeTheme': {
                'backgroundColor': '#006a6a',
                'textColor': '#ffffff',
                'smallSize': -4,
                'largeSize': 18,
                'textStyle': {'fontSize': 11, 'fontWeight': 'w700'},
                'padding': {'horizontal': 6},
                'alignment': 'topRight',
                'offset': [3, -5],
              },
              'bannerTheme': {
                'backgroundColor': '#f4eff4',
                'surfaceTintColor': '#fffbfe',
                'shadowColor': '#22000000',
                'dividerColor': '#e7e0ec',
                'contentTextStyle': {'fontSize': 14, 'color': '#1d1b20'},
                'elevation': -3,
                'padding': {'horizontal': 16, 'vertical': 12},
                'leadingPadding': {'left': 16, 'right': 8},
              },
              'buttonTheme': {
                'textTheme': 'normal',
                'minWidth': 64,
                'height': 38,
                'padding': {'horizontal': 14},
                'shape': {'borderRadius': 999},
                'layoutBehavior': 'constrained',
                'alignedDropdown': true,
                'buttonColor': '#006a6a',
                'disabledColor': '#cac4d0',
                'focusColor': '#22006a6a',
                'hoverColor': '#11006a6a',
                'highlightColor': '#22006a6a',
                'splashColor': '#33006a6a',
                'colorScheme': {'primary': '#006a6a', 'onPrimary': '#ffffff'},
                'tapTargetSize': 'shrinkWrap',
              },
              'scrollbarTheme': {
                'thumbVisibility': true,
                'trackVisibility': {'default': false, 'hovered': true},
                'thickness': {'default': -2, 'hovered': 8},
                'radius': -6,
                'thumbColor': {'default': '#006a6a', 'dragged': '#984061'},
                'trackColor': {'hovered': '#f4eff4'},
                'trackBorderColor': {'hovered': '#79747e'},
                'crossAxisMargin': -4,
                'mainAxisMargin': 3,
                'minThumbLength': -20,
                'interactive': false,
              },
              'carouselViewTheme': {
                'backgroundColor': '#fffbfe',
                'elevation': -1,
                'overlayColor': {'pressed': '#11006a6a'},
                'shape': {'borderRadius': 20},
                'padding': {'all': 6},
                'itemClipBehavior': 'antiAlias',
              },
              'chipTheme': {
                'color': '#f4eff4',
                'backgroundColor': '#fffbfe',
                'labelStyle': {'fontSize': 13, 'fontWeight': 'w600'},
                'avatarBoxConstraints': {'minWidth': 22, 'minHeight': 22},
                'deleteIconBoxConstraints': {'minWidth': 18, 'minHeight': 18},
                'elevation': -1,
                'pressElevation': 5,
              },
              'checkboxTheme': {
                'fillColor': {'selected': '#006a6a'},
                'checkColor': '#ffffff',
                'overlayColor': '#33006a6a',
                'splashRadius': 16,
                'tapTargetSize': 'shrinkWrap',
                'visualDensity': 'compact',
                'shape': {'borderRadius': 4},
                'side': {'color': '#79747e', 'width': 1.5},
              },
              'radioTheme': {
                'fillColor': {'selected': '#006a6a'},
                'backgroundColor': {'default': '#fffbfe'},
                'innerRadius': {'default': 5},
                'overlayColor': '#33006a6a',
                'splashRadius': 17,
                'tapTargetSize': 'shrinkWrap',
                'visualDensity': 'compact',
                'side': {'color': '#79747e', 'width': 1.2},
              },
              'switchTheme': {
                'thumbColor': {'selected': '#006a6a'},
                'trackColor': {'default': '#e7e0ec'},
                'trackOutlineColor': {'default': '#79747e'},
                'trackOutlineWidth': {'default': 2},
                'overlayColor': '#33006a6a',
                'splashRadius': 18,
                'tapTargetSize': 'shrinkWrap',
                'thumbIcon': {
                  'selected': {'icon': 'check'},
                },
                'padding': {'horizontal': 8},
              },
              'sliderTheme': {
                'trackHeight': 6,
                'activeTrackColor': '#006a6a',
                'inactiveTrackColor': '#e7e0ec',
                'secondaryActiveTrackColor': '#80cbc4',
                'activeTickMarkColor': '#ffffff',
                'inactiveTickMarkColor': '#79747e',
                'thumbColor': '#006a6a',
                'overlayColor': '#33006a6a',
                'valueIndicatorColor': '#1d1b20',
                'valueIndicatorTextStyle': {'fontSize': 12, 'color': '#ffffff'},
                'showValueIndicator': 'alwaysVisible',
                'minThumbSeparation': 8,
                'mouseCursor': {'default': 'click'},
                'allowedInteraction': 'slideThumb',
                'padding': {'horizontal': 10},
                'thumbSize': {
                  'default': [20, 20],
                },
                'trackGap': 2,
              },
              'segmentedButtonTheme': {
                'selectedIcon': {'icon': 'check'},
                'style': {
                  'backgroundColor': '#f4eff4',
                  'foregroundColor': '#1d1b20',
                  'padding': {'horizontal': 12, 'vertical': 8},
                  'side': {'color': '#79747e', 'width': 1},
                  'shape': {'borderRadius': 12},
                },
              },
              'dropdownMenuTheme': {
                'textStyle': {'fontSize': 15, 'fontWeight': 'w500'},
                'inputDecorationTheme': {
                  'filled': true,
                  'fillColor': '#f4eff4',
                },
                'menuStyle': {
                  'backgroundColor': '#fffbfe',
                  'padding': {'vertical': 6},
                  'shape': {'borderRadius': 16},
                },
                'disabledColor': '#79747e',
              },
              'popupMenuTheme': {
                'color': '#fffbfe',
                'shape': {'borderRadius': 14},
                'menuPadding': {'vertical': 4},
                'elevation': 3,
                'shadowColor': '#33000000',
                'surfaceTintColor': '#f4eff4',
                'textStyle': {'fontSize': 13},
                'labelTextStyle': {
                  'disabled': {'color': '#79747e'},
                  'default': {'color': '#1d1b20'},
                },
                'enableFeedback': false,
                'mouseCursor': {'default': 'click'},
                'position': 'under',
                'iconColor': '#006a6a',
                'iconSize': 22,
              },
              'dataTableTheme': {
                'decoration': {'color': '#fffbfe', 'borderRadius': 12},
                'dataRowColor': {'selected': '#11006a6a'},
                'dataRowMinHeight': 44,
                'dataRowMaxHeight': 36,
                'dataTextStyle': {'fontSize': 13},
                'headingRowColor': '#f4eff4',
                'headingRowHeight': 52,
                'headingTextStyle': {'fontWeight': 'w600'},
                'horizontalMargin': 16,
                'columnSpacing': 24,
                'dividerThickness': -1,
                'checkboxHorizontalMargin': 10,
                'headingCellCursor': {'default': 'click'},
                'dataRowCursor': {'default': 'click'},
                'headingRowAlignment': 'center',
              },
              'datePickerTheme': {
                'backgroundColor': '#fffbfe',
                'elevation': -1,
                'shadowColor': '#22000000',
                'surfaceTintColor': '#f4eff4',
                'shape': {'borderRadius': 28},
                'headerBackgroundColor': '#006a6a',
                'headerForegroundColor': '#ffffff',
                'headerHeadlineStyle': {'fontSize': 28},
                'headerHelpStyle': {'fontSize': 14, 'fontWeight': 'w600'},
                'weekdayStyle': {'fontSize': 12, 'color': '#79747e'},
                'dayStyle': {'fontSize': 14},
                'dayForegroundColor': {
                  'selected': '#ffffff',
                  'default': '#1d1b20',
                },
                'dayBackgroundColor': {'selected': '#006a6a'},
                'dayOverlayColor': {'hovered': '#11006a6a'},
                'dayShape': {'borderRadius': 20},
                'todayForegroundColor': {'default': '#006a6a'},
                'todayBackgroundColor': {'selected': '#d0bcff'},
                'todayBorder': {'color': '#006a6a', 'width': 1.5},
                'yearStyle': {'fontSize': 15},
                'yearForegroundColor': {
                  'selected': '#ffffff',
                  'default': '#1d1b20',
                },
                'yearBackgroundColor': {'selected': '#006a6a'},
                'yearOverlayColor': {'pressed': '#22006a6a'},
                'yearShape': {'borderRadius': 18},
                'rangePickerBackgroundColor': '#fffbfe',
                'rangePickerElevation': -2,
                'rangePickerShadowColor': '#22000000',
                'rangePickerSurfaceTintColor': '#f4eff4',
                'rangePickerShape': {'borderRadius': 24},
                'rangePickerHeaderBackgroundColor': '#006a6a',
                'rangePickerHeaderForegroundColor': '#ffffff',
                'rangePickerHeaderHeadlineStyle': {'fontSize': 24},
                'rangePickerHeaderHelpStyle': {'fontSize': 13},
                'rangeSelectionBackgroundColor': '#22006a6a',
                'rangeSelectionOverlayColor': {'pressed': '#33006a6a'},
                'dividerColor': '#e7e0ec',
                'inputDecorationTheme': {
                  'filled': true,
                  'fillColor': '#f4eff4',
                },
                'cancelButtonStyle': {'foregroundColor': '#984061'},
                'confirmButtonStyle': {'foregroundColor': '#006a6a'},
                'locale': 'zh-CN',
                'toggleButtonTextStyle': {'fontSize': 13},
                'subHeaderForegroundColor': '#49454f',
              },
              'menuTheme': {
                'style': {
                  'backgroundColor': '#fffbfe',
                  'surfaceTintColor': '#f4eff4',
                  'elevation': 2,
                  'padding': {'horizontal': 4},
                  'minimumSize': [120, 40],
                  'side': {'color': '#79747e', 'width': 1},
                  'shape': {'borderRadius': 12},
                  'mouseCursor': {'default': 'click'},
                  'visualDensity': 'compact',
                  'alignment': 'bottomLeft',
                },
                'submenuIcon': {'icon': 'chevron_right'},
              },
              'menuBarTheme': {
                'style': {
                  'backgroundColor': '#f4eff4',
                  'padding': {'horizontal': 8},
                },
              },
              'menuButtonTheme': {
                'style': {
                  'foregroundColor': '#1d1b20',
                  'padding': {'horizontal': 12, 'vertical': 8},
                },
              },
              'progressIndicatorTheme': {
                'color': '#006a6a',
                'linearTrackColor': '#e7e0ec',
                'linearMinHeight': 5,
                'circularTrackColor': '#f4eff4',
                'refreshBackgroundColor': '#fffbfe',
                'borderRadius': 6,
                'stopIndicatorColor': '#b3261e',
                'stopIndicatorRadius': 3,
                'strokeWidth': 4,
                'strokeAlign': -1,
                'strokeCap': 'round',
                'constraints': {'width': 44, 'height': 44},
                'trackGap': 2,
                'circularTrackPadding': {'all': 4},
              },
              'listTileTheme': {
                'iconColor': '#006a6a',
                'textColor': '#1d1b20',
                'contentPadding': {'horizontal': 20, 'vertical': 8},
                'style': 'drawer',
                'visualDensity': 'compact',
                'titleAlignment': 'center',
                'controlAffinity': 'leading',
                'isThreeLine': true,
                'minTileHeight': 56,
              },
              'expansionTileTheme': {
                'backgroundColor': '#f4eff4',
                'collapsedBackgroundColor': '#fffbfe',
                'tilePadding': {'horizontal': 24},
                'expandedAlignment': 'centerLeft',
                'childrenPadding': {'left': 16, 'right': 16, 'bottom': 12},
                'iconColor': '#006a6a',
                'collapsedIconColor': '#49454f',
                'textColor': '#1d1b20',
                'collapsedTextColor': '#49454f',
                'shape': {'borderRadius': 16},
                'collapsedShape': {'borderRadius': 8},
                'clipBehavior': 'antiAlias',
                'animationStyle': {
                  'duration': 180,
                  'reverseDuration': 120,
                  'curve': 'easeInOut',
                  'reverseCurve': 'easeOut',
                },
              },
              'inputDecorationTheme': {
                'filled': true,
                'fillColor': '#f4eff4',
                'floatingLabelAlignment': 'center',
                'hintFadeDuration': 120,
                'prefixIconConstraints': {'minWidth': 32, 'minHeight': 30},
                'suffixIconConstraints': {'minWidth': 34, 'minHeight': 32},
                'activeIndicatorBorder': {'color': '#006a6a', 'width': 2},
                'outlineBorder': {'color': '#6750a4', 'width': 1.5},
                'border': {
                  'type': 'outline',
                  'borderRadius': 12,
                  'borderSide': {'color': '#79747e', 'width': 1},
                },
                'visualDensity': 'compact',
              },
              'textSelectionTheme': {
                'cursorColor': '#006a6a',
                'selectionColor': '#33006a6a',
                'selectionHandleColor': '#984061',
              },
              'elevatedButtonTheme': {
                'style': {
                  'backgroundColor': '#006a6a',
                  'foregroundColor': '#ffffff',
                  'elevation': 2,
                  'textStyle': {'fontSize': 16, 'fontWeight': 'w600'},
                  'iconColor': '#ffcc00',
                  'iconSize': 20,
                  'iconAlignment': 'end',
                  'visualDensity': 'comfortable',
                  'tapTargetSize': 'shrinkWrap',
                  'animationDuration': 180,
                  'enableFeedback': false,
                  'alignment': 'centerRight',
                  'shape': {'borderRadius': 16},
                },
              },
              'navigationBarTheme': {
                'backgroundColor': '#fef7ff',
                'shadowColor': '#33000000',
                'surfaceTintColor': '#f4eff4',
                'indicatorColor': '#d0bcff',
                'indicatorShape': {'borderRadius': 20},
                'labelBehavior': 'alwaysHide',
                'labelTextStyle': {
                  'default': {'fontSize': 11},
                },
                'iconTheme': {
                  'selected': {'color': '#006a6a', 'size': 26},
                  'default': {'color': '#49454f', 'size': 22},
                },
                'overlayColor': {'pressed': '#22006a6a'},
                'labelPadding': {'horizontal': 6},
              },
              'navigationDrawerTheme': {
                'tileHeight': 64,
                'backgroundColor': '#fffbfe',
                'elevation': -1,
                'shadowColor': '#22000000',
                'surfaceTintColor': '#f4eff4',
                'indicatorColor': '#d0bcff',
                'indicatorShape': {'borderRadius': 28},
                'indicatorSize': [56, 32],
                'labelTextStyle': {
                  'default': {'fontSize': 13},
                },
                'iconTheme': {
                  'selected': {'color': '#006a6a', 'size': 24},
                },
              },
              'searchBarTheme': {
                'elevation': {'default': -1, 'hovered': 5},
                'backgroundColor': {'default': '#f4eff4'},
                'shadowColor': '#33000000',
                'surfaceTintColor': '#fffbfe',
                'overlayColor': {'pressed': '#22006a6a'},
                'side': {'color': '#79747e', 'width': 1.5},
                'shape': {'borderRadius': 24},
                'padding': {'horizontal': 14, 'vertical': 2},
                'textStyle': {'fontSize': 14, 'color': '#1d1b20'},
                'hintStyle': {'fontSize': 13, 'color': '#49454f'},
                'constraints': {'minWidth': 120, 'minHeight': 48},
                'textCapitalization': 'words',
              },
              'searchViewTheme': {
                'backgroundColor': '#fffbfe',
                'elevation': -2,
                'surfaceTintColor': '#f4eff4',
                'side': {'color': '#79747e', 'width': 1},
                'shape': {'borderRadius': 28},
                'headerHeight': -56,
                'headerTextStyle': {'fontSize': 16, 'fontWeight': 'w600'},
                'headerHintStyle': {'fontSize': 15, 'color': '#49454f'},
                'constraints': {'minWidth': 240, 'maxWidth': 640},
                'padding': {'horizontal': 12, 'bottom': 8},
                'barPadding': {'horizontal': 8, 'top': 6},
                'shrinkWrap': true,
                'dividerColor': '#e7e0ec',
              },
              'bottomNavigationBarTheme': {
                'backgroundColor': '#fffbfe',
                'elevation': -2,
                'selectedIconTheme': {'color': '#006a6a', 'size': 28},
                'unselectedIconTheme': {'color': '#49454f', 'size': 22},
                'selectedItemColor': '#006a6a',
                'unselectedItemColor': '#49454f',
                'selectedLabelStyle': {'fontSize': 12},
                'unselectedLabelStyle': {'fontSize': 10},
                'showSelectedLabels': true,
                'showUnselectedLabels': false,
                'type': 'fixed',
                'enableFeedback': false,
                'landscapeLayout': 'centered',
                'mouseCursor': {'default': 'click'},
              },
              'bottomAppBarTheme': {
                'color': '#fffbfe',
                'elevation': -1,
                'shape': 'circular',
                'height': 68,
                'surfaceTintColor': '#f4eff4',
                'shadowColor': '#22000000',
                'padding': {'horizontal': 16},
              },
              'snackBarTheme': {
                'backgroundColor': '#1d1b20',
                'behavior': 'floating',
                'showCloseIcon': true,
              },
              'dialogTheme': {
                'backgroundColor': '#fffbfe',
                'shape': {'borderRadius': 28},
              },
              'dividerTheme': {
                'color': '#79747e',
                'space': -4,
                'thickness': -2,
                'indent': 12,
                'endIndent': 8,
                'radius': 3,
              },
              'bottomSheetTheme': {
                'backgroundColor': '#fffbfe',
                'showDragHandle': true,
              },
              'timePickerTheme': {
                'backgroundColor': '#fffbfe',
                'elevation': -4,
                'shape': {'borderRadius': 28},
                'padding': {'all': 20},
                'entryModeIconColor': '#006a6a',
                'helpTextStyle': {'fontSize': 12, 'color': '#79747e'},
                'hourMinuteColor': {
                  'selected': '#22006a6a',
                  'default': '#f4eff4',
                },
                'hourMinuteTextColor': {
                  'selected': '#006a6a',
                  'default': '#1d1b20',
                },
                'hourMinuteTextStyle': {'fontSize': 46},
                'hourMinuteShape': {'borderRadius': 16},
                'dayPeriodColor': {
                  'selected': '#22006a6a',
                  'default': 'transparent',
                },
                'dayPeriodTextColor': {
                  'selected': '#006a6a',
                  'default': '#79747e',
                },
                'dayPeriodBorderSide': {'color': '#79747e', 'width': 1},
                'dayPeriodShape': {'borderRadius': 12},
                'dayPeriodTextStyle': {'fontSize': 13},
                'dialBackgroundColor': '#f4eff4',
                'dialHandColor': '#006a6a',
                'dialTextColor': {'selected': '#ffffff', 'default': '#1d1b20'},
                'dialTextStyle': {'fontSize': 14},
                'timeSelectorSeparatorColor': {
                  'selected': '#006a6a',
                  'default': '#79747e',
                },
                'timeSelectorSeparatorTextStyle': {
                  'default': {'fontSize': 44, 'color': '#79747e'},
                },
                'inputDecorationTheme': {
                  'filled': true,
                  'fillColor': '#f4eff4',
                },
                'cancelButtonStyle': {'foregroundColor': '#984061'},
                'confirmButtonStyle': {'foregroundColor': '#006a6a'},
              },
              'toggleButtonsTheme': {
                'textStyle': {'fontSize': 14, 'fontWeight': 'w600'},
                'constraints': {'minWidth': 44, 'minHeight': 40},
                'color': '#1d1b20',
                'selectedColor': '#006a6a',
                'disabledColor': '#cac4d0',
                'fillColor': '#11006a6a',
                'focusColor': '#22006a6a',
                'highlightColor': '#11006a6a',
                'hoverColor': '#11006a6a',
                'splashColor': '#22006a6a',
                'borderColor': '#79747e',
                'selectedBorderColor': '#006a6a',
                'disabledBorderColor': '#cac4d0',
                'borderRadius': 18,
                'borderWidth': -1,
              },
              'tooltipTheme': {
                'height': 28,
                'padding': {'horizontal': 10, 'vertical': 6},
                'margin': {'all': 4},
                'verticalOffset': -6,
                'preferBelow': false,
                'excludeFromSemantics': true,
                'decoration': {'color': '#1d1b20', 'borderRadius': 8},
                'textStyle': {'fontSize': 12, 'color': '#ffffff'},
                'textAlign': 'center',
                'waitDuration': 100,
                'showDuration': {'seconds': 2},
                'exitDuration': 40,
                'triggerMode': 'tap',
                'enableFeedback': false,
              },
            },
            'home': {'type': 'CaptureTheme', 'props': {}},
          },
        }),
      ),
    );

    expect(capturedTheme.scaffoldBackgroundColor, const Color(0xfffafafa));
    expect(capturedTheme.applyElevationOverlayColor, isTrue);
    expect(
      capturedTheme.materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(capturedTheme.platform, TargetPlatform.macOS);
    expect(capturedTheme.visualDensity, VisualDensity.comfortable);
    expect(capturedTheme.primaryColorDark, const Color(0xff003737));
    expect(capturedTheme.primaryColorLight, const Color(0xff80cbc4));
    expect(capturedTheme.secondaryHeaderColor, const Color(0xffd0bcff));
    expect(capturedTheme.unselectedWidgetColor, const Color(0xff79747e));
    final actionIcons = capturedTheme.actionIconTheme!;
    final backIcon =
        actionIcons.backButtonIconBuilder!(capturedContext) as Icon;
    final closeIcon =
        actionIcons.closeButtonIconBuilder!(capturedContext) as Icon;
    final drawerIcon =
        actionIcons.drawerButtonIconBuilder!(capturedContext) as Icon;
    final endDrawerIcon =
        actionIcons.endDrawerButtonIconBuilder!(capturedContext) as Icon;
    expect(backIcon.icon, Icons.arrow_back);
    expect(backIcon.color, const Color(0xff006a6a));
    expect(closeIcon.icon, Icons.close);
    expect(closeIcon.size, 20);
    expect(drawerIcon.icon, Icons.menu);
    expect(endDrawerIcon.icon, Icons.menu);
    expect(endDrawerIcon.color, const Color(0xff984061));
    expect(capturedTheme.textTheme.titleLarge?.fontSize, 24);
    expect(capturedTheme.textTheme.titleLarge?.fontWeight, FontWeight.w600);
    expect(capturedTheme.appBarTheme.backgroundColor, const Color(0xff111111));
    expect(capturedTheme.appBarTheme.centerTitle, isTrue);
    expect(capturedTheme.cardTheme.elevation, 4);
    expect(capturedTheme.cardTheme.color, const Color(0xfffef7ff));
    expect(capturedTheme.badgeTheme.backgroundColor, const Color(0xff006a6a));
    expect(capturedTheme.badgeTheme.textColor, const Color(0xffffffff));
    expect(capturedTheme.badgeTheme.smallSize, 0);
    expect(capturedTheme.badgeTheme.largeSize, 18);
    expect(capturedTheme.badgeTheme.textStyle?.fontSize, 11);
    expect(capturedTheme.badgeTheme.textStyle?.fontWeight, FontWeight.w700);
    expect(
      capturedTheme.badgeTheme.padding,
      const EdgeInsets.symmetric(horizontal: 6),
    );
    expect(capturedTheme.badgeTheme.alignment, Alignment.topRight);
    expect(capturedTheme.badgeTheme.offset, const Offset(3, -5));
    expect(capturedTheme.bannerTheme.backgroundColor, const Color(0xfff4eff4));
    expect(capturedTheme.bannerTheme.surfaceTintColor, const Color(0xfffffbfe));
    expect(capturedTheme.bannerTheme.shadowColor, const Color(0x22000000));
    expect(capturedTheme.bannerTheme.dividerColor, const Color(0xffe7e0ec));
    expect(capturedTheme.bannerTheme.contentTextStyle?.fontSize, 14);
    expect(
      capturedTheme.bannerTheme.contentTextStyle?.color,
      const Color(0xff1d1b20),
    );
    expect(capturedTheme.bannerTheme.elevation, 0);
    expect(
      capturedTheme.bannerTheme.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
    expect(
      capturedTheme.bannerTheme.leadingPadding,
      const EdgeInsets.only(left: 16, right: 8),
    );
    final legacyButtonTheme = capturedTheme.buttonTheme;
    final enabledLegacyButton = MaterialButton(
      onPressed: () {},
      child: const Text('Enabled'),
    );
    final disabledLegacyButton = const MaterialButton(
      onPressed: null,
      child: Text('Disabled'),
    );
    expect(legacyButtonTheme.textTheme, ButtonTextTheme.normal);
    expect(legacyButtonTheme.minWidth, 64);
    expect(legacyButtonTheme.height, 38);
    expect(
      legacyButtonTheme.padding,
      const EdgeInsets.symmetric(horizontal: 14),
    );
    expect(legacyButtonTheme.shape, isA<RoundedRectangleBorder>());
    expect(
      legacyButtonTheme.layoutBehavior,
      ButtonBarLayoutBehavior.constrained,
    );
    expect(legacyButtonTheme.alignedDropdown, isTrue);
    expect(
      legacyButtonTheme.getDisabledFillColor(disabledLegacyButton),
      const Color(0xffcac4d0),
    );
    expect(
      legacyButtonTheme.getFocusColor(enabledLegacyButton),
      const Color(0x22006a6a),
    );
    expect(
      legacyButtonTheme.getHoverColor(enabledLegacyButton),
      const Color(0x11006a6a),
    );
    expect(
      legacyButtonTheme.getHighlightColor(enabledLegacyButton),
      const Color(0x22006a6a),
    );
    expect(
      legacyButtonTheme.getSplashColor(enabledLegacyButton),
      const Color(0x33006a6a),
    );
    expect(
      legacyButtonTheme.getMaterialTapTargetSize(enabledLegacyButton),
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(capturedTheme.scrollbarTheme.thumbVisibility?.resolve({}), isTrue);
    expect(capturedTheme.scrollbarTheme.trackVisibility?.resolve({}), isFalse);
    expect(
      capturedTheme.scrollbarTheme.trackVisibility?.resolve({
        WidgetState.hovered,
      }),
      isTrue,
    );
    expect(capturedTheme.scrollbarTheme.thickness?.resolve({}), 0);
    expect(
      capturedTheme.scrollbarTheme.thickness?.resolve({WidgetState.hovered}),
      8,
    );
    expect(capturedTheme.scrollbarTheme.radius, Radius.zero);
    expect(
      capturedTheme.scrollbarTheme.thumbColor?.resolve({}),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.scrollbarTheme.thumbColor?.resolve({WidgetState.dragged}),
      const Color(0xff984061),
    );
    expect(
      capturedTheme.scrollbarTheme.trackColor?.resolve({WidgetState.hovered}),
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.scrollbarTheme.trackBorderColor?.resolve({
        WidgetState.hovered,
      }),
      const Color(0xff79747e),
    );
    expect(capturedTheme.scrollbarTheme.crossAxisMargin, 0);
    expect(capturedTheme.scrollbarTheme.mainAxisMargin, 3);
    expect(capturedTheme.scrollbarTheme.minThumbLength, 0);
    expect(capturedTheme.scrollbarTheme.interactive, isFalse);
    expect(
      capturedTheme.carouselViewTheme.backgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.carouselViewTheme.elevation, 0);
    expect(
      capturedTheme.carouselViewTheme.overlayColor?.resolve({
        WidgetState.pressed,
      }),
      const Color(0x11006a6a),
    );
    expect(
      capturedTheme.carouselViewTheme.shape,
      isA<RoundedRectangleBorder>(),
    );
    expect(capturedTheme.carouselViewTheme.padding, const EdgeInsets.all(6));
    expect(capturedTheme.carouselViewTheme.itemClipBehavior, Clip.antiAlias);
    expect(capturedTheme.chipTheme.color?.resolve({}), const Color(0xfff4eff4));
    expect(capturedTheme.chipTheme.backgroundColor, const Color(0xfffffbfe));
    expect(capturedTheme.chipTheme.labelStyle?.fontSize, 13);
    expect(capturedTheme.chipTheme.labelStyle?.fontWeight, FontWeight.w600);
    expect(
      capturedTheme.chipTheme.avatarBoxConstraints,
      const BoxConstraints(minWidth: 22, minHeight: 22),
    );
    expect(
      capturedTheme.chipTheme.deleteIconBoxConstraints,
      const BoxConstraints(minWidth: 18, minHeight: 18),
    );
    expect(capturedTheme.chipTheme.elevation, 0);
    expect(capturedTheme.chipTheme.pressElevation, 5);
    expect(
      capturedTheme.checkboxTheme.fillColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.checkboxTheme.checkColor?.resolve({}),
      const Color(0xffffffff),
    );
    expect(
      capturedTheme.checkboxTheme.materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(capturedTheme.checkboxTheme.visualDensity, VisualDensity.compact);
    expect(capturedTheme.checkboxTheme.shape, isA<RoundedRectangleBorder>());
    expect(capturedTheme.checkboxTheme.side?.color, const Color(0xff79747e));
    expect(
      capturedTheme.radioTheme.fillColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.radioTheme.backgroundColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.radioTheme.innerRadius?.resolve({}), 5);
    expect(
      capturedTheme.radioTheme.materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(capturedTheme.radioTheme.visualDensity, VisualDensity.compact);
    expect(capturedTheme.radioTheme.side?.width, 1.2);
    expect(
      capturedTheme.switchTheme.thumbColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.switchTheme.trackColor?.resolve({}),
      const Color(0xffe7e0ec),
    );
    expect(capturedTheme.switchTheme.trackOutlineWidth?.resolve({}), 2);
    expect(
      capturedTheme.switchTheme.materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(
      capturedTheme.switchTheme.thumbIcon?.resolve({
        WidgetState.selected,
      })?.icon,
      Icons.check,
    );
    expect(
      capturedTheme.switchTheme.padding,
      const EdgeInsets.symmetric(horizontal: 8),
    );
    expect(capturedTheme.sliderTheme.trackHeight, 6);
    expect(capturedTheme.sliderTheme.activeTrackColor, const Color(0xff006a6a));
    expect(
      capturedTheme.sliderTheme.inactiveTrackColor,
      const Color(0xffe7e0ec),
    );
    expect(
      capturedTheme.sliderTheme.secondaryActiveTrackColor,
      const Color(0xff80cbc4),
    );
    expect(capturedTheme.sliderTheme.thumbColor, const Color(0xff006a6a));
    expect(capturedTheme.sliderTheme.overlayColor, const Color(0x33006a6a));
    expect(
      capturedTheme.sliderTheme.valueIndicatorColor,
      const Color(0xff1d1b20),
    );
    expect(capturedTheme.sliderTheme.valueIndicatorTextStyle?.fontSize, 12);
    expect(
      capturedTheme.sliderTheme.showValueIndicator,
      ShowValueIndicator.alwaysVisible,
    );
    expect(capturedTheme.sliderTheme.minThumbSeparation, 8);
    expect(
      capturedTheme.sliderTheme.mouseCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(
      capturedTheme.sliderTheme.allowedInteraction,
      SliderInteraction.slideThumb,
    );
    expect(
      capturedTheme.sliderTheme.padding,
      const EdgeInsets.symmetric(horizontal: 10),
    );
    expect(
      capturedTheme.sliderTheme.thumbSize?.resolve({}),
      const Size(20, 20),
    );
    expect(capturedTheme.sliderTheme.trackGap, 2);
    expect(capturedTheme.segmentedButtonTheme.selectedIcon, isA<Icon>());
    expect(
      (capturedTheme.segmentedButtonTheme.selectedIcon! as Icon).icon,
      Icons.check,
    );
    final segmentedStyle = capturedTheme.segmentedButtonTheme.style!;
    expect(
      segmentedStyle.backgroundColor?.resolve({}),
      const Color(0xfff4eff4),
    );
    expect(
      segmentedStyle.foregroundColor?.resolve({}),
      const Color(0xff1d1b20),
    );
    expect(
      segmentedStyle.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
    expect(segmentedStyle.side?.resolve({})?.color, const Color(0xff79747e));
    expect(segmentedStyle.shape?.resolve({}), isA<RoundedRectangleBorder>());
    expect(capturedTheme.dropdownMenuTheme.textStyle?.fontSize, 15);
    expect(
      capturedTheme.dropdownMenuTheme.textStyle?.fontWeight,
      FontWeight.w500,
    );
    expect(
      capturedTheme.dropdownMenuTheme.inputDecorationTheme?.filled,
      isTrue,
    );
    expect(
      capturedTheme.dropdownMenuTheme.inputDecorationTheme?.fillColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(
      capturedTheme.dropdownMenuTheme.menuStyle?.padding?.resolve({}),
      const EdgeInsets.symmetric(vertical: 6),
    );
    expect(
      capturedTheme.dropdownMenuTheme.menuStyle?.shape?.resolve({}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.dropdownMenuTheme.disabledColor,
      const Color(0xff79747e),
    );
    expect(capturedTheme.popupMenuTheme.color, const Color(0xfffffbfe));
    expect(capturedTheme.popupMenuTheme.shape, isA<RoundedRectangleBorder>());
    expect(
      capturedTheme.popupMenuTheme.menuPadding,
      const EdgeInsets.symmetric(vertical: 4),
    );
    expect(capturedTheme.popupMenuTheme.elevation, 3);
    expect(capturedTheme.popupMenuTheme.shadowColor, const Color(0x33000000));
    expect(
      capturedTheme.popupMenuTheme.surfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(capturedTheme.popupMenuTheme.textStyle?.fontSize, 13);
    expect(
      capturedTheme.popupMenuTheme.labelTextStyle?.resolve({
        WidgetState.disabled,
      })?.color,
      const Color(0xff79747e),
    );
    expect(capturedTheme.popupMenuTheme.enableFeedback, isFalse);
    expect(
      capturedTheme.popupMenuTheme.mouseCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(capturedTheme.popupMenuTheme.position, PopupMenuPosition.under);
    expect(capturedTheme.popupMenuTheme.iconColor, const Color(0xff006a6a));
    expect(capturedTheme.popupMenuTheme.iconSize, 22);
    expect(capturedTheme.dataTableTheme.decoration, isA<BoxDecoration>());
    expect(
      capturedTheme.dataTableTheme.dataRowColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0x11006a6a),
    );
    expect(capturedTheme.dataTableTheme.dataRowMinHeight, 44);
    expect(capturedTheme.dataTableTheme.dataRowMaxHeight, 44);
    expect(capturedTheme.dataTableTheme.dataTextStyle?.fontSize, 13);
    expect(
      capturedTheme.dataTableTheme.headingRowColor?.resolve({}),
      const Color(0xfff4eff4),
    );
    expect(capturedTheme.dataTableTheme.headingRowHeight, 52);
    expect(
      capturedTheme.dataTableTheme.headingTextStyle?.fontWeight,
      FontWeight.w600,
    );
    expect(capturedTheme.dataTableTheme.horizontalMargin, 16);
    expect(capturedTheme.dataTableTheme.columnSpacing, 24);
    expect(capturedTheme.dataTableTheme.dividerThickness, 0);
    expect(capturedTheme.dataTableTheme.checkboxHorizontalMargin, 10);
    expect(
      capturedTheme.dataTableTheme.headingCellCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(
      capturedTheme.dataTableTheme.dataRowCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(
      capturedTheme.dataTableTheme.headingRowAlignment,
      MainAxisAlignment.center,
    );
    expect(
      capturedTheme.datePickerTheme.backgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.datePickerTheme.elevation, 0);
    expect(capturedTheme.datePickerTheme.shadowColor, const Color(0x22000000));
    expect(
      capturedTheme.datePickerTheme.surfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(capturedTheme.datePickerTheme.shape, isA<RoundedRectangleBorder>());
    expect(
      capturedTheme.datePickerTheme.headerBackgroundColor,
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.headerForegroundColor,
      const Color(0xffffffff),
    );
    expect(capturedTheme.datePickerTheme.headerHeadlineStyle?.fontSize, 28);
    expect(
      capturedTheme.datePickerTheme.headerHelpStyle?.fontWeight,
      FontWeight.w600,
    );
    expect(capturedTheme.datePickerTheme.weekdayStyle?.fontSize, 12);
    expect(capturedTheme.datePickerTheme.dayStyle?.fontSize, 14);
    expect(
      capturedTheme.datePickerTheme.dayForegroundColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0xffffffff),
    );
    expect(
      capturedTheme.datePickerTheme.dayForegroundColor?.resolve({}),
      const Color(0xff1d1b20),
    );
    expect(
      capturedTheme.datePickerTheme.dayBackgroundColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.dayOverlayColor?.resolve({
        WidgetState.hovered,
      }),
      const Color(0x11006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.dayShape?.resolve({}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.datePickerTheme.todayForegroundColor?.resolve({}),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.todayBackgroundColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0xffd0bcff),
    );
    expect(
      capturedTheme.datePickerTheme.todayBorder?.color,
      const Color(0xff006a6a),
    );
    expect(capturedTheme.datePickerTheme.todayBorder?.width, 1.5);
    expect(capturedTheme.datePickerTheme.yearStyle?.fontSize, 15);
    expect(
      capturedTheme.datePickerTheme.yearForegroundColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0xffffffff),
    );
    expect(
      capturedTheme.datePickerTheme.yearBackgroundColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.yearOverlayColor?.resolve({
        WidgetState.pressed,
      }),
      const Color(0x22006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.yearShape?.resolve({}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerBackgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.datePickerTheme.rangePickerElevation, 0);
    expect(
      capturedTheme.datePickerTheme.rangePickerShadowColor,
      const Color(0x22000000),
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerSurfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerShape,
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerHeaderBackgroundColor,
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerHeaderForegroundColor,
      const Color(0xffffffff),
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerHeaderHeadlineStyle?.fontSize,
      24,
    );
    expect(
      capturedTheme.datePickerTheme.rangePickerHeaderHelpStyle?.fontSize,
      13,
    );
    expect(
      capturedTheme.datePickerTheme.rangeSelectionBackgroundColor,
      const Color(0x22006a6a),
    );
    expect(
      capturedTheme.datePickerTheme.rangeSelectionOverlayColor?.resolve({
        WidgetState.pressed,
      }),
      const Color(0x33006a6a),
    );
    expect(capturedTheme.datePickerTheme.dividerColor, const Color(0xffe7e0ec));
    expect(capturedTheme.datePickerTheme.inputDecorationTheme?.filled, isTrue);
    expect(
      capturedTheme.datePickerTheme.inputDecorationTheme?.fillColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.datePickerTheme.cancelButtonStyle?.foregroundColor?.resolve(
        {},
      ),
      const Color(0xff984061),
    );
    expect(
      capturedTheme.datePickerTheme.confirmButtonStyle?.foregroundColor
          ?.resolve({}),
      const Color(0xff006a6a),
    );
    expect(capturedTheme.datePickerTheme.locale, const Locale('zh', 'CN'));
    expect(capturedTheme.datePickerTheme.toggleButtonTextStyle?.fontSize, 13);
    expect(
      capturedTheme.datePickerTheme.subHeaderForegroundColor,
      const Color(0xff49454f),
    );
    expect(
      capturedTheme.menuTheme.style?.backgroundColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(
      capturedTheme.menuTheme.style?.surfaceTintColor?.resolve({}),
      const Color(0xfff4eff4),
    );
    expect(capturedTheme.menuTheme.style?.elevation?.resolve({}), 2);
    expect(
      capturedTheme.menuTheme.style?.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 4),
    );
    expect(
      capturedTheme.menuTheme.style?.minimumSize?.resolve({}),
      const Size(120, 40),
    );
    expect(
      capturedTheme.menuTheme.style?.side?.resolve({})?.color,
      const Color(0xff79747e),
    );
    expect(
      capturedTheme.menuTheme.style?.shape?.resolve({}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.menuTheme.style?.mouseCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(capturedTheme.menuTheme.style?.visualDensity, VisualDensity.compact);
    expect(capturedTheme.menuTheme.style?.alignment, Alignment.bottomLeft);
    expect(
      (capturedTheme.menuTheme.submenuIcon?.resolve({})! as Icon).icon,
      Icons.chevron_right,
    );
    expect(
      capturedTheme.menuBarTheme.style?.backgroundColor?.resolve({}),
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.menuButtonTheme.style?.foregroundColor?.resolve({}),
      const Color(0xff1d1b20),
    );
    expect(
      capturedTheme.menuButtonTheme.style?.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
    expect(capturedTheme.progressIndicatorTheme.color, const Color(0xff006a6a));
    expect(
      capturedTheme.progressIndicatorTheme.linearTrackColor,
      const Color(0xffe7e0ec),
    );
    expect(capturedTheme.progressIndicatorTheme.linearMinHeight, 5);
    expect(
      capturedTheme.progressIndicatorTheme.circularTrackColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.progressIndicatorTheme.refreshBackgroundColor,
      const Color(0xfffffbfe),
    );
    expect(
      capturedTheme.progressIndicatorTheme.borderRadius,
      BorderRadius.circular(6),
    );
    expect(
      capturedTheme.progressIndicatorTheme.stopIndicatorColor,
      const Color(0xffb3261e),
    );
    expect(capturedTheme.progressIndicatorTheme.stopIndicatorRadius, 3);
    expect(capturedTheme.progressIndicatorTheme.strokeWidth, 4);
    expect(capturedTheme.progressIndicatorTheme.strokeAlign, -1);
    expect(capturedTheme.progressIndicatorTheme.strokeCap, ui.StrokeCap.round);
    expect(
      capturedTheme.progressIndicatorTheme.constraints,
      const BoxConstraints.tightFor(width: 44, height: 44),
    );
    expect(capturedTheme.progressIndicatorTheme.trackGap, 2);
    expect(
      capturedTheme.progressIndicatorTheme.circularTrackPadding,
      const EdgeInsets.all(4),
    );
    expect(
      capturedTheme.listTileTheme.contentPadding,
      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
    expect(capturedTheme.listTileTheme.style, ListTileStyle.drawer);
    expect(capturedTheme.listTileTheme.visualDensity, VisualDensity.compact);
    expect(
      capturedTheme.listTileTheme.titleAlignment,
      ListTileTitleAlignment.center,
    );
    expect(
      capturedTheme.listTileTheme.controlAffinity,
      ListTileControlAffinity.leading,
    );
    expect(capturedTheme.listTileTheme.isThreeLine, isTrue);
    expect(capturedTheme.listTileTheme.minTileHeight, 56);
    expect(
      capturedTheme.expansionTileTheme.backgroundColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.expansionTileTheme.collapsedBackgroundColor,
      const Color(0xfffffbfe),
    );
    expect(
      capturedTheme.expansionTileTheme.tilePadding,
      const EdgeInsets.symmetric(horizontal: 24),
    );
    expect(
      capturedTheme.expansionTileTheme.expandedAlignment,
      Alignment.centerLeft,
    );
    expect(
      capturedTheme.expansionTileTheme.childrenPadding,
      const EdgeInsets.only(left: 16, right: 16, bottom: 12),
    );
    expect(capturedTheme.expansionTileTheme.iconColor, const Color(0xff006a6a));
    expect(
      capturedTheme.expansionTileTheme.collapsedIconColor,
      const Color(0xff49454f),
    );
    expect(
      capturedTheme.expansionTileTheme.shape,
      isA<RoundedRectangleBorder>(),
    );
    expect(capturedTheme.expansionTileTheme.clipBehavior, Clip.antiAlias);
    expect(
      capturedTheme.expansionTileTheme.expansionAnimationStyle?.duration,
      const Duration(milliseconds: 180),
    );
    expect(
      capturedTheme.expansionTileTheme.expansionAnimationStyle?.reverseDuration,
      const Duration(milliseconds: 120),
    );
    expect(capturedTheme.inputDecorationTheme.filled, isTrue);
    expect(
      capturedTheme.inputDecorationTheme.floatingLabelAlignment,
      FloatingLabelAlignment.center,
    );
    expect(
      capturedTheme.inputDecorationTheme.hintFadeDuration,
      const Duration(milliseconds: 120),
    );
    expect(
      capturedTheme.inputDecorationTheme.prefixIconConstraints,
      const BoxConstraints(minWidth: 32, minHeight: 30),
    );
    expect(
      capturedTheme.inputDecorationTheme.suffixIconConstraints,
      const BoxConstraints(minWidth: 34, minHeight: 32),
    );
    expect(
      capturedTheme.inputDecorationTheme.activeIndicatorBorder?.color,
      const Color(0xff006a6a),
    );
    expect(capturedTheme.inputDecorationTheme.activeIndicatorBorder?.width, 2);
    expect(
      capturedTheme.inputDecorationTheme.outlineBorder?.color,
      const Color(0xff6750a4),
    );
    expect(capturedTheme.inputDecorationTheme.outlineBorder?.width, 1.5);
    expect(
      capturedTheme.inputDecorationTheme.border,
      isA<OutlineInputBorder>(),
    );
    final inputBorder =
        capturedTheme.inputDecorationTheme.border! as OutlineInputBorder;
    expect(inputBorder.borderRadius, BorderRadius.circular(12));
    expect(inputBorder.borderSide.color, const Color(0xff79747e));
    expect(inputBorder.borderSide.width, 1);
    expect(
      capturedTheme.inputDecorationTheme.visualDensity,
      VisualDensity.compact,
    );
    expect(
      capturedTheme.textSelectionTheme.cursorColor,
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.textSelectionTheme.selectionColor,
      const Color(0x33006a6a),
    );
    expect(
      capturedTheme.textSelectionTheme.selectionHandleColor,
      const Color(0xff984061),
    );
    expect(
      capturedTheme.elevatedButtonTheme.style?.backgroundColor?.resolve(
        const <WidgetState>{},
      ),
      const Color(0xff006a6a),
    );
    final elevatedStyle = capturedTheme.elevatedButtonTheme.style!;
    expect(elevatedStyle.textStyle?.resolve({})?.fontSize, 16);
    expect(elevatedStyle.textStyle?.resolve({})?.fontWeight, FontWeight.w600);
    expect(elevatedStyle.iconColor?.resolve({}), const Color(0xffffcc00));
    expect(elevatedStyle.iconSize?.resolve({}), 20);
    expect(elevatedStyle.iconAlignment, IconAlignment.end);
    expect(elevatedStyle.visualDensity, VisualDensity.comfortable);
    expect(elevatedStyle.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(elevatedStyle.animationDuration, const Duration(milliseconds: 180));
    expect(elevatedStyle.enableFeedback, isFalse);
    expect(elevatedStyle.alignment, Alignment.centerRight);
    expect(
      capturedTheme.navigationBarTheme.labelBehavior,
      NavigationDestinationLabelBehavior.alwaysHide,
    );
    expect(
      capturedTheme.navigationBarTheme.backgroundColor,
      const Color(0xfffef7ff),
    );
    expect(
      capturedTheme.navigationBarTheme.shadowColor,
      const Color(0x33000000),
    );
    expect(
      capturedTheme.navigationBarTheme.surfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.navigationBarTheme.indicatorColor,
      const Color(0xffd0bcff),
    );
    expect(
      capturedTheme.navigationBarTheme.indicatorShape,
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.navigationBarTheme.labelTextStyle?.resolve({})?.fontSize,
      11,
    );
    expect(
      capturedTheme.navigationBarTheme.iconTheme?.resolve({
        WidgetState.selected,
      })?.color,
      const Color(0xff006a6a),
    );
    expect(capturedTheme.navigationBarTheme.iconTheme?.resolve({})?.size, 22);
    expect(
      capturedTheme.navigationBarTheme.overlayColor?.resolve({
        WidgetState.pressed,
      }),
      const Color(0x22006a6a),
    );
    expect(
      capturedTheme.navigationBarTheme.labelPadding,
      const EdgeInsets.symmetric(horizontal: 6),
    );
    expect(capturedTheme.navigationDrawerTheme.tileHeight, 64);
    expect(
      capturedTheme.navigationDrawerTheme.backgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.navigationDrawerTheme.elevation, 0);
    expect(
      capturedTheme.navigationDrawerTheme.shadowColor,
      const Color(0x22000000),
    );
    expect(
      capturedTheme.navigationDrawerTheme.surfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.navigationDrawerTheme.indicatorColor,
      const Color(0xffd0bcff),
    );
    expect(
      capturedTheme.navigationDrawerTheme.indicatorShape,
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.navigationDrawerTheme.indicatorSize,
      const Size(56, 32),
    );
    expect(
      capturedTheme.navigationDrawerTheme.labelTextStyle?.resolve({})?.fontSize,
      13,
    );
    expect(
      capturedTheme.navigationDrawerTheme.iconTheme?.resolve({
        WidgetState.selected,
      })?.color,
      const Color(0xff006a6a),
    );
    expect(capturedTheme.searchBarTheme.elevation?.resolve({}), 0);
    expect(
      capturedTheme.searchBarTheme.elevation?.resolve({WidgetState.hovered}),
      5,
    );
    expect(
      capturedTheme.searchBarTheme.backgroundColor?.resolve({}),
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.searchBarTheme.shadowColor?.resolve({}),
      const Color(0x33000000),
    );
    expect(
      capturedTheme.searchBarTheme.surfaceTintColor?.resolve({}),
      const Color(0xfffffbfe),
    );
    expect(
      capturedTheme.searchBarTheme.overlayColor?.resolve({WidgetState.pressed}),
      const Color(0x22006a6a),
    );
    expect(
      capturedTheme.searchBarTheme.side?.resolve({})?.color,
      const Color(0xff79747e),
    );
    expect(capturedTheme.searchBarTheme.side?.resolve({})?.width, 1.5);
    expect(
      capturedTheme.searchBarTheme.shape?.resolve({}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      capturedTheme.searchBarTheme.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
    expect(capturedTheme.searchBarTheme.textStyle?.resolve({})?.fontSize, 14);
    expect(
      capturedTheme.searchBarTheme.textStyle?.resolve({})?.color,
      const Color(0xff1d1b20),
    );
    expect(capturedTheme.searchBarTheme.hintStyle?.resolve({})?.fontSize, 13);
    expect(
      capturedTheme.searchBarTheme.constraints,
      const BoxConstraints(minWidth: 120, minHeight: 48),
    );
    expect(
      capturedTheme.searchBarTheme.textCapitalization,
      TextCapitalization.words,
    );
    expect(
      capturedTheme.searchViewTheme.backgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.searchViewTheme.elevation, 0);
    expect(
      capturedTheme.searchViewTheme.surfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(capturedTheme.searchViewTheme.side?.color, const Color(0xff79747e));
    expect(capturedTheme.searchViewTheme.side?.width, 1);
    expect(capturedTheme.searchViewTheme.shape, isA<RoundedRectangleBorder>());
    expect(capturedTheme.searchViewTheme.headerHeight, 0);
    expect(capturedTheme.searchViewTheme.headerTextStyle?.fontSize, 16);
    expect(
      capturedTheme.searchViewTheme.headerTextStyle?.fontWeight,
      FontWeight.w600,
    );
    expect(capturedTheme.searchViewTheme.headerHintStyle?.fontSize, 15);
    expect(
      capturedTheme.searchViewTheme.headerHintStyle?.color,
      const Color(0xff49454f),
    );
    expect(
      capturedTheme.searchViewTheme.constraints,
      const BoxConstraints(minWidth: 240, maxWidth: 640),
    );
    expect(
      capturedTheme.searchViewTheme.padding,
      const EdgeInsets.only(left: 12, right: 12, bottom: 8),
    );
    expect(
      capturedTheme.searchViewTheme.barPadding,
      const EdgeInsets.only(left: 8, right: 8, top: 6),
    );
    expect(capturedTheme.searchViewTheme.shrinkWrap, isTrue);
    expect(capturedTheme.searchViewTheme.dividerColor, const Color(0xffe7e0ec));
    expect(capturedTheme.dividerTheme.color, const Color(0xff79747e));
    expect(capturedTheme.dividerTheme.space, 0);
    expect(capturedTheme.dividerTheme.thickness, 0);
    expect(capturedTheme.dividerTheme.indent, 12);
    expect(capturedTheme.dividerTheme.endIndent, 8);
    expect(capturedTheme.dividerTheme.radius, BorderRadius.circular(3));
    expect(
      capturedTheme.bottomNavigationBarTheme.backgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.bottomNavigationBarTheme.elevation, 0);
    expect(
      capturedTheme.bottomNavigationBarTheme.selectedIconTheme?.color,
      const Color(0xff006a6a),
    );
    expect(capturedTheme.bottomNavigationBarTheme.selectedIconTheme?.size, 28);
    expect(
      capturedTheme.bottomNavigationBarTheme.unselectedIconTheme?.color,
      const Color(0xff49454f),
    );
    expect(
      capturedTheme.bottomNavigationBarTheme.selectedItemColor,
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.bottomNavigationBarTheme.unselectedItemColor,
      const Color(0xff49454f),
    );
    expect(
      capturedTheme.bottomNavigationBarTheme.selectedLabelStyle?.fontSize,
      12,
    );
    expect(
      capturedTheme.bottomNavigationBarTheme.unselectedLabelStyle?.fontSize,
      10,
    );
    expect(capturedTheme.bottomNavigationBarTheme.showSelectedLabels, isTrue);
    expect(
      capturedTheme.bottomNavigationBarTheme.showUnselectedLabels,
      isFalse,
    );
    expect(
      capturedTheme.bottomNavigationBarTheme.type,
      BottomNavigationBarType.fixed,
    );
    expect(capturedTheme.bottomNavigationBarTheme.enableFeedback, isFalse);
    expect(
      capturedTheme.bottomNavigationBarTheme.landscapeLayout,
      BottomNavigationBarLandscapeLayout.centered,
    );
    expect(
      capturedTheme.bottomNavigationBarTheme.mouseCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(capturedTheme.bottomAppBarTheme.color, const Color(0xfffffbfe));
    expect(capturedTheme.bottomAppBarTheme.elevation, 0);
    expect(
      capturedTheme.bottomAppBarTheme.shape,
      isA<CircularNotchedRectangle>(),
    );
    expect(capturedTheme.bottomAppBarTheme.height, 68);
    expect(
      capturedTheme.bottomAppBarTheme.surfaceTintColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.bottomAppBarTheme.shadowColor,
      const Color(0x22000000),
    );
    expect(
      capturedTheme.bottomAppBarTheme.padding,
      const EdgeInsets.symmetric(horizontal: 16),
    );
    expect(capturedTheme.snackBarTheme.behavior, SnackBarBehavior.floating);
    expect(capturedTheme.snackBarTheme.showCloseIcon, isTrue);
    expect(capturedTheme.dialogTheme.backgroundColor, const Color(0xfffffbfe));
    expect(capturedTheme.bottomSheetTheme.showDragHandle, isTrue);
    expect(
      capturedTheme.timePickerTheme.backgroundColor,
      const Color(0xfffffbfe),
    );
    expect(capturedTheme.timePickerTheme.elevation, 0);
    expect(capturedTheme.timePickerTheme.shape, isA<RoundedRectangleBorder>());
    expect(capturedTheme.timePickerTheme.padding, const EdgeInsets.all(20));
    expect(
      capturedTheme.timePickerTheme.entryModeIconColor,
      const Color(0xff006a6a),
    );
    expect(capturedTheme.timePickerTheme.helpTextStyle?.fontSize, 12);
    expect(
      WidgetStateProperty.resolveAs<Color>(
        capturedTheme.timePickerTheme.hourMinuteColor!,
        {WidgetState.selected},
      ),
      const Color(0x22006a6a),
    );
    expect(
      WidgetStateProperty.resolveAs<Color>(
        capturedTheme.timePickerTheme.hourMinuteColor!,
        {},
      ),
      const Color(0xfff4eff4),
    );
    expect(
      WidgetStateProperty.resolveAs<Color>(
        capturedTheme.timePickerTheme.hourMinuteTextColor!,
        {WidgetState.selected},
      ),
      const Color(0xff006a6a),
    );
    expect(capturedTheme.timePickerTheme.hourMinuteTextStyle?.fontSize, 46);
    expect(
      capturedTheme.timePickerTheme.hourMinuteShape,
      isA<RoundedRectangleBorder>(),
    );
    expect(
      WidgetStateProperty.resolveAs<Color>(
        capturedTheme.timePickerTheme.dayPeriodColor!,
        {WidgetState.selected},
      ),
      const Color(0x22006a6a),
    );
    expect(
      WidgetStateProperty.resolveAs<Color>(
        capturedTheme.timePickerTheme.dayPeriodTextColor!,
        {},
      ),
      const Color(0xff79747e),
    );
    expect(
      capturedTheme.timePickerTheme.dayPeriodBorderSide?.color,
      const Color(0xff79747e),
    );
    expect(
      capturedTheme.timePickerTheme.dayPeriodShape,
      isA<RoundedRectangleBorder>(),
    );
    expect(capturedTheme.timePickerTheme.dayPeriodTextStyle?.fontSize, 13);
    expect(
      capturedTheme.timePickerTheme.dialBackgroundColor,
      const Color(0xfff4eff4),
    );
    expect(
      capturedTheme.timePickerTheme.dialHandColor,
      const Color(0xff006a6a),
    );
    expect(
      WidgetStateProperty.resolveAs<Color>(
        capturedTheme.timePickerTheme.dialTextColor!,
        {WidgetState.selected},
      ),
      const Color(0xffffffff),
    );
    expect(capturedTheme.timePickerTheme.dialTextStyle?.fontSize, 14);
    expect(
      capturedTheme.timePickerTheme.timeSelectorSeparatorColor?.resolve({
        WidgetState.selected,
      }),
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.timePickerTheme.timeSelectorSeparatorTextStyle
          ?.resolve({})
          ?.fontSize,
      44,
    );
    expect(capturedTheme.timePickerTheme.inputDecorationTheme?.filled, isTrue);
    expect(
      capturedTheme.timePickerTheme.cancelButtonStyle?.foregroundColor?.resolve(
        {},
      ),
      const Color(0xff984061),
    );
    expect(
      capturedTheme.timePickerTheme.confirmButtonStyle?.foregroundColor
          ?.resolve({}),
      const Color(0xff006a6a),
    );
    expect(capturedTheme.toggleButtonsTheme.textStyle?.fontSize, 14);
    expect(
      capturedTheme.toggleButtonsTheme.textStyle?.fontWeight,
      FontWeight.w600,
    );
    expect(
      capturedTheme.toggleButtonsTheme.constraints,
      const BoxConstraints(minWidth: 44, minHeight: 40),
    );
    expect(capturedTheme.toggleButtonsTheme.color, const Color(0xff1d1b20));
    expect(
      capturedTheme.toggleButtonsTheme.selectedColor,
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.toggleButtonsTheme.disabledColor,
      const Color(0xffcac4d0),
    );
    expect(capturedTheme.toggleButtonsTheme.fillColor, const Color(0x11006a6a));
    expect(
      capturedTheme.toggleButtonsTheme.focusColor,
      const Color(0x22006a6a),
    );
    expect(
      capturedTheme.toggleButtonsTheme.highlightColor,
      const Color(0x11006a6a),
    );
    expect(
      capturedTheme.toggleButtonsTheme.hoverColor,
      const Color(0x11006a6a),
    );
    expect(
      capturedTheme.toggleButtonsTheme.splashColor,
      const Color(0x22006a6a),
    );
    expect(
      capturedTheme.toggleButtonsTheme.borderColor,
      const Color(0xff79747e),
    );
    expect(
      capturedTheme.toggleButtonsTheme.selectedBorderColor,
      const Color(0xff006a6a),
    );
    expect(
      capturedTheme.toggleButtonsTheme.disabledBorderColor,
      const Color(0xffcac4d0),
    );
    expect(
      capturedTheme.toggleButtonsTheme.borderRadius,
      BorderRadius.circular(18),
    );
    expect(capturedTheme.toggleButtonsTheme.borderWidth, 0);
    expect(
      capturedTheme.tooltipTheme.constraints,
      const BoxConstraints(minHeight: 28),
    );
    expect(
      capturedTheme.tooltipTheme.padding,
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
    expect(capturedTheme.tooltipTheme.margin, const EdgeInsets.all(4));
    expect(capturedTheme.tooltipTheme.verticalOffset, 0);
    expect(capturedTheme.tooltipTheme.preferBelow, isFalse);
    expect(capturedTheme.tooltipTheme.excludeFromSemantics, isTrue);
    expect(
      (capturedTheme.tooltipTheme.decoration as BoxDecoration).color,
      const Color(0xff1d1b20),
    );
    expect(capturedTheme.tooltipTheme.textStyle?.fontSize, 12);
    expect(
      capturedTheme.tooltipTheme.textStyle?.color,
      const Color(0xffffffff),
    );
    expect(capturedTheme.tooltipTheme.textAlign, TextAlign.center);
    expect(
      capturedTheme.tooltipTheme.waitDuration,
      const Duration(milliseconds: 100),
    );
    expect(capturedTheme.tooltipTheme.showDuration, const Duration(seconds: 2));
    expect(
      capturedTheme.tooltipTheme.exitDuration,
      const Duration(milliseconds: 40),
    );
    expect(capturedTheme.tooltipTheme.triggerMode, TooltipTriggerMode.tap);
    expect(capturedTheme.tooltipTheme.enableFeedback, isFalse);
  });

  testWidgets('validates text form fields with serializable rules', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'Form',
                'props': {
                  'onChanged': {
                    'type': 'Action',
                    'props': {'name': 'formChanged'},
                  },
                  'child': {
                    'type': 'TextFormField',
                    'props': {
                      'name': 'email',
                      'labelText': 'Email',
                      'textInputAction': 'done',
                      'validateOnSubmitted': true,
                      'validation': {
                        'required': true,
                        'requiredMessage': 'Email is required',
                        'email': true,
                        'emailMessage': 'Enter a valid email',
                      },
                      'onSubmit': {
                        'type': 'Action',
                        'props': {'name': 'emailSubmitted'},
                      },
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(
      actions.lastWhere((action) => action.name == 'emailSubmitted').payload,
      {'name': 'email', 'value': '', 'valid': false},
    );

    await tester.enterText(find.byType(TextFormField), 'bad-email');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(actions.map((action) => action.name), contains('formChanged'));
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(
      actions.lastWhere((action) => action.name == 'emailSubmitted').payload,
      {'name': 'email', 'value': 'bad-email', 'valid': false},
    );

    await tester.enterText(find.byType(TextFormField), 'hello@example.com');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Enter a valid email'), findsNothing);
    expect(
      actions.lastWhere((action) => action.name == 'emailSubmitted').payload,
      {'name': 'email', 'value': 'hello@example.com', 'valid': true},
    );
  });

  testWidgets('renders material search anchor suggestions and callbacks', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: renderer.buildWidget(context, {
                'type': 'SearchAnchor',
                'props': {
                  'hintText': 'Search demos',
                  'leading': {
                    'type': 'Icon',
                    'props': {'icon': 'search'},
                  },
                  'trailing': [
                    {
                      'type': 'Icon',
                      'props': {'icon': 'tune'},
                    },
                  ],
                  'enabled': true,
                  'constraints': {'minWidth': 180, 'maxWidth': 360},
                  'elevation': -3,
                  'backgroundColor': '#fffbfe',
                  'shadowColor': '#111111',
                  'surfaceTintColor': '#222222',
                  'overlayColor': '#333333',
                  'side': {'color': '#444444', 'width': 1.5},
                  'shape': {'borderRadius': 18},
                  'padding': {'horizontal': 12, 'vertical': 6},
                  'textStyle': {'fontSize': 16, 'color': '#123456'},
                  'hintStyle': {'fontSize': 14, 'color': '#654321'},
                  'textCapitalization': 'words',
                  'autoFocus': false,
                  'readOnly': false,
                  'textInputAction': 'search',
                  'keyboardType': 'text',
                  'scrollPadding': {'all': 9},
                  'isFullScreen': false,
                  'viewLeading': {
                    'type': 'Icon',
                    'props': {'icon': 'arrow_back'},
                  },
                  'viewTrailing': [
                    {
                      'type': 'Icon',
                      'props': {'icon': 'close'},
                    },
                  ],
                  'viewHintText': 'Search all demos',
                  'viewBackgroundColor': '#f4eff4',
                  'viewElevation': -6,
                  'viewSurfaceTintColor': '#6750a4',
                  'viewSide': {'color': '#006a6a', 'width': 2},
                  'viewShape': {'borderRadius': 20},
                  'viewBarPadding': {'horizontal': 10},
                  'headerHeight': -72,
                  'headerTextStyle': {'fontSize': 18},
                  'headerHintStyle': {'fontSize': 13},
                  'dividerColor': '#79747e',
                  'viewConstraints': {'maxWidth': 500},
                  'viewPadding': {'all': 8},
                  'shrinkWrap': true,
                  'viewOnOpen': {
                    'type': 'Action',
                    'props': {'name': 'searchOpen'},
                  },
                  'viewOnChanged': {
                    'type': 'Action',
                    'props': {'name': 'searchChanged'},
                  },
                  'suggestions': [
                    {
                      'type': 'ListTile',
                      'props': {'label': 'Buttons'},
                    },
                    {
                      'type': 'ListTile',
                      'props': {'label': 'Cards'},
                    },
                  ],
                },
              }),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SearchBar), findsOneWidget);
    final anchor = tester.widget<SearchAnchor>(find.byType(SearchAnchor));
    expect(anchor.isFullScreen, isFalse);
    expect(anchor.viewHintText, 'Search all demos');
    expect(anchor.viewBackgroundColor, const Color(0xfff4eff4));
    expect(anchor.viewElevation, 0);
    expect(anchor.viewSurfaceTintColor, const Color(0xff6750a4));
    expect(anchor.viewSide?.color, const Color(0xff006a6a));
    expect(anchor.viewSide?.width, 2);
    expect(anchor.viewShape, isA<RoundedRectangleBorder>());
    expect(anchor.viewBarPadding, const EdgeInsets.symmetric(horizontal: 10));
    expect(anchor.headerHeight, 0);
    expect(anchor.headerTextStyle?.fontSize, 18);
    expect(anchor.headerHintStyle?.fontSize, 13);
    expect(anchor.dividerColor, const Color(0xff79747e));
    expect(anchor.viewConstraints?.maxWidth, 500);
    expect(anchor.viewPadding, const EdgeInsets.all(8));
    expect(anchor.shrinkWrap, isTrue);

    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(searchBar.hintText, 'Search demos');
    expect(searchBar.trailing, hasLength(1));
    expect(searchBar.enabled, isTrue);
    expect(searchBar.constraints?.minWidth, 180);
    expect(searchBar.constraints?.maxWidth, 360);
    expect(searchBar.elevation?.resolve({}), 0);
    expect(searchBar.backgroundColor?.resolve({}), const Color(0xfffffbfe));
    expect(searchBar.shadowColor?.resolve({}), const Color(0xff111111));
    expect(searchBar.surfaceTintColor?.resolve({}), const Color(0xff222222));
    expect(searchBar.overlayColor?.resolve({}), const Color(0xff333333));
    expect(searchBar.side?.resolve({})?.color, const Color(0xff444444));
    expect(searchBar.side?.resolve({})?.width, 1.5);
    expect(searchBar.shape?.resolve({}), isA<RoundedRectangleBorder>());
    expect(
      searchBar.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
    expect(searchBar.textStyle?.resolve({})?.fontSize, 16);
    expect(searchBar.textStyle?.resolve({})?.color, const Color(0xff123456));
    expect(searchBar.hintStyle?.resolve({})?.fontSize, 14);
    expect(searchBar.hintStyle?.resolve({})?.color, const Color(0xff654321));
    expect(searchBar.textCapitalization, TextCapitalization.words);
    expect(searchBar.autoFocus, isFalse);
    expect(searchBar.readOnly, isFalse);
    expect(searchBar.textInputAction, TextInputAction.search);
    expect(searchBar.keyboardType, TextInputType.text);
    expect(searchBar.scrollPadding, const EdgeInsets.all(9));

    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();

    expect(actions.map((action) => action.name), contains('searchOpen'));
    expect(find.text('Buttons'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).last, 'card');
    await tester.pump();

    expect(actions.last.name, 'searchChanged');
    expect(actions.last.payload, 'card');
  });

  testWidgets('renders material snack bars and dispatches actions', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'ScaffoldMessenger',
            'props': {
              'child': {
                'type': 'Scaffold',
                'props': {
                  'body': {
                    'type': 'Text',
                    'props': {'data': 'Host'},
                  },
                  'snackBar': {
                    'type': 'SnackBar',
                    'props': {
                      'content': {
                        'type': 'Text',
                        'props': {'data': 'Saved'},
                      },
                      'behavior': 'floating',
                      'hitTestBehavior': 'translucent',
                      'margin': {'all': 12},
                      'padding': {'horizontal': 18, 'vertical': 10},
                      'elevation': -4,
                      'actionOverflowThreshold': 1.4,
                      'showCloseIcon': true,
                      'clipBehavior': 'antiAlias',
                      'dismissDirection': 'startToEnd',
                      'duration': {'seconds': 2},
                      'action': {
                        'label': 'Undo',
                        'textColor': '#ff0000',
                        'backgroundColor': '#00ff00',
                        'disabledTextColor': '#888888',
                        'disabledBackgroundColor': '#222222',
                        'onPressed': {
                          'type': 'Action',
                          'props': {'name': 'undo'},
                        },
                      },
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(snackBar.hitTestBehavior, HitTestBehavior.translucent);
    expect(snackBar.elevation, 0);
    expect(snackBar.actionOverflowThreshold, 1);
    expect(snackBar.showCloseIcon, isTrue);
    expect(snackBar.clipBehavior, Clip.antiAlias);
    expect(snackBar.dismissDirection, DismissDirection.startToEnd);
    expect(snackBar.duration, const Duration(seconds: 2));
    expect(find.text('Saved'), findsOneWidget);

    final snackBarAction = tester.widget<SnackBarAction>(
      find.byType(SnackBarAction),
    );
    expect(snackBarAction.textColor, const Color(0xffff0000));
    expect(snackBarAction.backgroundColor, const Color(0xff00ff00));
    expect(snackBarAction.disabledTextColor, const Color(0xff888888));
    expect(snackBarAction.disabledBackgroundColor, const Color(0xff222222));

    snackBarAction.onPressed();
    await tester.pump();

    expect(actions.single.name, 'undo');
  });

  testWidgets('renders material bottom sheets safely', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'Text',
                'props': {'data': 'Body'},
              },
              'bottomSheet': {
                'type': 'BottomSheet',
                'props': {
                  'showDragHandle': true,
                  'backgroundColor': '#fef7ff',
                  'shape': {'borderRadius': 24},
                  'onClosing': {
                    'type': 'Action',
                    'props': {'name': 'closeSheet'},
                  },
                  'child': {
                    'type': 'Padding',
                    'props': {
                      'padding': {'all': 16},
                      'child': {
                        'type': 'Text',
                        'props': {'data': 'Persistent sheet'},
                      },
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('Persistent sheet'), findsOneWidget);
    final bottomSheet = tester.widget<BottomSheet>(
      find
          .ancestor(
            of: find.text('Persistent sheet'),
            matching: find.byType(BottomSheet),
          )
          .first,
    );
    expect(bottomSheet.enableDrag, isFalse);
    expect(bottomSheet.showDragHandle, isFalse);

    bottomSheet.onClosing();
    expect(actions.single.name, 'closeSheet');
  });

  testWidgets('maps rich material dialog props safely', (tester) async {
    final renderer = AppletRenderer();

    Future<T> pumpSpec<T extends Widget>(Map<String, Object?> spec) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) =>
                Center(child: renderer.buildWidget(context, spec)),
          ),
        ),
      );
      await tester.pump();
      return tester.widget<T>(find.byType(T).first);
    }

    final alert = await pumpSpec<AlertDialog>({
      'type': 'AlertDialog',
      'props': {
        'icon': {
          'type': 'Icon',
          'props': {'icon': 'info'},
        },
        'iconPadding': {'all': 8},
        'iconColor': '#006a6a',
        'title': {
          'type': 'Text',
          'props': {'data': 'Rich alert'},
        },
        'titlePadding': {'left': 12, 'top': 14, 'right': 16, 'bottom': 18},
        'titleTextStyle': {'fontSize': 21, 'color': '#111111'},
        'content': {
          'type': 'Text',
          'props': {'data': 'Mapped content'},
        },
        'contentPadding': {'horizontal': 20, 'vertical': 10},
        'contentTextStyle': {'fontSize': 15, 'color': '#222222'},
        'actions': [
          {
            'type': 'TextButton',
            'props': {'label': 'Close'},
          },
        ],
        'actionsPadding': {'all': 6},
        'actionsAlignment': 'end',
        'actionsOverflowAlignment': 'center',
        'actionsOverflowDirection': 'up',
        'actionsOverflowButtonSpacing': -4,
        'buttonPadding': {'horizontal': 5, 'vertical': 7},
        'backgroundColor': '#fff8e1',
        'surfaceTintColor': '#ffee58',
        'elevation': -12,
        'shadowColor': '#333333',
        'semanticLabel': 'Alert semantics',
        'insetPadding': {'horizontal': 32, 'vertical': 18},
        'clipBehavior': 'antiAlias',
        'shape': {'borderRadius': 16},
        'alignment': 'topRight',
        'constraints': {'maxWidth': 420, 'minHeight': 120},
        'scrollable': true,
      },
    });

    expect(alert.iconPadding, const EdgeInsets.all(8));
    expect(alert.iconColor, const Color(0xff006a6a));
    expect(alert.titlePadding, const EdgeInsets.fromLTRB(12, 14, 16, 18));
    expect(alert.titleTextStyle?.fontSize, 21);
    expect(alert.titleTextStyle?.color, const Color(0xff111111));
    expect(
      alert.contentPadding,
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
    expect(alert.contentTextStyle?.fontSize, 15);
    expect(alert.contentTextStyle?.color, const Color(0xff222222));
    expect(alert.actions, hasLength(1));
    expect(alert.actionsPadding, const EdgeInsets.all(6));
    expect(alert.actionsAlignment, MainAxisAlignment.end);
    expect(alert.actionsOverflowAlignment, OverflowBarAlignment.center);
    expect(alert.actionsOverflowDirection, VerticalDirection.up);
    expect(alert.actionsOverflowButtonSpacing, 0);
    expect(
      alert.buttonPadding,
      const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
    );
    expect(alert.backgroundColor, const Color(0xfffff8e1));
    expect(alert.surfaceTintColor, const Color(0xffffee58));
    expect(alert.elevation, 0);
    expect(alert.shadowColor, const Color(0xff333333));
    expect(alert.semanticLabel, 'Alert semantics');
    expect(
      alert.insetPadding,
      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    );
    expect(alert.clipBehavior, Clip.antiAlias);
    expect(alert.shape, isA<RoundedRectangleBorder>());
    expect(alert.alignment, Alignment.topRight);
    expect(alert.constraints?.maxWidth, 420);
    expect(alert.constraints?.minHeight, 120);
    expect(alert.scrollable, isTrue);

    final dialog = await pumpSpec<Dialog>({
      'type': 'Dialog',
      'props': {
        'backgroundColor': '#f5f5f5',
        'elevation': -3,
        'shadowColor': '#010203',
        'surfaceTintColor': '#040506',
        'insetAnimationDuration': {'milliseconds': 180},
        'insetAnimationCurve': 'easeOut',
        'insetPadding': {'all': 22},
        'clipBehavior': 'hardEdge',
        'shape': {'borderRadius': 10},
        'alignment': 'bottomCenter',
        'constraints': {'maxWidth': 360},
        'semanticsRole': 'alertDialog',
        'child': {
          'type': 'Text',
          'props': {'data': 'Dialog body'},
        },
      },
    });

    expect(dialog.backgroundColor, const Color(0xfff5f5f5));
    expect(dialog.elevation, 0);
    expect(dialog.shadowColor, const Color(0xff010203));
    expect(dialog.surfaceTintColor, const Color(0xff040506));
    expect(dialog.insetAnimationDuration, const Duration(milliseconds: 180));
    expect(dialog.insetAnimationCurve, Curves.easeOut);
    expect(dialog.insetPadding, const EdgeInsets.all(22));
    expect(dialog.clipBehavior, Clip.hardEdge);
    expect(dialog.shape, isA<RoundedRectangleBorder>());
    expect(dialog.alignment, Alignment.bottomCenter);
    expect(dialog.constraints?.maxWidth, 360);
    expect(dialog.semanticsRole, ui.SemanticsRole.alertDialog);

    final simple = await pumpSpec<SimpleDialog>({
      'type': 'SimpleDialog',
      'props': {
        'title': {
          'type': 'Text',
          'props': {'data': 'Simple title'},
        },
        'titlePadding': {'all': 11},
        'titleTextStyle': {'fontSize': 19, 'color': '#123456'},
        'contentPadding': {'horizontal': 9, 'vertical': 5},
        'contentTextStyle': {'fontSize': 13, 'color': '#654321'},
        'backgroundColor': '#fafafa',
        'elevation': -1,
        'shadowColor': '#111111',
        'surfaceTintColor': '#222222',
        'semanticLabel': 'Simple semantics',
        'insetPadding': {'all': 17},
        'clipBehavior': 'antiAlias',
        'shape': {'borderRadius': 12},
        'alignment': 'center',
        'constraints': {'maxWidth': 300},
        'children': [
          {
            'type': 'Text',
            'props': {'data': 'Option'},
          },
        ],
      },
    });

    expect(simple.titlePadding, const EdgeInsets.all(11));
    expect(simple.titleTextStyle?.fontSize, 19);
    expect(simple.titleTextStyle?.color, const Color(0xff123456));
    expect(
      simple.contentPadding,
      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    );
    expect(simple.contentTextStyle?.fontSize, 13);
    expect(simple.contentTextStyle?.color, const Color(0xff654321));
    expect(simple.backgroundColor, const Color(0xfffafafa));
    expect(simple.elevation, 0);
    expect(simple.shadowColor, const Color(0xff111111));
    expect(simple.surfaceTintColor, const Color(0xff222222));
    expect(simple.semanticLabel, 'Simple semantics');
    expect(simple.insetPadding, const EdgeInsets.all(17));
    expect(simple.clipBehavior, Clip.antiAlias);
    expect(simple.shape, isA<RoundedRectangleBorder>());
    expect(simple.alignment, Alignment.center);
    expect(simple.constraints?.maxWidth, 300);
    expect(simple.children, hasLength(1));
  });

  testWidgets('renders adaptive material alert dialogs', (tester) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'AlertDialog',
            'props': {
              'adaptive': true,
              'title': {
                'type': 'Text',
                'props': {'data': 'Adaptive alert'},
              },
              'content': {
                'type': 'Text',
                'props': {'data': 'Adaptive content'},
              },
            },
          }),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Adaptive alert'), findsOneWidget);
    expect(find.text('Adaptive content'), findsOneWidget);
  });

  testWidgets('presents material dialogs declaratively', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'Text',
                'props': {'data': 'Dialog host'},
              },
              'dialog': {
                'type': 'AlertDialog',
                'props': {
                  'title': {
                    'type': 'Text',
                    'props': {'data': 'Confirm action'},
                  },
                  'content': {
                    'type': 'Text',
                    'props': {'data': 'This is presented as an overlay.'},
                  },
                  'actions': [
                    {
                      'type': 'FilledButton',
                      'props': {
                        'label': 'Okay',
                        'onPressed': {
                          'type': 'Action',
                          'props': {'name': 'acceptDialog'},
                        },
                      },
                    },
                  ],
                },
              },
            },
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirm action'), findsOneWidget);
    expect(find.text('This is presented as an overlay.'), findsOneWidget);

    await tester.tap(find.text('Okay'));
    await tester.pump();

    expect(actions.single.name, 'acceptDialog');
  });

  testWidgets('handles declarative dialog dismissal semantics', (tester) async {
    final actions = <AppletAction>[];
    var visible = true;
    late StateSetter setHostState;
    late final AppletRenderer renderer;

    Map<String, Object?> scaffoldSpec() => {
      'type': 'Scaffold',
      'props': {
        'body': {
          'type': 'Text',
          'props': {'data': 'Dialog host'},
        },
        'dialog': {
          'type': 'AlertDialog',
          'props': {
            'visible': visible,
            'title': {
              'type': 'Text',
              'props': {'data': 'Controlled dialog'},
            },
            'actions': [
              {
                'type': 'TextButton',
                'props': {
                  'label': 'Close',
                  'onPressed': {
                    'type': 'Action',
                    'props': {'name': 'closeDialog'},
                  },
                },
              },
            ],
            'onDismissed': {
              'type': 'Action',
              'props': {'name': 'dialogDismissed'},
            },
          },
        },
      },
    };

    renderer = AppletRenderer(
      dispatchAction: (action) {
        actions.add(action);
        if (action.name == 'closeDialog') {
          setHostState(() => visible = false);
        }
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return renderer.buildWidget(context, scaffoldSpec());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(actions.map((action) => action.name), ['closeDialog']);
    expect(find.text('Controlled dialog'), findsNothing);

    actions.clear();
    setHostState(() => visible = true);
    await tester.pumpAndSettle();

    expect(find.text('Controlled dialog'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(actions.single.name, 'dialogDismissed');
  });

  testWidgets('dispatches picker dialog results', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'Text',
                'props': {'data': 'Picker host'},
              },
              'dialog': {
                'type': 'DatePickerDialog',
                'props': {
                  'initialDate': '2026-06-29',
                  'firstDate': '2020-01-01',
                  'lastDate': '2030-12-31',
                  'confirmText': 'Choose',
                  'onResult': {
                    'type': 'Action',
                    'props': {'name': 'datePicked'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(actions.single.name, 'datePicked');
    expect(actions.single.payload, '2026-06-29');

    actions.clear();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'Text',
                'props': {'data': 'Picker host'},
              },
              'dialog': {
                'type': 'TimePickerDialog',
                'props': {
                  'initialTime': '10:30',
                  'confirmText': 'Set time',
                  'onResult': {
                    'type': 'Action',
                    'props': {'name': 'timePicked'},
                  },
                },
              },
            },
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();

    expect(actions.single.name, 'timePicked');
    expect(actions.single.payload, '10:30');
  });

  testWidgets('renders material top app bar variants', (tester) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'SizedBox',
            'props': {
              'height': 360,
              'child': {
                'type': 'CustomScrollView',
                'props': {
                  'slivers': [
                    {
                      'type': 'SliverAppBar',
                      'props': {
                        'variant': 'medium',
                        'title': {
                          'type': 'Text',
                          'props': {'data': 'Medium top app bar'},
                        },
                        'leading': {
                          'type': 'IconButton',
                          'props': {
                            'icon': {
                              'type': 'Icon',
                              'props': {'icon': 'menu'},
                            },
                          },
                        },
                        'actions': [
                          {
                            'type': 'IconButton',
                            'props': {
                              'icon': {
                                'type': 'Icon',
                                'props': {'icon': 'search'},
                              },
                            },
                          },
                        ],
                        'primary': false,
                      },
                    },
                    {
                      'type': 'SliverToBoxAdapter',
                      'props': {
                        'child': {
                          'type': 'SizedBox',
                          'props': {'height': 80},
                        },
                      },
                    },
                    {
                      'type': 'SliverAppBar',
                      'props': {
                        'variant': 'large',
                        'title': {
                          'type': 'Text',
                          'props': {'data': 'Large top app bar'},
                        },
                        'primary': false,
                        'surfaceTintColor': '#6750a4',
                        'actionsPadding': {'horizontal': 8},
                      },
                    },
                    {
                      'type': 'SliverToBoxAdapter',
                      'props': {
                        'child': {
                          'type': 'SizedBox',
                          'props': {'height': 160},
                        },
                      },
                    },
                  ],
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('Medium top app bar'), findsWidgets);
    expect(find.text('Large top app bar'), findsWidgets);
    final bars = tester.widgetList<SliverAppBar>(find.byType(SliverAppBar));
    expect(bars, hasLength(2));
    expect(bars.every((bar) => bar.pinned), isTrue);
  });

  testWidgets('renders tabs, data tables, steppers, and tables', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'DefaultTabController',
            'props': {
              'length': 2,
              'child': {
                'type': 'Scaffold',
                'props': {
                  'appBar': {
                    'type': 'AppBar',
                    'props': {
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Advanced'},
                      },
                      'bottom': null,
                    },
                  },
                  'body': {
                    'type': 'SingleChildScrollView',
                    'props': {
                      'child': {
                        'type': 'Column',
                        'props': {
                          'children': [
                            {
                              'type': 'TabBar',
                              'props': {
                                'tabs': [
                                  {
                                    'type': 'Tab',
                                    'props': {'text': 'One'},
                                  },
                                  {
                                    'type': 'Tab',
                                    'props': {'text': 'Two'},
                                  },
                                ],
                              },
                            },
                            {
                              'type': 'DataTable',
                              'props': {
                                'columns': [
                                  {'label': 'Name'},
                                  {'label': 'Value', 'numeric': true},
                                ],
                                'rows': [
                                  {
                                    'cells': ['Counter', '42'],
                                  },
                                ],
                              },
                            },
                            {
                              'type': 'Stepper',
                              'props': {
                                'steps': [
                                  {
                                    'title': {
                                      'type': 'Text',
                                      'props': {'data': 'Load'},
                                    },
                                    'content': {
                                      'type': 'Text',
                                      'props': {'data': 'Load JS'},
                                    },
                                  },
                                ],
                              },
                            },
                            {
                              'type': 'Table',
                              'props': {
                                'rows': [
                                  ['A', 'B'],
                                  ['C', 'D'],
                                ],
                              },
                            },
                          ],
                        },
                      },
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Counter'), findsOneWidget);
    expect(find.text('Load JS'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('maps rich material navigation components safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'DefaultTabController',
            'props': {
              'length': 2,
              'initialIndex': 99,
              'child': {
                'type': 'Scaffold',
                'props': {
                  'body': {
                    'type': 'ListView',
                    'props': {
                      'children': [
                        {
                          'type': 'NavigationBar',
                          'props': {
                            'selectedIndex': 99,
                            'animationDuration': 250,
                            'backgroundColor': '#fef7ff',
                            'shadowColor': '#33000000',
                            'surfaceTintColor': '#f4eff4',
                            'indicatorColor': '#d0bcff',
                            'indicatorShape': {'borderRadius': 18},
                            'height': 72,
                            'labelBehavior': 'alwaysShow',
                            'overlayColor': {'pressed': '#22006a6a'},
                            'labelTextStyle': {
                              'default': {'fontSize': 12},
                            },
                            'labelPadding': {'horizontal': 8},
                            'maintainBottomViewPadding': true,
                            'onChanged': {
                              'type': 'Action',
                              'props': {'name': 'navBar'},
                            },
                            'destinations': [
                              {
                                'type': 'NavigationDestination',
                                'props': {
                                  'icon': 'home',
                                  'selectedIcon': {
                                    'type': 'Icon',
                                    'props': {'icon': 'home_filled'},
                                  },
                                  'label': 'Home',
                                  'enabled': false,
                                },
                              },
                              {
                                'type': 'NavigationDestination',
                                'props': {
                                  'icon': 'settings',
                                  'label': 'Settings',
                                },
                              },
                            ],
                          },
                        },
                        {
                          'type': 'NavigationBar',
                          'props': {
                            'destinations': [
                              {
                                'type': 'NavigationDestination',
                                'props': {'icon': 'home', 'label': 'Only'},
                              },
                            ],
                          },
                        },
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 180,
                            'child': {
                              'type': 'NavigationRail',
                              'props': {
                                'selectedIndex': 42,
                                'backgroundColor': '#fffbfe',
                                'elevation': 2,
                                'groupAlignment': -1,
                                'labelType': 'selected',
                                'selectedLabelStyle': {'fontSize': 13},
                                'unselectedLabelStyle': {'fontSize': 11},
                                'selectedIconTheme': {
                                  'color': '#006a6a',
                                  'size': 28,
                                },
                                'unselectedIconTheme': {
                                  'color': '#49454f',
                                  'size': 24,
                                },
                                'minWidth': 72,
                                'minExtendedWidth': 64,
                                'useIndicator': true,
                                'indicatorColor': '#d0bcff',
                                'indicatorShape': {'borderRadius': 24},
                                'leadingAtTop': false,
                                'trailingAtBottom': true,
                                'scrollable': true,
                                'mainAxisAlignment': 'center',
                                'onChanged': {
                                  'type': 'Action',
                                  'props': {'name': 'rail'},
                                },
                                'destinations': [
                                  {'icon': 'home', 'label': 'Rail home'},
                                  {
                                    'icon': 'settings',
                                    'label': 'Rail settings',
                                  },
                                ],
                              },
                            },
                          },
                        },
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 220,
                            'child': {
                              'type': 'NavigationDrawer',
                              'props': {
                                'selectedIndex': 1,
                                'header': {
                                  'type': 'Text',
                                  'props': {'data': 'Drawer header'},
                                },
                                'footer': {
                                  'type': 'Text',
                                  'props': {'data': 'Drawer footer'},
                                },
                                'backgroundColor': '#fffbfe',
                                'shadowColor': '#22000000',
                                'surfaceTintColor': '#f4eff4',
                                'elevation': 3,
                                'indicatorColor': '#d0bcff',
                                'indicatorShape': {'borderRadius': 28},
                                'tilePadding': {'horizontal': 20},
                                'onChanged': {
                                  'type': 'Action',
                                  'props': {'name': 'drawer'},
                                },
                                'children': [
                                  {
                                    'type': 'NavigationDrawerDestination',
                                    'props': {
                                      'icon': 'home',
                                      'label': 'Drawer home',
                                      'backgroundColor': '#f4eff4',
                                    },
                                  },
                                  {
                                    'type': 'NavigationDrawerDestination',
                                    'props': {
                                      'icon': 'settings',
                                      'selectedIcon': {
                                        'type': 'Icon',
                                        'props': {'icon': 'settings'},
                                      },
                                      'label': 'Drawer settings',
                                      'enabled': false,
                                    },
                                  },
                                ],
                              },
                            },
                          },
                        },
                        {
                          'type': 'BottomNavigationBar',
                          'props': {
                            'selectedIndex': -8,
                            'elevation': -4,
                            'type': 'fixed',
                            'backgroundColor': '#fffbfe',
                            'iconSize': 26,
                            'selectedItemColor': '#006a6a',
                            'unselectedItemColor': '#49454f',
                            'selectedIconTheme': {
                              'color': '#006a6a',
                              'size': 30,
                            },
                            'unselectedIconTheme': {
                              'color': '#49454f',
                              'size': 22,
                            },
                            'selectedFontSize': 15,
                            'unselectedFontSize': 11,
                            'selectedLabelStyle': {'fontWeight': 'w600'},
                            'unselectedLabelStyle': {'fontWeight': 'w400'},
                            'showSelectedLabels': true,
                            'showUnselectedLabels': false,
                            'mouseCursor': 'click',
                            'enableFeedback': false,
                            'landscapeLayout': 'linear',
                            'useLegacyColorScheme': false,
                            'onTap': {
                              'type': 'Action',
                              'props': {'name': 'bottomNav'},
                            },
                            'items': [
                              {'icon': 'home', 'label': 'Bottom home'},
                              {
                                'icon': 'settings',
                                'activeIcon': 'settings',
                                'label': 'Bottom settings',
                                'backgroundColor': '#f4eff4',
                              },
                            ],
                          },
                        },
                        {
                          'type': 'BottomNavigationBar',
                          'props': {
                            'items': [
                              {'icon': 'home', 'label': 'Only'},
                            ],
                          },
                        },
                        {
                          'type': 'BottomAppBar',
                          'props': {
                            'color': '#fffbfe',
                            'elevation': -2,
                            'shape': 'circular',
                            'clipBehavior': 'antiAlias',
                            'notchMargin': -5,
                            'height': 64,
                            'padding': {'horizontal': 12},
                            'surfaceTintColor': '#f4eff4',
                            'shadowColor': '#22000000',
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Bottom app bar'},
                            },
                          },
                        },
                        {
                          'type': 'TabBar',
                          'props': {
                            'isScrollable': true,
                            'padding': {'horizontal': 8},
                            'indicatorColor': '#006a6a',
                            'indicatorWeight': 3,
                            'indicatorPadding': {'horizontal': 4},
                            'indicator': {
                              'color': '#d0bcff',
                              'borderRadius': 16,
                            },
                            'indicatorSize': 'label',
                            'dividerColor': '#cac4d0',
                            'dividerHeight': 1,
                            'labelColor': '#006a6a',
                            'labelStyle': {'fontSize': 14},
                            'labelPadding': {'horizontal': 16},
                            'unselectedLabelColor': '#49454f',
                            'unselectedLabelStyle': {'fontSize': 12},
                            'dragStartBehavior': 'down',
                            'overlayColor': {'hovered': '#11006a6a'},
                            'mouseCursor': 'click',
                            'enableFeedback': false,
                            'physics': 'clamping',
                            'splashBorderRadius': 12,
                            'tabAlignment': 'startOffset',
                            'indicatorAnimation': 'linear',
                            'onTap': {
                              'type': 'Action',
                              'props': {'name': 'tabTap'},
                            },
                            'onHover': {
                              'type': 'Action',
                              'props': {'name': 'tabHover'},
                            },
                            'onFocusChange': {
                              'type': 'Action',
                              'props': {'name': 'tabFocus'},
                            },
                            'tabs': [
                              {
                                'type': 'Tab',
                                'props': {
                                  'text': 'One',
                                  'icon': 'home',
                                  'iconMargin': {'bottom': 4},
                                  'height': 52,
                                },
                              },
                              {
                                'type': 'Tab',
                                'props': {
                                  'text': 'Ignored',
                                  'child': {
                                    'type': 'Text',
                                    'props': {'data': 'Child tab'},
                                  },
                                },
                              },
                            ],
                          },
                        },
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 96,
                            'child': {
                              'type': 'TabBarView',
                              'props': {
                                'viewportFraction': 0.75,
                                'dragStartBehavior': 'down',
                                'clipBehavior': 'antiAlias',
                                'physics': 'never',
                                'children': [
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Panel one'},
                                  },
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Panel two'},
                                  },
                                ],
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    final controller = tester.widget<DefaultTabController>(
      find.byType(DefaultTabController),
    );
    expect(controller.length, 2);
    expect(controller.initialIndex, 1);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 1);
    expect(navigationBar.animationDuration, const Duration(milliseconds: 250));
    expect(navigationBar.backgroundColor, const Color(0xfffef7ff));
    expect(navigationBar.shadowColor, const Color(0x33000000));
    expect(navigationBar.surfaceTintColor, const Color(0xfff4eff4));
    expect(navigationBar.indicatorColor, const Color(0xffd0bcff));
    expect(navigationBar.indicatorShape, isA<RoundedRectangleBorder>());
    expect(navigationBar.height, 72);
    expect(
      navigationBar.labelBehavior,
      NavigationDestinationLabelBehavior.alwaysShow,
    );
    expect(
      navigationBar.overlayColor?.resolve({WidgetState.pressed}),
      const Color(0x22006a6a),
    );
    expect(navigationBar.labelTextStyle?.resolve({})?.fontSize, 12);
    expect(
      navigationBar.labelPadding,
      const EdgeInsets.symmetric(horizontal: 8),
    );
    expect(navigationBar.maintainBottomViewPadding, isTrue);

    final destinations = tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    );
    expect(destinations, hasLength(2));
    expect(destinations.first.enabled, isFalse);

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 1);
    expect(rail.backgroundColor, const Color(0xfffffbfe));
    expect(rail.elevation, 2);
    expect(rail.groupAlignment, -1);
    expect(rail.labelType, NavigationRailLabelType.selected);
    expect(rail.selectedLabelTextStyle?.fontSize, 13);
    expect(rail.unselectedLabelTextStyle?.fontSize, 11);
    expect(rail.selectedIconTheme?.color, const Color(0xff006a6a));
    expect(rail.selectedIconTheme?.size, 28);
    expect(rail.unselectedIconTheme?.color, const Color(0xff49454f));
    expect(rail.minWidth, 72);
    expect(rail.minExtendedWidth, 72);
    expect(rail.useIndicator, isTrue);
    expect(rail.indicatorColor, const Color(0xffd0bcff));
    expect(rail.indicatorShape, isA<RoundedRectangleBorder>());
    expect(rail.leadingAtTop, isFalse);
    expect(rail.trailingAtBottom, isTrue);
    expect(rail.scrollable, isTrue);
    expect(rail.mainAxisAlignment, MainAxisAlignment.center);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(drawer.selectedIndex, 1);
    expect(drawer.backgroundColor, const Color(0xfffffbfe));
    expect(drawer.shadowColor, const Color(0x22000000));
    expect(drawer.surfaceTintColor, const Color(0xfff4eff4));
    expect(drawer.elevation, 3);
    expect(drawer.indicatorColor, const Color(0xffd0bcff));
    expect(drawer.indicatorShape, isA<RoundedRectangleBorder>());
    expect(drawer.tilePadding, const EdgeInsets.symmetric(horizontal: 20));

    final drawerDestinations = tester.widgetList<NavigationDrawerDestination>(
      find.byType(NavigationDrawerDestination),
    );
    expect(drawerDestinations, hasLength(2));
    expect(drawerDestinations.first.backgroundColor, const Color(0xfff4eff4));
    expect(drawerDestinations.last.enabled, isFalse);

    final bottomNav = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomNav.currentIndex, 0);
    expect(bottomNav.elevation, 0);
    expect(bottomNav.type, BottomNavigationBarType.fixed);
    expect(bottomNav.backgroundColor, const Color(0xfffffbfe));
    expect(bottomNav.iconSize, 26);
    expect(bottomNav.selectedItemColor, const Color(0xff006a6a));
    expect(bottomNav.unselectedItemColor, const Color(0xff49454f));
    expect(bottomNav.selectedIconTheme?.color, const Color(0xff006a6a));
    expect(bottomNav.selectedIconTheme?.size, 30);
    expect(bottomNav.unselectedIconTheme?.color, const Color(0xff49454f));
    expect(bottomNav.selectedFontSize, 15);
    expect(bottomNav.unselectedFontSize, 11);
    expect(bottomNav.selectedLabelStyle?.fontWeight, FontWeight.w600);
    expect(bottomNav.unselectedLabelStyle?.fontWeight, FontWeight.w400);
    expect(bottomNav.showSelectedLabels, isTrue);
    expect(bottomNav.showUnselectedLabels, isFalse);
    expect(bottomNav.mouseCursor, SystemMouseCursors.click);
    expect(bottomNav.enableFeedback, isFalse);
    expect(
      bottomNav.landscapeLayout,
      BottomNavigationBarLandscapeLayout.linear,
    );
    expect(bottomNav.useLegacyColorScheme, isFalse);

    final bottomAppBar = tester.widget<BottomAppBar>(find.byType(BottomAppBar));
    expect(bottomAppBar.color, const Color(0xfffffbfe));
    expect(bottomAppBar.elevation, 0);
    expect(bottomAppBar.shape, isA<CircularNotchedRectangle>());
    expect(bottomAppBar.clipBehavior, Clip.antiAlias);
    expect(bottomAppBar.notchMargin, 0);
    expect(bottomAppBar.height, 64);
    expect(bottomAppBar.padding, const EdgeInsets.symmetric(horizontal: 12));
    expect(bottomAppBar.surfaceTintColor, const Color(0xfff4eff4));
    expect(bottomAppBar.shadowColor, const Color(0x22000000));

    final tabBar = tester.widget<TabBar>(
      find.byType(TabBar, skipOffstage: false),
    );
    expect(tabBar.tabs, hasLength(2));
    expect(tabBar.isScrollable, isTrue);
    expect(tabBar.padding, const EdgeInsets.symmetric(horizontal: 8));
    expect(tabBar.indicatorColor, const Color(0xff006a6a));
    expect(tabBar.indicatorWeight, 3);
    expect(tabBar.indicatorPadding, const EdgeInsets.symmetric(horizontal: 4));
    expect(tabBar.indicator, isA<BoxDecoration>());
    expect(tabBar.indicatorSize, TabBarIndicatorSize.label);
    expect(tabBar.dividerColor, const Color(0xffcac4d0));
    expect(tabBar.dividerHeight, 1);
    expect(tabBar.labelColor, const Color(0xff006a6a));
    expect(tabBar.labelStyle?.fontSize, 14);
    expect(tabBar.labelPadding, const EdgeInsets.symmetric(horizontal: 16));
    expect(tabBar.unselectedLabelColor, const Color(0xff49454f));
    expect(tabBar.unselectedLabelStyle?.fontSize, 12);
    expect(tabBar.dragStartBehavior, DragStartBehavior.down);
    expect(
      tabBar.overlayColor?.resolve({WidgetState.hovered}),
      const Color(0x11006a6a),
    );
    expect(tabBar.mouseCursor, SystemMouseCursors.click);
    expect(tabBar.enableFeedback, isFalse);
    expect(tabBar.physics, isA<ClampingScrollPhysics>());
    expect(tabBar.splashBorderRadius, BorderRadius.circular(12));
    expect(tabBar.tabAlignment, TabAlignment.startOffset);
    expect(tabBar.indicatorAnimation, TabIndicatorAnimation.linear);

    final tabs = tester
        .widgetList<Tab>(find.byType(Tab, skipOffstage: false))
        .toList();
    expect(tabs.first.iconMargin, const EdgeInsets.only(bottom: 4));
    expect(tabs.first.height, 52);
    expect(tabs.last.text, isNull);
    expect(find.text('Child tab', skipOffstage: false), findsOneWidget);

    final tabBarView = tester.widget<TabBarView>(
      find.byType(TabBarView, skipOffstage: false),
    );
    expect(tabBarView.viewportFraction, 0.75);
    expect(tabBarView.dragStartBehavior, DragStartBehavior.down);
    expect(tabBarView.clipBehavior, Clip.antiAlias);
    expect(tabBarView.physics, isA<NeverScrollableScrollPhysics>());

    navigationBar.onDestinationSelected!(0);
    rail.onDestinationSelected!(0);
    drawer.onDestinationSelected!(1);
    bottomNav.onTap!(1);
    tabBar.onTap!(1);
    tabBar.onHover!(true, 0);
    tabBar.onFocusChange!(false, 1);

    expect(
      actions.map((action) => [action.name, action.payload]),
      containsAll([
        ['navBar', 0],
        ['rail', 0],
        ['drawer', 1],
        ['bottomNav', 1],
        ['tabTap', 1],
        [
          'tabHover',
          {'value': true, 'index': 0},
        ],
        [
          'tabFocus',
          {'value': false, 'index': 1},
        ],
      ]),
    );
  });

  testWidgets('maps adaptive navigation scaffold breakpoints and slots', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    Map<String, Object?> spec({Object? largeWidth = 1500}) => {
      'type': 'AdaptiveNavigationScaffold',
      'props': {
        'narrowWidth': 450,
        'largeWidth': largeWidth,
        'duration': 1,
        'appBar': {
          'type': 'AppBar',
          'props': {
            'title': {
              'type': 'Text',
              'props': {'data': 'Compact app bar'},
            },
          },
        },
        'railAppBar': {
          'type': 'AppBar',
          'props': {
            'title': {
              'type': 'Text',
              'props': {'data': 'Rail app bar'},
            },
          },
        },
        'body': {
          'type': 'Text',
          'props': {'data': 'Adaptive body'},
        },
        'navigationBar': {
          'type': 'NavigationBar',
          'props': {
            'destinations': [
              {
                'type': 'NavigationDestination',
                'props': {'icon': 'home', 'label': 'Home'},
              },
              {
                'type': 'NavigationDestination',
                'props': {'icon': 'palette', 'label': 'Color'},
              },
            ],
          },
        },
        'navigationRail': {
          'type': 'NavigationRail',
          'props': {
            'extended': false,
            'destinations': [
              {
                'type': 'NavigationRailDestination',
                'props': {'icon': 'home', 'label': 'Home'},
              },
              {
                'type': 'NavigationRailDestination',
                'props': {'icon': 'palette', 'label': 'Color'},
              },
            ],
          },
        },
        'extendedNavigationRail': {
          'type': 'NavigationRail',
          'props': {
            'extended': true,
            'destinations': [
              {
                'type': 'NavigationRailDestination',
                'props': {'icon': 'home', 'label': 'Home'},
              },
              {
                'type': 'NavigationRailDestination',
                'props': {'icon': 'palette', 'label': 'Color'},
              },
            ],
          },
        },
      },
    };

    Future<void> pumpAtWidth(double width, {Object? largeWidth = 1500}) async {
      tester.view.physicalSize = Size(width, 720);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) =>
                renderer.buildWidget(context, spec(largeWidth: largeWidth)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpAtWidth(400);
    expect(find.text('Compact app bar'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await pumpAtWidth(900);
    expect(find.text('Rail app bar'), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );

    await pumpAtWidth(1600);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );

    await pumpAtWidth(900, largeWidth: 300);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
  });

  testWidgets('maps adaptive two pane breakpoints and aliases', (tester) async {
    final renderer = AppletRenderer();
    final spec = {
      'type': 'AdaptiveTwoPane',
      'props': {
        'breakpoint': 1000,
        'duration': 1,
        'firstFlex': 700,
        'secondFlex': 300,
        'compact': {
          'type': 'Text',
          'props': {'data': 'Compact list'},
        },
        'one': {
          'type': 'Text',
          'props': {'data': 'Primary list'},
        },
        'two': {
          'type': 'Text',
          'props': {'data': 'Secondary list'},
        },
      },
    };

    Future<void> pumpAtWidth(double width) async {
      tester.view.physicalSize = Size(width, 720);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => renderer.buildWidget(context, spec),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpAtWidth(700);
    expect(find.text('Compact list'), findsOneWidget);
    expect(find.text('Primary list'), findsNothing);
    expect(find.text('Secondary list'), findsNothing);

    await pumpAtWidth(1200);
    expect(find.text('Compact list'), findsNothing);
    expect(find.text('Primary list'), findsOneWidget);
    expect(find.text('Secondary list'), findsOneWidget);
    final panes = tester.widgetList<Flexible>(find.byType(Flexible)).toList();
    expect(panes.map((pane) => pane.flex), containsAll(<int>[700, 300]));
  });

  testWidgets('maps rich material data, stepper, table, and carousel safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'body': {
                'type': 'SingleChildScrollView',
                'props': {
                  'child': {
                    'type': 'Column',
                    'props': {
                      'children': [
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 320,
                            'child': {
                              'type': 'Stepper',
                              'props': {
                                'currentStep': 99,
                                'type': 'vertical',
                                'physics': 'clamping',
                                'elevation': -2,
                                'margin': {'all': 12},
                                'connectorColor': {'selected': '#006a6a'},
                                'connectorThickness': -1,
                                'stepIconSize': 12,
                                'stepIconMargin': {'all': 6},
                                'clipBehavior': 'antiAlias',
                                'headerPadding': {'horizontal': 8},
                                'contentPadding': {'all': 10},
                                'onStepTapped': {
                                  'type': 'Action',
                                  'props': {'name': 'stepTapped'},
                                },
                                'onStepContinue': {
                                  'type': 'Action',
                                  'props': {'name': 'stepContinue'},
                                },
                                'onStepCancel': {
                                  'type': 'Action',
                                  'props': {'name': 'stepCancel'},
                                },
                                'steps': [
                                  {
                                    'title': {
                                      'type': 'Text',
                                      'props': {'data': 'Configure'},
                                    },
                                    'subtitle': {
                                      'type': 'Text',
                                      'props': {'data': 'Optional'},
                                    },
                                    'label': {
                                      'type': 'Text',
                                      'props': {'data': 'Step label'},
                                    },
                                    'content': {
                                      'type': 'Text',
                                      'props': {'data': 'Configure content'},
                                    },
                                    'isActive': true,
                                    'state': 'editing',
                                    'stepStyle': {
                                      'color': '#d0bcff',
                                      'errorColor': '#b3261e',
                                      'connectorColor': '#006a6a',
                                      'connectorThickness': 2,
                                      'border': {
                                        'color': '#006a6a',
                                        'width': 1,
                                      },
                                      'boxShadow': {
                                        'color': '#22000000',
                                        'blur': 2,
                                      },
                                      'indexStyle': {'fontSize': 11},
                                    },
                                  },
                                  {
                                    'title': {
                                      'type': 'Text',
                                      'props': {'data': 'Review'},
                                    },
                                    'content': {
                                      'type': 'Text',
                                      'props': {'data': 'Review content'},
                                    },
                                    'state': 'complete',
                                  },
                                ],
                              },
                            },
                          },
                        },
                        {
                          'type': 'DataTable',
                          'props': {
                            'sortColumnIndex': 99,
                            'sortAscending': false,
                            'onSelectAll': {
                              'type': 'Action',
                              'props': {'name': 'selectAll'},
                            },
                            'decoration': {
                              'color': '#fffbfe',
                              'borderRadius': 12,
                            },
                            'dataRowColor': {'selected': '#11006a6a'},
                            'dataRowMinHeight': 44,
                            'dataRowMaxHeight': 36,
                            'dataTextStyle': {'fontSize': 13},
                            'headingRowColor': '#f4eff4',
                            'headingRowHeight': 52,
                            'headingTextStyle': {'fontWeight': 'w600'},
                            'horizontalMargin': 16,
                            'columnSpacing': 24,
                            'showCheckboxColumn': true,
                            'showBottomBorder': true,
                            'dividerThickness': -1,
                            'checkboxHorizontalMargin': 10,
                            'border': {'color': '#cac4d0', 'width': 1},
                            'clipBehavior': 'antiAlias',
                            'columns': [
                              {
                                'label': 'Name',
                                'columnWidth': {'type': 'fixed', 'value': 160},
                                'tooltip': 'Item name',
                                'onSort': {
                                  'type': 'Action',
                                  'props': {'name': 'sort'},
                                },
                                'mouseCursor': {'default': 'click'},
                                'headingRowAlignment': 'center',
                              },
                              {'label': 'Value', 'numeric': true},
                              {'label': 'Status'},
                            ],
                            'rows': [
                              {
                                'key': 'row-1',
                                'selected': true,
                                'color': {'selected': '#22006a6a'},
                                'mouseCursor': {'default': 'click'},
                                'onSelectChanged': {
                                  'type': 'Action',
                                  'props': {'name': 'rowSelect'},
                                },
                                'onLongPress': {
                                  'type': 'Action',
                                  'props': {'name': 'rowLong'},
                                },
                                'onHover': {
                                  'type': 'Action',
                                  'props': {'name': 'rowHover'},
                                },
                                'cells': [
                                  {
                                    'child': {
                                      'type': 'Text',
                                      'props': {'data': 'Alpha'},
                                    },
                                    'placeholder': true,
                                    'showEditIcon': true,
                                    'onTap': {
                                      'type': 'Action',
                                      'props': {'name': 'cellTap'},
                                    },
                                    'onLongPress': {
                                      'type': 'Action',
                                      'props': {'name': 'cellLong'},
                                    },
                                    'onDoubleTap': {
                                      'type': 'Action',
                                      'props': {'name': 'cellDouble'},
                                    },
                                    'onTapCancel': {
                                      'type': 'Action',
                                      'props': {'name': 'cellCancel'},
                                    },
                                    'onTapDown': {
                                      'type': 'Action',
                                      'props': {'name': 'cellDown'},
                                    },
                                  },
                                  '42',
                                ],
                              },
                              {
                                'cells': ['Beta', '64', 'Ready', 'Ignored'],
                              },
                            ],
                          },
                        },
                        {
                          'type': 'Table',
                          'props': {
                            'columnWidths': [
                              {'type': 'fixed', 'value': 80},
                              {'type': 'flex', 'value': 2},
                            ],
                            'defaultColumnWidth': {'type': 'intrinsic'},
                            'textDirection': 'rtl',
                            'border': {'color': '#79747e', 'width': 1},
                            'defaultVerticalAlignment': 'baseline',
                            'rows': [
                              ['A', 'B'],
                              {
                                'key': 'table-row',
                                'decoration': {'color': '#f4eff4'},
                                'children': [
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'C'},
                                  },
                                ],
                              },
                            ],
                          },
                        },
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 140,
                            'child': {
                              'type': 'CarouselView',
                              'props': {
                                'padding': {'all': 4},
                                'backgroundColor': '#fffbfe',
                                'elevation': -2,
                                'shape': {'borderRadius': 16},
                                'itemClipBehavior': 'antiAlias',
                                'overlayColor': {'pressed': '#11006a6a'},
                                'itemSnapping': true,
                                'shrinkExtent': -10,
                                'scrollDirection': 'horizontal',
                                'reverse': true,
                                'enableSplash': false,
                                'infinite': true,
                                'itemExtent': 120,
                                'onTap': {
                                  'type': 'Action',
                                  'props': {'name': 'carouselTap'},
                                },
                                'onIndexChanged': {
                                  'type': 'Action',
                                  'props': {'name': 'carouselIndex'},
                                },
                                'children': [
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Slide one'},
                                  },
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Slide two'},
                                  },
                                ],
                              },
                            },
                          },
                        },
                        {
                          'type': 'SizedBox',
                          'props': {
                            'height': 140,
                            'child': {
                              'type': 'CarouselView',
                              'props': {
                                'flexWeights': [1, 7, 1],
                                'consumeMaxWeight': false,
                                'children': [
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Weighted one'},
                                  },
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Weighted two'},
                                  },
                                  {
                                    'type': 'Text',
                                    'props': {'data': 'Weighted three'},
                                  },
                                ],
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    final stepper = tester.widget<Stepper>(find.byType(Stepper));
    expect(stepper.currentStep, 1);
    expect(stepper.physics, isA<ClampingScrollPhysics>());
    expect(stepper.type, StepperType.vertical);
    expect(stepper.elevation, 0);
    expect(stepper.margin, const EdgeInsets.all(12));
    expect(
      stepper.connectorColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(stepper.connectorThickness, 0);
    expect(stepper.stepIconHeight, 24);
    expect(stepper.stepIconWidth, 24);
    expect(stepper.stepIconMargin, const EdgeInsets.all(6));
    expect(stepper.clipBehavior, Clip.antiAlias);
    expect(stepper.headerPadding, const EdgeInsets.symmetric(horizontal: 8));
    expect(stepper.contentPadding, const EdgeInsets.all(10));
    expect(stepper.steps.first.state, StepState.editing);
    expect(stepper.steps.first.isActive, isTrue);
    expect(stepper.steps.first.label, isA<Text>());
    expect(stepper.steps.first.stepStyle?.color, const Color(0xffd0bcff));
    expect(stepper.steps.first.stepStyle?.connectorThickness, 2);
    expect(stepper.steps.first.stepStyle?.border, isA<Border>());
    expect(stepper.steps.first.stepStyle?.boxShadow, isA<BoxShadow>());
    expect(stepper.steps.first.stepStyle?.indexStyle?.fontSize, 11);

    final dataTable = tester.widget<DataTable>(find.byType(DataTable));
    expect(dataTable.sortColumnIndex, 2);
    expect(dataTable.sortAscending, isFalse);
    expect(dataTable.decoration, isA<BoxDecoration>());
    expect(
      dataTable.dataRowColor?.resolve({WidgetState.selected}),
      const Color(0x11006a6a),
    );
    expect(dataTable.dataRowMinHeight, 44);
    expect(dataTable.dataRowMaxHeight, 44);
    expect(dataTable.dataTextStyle?.fontSize, 13);
    expect(dataTable.headingRowColor?.resolve({}), const Color(0xfff4eff4));
    expect(dataTable.headingRowHeight, 52);
    expect(dataTable.headingTextStyle?.fontWeight, FontWeight.w600);
    expect(dataTable.horizontalMargin, 16);
    expect(dataTable.columnSpacing, 24);
    expect(dataTable.showCheckboxColumn, isTrue);
    expect(dataTable.showBottomBorder, isTrue);
    expect(dataTable.dividerThickness, 0);
    expect(dataTable.checkboxHorizontalMargin, 10);
    expect(dataTable.border, isA<TableBorder>());
    expect(dataTable.clipBehavior, Clip.antiAlias);
    expect(dataTable.columns.first.columnWidth, isA<FixedColumnWidth>());
    expect(dataTable.columns.first.tooltip, 'Item name');
    expect(
      dataTable.columns.first.mouseCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(
      dataTable.columns.first.headingRowAlignment,
      MainAxisAlignment.center,
    );
    expect(dataTable.rows.first.key, const ValueKey<String>('row-1'));
    expect(dataTable.rows.first.selected, isTrue);
    expect(
      dataTable.rows.first.color?.resolve({WidgetState.selected}),
      const Color(0x22006a6a),
    );
    expect(
      dataTable.rows.first.mouseCursor?.resolve({}),
      SystemMouseCursors.click,
    );
    expect(dataTable.rows.first.cells, hasLength(3));
    expect(dataTable.rows.first.cells.first.placeholder, isTrue);
    expect(dataTable.rows.first.cells.first.showEditIcon, isTrue);
    expect(dataTable.rows.last.cells, hasLength(3));

    final table = tester
        .widgetList<Table>(find.byType(Table))
        .firstWhere(
          (widget) =>
              widget.children.length == 2 &&
              widget.textDirection == TextDirection.rtl,
        );
    expect(table.columnWidths?[0], isA<FixedColumnWidth>());
    expect(table.columnWidths?[1], isA<FlexColumnWidth>());
    expect(table.defaultColumnWidth, isA<IntrinsicColumnWidth>());
    expect(table.textDirection, TextDirection.rtl);
    expect(table.border, isA<TableBorder>());
    expect(table.defaultVerticalAlignment, TableCellVerticalAlignment.baseline);
    expect(table.textBaseline, TextBaseline.alphabetic);
    expect(table.children, hasLength(2));
    expect(table.children.last.children, hasLength(2));

    final carousels = tester.widgetList<CarouselView>(
      find.byType(CarouselView, skipOffstage: false),
    );
    expect(carousels, hasLength(2));
    final carousel = carousels.first;
    expect(carousel.padding, const EdgeInsets.all(4));
    expect(carousel.backgroundColor, const Color(0xfffffbfe));
    expect(carousel.elevation, 0);
    expect(carousel.shape, isA<RoundedRectangleBorder>());
    expect(carousel.itemClipBehavior, Clip.antiAlias);
    expect(
      carousel.overlayColor?.resolve({WidgetState.pressed}),
      const Color(0x11006a6a),
    );
    expect(carousel.itemSnapping, isTrue);
    expect(carousel.shrinkExtent, 0);
    expect(carousel.scrollDirection, Axis.horizontal);
    expect(carousel.reverse, isTrue);
    expect(carousel.enableSplash, isFalse);
    expect(carousel.infinite, isTrue);
    expect(carousel.itemExtent, 120);
    final weightedCarousel = carousels.last;
    expect(weightedCarousel.flexWeights, [1, 7, 1]);
    expect(weightedCarousel.consumeMaxWeight, isFalse);

    stepper.onStepTapped!(0);
    stepper.onStepContinue!();
    stepper.onStepCancel!();
    dataTable.onSelectAll!(true);
    dataTable.columns.first.onSort!(1, false);
    dataTable.rows.first.onSelectChanged!(false);
    dataTable.rows.first.onLongPress!();
    dataTable.rows.first.onHover!(true);
    final firstCell = dataTable.rows.first.cells.first;
    firstCell.onTap!();
    firstCell.onLongPress!();
    firstCell.onDoubleTap!();
    firstCell.onTapCancel!();
    firstCell.onTapDown!(
      TapDownDetails(
        globalPosition: Offset(10, 20),
        localPosition: Offset(3, 4),
      ),
    );
    carousel.onTap!(1);
    carousel.onIndexChanged!(2);

    expect(
      actions.map((action) => action.name),
      containsAll([
        'stepTapped',
        'stepContinue',
        'stepCancel',
        'selectAll',
        'sort',
        'rowSelect',
        'rowLong',
        'rowHover',
        'cellTap',
        'cellLong',
        'cellDouble',
        'cellCancel',
        'cellDown',
        'carouselTap',
        'carouselIndex',
      ]),
    );
    expect(actions.firstWhere((action) => action.name == 'sort').payload, {
      'columnIndex': 1,
      'index': 1,
      'ascending': false,
      'fallbackIndex': 0,
    });
    expect(
      actions.firstWhere((action) => action.name == 'cellDown').payload,
      containsPair('localX', 3),
    );
    expect(
      actions.firstWhere((action) => action.name == 'carouselIndex').payload,
      2,
    );
  });

  testWidgets('renders extended layout, animation, and feedback widgets', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'DefaultTabController',
            'props': {
              'length': 1,
              'child': {
                'type': 'Scaffold',
                'props': {
                  'appBar': {
                    'type': 'AppBar',
                    'props': {
                      'title': {
                        'type': 'Text',
                        'props': {'data': 'Extended'},
                      },
                      'bottom': {
                        'type': 'TabBar',
                        'props': {
                          'tabs': [
                            {
                              'type': 'Tab',
                              'props': {'text': 'One'},
                            },
                          ],
                        },
                      },
                    },
                  },
                  'body': {
                    'type': 'CustomScrollView',
                    'props': {
                      'slivers': [
                        {
                          'type': 'SliverToBoxAdapter',
                          'props': {
                            'child': {
                              'type': 'AnimatedOpacity',
                              'props': {
                                'opacity': 1,
                                'child': {
                                  'type': 'Form',
                                  'props': {
                                    'child': {
                                      'type': 'Column',
                                      'props': {
                                        'children': [
                                          {
                                            'type': 'MaterialBanner',
                                            'props': {
                                              'content': {
                                                'type': 'Text',
                                                'props': {'data': 'Banner'},
                                              },
                                              'actions': [
                                                {
                                                  'type': 'TextButton',
                                                  'props': {'label': 'Ok'},
                                                },
                                              ],
                                            },
                                          },
                                          {
                                            'type': 'SnackBar',
                                            'props': {
                                              'content': {
                                                'type': 'Text',
                                                'props': {'data': 'Snack'},
                                              },
                                            },
                                          },
                                          {
                                            'type': 'TextField',
                                            'props': {
                                              'labelText': 'Email',
                                              'prefix': 'https://',
                                              'suffixIcon': {
                                                'type': 'Icon',
                                                'props': {'icon': 'search'},
                                              },
                                            },
                                          },
                                        ],
                                      },
                                    },
                                  },
                                },
                              },
                            },
                          },
                        },
                        {
                          'type': 'SliverGrid',
                          'props': {
                            'crossAxisCount': 2,
                            'children': [
                              {
                                'type': 'DatePickerDialog',
                                'props': {
                                  'initialDate': '2026-06-29',
                                  'firstDate': '2020-01-01',
                                  'lastDate': '2030-01-01',
                                },
                              },
                              {
                                'type': 'TimePickerDialog',
                                'props': {'initialTime': '10:30'},
                              },
                            ],
                          },
                        },
                      ],
                    },
                  },
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('Extended'), findsOneWidget);
    expect(find.text('Banner'), findsOneWidget);
    expect(find.text('Snack'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('renders second batch foundation and Material menu widgets', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => renderer.buildWidget(context, {
            'type': 'Scaffold',
            'props': {
              'appBar': {
                'type': 'AppBar',
                'props': {
                  'leading': {'type': 'BackButton'},
                  'title': {
                    'type': 'Text',
                    'props': {'data': 'Batch'},
                  },
                  'actions': [
                    {'type': 'CloseButton'},
                  ],
                },
              },
              'body': {
                'type': 'ListView',
                'props': {
                  'children': [
                    {
                      'type': 'Semantics',
                      'props': {
                        'label': 'copyable-label',
                        'button': true,
                        'child': {
                          'type': 'SelectableText',
                          'props': {'data': 'Copyable'},
                        },
                      },
                    },
                    {
                      'type': 'RepaintBoundary',
                      'props': {
                        'child': {
                          'type': 'ClipRect',
                          'props': {
                            'child': {
                              'type': 'SizedBox',
                              'props': {
                                'width': 80,
                                'height': 32,
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Clipped'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    {
                      'type': 'UnconstrainedBox',
                      'props': {
                        'child': {
                          'type': 'SizedOverflowBox',
                          'props': {
                            'size': {'width': 80, 'height': 32},
                            'child': {
                              'type': 'OverflowBox',
                              'props': {
                                'fit': 'deferToChild',
                                'maxWidth': 80,
                                'maxHeight': 32,
                                'child': {
                                  'type': 'Text',
                                  'props': {'data': 'Overflow'},
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    {
                      'type': 'IndexedStack',
                      'props': {
                        'index': 1,
                        'children': [
                          {
                            'type': 'Text',
                            'props': {'data': 'Hidden'},
                          },
                          {
                            'type': 'Text',
                            'props': {'data': 'Shown'},
                          },
                        ],
                      },
                    },
                    {
                      'type': 'ListBody',
                      'props': {
                        'children': [
                          {
                            'type': 'Text',
                            'props': {'data': 'Body A'},
                          },
                          {
                            'type': 'Text',
                            'props': {'data': 'Body B'},
                          },
                        ],
                      },
                    },
                    {
                      'type': 'MergeSemantics',
                      'props': {
                        'child': {
                          'type': 'ExcludeSemantics',
                          'props': {
                            'child': {
                              'type': 'Text',
                              'props': {'data': 'Visual only'},
                            },
                          },
                        },
                      },
                    },
                    {
                      'type': 'MenuItemButton',
                      'props': {
                        'child': {
                          'type': 'Text',
                          'props': {'data': 'Menu action'},
                        },
                        'onPressed': {
                          'type': 'Action',
                          'props': {'name': 'menuPressed'},
                        },
                      },
                    },
                    {
                      'type': 'MenuBar',
                      'props': {
                        'children': [
                          {
                            'type': 'SubmenuButton',
                            'props': {
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'More'},
                              },
                              'menuChildren': [
                                {
                                  'type': 'CheckboxMenuButton',
                                  'props': {
                                    'value': true,
                                    'child': {
                                      'type': 'Text',
                                      'props': {'data': 'Enabled'},
                                    },
                                  },
                                },
                                {
                                  'type': 'RadioMenuButton',
                                  'props': {
                                    'value': 'a',
                                    'groupValue': 'a',
                                    'child': {
                                      'type': 'Text',
                                      'props': {'data': 'Choice A'},
                                    },
                                  },
                                },
                              ],
                            },
                          },
                        ],
                      },
                    },
                    {
                      'type': 'MenuAnchor',
                      'props': {
                        'child': {
                          'type': 'Text',
                          'props': {'data': 'Anchor'},
                        },
                        'menuChildren': [
                          {
                            'type': 'MenuItemButton',
                            'props': {
                              'label': 'Anchored',
                              'onPressed': {
                                'type': 'Action',
                                'props': {'name': 'anchoredMenuPressed'},
                              },
                            },
                          },
                        ],
                      },
                    },
                  ],
                },
              },
            },
          }),
        ),
      ),
    );

    expect(find.text('Copyable'), findsOneWidget);
    expect(find.bySemanticsLabel('copyable-label'), findsOneWidget);
    expect(find.text('Clipped'), findsOneWidget);
    expect(find.text('Overflow'), findsOneWidget);
    expect(find.text('Shown'), findsOneWidget);
    expect(find.text('Body B'), findsOneWidget);
    expect(find.text('Visual only'), findsOneWidget);
    expect(find.text('Menu action'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Anchor'), findsOneWidget);

    await tester.tap(find.text('Menu action'));
    await tester.pump();

    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    expect(find.text('Anchored'), findsOneWidget);

    await tester.tap(find.text('Anchored'));
    await tester.pump();

    expect(actions.map((action) => action.name), [
      'menuPressed',
      'anchoredMenuPressed',
    ]);
  });

  testWidgets(
    'normalizes foundational layout props before building Flutter widgets',
    (tester) async {
      final renderer = AppletRenderer();

      Future<void> pumpSpec(Map<String, Object?> spec) {
        return tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle(
                style: const TextStyle(fontSize: 14),
                child: Builder(
                  builder: (context) => renderer.buildWidget(context, spec),
                ),
              ),
            ),
          ),
        );
      }

      await pumpSpec({
        'type': 'SafeArea',
        'props': {
          'minimum': -8,
          'maintainBottomViewPadding': true,
          'child': {
            'type': 'Text',
            'props': {'data': 'safe'},
          },
        },
      });
      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.minimum, EdgeInsets.zero);
      expect(safeArea.maintainBottomViewPadding, isTrue);

      await pumpSpec({
        'type': 'Column',
        'props': {
          'spacing': -12,
          'children': [
            {
              'type': 'SizedBox',
              'props': {
                'width': -20,
                'height': -10,
                'child': {
                  'type': 'Text',
                  'props': {'data': 'box'},
                },
              },
            },
            {
              'type': 'Baseline',
              'props': {
                'baseline': -4,
                'child': {
                  'type': 'Text',
                  'props': {'data': 'baseline'},
                },
              },
            },
            {
              'type': 'LimitedBox',
              'props': {
                'maxWidth': -30,
                'maxHeight': -40,
                'child': {
                  'type': 'Text',
                  'props': {'data': 'limited'},
                },
              },
            },
          ],
        },
      });
      expect(tester.widget<Column>(find.byType(Column)).spacing, 0);
      final sizedBox = tester
          .widgetList<SizedBox>(
            find.byWidgetPredicate(
              (widget) => widget is SizedBox && widget.child is Text,
            ),
          )
          .first;
      expect(sizedBox.width, 0);
      expect(sizedBox.height, 0);
      expect(tester.widget<Baseline>(find.byType(Baseline)).baseline, 0);
      final limited = tester.widget<LimitedBox>(find.byType(LimitedBox));
      expect(limited.maxWidth, 0);
      expect(limited.maxHeight, 0);

      await pumpSpec({
        'type': 'AspectRatio',
        'props': {
          'aspectRatio': -2,
          'child': {
            'type': 'Text',
            'props': {'data': 'ratio'},
          },
        },
      });
      expect(
        tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
        1,
      );

      await pumpSpec({
        'type': 'OverflowBox',
        'props': {
          'minWidth': 12,
          'maxWidth': -5,
          'minHeight': 8,
          'maxHeight': -3,
          'child': {
            'type': 'Text',
            'props': {'data': 'overflow'},
          },
        },
      });
      final overflow = tester.widget<OverflowBox>(find.byType(OverflowBox));
      expect(overflow.minWidth, 12);
      expect(overflow.maxWidth, 12);
      expect(overflow.minHeight, 8);
      expect(overflow.maxHeight, 8);

      await pumpSpec({
        'type': 'FractionallySizedBox',
        'props': {
          'widthFactor': -1,
          'heightFactor': -2,
          'child': {
            'type': 'Text',
            'props': {'data': 'fraction'},
          },
        },
      });
      final fractional = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractional.widthFactor, 0);
      expect(fractional.heightFactor, 0);

      await pumpSpec({
        'type': 'Row',
        'props': {
          'crossAxisAlignment': 'baseline',
          'children': [
            {
              'type': 'Text',
              'props': {'data': 'baseline a'},
            },
            {
              'type': 'Text',
              'props': {'data': 'baseline b'},
            },
          ],
        },
      });
      expect(
        tester.widget<Row>(find.byType(Row)).textBaseline,
        TextBaseline.alphabetic,
      );

      await pumpSpec({
        'type': 'Column',
        'props': {
          'spacing': -2,
          'children': [
            {
              'type': 'Flexible',
              'props': {
                'flex': -4,
                'fit': 'tight',
                'child': {
                  'type': 'Text',
                  'props': {'data': 'flexible'},
                },
              },
            },
            {
              'type': 'Expanded',
              'props': {
                'flex': 0,
                'child': {
                  'type': 'Text',
                  'props': {'data': 'expanded'},
                },
              },
            },
            {
              'type': 'Spacer',
              'props': {'flex': -1},
            },
          ],
        },
      });
      expect(tester.widget<Column>(find.byType(Column)).spacing, 0);
      final flexible = tester.widget<Flexible>(find.byType(Flexible));
      expect(flexible.flex, 1);
      expect(flexible.fit, FlexFit.tight);
      expect(
        tester
            .widgetList<Expanded>(find.byType(Expanded))
            .map((widget) => widget.flex),
        everyElement(1),
      );
      expect(tester.widget<Spacer>(find.byType(Spacer)).flex, 1);

      await pumpSpec({
        'type': 'IndexedStack',
        'props': {
          'index': 99,
          'textDirection': 'rtl',
          'children': [
            {
              'type': 'Text',
              'props': {'data': 'first'},
            },
            {
              'type': 'Text',
              'props': {'data': 'second'},
            },
          ],
        },
      });
      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, 1);
      expect(indexedStack.textDirection, TextDirection.rtl);

      await pumpSpec({
        'type': 'Stack',
        'props': {
          'clipBehavior': 'none',
          'children': [
            {
              'type': 'Positioned',
              'props': {
                'left': 1,
                'right': 2,
                'width': -4,
                'top': 3,
                'bottom': 4,
                'height': -5,
                'child': {
                  'type': 'Text',
                  'props': {'data': 'positioned'},
                },
              },
            },
          ],
        },
      });
      expect(tester.widget<Stack>(find.byType(Stack)).clipBehavior, Clip.none);
      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.width, isNull);
      expect(positioned.height, isNull);

      await pumpSpec({
        'type': 'Stack',
        'props': {
          'children': [
            {
              'type': 'AnimatedPositioned',
              'props': {
                'left': 0,
                'top': 0,
                'width': -9,
                'height': -10,
                'duration': 1,
                'child': {
                  'type': 'Text',
                  'props': {'data': 'animated positioned'},
                },
              },
            },
          ],
        },
      });
      final animatedPositioned = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(animatedPositioned.width, 0);
      expect(animatedPositioned.height, 0);

      await pumpSpec({
        'type': 'Wrap',
        'props': {
          'spacing': -6,
          'runSpacing': -7,
          'runAlignment': 'spaceEvenly',
          'textDirection': 'rtl',
          'verticalDirection': 'up',
          'clipBehavior': 'hardEdge',
          'children': [
            {
              'type': 'Text',
              'props': {'data': 'wrapped'},
            },
          ],
        },
      });
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 0);
      expect(wrap.runSpacing, 0);
      expect(wrap.runAlignment, WrapAlignment.spaceEvenly);
      expect(wrap.textDirection, TextDirection.rtl);
      expect(wrap.verticalDirection, VerticalDirection.up);
      expect(wrap.clipBehavior, Clip.hardEdge);
    },
  );

  testWidgets('maps implicit animation props and callbacks safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    Future<void> pumpSpec(Map<String, Object?> spec) {
      return tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 14),
              child: Builder(
                builder: (context) => renderer.buildWidget(context, spec),
              ),
            ),
          ),
        ),
      );
    }

    await pumpSpec({
      'type': 'Opacity',
      'props': {
        'opacity': 4,
        'alwaysIncludeSemantics': true,
        'child': {
          'type': 'Text',
          'props': {'data': 'opacity'},
        },
      },
    });
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1);
    expect(opacity.alwaysIncludeSemantics, isTrue);

    await pumpSpec({
      'type': 'AnimatedOpacity',
      'props': {
        'opacity': .2,
        'duration': 1,
        'alwaysIncludeSemantics': true,
        'onEnd': {
          'type': 'Action',
          'props': {'name': 'animationEnded'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'fade'},
        },
      },
    });
    actions.clear();
    await pumpSpec({
      'type': 'AnimatedOpacity',
      'props': {
        'opacity': 2,
        'duration': 1,
        'alwaysIncludeSemantics': true,
        'onEnd': {
          'type': 'Action',
          'props': {'name': 'animationEnded'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'fade'},
        },
      },
    });
    final animatedOpacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(animatedOpacity.opacity, 1);
    expect(animatedOpacity.alwaysIncludeSemantics, isTrue);
    await tester.pump(const Duration(milliseconds: 20));
    expect(actions.map((action) => action.name), contains('animationEnded'));

    await pumpSpec({
      'type': 'AnimatedContainer',
      'props': {
        'width': -24,
        'height': -12,
        'margin': -8,
        'padding': -6,
        'constraints': {'minWidth': -1, 'maxWidth': -2},
        'color': '#ffffff',
        'clipBehavior': 'hardEdge',
        'duration': 120,
        'child': {
          'type': 'Text',
          'props': {'data': 'animated container'},
        },
      },
    });
    final animatedContainer = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(animatedContainer.constraints!.minWidth, 0);
    expect(animatedContainer.constraints!.maxWidth, 0);
    expect(animatedContainer.margin, EdgeInsets.zero);
    expect(animatedContainer.padding, EdgeInsets.zero);
    expect(animatedContainer.clipBehavior, Clip.hardEdge);

    await pumpSpec({
      'type': 'AnimatedAlign',
      'props': {
        'alignment': 'bottomRight',
        'widthFactor': -1,
        'heightFactor': -2,
        'duration': 120,
        'child': {
          'type': 'Text',
          'props': {'data': 'animated align'},
        },
      },
    });
    final animatedAlign = tester.widget<AnimatedAlign>(
      find.byType(AnimatedAlign),
    );
    expect(animatedAlign.alignment, Alignment.bottomRight);
    expect(animatedAlign.widthFactor, 0);
    expect(animatedAlign.heightFactor, 0);

    await pumpSpec({
      'type': 'AnimatedScale',
      'props': {
        'scale': 1.5,
        'alignment': 'topLeft',
        'filterQuality': 'high',
        'duration': 120,
        'child': {
          'type': 'Text',
          'props': {'data': 'scale'},
        },
      },
    });
    final animatedScale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(animatedScale.scale, 1.5);
    expect(animatedScale.alignment, Alignment.topLeft);
    expect(animatedScale.filterQuality, FilterQuality.high);

    await pumpSpec({
      'type': 'AnimatedRotation',
      'props': {
        'turns': .25,
        'filterQuality': 'low',
        'duration': 120,
        'child': {
          'type': 'Text',
          'props': {'data': 'rotation'},
        },
      },
    });
    final animatedRotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(animatedRotation.turns, .25);
    expect(animatedRotation.filterQuality, FilterQuality.low);

    await pumpSpec({
      'type': 'AnimatedSlide',
      'props': {
        'offset': {'dx': .25, 'dy': -.5},
        'duration': 120,
        'child': {
          'type': 'Text',
          'props': {'data': 'slide'},
        },
      },
    });
    expect(
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
      const Offset(.25, -.5),
    );

    await pumpSpec({
      'type': 'AnimatedSize',
      'props': {
        'duration': 120,
        'reverseDuration': 60,
        'clipBehavior': 'none',
        'child': {
          'type': 'Text',
          'props': {'data': 'size'},
        },
      },
    });
    final animatedSize = tester.widget<AnimatedSize>(find.byType(AnimatedSize));
    expect(animatedSize.reverseDuration, const Duration(milliseconds: 60));
    expect(animatedSize.clipBehavior, Clip.none);

    await pumpSpec({
      'type': 'AnimatedCrossFade',
      'props': {
        'crossFadeState': 'showSecond',
        'duration': 120,
        'reverseDuration': 40,
        'alignment': 'bottomCenter',
        'excludeBottomFocus': false,
        'firstChild': {
          'type': 'Text',
          'props': {'data': 'first'},
        },
        'secondChild': {
          'type': 'Text',
          'props': {'data': 'second'},
        },
      },
    });
    final crossFade = tester.widget<AnimatedCrossFade>(
      find.byType(AnimatedCrossFade),
    );
    expect(crossFade.crossFadeState, CrossFadeState.showSecond);
    expect(crossFade.reverseDuration, const Duration(milliseconds: 40));
    expect(crossFade.alignment, Alignment.bottomCenter);
    expect(crossFade.excludeBottomFocus, isFalse);

    await pumpSpec({
      'type': 'PhysicalModel',
      'props': {
        'elevation': -3,
        'color': '#ffffff',
        'clipBehavior': 'antiAlias',
        'child': {
          'type': 'Text',
          'props': {'data': 'physical'},
        },
      },
    });
    final physicalModel = tester.widget<PhysicalModel>(
      find.byType(PhysicalModel),
    );
    expect(physicalModel.elevation, 0);
    expect(physicalModel.clipBehavior, Clip.antiAlias);

    await pumpSpec({
      'type': 'AnimatedPhysicalModel',
      'props': {
        'elevation': -4,
        'color': '#ffffff',
        'shadowColor': '#000000',
        'animateColor': false,
        'animateShadowColor': false,
        'duration': 120,
        'child': {
          'type': 'Text',
          'props': {'data': 'animated physical'},
        },
      },
    });
    final animatedPhysical = tester.widget<AnimatedPhysicalModel>(
      find.byType(AnimatedPhysicalModel),
    );
    expect(animatedPhysical.elevation, 0);
    expect(animatedPhysical.animateColor, isFalse);
    expect(animatedPhysical.animateShadowColor, isFalse);
  });

  testWidgets('maps visibility, clipping, and transform props safely', (
    tester,
  ) async {
    final renderer = AppletRenderer();

    Future<void> pumpSpec(Map<String, Object?> spec) {
      return tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 14),
              child: Builder(
                builder: (context) => renderer.buildWidget(context, spec),
              ),
            ),
          ),
        ),
      );
    }

    await pumpSpec({
      'type': 'Visibility',
      'props': {
        'visible': false,
        'maintainSemantics': true,
        'maintainInteractivity': true,
        'maintainFocusability': true,
        'replacement': {
          'type': 'Text',
          'props': {'data': 'replacement'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'hidden'},
        },
      },
    });
    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, isFalse);
    expect(visibility.maintainState, isTrue);
    expect(visibility.maintainAnimation, isTrue);
    expect(visibility.maintainSize, isTrue);
    expect(visibility.maintainSemantics, isTrue);
    expect(visibility.maintainInteractivity, isTrue);
    expect(visibility.maintainFocusability, isTrue);

    await pumpSpec({
      'type': 'Column',
      'props': {
        'children': [
          {
            'type': 'Offstage',
            'props': {
              'offstage': false,
              'child': {
                'type': 'Text',
                'props': {'data': 'offstage'},
              },
            },
          },
          {
            'type': 'IgnorePointer',
            'props': {
              'ignoring': false,
              'child': {
                'type': 'Text',
                'props': {'data': 'ignore'},
              },
            },
          },
          {
            'type': 'AbsorbPointer',
            'props': {
              'absorbing': false,
              'child': {
                'type': 'Text',
                'props': {'data': 'absorb'},
              },
            },
          },
        ],
      },
    });
    expect(tester.widget<Offstage>(find.byType(Offstage)).offstage, isFalse);
    expect(
      tester.widget<IgnorePointer>(find.byType(IgnorePointer)).ignoring,
      isFalse,
    );
    expect(
      tester.widget<AbsorbPointer>(find.byType(AbsorbPointer)).absorbing,
      isFalse,
    );

    await pumpSpec({
      'type': 'Column',
      'props': {
        'children': [
          {
            'type': 'ClipRRect',
            'props': {
              'radius': 8,
              'clipBehavior': 'none',
              'child': {
                'type': 'Text',
                'props': {'data': 'clip rrect'},
              },
            },
          },
          {
            'type': 'ClipOval',
            'props': {
              'clipBehavior': 'hardEdge',
              'child': {
                'type': 'Text',
                'props': {'data': 'clip oval'},
              },
            },
          },
          {
            'type': 'ClipRect',
            'props': {
              'clipBehavior': 'antiAlias',
              'child': {
                'type': 'Text',
                'props': {'data': 'clip rect'},
              },
            },
          },
          {
            'type': 'RotatedBox',
            'props': {
              'quarterTurns': -1,
              'child': {
                'type': 'Text',
                'props': {'data': 'rotated'},
              },
            },
          },
        ],
      },
    });
    final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clipRRect.borderRadius, BorderRadius.circular(8));
    expect(clipRRect.clipBehavior, Clip.none);
    expect(
      tester.widget<ClipOval>(find.byType(ClipOval)).clipBehavior,
      Clip.hardEdge,
    );
    expect(
      tester.widget<ClipRect>(find.byType(ClipRect)).clipBehavior,
      Clip.antiAlias,
    );
    expect(tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns, -1);

    await pumpSpec({
      'type': 'Transform',
      'props': {
        'rotate': .5,
        'origin': {'dx': 2, 'dy': 3},
        'alignment': 'topLeft',
        'transformHitTests': false,
        'filterQuality': 'high',
        'child': {
          'type': 'Text',
          'props': {'data': 'rotate'},
        },
      },
    });
    var transform = tester.widget<Transform>(find.byType(Transform));
    expect(transform.origin, const Offset(2, 3));
    expect(transform.alignment, Alignment.topLeft);
    expect(transform.transformHitTests, isFalse);
    expect(transform.filterQuality, FilterQuality.high);

    await pumpSpec({
      'type': 'Transform',
      'props': {
        'scaleX': 2,
        'scaleY': 3,
        'filterQuality': 'low',
        'child': {
          'type': 'Text',
          'props': {'data': 'scale'},
        },
      },
    });
    transform = tester.widget<Transform>(find.byType(Transform));
    expect(transform.transform.storage[0], 2);
    expect(transform.transform.storage[5], 3);
    expect(transform.filterQuality, FilterQuality.low);

    await pumpSpec({
      'type': 'Transform',
      'props': {
        'translate': {'dx': 4, 'dy': 5},
        'transformHitTests': false,
        'child': {
          'type': 'Text',
          'props': {'data': 'translate'},
        },
      },
    });
    transform = tester.widget<Transform>(find.byType(Transform));
    expect(transform.transform.storage[12], 4);
    expect(transform.transform.storage[13], 5);
    expect(transform.transformHitTests, isFalse);

    await pumpSpec({
      'type': 'Transform',
      'props': {
        'flipX': true,
        'flipY': true,
        'child': {
          'type': 'Text',
          'props': {'data': 'flip'},
        },
      },
    });
    transform = tester.widget<Transform>(find.byType(Transform));
    expect(transform.transform.storage[0], -1);
    expect(transform.transform.storage[5], -1);
  });

  testWidgets('maps inherited, semantics, and simple widget props safely', (
    tester,
  ) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    Future<void> pumpSpec(Map<String, Object?> spec) {
      return tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 14),
              child: Builder(
                builder: (context) => renderer.buildWidget(context, spec),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> pumpMaterialSpec(Map<String, Object?> spec) {
      return tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => renderer.buildWidget(context, spec),
          ),
        ),
      );
    }

    await pumpSpec({
      'type': 'MediaQuery',
      'props': {
        'size': {'width': 390, 'height': 844},
        'devicePixelRatio': 3,
        'textScaler': {'scale': 1.3},
        'platformBrightness': 'dark',
        'padding': {'top': 24, 'bottom': 12},
        'viewInsets': {'bottom': 300},
        'viewPadding': {'top': 44},
        'systemGestureInsets': {'left': 8, 'right': 8},
        'alwaysUse24HourFormat': true,
        'accessibleNavigation': true,
        'invertColors': true,
        'highContrast': true,
        'onOffSwitchLabels': true,
        'disableAnimations': true,
        'boldText': true,
        'supportsAnnounce': true,
        'navigationMode': 'directional',
        'gestureSettings': {'touchSlop': -12},
        'displayFeatures': [
          {
            'bounds': {'left': 100, 'top': 0, 'width': 20, 'height': 844},
            'type': 'hinge',
            'state': 'postureHalfOpened',
          },
          {
            'bounds': {'left': 0, 'top': 0, 'width': 40, 'height': 20},
            'type': 'cutout',
            'state': 'postureFlat',
          },
        ],
        'supportsShowingSystemContextMenu': true,
        'lineHeightScaleFactorOverride': 1.4,
        'letterSpacingOverride': -0.2,
        'wordSpacingOverride': 1.1,
        'paragraphSpacingOverride': -6,
        'displayCornerRadius': 18,
        'child': {
          'type': 'Text',
          'props': {'data': 'media'},
        },
      },
    });
    final mediaQuery = tester.widget<MediaQuery>(
      find.byWidgetPredicate(
        (widget) =>
            widget is MediaQuery && widget.data.size == const Size(390, 844),
      ),
    );
    final media = mediaQuery.data;
    expect(media.devicePixelRatio, 3);
    expect(media.textScaler.scale(10), 13);
    expect(media.platformBrightness, Brightness.dark);
    expect(media.padding, const EdgeInsets.only(top: 24, bottom: 12));
    expect(media.viewInsets, const EdgeInsets.only(bottom: 300));
    expect(media.viewPadding, const EdgeInsets.only(top: 44));
    expect(media.systemGestureInsets, const EdgeInsets.only(left: 8, right: 8));
    expect(media.alwaysUse24HourFormat, isTrue);
    expect(media.accessibleNavigation, isTrue);
    expect(media.invertColors, isTrue);
    expect(media.highContrast, isTrue);
    expect(media.onOffSwitchLabels, isTrue);
    expect(media.disableAnimations, isTrue);
    expect(media.boldText, isTrue);
    expect(media.supportsAnnounce, isTrue);
    expect(media.navigationMode, NavigationMode.directional);
    expect(media.gestureSettings.touchSlop, 0);
    expect(media.displayFeatures, hasLength(2));
    expect(
      media.displayFeatures.first.bounds,
      const Rect.fromLTWH(100, 0, 20, 844),
    );
    expect(media.displayFeatures.first.type, ui.DisplayFeatureType.hinge);
    expect(
      media.displayFeatures.first.state,
      ui.DisplayFeatureState.postureHalfOpened,
    );
    expect(media.displayFeatures.last.type, ui.DisplayFeatureType.cutout);
    expect(media.displayFeatures.last.state, ui.DisplayFeatureState.unknown);
    expect(media.supportsShowingSystemContextMenu, isTrue);
    expect(media.lineHeightScaleFactorOverride, 1.4);
    expect(media.letterSpacingOverride, -0.2);
    expect(media.wordSpacingOverride, 1.1);
    expect(media.paragraphSpacingOverride, 0);
    expect(media.displayCornerRadii, BorderRadius.circular(18));

    await pumpSpec({
      'type': 'Directionality',
      'props': {
        'textDirection': 'rtl',
        'child': {
          'type': 'TickerMode',
          'props': {
            'enabled': false,
            'forceFrames': true,
            'child': {
              'type': 'Text',
              'props': {'data': 'directional'},
            },
          },
        },
      },
    });
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).last,
    );
    expect(directionality.textDirection, TextDirection.rtl);
    final tickerMode = tester.widget<TickerMode>(find.byType(TickerMode));
    expect(tickerMode.enabled, isFalse);
    expect(tickerMode.forceFrames, isTrue);

    await pumpSpec({
      'type': 'DefaultSelectionStyle',
      'props': {
        'cursorColor': '#ff0000',
        'selectionColor': '#00ff00',
        'mouseCursor': 'text',
        'child': {
          'type': 'Text',
          'props': {'data': 'selection style'},
        },
      },
    });
    final selectionStyle = tester.widget<DefaultSelectionStyle>(
      find.byType(DefaultSelectionStyle),
    );
    expect(selectionStyle.cursorColor, const Color(0xffff0000));
    expect(selectionStyle.selectionColor, const Color(0xff00ff00));
    expect(selectionStyle.mouseCursor, SystemMouseCursors.text);

    await pumpMaterialSpec({
      'type': 'SelectionArea',
      'props': {
        'selectionControls': 'empty',
        'contextMenu': false,
        'magnifier': false,
        'onSelectionChanged': {
          'type': 'Action',
          'props': {'name': 'selectionChanged'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'selectable surface'},
        },
      },
    });
    var selectionArea = tester.widget<SelectionArea>(
      find.byType(SelectionArea),
    );
    expect(selectionArea.selectionControls, same(emptyTextSelectionControls));
    expect(selectionArea.contextMenuBuilder, isNull);
    expect(
      selectionArea.magnifierConfiguration,
      TextMagnifierConfiguration.disabled,
    );
    selectionArea.onSelectionChanged!(
      const SelectedContent(plainText: 'selected plain text'),
    );
    selectionArea.onSelectionChanged!(null);
    expect(actions.map((action) => action.name), [
      'selectionChanged',
      'selectionChanged',
    ]);
    expect(actions[0].payload, 'selected plain text');
    expect(actions[1].payload, isNull);
    actions.clear();

    await pumpMaterialSpec({
      'type': 'SelectionArea',
      'props': {
        'selectionControls': 'cupertinoDesktop',
        'showToolbar': true,
        'magnifier': true,
        'child': {
          'type': 'Text',
          'props': {'data': 'adaptive selectable surface'},
        },
      },
    });
    selectionArea = tester.widget<SelectionArea>(find.byType(SelectionArea));
    expect(
      selectionArea.selectionControls,
      same(cupertino.cupertinoDesktopTextSelectionHandleControls),
    );
    expect(selectionArea.contextMenuBuilder, isNotNull);
    expect(
      selectionArea.magnifierConfiguration,
      same(TextMagnifier.adaptiveMagnifierConfiguration),
    );

    await pumpSpec({
      'type': 'DefaultTextStyle',
      'props': {
        'style': {'fontSize': 18, 'fontWeight': 'w700'},
        'textAlign': 'center',
        'softWrap': false,
        'maxLines': -3,
        'overflow': 'ellipsis',
        'child': {
          'type': 'Text',
          'props': {'data': 'default text'},
        },
      },
    });
    final defaultTextStyle = tester.widget<DefaultTextStyle>(
      find.byType(DefaultTextStyle).last,
    );
    expect(defaultTextStyle.style.fontSize, 18);
    expect(defaultTextStyle.style.fontWeight, FontWeight.w700);
    expect(defaultTextStyle.textAlign, TextAlign.center);
    expect(defaultTextStyle.softWrap, isFalse);
    expect(defaultTextStyle.maxLines, isNull);
    expect(defaultTextStyle.overflow, TextOverflow.ellipsis);

    await pumpSpec({
      'type': 'IconTheme',
      'props': {
        'color': '#123456',
        'size': 32,
        'opacity': 1.2,
        'fill': 1.4,
        'weight': -5,
        'grade': 100,
        'opticalSize': -24,
        'shadows': [
          {
            'color': '#55000000',
            'offset': [1, 2],
            'blurRadius': 3,
          },
        ],
        'applyTextScaling': true,
        'child': {
          'type': 'Icon',
          'props': {'icon': 'star'},
        },
      },
    });
    final iconTheme = tester.widget<IconTheme>(find.byType(IconTheme));
    expect(iconTheme.data.color, const Color(0xff123456));
    expect(iconTheme.data.size, 32);
    expect(iconTheme.data.opacity, 1);
    expect(iconTheme.data.fill, 1);
    expect(iconTheme.data.weight, isNull);
    expect(iconTheme.data.grade, 100);
    expect(iconTheme.data.opticalSize, isNull);
    expect(iconTheme.data.shadows, hasLength(1));
    expect(iconTheme.data.shadows!.single.color, const Color(0x55000000));
    expect(iconTheme.data.shadows!.single.offset, const Offset(1, 2));
    expect(iconTheme.data.shadows!.single.blurRadius, 3);
    expect(iconTheme.data.applyTextScaling, isTrue);

    await pumpSpec({
      'type': 'Icon',
      'props': {
        'icon': 'star',
        'size': -24,
        'fill': 4,
        'weight': -10,
        'grade': -25,
        'opticalSize': -48,
        'color': '#654321',
        'shadow': {'color': '#33000000', 'dx': 2, 'dy': 4, 'blur': 6},
        'semanticsLabel': 'Favorite star',
        'textDirection': 'rtl',
        'applyTextScaling': true,
        'blendMode': 'srcIn',
        'fontWeight': 'w700',
      },
    });
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.star);
    expect(icon.size, 0);
    expect(icon.fill, 1);
    expect(icon.weight, isNull);
    expect(icon.grade, -25);
    expect(icon.opticalSize, isNull);
    expect(icon.color, const Color(0xff654321));
    expect(icon.shadows, hasLength(1));
    expect(icon.shadows!.single.color, const Color(0x33000000));
    expect(icon.shadows!.single.offset, const Offset(2, 4));
    expect(icon.shadows!.single.blurRadius, 6);
    expect(icon.semanticLabel, 'Favorite star');
    expect(icon.textDirection, TextDirection.rtl);
    expect(icon.applyTextScaling, isTrue);
    expect(icon.blendMode, BlendMode.srcIn);
    expect(icon.fontWeight, FontWeight.w700);

    await pumpSpec({
      'type': 'Theme',
      'props': {
        'data': {'seedColor': '#006a6a', 'brightness': 'dark'},
        'child': {
          'type': 'Text',
          'props': {'data': 'themed'},
        },
      },
    });
    final theme = tester.widget<Theme>(find.byType(Theme));
    expect(theme.data.brightness, Brightness.dark);

    await pumpSpec({
      'type': 'Semantics',
      'props': {
        'container': true,
        'explicitChildNodes': true,
        'blockUserActions': true,
        'enabled': true,
        'button': true,
        'link': true,
        'linkUrl': 'https://example.com/docs',
        'headingLevel': 2,
        'maxValueLength': -5,
        'currentValueLength': 3,
        'identifier': 'sem-id',
        'traversalParentIdentifier': 'parent-id',
        'traversalChildIdentifier': 'child-id',
        'label': 'Sem label',
        'value': '50',
        'minValue': 0,
        'maxValue': 100,
        'hint': 'Sem hint',
        'tooltip': 'Sem tooltip',
        'onTapHint': 'Activate',
        'onLongPressHint': 'Inspect',
        'textDirection': 'rtl',
        'role': 'status',
        'onCopy': {
          'type': 'Action',
          'props': {'name': 'copySemantics'},
        },
        'onDidGainAccessibilityFocus': {
          'type': 'Action',
          'props': {'name': 'gainFocus'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'semantic child'},
        },
      },
    });
    final semantics = tester.widget<Semantics>(find.byType(Semantics));
    expect(semantics.container, isTrue);
    expect(semantics.explicitChildNodes, isTrue);
    expect(semantics.blockUserActions, isTrue);
    expect(semantics.properties.enabled, isTrue);
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.link, isTrue);
    expect(semantics.properties.linkUrl, Uri.parse('https://example.com/docs'));
    expect(semantics.properties.headingLevel, 2);
    expect(semantics.properties.maxValueLength, 0);
    expect(semantics.properties.currentValueLength, 3);
    expect(semantics.properties.identifier, 'sem-id');
    expect(semantics.properties.traversalParentIdentifier, 'parent-id');
    expect(semantics.properties.traversalChildIdentifier, 'child-id');
    expect(semantics.properties.label, 'Sem label');
    expect(semantics.properties.value, '50');
    expect(semantics.properties.minValue, '0');
    expect(semantics.properties.maxValue, '100');
    expect(semantics.properties.hint, 'Sem hint');
    expect(semantics.properties.tooltip, 'Sem tooltip');
    expect(semantics.properties.hintOverrides?.onTapHint, 'Activate');
    expect(semantics.properties.hintOverrides?.onLongPressHint, 'Inspect');
    expect(semantics.properties.textDirection, TextDirection.rtl);
    expect(semantics.properties.role, ui.SemanticsRole.status);

    actions.clear();
    semantics.properties.onCopy!();
    semantics.properties.onDidGainAccessibilityFocus!();
    expect(actions.map((action) => action.name), [
      'copySemantics',
      'gainFocus',
    ]);

    await pumpSpec({
      'type': 'Column',
      'props': {
        'children': [
          {
            'type': 'MergeSemantics',
            'props': {
              'child': {
                'type': 'ExcludeSemantics',
                'props': {
                  'excluding': false,
                  'child': {
                    'type': 'Text',
                    'props': {'data': 'included'},
                  },
                },
              },
            },
          },
          {
            'type': 'RepaintBoundary',
            'props': {
              'child': {
                'type': 'Text',
                'props': {'data': 'paint boundary'},
              },
            },
          },
        ],
      },
    });
    expect(find.byType(MergeSemantics), findsOneWidget);
    expect(
      tester.widget<ExcludeSemantics>(find.byType(ExcludeSemantics)).excluding,
      isFalse,
    );
    expect(find.byType(RepaintBoundary), findsOneWidget);

    await pumpSpec({
      'type': 'ColoredBox',
      'props': {
        'color': '#123456',
        'isAntiAlias': false,
        'child': {
          'type': 'Text',
          'props': {'data': 'color box'},
        },
      },
    });
    final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
    expect(coloredBox.color, const Color(0xff123456));
    expect(coloredBox.isAntiAlias, isFalse);

    await pumpSpec({
      'type': 'DecoratedBox',
      'props': {
        'position': 'foreground',
        'decoration': {'color': '#654321'},
        'child': {
          'type': 'Text',
          'props': {'data': 'decorated'},
        },
      },
    });
    final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    expect(decoratedBox.position, DecorationPosition.foreground);
    expect(
      (decoratedBox.decoration as BoxDecoration).color,
      const Color(0xff654321),
    );

    await pumpSpec({
      'type': 'Placeholder',
      'props': {
        'color': '#abcdef',
        'strokeWidth': -1,
        'fallbackWidth': -2,
        'fallbackHeight': -3,
        'child': {
          'type': 'Text',
          'props': {'data': 'placeholder child'},
        },
      },
    });
    final placeholder = tester.widget<Placeholder>(find.byType(Placeholder));
    expect(placeholder.color, const Color(0xffabcdef));
    expect(placeholder.strokeWidth, 0);
    expect(placeholder.fallbackWidth, 0);
    expect(placeholder.fallbackHeight, 0);
    expect(placeholder.child, isNotNull);

    await pumpMaterialSpec({
      'type': 'Tooltip',
      'props': {
        'message': 'Tip',
        'constraints': {'minWidth': 24, 'maxWidth': 64},
        'padding': {'horizontal': 8, 'vertical': 4},
        'margin': 12,
        'verticalOffset': -4,
        'preferBelow': false,
        'excludeFromSemantics': true,
        'decoration': {'color': '#222222'},
        'textStyle': {'fontSize': 13, 'color': '#ffffff'},
        'textAlign': 'center',
        'waitDuration': 10,
        'showDuration': {'milliseconds': 20},
        'exitDuration': {'milliseconds': 30},
        'enableTapToDismiss': false,
        'triggerMode': 'tap',
        'enableFeedback': false,
        'mouseCursor': 'click',
        'ignorePointer': true,
        'onTriggered': {
          'type': 'Action',
          'props': {'name': 'tooltipTriggered'},
        },
        'child': {
          'type': 'Text',
          'props': {'data': 'tooltip target'},
        },
      },
    });
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'Tip');
    expect(
      tooltip.constraints,
      const BoxConstraints(minWidth: 24, maxWidth: 64),
    );
    expect(
      tooltip.padding,
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
    expect(tooltip.margin, const EdgeInsets.all(12));
    expect(tooltip.verticalOffset, 0);
    expect(tooltip.preferBelow, isFalse);
    expect(tooltip.excludeFromSemantics, isTrue);
    expect(
      (tooltip.decoration as BoxDecoration).color,
      const Color(0xff222222),
    );
    expect(tooltip.textStyle?.fontSize, 13);
    expect(tooltip.textStyle?.color, const Color(0xffffffff));
    expect(tooltip.textAlign, TextAlign.center);
    expect(tooltip.waitDuration, const Duration(milliseconds: 10));
    expect(tooltip.showDuration, const Duration(milliseconds: 20));
    expect(tooltip.exitDuration, const Duration(milliseconds: 30));
    expect(tooltip.enableTapToDismiss, isFalse);
    expect(tooltip.triggerMode, TooltipTriggerMode.tap);
    expect(tooltip.enableFeedback, isFalse);
    expect(tooltip.mouseCursor, SystemMouseCursors.click);
    expect(tooltip.ignorePointer, isTrue);
    actions.clear();
    tooltip.onTriggered!();
    expect(actions.single.name, 'tooltipTriggered');

    await pumpSpec({
      'type': 'Hero',
      'props': {
        'tag': 'hero-tag',
        'transitionOnUserGestures': true,
        'curve': 'easeIn',
        'reverseCurve': 'easeOut',
        'child': {
          'type': 'Text',
          'props': {'data': 'hero child'},
        },
      },
    });
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'hero-tag');
    expect(hero.transitionOnUserGestures, isTrue);
    expect(hero.curve, Curves.easeIn);
    expect(hero.reverseCurve, Curves.easeOut);
  });

  testWidgets(
    'renders selection, adaptive wrappers, animations, and surfaces',
    (tester) async {
      final renderer = AppletRenderer();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => renderer.buildWidget(context, {
              'type': 'Scaffold',
              'props': {
                'body': {
                  'type': 'ListView',
                  'props': {
                    'children': [
                      {
                        'type': 'AnimatedTheme',
                        'props': {
                          'data': {'seedColor': '#006a6a'},
                          'duration': 120,
                          'child': {
                            'type': 'Directionality',
                            'props': {
                              'textDirection': 'ltr',
                              'child': {
                                'type': 'DefaultSelectionStyle',
                                'props': {
                                  'selectionColor': '#ffcc80',
                                  'child': {
                                    'type': 'SelectionArea',
                                    'props': {
                                      'child': {
                                        'type': 'SelectableText',
                                        'props': {'data': 'Selectable shell'},
                                      },
                                    },
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                      {
                        'type': 'TickerMode',
                        'props': {
                          'enabled': true,
                          'child': {
                            'type': 'AnimatedDefaultTextStyle',
                            'props': {
                              'style': {'fontSize': 18, 'color': '#006a6a'},
                              'duration': 120,
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'Animated text'},
                              },
                            },
                          },
                        },
                      },
                      {
                        'type': 'SizedBox',
                        'props': {
                          'height': 80,
                          'child': {
                            'type': 'Stack',
                            'props': {
                              'children': [
                                {
                                  'type': 'AnimatedPositioned',
                                  'props': {
                                    'left': 12,
                                    'top': 8,
                                    'width': 160,
                                    'height': 48,
                                    'duration': 120,
                                    'child': {
                                      'type': 'Text',
                                      'props': {'data': 'Positioned'},
                                    },
                                  },
                                },
                              ],
                            },
                          },
                        },
                      },
                      {
                        'type': 'PhysicalModel',
                        'props': {
                          'color': '#ffffff',
                          'shadowColor': '#000000',
                          'elevation': 2,
                          'borderRadius': 8,
                          'child': {
                            'type': 'Text',
                            'props': {'data': 'Physical'},
                          },
                        },
                      },
                      {
                        'type': 'AnimatedPhysicalModel',
                        'props': {
                          'color': '#ffffff',
                          'shadowColor': '#000000',
                          'elevation': 4,
                          'duration': 120,
                          'child': {
                            'type': 'Text',
                            'props': {'data': 'Animated physical'},
                          },
                        },
                      },
                      {
                        'type': 'SizedBox',
                        'props': {
                          'height': 96,
                          'child': {
                            'type': 'Scrollbar',
                            'props': {
                              'child': {
                                'type': 'ListView',
                                'props': {
                                  'children': [
                                    {
                                      'type': 'Text',
                                      'props': {'data': 'Scrolled item'},
                                    },
                                  ],
                                },
                              },
                            },
                          },
                        },
                      },
                      {
                        'type': 'Dialog',
                        'props': {
                          'child': {
                            'type': 'Padding',
                            'props': {
                              'padding': 16,
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'Dialog body'},
                              },
                            },
                          },
                        },
                      },
                      {
                        'type': 'BottomSheet',
                        'props': {
                          'showDragHandle': true,
                          'child': {
                            'type': 'Padding',
                            'props': {
                              'padding': 16,
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'Sheet body'},
                              },
                            },
                          },
                        },
                      },
                    ],
                  },
                },
              },
            }),
          ),
        ),
      );

      expect(find.text('Selectable shell'), findsOneWidget);
      expect(find.text('Animated text'), findsOneWidget);
      expect(find.text('Positioned'), findsOneWidget);
      expect(find.text('Physical'), findsOneWidget);
      expect(find.text('Animated physical'), findsOneWidget);
      expect(find.text('Scrolled item'), findsOneWidget);
      expect(find.text('Dialog body'), findsOneWidget);
      expect(find.text('Sheet body'), findsOneWidget);
    },
  );

  test('keeps coverage docs and type declarations aligned', () {
    final coverage = File('docs/flutter-coverage.md').readAsStringSync();
    final declarations = File('types/app.d.ts').readAsStringSync();

    for (final symbol in <String>[
      'SelectableText',
      'Semantics',
      'IndexedStack',
      'MenuBar',
      'MenuItemButton',
      'Directionality',
      'SelectionArea',
      'AnimatedTheme',
      'AnimatedPositioned',
      'Scrollbar',
      'Dialog',
      'BottomSheet',
      'Listener',
      'MouseRegion',
      'InteractiveViewer',
      'AdaptiveTwoPane',
      'Dismissible',
      'Draggable',
      'LongPressDraggable',
      'DragTarget',
      'TapRegion',
      'TapRegionSurface',
      'FocusableActionDetector',
      'ReorderableListView',
      'ReorderableDragStartListener',
      'ReorderableDelayedDragStartListener',
      'SliverAppBar',
      'SliverLayoutBuilder',
      'SliverCachedList',
      'CupertinoSliverNavigationBar',
      'OrientationBuilder',
      'ScaffoldMessenger',
      'AdaptiveNavigationScaffold',
      'KeyboardListener',
      'CallbackShortcuts',
      'Autocomplete',
    ]) {
      expect(coverage, contains(symbol));
      expect(declarations, contains(symbol));
    }
    expect(appletBuiltinModules['@app/widgets'], contains('SelectableText'));
    expect(appletBuiltinModules['@app/widgets'], contains('Directionality'));
    expect(appletBuiltinModules['@app/widgets'], contains('Listener'));
    expect(appletBuiltinModules['@app/widgets'], contains('MouseRegion'));
    expect(appletBuiltinModules['@app/widgets'], contains('InteractiveViewer'));
    expect(appletBuiltinModules['@app/layout'], contains('InteractiveViewer'));
    expect(appletBuiltinModules['@app/layout'], contains('AdaptiveTwoPane'));
    expect(appletBuiltinModules['@app/widgets'], contains('Dismissible'));
    expect(appletBuiltinModules['@app/widgets'], contains('Draggable'));
    expect(
      appletBuiltinModules['@app/widgets'],
      contains('LongPressDraggable'),
    );
    expect(appletBuiltinModules['@app/widgets'], contains('DragTarget'));
    expect(appletBuiltinModules['@app/widgets'], contains('TapRegion'));
    expect(appletBuiltinModules['@app/widgets'], contains('TapRegionSurface'));
    expect(
      appletBuiltinModules['@app/widgets'],
      contains('FocusableActionDetector'),
    );
    expect(appletBuiltinModules['@app/layout'], contains('OrientationBuilder'));
    expect(
      appletBuiltinModules['@app/layout'],
      contains('ReorderableListView'),
    );
    expect(
      appletBuiltinModules['@app/layout'],
      contains('ReorderableDragStartListener'),
    );
    expect(
      appletBuiltinModules['@app/layout'],
      contains('ReorderableDelayedDragStartListener'),
    );
    expect(appletBuiltinModules['@app/widgets'], contains('KeyboardListener'));
    expect(appletBuiltinModules['@app/widgets'], contains('CallbackShortcuts'));
    expect(appletBuiltinModules['@app/layout'], contains('IndexedStack'));
    expect(appletBuiltinModules['@app/layout'], contains('AnimatedPositioned'));
    expect(appletBuiltinModules['@app/layout'], contains('SliverAppBar'));
    expect(
      appletBuiltinModules['@app/layout'],
      contains('SliverLayoutBuilder'),
    );
    expect(appletBuiltinModules['@app/layout'], contains('SliverCachedList'));
    expect(appletBuiltinModules['@app/material'], contains('MenuItemButton'));
    expect(
      appletBuiltinModules['@app/material'],
      contains('ExpansionPanelList'),
    );
    expect(appletBuiltinModules['@app/material'], contains('SelectionArea'));
    expect(appletBuiltinModules['@app/material'], contains('BottomSheet'));
    expect(
      appletBuiltinModules['@app/material'],
      contains('ScaffoldMessenger'),
    );
    expect(
      appletBuiltinModules['@app/material'],
      contains('AdaptiveNavigationScaffold'),
    );
    expect(appletBuiltinModules['@app/material'], contains('Autocomplete'));
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoFormSection'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoSliverNavigationBar'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoNavigationBarBackButton'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoCheckbox'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoDatePicker'),
    );
    expect(
      appletBuiltinModules['@app/cupertino'],
      contains('CupertinoTimerPicker'),
    );
    expect(appletBootstrapScript, contains('define("ExpansionPanelList"'));
    expect(appletBootstrapScript, contains('ExpansionPanelListRadio'));
    expect(appletBootstrapScript, contains('define("CupertinoFormSection"'));
    expect(appletBootstrapScript, contains('define("CupertinoCheckbox"'));
    expect(appletBootstrapScript, contains('define("CupertinoDatePicker"'));
  });

  testWidgets('renders Cupertino sliver navigation bars', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      Builder(
        builder: (context) => renderer.buildWidget(context, {
          'type': 'CupertinoApp',
          'props': {
            'home': {
              'type': 'CupertinoPageScaffold',
              'props': {
                'child': {
                  'type': 'CustomScrollView',
                  'props': {
                    'slivers': [
                      {
                        'type': 'CupertinoSliverNavigationBar',
                        'props': {
                          'largeTitle': {
                            'type': 'Text',
                            'props': {'data': 'Library'},
                          },
                          'leading': {
                            'type': 'CupertinoNavigationBarBackButton',
                            'props': {
                              'color': '#006a6a',
                              'previousPageTitle': 'Back',
                              'onPressed': {
                                'type': 'Action',
                                'props': {'name': 'backPressed'},
                              },
                            },
                          },
                          'automaticallyImplyLeading': false,
                          'automaticallyImplyTitle': false,
                          'alwaysShowMiddle': false,
                          'previousPageTitle': 'Previous',
                          'middle': {
                            'type': 'Text',
                            'props': {'data': 'Collapsed'},
                          },
                          'trailing': {
                            'type': 'Text',
                            'props': {'data': 'Edit'},
                          },
                          'border': {'color': '#123456', 'width': 2},
                          'backgroundColor': '#eeeeee',
                          'automaticBackgroundVisibility': false,
                          'enableBackgroundFilterBlur': false,
                          'brightness': 'dark',
                          'padding': {'left': 12, 'right': 14},
                          'transitionBetweenRoutes': false,
                          'heroTag': 'sliver-nav',
                          'stretch': true,
                          'bottom': {
                            'type': 'Text',
                            'props': {'data': 'Filters'},
                          },
                          'bottomMode': 'always',
                        },
                      },
                      {
                        'type': 'CupertinoSliverNavigationBar',
                        'props': {
                          'type': 'search',
                          'largeTitle': {
                            'type': 'Text',
                            'props': {'data': 'Search'},
                          },
                          'automaticallyImplyTitle': false,
                          'searchField': {
                            'type': 'CupertinoSearchTextField',
                            'props': {'placeholder': 'Search catalog'},
                          },
                          'bottomMode': 'automatic',
                          'transitionBetweenRoutes': false,
                          'heroTag': 'search-nav',
                          'onSearchableBottomTap': {
                            'type': 'Action',
                            'props': {'name': 'searchBottomTap'},
                          },
                        },
                      },
                      {
                        'type': 'SliverToBoxAdapter',
                        'props': {
                          'child': {
                            'type': 'SizedBox',
                            'props': {'height': 600},
                          },
                        },
                      },
                    ],
                  },
                },
              },
            },
          },
        }),
      ),
    );

    final navBars = tester
        .widgetList<cupertino.CupertinoSliverNavigationBar>(
          find.byType(cupertino.CupertinoSliverNavigationBar),
        )
        .toList();
    expect(navBars, hasLength(2));

    final nav = navBars.first;
    expect((nav.largeTitle as Text).data, 'Library');
    expect(nav.leading, isA<cupertino.CupertinoNavigationBarBackButton>());
    expect(nav.automaticallyImplyLeading, isFalse);
    expect(nav.automaticallyImplyTitle, isFalse);
    expect(nav.alwaysShowMiddle, isFalse);
    expect(nav.previousPageTitle, 'Previous');
    expect((nav.middle as Text).data, 'Collapsed');
    expect((nav.trailing as Text).data, 'Edit');
    expect(nav.border?.bottom.color, const Color(0xff123456));
    expect(nav.border?.bottom.width, 2);
    expect(nav.backgroundColor, const Color(0xffeeeeee));
    expect(nav.automaticBackgroundVisibility, isFalse);
    expect(nav.enableBackgroundFilterBlur, isFalse);
    expect(nav.brightness, Brightness.dark);
    expect(nav.padding, const EdgeInsetsDirectional.only(start: 12, end: 14));
    expect(nav.transitionBetweenRoutes, isFalse);
    expect(nav.heroTag, 'sliver-nav');
    expect(nav.stretch, isTrue);
    expect(nav.bottom, isA<PreferredSize>());
    expect(nav.bottomMode, cupertino.NavigationBarBottomMode.always);

    final backButton =
        nav.leading as cupertino.CupertinoNavigationBarBackButton;
    expect(backButton.color, const Color(0xff006a6a));
    expect(backButton.previousPageTitle, 'Back');

    final searchNav = navBars.last;
    expect((searchNav.largeTitle as Text).data, 'Search');
    expect(searchNav.searchField, isA<cupertino.CupertinoSearchTextField>());
    expect(searchNav.bottom, isNull);
    expect(searchNav.bottomMode, cupertino.NavigationBarBottomMode.automatic);
    expect(searchNav.transitionBetweenRoutes, isFalse);
    expect(searchNav.heroTag, 'search-nav');

    actions.clear();
    backButton.onPressed!();
    searchNav.onSearchableBottomTap!(true);
    expect(actions.map((action) => action.name), [
      'backPressed',
      'searchBottomTap',
    ]);
    expect(actions[1].payload, isTrue);
  });

  testWidgets('renders Cupertino component family', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      Builder(
        builder: (context) => renderer.buildWidget(context, {
          'type': 'CupertinoApp',
          'props': {
            'title': 'Cupertino Suite',
            'debugShowCheckedModeBanner': true,
            'theme': {'primaryColor': '#006a6a'},
            'home': {
              'type': 'CupertinoPageScaffold',
              'props': {
                'backgroundColor': '#f7f7f7',
                'resizeToAvoidBottomInset': false,
                'navigationBar': {
                  'type': 'CupertinoNavigationBar',
                  'props': {
                    'automaticallyImplyLeading': false,
                    'automaticallyImplyMiddle': false,
                    'previousPageTitle': 'Back',
                    'backgroundColor': '#eeeeee',
                    'automaticBackgroundVisibility': false,
                    'enableBackgroundFilterBlur': false,
                    'brightness': 'dark',
                    'padding': {'left': 12, 'right': 14},
                    'transitionBetweenRoutes': false,
                    'heroTag': 'cupertino-nav',
                    'border': {'color': '#00ff00', 'width': 2},
                    'bottom': {
                      'type': 'Text',
                      'props': {'data': 'Nav bottom'},
                    },
                    'middle': {
                      'type': 'Text',
                      'props': {'data': 'iOS'},
                    },
                  },
                },
                'child': {
                  'type': 'SingleChildScrollView',
                  'props': {
                    'child': {
                      'type': 'Column',
                      'props': {
                        'children': [
                          {
                            'type': 'CupertinoSearchTextField',
                            'props': {
                              'placeholder': 'Search iOS',
                              'placeholderStyle': {'color': '#123456'},
                              'backgroundColor': '#eeeeee',
                              'borderRadius': 10,
                              'keyboardType': 'email',
                              'padding': {'horizontal': 9, 'vertical': 7},
                              'itemColor': '#006a6a',
                              'itemSize': 18,
                              'prefixInsets': {'left': 4, 'right': 5},
                              'prefixIcon': {
                                'icon': 'search',
                                'size': 17,
                                'color': '#111111',
                              },
                              'suffixInsets': {'left': 6, 'right': 7},
                              'suffixIcon': 'close',
                              'suffixMode': 'always',
                              'restorationId': 'cupertino-search',
                              'enableIMEPersonalizedLearning': false,
                              'autofocus': true,
                              'autocorrect': false,
                              'enabled': true,
                              'cursorWidth': -1,
                              'cursorHeight': -4,
                              'cursorRadius': {'x': 3, 'y': -5},
                              'cursorOpacityAnimates': false,
                              'cursorColor': '#ff0000',
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'searchChanged'},
                              },
                              'onSubmitted': {
                                'type': 'Action',
                                'props': {'name': 'searchSubmitted'},
                              },
                              'onSuffixTap': {
                                'type': 'Action',
                                'props': {'name': 'searchSuffix'},
                              },
                              'onTap': {
                                'type': 'Action',
                                'props': {'name': 'searchTap'},
                              },
                            },
                          },
                          {
                            'type': 'CupertinoTextField',
                            'props': {
                              'placeholder': 'Account',
                              'placeholderStyle': {'color': '#333333'},
                              'backgroundColor': '#ffffff',
                              'borderRadius': 8,
                              'padding': {'all': 11},
                              'prefix': {
                                'type': 'Icon',
                                'props': {'icon': 'person'},
                              },
                              'prefixMode': 'always',
                              'suffix': {
                                'type': 'Icon',
                                'props': {'icon': 'check'},
                              },
                              'suffixMode': 'editing',
                              'clearButtonMode': 'never',
                              'clearButtonSemanticLabel': 'Clear account',
                              'keyboardType': 'email',
                              'textInputAction': 'next',
                              'textCapitalization': 'words',
                              'style': {'fontSize': 15},
                              'strutStyle': {'fontSize': 14},
                              'textAlign': 'center',
                              'textDirection': 'rtl',
                              'readOnly': false,
                              'showCursor': true,
                              'obscuringCharacter': '**',
                              'obscureText': true,
                              'autocorrect': false,
                              'enableSuggestions': false,
                              'minLines': 3,
                              'maxLines': 2,
                              'maxLength': 'none',
                              'enabled': true,
                              'cursorWidth': -2,
                              'cursorHeight': -3,
                              'cursorRadius': {'x': 4, 'y': -2},
                              'cursorOpacityAnimates': false,
                              'cursorColor': '#00ff00',
                              'selectionHeightStyle': 'top',
                              'selectionWidthStyle': 'max',
                              'scrollPadding': {'all': 12},
                              'dragStartBehavior': 'down',
                              'enableInteractiveSelection': false,
                              'selectAllOnFocus': true,
                              'selectionControls': 'cupertinoDesktop',
                              'scrollPhysics': 'never',
                              'clipBehavior': 'none',
                              'restorationId': 'cupertino-account',
                              'stylusHandwritingEnabled': false,
                              'enableIMEPersonalizedLearning': false,
                              'enableInlinePrediction': true,
                              'contextMenu': false,
                              'magnifier': false,
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'accountChanged'},
                              },
                              'onEditingComplete': {
                                'type': 'Action',
                                'props': {'name': 'accountComplete'},
                              },
                              'onSubmitted': {
                                'type': 'Action',
                                'props': {'name': 'accountSubmitted'},
                              },
                              'onTapOutside': {
                                'type': 'Action',
                                'props': {'name': 'accountTapOutside'},
                              },
                              'onTapUpOutside': {
                                'type': 'Action',
                                'props': {'name': 'accountTapUpOutside'},
                              },
                              'onTap': {
                                'type': 'Action',
                                'props': {'name': 'accountTap'},
                              },
                            },
                          },
                          {
                            'type': 'CupertinoSegmentedControl',
                            'props': {
                              'groupValue': 'one',
                              'unselectedColor': '#ffffff',
                              'selectedColor': '#006a6a',
                              'borderColor': '#333333',
                              'pressedColor': '#dddddd',
                              'disabledColor': '#aaaaaa',
                              'disabledTextColor': '#999999',
                              'padding': {'horizontal': 5, 'vertical': 4},
                              'disabledChildren': ['missing'],
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'segmentChanged'},
                              },
                              'children': [
                                {
                                  'value': 'one',
                                  'label': {
                                    'type': 'Text',
                                    'props': {'data': 'One'},
                                  },
                                },
                                {
                                  'value': 'two',
                                  'label': {
                                    'type': 'Text',
                                    'props': {'data': 'Two'},
                                  },
                                },
                              ],
                            },
                          },
                          {
                            'type': 'CupertinoSlidingSegmentedControl',
                            'props': {
                              'groupValue': 'alpha',
                              'thumbColor': '#ffffff',
                              'backgroundColor': '#eeeeee',
                              'padding': {'horizontal': 7, 'vertical': 3},
                              'proportionalWidth': true,
                              'isMomentary': true,
                              'disabledChildren': ['gamma'],
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'slidingChanged'},
                              },
                              'children': [
                                {
                                  'value': 'alpha',
                                  'label': {
                                    'type': 'Text',
                                    'props': {'data': 'Alpha'},
                                  },
                                },
                                {
                                  'value': 'beta',
                                  'label': {
                                    'type': 'Text',
                                    'props': {'data': 'Beta'},
                                  },
                                },
                              ],
                            },
                          },
                          {
                            'type': 'CupertinoListSection',
                            'props': {
                              'insetGrouped': true,
                              'header': {
                                'type': 'Text',
                                'props': {'data': 'Settings'},
                              },
                              'footer': {
                                'type': 'Text',
                                'props': {'data': 'Settings footer'},
                              },
                              'margin': {'horizontal': 8, 'vertical': 4},
                              'backgroundColor': '#eeeeee',
                              'decoration': {
                                'color': '#ffffff',
                                'borderRadius': 6,
                              },
                              'clipBehavior': 'hardEdge',
                              'dividerMargin': -4,
                              'additionalDividerMargin': 5,
                              'topMargin': 6,
                              'hasLeading': false,
                              'separatorColor': '#123456',
                              'children': [
                                {
                                  'type': 'CupertinoListTile',
                                  'props': {
                                    'notched': true,
                                    'title': {
                                      'type': 'Text',
                                      'props': {'data': 'Account'},
                                    },
                                    'subtitle': {
                                      'type': 'Text',
                                      'props': {'data': 'Primary account'},
                                    },
                                    'additionalInfo': {
                                      'type': 'Text',
                                      'props': {'data': 'Active'},
                                    },
                                    'leading': {
                                      'type': 'Icon',
                                      'props': {'icon': 'person'},
                                    },
                                    'trailing': {
                                      'type': 'CupertinoListTileChevron',
                                      'props': {},
                                    },
                                    'backgroundColor': '#ffffff',
                                    'backgroundColorActivated': '#dddddd',
                                    'padding': {
                                      'left': 8,
                                      'top': 6,
                                      'right': 7,
                                      'bottom': 5,
                                    },
                                    'leadingSize': -8,
                                    'leadingToTitle': 9,
                                    'onTap': {
                                      'type': 'Action',
                                      'props': {'name': 'tileTapped'},
                                    },
                                  },
                                },
                              ],
                            },
                          },
                          {
                            'type': 'CupertinoFormSection',
                            'props': {
                              'insetGrouped': true,
                              'header': {
                                'type': 'Text',
                                'props': {'data': 'Profile'},
                              },
                              'footer': {
                                'type': 'Text',
                                'props': {'data': 'Profile footer'},
                              },
                              'margin': {'horizontal': 12, 'vertical': 6},
                              'backgroundColor': '#f0f0f0',
                              'decoration': {
                                'color': '#ffffff',
                                'borderRadius': 8,
                              },
                              'clipBehavior': 'hardEdge',
                              'children': [
                                {
                                  'type': 'CupertinoFormRow',
                                  'props': {
                                    'prefix': {
                                      'type': 'Text',
                                      'props': {'data': 'Newsletter'},
                                    },
                                    'helper': {
                                      'type': 'Text',
                                      'props': {'data': 'Weekly updates'},
                                    },
                                    'error': {
                                      'type': 'Text',
                                      'props': {'data': 'Required choice'},
                                    },
                                    'padding': {
                                      'left': 9,
                                      'top': 8,
                                      'right': 7,
                                      'bottom': 6,
                                    },
                                    'child': {
                                      'type': 'CupertinoCheckbox',
                                      'props': {
                                        'value': null,
                                        'tristate': true,
                                        'activeColor': '#006a6a',
                                        'fillColor': {
                                          'selected': '#006a6a',
                                          'default': '#ffffff',
                                        },
                                        'checkColor': '#ffffff',
                                        'focusColor': '#123456',
                                        'mouseCursor': 'click',
                                        'autofocus': true,
                                        'side': {
                                          'color': '#333333',
                                          'width': 2,
                                        },
                                        'shape': {
                                          'type': 'rounded',
                                          'borderRadius': 4,
                                        },
                                        'tapTargetSize': {
                                          'width': -8,
                                          'height': 32,
                                        },
                                        'semanticLabel': 'Newsletter checkbox',
                                        'onChanged': {
                                          'type': 'Action',
                                          'props': {
                                            'name': 'cupertinoCheckboxChanged',
                                          },
                                        },
                                      },
                                    },
                                  },
                                },
                                {
                                  'type': 'CupertinoFormRow',
                                  'props': {
                                    'prefix': {
                                      'type': 'Text',
                                      'props': {'data': 'Plan'},
                                    },
                                    'child': {
                                      'type': 'CupertinoRadio',
                                      'props': {
                                        'value': 'pro',
                                        'groupValue': 'basic',
                                        'toggleable': true,
                                        'activeColor': '#006a6a',
                                        'inactiveColor': '#ffffff',
                                        'fillColor': '#ffffff',
                                        'focusColor': '#123456',
                                        'mouseCursor': 'click',
                                        'autofocus': true,
                                        'useCheckmarkStyle': true,
                                        'onChanged': {
                                          'type': 'Action',
                                          'props': {
                                            'name': 'cupertinoRadioChanged',
                                          },
                                        },
                                      },
                                    },
                                  },
                                },
                                {
                                  'type': 'CupertinoTextFormFieldRow',
                                  'props': {
                                    'initialValue': 'bad',
                                    'prefix': {
                                      'type': 'Text',
                                      'props': {'data': 'Email'},
                                    },
                                    'padding': {
                                      'horizontal': 10,
                                      'vertical': 7,
                                    },
                                    'placeholder': 'Email address',
                                    'placeholderStyle': {'color': '#333333'},
                                    'backgroundColor': '#ffffff',
                                    'borderRadius': 9,
                                    'keyboardType': 'email',
                                    'textCapitalization': 'words',
                                    'textInputAction': 'done',
                                    'style': {'fontSize': 16},
                                    'strutStyle': {'fontSize': 15},
                                    'textAlign': 'right',
                                    'textDirection': 'ltr',
                                    'showCursor': true,
                                    'autocorrect': false,
                                    'enableSuggestions': false,
                                    'minLines': 3,
                                    'maxLines': 2,
                                    'maxLength': 20,
                                    'cursorWidth': -3,
                                    'cursorHeight': -4,
                                    'cursorColor': '#ff0000',
                                    'keyboardAppearance': 'dark',
                                    'scrollPadding': {'all': 14},
                                    'enableInteractiveSelection': false,
                                    'selectionControls': 'cupertino',
                                    'scrollPhysics': 'never',
                                    'autovalidateMode': 'always',
                                    'contextMenu': false,
                                    'selectionHeightStyle': 'top',
                                    'selectionWidthStyle': 'max',
                                    'restorationId': 'cupertino-form-email',
                                    'validation': [
                                      {
                                        'type': 'required',
                                        'message': 'Email required',
                                      },
                                      {
                                        'type': 'email',
                                        'message': 'Email invalid',
                                      },
                                    ],
                                    'onChanged': {
                                      'type': 'Action',
                                      'props': {
                                        'name': 'cupertinoEmailChanged',
                                      },
                                    },
                                    'onTap': {
                                      'type': 'Action',
                                      'props': {'name': 'cupertinoEmailTap'},
                                    },
                                    'onEditingComplete': {
                                      'type': 'Action',
                                      'props': {
                                        'name': 'cupertinoEmailComplete',
                                      },
                                    },
                                    'onSubmitted': {
                                      'type': 'Action',
                                      'props': {
                                        'name': 'cupertinoEmailSubmitted',
                                      },
                                    },
                                    'onSaved': {
                                      'type': 'Action',
                                      'props': {'name': 'cupertinoEmailSaved'},
                                    },
                                  },
                                },
                              ],
                            },
                          },
                          {
                            'type': 'CupertinoScrollbar',
                            'props': {
                              'thumbVisibility': true,
                              'thickness': 4,
                              'thicknessWhileDragging': 9,
                              'radius': 2,
                              'radiusWhileDragging': 5,
                              'scrollbarOrientation': 'right',
                              'mainAxisMargin': -1,
                              'child': {
                                'type': 'SizedBox',
                                'props': {
                                  'height': 96,
                                  'child': {
                                    'type': 'ListView',
                                    'props': {
                                      'children': [
                                        {
                                          'type': 'Text',
                                          'props': {'data': 'Scrollable row'},
                                        },
                                      ],
                                    },
                                  },
                                },
                              },
                            },
                          },
                          {
                            'type': 'CupertinoAlertDialog',
                            'props': {
                              'insetAnimationDuration': 150,
                              'insetAnimationCurve': 'easeInOut',
                              'title': {
                                'type': 'Text',
                                'props': {'data': 'Alert'},
                              },
                              'content': {
                                'type': 'Text',
                                'props': {'data': 'Confirm action'},
                              },
                              'actions': [
                                {
                                  'type': 'CupertinoDialogAction',
                                  'props': {
                                    'isDefaultAction': true,
                                    'textStyle': {'color': '#006a6a'},
                                    'mouseCursor': 'click',
                                    'child': {
                                      'type': 'Text',
                                      'props': {'data': 'OK'},
                                    },
                                    'onPressed': {
                                      'type': 'Action',
                                      'props': {'name': 'alertOk'},
                                    },
                                  },
                                },
                              ],
                            },
                          },
                          {
                            'type': 'CupertinoActionSheet',
                            'props': {
                              'title': {
                                'type': 'Text',
                                'props': {'data': 'Action sheet'},
                              },
                              'message': {
                                'type': 'Text',
                                'props': {'data': 'Choose carefully'},
                              },
                              'actions': [
                                {
                                  'type': 'CupertinoActionSheetAction',
                                  'props': {
                                    'isDefaultAction': true,
                                    'isDestructiveAction': true,
                                    'mouseCursor': 'click',
                                    'focusColor': '#123456',
                                    'child': {
                                      'type': 'Text',
                                      'props': {'data': 'Delete'},
                                    },
                                    'onPressed': {
                                      'type': 'Action',
                                      'props': {'name': 'deleteAction'},
                                    },
                                  },
                                },
                              ],
                              'cancelButton': {
                                'type': 'CupertinoActionSheetAction',
                                'props': {
                                  'child': {
                                    'type': 'Text',
                                    'props': {'data': 'Cancel'},
                                  },
                                },
                              },
                            },
                          },
                          {
                            'type': 'CupertinoTabBar',
                            'props': {
                              'currentIndex': 99,
                              'backgroundColor': '#eeeeee',
                              'activeColor': '#006a6a',
                              'inactiveColor': '#999999',
                              'iconSize': -4,
                              'height': -8,
                              'border': false,
                              'onTap': {
                                'type': 'Action',
                                'props': {'name': 'tabTapped'},
                              },
                              'items': [
                                {'icon': 'home', 'label': 'Home'},
                                {'icon': 'search', 'label': 'Browse'},
                              ],
                            },
                          },
                          {
                            'type': 'CupertinoSwitch',
                            'props': {
                              'value': true,
                              'activeTrackColor': '#006a6a',
                              'inactiveTrackColor': '#eeeeee',
                              'thumbColor': '#ffffff',
                              'inactiveThumbColor': '#999999',
                              'applyTheme': false,
                              'focusColor': '#123456',
                              'onLabelColor': '#00ff00',
                              'offLabelColor': '#ff0000',
                              'trackOutlineColor': {
                                'selected': '#111111',
                                'default': '#222222',
                              },
                              'trackOutlineWidth': {
                                'selected': 3,
                                'default': 1,
                              },
                              'thumbIcon': {
                                'selected': 'check',
                                'default': 'close',
                              },
                              'mouseCursor': {
                                'disabled': 'forbidden',
                                'default': 'click',
                              },
                              'onFocusChange': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoSwitchFocus'},
                              },
                              'autofocus': true,
                              'dragStartBehavior': 'down',
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoSwitchChanged'},
                              },
                            },
                          },
                          {
                            'type': 'CupertinoSlider',
                            'props': {
                              'value': 8,
                              'min': 10,
                              'max': 2,
                              'divisions': -4,
                              'activeColor': '#006a6a',
                              'thumbColor': '#ffffff',
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoSliderChanged'},
                              },
                              'onChangeStart': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoSliderStart'},
                              },
                              'onChangeEnd': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoSliderEnd'},
                              },
                            },
                          },
                          {
                            'type': 'CupertinoActivityIndicator',
                            'props': {
                              'radius': -5,
                              'color': '#006a6a',
                              'animating': false,
                            },
                          },
                          {
                            'type': 'CupertinoActivityIndicator',
                            'props': {
                              'partiallyRevealed': true,
                              'progress': 1.4,
                              'radius': 6,
                              'color': '#ff0000',
                            },
                          },
                          {
                            'type': 'CupertinoButton',
                            'props': {
                              'variant': 'tinted',
                              'sizeStyle': 'small',
                              'padding': {'horizontal': 10, 'vertical': 6},
                              'color': '#eeeeee',
                              'foregroundColor': '#111111',
                              'disabledColor': '#cccccc',
                              'minimumSize': {'width': -4, 'height': 30},
                              'pressedOpacity': 1.4,
                              'borderRadius': 12,
                              'alignment': 'centerRight',
                              'focusColor': '#123456',
                              'onFocusChange': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoButtonFocus'},
                              },
                              'autofocus': true,
                              'mouseCursor': 'click',
                              'onPressed': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoButtonPressed'},
                              },
                              'onLongPress': {
                                'type': 'Action',
                                'props': {'name': 'cupertinoButtonLongPress'},
                              },
                              'child': {
                                'type': 'Text',
                                'props': {'data': 'Continue'},
                              },
                            },
                          },
                        ],
                      },
                    },
                  },
                },
              },
            },
          },
        }),
      ),
    );

    expect(find.text('iOS'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings footer'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Profile footer'), findsOneWidget);
    expect(find.text('Alert'), findsOneWidget);
    expect(find.text('Action sheet'), findsOneWidget);
    expect(find.text('Choose carefully'), findsOneWidget);

    final cupertinoApp = tester.widget<cupertino.CupertinoApp>(
      find.byType(cupertino.CupertinoApp),
    );
    expect(cupertinoApp.title, 'Cupertino Suite');
    expect(cupertinoApp.debugShowCheckedModeBanner, isTrue);
    expect(cupertinoApp.theme?.primaryColor, const Color(0xff006a6a));

    final pageScaffold = tester.widget<cupertino.CupertinoPageScaffold>(
      find.byType(cupertino.CupertinoPageScaffold),
    );
    expect(pageScaffold.backgroundColor, const Color(0xfff7f7f7));
    expect(pageScaffold.resizeToAvoidBottomInset, isFalse);

    final navigationBar = tester.widget<cupertino.CupertinoNavigationBar>(
      find.byType(cupertino.CupertinoNavigationBar),
    );
    expect(navigationBar.automaticallyImplyLeading, isFalse);
    expect(navigationBar.automaticallyImplyMiddle, isFalse);
    expect(navigationBar.previousPageTitle, 'Back');
    expect(navigationBar.backgroundColor, const Color(0xffeeeeee));
    expect(navigationBar.automaticBackgroundVisibility, isFalse);
    expect(navigationBar.enableBackgroundFilterBlur, isFalse);
    expect(navigationBar.brightness, Brightness.dark);
    expect(
      navigationBar.padding,
      const EdgeInsetsDirectional.only(start: 12, end: 14),
    );
    expect(navigationBar.transitionBetweenRoutes, isFalse);
    expect(navigationBar.heroTag, 'cupertino-nav');
    expect(navigationBar.border?.bottom.color, const Color(0xff00ff00));
    expect(navigationBar.border?.bottom.width, 2);
    expect(navigationBar.bottom, isA<PreferredSize>());

    final search = tester.widget<cupertino.CupertinoSearchTextField>(
      find.byType(cupertino.CupertinoSearchTextField),
    );
    expect(search.placeholder, 'Search iOS');
    expect(search.placeholderStyle?.color, const Color(0xff123456));
    expect(search.backgroundColor, const Color(0xffeeeeee));
    expect(search.borderRadius, BorderRadius.circular(10));
    expect(search.keyboardType, TextInputType.emailAddress);
    expect(
      search.padding,
      const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    );
    expect(search.itemColor, const Color(0xff006a6a));
    expect(search.itemSize, 18);
    expect(search.prefixInsets, const EdgeInsets.only(left: 4, right: 5));
    final searchPrefixIcon = search.prefixIcon as Icon;
    expect(searchPrefixIcon.size, 17);
    expect(searchPrefixIcon.color, const Color(0xff111111));
    expect(search.suffixInsets, const EdgeInsets.only(left: 6, right: 7));
    expect(search.suffixMode, cupertino.OverlayVisibilityMode.always);
    expect(search.restorationId, 'cupertino-search');
    expect(search.enableIMEPersonalizedLearning, isFalse);
    expect(search.autofocus, isTrue);
    expect(search.autocorrect, isFalse);
    expect(search.enabled, isTrue);
    expect(search.cursorWidth, 2);
    expect(search.cursorHeight, isNull);
    expect(search.cursorRadius, const Radius.elliptical(3, 0));
    expect(search.cursorOpacityAnimates, isFalse);
    expect(search.cursorColor, const Color(0xffff0000));

    final accountField = tester.widget<cupertino.CupertinoTextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoTextField &&
            widget.placeholder == 'Account',
      ),
    );
    expect(accountField.placeholderStyle?.color, const Color(0xff333333));
    expect(accountField.decoration?.color, const Color(0xffffffff));
    expect(accountField.decoration?.borderRadius, BorderRadius.circular(8));
    expect(accountField.padding, const EdgeInsets.all(11));
    expect(accountField.prefix, isA<Icon>());
    expect(accountField.prefixMode, cupertino.OverlayVisibilityMode.always);
    expect(accountField.suffix, isA<Icon>());
    expect(accountField.suffixMode, cupertino.OverlayVisibilityMode.editing);
    expect(accountField.clearButtonMode, cupertino.OverlayVisibilityMode.never);
    expect(accountField.clearButtonSemanticLabel, 'Clear account');
    expect(accountField.keyboardType, TextInputType.emailAddress);
    expect(accountField.textInputAction, TextInputAction.next);
    expect(accountField.textCapitalization, TextCapitalization.words);
    expect(accountField.style?.fontSize, 15);
    expect(accountField.strutStyle?.fontSize, 14);
    expect(accountField.textAlign, TextAlign.center);
    expect(accountField.textDirection, TextDirection.rtl);
    expect(accountField.showCursor, isTrue);
    expect(accountField.obscuringCharacter, '•');
    expect(accountField.obscureText, isTrue);
    expect(accountField.autocorrect, isFalse);
    expect(accountField.enableSuggestions, isFalse);
    expect(accountField.minLines, isNull);
    expect(accountField.maxLines, 1);
    expect(accountField.maxLength, isNull);
    expect(accountField.cursorWidth, 2);
    expect(accountField.cursorHeight, isNull);
    expect(accountField.cursorRadius, const Radius.elliptical(4, 0));
    expect(accountField.cursorOpacityAnimates, isFalse);
    expect(accountField.cursorColor, const Color(0xff00ff00));
    expect(
      accountField.selectionHeightStyle,
      ui.BoxHeightStyle.includeLineSpacingTop,
    );
    expect(accountField.selectionWidthStyle, ui.BoxWidthStyle.max);
    expect(accountField.scrollPadding, const EdgeInsets.all(12));
    expect(accountField.dragStartBehavior, DragStartBehavior.down);
    expect(accountField.enableInteractiveSelection, isFalse);
    expect(accountField.selectAllOnFocus, isTrue);
    expect(
      accountField.selectionControls,
      same(cupertino.cupertinoDesktopTextSelectionHandleControls),
    );
    expect(accountField.scrollPhysics, isA<NeverScrollableScrollPhysics>());
    expect(accountField.clipBehavior, Clip.none);
    expect(accountField.restorationId, 'cupertino-account');
    expect(accountField.stylusHandwritingEnabled, isFalse);
    expect(accountField.enableIMEPersonalizedLearning, isFalse);
    expect(accountField.enableInlinePrediction, isTrue);
    expect(accountField.contextMenuBuilder, isNull);
    expect(
      accountField.magnifierConfiguration,
      TextMagnifierConfiguration.disabled,
    );

    final segmented = tester
        .widget<cupertino.CupertinoSegmentedControl<Object>>(
          find.byType(cupertino.CupertinoSegmentedControl<Object>),
        );
    expect(segmented.groupValue, 'one');
    expect(segmented.unselectedColor, const Color(0xffffffff));
    expect(segmented.selectedColor, const Color(0xff006a6a));
    expect(segmented.borderColor, const Color(0xff333333));
    expect(segmented.pressedColor, const Color(0xffdddddd));
    expect(segmented.disabledColor, const Color(0xffaaaaaa));
    expect(segmented.disabledTextColor, const Color(0xff999999));
    expect(
      segmented.padding,
      const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    );
    expect(segmented.disabledChildren, contains('missing'));

    final slidingSegmented = tester
        .widget<cupertino.CupertinoSlidingSegmentedControl<Object>>(
          find.byType(cupertino.CupertinoSlidingSegmentedControl<Object>),
        );
    expect(slidingSegmented.groupValue, 'alpha');
    expect(slidingSegmented.thumbColor, const Color(0xffffffff));
    expect(slidingSegmented.backgroundColor, const Color(0xffeeeeee));
    expect(
      slidingSegmented.padding,
      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
    expect(slidingSegmented.proportionalWidth, isTrue);
    expect(slidingSegmented.isMomentary, isTrue);
    expect(slidingSegmented.disabledChildren, contains('gamma'));

    final listSection = tester.widget<cupertino.CupertinoListSection>(
      find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoListSection &&
            widget.separatorColor == const Color(0xff123456),
      ),
    );
    expect(
      listSection.margin,
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
    expect(listSection.backgroundColor, const Color(0xffeeeeee));
    expect(listSection.decoration?.color, const Color(0xffffffff));
    expect(listSection.decoration?.borderRadius, BorderRadius.circular(6));
    expect(listSection.clipBehavior, Clip.hardEdge);
    expect(listSection.dividerMargin, 0);
    expect(listSection.additionalDividerMargin, 5);
    expect(listSection.topMargin, 6);
    expect(listSection.separatorColor, const Color(0xff123456));

    final listTile = tester.widget<cupertino.CupertinoListTile>(
      find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Account',
      ),
    );
    expect(listTile.subtitle, isA<Text>());
    expect(listTile.additionalInfo, isA<Text>());
    expect(listTile.leading, isA<Icon>());
    expect(listTile.trailing, isA<cupertino.CupertinoListTileChevron>());
    expect(listTile.backgroundColor, const Color(0xffffffff));
    expect(listTile.backgroundColorActivated, const Color(0xffdddddd));
    expect(listTile.padding, const EdgeInsets.fromLTRB(8, 6, 7, 5));
    expect(listTile.leadingSize, 30);
    expect(listTile.leadingToTitle, 9);

    final formSection = tester.widget<cupertino.CupertinoFormSection>(
      find.byType(cupertino.CupertinoFormSection),
    );
    expect(
      formSection.margin,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
    expect(formSection.backgroundColor, const Color(0xfff0f0f0));
    expect(formSection.decoration?.color, const Color(0xffffffff));
    expect(formSection.decoration?.borderRadius, BorderRadius.circular(8));
    expect(formSection.clipBehavior, Clip.hardEdge);
    expect(formSection.children, hasLength(3));

    final checkboxFormRow = tester.widget<cupertino.CupertinoFormRow>(
      find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoFormRow &&
            widget.child is cupertino.CupertinoCheckbox,
      ),
    );
    expect((checkboxFormRow.prefix as Text).data, 'Newsletter');
    expect(checkboxFormRow.padding, const EdgeInsets.fromLTRB(9, 8, 7, 6));
    expect((checkboxFormRow.helper as Text).data, 'Weekly updates');
    expect((checkboxFormRow.error as Text).data, 'Required choice');

    final cupertinoCheckbox = tester.widget<cupertino.CupertinoCheckbox>(
      find.byType(cupertino.CupertinoCheckbox),
    );
    expect(cupertinoCheckbox.value, isNull);
    expect(cupertinoCheckbox.tristate, isTrue);
    expect(cupertinoCheckbox.activeColor, const Color(0xff006a6a));
    expect(
      cupertinoCheckbox.fillColor?.resolve({WidgetState.selected}),
      const Color(0xff006a6a),
    );
    expect(cupertinoCheckbox.checkColor, const Color(0xffffffff));
    expect(cupertinoCheckbox.focusColor, const Color(0xff123456));
    expect(cupertinoCheckbox.mouseCursor, SystemMouseCursors.click);
    expect(cupertinoCheckbox.autofocus, isTrue);
    expect(cupertinoCheckbox.side?.color, const Color(0xff333333));
    expect(cupertinoCheckbox.side?.width, 2);
    expect(cupertinoCheckbox.shape, isA<RoundedRectangleBorder>());
    expect(cupertinoCheckbox.tapTargetSize, const Size(0, 32));
    expect(cupertinoCheckbox.semanticLabel, 'Newsletter checkbox');

    final cupertinoRadio = tester.widget<cupertino.CupertinoRadio<Object>>(
      find.byWidgetPredicate(
        (widget) => widget is cupertino.CupertinoRadio<Object>,
      ),
    );
    expect(cupertinoRadio.value, 'pro');
    expect(cupertinoRadio.toggleable, isTrue);
    expect(cupertinoRadio.activeColor, const Color(0xff006a6a));
    expect(cupertinoRadio.inactiveColor, const Color(0xffffffff));
    expect(cupertinoRadio.fillColor, const Color(0xffffffff));
    expect(cupertinoRadio.focusColor, const Color(0xff123456));
    expect(cupertinoRadio.mouseCursor, SystemMouseCursors.click);
    expect(cupertinoRadio.autofocus, isTrue);
    expect(cupertinoRadio.useCheckmarkStyle, isTrue);
    expect(cupertinoRadio.enabled, isTrue);
    final cupertinoRadioGroup = tester.widget<RadioGroup<Object>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RadioGroup<Object> &&
            widget.child is cupertino.CupertinoRadio<Object>,
      ),
    );
    expect(cupertinoRadioGroup.groupValue, 'basic');

    final textFormRow = tester.widget<cupertino.CupertinoTextFormFieldRow>(
      find.byType(cupertino.CupertinoTextFormFieldRow),
    );
    expect(textFormRow.initialValue, 'bad');
    expect((textFormRow.prefix as Text).data, 'Email');
    expect(
      textFormRow.padding,
      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    );
    expect(textFormRow.autovalidateMode, AutovalidateMode.always);
    expect(textFormRow.restorationId, 'cupertino-form-email');
    expect(textFormRow.validator?.call(''), 'Email required');
    expect(textFormRow.validator?.call('bad'), 'Email invalid');
    expect(textFormRow.validator?.call('person@example.com'), isNull);

    final emailField = tester.widget<cupertino.CupertinoTextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoTextField &&
            widget.placeholder == 'Email address',
      ),
    );
    expect(emailField.placeholderStyle?.color, const Color(0xff333333));
    expect(emailField.decoration?.color, const Color(0xffffffff));
    expect(emailField.decoration?.borderRadius, BorderRadius.circular(9));
    expect(emailField.keyboardType, TextInputType.emailAddress);
    expect(emailField.textCapitalization, TextCapitalization.words);
    expect(emailField.textInputAction, TextInputAction.done);
    expect(emailField.style?.fontSize, 16);
    expect(emailField.strutStyle?.fontSize, 15);
    expect(emailField.textAlign, TextAlign.right);
    expect(emailField.textDirection, TextDirection.ltr);
    expect(emailField.showCursor, isTrue);
    expect(emailField.autocorrect, isFalse);
    expect(emailField.enableSuggestions, isFalse);
    expect(emailField.minLines, 3);
    expect(emailField.maxLines, 3);
    expect(emailField.maxLength, 20);
    expect(emailField.cursorWidth, 2);
    expect(emailField.cursorHeight, isNull);
    expect(emailField.cursorColor, const Color(0xffff0000));
    expect(emailField.keyboardAppearance, Brightness.dark);
    expect(emailField.scrollPadding, const EdgeInsets.all(14));
    expect(emailField.enableInteractiveSelection, isFalse);
    expect(
      emailField.selectionControls,
      same(cupertino.cupertinoTextSelectionHandleControls),
    );
    expect(emailField.scrollPhysics, isA<NeverScrollableScrollPhysics>());
    expect(emailField.contextMenuBuilder, isNull);
    expect(
      emailField.selectionHeightStyle,
      ui.BoxHeightStyle.includeLineSpacingTop,
    );
    expect(emailField.selectionWidthStyle, ui.BoxWidthStyle.max);

    final cupertinoScrollbar = tester
        .widgetList<cupertino.CupertinoScrollbar>(
          find.byWidgetPredicate(
            (widget) =>
                widget is cupertino.CupertinoScrollbar && widget.thickness == 4,
          ),
        )
        .single;
    expect(cupertinoScrollbar.thumbVisibility, isTrue);
    expect(cupertinoScrollbar.thicknessWhileDragging, 9);
    expect(cupertinoScrollbar.radius, const Radius.circular(2));
    expect(cupertinoScrollbar.radiusWhileDragging, const Radius.circular(5));
    expect(cupertinoScrollbar.scrollbarOrientation, ScrollbarOrientation.right);
    expect(cupertinoScrollbar.mainAxisMargin, 0);

    final alertDialog = tester.widget<cupertino.CupertinoAlertDialog>(
      find.byType(cupertino.CupertinoAlertDialog),
    );
    expect(
      alertDialog.insetAnimationDuration,
      const Duration(milliseconds: 150),
    );
    expect(alertDialog.insetAnimationCurve, Curves.easeInOut);

    final dialogAction = tester.widget<cupertino.CupertinoDialogAction>(
      find.widgetWithText(cupertino.CupertinoDialogAction, 'OK'),
    );
    expect(dialogAction.isDefaultAction, isTrue);
    expect(dialogAction.textStyle?.color, const Color(0xff006a6a));
    expect(dialogAction.mouseCursor, SystemMouseCursors.click);

    final actionSheetAction = tester
        .widget<cupertino.CupertinoActionSheetAction>(
          find.widgetWithText(cupertino.CupertinoActionSheetAction, 'Delete'),
        );
    expect(actionSheetAction.isDefaultAction, isTrue);
    expect(actionSheetAction.isDestructiveAction, isTrue);
    expect(actionSheetAction.mouseCursor, SystemMouseCursors.click);
    expect(actionSheetAction.focusColor, const Color(0xff123456));

    final tabBar = tester.widget<cupertino.CupertinoTabBar>(
      find.byType(cupertino.CupertinoTabBar),
    );
    expect(tabBar.currentIndex, 1);
    expect(tabBar.backgroundColor, const Color(0xffeeeeee));
    expect(tabBar.activeColor, const Color(0xff006a6a));
    expect(tabBar.inactiveColor, const Color(0xff999999));
    expect(tabBar.iconSize, 30);
    expect(tabBar.height, 50);
    expect(tabBar.border, isNull);

    final continueButton = tester.widget<cupertino.CupertinoButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Continue',
      ),
    );
    expect(continueButton.sizeStyle, cupertino.CupertinoButtonSize.small);
    expect(
      continueButton.padding,
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
    expect(continueButton.color, const Color(0xffeeeeee));
    expect(continueButton.foregroundColor, const Color(0xff111111));
    expect(continueButton.disabledColor, const Color(0xffcccccc));
    expect(continueButton.minimumSize, const Size(0, 30));
    expect(continueButton.pressedOpacity, 1);
    expect(continueButton.borderRadius, BorderRadius.circular(12));
    expect(continueButton.alignment, Alignment.centerRight);
    expect(continueButton.focusColor, const Color(0xff123456));
    expect(continueButton.autofocus, isTrue);
    expect(continueButton.mouseCursor, SystemMouseCursors.click);

    final cupertinoSwitch = tester.widget<cupertino.CupertinoSwitch>(
      find.byType(cupertino.CupertinoSwitch),
    );
    expect(cupertinoSwitch.value, isTrue);
    expect(cupertinoSwitch.activeTrackColor, const Color(0xff006a6a));
    expect(cupertinoSwitch.inactiveTrackColor, const Color(0xffeeeeee));
    expect(cupertinoSwitch.thumbColor, const Color(0xffffffff));
    expect(cupertinoSwitch.inactiveThumbColor, const Color(0xff999999));
    expect(cupertinoSwitch.applyTheme, isFalse);
    expect(cupertinoSwitch.focusColor, const Color(0xff123456));
    expect(cupertinoSwitch.onLabelColor, const Color(0xff00ff00));
    expect(cupertinoSwitch.offLabelColor, const Color(0xffff0000));
    expect(
      cupertinoSwitch.trackOutlineColor?.resolve({WidgetState.selected}),
      const Color(0xff111111),
    );
    expect(
      cupertinoSwitch.trackOutlineWidth?.resolve({WidgetState.selected}),
      3,
    );
    final selectedThumbIcon = cupertinoSwitch.thumbIcon?.resolve({
      WidgetState.selected,
    });
    expect(selectedThumbIcon?.icon, Icons.check);
    expect(
      cupertinoSwitch.mouseCursor?.resolve({WidgetState.disabled}),
      SystemMouseCursors.forbidden,
    );
    expect(cupertinoSwitch.autofocus, isTrue);
    expect(cupertinoSwitch.dragStartBehavior, DragStartBehavior.down);

    final cupertinoSlider = tester.widget<cupertino.CupertinoSlider>(
      find.byType(cupertino.CupertinoSlider),
    );
    expect(cupertinoSlider.value, 8);
    expect(cupertinoSlider.min, 2);
    expect(cupertinoSlider.max, 10);
    expect(cupertinoSlider.divisions, isNull);
    expect(cupertinoSlider.activeColor, const Color(0xff006a6a));
    expect(cupertinoSlider.thumbColor, const Color(0xffffffff));

    final activityIndicators = tester
        .widgetList<cupertino.CupertinoActivityIndicator>(
          find.byType(cupertino.CupertinoActivityIndicator),
        )
        .toList();
    expect(activityIndicators, hasLength(2));
    expect(activityIndicators[0].radius, 10);
    expect(activityIndicators[0].animating, isFalse);
    expect(activityIndicators[0].progress, 1);
    expect(activityIndicators[0].color, const Color(0xff006a6a));
    expect(activityIndicators[1].radius, 6);
    expect(activityIndicators[1].animating, isFalse);
    expect(activityIndicators[1].progress, 1);
    expect(activityIndicators[1].color, const Color(0xffff0000));

    actions.clear();
    cupertinoCheckbox.onChanged!(false);
    cupertinoRadioGroup.onChanged('pro');
    emailField.onTap!();
    emailField.onChanged!('person@example.com');
    emailField.onEditingComplete!();
    emailField.onSubmitted!('submit@example.com');
    textFormRow.onSaved!('saved@example.com');
    continueButton.onFocusChange!(true);
    continueButton.onLongPress!();
    continueButton.onPressed!();
    cupertinoSwitch.onFocusChange!(false);
    cupertinoSwitch.onChanged!(false);
    cupertinoSlider.onChangeStart!(2);
    cupertinoSlider.onChanged!(5.5);
    cupertinoSlider.onChangeEnd!(10);
    expect(actions.map((action) => action.name), [
      'cupertinoCheckboxChanged',
      'cupertinoRadioChanged',
      'cupertinoEmailTap',
      'cupertinoEmailChanged',
      'cupertinoEmailComplete',
      'cupertinoEmailSubmitted',
      'cupertinoEmailSaved',
      'cupertinoButtonFocus',
      'cupertinoButtonLongPress',
      'cupertinoButtonPressed',
      'cupertinoSwitchFocus',
      'cupertinoSwitchChanged',
      'cupertinoSliderStart',
      'cupertinoSliderChanged',
      'cupertinoSliderEnd',
    ]);
    expect(actions[0].payload, isFalse);
    expect(actions[1].payload, 'pro');
    expect(actions[3].payload, 'person@example.com');
    expect(actions[5].payload, 'submit@example.com');
    expect(actions[6].payload, 'saved@example.com');
    expect(actions[7].payload, isTrue);
    expect(actions[11].payload, isFalse);
    expect(actions[13].payload, 5.5);
    actions.clear();

    search.onTap!();
    search.onSuffixTap!();
    search.onSubmitted!('done');
    accountField.onTap!();
    accountField.onTapOutside!(const PointerDownEvent(position: Offset(8, 9)));
    accountField.onTapUpOutside!(
      const PointerDownEvent(position: Offset(10, 11)),
    );
    accountField.onEditingComplete!();
    accountField.onSubmitted!('sent');
    expect(actions.map((action) => action.name).take(8), [
      'searchTap',
      'searchSuffix',
      'searchSubmitted',
      'accountTap',
      'accountTapOutside',
      'accountTapUpOutside',
      'accountComplete',
      'accountSubmitted',
    ]);
    expect(actions[2].payload, 'done');
    expect(actions[4].payload, containsPair('x', 8.0));
    expect(actions[7].payload, 'sent');
    actions.clear();

    await tester.enterText(
      find.byType(cupertino.CupertinoSearchTextField),
      'query',
    );
    await tester.pump();
    expect(actions.last.name, 'searchChanged');
    expect(actions.last.payload, 'query');

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(actions.last.name, 'segmentChanged');
    expect(actions.last.payload, 'two');

    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(actions.last.name, 'slidingChanged');
    expect(actions.last.payload, 'beta');

    await tester.tap(find.text('Account').last);
    await tester.pump();
    expect(actions.last.name, 'tileTapped');

    await tester.ensureVisible(find.text('OK'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(actions.last.name, 'alertOk');

    await tester.ensureVisible(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(actions.last.name, 'deleteAction');

    await tester.ensureVisible(find.text('Browse'));
    await tester.pump();
    await tester.tap(find.text('Browse'));
    await tester.pump();
    expect(actions.last.name, 'tabTapped');
    expect(actions.last.payload, 1);
  });

  testWidgets('renders Cupertino picker family', (tester) async {
    final actions = <AppletAction>[];
    final renderer = AppletRenderer(
      dispatchAction: (action) => actions.add(action),
    );

    await tester.pumpWidget(
      Builder(
        builder: (context) => renderer.buildWidget(context, {
          'type': 'CupertinoApp',
          'props': {
            'home': {
              'type': 'CupertinoPageScaffold',
              'props': {
                'child': {
                  'type': 'ListView',
                  'props': {
                    'children': [
                      {
                        'type': 'SizedBox',
                        'props': {
                          'height': 216,
                          'child': {
                            'type': 'CupertinoPicker',
                            'props': {
                              'items': ['One', 'Two', 'Three'],
                              'itemExtent': 36,
                              'initialItem': -4,
                              'diameterRatio': -2,
                              'backgroundColor': '#eeeeee',
                              'offAxisFraction': 0.25,
                              'useMagnifier': true,
                              'magnification': 1.2,
                              'squeeze': 1.1,
                              'looping': true,
                              'changeReportingBehavior': 'onScrollEnd',
                              'selectionOverlay': {
                                'type':
                                    'CupertinoPickerDefaultSelectionOverlay',
                                'props': {
                                  'backgroundColor': '#123456',
                                  'capStartEdge': false,
                                  'capEndEdge': true,
                                },
                              },
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'pickerChanged'},
                              },
                            },
                          },
                        },
                      },
                      {
                        'type': 'SizedBox',
                        'props': {
                          'height': 216,
                          'child': {
                            'type': 'CupertinoDatePicker',
                            'props': {
                              'mode': 'dateAndTime',
                              'initialDateTime': {
                                'year': 2026,
                                'month': 6,
                                'day': 30,
                                'hour': 10,
                                'minute': 21,
                                'second': 45,
                              },
                              'minimumDate': '2026-01-01T00:00:00',
                              'maximumDate': '2026-12-31T23:59:00',
                              'minimumYear': -10,
                              'maximumYear': 2027,
                              'minuteInterval': 7,
                              'use24hFormat': true,
                              'dateOrder': 'ymd',
                              'backgroundColor': '#f5f5f5',
                              'showDayOfWeek': true,
                              'showTimeSeparator': true,
                              'itemExtent': -6,
                              'selectionOverlay': false,
                              'changeReportingBehavior': 'onScrollEnd',
                              'onDateTimeChanged': {
                                'type': 'Action',
                                'props': {'name': 'dateChanged'},
                              },
                            },
                          },
                        },
                      },
                      {
                        'type': 'SizedBox',
                        'props': {
                          'height': 216,
                          'child': {
                            'type': 'CupertinoTimerPicker',
                            'props': {
                              'mode': 'hm',
                              'initialTimerDuration': {
                                'hours': 1,
                                'minutes': 34,
                                'seconds': 44,
                              },
                              'minuteInterval': 7,
                              'secondInterval': 15,
                              'alignment': 'centerRight',
                              'backgroundColor': '#dddddd',
                              'itemExtent': 40,
                              'selectionOverlayBuilder': {
                                'type':
                                    'CupertinoPickerDefaultSelectionOverlay',
                                'props': {
                                  'backgroundColor': '#abcdef',
                                  'capStartEdge': false,
                                  'capEndEdge': false,
                                },
                              },
                              'changeReportingBehavior': 'onScrollEnd',
                              'onChanged': {
                                'type': 'Action',
                                'props': {'name': 'timerChanged'},
                              },
                            },
                          },
                        },
                      },
                    ],
                  },
                },
              },
            },
          },
        }),
      ),
    );

    expect(find.text('One'), findsWidgets);
    expect(find.text('Two'), findsWidgets);
    expect(find.text('Three'), findsWidgets);

    final picker = tester.widget<cupertino.CupertinoPicker>(
      find.byType(cupertino.CupertinoPicker).first,
    );
    expect(picker.itemExtent, 36);
    expect(picker.diameterRatio, 1.07);
    expect(picker.backgroundColor, const Color(0xffeeeeee));
    expect(picker.offAxisFraction, 0.25);
    expect(picker.useMagnifier, isTrue);
    expect(picker.magnification, 1.2);
    expect(picker.squeeze, 1.1);
    expect(picker.changeReportingBehavior, ChangeReportingBehavior.onScrollEnd);
    final pickerController =
        picker.scrollController as FixedExtentScrollController;
    expect(pickerController.initialItem, 0);
    final pickerOverlay =
        picker.selectionOverlay
            as cupertino.CupertinoPickerDefaultSelectionOverlay;
    expect(pickerOverlay.background, const Color(0xff123456));
    expect(pickerOverlay.capStartEdge, isFalse);
    expect(pickerOverlay.capEndEdge, isTrue);

    final datePicker = tester.widget<cupertino.CupertinoDatePicker>(
      find.byType(cupertino.CupertinoDatePicker),
    );
    expect(datePicker.mode, cupertino.CupertinoDatePickerMode.dateAndTime);
    expect(datePicker.initialDateTime, DateTime(2026, 6, 30, 10, 21));
    expect(datePicker.minimumDate, DateTime(2026));
    expect(datePicker.maximumDate, DateTime(2026, 12, 31, 23, 59));
    expect(datePicker.minimumYear, 1);
    expect(datePicker.maximumYear, 2027);
    expect(datePicker.minuteInterval, 1);
    expect(datePicker.use24hFormat, isTrue);
    expect(datePicker.dateOrder, cupertino.DatePickerDateOrder.ymd);
    expect(datePicker.backgroundColor, const Color(0xfff5f5f5));
    expect(datePicker.showDayOfWeek, isFalse);
    expect(datePicker.showTimeSeparator, isTrue);
    expect(datePicker.itemExtent, 32);
    expect(datePicker.selectionOverlayBuilder, isNotNull);
    expect(
      datePicker.changeReportingBehavior,
      ChangeReportingBehavior.onScrollEnd,
    );

    final timerPicker = tester.widget<cupertino.CupertinoTimerPicker>(
      find.byType(cupertino.CupertinoTimerPicker),
    );
    expect(timerPicker.mode, cupertino.CupertinoTimerPickerMode.hm);
    expect(
      timerPicker.initialTimerDuration,
      const Duration(hours: 1, minutes: 34, seconds: 30),
    );
    expect(timerPicker.minuteInterval, 1);
    expect(timerPicker.secondInterval, 15);
    expect(timerPicker.alignment, Alignment.centerRight);
    expect(timerPicker.backgroundColor, const Color(0xffdddddd));
    expect(timerPicker.itemExtent, 40);
    expect(timerPicker.selectionOverlayBuilder, isNotNull);
    expect(
      timerPicker.changeReportingBehavior,
      ChangeReportingBehavior.onScrollEnd,
    );

    picker.onSelectedItemChanged!(2);
    datePicker.onDateTimeChanged(DateTime(2026, 7, 1, 12, 30, 15, 250));
    timerPicker.onTimerDurationChanged(
      const Duration(hours: 2, minutes: 15, seconds: 30),
    );

    expect(actions.map((action) => action.name), [
      'pickerChanged',
      'dateChanged',
      'timerChanged',
    ]);
    expect(actions[0].payload, 2);
    expect(actions[1].payload, containsPair('iso', '2026-07-01T12:30:15.250'));
    expect(actions[1].payload, containsPair('date', '2026-07-01'));
    expect(actions[1].payload, containsPair('time', '12:30'));
    expect(actions[1].payload, containsPair('year', 2026));
    expect(actions[1].payload, containsPair('month', 7));
    expect(actions[1].payload, containsPair('day', 1));
    expect(actions[1].payload, containsPair('hour', 12));
    expect(actions[1].payload, containsPair('minute', 30));
    expect(actions[1].payload, containsPair('second', 15));
    expect(actions[1].payload, containsPair('millisecond', 250));
    expect(actions[2].payload, containsPair('hours', 2));
    expect(actions[2].payload, containsPair('minutes', 135));
    expect(actions[2].payload, containsPair('seconds', 8130));
    expect(actions[2].payload, containsPair('hour', 2));
    expect(actions[2].payload, containsPair('minute', 15));
    expect(actions[2].payload, containsPair('second', 30));
  });
}
