import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart'
    show
        DeviceGestureSettings,
        DragStartBehavior,
        kDefaultMouseScrollToScaleFactor;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        OverflowBoxFit,
        RenderProxyBox,
        ScrollCacheExtent,
        SelectedContent,
        SliverConstraints;
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'applet_core.dart';

typedef AppletWidgetFactory =
    Widget Function(AppletBuildContext context, Map<String, Object?> props);

class _AppletDefaultFabHeroTag {
  const _AppletDefaultFabHeroTag();

  @override
  String toString() => '<default Applet FloatingActionButton tag>';
}

const Object _defaultCupertinoNavBarHeroTag = Object();

const Border _defaultCupertinoNavBarBorder = Border(
  bottom: BorderSide(color: Color(0x4D000000), width: 0),
);

const Border _defaultCupertinoTabBarBorder = Border(
  top: BorderSide(color: Color(0x4D000000), width: 0),
);

class _AutocompleteOption {
  const _AutocompleteOption({
    required this.label,
    required this.value,
    required this.searchText,
  });

  final String label;
  final Object? value;
  final String searchText;
}

class _AppletCachedSliverChildDelegate extends SliverChildBuilderDelegate {
  _AppletCachedSliverChildDelegate({
    required NullableIndexedWidgetBuilder builder,
    required this.heights,
    required int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(
         builder,
         childCount: childCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       );

  final List<double?> heights;

  @override
  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    final knownExtent = heights.fold<double>(
      0,
      (sum, height) => sum + (height ?? 0),
    );
    if (knownExtent > 0) {
      return knownExtent;
    }
    return super.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }
}

class _AppletCacheHeight extends SingleChildRenderObjectWidget {
  const _AppletCacheHeight({
    required this.heights,
    required this.index,
    super.child,
  });

  final List<double?> heights;
  final int index;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAppletCacheHeight(heights: heights, index: index);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAppletCacheHeight renderObject,
  ) {
    renderObject
      ..heights = heights
      ..index = index;
  }
}

class _RenderAppletCacheHeight extends RenderProxyBox {
  _RenderAppletCacheHeight({required List<double?> heights, required int index})
    : _heights = heights,
      _index = index;

  List<double?> _heights;
  List<double?> get heights => _heights;
  set heights(List<double?> value) {
    if (identical(value, _heights)) {
      return;
    }
    _heights = value;
    markNeedsLayout();
  }

  int _index;
  int get index => _index;
  set index(int value) {
    if (value == _index) {
      return;
    }
    _index = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();
    if (_index >= 0 && _index < _heights.length) {
      _heights[_index] = size.height;
    }
  }
}

class _CupertinoNavigationBarCommon {
  const _CupertinoNavigationBarCommon({
    required this.leading,
    required this.trailing,
    required this.automaticallyImplyLeading,
    required this.automaticallyImplyMiddle,
    required this.previousPageTitle,
    required this.backgroundColor,
    required this.automaticBackgroundVisibility,
    required this.enableBackgroundFilterBlur,
    required this.brightness,
    required this.padding,
    required this.transitionBetweenRoutes,
    required this.heroTag,
    required this.bottom,
    required this.border,
  });

  final Widget? leading;
  final Widget? trailing;
  final bool automaticallyImplyLeading;
  final bool automaticallyImplyMiddle;
  final String? previousPageTitle;
  final Color? backgroundColor;
  final bool automaticBackgroundVisibility;
  final bool enableBackgroundFilterBlur;
  final Brightness? brightness;
  final EdgeInsetsDirectional? padding;
  final bool transitionBetweenRoutes;
  final Object? heroTag;
  final PreferredSizeWidget? bottom;
  final Border? border;
}

/// Context passed to custom widget factories.
class AppletBuildContext {
  const AppletBuildContext(this.context, this.renderer);

  final BuildContext context;
  final AppletRenderer renderer;

  Widget build(Object? spec) => renderer.buildWidget(context, spec);
  List<Widget> buildAll(Object? specs) => renderer.buildWidgets(context, specs);
}

class _AppletKeyboardListener extends StatefulWidget {
  const _AppletKeyboardListener({
    required this.child,
    this.autofocus = false,
    this.includeSemantics = true,
    this.onKeyEvent,
  });

  final Widget child;
  final bool autofocus;
  final bool includeSemantics;
  final ValueChanged<KeyEvent>? onKeyEvent;

  @override
  State<_AppletKeyboardListener> createState() =>
      _AppletKeyboardListenerState();
}

class _AppletKeyboardListenerState extends State<_AppletKeyboardListener> {
  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      includeSemantics: widget.includeSemantics,
      onKeyEvent: widget.onKeyEvent,
      child: widget.child,
    );
  }
}

class _AppletScrollbar extends StatefulWidget {
  const _AppletScrollbar({
    required this.child,
    this.thumbVisibility,
    this.trackVisibility,
    this.thickness,
    this.radius,
    this.interactive,
    this.scrollbarOrientation,
  });

  final Widget child;
  final bool? thumbVisibility;
  final bool? trackVisibility;
  final double? thickness;
  final Radius? radius;
  final bool? interactive;
  final ScrollbarOrientation? scrollbarOrientation;

  @override
  State<_AppletScrollbar> createState() => _AppletScrollbarState();
}

class _AppletScrollbarState extends State<_AppletScrollbar> {
  late final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _controller,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: widget.trackVisibility,
        thickness: widget.thickness,
        radius: widget.radius,
        interactive: widget.interactive,
        scrollbarOrientation: widget.scrollbarOrientation,
        child: widget.child,
      ),
    );
  }
}

class _AppletCupertinoScrollbar extends StatefulWidget {
  const _AppletCupertinoScrollbar({
    required this.child,
    this.thumbVisibility,
    this.thickness = cupertino.CupertinoScrollbar.defaultThickness,
    this.thicknessWhileDragging =
        cupertino.CupertinoScrollbar.defaultThicknessWhileDragging,
    this.radius = cupertino.CupertinoScrollbar.defaultRadius,
    this.radiusWhileDragging =
        cupertino.CupertinoScrollbar.defaultRadiusWhileDragging,
    this.scrollbarOrientation,
    this.mainAxisMargin = 3,
  });

  final Widget child;
  final bool? thumbVisibility;
  final double thickness;
  final double thicknessWhileDragging;
  final Radius radius;
  final Radius radiusWhileDragging;
  final ScrollbarOrientation? scrollbarOrientation;
  final double mainAxisMargin;

  @override
  State<_AppletCupertinoScrollbar> createState() =>
      _AppletCupertinoScrollbarState();
}

class _AppletCupertinoScrollbarState extends State<_AppletCupertinoScrollbar> {
  late final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _controller,
      child: cupertino.CupertinoScrollbar(
        controller: _controller,
        thumbVisibility: widget.thumbVisibility,
        thickness: widget.thickness,
        thicknessWhileDragging: widget.thicknessWhileDragging,
        radius: widget.radius,
        radiusWhileDragging: widget.radiusWhileDragging,
        scrollbarOrientation: widget.scrollbarOrientation,
        mainAxisMargin: widget.mainAxisMargin,
        child: widget.child,
      ),
    );
  }
}

class _AppletAdaptiveNavigationScaffold extends StatefulWidget {
  const _AppletAdaptiveNavigationScaffold({
    required this.body,
    required this.navigationRail,
    required this.navigationBar,
    this.extendedNavigationRail,
    this.appBar,
    this.railAppBar,
    this.floatingActionButton,
    this.bottomSheet,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.extendBody = false,
    this.drawerBarrierDismissible = true,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.persistentFooterButtons = const <Widget>[],
    this.narrowWidth = 450,
    this.largeWidth = 1500,
    this.duration = const Duration(milliseconds: 500),
    this.backgroundTransitionColor,
  });

  final Widget body;
  final Widget navigationRail;
  final Widget? extendedNavigationRail;
  final Widget navigationBar;
  final PreferredSizeWidget? appBar;
  final PreferredSizeWidget? railAppBar;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final Widget? drawer;
  final ValueChanged<bool>? onDrawerChanged;
  final Widget? endDrawer;
  final ValueChanged<bool>? onEndDrawerChanged;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final bool extendBody;
  final bool drawerBarrierDismissible;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final List<Widget> persistentFooterButtons;
  final double narrowWidth;
  final double largeWidth;
  final Duration duration;
  final Color? backgroundTransitionColor;

  @override
  State<_AppletAdaptiveNavigationScaffold> createState() =>
      _AppletAdaptiveNavigationScaffoldState();
}

class _AppletAdaptiveNavigationScaffoldState
    extends State<_AppletAdaptiveNavigationScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 0,
  );
  bool? _usesRail;

  @override
  void didUpdateWidget(_AppletAdaptiveNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController(bool usesRail) {
    if (_usesRail == null) {
      _usesRail = usesRail;
      _controller.value = usesRail ? 1 : 0;
      return;
    }
    if (_usesRail == usesRail) {
      return;
    }
    _usesRail = usesRail;
    unawaited(
      _controller.animateTo(
        usesRail ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  double _interval(double begin, double end, double value) {
    if (value <= begin) {
      return 0;
    }
    if (value >= end) {
      return 1;
    }
    return ((value - begin) / (end - begin)).clamp(0, 1).toDouble();
  }

  double _materialDemoSizeValue(double value, {required bool reverse}) {
    if (reverse) {
      return Curves.easeInOutCubicEmphasized.flipped.transform(
        _interval(0, 0.2, value),
      );
    }
    return Curves.easeInOutCubicEmphasized.transform(
      _interval(0.2, 0.8, value),
    );
  }

  double _materialDemoOffsetValue(double value, {required bool reverse}) {
    if (reverse) {
      return Curves.easeInOutCubicEmphasized.flipped.transform(
        _interval(0, 0.2, value),
      );
    }
    return Curves.easeInOutCubicEmphasized.transform(_interval(0.4, 1, value));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final usesRail = width >= widget.narrowWidth;
        final usesExtendedRail = width >= widget.largeWidth;
        _syncController(usesRail);

        final color =
            widget.backgroundTransitionColor ??
            Theme.of(context).colorScheme.surface;
        final rail = usesExtendedRail
            ? (widget.extendedNavigationRail ?? widget.navigationRail)
            : widget.navigationRail;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final railParent = _interval(0.5, 1, _controller.value);
            final barParent = 1 - _interval(0, 0.5, _controller.value);
            final railIsReversing =
                _controller.status == AnimationStatus.reverse;
            final barIsReversing =
                _controller.status == AnimationStatus.forward;
            final railSizeValue = _materialDemoSizeValue(
              railParent,
              reverse: railIsReversing,
            );
            final railOffsetValue = _materialDemoOffsetValue(
              railParent,
              reverse: railIsReversing,
            );
            final barSizeValue = _materialDemoSizeValue(
              barParent,
              reverse: barIsReversing,
            );
            final barOffsetValue = _materialDemoOffsetValue(
              barParent,
              reverse: barIsReversing,
            );
            final isLtr = Directionality.of(context) == TextDirection.ltr;

            return Scaffold(
              appBar: usesRail
                  ? (widget.railAppBar ?? widget.appBar)
                  : widget.appBar,
              body: Row(
                children: <Widget>[
                  ClipRect(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color),
                      child: Align(
                        alignment: Alignment.topLeft,
                        widthFactor: railSizeValue,
                        child: FractionalTranslation(
                          translation: Offset(
                            (isLtr ? -1 : 1) * (1 - railOffsetValue),
                            0,
                          ),
                          child: rail,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: widget.body),
                ],
              ),
              bottomNavigationBar: ClipRect(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                  child: Align(
                    alignment: Alignment.topLeft,
                    heightFactor: barSizeValue,
                    child: FractionalTranslation(
                      translation: Offset(0, 1 - barOffsetValue),
                      child: widget.navigationBar,
                    ),
                  ),
                ),
              ),
              floatingActionButton: widget.floatingActionButton,
              bottomSheet: widget.bottomSheet,
              drawer: widget.drawer,
              onDrawerChanged: widget.onDrawerChanged,
              endDrawer: widget.endDrawer,
              onEndDrawerChanged: widget.onEndDrawerChanged,
              backgroundColor: widget.backgroundColor,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              primary: widget.primary,
              extendBody: widget.extendBody,
              drawerBarrierDismissible: widget.drawerBarrierDismissible,
              extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
              drawerScrimColor: widget.drawerScrimColor,
              drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
              drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
              endDrawerEnableOpenDragGesture:
                  widget.endDrawerEnableOpenDragGesture,
              restorationId: widget.restorationId,
              persistentFooterButtons: widget.persistentFooterButtons,
            );
          },
        );
      },
    );
  }
}

class _AppletAdaptiveTwoPane extends StatefulWidget {
  const _AppletAdaptiveTwoPane({
    required this.compactPane,
    required this.primaryPane,
    this.secondaryPane,
    this.breakpoint = 1000,
    this.primaryFlex = 1000,
    this.secondaryFlex = 1000,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget compactPane;
  final Widget primaryPane;
  final Widget? secondaryPane;
  final double breakpoint;
  final int primaryFlex;
  final int secondaryFlex;
  final Duration duration;

  @override
  State<_AppletAdaptiveTwoPane> createState() => _AppletAdaptiveTwoPaneState();
}

class _AppletAdaptiveTwoPaneState extends State<_AppletAdaptiveTwoPane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 0,
  );
  bool? _usesTwoPanes;

  @override
  void didUpdateWidget(_AppletAdaptiveTwoPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController(bool usesTwoPanes) {
    if (_usesTwoPanes == null) {
      _usesTwoPanes = usesTwoPanes;
      _controller.value = usesTwoPanes ? 1 : 0;
      return;
    }
    if (_usesTwoPanes == usesTwoPanes) {
      return;
    }
    _usesTwoPanes = usesTwoPanes;
    unawaited(
      _controller.animateTo(
        usesTwoPanes ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  double _interval(double begin, double end, double value) {
    if (value <= begin) {
      return 0;
    }
    if (value >= end) {
      return 1;
    }
    return ((value - begin) / (end - begin)).clamp(0, 1).toDouble();
  }

  double _materialDemoSizeValue(double value, {required bool reverse}) {
    if (reverse) {
      return Curves.easeInOutCubicEmphasized.flipped.transform(
        _interval(0, 0.2, value),
      );
    }
    return Curves.easeInOutCubicEmphasized.transform(
      _interval(0.2, 0.8, value),
    );
  }

  double _materialDemoOffsetValue(double value, {required bool reverse}) {
    if (reverse) {
      return Curves.easeInOutCubicEmphasized.flipped.transform(
        _interval(0, 0.2, value),
      );
    }
    return Curves.easeInOutCubicEmphasized.transform(_interval(0.4, 1, value));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        _syncController(width >= widget.breakpoint);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final isReversing = _controller.status == AnimationStatus.reverse;
            final sizeValue = _materialDemoSizeValue(
              _controller.value,
              reverse: isReversing,
            );
            final offsetValue = _materialDemoOffsetValue(
              _controller.value,
              reverse: isReversing,
            );
            if (sizeValue <= 0.001) {
              return widget.compactPane;
            }

            final secondary = widget.secondaryPane;
            final isLtr = Directionality.of(context) == TextDirection.ltr;
            final children = <Widget>[
              Flexible(flex: widget.primaryFlex, child: widget.primaryPane),
            ];
            if (secondary != null) {
              children.add(
                Flexible(
                  flex: math.max(1, (widget.secondaryFlex * sizeValue).round()),
                  child: ClipRect(
                    child: FractionalTranslation(
                      translation: Offset(
                        (isLtr ? 1 : -1) * (1 - offsetValue),
                        0,
                      ),
                      child: secondary,
                    ),
                  ),
                ),
              );
            }
            return Row(children: children);
          },
        );
      },
    );
  }
}

/// Converts JavaScript Applet specs into Flutter widgets.
class AppletRenderer {
  const AppletRenderer({
    this.dispatchAction,
    this.builders = const <String, AppletWidgetFactory>{},
  });

  /// Invoked when a JS action descriptor is triggered by Flutter.
  final AppletActionDispatcher? dispatchAction;

  /// Optional custom widget factories keyed by Applet type.
  final Map<String, AppletWidgetFactory> builders;

  Widget buildWidget(BuildContext context, Object? spec) {
    if (spec == null) {
      return const SizedBox.shrink();
    }
    if (spec is Widget) {
      return spec;
    }
    if (spec is String || spec is num || spec is bool) {
      return Text(spec.toString());
    }
    if (spec is List) {
      return Column(children: buildWidgets(context, spec));
    }
    if (spec is! Map) {
      return Text(spec.toString());
    }

    final map = _stringMap(spec);
    final type = (map['type'] ?? map[r'$applet.type'] ?? 'Text').toString();
    final props = _props(map);
    final custom = builders[type] ?? builders[type.toLowerCase()];
    if (custom != null) {
      return custom(AppletBuildContext(context, this), props);
    }

    switch (type.toLowerCase()) {
      case 'action':
        return const SizedBox.shrink();
      case 'materialapp':
        return _materialApp(context, props);
      case 'cupertinoapp':
        return cupertino.CupertinoApp(
          title: _string(props['title']) ?? 'Applet',
          debugShowCheckedModeBanner:
              _bool(props['debugShowCheckedModeBanner']) ?? false,
          theme: _cupertinoThemeData(props['theme']),
          home: buildWidget(context, props['home'] ?? props['child']),
        );
      case 'theme':
        return Theme(
          data: _themeData(props['data']) ?? Theme.of(context),
          child: buildWidget(context, props['child']),
        );
      case 'animatedtheme':
        return AnimatedTheme(
          data: _themeData(props['data']) ?? Theme.of(context),
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'scaffold':
        return _scaffold(context, props);
      case 'adaptivenavigationscaffold':
        return _adaptiveNavigationScaffold(context, props);
      case 'adaptivetwopane':
        return _adaptiveTwoPane(context, props);
      case 'scaffoldmessenger':
        return ScaffoldMessenger(child: _child(context, props));
      case 'appbar':
        return _appBar(context, props);
      case 'cupertinopagescaffold':
        return cupertino.CupertinoPageScaffold(
          navigationBar: _cupertinoNavigationBar(
            context,
            props['navigationBar'],
          ),
          backgroundColor: _color(props['backgroundColor'], context),
          resizeToAvoidBottomInset:
              _bool(props['resizeToAvoidBottomInset']) ?? true,
          child: _child(context, props),
        );
      case 'cupertinonavigationbar':
        return _cupertinoNavigationBar(context, props) ??
            const SizedBox.shrink();
      case 'cupertinoslivernavigationbar':
        return _cupertinoSliverNavigationBar(context, props);
      case 'cupertinonavigationbarbackbutton':
        return cupertino.CupertinoNavigationBarBackButton(
          color: _color(props['color'], context),
          previousPageTitle: _string(props['previousPageTitle']),
          onPressed: _callback(props['onPressed'] ?? props['onTap']),
        );
      case 'cupertinoalertdialog':
        return cupertino.CupertinoAlertDialog(
          title: _optionalWidget(context, props['title']),
          content: _optionalWidget(context, props['content'] ?? props['child']),
          actions: buildWidgets(context, props['actions'] ?? props['children']),
          insetAnimationDuration:
              _duration(props['insetAnimationDuration']) ??
              const Duration(milliseconds: 100),
          insetAnimationCurve:
              _curve(props['insetAnimationCurve'] ?? props['curve']) ??
              Curves.decelerate,
        );
      case 'cupertinoactionsheet':
        return cupertino.CupertinoActionSheet(
          title: _optionalWidget(context, props['title']),
          message: _optionalWidget(
            context,
            props['message'] ?? props['content'],
          ),
          actions: buildWidgets(context, props['actions'] ?? props['children']),
          cancelButton: _optionalWidget(context, props['cancelButton']),
        );
      case 'cupertinodialogaction':
        return cupertino.CupertinoDialogAction(
          onPressed: _callback(props['onPressed'] ?? props['onTap']),
          isDefaultAction: _bool(props['isDefaultAction']) ?? false,
          isDestructiveAction: _bool(props['isDestructiveAction']) ?? false,
          textStyle: _textStyle(props['textStyle'] ?? props['style'], context),
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          child: _child(context, props),
        );
      case 'cupertinoactionsheetaction':
        return cupertino.CupertinoActionSheetAction(
          onPressed: _callback(props['onPressed'] ?? props['onTap']) ?? () {},
          isDefaultAction: _bool(props['isDefaultAction']) ?? false,
          isDestructiveAction: _bool(props['isDestructiveAction']) ?? false,
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          focusColor: _color(props['focusColor'], context),
          child: _child(context, props),
        );
      case 'safearea':
        return SafeArea(
          top: _bool(props['top']) ?? true,
          bottom: _bool(props['bottom']) ?? true,
          left: _bool(props['left']) ?? true,
          right: _bool(props['right']) ?? true,
          minimum:
              _nonNegativeEdgeInsetsOnly(props['minimum']) ?? EdgeInsets.zero,
          maintainBottomViewPadding:
              _bool(props['maintainBottomViewPadding']) ?? false,
          child: _child(context, props),
        );
      case 'directionality':
        return Directionality(
          textDirection:
              _textDirection(props['textDirection']) ?? TextDirection.ltr,
          child: _child(context, props),
        );
      case 'tickermode':
        return TickerMode(
          enabled: _bool(props['enabled']) ?? true,
          forceFrames: _bool(props['forceFrames']) ?? false,
          child: _child(context, props),
        );
      case 'selectionarea':
        final selectionControls = _textSelectionControls(
          props['selectionControls'] ?? props['controls'],
        );
        return SelectionArea(
          selectionControls: selectionControls,
          contextMenuBuilder: _selectionAreaContextMenuBuilder(props),
          magnifierConfiguration: _textMagnifierConfiguration(
            props['magnifierConfiguration'] ??
                props['magnifier'] ??
                props['enableMagnifier'],
          ),
          onSelectionChanged: _selectedContentCallback(
            props['onSelectionChanged'] ?? props['onChanged'],
          ),
          child: _child(context, props),
        );
      case 'defaultselectionstyle':
        return DefaultSelectionStyle(
          cursorColor: _color(props['cursorColor'], context),
          selectionColor: _color(props['selectionColor'], context),
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          child: _child(context, props),
        );
      case 'center':
        return Center(
          widthFactor: _nonNegativeDouble(props['widthFactor']),
          heightFactor: _nonNegativeDouble(props['heightFactor']),
          child: _child(context, props),
        );
      case 'align':
        return Align(
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          widthFactor: _nonNegativeDouble(props['widthFactor']),
          heightFactor: _nonNegativeDouble(props['heightFactor']),
          child: _child(context, props),
        );
      case 'padding':
        return Padding(
          padding: _nonNegativeEdgeInsets(props['padding']) ?? EdgeInsets.zero,
          child: _child(context, props),
        );
      case 'container':
        return _container(context, props);
      case 'coloredbox':
        return ColoredBox(
          color: _color(props['color'], context) ?? Colors.transparent,
          isAntiAlias: _bool(props['isAntiAlias']) ?? true,
          child: _child(context, props),
        );
      case 'decoratedbox':
        return DecoratedBox(
          decoration:
              _boxDecoration(props['decoration'], context) ??
              const BoxDecoration(),
          position:
              _decorationPosition(props['position']) ??
              DecorationPosition.background,
          child: _child(context, props),
        );
      case 'sizedbox':
        return SizedBox(
          width: _nonNegativeDouble(props['width']),
          height: _nonNegativeDouble(props['height']),
          child: _maybeChild(context, props),
        );
      case 'constrainedbox':
        return ConstrainedBox(
          constraints:
              _boxConstraints(props['constraints']) ?? const BoxConstraints(),
          child: _child(context, props),
        );
      case 'limitedbox':
        return LimitedBox(
          maxWidth: _nonNegativeDouble(props['maxWidth']) ?? double.infinity,
          maxHeight: _nonNegativeDouble(props['maxHeight']) ?? double.infinity,
          child: _child(context, props),
        );
      case 'unconstrainedbox':
        return UnconstrainedBox(
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          constrainedAxis: _axis(props['constrainedAxis']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          child: _child(context, props),
        );
      case 'overflowbox':
        final minWidth = _nonNegativeDouble(props['minWidth']);
        final minHeight = _nonNegativeDouble(props['minHeight']);
        return OverflowBox(
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          minWidth: minWidth,
          maxWidth: _safeMaxDouble(props['maxWidth'], minWidth),
          minHeight: minHeight,
          maxHeight: _safeMaxDouble(props['maxHeight'], minHeight),
          fit: _overflowBoxFit(props['fit']) ?? OverflowBoxFit.max,
          child: _child(context, props),
        );
      case 'sizedoverflowbox':
        return SizedOverflowBox(
          size:
              _nonNegativeSize(props['size']) ??
              Size(
                _nonNegativeDouble(props['width']) ?? 0,
                _nonNegativeDouble(props['height']) ?? 0,
              ),
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          child: _child(context, props),
        );
      case 'aspectratio':
        return AspectRatio(
          aspectRatio:
              _positiveDouble(props['aspectRatio'] ?? props['ratio']) ?? 1,
          child: _child(context, props),
        );
      case 'fractionallysizedbox':
        return FractionallySizedBox(
          widthFactor: _nonNegativeDouble(props['widthFactor']),
          heightFactor: _nonNegativeDouble(props['heightFactor']),
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          child: _child(context, props),
        );
      case 'fittedbox':
        return FittedBox(
          fit: _boxFit(props['fit']) ?? BoxFit.contain,
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          child: _maybeChild(context, props),
        );
      case 'baseline':
        return Baseline(
          baseline: _nonNegativeDouble(props['baseline']) ?? 0,
          baselineType:
              _textBaseline(props['baselineType']) ?? TextBaseline.alphabetic,
          child: _child(context, props),
        );
      case 'intrinsicwidth':
        return IntrinsicWidth(
          stepWidth: _nonNegativeDouble(props['stepWidth']),
          stepHeight: _nonNegativeDouble(props['stepHeight']),
          child: _child(context, props),
        );
      case 'intrinsicheight':
        return IntrinsicHeight(child: _child(context, props));
      case 'expanded':
        return Expanded(
          flex: _positiveInt(props['flex']) ?? 1,
          child: _child(context, props),
        );
      case 'flexible':
        return Flexible(
          flex: _positiveInt(props['flex']) ?? 1,
          fit: _flexFit(props['fit']) ?? FlexFit.loose,
          child: _child(context, props),
        );
      case 'spacer':
        return Spacer(flex: _positiveInt(props['flex']) ?? 1);
      case 'opacity':
        return Opacity(
          opacity: (_double(props['opacity']) ?? 1).clamp(0, 1),
          alwaysIncludeSemantics:
              _bool(props['alwaysIncludeSemantics']) ?? false,
          child: _child(context, props),
        );
      case 'animatedopacity':
        return AnimatedOpacity(
          opacity: (_double(props['opacity']) ?? 1).clamp(0, 1),
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          onEnd: _callback(props['onEnd']),
          alwaysIncludeSemantics:
              _bool(props['alwaysIncludeSemantics']) ?? false,
          child: _child(context, props),
        );
      case 'animatedcontainer':
        return AnimatedContainer(
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          width: _nonNegativeDouble(props['width']),
          height: _nonNegativeDouble(props['height']),
          constraints: _boxConstraints(props['constraints']),
          margin: _nonNegativeEdgeInsets(props['margin']),
          padding: _nonNegativeEdgeInsets(props['padding']),
          alignment: _alignment(props['alignment']),
          decoration:
              _boxDecoration(props['decoration'], context) ??
              _boxDecoration(props, context),
          foregroundDecoration: _boxDecoration(
            props['foregroundDecoration'],
            context,
          ),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          onEnd: _callback(props['onEnd']),
          child: _maybeChild(context, props),
        );
      case 'animatedalign':
        return AnimatedAlign(
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          widthFactor: _nonNegativeDouble(props['widthFactor']),
          heightFactor: _nonNegativeDouble(props['heightFactor']),
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedpadding':
        return AnimatedPadding(
          padding: _nonNegativeEdgeInsets(props['padding']) ?? EdgeInsets.zero,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedscale':
        return AnimatedScale(
          scale: _double(props['scale']) ?? 1,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          filterQuality: _filterQuality(props['filterQuality']),
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedrotation':
        return AnimatedRotation(
          turns: _double(props['turns']) ?? 0,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          alignment: _plainAlignment(props['alignment']) ?? Alignment.center,
          filterQuality: _filterQuality(props['filterQuality']),
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedslide':
        return AnimatedSlide(
          offset: _offset(props['offset']) ?? Offset.zero,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedsize':
        return AnimatedSize(
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          reverseDuration: _duration(props['reverseDuration']),
          curve: _curve(props['curve']) ?? Curves.linear,
          alignment: _alignment(props['alignment']) ?? Alignment.center,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedswitcher':
        return AnimatedSwitcher(
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          reverseDuration: _duration(props['reverseDuration']),
          switchInCurve: _curve(props['switchInCurve']) ?? Curves.linear,
          switchOutCurve: _curve(props['switchOutCurve']) ?? Curves.linear,
          child: _child(context, props),
        );
      case 'animatedcrossfade':
        return AnimatedCrossFade(
          firstChild:
              _optionalWidget(context, props['firstChild']) ??
              const SizedBox.shrink(),
          secondChild:
              _optionalWidget(context, props['secondChild']) ??
              const SizedBox.shrink(),
          crossFadeState: (_bool(props['showSecond']) ?? false)
              ? CrossFadeState.showSecond
              : _crossFadeState(props['crossFadeState']) ??
                    CrossFadeState.showFirst,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          reverseDuration: _duration(props['reverseDuration']),
          firstCurve: _curve(props['firstCurve']) ?? Curves.linear,
          secondCurve: _curve(props['secondCurve']) ?? Curves.linear,
          sizeCurve: _curve(props['sizeCurve']) ?? Curves.linear,
          alignment: _alignment(props['alignment']) ?? Alignment.topCenter,
          excludeBottomFocus: _bool(props['excludeBottomFocus']) ?? true,
          onEnd: _callback(props['onEnd']),
        );
      case 'animateddefaulttextstyle':
        return AnimatedDefaultTextStyle(
          style:
              _textStyle(props['style'], context) ??
              DefaultTextStyle.of(context).style,
          textAlign: _textAlign(props['textAlign']),
          softWrap: _bool(props['softWrap']) ?? true,
          overflow: _textOverflow(props['overflow']) ?? TextOverflow.clip,
          maxLines: _int(props['maxLines']),
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'animatedphysicalmodel':
        return AnimatedPhysicalModel(
          shape: _boxShape(props['shape']) ?? BoxShape.rectangle,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          borderRadius: _borderRadius(props['borderRadius'] ?? props['radius']),
          elevation: math.max(0, _double(props['elevation']) ?? 0),
          color: _color(props['color'], context) ?? Colors.transparent,
          animateColor: _bool(props['animateColor']) ?? true,
          shadowColor: _color(props['shadowColor'], context) ?? Colors.black,
          animateShadowColor: _bool(props['animateShadowColor']) ?? true,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          child: _child(context, props),
        );
      case 'visibility':
        final maintainAll = _bool(props['maintain']) ?? false;
        final maintainSemantics =
            maintainAll || (_bool(props['maintainSemantics']) ?? false);
        final maintainInteractivity =
            maintainAll || (_bool(props['maintainInteractivity']) ?? false);
        final maintainFocusability =
            maintainAll || (_bool(props['maintainFocusability']) ?? false);
        final maintainSize =
            maintainAll ||
            (_bool(props['maintainSize']) ?? false) ||
            maintainSemantics ||
            maintainInteractivity;
        final maintainAnimation =
            maintainAll ||
            (_bool(props['maintainAnimation']) ?? false) ||
            maintainSize;
        final maintainState =
            maintainAll ||
            (_bool(props['maintainState']) ?? false) ||
            maintainAnimation ||
            maintainFocusability;
        return Visibility(
          visible: _bool(props['visible']) ?? true,
          maintainState: maintainState,
          maintainAnimation: maintainAnimation,
          maintainSize: maintainSize,
          maintainSemantics: maintainSemantics,
          maintainInteractivity: maintainInteractivity,
          maintainFocusability: maintainFocusability,
          replacement:
              _optionalWidget(context, props['replacement']) ??
              const SizedBox.shrink(),
          child: _child(context, props),
        );
      case 'offstage':
        return Offstage(
          offstage: _bool(props['offstage']) ?? true,
          child: _child(context, props),
        );
      case 'ignorepointer':
        return IgnorePointer(
          ignoring: _bool(props['ignoring']) ?? true,
          child: _child(context, props),
        );
      case 'absorbpointer':
        return AbsorbPointer(
          absorbing: _bool(props['absorbing']) ?? true,
          child: _child(context, props),
        );
      case 'repaintboundary':
        return RepaintBoundary(child: _child(context, props));
      case 'semantics':
        return _semantics(context, props);
      case 'excludesemantics':
        return ExcludeSemantics(
          excluding: _bool(props['excluding']) ?? true,
          child: _child(context, props),
        );
      case 'mergesemantics':
        return MergeSemantics(child: _child(context, props));
      case 'physicalmodel':
        return PhysicalModel(
          shape: _boxShape(props['shape']) ?? BoxShape.rectangle,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          borderRadius: _borderRadius(props['borderRadius'] ?? props['radius']),
          elevation: math.max(0, _double(props['elevation']) ?? 0),
          color: _color(props['color'], context) ?? Colors.transparent,
          shadowColor: _color(props['shadowColor'], context) ?? Colors.black,
          child: _child(context, props),
        );
      case 'cliprrect':
        return ClipRRect(
          borderRadius:
              _borderRadius(props['borderRadius'] ?? props['radius']) ??
              BorderRadius.zero,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.antiAlias,
          child: _child(context, props),
        );
      case 'clipoval':
        return ClipOval(
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.antiAlias,
          child: _child(context, props),
        );
      case 'cliprect':
        return ClipRect(
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          child: _child(context, props),
        );
      case 'rotatedbox':
        return RotatedBox(
          quarterTurns: _int(props['quarterTurns']) ?? 0,
          child: _child(context, props),
        );
      case 'transform':
        return _transform(context, props);
      case 'singlechildscrollview':
        return SingleChildScrollView(
          scrollDirection: _axis(props['scrollDirection']) ?? Axis.vertical,
          reverse: _bool(props['reverse']) ?? false,
          padding: _edgeInsets(props['padding']),
          primary: _bool(props['primary']),
          physics: _scrollPhysics(props),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          hitTestBehavior:
              _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
              HitTestBehavior.opaque,
          restorationId: _string(props['restorationId']),
          child: _child(context, props),
        );
      case 'customscrollview':
        return CustomScrollView(
          scrollDirection: _axis(props['scrollDirection']) ?? Axis.vertical,
          reverse: _bool(props['reverse']) ?? false,
          primary: _bool(props['primary']),
          physics: _scrollPhysics(props),
          shrinkWrap: _bool(props['shrinkWrap']) ?? false,
          anchor: _unitDouble(props['anchor']) ?? 0,
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          hitTestBehavior:
              _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
              HitTestBehavior.opaque,
          restorationId: _string(props['restorationId']),
          slivers: buildWidgets(context, props['slivers'] ?? props['children']),
        );
      case 'slivertoboxadapter':
        return SliverToBoxAdapter(child: _child(context, props));
      case 'sliverpadding':
        return SliverPadding(
          padding: _edgeInsets(props['padding']) ?? EdgeInsets.zero,
          sliver: _child(context, props),
        );
      case 'sliverlist':
        return SliverList(
          delegate: SliverChildListDelegate(
            buildWidgets(context, props['children']),
          ),
        );
      case 'slivercachedlist':
      case 'sliverestimatedlist':
        return _sliverCachedList(context, props);
      case 'slivergrid':
        return SliverGrid.count(
          crossAxisCount: math.max(1, _int(props['crossAxisCount']) ?? 2),
          childAspectRatio: _positiveDouble(props['childAspectRatio']) ?? 1,
          mainAxisSpacing: _nonNegativeDouble(props['mainAxisSpacing']) ?? 0,
          crossAxisSpacing: _nonNegativeDouble(props['crossAxisSpacing']) ?? 0,
          children: buildWidgets(context, props['children']),
        );
      case 'sliverfillremaining':
        return SliverFillRemaining(
          hasScrollBody: _bool(props['hasScrollBody']) ?? true,
          fillOverscroll: _bool(props['fillOverscroll']) ?? false,
          child: _child(context, props),
        );
      case 'sliverappbar':
        return _sliverAppBar(context, props);
      case 'sliverlayoutbuilder':
        return _sliverLayoutBuilder(context, props);
      case 'builder':
        return _child(context, props);
      case 'layoutbuilder':
        return _layoutBuilder(context, props);
      case 'orientationbuilder':
        return _orientationBuilder(context, props);
      case 'mediaquery':
        return MediaQuery(
          data: _mediaQueryData(context, props['data'] ?? props),
          child: _child(context, props),
        );
      case 'defaulttextstyle':
        return DefaultTextStyle(
          style:
              _textStyle(props['style'], context) ??
              DefaultTextStyle.of(context).style,
          textAlign: _textAlign(props['textAlign']),
          softWrap: _bool(props['softWrap']) ?? true,
          maxLines: _positiveInt(props['maxLines']),
          overflow: _textOverflow(props['overflow']) ?? TextOverflow.clip,
          child: _child(context, props),
        );
      case 'icontheme':
        return IconTheme(
          data: _iconThemeData(props['data'] ?? props),
          child: _child(context, props),
        );
      case 'form':
        return Form(
          autovalidateMode: _autovalidateMode(props['autovalidateMode']),
          onChanged: _callback(props['onChanged']),
          child: _child(context, props),
        );
      case 'autofillgroup':
        return AutofillGroup(
          onDisposeAction:
              _autofillContextAction(props['onDisposeAction']) ??
              AutofillContextAction.commit,
          child: _child(context, props),
        );
      case 'focus':
        return Focus(
          autofocus: _bool(props['autofocus']) ?? false,
          onFocusChange: _valueCallback(props['onFocusChange']),
          canRequestFocus: _bool(props['canRequestFocus']),
          skipTraversal: _bool(props['skipTraversal']) ?? false,
          descendantsAreFocusable: _bool(props['descendantsAreFocusable']),
          descendantsAreTraversable: _bool(props['descendantsAreTraversable']),
          includeSemantics: _bool(props['includeSemantics']) ?? true,
          debugLabel: _string(props['debugLabel'] ?? props['label']),
          onKeyEvent: _focusKeyEventCallback(
            props['onKeyEvent'] ?? props['onKey'],
          ),
          child: _child(context, props),
        );
      case 'focustraversalgroup':
        return FocusTraversalGroup(
          policy: _focusTraversalPolicy(props['policy']),
          descendantsAreFocusable:
              _bool(props['descendantsAreFocusable']) ?? true,
          descendantsAreTraversable:
              _bool(props['descendantsAreTraversable']) ?? true,
          child: _child(context, props),
        );
      case 'focusableactiondetector':
        return FocusableActionDetector(
          enabled: _bool(props['enabled']) ?? true,
          autofocus: _bool(props['autofocus']) ?? false,
          descendantsAreFocusable:
              _bool(props['descendantsAreFocusable']) ?? true,
          descendantsAreTraversable:
              _bool(props['descendantsAreTraversable']) ?? true,
          onShowFocusHighlight: _valueCallback(props['onShowFocusHighlight']),
          onShowHoverHighlight: _valueCallback(props['onShowHoverHighlight']),
          onFocusChange: _valueCallback(props['onFocusChange']),
          mouseCursor: _mouseCursor(props['mouseCursor'] ?? props['cursor']),
          includeFocusSemantics: _bool(props['includeFocusSemantics']) ?? true,
          child: _child(context, props),
        );
      case 'keyboardlistener':
        return _AppletKeyboardListener(
          autofocus: _bool(props['autofocus']) ?? false,
          includeSemantics: _bool(props['includeSemantics']) ?? true,
          onKeyEvent: _keyEventCallback(props['onKeyEvent'] ?? props['onKey']),
          child: _child(context, props),
        );
      case 'callbackshortcuts':
        return CallbackShortcuts(
          bindings: _shortcutBindings(props['bindings'] ?? props['shortcuts']),
          child: _child(context, props),
        );
      case 'column':
        final crossAxisAlignment =
            _crossAxisAlignment(props['crossAxisAlignment']) ??
            CrossAxisAlignment.center;
        return Column(
          mainAxisAlignment:
              _mainAxisAlignment(props['mainAxisAlignment']) ??
              MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize:
              _mainAxisSize(props['mainAxisSize']) ?? MainAxisSize.max,
          textDirection: _textDirection(props['textDirection']),
          verticalDirection:
              _verticalDirection(props['verticalDirection']) ??
              VerticalDirection.down,
          textBaseline:
              _textBaseline(props['textBaseline'] ?? props['baseline']) ??
              (crossAxisAlignment == CrossAxisAlignment.baseline
                  ? TextBaseline.alphabetic
                  : null),
          spacing: _nonNegativeDouble(props['spacing']) ?? 0,
          children: buildWidgets(context, props['children']),
        );
      case 'row':
        final crossAxisAlignment =
            _crossAxisAlignment(props['crossAxisAlignment']) ??
            CrossAxisAlignment.center;
        return Row(
          mainAxisAlignment:
              _mainAxisAlignment(props['mainAxisAlignment']) ??
              MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize:
              _mainAxisSize(props['mainAxisSize']) ?? MainAxisSize.max,
          textDirection: _textDirection(props['textDirection']),
          verticalDirection:
              _verticalDirection(props['verticalDirection']) ??
              VerticalDirection.down,
          textBaseline:
              _textBaseline(props['textBaseline'] ?? props['baseline']) ??
              (crossAxisAlignment == CrossAxisAlignment.baseline
                  ? TextBaseline.alphabetic
                  : null),
          spacing: _nonNegativeDouble(props['spacing']) ?? 0,
          children: buildWidgets(context, props['children']),
        );
      case 'stack':
        return Stack(
          alignment:
              _alignment(props['alignment']) ?? AlignmentDirectional.topStart,
          textDirection: _textDirection(props['textDirection']),
          fit: _stackFit(props['fit']) ?? StackFit.loose,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          children: buildWidgets(context, props['children']),
        );
      case 'indexedstack':
        final children = buildWidgets(context, props['children']);
        final index = children.isEmpty
            ? 0
            : (_int(props['index']) ?? 0).clamp(0, children.length - 1).toInt();
        return IndexedStack(
          index: index,
          alignment:
              _alignment(props['alignment']) ?? AlignmentDirectional.topStart,
          textDirection: _textDirection(props['textDirection']),
          sizing: _stackFit(props['sizing'] ?? props['fit']) ?? StackFit.loose,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          children: children,
        );
      case 'positioned':
        final left = _double(props['left']);
        final top = _double(props['top']);
        final right = _double(props['right']);
        final bottom = _double(props['bottom']);
        var width = _nonNegativeDouble(props['width']);
        var height = _nonNegativeDouble(props['height']);
        if (left != null && right != null && width != null) {
          width = null;
        }
        if (top != null && bottom != null && height != null) {
          height = null;
        }
        return Positioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          width: width,
          height: height,
          child: _child(context, props),
        );
      case 'animatedpositioned':
        final left = _double(props['left']);
        final top = _double(props['top']);
        final right = _double(props['right']);
        final bottom = _double(props['bottom']);
        var width = _nonNegativeDouble(props['width']);
        var height = _nonNegativeDouble(props['height']);
        if (left != null && right != null && width != null) {
          width = null;
        }
        if (top != null && bottom != null && height != null) {
          height = null;
        }
        return AnimatedPositioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          width: width,
          height: height,
          duration:
              _duration(props['duration']) ?? const Duration(milliseconds: 200),
          curve: _curve(props['curve']) ?? Curves.linear,
          onEnd: _callback(props['onEnd']),
          child: _child(context, props),
        );
      case 'wrap':
        return Wrap(
          direction: _axis(props['direction']) ?? Axis.horizontal,
          alignment: _wrapAlignment(props['alignment']) ?? WrapAlignment.start,
          runAlignment:
              _wrapAlignment(props['runAlignment']) ?? WrapAlignment.start,
          crossAxisAlignment:
              _wrapCrossAlignment(props['crossAxisAlignment']) ??
              WrapCrossAlignment.start,
          spacing: _nonNegativeDouble(props['spacing']) ?? 0,
          runSpacing: _nonNegativeDouble(props['runSpacing']) ?? 0,
          textDirection: _textDirection(props['textDirection']),
          verticalDirection:
              _verticalDirection(props['verticalDirection']) ??
              VerticalDirection.down,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          children: buildWidgets(context, props['children']),
        );
      case 'listbody':
        return ListBody(
          mainAxis: _axis(props['mainAxis'] ?? props['axis']) ?? Axis.vertical,
          reverse: _bool(props['reverse']) ?? false,
          children: buildWidgets(context, props['children']),
        );
      case 'listview':
        final axis = _axis(props['scrollDirection']) ?? Axis.vertical;
        return ListView(
          scrollDirection: axis,
          reverse: _bool(props['reverse']) ?? false,
          padding: _edgeInsets(props['padding']),
          shrinkWrap: _bool(props['shrinkWrap']) ?? false,
          primary: _bool(props['primary']),
          physics: _scrollPhysics(props),
          itemExtent: _positiveDouble(props['itemExtent']),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          hitTestBehavior:
              _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
              HitTestBehavior.opaque,
          restorationId: _string(props['restorationId']),
          children: _spacedWidgets(
            buildWidgets(context, props['children']),
            _double(props['spacing']) ?? 0,
            axis,
          ),
        );
      case 'scrollbar':
        return _AppletScrollbar(
          thumbVisibility: _bool(props['thumbVisibility']),
          trackVisibility: _bool(props['trackVisibility']),
          thickness: _nonNegativeDouble(props['thickness']),
          radius: _nonNegativeRadius(props['radius']),
          interactive: _bool(props['interactive']),
          scrollbarOrientation: _scrollbarOrientation(
            props['scrollbarOrientation'] ?? props['orientation'],
          ),
          child: _scrollbarChild(context, props),
        );
      case 'cupertinoscrollbar':
        return _AppletCupertinoScrollbar(
          thumbVisibility: _bool(props['thumbVisibility']),
          thickness:
              _nonNegativeDouble(props['thickness']) ??
              cupertino.CupertinoScrollbar.defaultThickness,
          thicknessWhileDragging:
              _nonNegativeDouble(props['thicknessWhileDragging']) ??
              cupertino.CupertinoScrollbar.defaultThicknessWhileDragging,
          radius:
              _nonNegativeRadius(props['radius']) ??
              cupertino.CupertinoScrollbar.defaultRadius,
          radiusWhileDragging:
              _nonNegativeRadius(props['radiusWhileDragging']) ??
              cupertino.CupertinoScrollbar.defaultRadiusWhileDragging,
          scrollbarOrientation: _scrollbarOrientation(
            props['scrollbarOrientation'] ?? props['orientation'],
          ),
          mainAxisMargin: _nonNegativeDouble(props['mainAxisMargin']) ?? 3,
          child: _child(context, props),
        );
      case 'gridview':
        return GridView.count(
          crossAxisCount: math.max(1, _int(props['crossAxisCount']) ?? 2),
          childAspectRatio: _positiveDouble(props['childAspectRatio']) ?? 1,
          mainAxisSpacing: _nonNegativeDouble(props['mainAxisSpacing']) ?? 0,
          crossAxisSpacing: _nonNegativeDouble(props['crossAxisSpacing']) ?? 0,
          mainAxisExtent: _positiveDouble(props['mainAxisExtent']),
          reverse: _bool(props['reverse']) ?? false,
          padding: _edgeInsets(props['padding']),
          primary: _bool(props['primary']),
          shrinkWrap: _bool(props['shrinkWrap']) ?? false,
          physics: _scrollPhysics(props),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          hitTestBehavior:
              _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
              HitTestBehavior.opaque,
          restorationId: _string(props['restorationId']),
          children: buildWidgets(context, props['children']),
        );
      case 'gridtile':
        return GridTile(
          header: _optionalWidget(context, props['header']),
          footer: _optionalWidget(context, props['footer']),
          child: _child(context, props),
        );
      case 'gridtilebar':
        return GridTileBar(
          backgroundColor: _color(props['backgroundColor']),
          leading: _optionalWidget(context, props['leading']),
          title: _optionalWidget(context, props['title'] ?? props['label']),
          subtitle: _optionalWidget(context, props['subtitle']),
          trailing: _optionalWidget(context, props['trailing']),
        );
      case 'pageview':
        return PageView(
          scrollDirection: _axis(props['scrollDirection']) ?? Axis.horizontal,
          reverse: _bool(props['reverse']) ?? false,
          physics: _scrollPhysics(props),
          pageSnapping: _bool(props['pageSnapping']) ?? true,
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          allowImplicitScrolling:
              _bool(props['allowImplicitScrolling']) ?? false,
          restorationId: _string(props['restorationId']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          hitTestBehavior:
              _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
              HitTestBehavior.opaque,
          padEnds: _bool(props['padEnds']) ?? true,
          onPageChanged: _intCallback(props['onPageChanged']),
          children: buildWidgets(context, props['children']),
        );
      case 'reorderablelistview':
        return ReorderableListView(
          onReorderItem:
              _reorderCallback(
                props['onReorderItem'] ??
                    props['onReorder'] ??
                    props['onChanged'],
              ) ??
              (_, _) {},
          onReorderStart: _intCallback(props['onReorderStart']),
          onReorderEnd: _intCallback(props['onReorderEnd']),
          itemExtent: _positiveDouble(props['itemExtent']),
          buildDefaultDragHandles:
              _bool(props['buildDefaultDragHandles']) ?? true,
          padding: _resolvedEdgeInsets(context, props['padding']),
          header: _optionalWidget(context, props['header']),
          footer: _optionalWidget(context, props['footer']),
          scrollDirection: _axis(props['scrollDirection']) ?? Axis.vertical,
          reverse: _bool(props['reverse']) ?? false,
          primary: _bool(props['primary']),
          physics: _scrollPhysics(props),
          shrinkWrap: _bool(props['shrinkWrap']) ?? false,
          anchor: _unitDouble(props['anchor']) ?? 0,
          scrollCacheExtent: _scrollCacheExtent(
            props['scrollCacheExtent'] ?? props['cacheExtent'],
          ),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          keyboardDismissBehavior: _keyboardDismissBehavior(
            props['keyboardDismissBehavior'],
          ),
          restorationId: _string(props['restorationId']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          autoScrollerVelocityScalar: _positiveDouble(
            props['autoScrollerVelocityScalar'],
          ),
          mouseCursor: _mouseCursor(props['mouseCursor'] ?? props['cursor']),
          children: _keyedWidgets(context, props['children']),
        );
      case 'card':
        final child = _child(context, props);
        final onTap = _callback(props['onTap'] ?? props['onPressed']);
        final variant = props['variant']?.toString().toLowerCase();
        final cardChild = onTap == null
            ? child
            : InkWell(onTap: onTap, child: child);
        final cardShape = _cardShape(context, props, variant);
        final cardColor = _color(props['color'], context);
        final cardShadowColor = _color(props['shadowColor'], context);
        final cardSurfaceTintColor = _color(props['surfaceTintColor'], context);
        final cardElevation = _nonNegativeDouble(props['elevation']);
        final cardMargin = _edgeInsets(props['margin']);
        final cardClipBehavior = _clip(props['clipBehavior']);
        final cardBorderOnForeground =
            _bool(props['borderOnForeground']) ?? true;
        final cardSemanticContainer = _bool(props['semanticContainer']) ?? true;
        if (variant == 'filled') {
          return Card.filled(
            color: cardColor,
            shadowColor: cardShadowColor,
            surfaceTintColor: cardSurfaceTintColor,
            elevation: cardElevation,
            shape: cardShape,
            borderOnForeground: cardBorderOnForeground,
            margin: cardMargin,
            clipBehavior: cardClipBehavior,
            semanticContainer: cardSemanticContainer,
            child: cardChild,
          );
        }
        if (variant == 'outlined') {
          return Card.outlined(
            color: cardColor,
            shadowColor: cardShadowColor,
            surfaceTintColor: cardSurfaceTintColor,
            elevation: cardElevation,
            shape: cardShape,
            borderOnForeground: cardBorderOnForeground,
            margin: cardMargin,
            clipBehavior: cardClipBehavior,
            semanticContainer: cardSemanticContainer,
            child: cardChild,
          );
        }
        return Card(
          color: cardColor,
          shadowColor: cardShadowColor,
          surfaceTintColor: cardSurfaceTintColor,
          elevation: cardElevation,
          shape: cardShape,
          borderOnForeground: cardBorderOnForeground,
          margin: cardMargin,
          clipBehavior: cardClipBehavior,
          semanticContainer: cardSemanticContainer,
          child: cardChild,
        );
      case 'gesturedetector':
        return GestureDetector(
          onTap: _callback(props['onTap']),
          onDoubleTap: _callback(props['onDoubleTap']),
          onLongPress: _callback(props['onLongPress']),
          behavior: _hitTestBehavior(props['behavior']),
          child: _child(context, props),
        );
      case 'listener':
        return Listener(
          onPointerDown: _pointerCallback(props['onPointerDown']),
          onPointerMove: _pointerCallback(props['onPointerMove']),
          onPointerUp: _pointerCallback(props['onPointerUp']),
          onPointerCancel: _pointerCallback(props['onPointerCancel']),
          onPointerSignal: _pointerCallback(props['onPointerSignal']),
          behavior:
              _hitTestBehavior(props['behavior']) ??
              HitTestBehavior.deferToChild,
          child: _child(context, props),
        );
      case 'mouseregion':
        return MouseRegion(
          onEnter: _pointerCallback(props['onEnter']),
          onExit: _pointerCallback(props['onExit']),
          onHover: _pointerCallback(props['onHover']),
          opaque: _bool(props['opaque']) ?? true,
          hitTestBehavior: _hitTestBehavior(props['hitTestBehavior']),
          child: _child(context, props),
        );
      case 'interactiveviewer':
        final minScale = _positiveFiniteDouble(props['minScale']) ?? 0.8;
        final rawMaxScale = _positiveFiniteDouble(props['maxScale']) ?? 2.5;
        final maxScale = math.max(minScale, rawMaxScale);
        final interactiveAlignment = _alignment(props['alignment']);
        return InteractiveViewer(
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          panAxis: _panAxis(props['panAxis']),
          boundaryMargin:
              _finiteEdgeInsets(props['boundaryMargin']) ?? EdgeInsets.zero,
          constrained: _bool(props['constrained']) ?? true,
          maxScale: maxScale,
          minScale: minScale,
          interactionEndFrictionCoefficient:
              _positiveFiniteDouble(
                props['interactionEndFrictionCoefficient'] ??
                    props['frictionCoefficient'] ??
                    props['friction'],
              ) ??
              0.0000135,
          panEnabled: _bool(props['panEnabled']) ?? true,
          scaleEnabled: _bool(props['scaleEnabled']) ?? true,
          scaleFactor:
              _positiveFiniteDouble(props['scaleFactor']) ??
              kDefaultMouseScrollToScaleFactor,
          alignment: interactiveAlignment is Alignment
              ? interactiveAlignment
              : null,
          trackpadScrollCausesScale:
              _bool(props['trackpadScrollCausesScale']) ?? false,
          onInteractionStart: _scaleStartCallback(
            props['onInteractionStart'] ?? props['onStart'],
          ),
          onInteractionUpdate: _scaleUpdateCallback(
            props['onInteractionUpdate'] ?? props['onUpdate'],
          ),
          onInteractionEnd: _scaleEndCallback(
            props['onInteractionEnd'] ?? props['onEnd'],
          ),
          child: _child(context, props),
        );
      case 'dismissible':
        return Dismissible(
          key: _key(props),
          direction:
              _dismissDirection(props['direction']) ??
              DismissDirection.horizontal,
          background: _optionalWidget(context, props['background']),
          secondaryBackground: _optionalWidget(
            context,
            props['secondaryBackground'],
          ),
          resizeDuration: _nonNegativeDuration(props['resizeDuration']),
          movementDuration:
              _nonNegativeDuration(props['movementDuration']) ??
              const Duration(milliseconds: 200),
          crossAxisEndOffset: _double(props['crossAxisEndOffset']) ?? 0,
          behavior:
              _hitTestBehavior(props['behavior']) ?? HitTestBehavior.opaque,
          onDismissed: _dismissCallback(props['onDismissed']),
          onResize: _callback(props['onResize']),
          child: _child(context, props),
        );
      case 'draggable':
        return _draggable(context, props);
      case 'longpressdraggable':
        return _draggable(context, props, longPress: true);
      case 'dragtarget':
        return _dragTarget(context, props);
      case 'tapregion':
        return TapRegion(
          enabled: _bool(props['enabled']) ?? true,
          behavior:
              _hitTestBehavior(props['behavior']) ??
              HitTestBehavior.deferToChild,
          onTapOutside: _pointerCallback(props['onTapOutside']),
          onTapInside: _pointerCallback(props['onTapInside']),
          onTapUpOutside: _pointerCallback(props['onTapUpOutside']),
          onTapUpInside: _pointerCallback(props['onTapUpInside']),
          groupId: props['groupId'],
          consumeOutsideTaps: _bool(props['consumeOutsideTaps']) ?? false,
          debugLabel: _string(props['debugLabel']),
          child: _child(context, props),
        );
      case 'tapregionsurface':
        return TapRegionSurface(child: _child(context, props));
      case 'reorderabledragstartlistener':
        return ReorderableDragStartListener(
          index: _nonNegativeInt(props['index']) ?? 0,
          enabled: _bool(props['enabled']) ?? true,
          child: _child(context, props),
        );
      case 'reorderabledelayeddragstartlistener':
        return ReorderableDelayedDragStartListener(
          index: _nonNegativeInt(props['index']) ?? 0,
          enabled: _bool(props['enabled']) ?? true,
          child: _child(context, props),
        );
      case 'inkwell':
        return InkWell(
          onTap: _callback(props['onTap']),
          onDoubleTap: _callback(props['onDoubleTap']),
          onLongPress: _callback(props['onLongPress']),
          onLongPressUp: _callback(props['onLongPressUp']),
          onTapDown: _tapDownCallback(props['onTapDown']),
          onTapUp: _tapUpCallback(props['onTapUp']),
          onTapCancel: _callback(props['onTapCancel']),
          onSecondaryTap: _callback(props['onSecondaryTap']),
          onSecondaryTapUp: _tapUpCallback(props['onSecondaryTapUp']),
          onSecondaryTapDown: _tapDownCallback(props['onSecondaryTapDown']),
          onSecondaryTapCancel: _callback(props['onSecondaryTapCancel']),
          onHighlightChanged: _valueCallback(props['onHighlightChanged']),
          onHover: _valueCallback(props['onHover']),
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          focusColor: _color(props['focusColor'], context),
          hoverColor: _color(props['hoverColor'], context),
          highlightColor: _color(props['highlightColor'], context),
          overlayColor: _stateColor(props['overlayColor'], context),
          splashColor: _color(props['splashColor'], context),
          radius: _nonNegativeDouble(props['radius']),
          borderRadius: _borderRadius(props['borderRadius']),
          customBorder: _outlinedBorder(
            props['customBorder'] ?? props['shape'],
          ),
          enableFeedback: _bool(props['enableFeedback']) ?? true,
          excludeFromSemantics: _bool(props['excludeFromSemantics']) ?? false,
          canRequestFocus: _bool(props['canRequestFocus']) ?? true,
          onFocusChange: _valueCallback(props['onFocusChange']),
          autofocus: _bool(props['autofocus']) ?? false,
          hoverDuration: _nonNegativeDuration(props['hoverDuration']),
          child: _child(context, props),
        );
      case 'tooltip':
        return Tooltip(
          message: _string(props['message']) ?? _string(props['text']) ?? '',
          constraints: _boxConstraints(props['constraints']),
          padding: _nonNegativeEdgeInsets(props['padding']),
          margin: _nonNegativeEdgeInsets(props['margin']),
          verticalOffset: _nonNegativeDouble(props['verticalOffset']),
          preferBelow: _bool(props['preferBelow']),
          excludeFromSemantics: _bool(props['excludeFromSemantics']),
          decoration: _boxDecoration(props['decoration'], context),
          textStyle: _textStyle(props['textStyle'] ?? props['style'], context),
          textAlign: _textAlign(props['textAlign']),
          waitDuration: _duration(props['waitDuration']),
          showDuration: _duration(props['showDuration']),
          exitDuration: _duration(props['exitDuration']),
          enableTapToDismiss: _bool(props['enableTapToDismiss']) ?? true,
          triggerMode: _tooltipTriggerMode(props['triggerMode']),
          enableFeedback: _bool(props['enableFeedback']),
          onTriggered: _callback(props['onTriggered']),
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          ignorePointer: _bool(props['ignorePointer']),
          child: _child(context, props),
        );
      case 'hero':
        return Hero(
          tag: _string(props['tag']) ?? '',
          transitionOnUserGestures:
              _bool(props['transitionOnUserGestures']) ?? false,
          curve: _curve(props['curve']) ?? Curves.fastOutSlowIn,
          reverseCurve: _curve(props['reverseCurve']),
          child: _child(context, props),
        );
      case 'placeholder':
        return Placeholder(
          color: _color(props['color'], context) ?? const Color(0xFF455A64),
          strokeWidth: _nonNegativeDouble(props['strokeWidth']) ?? 2,
          fallbackWidth: _nonNegativeDouble(props['fallbackWidth']) ?? 400,
          fallbackHeight: _nonNegativeDouble(props['fallbackHeight']) ?? 400,
          child: _maybeChild(context, props),
        );
      case 'material':
        final materialType =
            _materialType(props['materialType'] ?? props['type']) ??
            MaterialType.canvas;
        final materialShape = materialType == MaterialType.circle
            ? null
            : _outlinedBorder(props['shape']);
        final materialBorderRadius = materialShape == null
            ? _borderRadius(props['borderRadius'] ?? props['radius'])
            : null;
        return Material(
          type: materialType,
          color: _color(props['color'], context),
          shadowColor: _color(props['shadowColor'], context),
          surfaceTintColor: _color(props['surfaceTintColor'], context),
          textStyle: _textStyle(props['textStyle'], context),
          elevation: _nonNegativeDouble(props['elevation']) ?? 0,
          borderRadius: materialType == MaterialType.circle
              ? null
              : materialBorderRadius,
          shape: materialShape,
          borderOnForeground: _bool(props['borderOnForeground']) ?? true,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          animationDuration:
              _duration(props['animationDuration']) ?? kThemeChangeDuration,
          animateColor: _bool(props['animateColor']) ?? false,
          child: _child(context, props),
        );
      case 'circleavatar':
        final radius = _nonNegativeDouble(props['radius']);
        final minRadius = radius == null
            ? _nonNegativeDouble(props['minRadius'])
            : null;
        final maxRadius = radius == null
            ? _safeMaxDouble(props['maxRadius'], minRadius)
            : null;
        final backgroundImage = _imageProvider(
          props['backgroundImage'] ??
              props['image'] ??
              props['background'] ??
              props['src'],
        );
        final foregroundImage = _imageProvider(
          props['foregroundImage'] ??
              props['avatarImage'] ??
              props['foreground'] ??
              props['photo'],
        );
        return CircleAvatar(
          radius: radius,
          minRadius: minRadius,
          maxRadius: maxRadius,
          backgroundColor: _color(props['backgroundColor']),
          backgroundImage: backgroundImage,
          foregroundImage: foregroundImage,
          onBackgroundImageError: backgroundImage == null
              ? null
              : _imageErrorCallback(
                  props['onBackgroundImageError'] ??
                      props['onImageError'] ??
                      props['onError'],
                  'background',
                ),
          onForegroundImageError: foregroundImage == null
              ? null
              : _imageErrorCallback(
                  props['onForegroundImageError'] ??
                      props['onImageError'] ??
                      props['onError'],
                  'foreground',
                ),
          foregroundColor: _color(props['foregroundColor']),
          child: _maybeChild(context, props),
        );
      case 'badge':
        if (props.containsKey('count') && props['label'] == null) {
          return Badge.count(
            count: _nonNegativeInt(props['count']) ?? 0,
            maxCount: _positiveInt(props['maxCount']) ?? 999,
            isLabelVisible: _bool(props['isLabelVisible']) ?? true,
            backgroundColor: _color(props['backgroundColor'], context),
            textColor: _color(props['textColor'], context),
            smallSize: _nonNegativeDouble(props['smallSize']),
            largeSize: _nonNegativeDouble(props['largeSize']),
            textStyle: _textStyle(props['textStyle'], context),
            padding: _edgeInsets(props['padding']),
            alignment: _alignment(props['alignment']),
            offset: _offset(props['offset']),
            child: _maybeChild(context, props),
          );
        }
        return Badge(
          label: _optionalWidget(context, props['label']),
          isLabelVisible: _bool(props['isLabelVisible']) ?? true,
          backgroundColor: _color(props['backgroundColor'], context),
          textColor: _color(props['textColor'], context),
          smallSize: _nonNegativeDouble(props['smallSize']),
          largeSize: _nonNegativeDouble(props['largeSize']),
          textStyle: _textStyle(props['textStyle'], context),
          padding: _edgeInsets(props['padding']),
          alignment: _alignment(props['alignment']),
          offset: _offset(props['offset']),
          child: _maybeChild(context, props),
        );
      case 'banner':
        return Banner(
          message: _string(props['message']) ?? '',
          location: _bannerLocation(props['location']) ?? BannerLocation.topEnd,
          textDirection: _textDirection(props['textDirection']),
          layoutDirection: _textDirection(props['layoutDirection']),
          color: _color(props['color'], context) ?? const Color(0xA0B71C1C),
          textStyle:
              _textStyle(props['textStyle'], context) ??
              const TextStyle(
                color: Colors.white,
                fontSize: 10.2,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
          shadow:
              _boxShadow(props['shadow'] ?? props['boxShadow'], context) ??
              const BoxShadow(color: Color(0x7F000000), blurRadius: 6),
          child: _child(context, props),
        );
      case 'materialbanner':
        final actions = buildWidgets(context, props['actions']);
        if (actions.isEmpty) {
          return const SizedBox.shrink();
        }
        return MaterialBanner(
          content:
              _optionalWidget(context, props['content'] ?? props['child']) ??
              _label(context, props),
          contentTextStyle: _textStyle(props['contentTextStyle'], context),
          leading: _optionalWidget(context, props['leading']),
          backgroundColor: _color(props['backgroundColor'], context),
          surfaceTintColor: _color(props['surfaceTintColor'], context),
          shadowColor: _color(props['shadowColor'], context),
          dividerColor: _color(props['dividerColor'], context),
          elevation: _nonNegativeDouble(props['elevation']),
          padding: _edgeInsets(props['padding']),
          margin: _edgeInsets(props['margin']),
          leadingPadding: _edgeInsets(props['leadingPadding']),
          forceActionsBelow: _bool(props['forceActionsBelow']) ?? false,
          overflowAlignment:
              _overflowBarAlignment(props['overflowAlignment']) ??
              OverflowBarAlignment.end,
          minActionBarHeight:
              _nonNegativeDouble(props['minActionBarHeight']) ?? 52,
          onVisible: _callback(props['onVisible']),
          actions: actions,
        );
      case 'cupertinolistsection':
        return _cupertinoListSection(context, props);
      case 'cupertinolisttile':
        return _cupertinoListTile(context, props);
      case 'cupertinolisttilechevron':
        return const cupertino.CupertinoListTileChevron();
      case 'cupertinoformsection':
        return _cupertinoFormSection(context, props);
      case 'cupertinoformrow':
        return _cupertinoFormRow(context, props);
      case 'cupertinopicker':
        return _cupertinoPicker(context, props);
      case 'cupertinopickerdefaultselectionoverlay':
        return _cupertinoPickerDefaultSelectionOverlay(props);
      case 'cupertinodatepicker':
        return _cupertinoDatePicker(context, props);
      case 'cupertinotimerpicker':
        return _cupertinoTimerPicker(context, props);
      case 'drawer':
        return Drawer(
          backgroundColor: _color(props['backgroundColor'], context),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor'], context),
          surfaceTintColor: _color(props['surfaceTintColor'], context),
          shape: _outlinedBorder(props['shape'] ?? props),
          width: _positiveDouble(props['width']),
          clipBehavior: _clip(props['clipBehavior']),
          semanticLabel: _string(props['semanticLabel']),
          child: _child(context, props),
        );
      case 'drawerheader':
        return DrawerHeader(
          decoration: _boxDecoration(props['decoration'], context),
          margin: _edgeInsets(props['margin']) ?? const EdgeInsets.all(0),
          padding:
              _edgeInsets(props['padding']) ??
              const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _child(context, props),
        );
      case 'listtile':
        return _listTile(context, props);
      case 'expansiontile':
        return ExpansionTile(
          leading: _optionalWidget(context, props['leading']),
          title:
              _optionalWidget(context, props['title']) ??
              _label(context, props),
          subtitle: _optionalWidget(context, props['subtitle']),
          trailing: _optionalWidget(context, props['trailing']),
          showTrailingIcon: _bool(props['showTrailingIcon']) ?? true,
          initiallyExpanded: _bool(props['initiallyExpanded']) ?? false,
          maintainState: _bool(props['maintainState']) ?? false,
          tilePadding: _edgeInsets(props['tilePadding']),
          expandedCrossAxisAlignment: _expansionTileCrossAxisAlignment(
            props['expandedCrossAxisAlignment'],
          ),
          expandedAlignment: _alignment(props['expandedAlignment']),
          childrenPadding: _edgeInsets(props['childrenPadding']),
          backgroundColor: _color(props['backgroundColor']),
          collapsedBackgroundColor: _color(props['collapsedBackgroundColor']),
          textColor: _color(props['textColor']),
          collapsedTextColor: _color(props['collapsedTextColor']),
          iconColor: _color(props['iconColor']),
          collapsedIconColor: _color(props['collapsedIconColor']),
          shape: _outlinedBorder(props['shape']),
          collapsedShape: _outlinedBorder(props['collapsedShape']),
          clipBehavior: _clip(props['clipBehavior']),
          controlAffinity: _listTileControlAffinity(props['controlAffinity']),
          dense: _bool(props['dense']),
          splashColor: _color(props['splashColor']),
          visualDensity: _visualDensity(props['visualDensity']),
          minTileHeight: _double(props['minTileHeight']),
          enableFeedback: _bool(props['enableFeedback']) ?? true,
          enabled: _bool(props['enabled']) ?? true,
          expansionAnimationStyle: _animationStyle(
            props['expansionAnimationStyle'] ?? props['animationStyle'],
          ),
          onExpansionChanged: _valueCallback(props['onExpansionChanged']),
          children: buildWidgets(context, props['children']),
        );
      case 'expansionpanellist':
        return _expansionPanelList(context, props, radio: false);
      case 'expansionpanellistradio':
        return _expansionPanelList(context, props, radio: true);
      case 'expansionpanel':
      case 'expansionpanelradio':
        return const SizedBox.shrink();
      case 'divider':
        final dividerThickness = _nonNegativeDouble(props['thickness']);
        return Divider(
          height: _nonNegativeDouble(props['height']),
          thickness: dividerThickness,
          indent: _nonNegativeDouble(props['indent']),
          endIndent: _nonNegativeDouble(props['endIndent']),
          color: _color(props['color'], context),
          radius: _dividerRadius(props, dividerThickness),
        );
      case 'verticaldivider':
        final verticalDividerThickness = _nonNegativeDouble(props['thickness']);
        return VerticalDivider(
          width: _nonNegativeDouble(props['width']),
          thickness: verticalDividerThickness,
          indent: _nonNegativeDouble(props['indent']),
          endIndent: _nonNegativeDouble(props['endIndent']),
          color: _color(props['color'], context),
          radius: _dividerRadius(props, verticalDividerThickness),
        );
      case 'chip':
      case 'actionchip':
      case 'filterchip':
      case 'choicechip':
      case 'inputchip':
        return _chip(context, type.toLowerCase(), props);
      case 'text':
        return Text(
          _string(props['data'] ?? props['text']) ?? '',
          style: _textStyle(props['style'], context),
          strutStyle: _strutStyle(props['strutStyle']),
          textAlign: _textAlign(props['textAlign']),
          textDirection: _textDirection(props['textDirection']),
          locale: _locale(props['locale']),
          textScaler: _textScaler(
            props['textScaler'] ?? props['textScaleFactor'],
          ),
          overflow: _textOverflow(props['overflow']),
          maxLines: _positiveInt(props['maxLines']),
          softWrap: _bool(props['softWrap']),
          semanticsLabel: _string(
            props['semanticsLabel'] ?? props['semanticLabel'],
          ),
          semanticsIdentifier: _string(props['semanticsIdentifier']),
          textWidthBasis: _textWidthBasis(props['textWidthBasis']),
          textHeightBehavior: _textHeightBehavior(props['textHeightBehavior']),
          selectionColor: _color(props['selectionColor'], context),
        );
      case 'selectabletext':
        final minLines = _positiveInt(props['minLines']);
        final maxLines = _safeMaxInt(props['maxLines'], minLines);
        return SelectableText(
          _string(props['data'] ?? props['text']) ?? '',
          style: _textStyle(props['style'], context),
          strutStyle: _strutStyle(props['strutStyle']),
          textAlign: _textAlign(props['textAlign']),
          textDirection: _textDirection(props['textDirection']),
          textScaler: _textScaler(
            props['textScaler'] ?? props['textScaleFactor'],
          ),
          minLines: minLines,
          maxLines: maxLines,
          autofocus: _bool(props['autofocus']) ?? false,
          showCursor: _bool(props['showCursor']) ?? false,
          cursorWidth: _positiveDouble(props['cursorWidth']) ?? 2,
          cursorHeight: _positiveDouble(props['cursorHeight']),
          cursorRadius: _nonNegativeRadius(props['cursorRadius']),
          enableInteractiveSelection:
              _bool(props['enableInteractiveSelection']) ?? true,
          cursorColor: _color(props['cursorColor'], context),
          selectionColor: _color(props['selectionColor'], context),
          selectionHeightStyle: _boxHeightStyle(props['selectionHeightStyle']),
          selectionWidthStyle: _boxWidthStyle(props['selectionWidthStyle']),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          scrollPhysics: _scrollPhysics(props),
          semanticsLabel: _string(
            props['semanticsLabel'] ?? props['semanticLabel'],
          ),
          textHeightBehavior: _textHeightBehavior(props['textHeightBehavior']),
          textWidthBasis:
              _textWidthBasis(props['textWidthBasis']) ?? TextWidthBasis.parent,
          selectionControls: _textSelectionControls(
            props['selectionControls'] ?? props['controls'],
          ),
          onSelectionChanged: _selectionChangedCallback(
            props['onSelectionChanged'] ?? props['onSelection'],
          ),
          contextMenuBuilder: _editableTextContextMenuBuilder(props),
          magnifierConfiguration: _textMagnifierConfiguration(
            props['magnifierConfiguration'] ??
                props['magnifier'] ??
                props['enableMagnifier'],
          ),
          onTap: _callback(props['onTap']),
        );
      case 'richtext':
        return RichText(
          text: _inlineSpan(props['text'] ?? props['span'], context),
          textAlign: _textAlign(props['textAlign']) ?? TextAlign.start,
          textDirection: _textDirection(props['textDirection']),
          softWrap: _bool(props['softWrap']) ?? true,
          overflow: _textOverflow(props['overflow']) ?? TextOverflow.clip,
          textScaler:
              _textScaler(props['textScaler'] ?? props['textScaleFactor']) ??
              TextScaler.noScaling,
          maxLines: _positiveInt(props['maxLines']),
          locale: _locale(props['locale']),
          strutStyle: _strutStyle(props['strutStyle']),
          textWidthBasis:
              _textWidthBasis(props['textWidthBasis']) ?? TextWidthBasis.parent,
          textHeightBehavior: _textHeightBehavior(props['textHeightBehavior']),
          selectionColor: _color(props['selectionColor'], context),
        );
      case 'icon':
        return Icon(
          _iconData(props['icon'] ?? props['name']) ?? Icons.help_outline,
          size: _nonNegativeDouble(props['size']),
          fill: _unitDouble(props['fill']),
          weight: _positiveDouble(props['weight']),
          grade: _double(props['grade']),
          opticalSize: _positiveDouble(props['opticalSize']),
          color: _color(props['color'], context),
          shadows: _textShadows(props['shadows'] ?? props['shadow']),
          semanticLabel: _string(
            props['semanticLabel'] ?? props['semanticsLabel'],
          ),
          textDirection: _textDirection(props['textDirection']),
          applyTextScaling: _bool(props['applyTextScaling']),
          blendMode: _blendMode(props['blendMode']),
          fontWeight: _fontWeight(props['fontWeight']),
        );
      case 'image':
        return _image(context, props);
      case 'elevatedbutton':
      case 'filledbutton':
      case 'outlinedbutton':
      case 'textbutton':
        return _button(context, type.toLowerCase(), props);
      case 'cupertinobutton':
        return _cupertinoButton(context, props);
      case 'iconbutton':
        return _iconButton(context, props);
      case 'backbutton':
        return BackButton(
          color: _color(props['color'], context),
          style: _buttonStyle(props['style'] ?? props, context),
          onPressed: _callback(props['onPressed'] ?? props['onTap']),
        );
      case 'closebutton':
        return CloseButton(
          color: _color(props['color'], context),
          style: _buttonStyle(props['style'] ?? props, context),
          onPressed: _callback(props['onPressed'] ?? props['onTap']),
        );
      case 'floatingactionbutton':
        final variant = props['variant']?.toString().toLowerCase();
        final icon = _optionalWidget(context, props['icon']);
        final label = _optionalWidget(context, props['label']);
        final child = _child(context, props);
        final onPressed = _callback(props['onPressed'] ?? props['onTap']);
        final tooltip = _string(props['tooltip']);
        final foregroundColor = _color(props['foregroundColor'], context);
        final backgroundColor = _color(props['backgroundColor'], context);
        final focusColor = _color(props['focusColor'], context);
        final hoverColor = _color(props['hoverColor'], context);
        final splashColor = _color(props['splashColor'], context);
        final heroTag = props.containsKey('heroTag')
            ? props['heroTag']
            : const _AppletDefaultFabHeroTag();
        final elevation = _nonNegativeDouble(props['elevation']);
        final focusElevation = _nonNegativeDouble(props['focusElevation']);
        final hoverElevation = _nonNegativeDouble(props['hoverElevation']);
        final highlightElevation = _nonNegativeDouble(
          props['highlightElevation'],
        );
        final disabledElevation = _nonNegativeDouble(
          props['disabledElevation'],
        );
        final mouseCursor = _mouseCursorOrNull(
          props['mouseCursor'] ?? props['cursor'],
        );
        final shape = _outlinedBorder(props['shape'] ?? props);
        final clipBehavior = _clip(props['clipBehavior']) ?? Clip.none;
        final autofocus = _bool(props['autofocus']) ?? false;
        final tapTargetSize = _materialTapTargetSize(
          props['materialTapTargetSize'] ?? props['tapTargetSize'],
        );
        final enableFeedback = _bool(props['enableFeedback']);
        if (variant == 'extended' || label != null) {
          return FloatingActionButton.extended(
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            heroTag: heroTag,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            splashColor: splashColor,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            onPressed: onPressed,
            mouseCursor: mouseCursor,
            shape: shape,
            isExtended: _bool(props['isExtended']) ?? true,
            materialTapTargetSize: tapTargetSize,
            clipBehavior: clipBehavior,
            autofocus: autofocus,
            extendedIconLabelSpacing: _nonNegativeDouble(
              props['extendedIconLabelSpacing'] ?? props['iconLabelSpacing'],
            ),
            extendedPadding: _edgeInsets(props['extendedPadding']),
            extendedTextStyle: _textStyle(props['extendedTextStyle']),
            icon: icon,
            label: label ?? Text(_string(props['text']) ?? ''),
            enableFeedback: enableFeedback,
          );
        }
        if (variant == 'small') {
          return FloatingActionButton.small(
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            heroTag: heroTag,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            onPressed: onPressed,
            mouseCursor: mouseCursor,
            shape: shape,
            clipBehavior: clipBehavior,
            autofocus: autofocus,
            materialTapTargetSize: tapTargetSize,
            enableFeedback: enableFeedback,
            child: child,
          );
        }
        if (variant == 'large') {
          return FloatingActionButton.large(
            tooltip: tooltip,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashColor: splashColor,
            heroTag: heroTag,
            elevation: elevation,
            focusElevation: focusElevation,
            hoverElevation: hoverElevation,
            highlightElevation: highlightElevation,
            disabledElevation: disabledElevation,
            onPressed: onPressed,
            mouseCursor: mouseCursor,
            shape: shape,
            clipBehavior: clipBehavior,
            autofocus: autofocus,
            materialTapTargetSize: tapTargetSize,
            enableFeedback: enableFeedback,
            child: child,
          );
        }
        return FloatingActionButton(
          tooltip: tooltip,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          splashColor: splashColor,
          heroTag: heroTag,
          elevation: elevation,
          focusElevation: focusElevation,
          hoverElevation: hoverElevation,
          highlightElevation: highlightElevation,
          disabledElevation: disabledElevation,
          onPressed: onPressed,
          mouseCursor: mouseCursor,
          mini: _bool(props['mini']) ?? false,
          shape: shape,
          clipBehavior: clipBehavior,
          autofocus: autofocus,
          materialTapTargetSize: tapTargetSize,
          isExtended: _bool(props['isExtended']) ?? false,
          enableFeedback: enableFeedback,
          child: child,
        );
      case 'textfield':
      case 'textformfield':
        return _textInput(context, props);
      case 'autocomplete':
        return _autocomplete(context, props);
      case 'cupertinotextfield':
        return _cupertinoTextField(context, props);
      case 'cupertinotextformfieldrow':
        return _cupertinoTextFormFieldRow(context, props);
      case 'cupertinosearchtextfield':
        return _cupertinoSearchTextField(context, props);
      case 'switch':
        return _switch(props);
      case 'switchlisttile':
        return _switchListTile(context, props);
      case 'cupertinoswitch':
        return _cupertinoSwitch(props);
      case 'checkbox':
        return _checkbox(props);
      case 'cupertinocheckbox':
        return _cupertinoCheckbox(props);
      case 'checkboxlisttile':
        return _checkboxListTile(context, props);
      case 'radio':
        return _radio(props);
      case 'cupertinoradio':
        return _cupertinoRadio(props);
      case 'radiolisttile':
        return _radioListTile(context, props);
      case 'slider':
        return _slider(props);
      case 'rangeslider':
        return _rangeSlider(props);
      case 'cupertinoslider':
        return _cupertinoSlider(props);
      case 'dropdownbutton':
        final items = _dropdownItems(
          context,
          props['items'] ?? props['children'],
        );
        return DropdownButton<Object?>(
          value: _matchingDropdownValue(props['value'], items),
          hint: _optionalWidget(context, props['hint']),
          disabledHint: _optionalWidget(context, props['disabledHint']),
          isDense: _bool(props['isDense']) ?? false,
          isExpanded: _bool(props['isExpanded']) ?? false,
          itemHeight: _dropdownItemHeight(props['itemHeight']),
          menuWidth: _double(props['menuWidth']),
          menuMaxHeight: _double(props['menuMaxHeight']),
          elevation: _int(props['elevation']) ?? 8,
          style: _textStyle(props['style'] ?? props['textStyle']),
          underline: _optionalWidget(context, props['underline']),
          icon: _optionalWidget(context, props['icon']),
          iconDisabledColor: _color(props['iconDisabledColor']),
          iconEnabledColor: _color(props['iconEnabledColor']),
          iconSize: _double(props['iconSize']) ?? 24,
          focusColor: _color(props['focusColor']),
          autofocus: _bool(props['autofocus']) ?? false,
          dropdownColor: _color(props['dropdownColor']),
          enableFeedback: _bool(props['enableFeedback']),
          alignment:
              _alignment(props['alignment']) ??
              AlignmentDirectional.centerStart,
          borderRadius: _borderRadius(props['borderRadius'] ?? props['radius']),
          padding: _edgeInsets(props['padding']),
          barrierDismissible: _bool(props['barrierDismissible']) ?? true,
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          dropdownMenuItemMouseCursor: _mouseCursorOrNull(
            props['dropdownMenuItemMouseCursor'] ?? props['itemCursor'],
          ),
          items: items,
          onTap: _callback(props['onTap']),
          onChanged: (_bool(props['enabled']) ?? true)
              ? _objectCallback(props['onChanged'])
              : null,
        );
      case 'dropdownmenu':
        final entries = _dropdownMenuEntries(
          context,
          props['dropdownMenuEntries'] ?? props['entries'] ?? props['items'],
        );
        final initialSelection = _matchingDropdownMenuValue(
          props['initialSelection'] ?? props['value'],
          entries,
        );
        return DropdownMenu<Object?>(
          enabled: _bool(props['enabled']) ?? true,
          width: _double(props['width']),
          menuHeight: _double(props['menuHeight']),
          leadingIcon: _optionalWidget(
            context,
            props['leadingIcon'] ?? props['prefixIcon'],
          ),
          trailingIcon: _optionalWidget(
            context,
            props['trailingIcon'] ?? props['suffixIcon'],
          ),
          showTrailingIcon: _bool(props['showTrailingIcon']) ?? true,
          label: _optionalWidget(context, props['label']),
          hintText: _string(props['hintText'] ?? props['hint']),
          helperText: _string(props['helperText']),
          errorText: _string(props['errorText']),
          selectedTrailingIcon: _optionalWidget(
            context,
            props['selectedTrailingIcon'],
          ),
          enableFilter: _bool(props['enableFilter']) ?? false,
          enableSearch: _bool(props['enableSearch']) ?? true,
          keyboardType: _keyboardType(props['keyboardType']),
          textStyle: _textStyle(props['textStyle'] ?? props['style']),
          textAlign: _textAlign(props['textAlign']) ?? TextAlign.start,
          inputDecorationTheme: _inputDecorationThemeData(
            props['inputDecorationTheme'] ?? props['decoration'],
          ),
          menuStyle: _menuStyle(props['menuStyle'], context),
          initialSelection: initialSelection,
          onSelected: (_bool(props['enabled']) ?? true)
              ? _objectCallback(props['onSelected'] ?? props['onChanged'])
              : null,
          requestFocusOnTap: _bool(props['requestFocusOnTap']),
          selectOnly: _bool(props['selectOnly']) ?? false,
          expandedInsets: _edgeInsets(props['expandedInsets']),
          alignmentOffset: _offset(props['alignmentOffset']),
          dropdownMenuEntries: entries,
          closeBehavior:
              _dropdownMenuCloseBehavior(props['closeBehavior']) ??
              DropdownMenuCloseBehavior.all,
          maxLines: _int(props['maxLines']) ?? 1,
          textInputAction: _textInputAction(props['textInputAction']),
          cursorHeight: _double(props['cursorHeight']),
          restorationId: _string(props['restorationId']),
          scrollPadding:
              _edgeInsetsOnly(props['scrollPadding']) ??
              const EdgeInsets.all(20),
        );
      case 'popupmenubutton':
        final child = _optionalWidget(context, props['child']);
        return PopupMenuButton<Object?>(
          initialValue: props['initialValue'] ?? props['value'],
          onOpened: _callback(props['onOpened'] ?? props['onOpen']),
          onSelected: _objectValueCallback(props['onSelected']),
          onCanceled: _callback(props['onCanceled'] ?? props['onCancel']),
          tooltip: _string(props['tooltip']),
          elevation: _double(props['elevation']),
          shadowColor: _color(props['shadowColor'], context),
          surfaceTintColor: _color(props['surfaceTintColor'], context),
          padding: _edgeInsets(props['padding']) ?? const EdgeInsets.all(8),
          menuPadding: _edgeInsets(props['menuPadding']),
          borderRadius: _borderRadius(props['borderRadius'] ?? props['radius']),
          splashRadius: _double(props['splashRadius']),
          icon: child == null ? _optionalWidget(context, props['icon']) : null,
          iconSize: _double(props['iconSize']),
          offset: _offset(props['offset']) ?? Offset.zero,
          enabled: _bool(props['enabled']) ?? true,
          shape: _outlinedBorder(props['shape'] ?? props),
          color: _color(props['color'] ?? props['backgroundColor'], context),
          iconColor: _color(props['iconColor'], context),
          enableFeedback: _bool(props['enableFeedback']),
          constraints: _boxConstraints(props['constraints']),
          position: _popupMenuPosition(props['position']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          useRootNavigator: _bool(props['useRootNavigator']) ?? false,
          popUpAnimationStyle: _animationStyle(
            props['popUpAnimationStyle'] ?? props['animationStyle'],
          ),
          style: _buttonStyle(props['style'], context),
          requestFocus: _bool(props['requestFocus']),
          itemBuilder: (context) =>
              _popupMenuItems(context, props['items'] ?? props['children']),
          child: child,
        );
      case 'menubar':
        return MenuBar(
          style: _menuStyle(props['style'] ?? props['menuStyle'], context),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          children: _menuBarChildren(context, props['children']),
        );
      case 'menuanchor':
        final child = _maybeChild(context, props);
        return MenuAnchor(
          style: _menuStyle(props['style'] ?? props['menuStyle'], context),
          menuChildren: buildWidgets(
            context,
            props['menuChildren'] ?? props['items'],
          ),
          alignmentOffset: _offset(props['alignmentOffset']),
          reservedPadding: _edgeInsets(props['reservedPadding']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          consumeOutsideTap: _bool(props['consumeOutsideTap']) ?? false,
          crossAxisUnconstrained:
              _bool(props['crossAxisUnconstrained']) ?? true,
          useRootOverlay: _bool(props['useRootOverlay']) ?? false,
          animated: _bool(props['animated']) ?? false,
          onOpen: _callback(props['onOpen']),
          onClose: _callback(props['onClose']),
          builder: (_bool(props['passive']) ?? false)
              ? null
              : (context, controller, child) {
                  final anchorChild = child ?? _label(context, props);
                  return InkWell(
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: anchorChild,
                  );
                },
          child: child,
        );
      case 'menuitembutton':
        return MenuItemButton(
          onPressed: _callback(props['onPressed'] ?? props['onTap']),
          onHover: _valueCallback(props['onHover']),
          requestFocusOnHover: _bool(props['requestFocusOnHover']) ?? true,
          onFocusChange: _valueCallback(props['onFocusChange']),
          autofocus: _bool(props['autofocus']) ?? false,
          semanticsLabel: _string(props['semanticsLabel']),
          leadingIcon: _optionalWidget(context, props['leadingIcon']),
          trailingIcon: _optionalWidget(context, props['trailingIcon']),
          closeOnActivate: _bool(props['closeOnActivate']) ?? true,
          overflowAxis: _axis(props['overflowAxis']) ?? Axis.horizontal,
          style: _buttonStyle(props['style'] ?? props, context),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          child:
              _optionalWidget(context, props['child']) ??
              _label(context, props),
        );
      case 'checkboxmenubutton':
        return CheckboxMenuButton(
          value:
              _bool(props['value']) ??
              ((_bool(props['tristate']) ?? false) ? null : false),
          tristate: _bool(props['tristate']) ?? false,
          isError: _bool(props['isError']) ?? false,
          onChanged: _nullableBoolCallback(
            props['onChanged'] ?? props['onTap'],
          ),
          onHover: _valueCallback(props['onHover']),
          onFocusChange: _valueCallback(props['onFocusChange']),
          trailingIcon: _optionalWidget(context, props['trailingIcon']),
          closeOnActivate: _bool(props['closeOnActivate']) ?? true,
          style: _buttonStyle(props['style'] ?? props, context),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          child:
              _optionalWidget(context, props['child']) ??
              _label(context, props),
        );
      case 'radiomenubutton':
        return RadioMenuButton<Object?>(
          value: props['value'],
          groupValue: props['groupValue'],
          toggleable: _bool(props['toggleable']) ?? false,
          onChanged: _objectCallback(props['onChanged'] ?? props['onTap']),
          onHover: _valueCallback(props['onHover']),
          onFocusChange: _valueCallback(props['onFocusChange']),
          trailingIcon: _optionalWidget(context, props['trailingIcon']),
          closeOnActivate: _bool(props['closeOnActivate']) ?? true,
          style: _buttonStyle(props['style'] ?? props, context),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          child:
              _optionalWidget(context, props['child']) ??
              _label(context, props),
        );
      case 'submenubutton':
        return SubmenuButton(
          menuChildren: buildWidgets(
            context,
            props['menuChildren'] ?? props['children'],
          ),
          leadingIcon: _optionalWidget(context, props['leadingIcon']),
          trailingIcon: _optionalWidget(context, props['trailingIcon']),
          submenuIcon: _state(_optionalWidget(context, props['submenuIcon'])),
          onHover: _valueCallback(props['onHover']),
          onFocusChange: _valueCallback(props['onFocusChange']),
          style: _buttonStyle(props['style'] ?? props, context),
          menuStyle: _menuStyle(props['menuStyle'], context),
          alignmentOffset: _offset(props['alignmentOffset']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          useRootOverlay: _bool(props['useRootOverlay']) ?? false,
          hoverOpenDelay: _duration(props['hoverOpenDelay']) ?? Duration.zero,
          animated: _bool(props['animated']) ?? false,
          onOpen: _callback(props['onOpen']),
          onClose: _callback(props['onClose']),
          child:
              _optionalWidget(context, props['child']) ??
              _label(context, props),
        );
      case 'linearprogressindicator':
        return _linearProgressIndicator(props);
      case 'circularprogressindicator':
        return _circularProgressIndicator(props);
      case 'cupertinoactivityindicator':
        return _cupertinoActivityIndicator(props);
      case 'refreshindicator':
        return _refreshIndicator(context, props);
      case 'alertdialog':
        final icon = _optionalWidget(context, props['icon']);
        final title = _optionalWidget(context, props['title']);
        final content = _optionalWidget(
          context,
          props['content'] ?? props['child'],
        );
        final actions = buildWidgets(context, props['actions']);
        final insetPadding = _edgeInsetsOnly(props['insetPadding']);
        if (_bool(props['adaptive']) ?? false) {
          return AlertDialog.adaptive(
            icon: icon,
            iconPadding: _edgeInsets(props['iconPadding']),
            iconColor: _color(props['iconColor']),
            title: title,
            titlePadding: _edgeInsets(props['titlePadding']),
            titleTextStyle: _textStyle(props['titleTextStyle']),
            content: content,
            contentPadding: _edgeInsets(props['contentPadding']),
            contentTextStyle: _textStyle(props['contentTextStyle']),
            actions: actions,
            actionsPadding: _edgeInsets(props['actionsPadding']),
            actionsAlignment: _mainAxisAlignment(props['actionsAlignment']),
            actionsOverflowAlignment: _overflowBarAlignment(
              props['actionsOverflowAlignment'],
            ),
            actionsOverflowDirection: _verticalDirection(
              props['actionsOverflowDirection'],
            ),
            actionsOverflowButtonSpacing: _nonNegativeDouble(
              props['actionsOverflowButtonSpacing'],
            ),
            buttonPadding: _edgeInsets(props['buttonPadding']),
            backgroundColor: _color(props['backgroundColor']),
            surfaceTintColor: _color(props['surfaceTintColor']),
            elevation: _nonNegativeDouble(props['elevation']),
            shadowColor: _color(props['shadowColor']),
            semanticLabel: _string(props['semanticLabel']),
            insetPadding:
                insetPadding ??
                const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            clipBehavior: _clip(props['clipBehavior']),
            shape: _outlinedBorder(props['shape'] ?? props),
            alignment: _alignment(props['alignment']),
            constraints: _boxConstraints(props['constraints']),
            scrollable: _bool(props['scrollable']) ?? false,
            insetAnimationDuration:
                _duration(props['insetAnimationDuration']) ??
                const Duration(milliseconds: 100),
            insetAnimationCurve:
                _curve(props['insetAnimationCurve']) ?? Curves.decelerate,
          );
        }
        return AlertDialog(
          icon: icon,
          iconPadding: _edgeInsets(props['iconPadding']),
          iconColor: _color(props['iconColor']),
          title: title,
          titlePadding: _edgeInsets(props['titlePadding']),
          titleTextStyle: _textStyle(props['titleTextStyle']),
          content: content,
          contentPadding: _edgeInsets(props['contentPadding']),
          contentTextStyle: _textStyle(props['contentTextStyle']),
          actions: actions,
          actionsPadding: _edgeInsets(props['actionsPadding']),
          actionsAlignment: _mainAxisAlignment(props['actionsAlignment']),
          actionsOverflowAlignment: _overflowBarAlignment(
            props['actionsOverflowAlignment'],
          ),
          actionsOverflowDirection: _verticalDirection(
            props['actionsOverflowDirection'],
          ),
          actionsOverflowButtonSpacing: _nonNegativeDouble(
            props['actionsOverflowButtonSpacing'],
          ),
          buttonPadding: _edgeInsets(props['buttonPadding']),
          backgroundColor: _color(props['backgroundColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          semanticLabel: _string(props['semanticLabel']),
          insetPadding: insetPadding,
          clipBehavior: _clip(props['clipBehavior']),
          shape: _outlinedBorder(props['shape'] ?? props),
          alignment: _alignment(props['alignment']),
          constraints: _boxConstraints(props['constraints']),
          scrollable: _bool(props['scrollable']) ?? false,
        );
      case 'dialog':
        if ((_bool(props['fullscreen']) ?? false) ||
            props['variant']?.toString().toLowerCase() == 'fullscreen') {
          return Dialog.fullscreen(
            backgroundColor: _color(props['backgroundColor']),
            insetAnimationDuration:
                _duration(props['insetAnimationDuration']) ?? Duration.zero,
            insetAnimationCurve:
                _curve(props['insetAnimationCurve']) ?? Curves.decelerate,
            semanticsRole:
                _semanticsRole(props['semanticsRole']) ??
                ui.SemanticsRole.dialog,
            child: _child(context, props),
          );
        }
        return Dialog(
          backgroundColor: _color(props['backgroundColor']),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          insetAnimationDuration:
              _duration(props['insetAnimationDuration']) ??
              const Duration(milliseconds: 100),
          insetAnimationCurve:
              _curve(props['insetAnimationCurve']) ?? Curves.decelerate,
          insetPadding: _edgeInsets(props['insetPadding']) as EdgeInsets?,
          clipBehavior: _clip(props['clipBehavior']),
          shape: _outlinedBorder(props['shape'] ?? props),
          alignment: _alignment(props['alignment']),
          constraints: _boxConstraints(props['constraints']),
          semanticsRole:
              _semanticsRole(props['semanticsRole']) ?? ui.SemanticsRole.dialog,
          child: _child(context, props),
        );
      case 'bottomsheet':
        return _bottomSheet(context, props);
      case 'simpledialog':
        return SimpleDialog(
          title: _optionalWidget(context, props['title']),
          titlePadding:
              _edgeInsets(props['titlePadding']) ??
              const EdgeInsets.fromLTRB(24, 24, 24, 0),
          titleTextStyle: _textStyle(props['titleTextStyle']),
          contentPadding:
              _edgeInsets(props['contentPadding']) ??
              const EdgeInsets.fromLTRB(0, 12, 0, 16),
          contentTextStyle: _textStyle(props['contentTextStyle']),
          backgroundColor: _color(props['backgroundColor']),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          semanticLabel: _string(props['semanticLabel']),
          insetPadding: _edgeInsets(props['insetPadding']) as EdgeInsets?,
          clipBehavior: _clip(props['clipBehavior']),
          shape: _outlinedBorder(props['shape'] ?? props),
          alignment: _alignment(props['alignment']),
          constraints: _boxConstraints(props['constraints']),
          children: buildWidgets(context, props['children']),
        );
      case 'snackbar':
        return _snackBar(context, props);
      case 'datepickerdialog':
        return DatePickerDialog(
          initialDate: _dateTime(props['initialDate']) ?? DateTime.now(),
          firstDate: _dateTime(props['firstDate']) ?? DateTime(1900),
          lastDate: _dateTime(props['lastDate']) ?? DateTime(2100),
          helpText: _string(props['helpText']),
          cancelText: _string(props['cancelText']),
          confirmText: _string(props['confirmText']),
          initialEntryMode:
              _datePickerEntryMode(props['initialEntryMode']) ??
              DatePickerEntryMode.calendar,
        );
      case 'timepickerdialog':
        return TimePickerDialog(
          initialTime: _timeOfDay(props['initialTime']) ?? TimeOfDay.now(),
          helpText: _string(props['helpText']),
          cancelText: _string(props['cancelText']),
          confirmText: _string(props['confirmText']),
          initialEntryMode:
              _timePickerEntryMode(props['initialEntryMode']) ??
              TimePickerEntryMode.dial,
        );
      case 'searchbar':
        return _searchBar(context, props);
      case 'searchanchor':
        return _searchAnchor(context, props);
      case 'navigationbar':
        final destinations = buildWidgets(
          context,
          props['destinations'] ?? props['children'],
        );
        if (destinations.length < 2) {
          return const SizedBox.shrink();
        }
        return NavigationBar(
          animationDuration: _duration(props['animationDuration']),
          selectedIndex: _clampedIndex(props['selectedIndex'], destinations),
          onDestinationSelected: _intCallback(
            props['onDestinationSelected'] ?? props['onChanged'],
          ),
          destinations: destinations,
          backgroundColor: _color(props['backgroundColor']),
          elevation: _double(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          indicatorColor: _color(props['indicatorColor']),
          indicatorShape: _outlinedBorder(props['indicatorShape']),
          height: _double(props['height']),
          labelBehavior: _navigationDestinationLabelBehavior(
            props['labelBehavior'],
          ),
          overlayColor: _stateColor(props['overlayColor']),
          labelTextStyle: _stateProperty<TextStyle>(
            props['labelTextStyle'],
            _textStyle,
          ),
          labelPadding: _edgeInsets(props['labelPadding']),
          maintainBottomViewPadding:
              _bool(props['maintainBottomViewPadding']) ?? false,
        );
      case 'navigationdestination':
        return NavigationDestination(
          icon: _iconWidget(context, props['icon']),
          selectedIcon: _optionalWidget(context, props['selectedIcon']),
          label: _string(props['label']) ?? '',
          tooltip: _string(props['tooltip']),
          enabled: _bool(props['enabled']) ?? true,
        );
      case 'navigationrail':
        final extended = _bool(props['extended']) ?? false;
        final destinations = _navigationRailDestinations(
          context,
          props['destinations'] ?? props['children'],
        );
        final minWidth = _positiveDouble(props['minWidth']);
        final rawMinExtendedWidth = _positiveDouble(props['minExtendedWidth']);
        final minExtendedWidth = rawMinExtendedWidth == null || minWidth == null
            ? rawMinExtendedWidth
            : math.max(rawMinExtendedWidth, minWidth);
        return NavigationRail(
          selectedIndex: _clampedOptionalIndex(
            props['selectedIndex'],
            destinations,
          ),
          onDestinationSelected: _intCallback(
            props['onDestinationSelected'] ?? props['onChanged'],
          ),
          destinations: destinations,
          extended: extended,
          labelType: extended
              ? null
              : _navigationRailLabelType(props['labelType']),
          backgroundColor: _color(props['backgroundColor']),
          leading: _optionalWidget(context, props['leading']),
          trailing: _optionalWidget(context, props['trailing']),
          elevation: _positiveDouble(props['elevation']),
          groupAlignment: _double(props['groupAlignment']),
          unselectedLabelTextStyle: _textStyle(props['unselectedLabelStyle']),
          selectedLabelTextStyle: _textStyle(props['selectedLabelStyle']),
          unselectedIconTheme: _nullableIconThemeData(
            props['unselectedIconTheme'],
          ),
          selectedIconTheme: _nullableIconThemeData(props['selectedIconTheme']),
          minWidth: minWidth,
          minExtendedWidth: minExtendedWidth,
          useIndicator: _bool(props['useIndicator']),
          indicatorColor: _color(props['indicatorColor']),
          indicatorShape: _outlinedBorder(props['indicatorShape']),
          leadingAtTop: _bool(props['leadingAtTop']) ?? true,
          trailingAtBottom: _bool(props['trailingAtBottom']) ?? false,
          scrollable: _bool(props['scrollable']) ?? false,
          mainAxisAlignment: _mainAxisAlignment(props['mainAxisAlignment']),
        );
      case 'navigationraildestination':
        return const SizedBox.shrink();
      case 'navigationdrawer':
        return NavigationDrawer(
          selectedIndex: _int(props['selectedIndex']),
          onDestinationSelected: _intCallback(
            props['onDestinationSelected'] ?? props['onChanged'],
          ),
          header: _optionalWidget(context, props['header']),
          footer: _optionalWidget(context, props['footer']),
          backgroundColor: _color(props['backgroundColor']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          elevation: _double(props['elevation']),
          indicatorColor: _color(props['indicatorColor']),
          indicatorShape: _outlinedBorder(props['indicatorShape']),
          tilePadding:
              _edgeInsets(props['tilePadding']) ??
              const EdgeInsets.symmetric(horizontal: 12),
          children: buildWidgets(context, props['children']),
        );
      case 'navigationdrawerdestination':
        return NavigationDrawerDestination(
          backgroundColor: _color(props['backgroundColor']),
          icon: _iconWidget(context, props['icon']),
          selectedIcon: _optionalWidget(context, props['selectedIcon']),
          label: _label(context, props),
          enabled: _bool(props['enabled']) ?? true,
        );
      case 'bottomnavigationbar':
        final items = _bottomNavigationItems(
          props['items'] ?? props['children'],
        );
        if (items.length < 2) {
          return const SizedBox.shrink();
        }
        final selectedIconTheme = _nullableIconThemeData(
          props['selectedIconTheme'],
        );
        final unselectedIconTheme = _nullableIconThemeData(
          props['unselectedIconTheme'],
        );
        return BottomNavigationBar(
          currentIndex: _clampedIndex(
            props['currentIndex'] ?? props['selectedIndex'],
            items,
          ),
          onTap: _intCallback(
            props['onTap'] ??
                props['onChanged'] ??
                props['onDestinationSelected'],
          ),
          elevation: _nonNegativeDouble(props['elevation']),
          type: _bottomNavigationBarType(props['barType'] ?? props['type']),
          backgroundColor: _color(props['backgroundColor']),
          iconSize: _nonNegativeDouble(props['iconSize']) ?? 24,
          selectedItemColor: _color(
            props['selectedItemColor'] ?? props['fixedColor'],
          ),
          unselectedItemColor: _color(props['unselectedItemColor']),
          selectedIconTheme:
              selectedIconTheme != null && unselectedIconTheme != null
              ? selectedIconTheme
              : null,
          unselectedIconTheme:
              selectedIconTheme != null && unselectedIconTheme != null
              ? unselectedIconTheme
              : null,
          selectedFontSize: _nonNegativeDouble(props['selectedFontSize']) ?? 14,
          unselectedFontSize:
              _nonNegativeDouble(props['unselectedFontSize']) ?? 12,
          selectedLabelStyle: _textStyle(props['selectedLabelStyle']),
          unselectedLabelStyle: _textStyle(props['unselectedLabelStyle']),
          showSelectedLabels: _bool(props['showSelectedLabels']),
          showUnselectedLabels: _bool(props['showUnselectedLabels']),
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          enableFeedback: _bool(props['enableFeedback']),
          landscapeLayout: _bottomNavigationBarLandscapeLayout(
            props['landscapeLayout'],
          ),
          useLegacyColorScheme: _bool(props['useLegacyColorScheme']) ?? true,
          items: items,
        );
      case 'cupertinotabbar':
        final items = _safeCupertinoTabItems(
          _bottomNavigationItems(props['items'] ?? props['children']),
        );
        return cupertino.CupertinoTabBar(
          currentIndex: _safeIndex(
            _int(props['currentIndex'] ?? props['selectedIndex']) ?? 0,
            items.length,
          ),
          onTap: _intCallback(props['onTap'] ?? props['onChanged']),
          items: items,
          backgroundColor: _color(props['backgroundColor'], context),
          activeColor: _color(props['activeColor'], context),
          inactiveColor:
              _color(props['inactiveColor'], context) ??
              cupertino.CupertinoColors.inactiveGray,
          iconSize: _positiveDouble(props['iconSize']) ?? 30,
          height: _positiveDouble(props['height']) ?? 50,
          border: props.containsKey('border')
              ? _borderOrNull(props['border'])
              : _defaultCupertinoTabBarBorder,
        );
      case 'bottomappbar':
        return BottomAppBar(
          color: _color(props['color'], context),
          elevation: _nonNegativeDouble(props['elevation']),
          shape: _notchedShape(props['shape']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          notchMargin: _nonNegativeDouble(props['notchMargin']) ?? 4,
          height: _double(props['height']),
          padding: _edgeInsets(props['padding']),
          surfaceTintColor: _color(props['surfaceTintColor'], context),
          shadowColor: _color(props['shadowColor'], context),
          child: _child(context, props),
        );
      case 'segmentedbutton':
        return _segmentedButton(context, props);
      case 'togglebuttons':
        return _toggleButtons(context, props);
      case 'cupertinosegmentedcontrol':
        return _cupertinoSegmentedControl(context, props);
      case 'cupertinoslidingsegmentedcontrol':
        return _cupertinoSlidingSegmentedControl(context, props);
      case 'defaulttabcontroller':
        final length = math.max(
          1,
          _int(props['length']) ?? _listLength(props['tabs']) ?? 1,
        );
        return DefaultTabController(
          length: length,
          initialIndex: (_int(props['initialIndex']) ?? 0)
              .clamp(0, length - 1)
              .toInt(),
          child: _child(context, props),
        );
      case 'tabbar':
        final tabs = buildWidgets(context, props['tabs'] ?? props['children']);
        if (tabs.isEmpty) {
          return const SizedBox.shrink();
        }
        final padding = _edgeInsets(props['padding']);
        final isScrollable = _bool(props['isScrollable']) ?? false;
        final indicatorColor = _color(props['indicatorColor'], context);
        final automaticIndicatorColorAdjustment =
            _bool(props['automaticIndicatorColorAdjustment']) ?? true;
        final indicatorWeight = _positiveDouble(props['indicatorWeight']) ?? 2;
        final indicatorPadding =
            _edgeInsetsOnly(props['indicatorPadding']) ?? EdgeInsets.zero;
        final indicator = _boxDecoration(props['indicator'], context);
        final indicatorSize = _tabBarIndicatorSize(props['indicatorSize']);
        final dividerColor = _color(props['dividerColor'], context);
        final dividerHeight = _double(props['dividerHeight']);
        final labelColor = _color(props['labelColor'], context);
        final labelStyle = _textStyle(props['labelStyle'], context);
        final labelPadding = _edgeInsets(props['labelPadding']);
        final unselectedLabelColor = _color(
          props['unselectedLabelColor'],
          context,
        );
        final unselectedLabelStyle = _textStyle(
          props['unselectedLabelStyle'],
          context,
        );
        final dragStartBehavior = _dragStartBehavior(
          props['dragStartBehavior'],
        );
        final overlayColor = _stateColor(props['overlayColor'], context);
        final mouseCursor = _mouseCursorOrNull(
          props['mouseCursor'] ?? props['cursor'],
        );
        final enableFeedback = _bool(props['enableFeedback']);
        final onTap = _intCallback(props['onTap']);
        final onHover = _tabValueCallback(props['onHover']);
        final onFocusChange = _tabValueCallback(props['onFocusChange']);
        final physics = _scrollPhysics(props);
        final splashBorderRadius = _borderRadius(props['splashBorderRadius']);
        final tabAlignment = _safeTabAlignment(
          props['tabAlignment'],
          isScrollable,
        );
        final indicatorAnimation = _tabIndicatorAnimation(
          props['indicatorAnimation'],
        );
        if (_bool(props['secondary']) ?? false) {
          return TabBar.secondary(
            tabs: tabs,
            padding: padding,
            isScrollable: isScrollable,
            indicatorColor: indicatorColor,
            automaticIndicatorColorAdjustment:
                automaticIndicatorColorAdjustment,
            indicatorWeight: indicatorWeight,
            indicatorPadding: indicatorPadding,
            indicator: indicator,
            indicatorSize: indicatorSize,
            dividerColor: dividerColor,
            dividerHeight: dividerHeight,
            labelColor: labelColor,
            labelStyle: labelStyle,
            labelPadding: labelPadding,
            unselectedLabelColor: unselectedLabelColor,
            unselectedLabelStyle: unselectedLabelStyle,
            dragStartBehavior: dragStartBehavior,
            overlayColor: overlayColor,
            mouseCursor: mouseCursor,
            enableFeedback: enableFeedback,
            onTap: onTap,
            onHover: onHover,
            onFocusChange: onFocusChange,
            physics: physics,
            splashBorderRadius: splashBorderRadius,
            tabAlignment: tabAlignment,
            indicatorAnimation: indicatorAnimation,
          );
        }
        return TabBar(
          tabs: tabs,
          padding: padding,
          isScrollable: isScrollable,
          indicatorColor: indicatorColor,
          automaticIndicatorColorAdjustment: automaticIndicatorColorAdjustment,
          indicatorWeight: indicatorWeight,
          indicatorPadding: indicatorPadding,
          indicator: indicator,
          indicatorSize: indicatorSize,
          dividerColor: dividerColor,
          dividerHeight: dividerHeight,
          labelColor: labelColor,
          labelStyle: labelStyle,
          labelPadding: labelPadding,
          unselectedLabelColor: unselectedLabelColor,
          unselectedLabelStyle: unselectedLabelStyle,
          dragStartBehavior: dragStartBehavior,
          overlayColor: overlayColor,
          mouseCursor: mouseCursor,
          enableFeedback: enableFeedback,
          onTap: onTap,
          onHover: onHover,
          onFocusChange: onFocusChange,
          physics: physics,
          splashBorderRadius: splashBorderRadius,
          tabAlignment: tabAlignment,
          indicatorAnimation: indicatorAnimation,
        );
      case 'tabbarview':
        final children = buildWidgets(context, props['children']);
        if (children.isEmpty) {
          return const SizedBox.shrink();
        }
        return TabBarView(
          physics: _scrollPhysics(props),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          viewportFraction: _positiveDouble(props['viewportFraction']) ?? 1,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          children: children,
        );
      case 'tab':
        final child = _optionalWidget(context, props['child']);
        return Tab(
          text: child == null ? _string(props['text']) : null,
          icon: _optionalWidget(context, props['icon']),
          iconMargin:
              _edgeInsets(props['iconMargin']) ??
              const EdgeInsets.only(bottom: 10),
          height: _positiveDouble(props['height']),
          child: child,
        );
      case 'stepper':
        final steps = _steps(context, props['steps'] ?? props['children']);
        if (steps.isEmpty) {
          return const SizedBox.shrink();
        }
        final stepIconSize = _safeStepIconSize(
          props['stepIconSize'] ??
              props['stepIconHeight'] ??
              props['stepIconWidth'],
        );
        return Stepper(
          currentStep: _clampedIndex(props['currentStep'], steps),
          physics: _scrollPhysics(props),
          type:
              _stepperType(props['stepperType'] ?? props['type']) ??
              StepperType.vertical,
          onStepTapped: _intCallback(props['onStepTapped']),
          onStepContinue: _callback(props['onStepContinue']),
          onStepCancel: _callback(props['onStepCancel']),
          elevation: _nonNegativeDouble(props['elevation']),
          margin: _edgeInsets(props['margin']),
          connectorColor: _stateSolidColor(props['connectorColor']),
          connectorThickness: _nonNegativeDouble(props['connectorThickness']),
          stepIconHeight: stepIconSize,
          stepIconWidth: stepIconSize,
          stepIconMargin: _edgeInsetsOnly(props['stepIconMargin']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          headerPadding: _edgeInsets(props['headerPadding']),
          contentPadding: _edgeInsets(props['contentPadding']),
          steps: steps,
        );
      case 'datatable':
        final columns = _dataColumns(context, props['columns']);
        if (columns.isEmpty) {
          return const SizedBox.shrink();
        }
        final rows = _dataRows(context, props['rows'], columns.length);
        return DataTable(
          columns: columns,
          sortColumnIndex: _clampedOptionalIndex(
            props['sortColumnIndex'],
            columns,
          ),
          sortAscending: _bool(props['sortAscending']) ?? true,
          onSelectAll: _nullableBoolCallback(props['onSelectAll']),
          decoration: _boxDecoration(props['decoration']),
          dataRowColor: _stateColor(props['dataRowColor']),
          dataRowMinHeight:
              _nonNegativeDouble(props['dataRowMinHeight']) ??
              _nonNegativeDouble(props['dataRowHeight']),
          dataRowMaxHeight:
              _safeMaxHeight(
                props['dataRowMaxHeight'],
                props['dataRowMinHeight'],
              ) ??
              _nonNegativeDouble(props['dataRowHeight']),
          dataTextStyle: _dataTableTextStyle(props['dataTextStyle']),
          headingRowColor: _stateColor(props['headingRowColor']),
          headingRowHeight: _nonNegativeDouble(props['headingRowHeight']),
          headingTextStyle: _textStyle(props['headingTextStyle']),
          horizontalMargin: _nonNegativeDouble(props['horizontalMargin']),
          columnSpacing: _nonNegativeDouble(props['columnSpacing']),
          showCheckboxColumn: _bool(props['showCheckboxColumn']) ?? true,
          showBottomBorder: _bool(props['showBottomBorder']) ?? false,
          dividerThickness: _nonNegativeDouble(props['dividerThickness']),
          rows: rows,
          checkboxHorizontalMargin: _nonNegativeDouble(
            props['checkboxHorizontalMargin'],
          ),
          border: _tableBorder(props['border']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
        );
      case 'table':
        final rows = _rectangularTableRows(
          context,
          props['rows'] ?? props['children'],
        );
        final defaultVerticalAlignment =
            _tableCellVerticalAlignment(props['defaultVerticalAlignment']) ??
            TableCellVerticalAlignment.top;
        return Table(
          columnWidths: _tableColumnWidths(props['columnWidths']),
          defaultColumnWidth:
              _tableColumnWidth(props['defaultColumnWidth']) ??
              const FlexColumnWidth(),
          textDirection: _textDirection(props['textDirection']),
          border: _tableBorder(props['border']),
          defaultVerticalAlignment: defaultVerticalAlignment,
          textBaseline:
              _textBaseline(props['textBaseline']) ??
              (defaultVerticalAlignment == TableCellVerticalAlignment.baseline
                  ? TextBaseline.alphabetic
                  : null),
          children: rows,
        );
      case 'carouselview':
        final children = buildWidgets(context, props['children']);
        if (children.isEmpty) {
          return const SizedBox.shrink();
        }
        final flexWeights = _positiveIntList(
          props['flexWeights'] ?? props['weights'],
        );
        if (flexWeights.isNotEmpty) {
          return CarouselView.weighted(
            padding: _edgeInsetsOnly(props['padding']),
            backgroundColor: _color(props['backgroundColor']),
            elevation: _nonNegativeDouble(props['elevation']),
            shape: _outlinedBorder(props['shape']),
            itemClipBehavior: _clip(props['itemClipBehavior']),
            overlayColor: _stateColor(props['overlayColor']),
            itemSnapping: _bool(props['itemSnapping']) ?? false,
            shrinkExtent: _nonNegativeDouble(props['shrinkExtent']) ?? 0,
            scrollDirection: _axis(props['scrollDirection']) ?? Axis.horizontal,
            reverse: _bool(props['reverse']) ?? false,
            consumeMaxWeight: _bool(props['consumeMaxWeight']) ?? true,
            onTap: _intCallback(props['onTap']),
            enableSplash: _bool(props['enableSplash']) ?? true,
            infinite: _bool(props['infinite']) ?? false,
            onIndexChanged: _intCallback(props['onIndexChanged']),
            flexWeights: flexWeights,
            children: children,
          );
        }
        return CarouselView(
          padding: _edgeInsetsOnly(props['padding']),
          backgroundColor: _color(props['backgroundColor']),
          elevation: _nonNegativeDouble(props['elevation']),
          shape: _outlinedBorder(props['shape']),
          itemClipBehavior: _clip(props['itemClipBehavior']),
          overlayColor: _stateColor(props['overlayColor']),
          itemSnapping: _bool(props['itemSnapping']) ?? false,
          shrinkExtent: _nonNegativeDouble(props['shrinkExtent']) ?? 0,
          scrollDirection: _axis(props['scrollDirection']) ?? Axis.horizontal,
          reverse: _bool(props['reverse']) ?? false,
          onTap: _intCallback(props['onTap']),
          enableSplash: _bool(props['enableSplash']) ?? true,
          infinite: _bool(props['infinite']) ?? false,
          itemExtent: _positiveDouble(props['itemExtent']) ?? 320,
          onIndexChanged: _intCallback(props['onIndexChanged']),
          children: children,
        );
      default:
        return ErrorWidget.withDetails(
          message: 'Unknown Applet widget "$type".',
        );
    }
  }

  List<Widget> buildWidgets(BuildContext context, Object? specs) {
    if (specs == null) {
      return const <Widget>[];
    }
    if (specs is List) {
      return specs
          .map((spec) => buildWidget(context, spec))
          .toList(growable: false);
    }
    return <Widget>[buildWidget(context, specs)];
  }

  List<Widget> _menuBarChildren(BuildContext context, Object? specs) {
    if (specs is! List) {
      return buildWidgets(context, specs);
    }
    return specs
        .map((spec) => buildWidget(context, _safeMenuBarChildSpec(spec)))
        .toList(growable: false);
  }

  Object? _safeMenuBarChildSpec(Object? spec) {
    if (spec is! Map) {
      return spec;
    }
    final map = _stringMap(spec);
    final type = (map['type'] ?? map[r'$applet.type'])
        ?.toString()
        .toLowerCase();
    if (type != 'submenubutton') {
      return spec;
    }
    if (map['props'] is Map) {
      final next = Map<String, Object?>.from(map);
      final props = _stringMap(map['props']! as Map);
      props.remove('hoverOpenDelay');
      next['props'] = props;
      return next;
    }
    final next = Map<String, Object?>.from(map);
    next.remove('hoverOpenDelay');
    return next;
  }

  List<Widget> _keyedWidgets(BuildContext context, Object? specs) {
    final list = specs is List ? specs : const <Object?>[];
    return List<Widget>.generate(list.length, (index) {
      final spec = list[index];
      return KeyedSubtree(
        key: _specKey(spec, index),
        child: buildWidget(context, spec),
      );
    }, growable: false);
  }

  Widget _scrollbarChild(BuildContext context, Map<String, Object?> props) {
    return buildWidget(context, _primaryScrollableSpec(props['child']));
  }

  Object? _primaryScrollableSpec(Object? spec) {
    if (spec is! Map) {
      return spec;
    }
    final map = _stringMap(spec);
    final type = (map['type'] ?? map[r'$applet.type'])
        ?.toString()
        .toLowerCase();
    if (type == null) {
      return spec;
    }
    final props = _props(map);
    if (props.containsKey('primary')) {
      return spec;
    }
    final axis = _axis(props['scrollDirection']) ?? Axis.vertical;
    if (axis != Axis.vertical) {
      return spec;
    }
    switch (type) {
      case 'listview':
      case 'gridview':
      case 'customscrollview':
      case 'singlechildscrollview':
        final next = Map<String, Object?>.from(map);
        next['props'] = <String, Object?>{...props, 'primary': true};
        return next;
    }
    return spec;
  }

  Widget _layoutBuilder(BuildContext context, Map<String, Object?> props) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        return buildWidget(
          layoutContext,
          _layoutBuilderSpec(props, constraints),
        );
      },
    );
  }

  Widget _sliverLayoutBuilder(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    return SliverLayoutBuilder(
      builder: (sliverContext, constraints) {
        return buildWidget(
          sliverContext,
          _layoutBuilderSpec(props, _boxConstraintsFromSliver(constraints)),
        );
      },
    );
  }

  Widget _sliverCachedList(BuildContext context, Map<String, Object?> props) {
    final specs = _specList(props['children']);
    final heights = List<double?>.filled(specs.length, null);
    return SliverList(
      delegate: _AppletCachedSliverChildDelegate(
        childCount: specs.length,
        heights: heights,
        addAutomaticKeepAlives: _bool(props['addAutomaticKeepAlives']) ?? true,
        addRepaintBoundaries: _bool(props['addRepaintBoundaries']) ?? true,
        addSemanticIndexes: _bool(props['addSemanticIndexes']) ?? true,
        builder: (itemContext, index) => _AppletCacheHeight(
          heights: heights,
          index: index,
          child: buildWidget(itemContext, specs[index]),
        ),
      ),
    );
  }

  List<Object?> _specList(Object? specs) {
    if (specs == null) {
      return const <Object?>[];
    }
    if (specs is List) {
      return specs.cast<Object?>().toList(growable: false);
    }
    return <Object?>[specs];
  }

  BoxConstraints _boxConstraintsFromSliver(SliverConstraints constraints) {
    final crossAxisExtent = constraints.crossAxisExtent;
    final viewportMainAxisExtent = constraints.viewportMainAxisExtent;
    return BoxConstraints(
      maxWidth: crossAxisExtent.isFinite ? crossAxisExtent : double.infinity,
      maxHeight: viewportMainAxisExtent.isFinite
          ? viewportMainAxisExtent
          : double.infinity,
    );
  }

  Widget _orientationBuilder(BuildContext context, Map<String, Object?> props) {
    return OrientationBuilder(
      builder: (orientationContext, orientation) {
        return buildWidget(
          orientationContext,
          _orientationBuilderSpec(props, orientation),
        );
      },
    );
  }

  Object? _orientationBuilderSpec(
    Map<String, Object?> props,
    Orientation orientation,
  ) {
    final fromVariants = _orientationVariantSpec(
      props['variants'] ?? props['layouts'] ?? props['breakpoints'],
      orientation,
    );
    if (fromVariants != null) {
      return fromVariants;
    }

    final keys = orientation == Orientation.landscape
        ? const <String>['landscape', 'horizontal', 'wide', 'child']
        : const <String>['portrait', 'vertical', 'tall', 'child'];
    for (final key in keys) {
      if (props.containsKey(key) && props[key] != null) {
        return props[key];
      }
    }
    return props['fallback'] ?? props['default'] ?? props['child'];
  }

  Object? _orientationVariantSpec(Object? value, Orientation orientation) {
    if (value is List) {
      for (final item in value) {
        final spec = _orientationVariantItemSpec(item, orientation);
        if (spec != null) {
          return spec;
        }
      }
    }
    if (value is Map) {
      final map = _stringMap(value);
      final names = orientation == Orientation.landscape
          ? const <String>['landscape', 'horizontal', 'wide']
          : const <String>['portrait', 'vertical', 'tall'];
      for (final name in names) {
        if (map.containsKey(name) && map[name] != null) {
          return map[name];
        }
      }
    }
    return null;
  }

  Object? _orientationVariantItemSpec(Object? value, Orientation orientation) {
    if (value is! Map) {
      return null;
    }
    final props = _props(_stringMap(value));
    final orientationName = _string(props['orientation'] ?? props['mode']);
    if (orientationName != null &&
        !_orientationNameMatches(orientationName, orientation)) {
      return null;
    }
    if (orientationName == null && _bool(props['default']) != true) {
      return null;
    }
    return props['child'] ??
        props['view'] ??
        props['layout'] ??
        props['content'];
  }

  bool _orientationNameMatches(String name, Orientation orientation) {
    final normalized = name.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
    return switch (normalized) {
      'landscape' ||
      'horizontal' ||
      'wide' => orientation == Orientation.landscape,
      'portrait' || 'vertical' || 'tall' => orientation == Orientation.portrait,
      _ => false,
    };
  }

  Object? _layoutBuilderSpec(
    Map<String, Object?> props,
    BoxConstraints constraints,
  ) {
    final fromBreakpoints = _layoutBreakpointSpec(
      props['breakpoints'] ?? props['variants'] ?? props['layouts'],
      constraints,
    );
    if (fromBreakpoints != null) {
      return fromBreakpoints;
    }

    final widthClass = _layoutWidthClass(constraints);
    Iterable<String> keys;
    switch (widthClass) {
      case 'extraLarge':
        keys = const <String>[
          'extraLarge',
          'extra_large',
          'xlarge',
          'xl',
          'large',
          'expanded',
          'wide',
          'medium',
          'compact',
          'small',
          'mobile',
          'child',
        ];
      case 'large':
        keys = const <String>[
          'large',
          'expanded',
          'wide',
          'medium',
          'compact',
          'small',
          'mobile',
          'child',
        ];
      case 'expanded':
        keys = const <String>[
          'expanded',
          'wide',
          'medium',
          'compact',
          'small',
          'mobile',
          'child',
        ];
      case 'medium':
        keys = const <String>[
          'medium',
          'tablet',
          'compact',
          'small',
          'mobile',
          'child',
        ];
      default:
        keys = const <String>['compact', 'small', 'mobile', 'child'];
    }
    for (final key in keys) {
      if (props.containsKey(key) && props[key] != null) {
        return props[key];
      }
    }
    return props['fallback'] ?? props['default'] ?? props['child'];
  }

  Object? _layoutBreakpointSpec(Object? value, BoxConstraints constraints) {
    if (value is List) {
      for (final item in value) {
        final spec = _layoutBreakpointItemSpec(item, constraints);
        if (spec != null) {
          return spec;
        }
      }
    }
    if (value is Map) {
      final map = _stringMap(value);
      for (final entry in map.entries) {
        if (_matchesLayoutClass(entry.key, constraints)) {
          return entry.value;
        }
      }
    }
    return null;
  }

  Object? _layoutBreakpointItemSpec(Object? value, BoxConstraints constraints) {
    if (value is! Map) {
      return null;
    }
    final props = _props(_stringMap(value));
    if (!_matchesLayoutBreakpoint(props, constraints)) {
      return null;
    }
    return props['child'] ??
        props['view'] ??
        props['layout'] ??
        props['content'];
  }

  bool _matchesLayoutClass(String key, BoxConstraints constraints) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
    return switch (normalized) {
      'small' ||
      'compact' ||
      'mobile' => _layoutWidthClass(constraints) == 'compact',
      'medium' || 'tablet' => _layoutWidthClass(constraints) == 'medium',
      'expanded' || 'wide' => _layoutWidthClass(constraints) == 'expanded',
      'large' => _layoutWidthClass(constraints) == 'large',
      'extralarge' ||
      'xlarge' ||
      'xl' => _layoutWidthClass(constraints) == 'extraLarge',
      _ => false,
    };
  }

  bool _matchesLayoutBreakpoint(
    Map<String, Object?> props,
    BoxConstraints constraints,
  ) {
    var hasCondition = false;
    bool checkMin(String key, double value) {
      final limit = _double(props[key]);
      if (limit == null) {
        return true;
      }
      hasCondition = true;
      return value >= limit;
    }

    bool checkMax(String key, double value) {
      final limit = _double(props[key]);
      if (limit == null) {
        return true;
      }
      hasCondition = true;
      return value < limit;
    }

    final width = _constraintWidth(constraints);
    final height = _constraintHeight(constraints);
    final orientation = _string(props['orientation']);
    if (orientation != null) {
      hasCondition = true;
      final landscape = width >= height;
      if (orientation.toLowerCase() == 'landscape' && !landscape) {
        return false;
      }
      if (orientation.toLowerCase() == 'portrait' && landscape) {
        return false;
      }
    }
    return checkMin('minWidth', width) &&
        checkMax('maxWidth', width) &&
        checkMin('minHeight', height) &&
        checkMax('maxHeight', height) &&
        (hasCondition || props.containsKey('default'));
  }

  String _layoutWidthClass(BoxConstraints constraints) {
    final width = _constraintWidth(constraints);
    if (width >= 1600) {
      return 'extraLarge';
    }
    if (width >= 1200) {
      return 'large';
    }
    if (width >= 840) {
      return 'expanded';
    }
    if (width >= 600) {
      return 'medium';
    }
    return 'compact';
  }

  double _constraintWidth(BoxConstraints constraints) {
    if (constraints.maxWidth.isFinite) {
      return constraints.maxWidth;
    }
    if (constraints.minWidth.isFinite) {
      return constraints.minWidth;
    }
    return double.infinity;
  }

  double _constraintHeight(BoxConstraints constraints) {
    if (constraints.maxHeight.isFinite) {
      return constraints.maxHeight;
    }
    if (constraints.minHeight.isFinite) {
      return constraints.minHeight;
    }
    return double.infinity;
  }

  Widget _slider(Map<String, Object?> props) {
    final bounds = _sliderBounds(props);
    final min = bounds.min;
    final max = bounds.max;
    final enabled = _bool(props['enabled']) ?? true;
    final value = (_double(props['value']) ?? min).clamp(min, max).toDouble();
    final secondaryTrackValue = _double(props['secondaryTrackValue']);
    final adaptive = _bool(props['adaptive']) == true;
    final secondary = secondaryTrackValue?.clamp(min, max).toDouble();
    final onChanged = enabled ? _doubleCallback(props['onChanged']) : null;
    final onChangeStart = enabled
        ? _doubleCallback(props['onChangeStart'] ?? props['onStart'])
        : null;
    final onChangeEnd = enabled
        ? _doubleCallback(props['onChangeEnd'] ?? props['onEnd'])
        : null;
    if (adaptive) {
      return Slider.adaptive(
        value: value,
        secondaryTrackValue: secondary,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: _positiveInt(props['divisions']),
        label: _string(props['label']),
        activeColor: _color(props['activeColor']),
        inactiveColor: _color(props['inactiveColor']),
        secondaryActiveColor: _color(props['secondaryActiveColor']),
        thumbColor: _color(props['thumbColor']),
        overlayColor: _stateColor(props['overlayColor']),
        mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
            ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
            : null,
        semanticFormatterCallback: _sliderSemanticFormatter(
          props['semanticFormatter'] ?? props['semanticFormatterCallback'],
        ),
        autofocus: _bool(props['autofocus']) ?? false,
        allowedInteraction: _sliderInteraction(props['allowedInteraction']),
        showValueIndicator: _showValueIndicator(props['showValueIndicator']),
      );
    }
    return Slider(
      value: value,
      secondaryTrackValue: secondary,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      min: min,
      max: max,
      divisions: _positiveInt(props['divisions']),
      label: _string(props['label']),
      activeColor: _color(props['activeColor']),
      inactiveColor: _color(props['inactiveColor']),
      secondaryActiveColor: _color(props['secondaryActiveColor']),
      thumbColor: _color(props['thumbColor']),
      overlayColor: _stateColor(props['overlayColor']),
      mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
          ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
          : null,
      semanticFormatterCallback: _sliderSemanticFormatter(
        props['semanticFormatter'] ?? props['semanticFormatterCallback'],
      ),
      autofocus: _bool(props['autofocus']) ?? false,
      allowedInteraction: _sliderInteraction(props['allowedInteraction']),
      padding: _edgeInsets(props['padding']),
      showValueIndicator: _showValueIndicator(props['showValueIndicator']),
    );
  }

  Widget _cupertinoSlider(Map<String, Object?> props) {
    final bounds = _sliderBounds(props);
    final min = bounds.min;
    final max = bounds.max;
    final value = (_double(props['value']) ?? min).clamp(min, max).toDouble();
    final enabled = _bool(props['enabled']) ?? true;
    return cupertino.CupertinoSlider(
      value: value,
      onChanged: enabled ? _doubleCallback(props['onChanged']) : null,
      onChangeStart: enabled
          ? _doubleCallback(props['onChangeStart'] ?? props['onStart'])
          : null,
      onChangeEnd: enabled
          ? _doubleCallback(props['onChangeEnd'] ?? props['onEnd'])
          : null,
      min: min,
      max: max,
      divisions: _positiveInt(props['divisions']),
      activeColor: _color(props['activeColor']),
      thumbColor:
          _color(props['thumbColor']) ?? cupertino.CupertinoColors.white,
    );
  }

  Widget _rangeSlider(Map<String, Object?> props) {
    final bounds = _sliderBounds(props);
    final min = bounds.min;
    final max = bounds.max;
    final values = _rangeValuesInBounds(props['values'] ?? props, min, max);
    final enabled = _bool(props['enabled']) ?? true;
    return RangeSlider(
      values: values,
      min: min,
      max: max,
      divisions: _positiveInt(props['divisions']),
      labels: _rangeLabels(props['labels'], values),
      onChanged: enabled ? _rangeCallback(props['onChanged']) : null,
      onChangeStart: enabled
          ? _rangeCallback(props['onChangeStart'] ?? props['onStart'])
          : null,
      onChangeEnd: enabled
          ? _rangeCallback(props['onChangeEnd'] ?? props['onEnd'])
          : null,
      activeColor: _color(props['activeColor']),
      inactiveColor: _color(props['inactiveColor']),
      overlayColor: _stateColor(props['overlayColor']),
      mouseCursor: _stateMouseCursor(props['mouseCursor'] ?? props['cursor']),
      semanticFormatterCallback: _sliderSemanticFormatter(
        props['semanticFormatter'] ?? props['semanticFormatterCallback'],
      ),
      padding: _edgeInsets(props['padding']),
    );
  }

  Widget _linearProgressIndicator(Map<String, Object?> props) {
    final value = _progressValue(props['value']);
    return LinearProgressIndicator(
      value: value,
      backgroundColor: _color(props['backgroundColor']),
      color: _color(props['color']),
      valueColor: _colorAnimation(props['valueColor']),
      minHeight: _positiveDouble(props['minHeight']),
      semanticsLabel: _string(
        props['semanticsLabel'] ?? props['semanticLabel'],
      ),
      semanticsValue: _progressSemanticsValue(
        props['semanticsValue'] ?? props['semanticValue'],
        value,
      ),
      borderRadius: _borderRadius(props['borderRadius'] ?? props['radius']),
      stopIndicatorColor: _color(props['stopIndicatorColor']),
      stopIndicatorRadius: _nonNegativeDouble(props['stopIndicatorRadius']),
      trackGap: _nonNegativeDouble(props['trackGap']),
    );
  }

  Widget _circularProgressIndicator(Map<String, Object?> props) {
    final value = _progressValue(props['value']);
    final backgroundColor = _color(props['backgroundColor']);
    final valueColor = _colorAnimation(props['valueColor']);
    final strokeWidth = _positiveDouble(props['strokeWidth']);
    final strokeAlign = _double(props['strokeAlign']);
    final semanticsLabel = _string(
      props['semanticsLabel'] ?? props['semanticLabel'],
    );
    final semanticsValue = _progressSemanticsValue(
      props['semanticsValue'] ?? props['semanticValue'],
      value,
    );
    final strokeCap = _strokeCap(props['strokeCap']);
    final constraints = _boxConstraints(props['constraints']);
    final trackGap = _nonNegativeDouble(props['trackGap']);
    final padding = _edgeInsets(props['padding']);
    if (_bool(props['adaptive']) ?? false) {
      return CircularProgressIndicator.adaptive(
        value: value,
        backgroundColor: backgroundColor,
        valueColor: valueColor,
        strokeWidth: strokeWidth,
        strokeAlign: strokeAlign,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
        strokeCap: strokeCap,
        constraints: constraints,
        trackGap: trackGap,
        padding: padding,
      );
    }
    return CircularProgressIndicator(
      value: value,
      backgroundColor: backgroundColor,
      color: _color(props['color']),
      valueColor: valueColor,
      strokeWidth: strokeWidth,
      strokeAlign: strokeAlign,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      strokeCap: strokeCap,
      constraints: constraints,
      trackGap: trackGap,
      padding: padding,
    );
  }

  Widget _cupertinoActivityIndicator(Map<String, Object?> props) {
    final radius = _positiveDouble(props['radius']) ?? 10;
    final progress = _unitDouble(props['progress']) ?? 1;
    final partiallyRevealed =
        _bool(
          props['partiallyRevealed'] ??
              props['partial'] ??
              props['revealed'] ??
              props['static'],
        ) ??
        (props.containsKey('progress') && _bool(props['animating']) != true);
    if (partiallyRevealed) {
      return cupertino.CupertinoActivityIndicator.partiallyRevealed(
        color: _color(props['color']),
        radius: radius,
        progress: progress,
      );
    }
    return cupertino.CupertinoActivityIndicator(
      color: _color(props['color']),
      animating: _bool(props['animating']) ?? true,
      radius: radius,
    );
  }

  Widget _refreshIndicator(BuildContext context, Map<String, Object?> props) {
    final child = _child(context, props);
    final onRefresh = _asyncCallback(props['onRefresh']);
    final triggerMode = _refreshIndicatorTriggerMode(props['triggerMode']);
    final notificationPredicate = _scrollNotificationPredicate(
      props['notificationPredicate'] ??
          props['notificationDepth'] ??
          props['depth'],
    );
    final noSpinner =
        (_bool(props['noSpinner']) ?? false) ||
        (_bool(props['spinner']) == false) ||
        props['variant']?.toString().toLowerCase() == 'nospinner' ||
        props['variant']?.toString().toLowerCase() == 'no_spinner';
    final semanticsLabel = _string(
      props['semanticsLabel'] ?? props['semanticLabel'],
    );
    final semanticsValue = _string(
      props['semanticsValue'] ?? props['semanticValue'],
    );
    final elevation = _nonNegativeDouble(props['elevation']) ?? 2;
    if (noSpinner) {
      return RefreshIndicator.noSpinner(
        onRefresh: onRefresh,
        onStatusChange: _refreshIndicatorStatusCallback(
          props['onStatusChange'],
        ),
        notificationPredicate: notificationPredicate,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
        triggerMode: triggerMode ?? RefreshIndicatorTriggerMode.onEdge,
        elevation: elevation,
        child: child,
      );
    }
    final displacement = _nonNegativeDouble(props['displacement']) ?? 40;
    final edgeOffset = _nonNegativeDouble(props['edgeOffset']) ?? 0;
    final strokeWidth =
        _positiveDouble(props['strokeWidth']) ??
        RefreshProgressIndicator.defaultStrokeWidth;
    if (_bool(props['adaptive']) ?? false) {
      return RefreshIndicator.adaptive(
        displacement: displacement,
        edgeOffset: edgeOffset,
        onRefresh: onRefresh,
        color: _color(props['color']),
        backgroundColor: _color(props['backgroundColor']),
        notificationPredicate: notificationPredicate,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
        strokeWidth: strokeWidth,
        triggerMode: triggerMode ?? RefreshIndicatorTriggerMode.onEdge,
        elevation: elevation,
        child: child,
      );
    }
    return RefreshIndicator(
      displacement: displacement,
      edgeOffset: edgeOffset,
      onRefresh: onRefresh,
      color: _color(props['color']),
      backgroundColor: _color(props['backgroundColor']),
      notificationPredicate: notificationPredicate,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      strokeWidth: strokeWidth,
      triggerMode: triggerMode ?? RefreshIndicatorTriggerMode.onEdge,
      elevation: elevation,
      child: child,
    );
  }

  Widget _segmentedButton(BuildContext context, Map<String, Object?> props) {
    final segments = _buttonSegments(
      context,
      props['segments'] ?? props['children'],
    );
    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }
    final emptySelectionAllowed =
        _bool(props['emptySelectionAllowed']) ?? false;
    final multiSelectionEnabled =
        _bool(props['multiSelectionEnabled'] ?? props['multi']) ?? false;
    final selected = _objectSet(props['selected'] ?? props['value']);
    final segmentValues = segments.map((segment) => segment.value).toSet();
    selected.removeWhere((value) => !segmentValues.contains(value));
    if (selected.isEmpty && !emptySelectionAllowed && segments.isNotEmpty) {
      selected.add(segments.first.value);
    }
    if (!multiSelectionEnabled && selected.length > 1) {
      final first = selected.first;
      selected
        ..clear()
        ..add(first);
    }
    final direction =
        _axis(props['direction'] ?? props['axis']) ?? Axis.horizontal;
    final button = SegmentedButton<Object>(
      segments: segments,
      selected: selected,
      emptySelectionAllowed: emptySelectionAllowed,
      multiSelectionEnabled: multiSelectionEnabled,
      showSelectedIcon: _bool(props['showSelectedIcon']) ?? true,
      onSelectionChanged: _bool(props['enabled']) == false
          ? null
          : _setCallback(props['onSelectionChanged'] ?? props['onChanged']),
      expandedInsets: _edgeInsetsOnly(props['expandedInsets']),
      style: _buttonStyle(props['style']),
      selectedIcon: _optionalWidget(context, props['selectedIcon']),
      direction: direction,
    );
    return direction == Axis.vertical ? IntrinsicHeight(child: button) : button;
  }

  Widget _toggleButtons(BuildContext context, Map<String, Object?> props) {
    final children = buildWidgets(
      context,
      props['children'] ?? props['items'] ?? props['buttons'],
    );
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    final selected = _toggleButtonsSelection(
      props['isSelected'] ?? props['selected'] ?? props['value'],
      children.length,
    );
    final direction =
        _axis(props['direction'] ?? props['axis']) ?? Axis.horizontal;
    return ToggleButtons(
      isSelected: selected,
      onPressed: _bool(props['enabled']) == false
          ? null
          : _toggleButtonsCallback(
              props['onPressed'] ?? props['onChanged'] ?? props['onSelected'],
              selected,
            ),
      mouseCursor: _mouseCursor(props['mouseCursor'] ?? props['cursor']),
      tapTargetSize: _materialTapTargetSize(
        props['tapTargetSize'] ?? props['materialTapTargetSize'],
      ),
      textStyle: _textStyle(props['textStyle'] ?? props['style']),
      constraints: _boxConstraints(props['constraints']),
      color: _color(props['color'] ?? props['foregroundColor']),
      selectedColor: _color(props['selectedColor']),
      disabledColor: _color(props['disabledColor']),
      fillColor: _color(props['fillColor'] ?? props['backgroundColor']),
      focusColor: _color(props['focusColor']),
      highlightColor: _color(props['highlightColor']),
      hoverColor: _color(props['hoverColor']),
      splashColor: _color(props['splashColor']),
      renderBorder: _bool(props['renderBorder']) ?? true,
      borderColor: _color(props['borderColor']),
      selectedBorderColor: _color(props['selectedBorderColor']),
      disabledBorderColor: _color(props['disabledBorderColor']),
      borderRadius: _borderRadius(props['borderRadius'] ?? props['radius']),
      borderWidth: _nonNegativeDouble(props['borderWidth'] ?? props['width']),
      direction: direction,
      verticalDirection:
          _verticalDirection(props['verticalDirection']) ??
          VerticalDirection.down,
      children: children,
    );
  }

  Widget _cupertinoSegmentedControl(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final children = _safeCupertinoSegmentChildren(
      _cupertinoSegmentChildren(
        context,
        props['segments'] ?? props['children'] ?? props['items'],
      ),
    );
    final onChanged = _objectCallback(
      props['onValueChanged'] ?? props['onChanged'],
    );
    return cupertino.CupertinoSegmentedControl<Object>(
      children: children,
      groupValue: _cupertinoSegmentValue(
        children,
        props['groupValue'] ?? props['value'] ?? props['selected'],
      ),
      onValueChanged: (value) => onChanged?.call(value),
      unselectedColor: _color(props['unselectedColor']),
      selectedColor: _color(props['selectedColor']),
      borderColor: _color(props['borderColor']),
      pressedColor: _color(props['pressedColor']),
      disabledColor: _color(props['disabledColor']),
      disabledTextColor: _color(props['disabledTextColor']),
      padding: _edgeInsets(props['padding']),
      disabledChildren: _objectSet(props['disabledChildren']),
    );
  }

  Widget _cupertinoSlidingSegmentedControl(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final children = _safeCupertinoSegmentChildren(
      _cupertinoSegmentChildren(
        context,
        props['segments'] ?? props['children'] ?? props['items'],
      ),
    );
    final onChanged = _objectCallback(
      props['onValueChanged'] ?? props['onChanged'],
    );
    return cupertino.CupertinoSlidingSegmentedControl<Object>(
      children: children,
      groupValue: _cupertinoSegmentValue(
        children,
        props['groupValue'] ?? props['value'] ?? props['selected'],
      ),
      onValueChanged: (value) => onChanged?.call(value),
      disabledChildren: _objectSet(props['disabledChildren']),
      thumbColor: _color(props['thumbColor']) ?? const Color(0xFFFFFFFF),
      padding:
          _edgeInsets(props['padding']) ??
          const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor:
          _color(props['backgroundColor']) ??
          cupertino.CupertinoColors.tertiarySystemFill,
      proportionalWidth: _bool(props['proportionalWidth']) ?? false,
      isMomentary: _bool(props['isMomentary'] ?? props['momentary']) ?? false,
    );
  }

  Object? _cupertinoSegmentValue(Map<Object, Widget> children, Object? value) {
    if (value != null && children.keys.contains(value)) {
      return value;
    }
    return null;
  }

  Map<Object, Widget> _cupertinoSegmentChildren(
    BuildContext context,
    Object? value,
  ) {
    final out = <Object, Widget>{};
    void add(Object? item, int index) {
      if (item is Map) {
        final props = _props(_stringMap(item));
        final segmentValue =
            props['value'] ?? props['key'] ?? props['id'] ?? index;
        out[segmentValue] =
            _optionalWidget(context, props['child'] ?? props['label']) ??
            _label(context, props);
        return;
      }
      out[index] = Text(item?.toString() ?? '');
    }

    if (value is Map) {
      for (final entry in value.entries) {
        out[entry.key] =
            _optionalWidget(context, entry.value) ??
            Text(entry.value?.toString() ?? '');
      }
      return out;
    }
    final list = value is List ? value : const <Object?>[];
    for (var index = 0; index < list.length; index++) {
      add(list[index], index);
    }
    return out;
  }

  Map<Object, Widget> _safeCupertinoSegmentChildren(
    Map<Object, Widget> children,
  ) {
    if (children.length >= 2) {
      return children;
    }
    final out = <Object, Widget>{...children};
    var index = 0;
    while (out.length < 2) {
      final key = '__segment_$index';
      if (!out.containsKey(key)) {
        out[key] = Text('Segment ${out.length + 1}');
      }
      index++;
    }
    return out;
  }

  Widget _searchBar(BuildContext context, Map<String, Object?> props) {
    return SearchBar(
      hintText: _string(props['hintText'] ?? props['hint']),
      leading: _optionalWidget(context, props['leading']),
      trailing: buildWidgets(context, props['trailing']),
      enabled: _bool(props['enabled']) ?? true,
      constraints: _boxConstraints(props['constraints']),
      elevation: _state(_nonNegativeDouble(props['elevation'])),
      backgroundColor: _state(_color(props['backgroundColor'])),
      shadowColor: _state(_color(props['shadowColor'])),
      surfaceTintColor: _state(_color(props['surfaceTintColor'])),
      overlayColor: _state(_color(props['overlayColor'])),
      side: _state(_borderSide(props['side'])),
      shape: _state(_outlinedBorder(props['shape'] ?? props)),
      padding: _state(_edgeInsets(props['padding'])),
      textStyle: _state(_textStyle(props['textStyle'] ?? props['style'])),
      hintStyle: _state(_textStyle(props['hintStyle'])),
      textCapitalization:
          _textCapitalization(props['textCapitalization']) ??
          TextCapitalization.none,
      autoFocus: _bool(props['autoFocus'] ?? props['autofocus']) ?? false,
      readOnly: _bool(props['readOnly']) ?? false,
      textInputAction: _textInputAction(props['textInputAction']),
      keyboardType: _keyboardType(props['keyboardType']),
      scrollPadding:
          _resolvedEdgeInsets(context, props['scrollPadding']) ??
          const EdgeInsets.all(20),
      onTap: _callback(props['onTap']),
      onTapOutside: _pointerCallback(props['onTapOutside']),
      onChanged: _stringValueCallback(props['onChanged']),
      onSubmitted: _stringValueCallback(props['onSubmitted']),
    );
  }

  Widget _searchAnchor(BuildContext context, Map<String, Object?> props) {
    return SearchAnchor(
      isFullScreen: _bool(props['isFullScreen'] ?? props['fullscreen']),
      viewLeading: _optionalWidget(context, props['viewLeading']),
      viewTrailing: buildWidgets(context, props['viewTrailing']),
      viewHintText:
          _string(props['viewHintText']) ??
          _string(props['hintText'] ?? props['hint']),
      viewBackgroundColor: _color(props['viewBackgroundColor']),
      viewElevation: _nonNegativeDouble(props['viewElevation']),
      viewSurfaceTintColor: _color(props['viewSurfaceTintColor']),
      viewSide: _borderSide(props['viewSide']),
      viewShape: _outlinedBorder(props['viewShape']),
      viewBarPadding: _edgeInsets(props['viewBarPadding']),
      headerHeight: _nonNegativeDouble(
        props['headerHeight'] ?? props['viewHeaderHeight'],
      ),
      headerTextStyle: _textStyle(
        props['headerTextStyle'] ?? props['viewHeaderTextStyle'],
      ),
      headerHintStyle: _textStyle(
        props['headerHintStyle'] ?? props['viewHeaderHintStyle'],
      ),
      dividerColor: _color(props['dividerColor']),
      viewConstraints: _boxConstraints(props['viewConstraints']),
      viewPadding: _edgeInsets(props['viewPadding']),
      shrinkWrap: _bool(props['shrinkWrap']),
      textCapitalization: _textCapitalization(props['textCapitalization']),
      viewOnChanged: _stringValueCallback(
        props['viewOnChanged'] ?? props['onChanged'],
      ),
      viewOnSubmitted: _stringValueCallback(
        props['viewOnSubmitted'] ?? props['onSubmitted'],
      ),
      viewOnClose: _callback(props['viewOnClose'] ?? props['onClose']),
      viewOnOpen: _callback(props['viewOnOpen'] ?? props['onOpen']),
      textInputAction: _textInputAction(props['textInputAction']),
      keyboardType: _keyboardType(props['keyboardType']),
      enabled: _bool(props['enabled']) ?? true,
      viewBuilder: props.containsKey('view') || props.containsKey('viewChild')
          ? (_) =>
                _optionalWidget(context, props['view'] ?? props['viewChild']) ??
                const SizedBox.shrink()
          : null,
      builder: (context, controller) {
        final child = _optionalWidget(context, props['child']);
        if (child != null) {
          return child;
        }
        return SearchBar(
          controller: controller,
          hintText: _string(props['hintText'] ?? props['hint']),
          leading: _optionalWidget(context, props['leading']),
          trailing: buildWidgets(context, props['trailing']),
          enabled: _bool(props['enabled']) ?? true,
          constraints: _boxConstraints(props['constraints']),
          elevation: _state(_nonNegativeDouble(props['elevation'])),
          backgroundColor: _state(_color(props['backgroundColor'])),
          shadowColor: _state(_color(props['shadowColor'])),
          surfaceTintColor: _state(_color(props['surfaceTintColor'])),
          overlayColor: _state(_color(props['overlayColor'])),
          side: _state(_borderSide(props['side'])),
          shape: _state(_outlinedBorder(props['shape'] ?? props)),
          padding: _state(_edgeInsets(props['padding'])),
          textStyle: _state(_textStyle(props['textStyle'] ?? props['style'])),
          hintStyle: _state(_textStyle(props['hintStyle'])),
          textCapitalization:
              _textCapitalization(props['textCapitalization']) ??
              TextCapitalization.none,
          autoFocus: _bool(props['autoFocus'] ?? props['autofocus']) ?? false,
          readOnly: _bool(props['readOnly']) ?? false,
          textInputAction: _textInputAction(props['textInputAction']),
          keyboardType: _keyboardType(props['keyboardType']),
          scrollPadding:
              _resolvedEdgeInsets(context, props['scrollPadding']) ??
              const EdgeInsets.all(20),
          onTap: () {
            controller.openView();
            _callback(props['onTap'])?.call();
          },
          onTapOutside: _pointerCallback(props['onTapOutside']),
          onChanged: (value) {
            controller.openView();
            _stringValueCallback(props['onChanged'])?.call(value);
          },
          onSubmitted: _stringValueCallback(props['onSubmitted']),
        );
      },
      suggestionsBuilder: (context, controller) {
        return buildWidgets(
          context,
          props['suggestions'] ?? props['suggestionChildren'] ?? props['items'],
        );
      },
    );
  }

  Widget _draggable(
    BuildContext context,
    Map<String, Object?> props, {
    bool longPress = false,
  }) {
    final child = _child(context, props);
    final feedback =
        _optionalWidget(context, props['feedback']) ??
        Material(type: MaterialType.transparency, child: child);
    final childWhenDragging = _optionalWidget(
      context,
      props['childWhenDragging'],
    );
    final common = (
      data: props['data'] ?? props['value'] ?? props['payload'],
      axis: _axis(props['axis']),
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      feedbackOffset: _offset(props['feedbackOffset']) ?? Offset.zero,
      maxSimultaneousDrags: _nonNegativeInt(props['maxSimultaneousDrags']),
      onDragStarted: _callback(props['onDragStarted']),
      onDragUpdate: _dragUpdateCallback(props['onDragUpdate']),
      onDraggableCanceled: _draggableCanceledCallback(
        props['onDraggableCanceled'] ?? props['onDragCanceled'],
      ),
      onDragEnd: _dragEndCallback(props['onDragEnd']),
      onDragCompleted: _callback(props['onDragCompleted']),
      ignoringFeedbackSemantics:
          _bool(props['ignoringFeedbackSemantics']) ?? true,
      ignoringFeedbackPointer: _bool(props['ignoringFeedbackPointer']) ?? true,
      rootOverlay: _bool(props['rootOverlay']) ?? false,
      hitTestBehavior:
          _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
          HitTestBehavior.deferToChild,
    );

    if (longPress) {
      return LongPressDraggable<Object>(
        data: common.data,
        axis: common.axis,
        feedback: common.feedback,
        childWhenDragging: common.childWhenDragging,
        feedbackOffset: common.feedbackOffset,
        maxSimultaneousDrags: common.maxSimultaneousDrags,
        onDragStarted: common.onDragStarted,
        onDragUpdate: common.onDragUpdate,
        onDraggableCanceled: common.onDraggableCanceled,
        onDragEnd: common.onDragEnd,
        onDragCompleted: common.onDragCompleted,
        hapticFeedbackOnStart: _bool(props['hapticFeedbackOnStart']) ?? true,
        delay:
            _nonNegativeDuration(props['delay']) ??
            const Duration(milliseconds: 500),
        ignoringFeedbackSemantics: common.ignoringFeedbackSemantics,
        ignoringFeedbackPointer: common.ignoringFeedbackPointer,
        rootOverlay: common.rootOverlay,
        hitTestBehavior: common.hitTestBehavior,
        child: child,
      );
    }

    return Draggable<Object>(
      data: common.data,
      axis: common.axis,
      feedback: common.feedback,
      childWhenDragging: common.childWhenDragging,
      feedbackOffset: common.feedbackOffset,
      maxSimultaneousDrags: common.maxSimultaneousDrags,
      onDragStarted: common.onDragStarted,
      onDragUpdate: common.onDragUpdate,
      onDraggableCanceled: common.onDraggableCanceled,
      onDragEnd: common.onDragEnd,
      onDragCompleted: common.onDragCompleted,
      ignoringFeedbackSemantics: common.ignoringFeedbackSemantics,
      ignoringFeedbackPointer: common.ignoringFeedbackPointer,
      rootOverlay: common.rootOverlay,
      hitTestBehavior: common.hitTestBehavior,
      child: child,
    );
  }

  Widget _dragTarget(BuildContext context, Map<String, Object?> props) {
    final onWillAccept = _dragTargetWillAcceptCallback(
      props['onWillAccept'] ?? props['onEnter'],
    );
    return DragTarget<Object>(
      hitTestBehavior:
          _hitTestBehavior(props['hitTestBehavior'] ?? props['behavior']) ??
          HitTestBehavior.translucent,
      onWillAcceptWithDetails: (details) {
        onWillAccept?.call(details);
        return _dragTargetAccepts(props, details.data);
      },
      onAcceptWithDetails: _dragTargetAcceptCallback(
        props['onAcceptWithDetails'] ?? props['onAccept'] ?? props['onDrop'],
      ),
      onLeave: _objectCallback(props['onLeave']),
      onMove: _dragTargetMoveCallback(props['onMove']),
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty) {
          return _optionalWidget(
                context,
                props['candidateChild'] ?? props['activeChild'],
              ) ??
              _child(context, props);
        }
        if (rejectedData.isNotEmpty) {
          return _optionalWidget(context, props['rejectedChild']) ??
              _child(context, props);
        }
        return _child(context, props);
      },
    );
  }

  Widget _semantics(BuildContext context, Map<String, Object?> props) {
    return Semantics(
      container: _bool(props['container']) ?? false,
      explicitChildNodes: _bool(props['explicitChildNodes']) ?? false,
      excludeSemantics: _bool(props['excludeSemantics']) ?? false,
      blockUserActions: _bool(props['blockUserActions']) ?? false,
      enabled: _bool(props['enabled']),
      checked: _bool(props['checked']),
      mixed: _bool(props['mixed']),
      selected: _bool(props['selected']),
      toggled: _bool(props['toggled']),
      button: _bool(props['button']),
      slider: _bool(props['slider']),
      keyboardKey: _bool(props['keyboardKey']),
      link: _bool(props['link']),
      linkUrl: _uri(props['linkUrl'] ?? props['url']),
      header: _bool(props['header']),
      headingLevel: _positiveInt(props['headingLevel']),
      textField: _bool(props['textField']),
      readOnly: _bool(props['readOnly']),
      focusable: _bool(props['focusable']),
      focused: _bool(props['focused']),
      inMutuallyExclusiveGroup: _bool(props['inMutuallyExclusiveGroup']),
      obscured: _bool(props['obscured']),
      multiline: _bool(props['multiline']),
      scopesRoute: _bool(props['scopesRoute']),
      namesRoute: _bool(props['namesRoute']),
      hidden: _bool(props['hidden']),
      image: _bool(props['image']),
      liveRegion: _bool(props['liveRegion']),
      expanded: _bool(props['expanded']),
      isRequired: _bool(props['isRequired']),
      maxValueLength: _nonNegativeInt(props['maxValueLength']),
      currentValueLength: _nonNegativeInt(props['currentValueLength']),
      identifier: _string(props['identifier']),
      traversalParentIdentifier: _string(props['traversalParentIdentifier']),
      traversalChildIdentifier: _string(props['traversalChildIdentifier']),
      label: _string(props['label']),
      value: _string(props['value']),
      increasedValue: _string(props['increasedValue']),
      decreasedValue: _string(props['decreasedValue']),
      hint: _string(props['hint']),
      tooltip: _string(props['tooltip']),
      onTapHint: _string(props['onTapHint']),
      onLongPressHint: _string(props['onLongPressHint']),
      textDirection: _textDirection(props['textDirection']),
      onTap: _callback(props['onTap']),
      onLongPress: _callback(props['onLongPress']),
      onScrollLeft: _callback(props['onScrollLeft']),
      onScrollRight: _callback(props['onScrollRight']),
      onScrollUp: _callback(props['onScrollUp']),
      onScrollDown: _callback(props['onScrollDown']),
      onIncrease: _callback(props['onIncrease']),
      onDecrease: _callback(props['onDecrease']),
      onCopy: _callback(props['onCopy']),
      onCut: _callback(props['onCut']),
      onPaste: _callback(props['onPaste']),
      onDismiss: _callback(props['onDismiss']),
      onDidGainAccessibilityFocus: _callback(
        props['onDidGainAccessibilityFocus'],
      ),
      onDidLoseAccessibilityFocus: _callback(
        props['onDidLoseAccessibilityFocus'],
      ),
      onFocus: _callback(props['onFocus']),
      onExpand: _callback(props['onExpand']),
      onCollapse: _callback(props['onCollapse']),
      role: _semanticsRole(props['role'] ?? props['semanticsRole']),
      minValue: _string(props['minValue']),
      maxValue: _string(props['maxValue']),
      child: _child(context, props),
    );
  }

  Widget _bottomSheet(BuildContext context, Map<String, Object?> props) {
    final child = _child(context, props);
    final showDragHandle = _bool(props['showDragHandle']) ?? false;
    final body = showDragHandle
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_bottomSheetDragHandle(context, props), child],
          )
        : child;
    return BottomSheet(
      // Applet does not expose an AnimationController to JavaScript; direct
      // BottomSheet drag gestures are unsafe without one.
      enableDrag: false,
      showDragHandle: false,
      backgroundColor: _color(props['backgroundColor']),
      shadowColor: _color(props['shadowColor']),
      elevation: _nonNegativeDouble(props['elevation']),
      shape: _outlinedBorder(props['shape'] ?? props),
      clipBehavior: _clip(props['clipBehavior']),
      constraints: _boxConstraints(props['constraints']),
      onClosing: _callback(props['onClosing']) ?? () {},
      builder: (_) => body,
    );
  }

  Widget _bottomSheetDragHandle(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final size = _size(props['dragHandleSize']) ?? const Size(32, 4);
    final color =
        _color(props['dragHandleColor']) ??
        Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size.height / 2),
            ),
          ),
        ),
      ),
    );
  }

  OutlinedBorder? _cardShape(
    BuildContext context,
    Map<String, Object?> props,
    String? variant,
  ) {
    final explicitShape = _outlinedBorder(props['shape']);
    if (explicitShape != null) {
      return explicitShape;
    }
    final hasShapeParts =
        props.containsKey('borderRadius') ||
        props.containsKey('radius') ||
        props.containsKey('side') ||
        props.containsKey('outlineColor') ||
        props.containsKey('outlineWidth');
    if (!hasShapeParts) {
      return null;
    }
    final outlineColor = _color(props['outlineColor']);
    final outlineWidth = _nonNegativeDouble(props['outlineWidth']);
    final side =
        _borderSide(props['side']) ??
        (outlineColor != null || outlineWidth != null
            ? BorderSide(
                color:
                    outlineColor ??
                    (variant == 'outlined'
                        ? Theme.of(context).colorScheme.outlineVariant
                        : Colors.transparent),
                width: outlineWidth ?? 1,
              )
            : BorderSide.none);
    return RoundedRectangleBorder(
      borderRadius:
          _borderRadius(props['borderRadius'] ?? props['radius']) ??
          BorderRadius.circular(variant == 'outlined' ? 12 : 4),
      side: side,
    );
  }

  BorderRadiusGeometry? _dividerRadius(
    Map<String, Object?> props,
    double? thickness,
  ) {
    if (thickness == null || thickness <= 0) {
      return null;
    }
    return _borderRadius(props['radius'] ?? props['borderRadius']);
  }

  Widget _snackBar(BuildContext context, Map<String, Object?> props) {
    final action = _snackBarAction(props['action']);
    final behavior = _snackBarBehavior(
      props['snackBarBehavior'] ?? props['behavior'],
    );
    Widget surface = Material(
      color:
          _color(props['backgroundColor']) ??
          Theme.of(context).snackBarTheme.backgroundColor ??
          Theme.of(context).colorScheme.inverseSurface,
      elevation: _nonNegativeDouble(props['elevation']) ?? 6,
      shape:
          _outlinedBorder(props['shape'] ?? props) ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
      child: Padding(
        padding:
            _edgeInsets(props['padding']) ??
            EdgeInsets.fromLTRB(
              behavior == SnackBarBehavior.floating ? 16 : 24,
              14,
              action == null ? 24 : 0,
              14,
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child:
                  _optionalWidget(
                    context,
                    props['content'] ?? props['child'],
                  ) ??
                  _label(context, props),
            ),
            ?action,
          ],
        ),
      ),
    );
    final width = _double(props['width']);
    if (width != null) {
      surface = SizedBox(width: width, child: surface);
    }
    final margin = _edgeInsets(props['margin']);
    if (margin != null) {
      surface = Padding(padding: margin, child: surface);
    }
    return surface;
  }

  SnackBar _materialSnackBar(BuildContext context, Object? spec) {
    final props = spec is Map
        ? _props(_stringMap(spec))
        : <String, Object?>{'content': spec};
    return SnackBar(
      content:
          _optionalWidget(context, props['content'] ?? props['child']) ??
          _label(context, props),
      backgroundColor: _color(props['backgroundColor']),
      elevation: _nonNegativeDouble(props['elevation']),
      margin: _edgeInsets(props['margin']),
      padding: _edgeInsets(props['padding']),
      width: _double(props['width']),
      shape: _outlinedBorder(props['shape'] ?? props),
      hitTestBehavior: _hitTestBehavior(
        props['hitTestBehavior'] ?? props['behavior'],
      ),
      behavior: _snackBarBehavior(
        props['snackBarBehavior'] ?? props['behavior'],
      ),
      action: _snackBarAction(props['action']),
      actionOverflowThreshold: _unitDouble(props['actionOverflowThreshold']),
      showCloseIcon: _bool(props['showCloseIcon']),
      closeIconColor: _color(props['closeIconColor']),
      duration: _duration(props['duration']) ?? const Duration(seconds: 4),
      persist: _bool(props['persist']),
      onVisible: _callback(props['onVisible']),
      dismissDirection: _dismissDirection(props['dismissDirection']),
      clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
    );
  }

  SnackBarAction? _snackBarAction(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is SnackBarAction) {
      return value;
    }
    final props = value is Map
        ? _props(_stringMap(value))
        : <String, Object?>{};
    final label = _string(props['label'] ?? props['text'] ?? value) ?? '';
    return SnackBarAction(
      textColor: _color(props['textColor']),
      disabledTextColor: _color(props['disabledTextColor']),
      backgroundColor: _color(props['backgroundColor']),
      disabledBackgroundColor: _color(props['disabledBackgroundColor']),
      label: label,
      onPressed: _callback(props['onPressed'] ?? props['onTap']) ?? () {},
    );
  }

  SnackBarBehavior? _snackBarBehavior(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'fixed':
        return SnackBarBehavior.fixed;
      case 'floating':
        return SnackBarBehavior.floating;
    }
    return null;
  }

  List<Widget> _spacedWidgets(
    List<Widget> children,
    double spacing,
    Axis axis,
  ) {
    if (spacing <= 0 || children.length < 2) {
      return children;
    }
    final spaced = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        spaced.add(
          axis == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
      spaced.add(children[index]);
    }
    return spaced;
  }

  cupertino.CupertinoNavigationBar? _cupertinoNavigationBar(
    BuildContext context,
    Object? spec,
  ) {
    if (spec == null) {
      return null;
    }
    final props = spec is Map ? _props(_stringMap(spec)) : <String, Object?>{};
    final transitionBetweenRoutes =
        _bool(props['transitionBetweenRoutes']) ??
        (props.containsKey('heroTag') ? false : true);
    final common = _CupertinoNavigationBarCommon(
      leading: _optionalWidget(context, props['leading']),
      trailing: _optionalWidget(context, props['trailing']),
      automaticallyImplyLeading:
          _bool(props['automaticallyImplyLeading']) ?? true,
      automaticallyImplyMiddle:
          _bool(
            props['automaticallyImplyMiddle'] ??
                props['automaticallyImplyTitle'],
          ) ??
          true,
      previousPageTitle: _string(props['previousPageTitle']),
      backgroundColor: _color(props['backgroundColor']),
      automaticBackgroundVisibility:
          _bool(props['automaticBackgroundVisibility']) ?? true,
      enableBackgroundFilterBlur:
          _bool(props['enableBackgroundFilterBlur']) ?? true,
      brightness: _brightness(props['brightness']),
      padding: _edgeInsetsDirectional(props['padding']),
      transitionBetweenRoutes: transitionBetweenRoutes,
      heroTag: props.containsKey('heroTag') ? props['heroTag'] : null,
      bottom: _preferredWidget(context, props['bottom']),
      border: props.containsKey('border')
          ? _borderOrNull(props['border'])
          : _defaultCupertinoNavBarBorder,
    );
    final large =
        _bool(props['large']) ??
        (_normalizedToken(props['variant'] ?? props['type']) == 'large' ||
            props.containsKey('largeTitle'));
    if (large) {
      if (common.transitionBetweenRoutes) {
        return cupertino.CupertinoNavigationBar.large(
          largeTitle: _optionalWidget(
            context,
            props['largeTitle'] ?? props['title'] ?? props['middle'],
          ),
          leading: common.leading,
          automaticallyImplyLeading: common.automaticallyImplyLeading,
          automaticallyImplyTitle: common.automaticallyImplyMiddle,
          previousPageTitle: common.previousPageTitle,
          trailing: common.trailing,
          border: common.border,
          backgroundColor: common.backgroundColor,
          automaticBackgroundVisibility: common.automaticBackgroundVisibility,
          enableBackgroundFilterBlur: common.enableBackgroundFilterBlur,
          brightness: common.brightness,
          padding: common.padding,
          transitionBetweenRoutes: common.transitionBetweenRoutes,
          bottom: common.bottom,
        );
      }
      return cupertino.CupertinoNavigationBar.large(
        largeTitle: _optionalWidget(
          context,
          props['largeTitle'] ?? props['title'] ?? props['middle'],
        ),
        leading: common.leading,
        automaticallyImplyLeading: common.automaticallyImplyLeading,
        automaticallyImplyTitle: common.automaticallyImplyMiddle,
        previousPageTitle: common.previousPageTitle,
        trailing: common.trailing,
        border: common.border,
        backgroundColor: common.backgroundColor,
        automaticBackgroundVisibility: common.automaticBackgroundVisibility,
        enableBackgroundFilterBlur: common.enableBackgroundFilterBlur,
        brightness: common.brightness,
        padding: common.padding,
        transitionBetweenRoutes: common.transitionBetweenRoutes,
        heroTag: common.heroTag ?? _defaultCupertinoNavBarHeroTag,
        bottom: common.bottom,
      );
    }
    if (common.transitionBetweenRoutes) {
      return cupertino.CupertinoNavigationBar(
        leading: common.leading,
        automaticallyImplyLeading: common.automaticallyImplyLeading,
        automaticallyImplyMiddle: common.automaticallyImplyMiddle,
        previousPageTitle: common.previousPageTitle,
        middle: _optionalWidget(context, props['middle'] ?? props['title']),
        trailing: common.trailing,
        border: common.border,
        backgroundColor: common.backgroundColor,
        automaticBackgroundVisibility: common.automaticBackgroundVisibility,
        enableBackgroundFilterBlur: common.enableBackgroundFilterBlur,
        brightness: common.brightness,
        padding: common.padding,
        transitionBetweenRoutes: common.transitionBetweenRoutes,
        bottom: common.bottom,
      );
    }
    return cupertino.CupertinoNavigationBar(
      leading: common.leading,
      automaticallyImplyLeading: common.automaticallyImplyLeading,
      automaticallyImplyMiddle: common.automaticallyImplyMiddle,
      previousPageTitle: common.previousPageTitle,
      middle: _optionalWidget(context, props['middle'] ?? props['title']),
      trailing: common.trailing,
      border: common.border,
      backgroundColor: common.backgroundColor,
      automaticBackgroundVisibility: common.automaticBackgroundVisibility,
      enableBackgroundFilterBlur: common.enableBackgroundFilterBlur,
      brightness: common.brightness,
      padding: common.padding,
      transitionBetweenRoutes: common.transitionBetweenRoutes,
      heroTag: common.heroTag ?? _defaultCupertinoNavBarHeroTag,
      bottom: common.bottom,
    );
  }

  Widget _cupertinoSliverNavigationBar(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final transitionBetweenRoutes =
        _bool(props['transitionBetweenRoutes']) ??
        (props.containsKey('heroTag') ? false : true);
    final largeTitle =
        _optionalWidget(
          context,
          props['largeTitle'] ?? props['title'] ?? props['middle'],
        ) ??
        (_bool(props['automaticallyImplyTitle']) == false
            ? const Text('')
            : null);
    final common = _CupertinoNavigationBarCommon(
      leading: _optionalWidget(context, props['leading']),
      trailing: _optionalWidget(context, props['trailing']),
      automaticallyImplyLeading:
          _bool(props['automaticallyImplyLeading']) ?? true,
      automaticallyImplyMiddle:
          _bool(
            props['automaticallyImplyTitle'] ??
                props['automaticallyImplyMiddle'],
          ) ??
          true,
      previousPageTitle: _string(props['previousPageTitle']),
      backgroundColor: _color(props['backgroundColor']),
      automaticBackgroundVisibility:
          _bool(props['automaticBackgroundVisibility']) ?? true,
      enableBackgroundFilterBlur:
          _bool(props['enableBackgroundFilterBlur']) ?? true,
      brightness: _brightness(props['brightness']),
      padding: _edgeInsetsDirectional(props['padding']),
      transitionBetweenRoutes: transitionBetweenRoutes,
      heroTag: props.containsKey('heroTag') ? props['heroTag'] : null,
      bottom: _preferredWidget(context, props['bottom']),
      border: props.containsKey('border')
          ? _borderOrNull(props['border'])
          : _defaultCupertinoNavBarBorder,
    );
    final searchField = _optionalWidget(context, props['searchField']);
    final bottomMode = common.bottom == null && searchField == null
        ? null
        : _cupertinoNavigationBarBottomMode(props['bottomMode']);
    if (searchField != null ||
        _normalizedToken(props['variant'] ?? props['type']) == 'search') {
      return cupertino.CupertinoSliverNavigationBar.search(
        searchField: searchField ?? const SizedBox.shrink(),
        largeTitle: largeTitle,
        leading: common.leading,
        automaticallyImplyLeading: common.automaticallyImplyLeading,
        automaticallyImplyTitle: common.automaticallyImplyMiddle,
        alwaysShowMiddle: _bool(props['alwaysShowMiddle']) ?? true,
        previousPageTitle: common.previousPageTitle,
        middle: _optionalWidget(context, props['middle']),
        trailing: common.trailing,
        border: common.border,
        backgroundColor: common.backgroundColor,
        automaticBackgroundVisibility: common.automaticBackgroundVisibility,
        enableBackgroundFilterBlur: common.enableBackgroundFilterBlur,
        brightness: common.brightness,
        padding: common.padding,
        transitionBetweenRoutes: common.transitionBetweenRoutes,
        heroTag: common.heroTag ?? _defaultCupertinoNavBarHeroTag,
        stretch: _bool(props['stretch']) ?? false,
        bottomMode: bottomMode ?? cupertino.NavigationBarBottomMode.automatic,
        onSearchableBottomTap: _valueCallback(
          props['onSearchableBottomTap'] ?? props['onSearchTap'],
        ),
      );
    }
    return cupertino.CupertinoSliverNavigationBar(
      largeTitle: largeTitle,
      leading: common.leading,
      automaticallyImplyLeading: common.automaticallyImplyLeading,
      automaticallyImplyTitle: common.automaticallyImplyMiddle,
      alwaysShowMiddle: _bool(props['alwaysShowMiddle']) ?? true,
      previousPageTitle: common.previousPageTitle,
      middle: _optionalWidget(context, props['middle']),
      trailing: common.trailing,
      border: common.border,
      backgroundColor: common.backgroundColor,
      automaticBackgroundVisibility: common.automaticBackgroundVisibility,
      enableBackgroundFilterBlur: common.enableBackgroundFilterBlur,
      brightness: common.brightness,
      padding: common.padding,
      transitionBetweenRoutes: common.transitionBetweenRoutes,
      heroTag: common.heroTag ?? _defaultCupertinoNavBarHeroTag,
      stretch: _bool(props['stretch']) ?? false,
      bottom: common.bottom,
      bottomMode: bottomMode,
    );
  }

  Widget _materialApp(BuildContext context, Map<String, Object?> props) {
    return MaterialApp(
      title: _string(props['title']) ?? 'Applet',
      debugShowCheckedModeBanner:
          _bool(props['debugShowCheckedModeBanner']) ?? false,
      theme: _themeData(props['theme']) ?? ThemeData(useMaterial3: true),
      darkTheme: _themeData(props['darkTheme']),
      themeMode: _themeMode(props['themeMode']),
      home: buildWidget(context, props['home'] ?? props['child']),
    );
  }

  Widget _scaffold(BuildContext context, Map<String, Object?> props) {
    final scaffold = Scaffold(
      appBar: _preferredWidget(context, props['appBar']),
      body:
          _optionalWidget(context, props['body']) ??
          _maybeChild(context, props) ??
          const SizedBox.shrink(),
      floatingActionButton: _optionalWidget(
        context,
        props['floatingActionButton'],
      ),
      bottomNavigationBar: _optionalWidget(
        context,
        props['bottomNavigationBar'],
      ),
      bottomSheet: _optionalWidget(context, props['bottomSheet']),
      drawer: _optionalWidget(context, props['drawer']),
      onDrawerChanged: _valueCallback(props['onDrawerChanged']),
      endDrawer: _optionalWidget(context, props['endDrawer']),
      onEndDrawerChanged: _valueCallback(props['onEndDrawerChanged']),
      backgroundColor: _color(props['backgroundColor']),
      resizeToAvoidBottomInset: _bool(props['resizeToAvoidBottomInset']),
      primary: _bool(props['primary']) ?? true,
      extendBody: _bool(props['extendBody']) ?? false,
      drawerBarrierDismissible:
          _bool(props['drawerBarrierDismissible']) ?? true,
      extendBodyBehindAppBar: _bool(props['extendBodyBehindAppBar']) ?? false,
      drawerScrimColor: _color(props['drawerScrimColor']),
      drawerEdgeDragWidth: _double(props['drawerEdgeDragWidth']),
      drawerEnableOpenDragGesture:
          _bool(props['drawerEnableOpenDragGesture']) ?? true,
      endDrawerEnableOpenDragGesture:
          _bool(props['endDrawerEnableOpenDragGesture']) ?? true,
      restorationId: _string(props['restorationId']),
      persistentFooterButtons: buildWidgets(
        context,
        props['persistentFooterButtons'],
      ),
    );
    return _withScaffoldPresenters(props, scaffold);
  }

  Widget _adaptiveNavigationScaffold(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final narrowWidth =
        _positiveFiniteDouble(
          props['narrowWidth'] ??
              props['compactBreakpoint'] ??
              props['railBreakpoint'],
        ) ??
        450;
    final largeWidth = math.max(
      narrowWidth,
      _positiveFiniteDouble(
            props['largeWidth'] ??
                props['largeBreakpoint'] ??
                props['extendedRailBreakpoint'],
          ) ??
          1500,
    );
    final scaffold = _AppletAdaptiveNavigationScaffold(
      appBar: _preferredWidget(context, props['appBar']),
      railAppBar: _preferredWidget(
        context,
        props['railAppBar'] ?? props['wideAppBar'],
      ),
      body:
          _optionalWidget(context, props['body']) ??
          _maybeChild(context, props) ??
          const SizedBox.shrink(),
      navigationRail:
          _optionalWidget(context, props['navigationRail'] ?? props['rail']) ??
          const SizedBox.shrink(),
      extendedNavigationRail: _optionalWidget(
        context,
        props['extendedNavigationRail'] ??
            props['largeNavigationRail'] ??
            props['wideNavigationRail'] ??
            props['extendedRail'],
      ),
      navigationBar:
          _optionalWidget(context, props['navigationBar'] ?? props['bar']) ??
          const SizedBox.shrink(),
      floatingActionButton: _optionalWidget(
        context,
        props['floatingActionButton'],
      ),
      bottomSheet: _optionalWidget(context, props['bottomSheet']),
      drawer: _optionalWidget(context, props['drawer']),
      onDrawerChanged: _valueCallback(props['onDrawerChanged']),
      endDrawer: _optionalWidget(context, props['endDrawer']),
      onEndDrawerChanged: _valueCallback(props['onEndDrawerChanged']),
      backgroundColor: _color(props['backgroundColor']),
      resizeToAvoidBottomInset: _bool(props['resizeToAvoidBottomInset']),
      primary: _bool(props['primary']) ?? true,
      extendBody: _bool(props['extendBody']) ?? false,
      drawerBarrierDismissible:
          _bool(props['drawerBarrierDismissible']) ?? true,
      extendBodyBehindAppBar: _bool(props['extendBodyBehindAppBar']) ?? false,
      drawerScrimColor: _color(props['drawerScrimColor']),
      drawerEdgeDragWidth: _double(props['drawerEdgeDragWidth']),
      drawerEnableOpenDragGesture:
          _bool(props['drawerEnableOpenDragGesture']) ?? true,
      endDrawerEnableOpenDragGesture:
          _bool(props['endDrawerEnableOpenDragGesture']) ?? true,
      restorationId: _string(props['restorationId']),
      persistentFooterButtons: buildWidgets(
        context,
        props['persistentFooterButtons'],
      ),
      narrowWidth: narrowWidth,
      largeWidth: largeWidth,
      duration:
          _duration(props['duration'] ?? props['animationDuration']) ??
          const Duration(milliseconds: 500),
      backgroundTransitionColor: _color(
        props['backgroundTransitionColor'] ?? props['transitionColor'],
      ),
    );
    return _withScaffoldPresenters(props, scaffold);
  }

  Widget _adaptiveTwoPane(BuildContext context, Map<String, Object?> props) {
    final compactSpec =
        props['compact'] ??
        props['single'] ??
        props['child'] ??
        props['primary'] ??
        props['first'] ??
        props['one'];
    final primarySpec =
        props['primary'] ??
        props['first'] ??
        props['one'] ??
        props['left'] ??
        props['start'] ??
        compactSpec;
    final secondarySpec =
        props['secondary'] ??
        props['second'] ??
        props['two'] ??
        props['right'] ??
        props['end'];

    return _AppletAdaptiveTwoPane(
      compactPane: buildWidget(context, compactSpec),
      primaryPane: buildWidget(context, primarySpec),
      secondaryPane: _optionalWidget(context, secondarySpec),
      breakpoint:
          _positiveFiniteDouble(
            props['breakpoint'] ??
                props['minWidth'] ??
                props['twoPaneWidth'] ??
                props['mediumWidth'],
          ) ??
          1000,
      primaryFlex:
          _positiveInt(props['primaryFlex'] ?? props['firstFlex']) ?? 1000,
      secondaryFlex:
          _positiveInt(props['secondaryFlex'] ?? props['secondFlex']) ?? 1000,
      duration:
          _duration(props['duration'] ?? props['animationDuration']) ??
          const Duration(milliseconds: 500),
    );
  }

  Widget _withScaffoldPresenters(Map<String, Object?> props, Widget scaffold) {
    final snackBar = props['snackBar'] ?? props['snackbar'];
    final dialog = props['dialog'] ?? props['alertDialog'] ?? props['modal'];
    Widget result = scaffold;
    if (snackBar != null) {
      result = _AppletSnackBarPresenter(
        renderer: this,
        snackBarSpec: snackBar,
        child: result,
      );
    }
    if (dialog != null) {
      result = _AppletDialogPresenter(
        renderer: this,
        dialogSpec: dialog,
        child: result,
      );
    }
    return result;
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    return AppBar(
      title: _optionalWidget(context, props['title']),
      leading: _optionalWidget(context, props['leading']),
      actions: buildWidgets(context, props['actions']),
      automaticallyImplyActions:
          _bool(props['automaticallyImplyActions']) ?? true,
      flexibleSpace: _optionalWidget(context, props['flexibleSpace']),
      bottom: _preferredWidget(context, props['bottom']),
      backgroundColor: _color(props['backgroundColor']),
      foregroundColor: _color(props['foregroundColor']),
      centerTitle: _bool(props['centerTitle']),
      automaticallyImplyLeading:
          _bool(props['automaticallyImplyLeading']) ?? true,
      elevation: _nonNegativeDouble(props['elevation']),
      scrolledUnderElevation: _nonNegativeDouble(
        props['scrolledUnderElevation'],
      ),
      shadowColor: _color(props['shadowColor']),
      surfaceTintColor: _color(props['surfaceTintColor']),
      shape: _outlinedBorder(props['shape'] ?? props),
      iconTheme: props.containsKey('iconTheme')
          ? _iconThemeData(props['iconTheme'])
          : null,
      actionsIconTheme: props.containsKey('actionsIconTheme')
          ? _iconThemeData(props['actionsIconTheme'])
          : null,
      primary: _bool(props['primary']) ?? true,
      excludeHeaderSemantics: _bool(props['excludeHeaderSemantics']) ?? false,
      toolbarOpacity: _unitDouble(props['toolbarOpacity']) ?? 1,
      bottomOpacity: _unitDouble(props['bottomOpacity']) ?? 1,
      toolbarHeight: _nonNegativeDouble(props['toolbarHeight']),
      leadingWidth: _nonNegativeDouble(props['leadingWidth']),
      titleSpacing: _double(props['titleSpacing']),
      toolbarTextStyle: _textStyle(props['toolbarTextStyle']),
      titleTextStyle: _textStyle(props['titleTextStyle']),
      forceMaterialTransparency:
          _bool(props['forceMaterialTransparency']) ?? false,
      useDefaultSemanticsOrder:
          _bool(props['useDefaultSemanticsOrder']) ?? true,
      clipBehavior: _clip(props['clipBehavior']),
      actionsPadding: _edgeInsets(props['actionsPadding']),
      animateColor: _bool(props['animateColor']) ?? false,
    );
  }

  Widget _sliverAppBar(BuildContext context, Map<String, Object?> props) {
    final variant = props['variant']?.toString().toLowerCase();
    final common = (
      leading: _optionalWidget(context, props['leading']),
      automaticallyImplyLeading:
          _bool(props['automaticallyImplyLeading']) ?? true,
      title: _optionalWidget(context, props['title']),
      actions: buildWidgets(context, props['actions']),
      automaticallyImplyActions:
          _bool(props['automaticallyImplyActions']) ?? true,
      flexibleSpace: _optionalWidget(context, props['flexibleSpace']),
      bottom: _preferredWidget(context, props['bottom']),
      elevation: _nonNegativeDouble(props['elevation']),
      scrolledUnderElevation: _nonNegativeDouble(
        props['scrolledUnderElevation'],
      ),
      shadowColor: _color(props['shadowColor']),
      surfaceTintColor: _color(props['surfaceTintColor']),
      forceElevated: _bool(props['forceElevated']) ?? false,
      backgroundColor: _color(props['backgroundColor']),
      foregroundColor: _color(props['foregroundColor']),
      iconTheme: props.containsKey('iconTheme')
          ? _iconThemeData(props['iconTheme'])
          : null,
      actionsIconTheme: props.containsKey('actionsIconTheme')
          ? _iconThemeData(props['actionsIconTheme'])
          : null,
      primary: _bool(props['primary']) ?? true,
      centerTitle: _bool(props['centerTitle']),
      excludeHeaderSemantics: _bool(props['excludeHeaderSemantics']) ?? false,
      titleSpacing: _double(props['titleSpacing']),
      collapsedHeight: _nonNegativeDouble(props['collapsedHeight']),
      expandedHeight: _nonNegativeDouble(props['expandedHeight']),
      floating: _bool(props['floating']) ?? false,
      pinned: _bool(props['pinned']),
      snap:
          (_bool(props['floating']) ?? false) &&
          (_bool(props['snap']) ?? false),
      stretch: _bool(props['stretch']) ?? false,
      stretchTriggerOffset:
          _positiveDouble(props['stretchTriggerOffset']) ?? 100,
      shape: _outlinedBorder(props['shape'] ?? props),
      toolbarHeight: _nonNegativeDouble(props['toolbarHeight']),
      leadingWidth: _nonNegativeDouble(props['leadingWidth']),
      toolbarTextStyle: _textStyle(props['toolbarTextStyle']),
      titleTextStyle: _textStyle(props['titleTextStyle']),
      forceMaterialTransparency:
          _bool(props['forceMaterialTransparency']) ?? false,
      useDefaultSemanticsOrder:
          _bool(props['useDefaultSemanticsOrder']) ?? true,
      clipBehavior: _clip(props['clipBehavior']),
      actionsPadding: _edgeInsets(props['actionsPadding']),
    );

    if (variant == 'medium') {
      return SliverAppBar.medium(
        leading: common.leading,
        automaticallyImplyLeading: common.automaticallyImplyLeading,
        title: common.title,
        actions: common.actions,
        automaticallyImplyActions: common.automaticallyImplyActions,
        flexibleSpace: common.flexibleSpace,
        bottom: common.bottom,
        elevation: common.elevation,
        scrolledUnderElevation: common.scrolledUnderElevation,
        shadowColor: common.shadowColor,
        surfaceTintColor: common.surfaceTintColor,
        forceElevated: common.forceElevated,
        backgroundColor: common.backgroundColor,
        foregroundColor: common.foregroundColor,
        iconTheme: common.iconTheme,
        actionsIconTheme: common.actionsIconTheme,
        primary: common.primary,
        centerTitle: common.centerTitle,
        excludeHeaderSemantics: common.excludeHeaderSemantics,
        titleSpacing: common.titleSpacing,
        collapsedHeight: common.collapsedHeight,
        expandedHeight: common.expandedHeight,
        floating: common.floating,
        pinned: common.pinned ?? true,
        snap: common.snap,
        stretch: common.stretch,
        stretchTriggerOffset: common.stretchTriggerOffset,
        shape: common.shape,
        toolbarHeight: common.toolbarHeight ?? 64,
        leadingWidth: common.leadingWidth,
        toolbarTextStyle: common.toolbarTextStyle,
        titleTextStyle: common.titleTextStyle,
        forceMaterialTransparency: common.forceMaterialTransparency,
        useDefaultSemanticsOrder: common.useDefaultSemanticsOrder,
        clipBehavior: common.clipBehavior,
        actionsPadding: common.actionsPadding,
      );
    }

    if (variant == 'large') {
      return SliverAppBar.large(
        leading: common.leading,
        automaticallyImplyLeading: common.automaticallyImplyLeading,
        title: common.title,
        actions: common.actions,
        automaticallyImplyActions: common.automaticallyImplyActions,
        flexibleSpace: common.flexibleSpace,
        bottom: common.bottom,
        elevation: common.elevation,
        scrolledUnderElevation: common.scrolledUnderElevation,
        shadowColor: common.shadowColor,
        surfaceTintColor: common.surfaceTintColor,
        forceElevated: common.forceElevated,
        backgroundColor: common.backgroundColor,
        foregroundColor: common.foregroundColor,
        iconTheme: common.iconTheme,
        actionsIconTheme: common.actionsIconTheme,
        primary: common.primary,
        centerTitle: common.centerTitle,
        excludeHeaderSemantics: common.excludeHeaderSemantics,
        titleSpacing: common.titleSpacing,
        collapsedHeight: common.collapsedHeight,
        expandedHeight: common.expandedHeight,
        floating: common.floating,
        pinned: common.pinned ?? true,
        snap: common.snap,
        stretch: common.stretch,
        stretchTriggerOffset: common.stretchTriggerOffset,
        shape: common.shape,
        toolbarHeight: common.toolbarHeight ?? 64,
        leadingWidth: common.leadingWidth,
        toolbarTextStyle: common.toolbarTextStyle,
        titleTextStyle: common.titleTextStyle,
        forceMaterialTransparency: common.forceMaterialTransparency,
        useDefaultSemanticsOrder: common.useDefaultSemanticsOrder,
        clipBehavior: common.clipBehavior,
        actionsPadding: common.actionsPadding,
      );
    }

    return SliverAppBar(
      leading: common.leading,
      automaticallyImplyLeading: common.automaticallyImplyLeading,
      title: common.title,
      actions: common.actions,
      automaticallyImplyActions: common.automaticallyImplyActions,
      flexibleSpace: common.flexibleSpace,
      bottom: common.bottom,
      elevation: common.elevation,
      scrolledUnderElevation: common.scrolledUnderElevation,
      shadowColor: common.shadowColor,
      surfaceTintColor: common.surfaceTintColor,
      forceElevated: common.forceElevated,
      backgroundColor: common.backgroundColor,
      foregroundColor: common.foregroundColor,
      iconTheme: common.iconTheme,
      actionsIconTheme: common.actionsIconTheme,
      primary: common.primary,
      centerTitle: common.centerTitle,
      excludeHeaderSemantics: common.excludeHeaderSemantics,
      titleSpacing: common.titleSpacing,
      collapsedHeight: common.collapsedHeight,
      expandedHeight: common.expandedHeight,
      floating: common.floating,
      pinned: common.pinned ?? false,
      snap: common.snap,
      stretch: common.stretch,
      stretchTriggerOffset: common.stretchTriggerOffset,
      shape: common.shape,
      toolbarHeight: common.toolbarHeight ?? kToolbarHeight,
      leadingWidth: common.leadingWidth,
      toolbarTextStyle: common.toolbarTextStyle,
      titleTextStyle: common.titleTextStyle,
      forceMaterialTransparency: common.forceMaterialTransparency,
      useDefaultSemanticsOrder: common.useDefaultSemanticsOrder,
      clipBehavior: common.clipBehavior,
      actionsPadding: common.actionsPadding,
    );
  }

  Widget _container(BuildContext context, Map<String, Object?> props) {
    final decoration = _boxDecoration(props['decoration'], context);
    final hasDecorationProps =
        props.containsKey('color') ||
        props.containsKey('shape') ||
        props.containsKey('borderRadius') ||
        props.containsKey('radius') ||
        props.containsKey('border') ||
        props.containsKey('gradient') ||
        props.containsKey('image') ||
        props.containsKey('decorationImage') ||
        props.containsKey('backgroundImage') ||
        props.containsKey('boxShadow') ||
        props.containsKey('boxShadows') ||
        props.containsKey('shadow') ||
        props.containsKey('shadows') ||
        props.containsKey('backgroundBlendMode') ||
        props.containsKey('blendMode');
    final effectiveDecoration =
        decoration ??
        (hasDecorationProps ? _boxDecoration(props, context) : null);
    return Container(
      width: _nonNegativeDouble(props['width']),
      height: _nonNegativeDouble(props['height']),
      constraints: _boxConstraints(props['constraints']),
      margin: _nonNegativeEdgeInsets(props['margin']),
      padding: _nonNegativeEdgeInsets(props['padding']),
      alignment: _alignment(props['alignment']),
      decoration: effectiveDecoration,
      foregroundDecoration: _boxDecoration(
        props['foregroundDecoration'],
        context,
      ),
      color: effectiveDecoration == null
          ? _color(props['color'], context)
          : null,
      clipBehavior: effectiveDecoration == null
          ? Clip.none
          : (_clip(props['clipBehavior']) ?? Clip.none),
      child: _maybeChild(context, props),
    );
  }

  Widget _transform(BuildContext context, Map<String, Object?> props) {
    final transformHitTests = _bool(props['transformHitTests']) ?? true;
    final filterQuality = _filterQuality(props['filterQuality']);
    final angle = _double(props['rotate'] ?? props['angle']);
    if (angle != null) {
      return Transform.rotate(
        angle: angle,
        origin: _offset(props['origin']),
        alignment: _alignment(props['alignment']),
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: _child(context, props),
      );
    }
    final scale = _double(props['scale']);
    final scaleX = _double(props['scaleX']);
    final scaleY = _double(props['scaleY']);
    if (scale != null || scaleX != null || scaleY != null) {
      return Transform.scale(
        scale: scale,
        scaleX: scale == null ? scaleX : null,
        scaleY: scale == null ? scaleY : null,
        origin: _offset(props['origin']),
        alignment: _alignment(props['alignment']),
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: _child(context, props),
      );
    }
    final translate = _offset(props['translate']);
    if (translate != null) {
      return Transform.translate(
        offset: translate,
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: _child(context, props),
      );
    }
    final flipX = _bool(props['flipX']) ?? false;
    final flipY = _bool(props['flipY']) ?? false;
    if (flipX || flipY) {
      return Transform.flip(
        flipX: flipX,
        flipY: flipY,
        origin: _offset(props['origin']),
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: _child(context, props),
      );
    }
    return _child(context, props);
  }

  Widget _textInput(BuildContext context, Map<String, Object?> props) {
    return Builder(
      builder: (fieldContext) {
        final onSubmitted = _stringValueCallback(props['onSubmitted']);
        final onValidatedSubmitted = _mapCallback(
          props['onValidatedSubmitted'] ??
              props['onValidatedSubmit'] ??
              props['onSubmit'],
        );
        final onSaved = _stringValueCallback(props['onSaved']);
        final validateOnSubmitted =
            _bool(props['validateOnSubmitted'] ?? props['validateOnSubmit']) ??
            false;
        final obscureText = _bool(props['obscureText']) ?? false;
        final expands = _bool(props['expands']) ?? false;
        final minLines = expands || obscureText
            ? null
            : _positiveInt(props['minLines']);
        final requestedMaxLines = _safeMaxInt(props['maxLines'], minLines);
        final maxLines = expands
            ? null
            : (obscureText ? 1 : requestedMaxLines ?? 1);
        final shouldHandleSubmitted =
            onSubmitted != null ||
            onValidatedSubmitted != null ||
            validateOnSubmitted;
        return TextFormField(
          initialValue: _string(props['value'] ?? props['initialValue']),
          decoration: _inputDecoration(context, props['decoration'] ?? props),
          obscureText: obscureText,
          enabled: _bool(props['enabled']),
          ignorePointers: _bool(props['ignorePointers']),
          readOnly: _bool(props['readOnly']) ?? false,
          autofocus: _bool(props['autofocus']) ?? false,
          autocorrect: _bool(props['autocorrect']) ?? true,
          enableSuggestions: _bool(props['enableSuggestions']) ?? true,
          showCursor: _bool(props['showCursor']),
          obscuringCharacter:
              _singleCharacter(props['obscuringCharacter']) ?? '•',
          minLines: minLines,
          maxLines: maxLines,
          expands: expands,
          maxLength: _textFieldMaxLength(props['maxLength']),
          textAlign: _textAlign(props['textAlign']) ?? TextAlign.start,
          textDirection: _textDirection(props['textDirection']),
          style: _textStyle(props['style'], context),
          strutStyle: _strutStyle(props['strutStyle']),
          keyboardType: _keyboardType(props['keyboardType']),
          textInputAction: _textInputAction(props['textInputAction']),
          textCapitalization:
              _textCapitalization(props['textCapitalization']) ??
              TextCapitalization.none,
          cursorWidth: _positiveDouble(props['cursorWidth']) ?? 2,
          cursorHeight: _positiveDouble(props['cursorHeight']),
          cursorRadius: _nonNegativeRadius(props['cursorRadius']),
          cursorColor: _color(props['cursorColor'], context),
          cursorErrorColor: _color(props['cursorErrorColor'], context),
          selectionHeightStyle: _boxHeightStyle(props['selectionHeightStyle']),
          selectionWidthStyle: _boxWidthStyle(props['selectionWidthStyle']),
          scrollPadding:
              _edgeInsetsOnly(props['scrollPadding']) ??
              const EdgeInsets.all(20),
          dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
          enableInteractiveSelection: _bool(
            props['enableInteractiveSelection'],
          ),
          selectAllOnFocus: _bool(props['selectAllOnFocus']),
          selectionControls: _textSelectionControls(
            props['selectionControls'] ?? props['controls'],
          ),
          scrollPhysics: _scrollPhysics(props),
          restorationId: _string(props['restorationId']),
          enableIMEPersonalizedLearning:
              _bool(props['enableIMEPersonalizedLearning']) ?? true,
          mouseCursor: _mouseCursorOrNull(
            props['mouseCursor'] ?? props['cursor'],
          ),
          contextMenuBuilder: _editableTextContextMenuBuilder(props),
          magnifierConfiguration: _textMagnifierConfiguration(
            props['magnifierConfiguration'] ??
                props['magnifier'] ??
                props['enableMagnifier'],
          ),
          cursorOpacityAnimates: _bool(props['cursorOpacityAnimates']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
          stylusHandwritingEnabled:
              _bool(props['stylusHandwritingEnabled'] ?? props['stylus']) ??
              EditableText.defaultStylusHandwritingEnabled,
          canRequestFocus: _bool(props['canRequestFocus']) ?? true,
          autovalidateMode: _autovalidateMode(props['autovalidateMode']),
          validator: _fieldValidator(
            props['validator'] ?? props['validators'] ?? props['validation'],
          ),
          onChanged: _stringValueCallback(props['onChanged']),
          onTap: _callback(props['onTap']),
          onTapAlwaysCalled: _bool(props['onTapAlwaysCalled']) ?? false,
          onTapOutside: _pointerCallback(props['onTapOutside']),
          onTapUpOutside: _pointerCallback(props['onTapUpOutside']),
          onEditingComplete: _callback(props['onEditingComplete']),
          onSaved: onSaved == null ? null : (value) => onSaved(value ?? ''),
          onFieldSubmitted: shouldHandleSubmitted
              ? (value) {
                  final valid =
                      (validateOnSubmitted || onValidatedSubmitted != null)
                      ? (Form.maybeOf(fieldContext)?.validate() ?? true)
                      : true;
                  onSubmitted?.call(value);
                  onValidatedSubmitted?.call(<String, Object?>{
                    if (props['name'] != null) 'name': props['name'],
                    'value': value,
                    'valid': valid,
                  });
                }
              : null,
        );
      },
    );
  }

  Widget _autocomplete(BuildContext context, Map<String, Object?> props) {
    final options = _autocompleteOptions(
      props['options'] ?? props['items'] ?? props['suggestions'],
    );
    final initialText = _string(
      props['initialValue'] ?? props['value'] ?? props['text'],
    );
    final enabled = _bool(props['enabled']) ?? true;
    return Autocomplete<_AutocompleteOption>(
      initialValue: initialText == null
          ? null
          : TextEditingValue(text: initialText),
      displayStringForOption: (option) => option.label,
      optionsMaxHeight:
          _positiveDouble(props['optionsMaxHeight'] ?? props['maxHeight']) ??
          200,
      optionsViewOpenDirection:
          _optionsViewOpenDirection(
            props['optionsViewOpenDirection'] ??
                props['openDirection'] ??
                props['direction'],
          ) ??
          OptionsViewOpenDirection.down,
      optionsBuilder: (value) =>
          _filteredAutocompleteOptions(options, value.text, props),
      onSelected: enabled
          ? _autocompleteSelectedCallback(
              props['onSelected'],
              props['selectedPayload'] ?? props['payload'],
            )
          : null,
      fieldViewBuilder:
          (fieldContext, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: _inputDecoration(
                context,
                props['decoration'] ?? props,
              ),
              enabled: enabled,
              readOnly: _bool(props['readOnly']) ?? false,
              autofocus:
                  _bool(props['autofocus'] ?? props['autoFocus']) ?? false,
              autocorrect: _bool(props['autocorrect']) ?? true,
              enableSuggestions: _bool(props['enableSuggestions']) ?? true,
              keyboardType: _keyboardType(props['keyboardType']),
              textInputAction: _textInputAction(props['textInputAction']),
              textCapitalization:
                  _textCapitalization(props['textCapitalization']) ??
                  TextCapitalization.none,
              style: _textStyle(props['style'] ?? props['textStyle']),
              textAlign: _textAlign(props['textAlign']) ?? TextAlign.start,
              textDirection: _textDirection(props['textDirection']),
              cursorWidth: _positiveDouble(props['cursorWidth']) ?? 2,
              cursorHeight: _positiveDouble(props['cursorHeight']),
              cursorRadius: _nonNegativeRadius(props['cursorRadius']),
              cursorColor: _color(props['cursorColor']),
              selectionHeightStyle: _boxHeightStyle(
                props['selectionHeightStyle'],
              ),
              selectionWidthStyle: _boxWidthStyle(props['selectionWidthStyle']),
              scrollPadding:
                  _edgeInsetsOnly(props['scrollPadding']) ??
                  const EdgeInsets.all(20),
              dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
              enableInteractiveSelection: _bool(
                props['enableInteractiveSelection'],
              ),
              selectAllOnFocus: _bool(props['selectAllOnFocus']),
              mouseCursor: _mouseCursorOrNull(
                props['mouseCursor'] ?? props['cursor'],
              ),
              contextMenuBuilder: _editableTextContextMenuBuilder(props),
              magnifierConfiguration: _textMagnifierConfiguration(
                props['magnifierConfiguration'] ??
                    props['magnifier'] ??
                    props['enableMagnifier'],
              ),
              restorationId: _string(props['restorationId']),
              clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
              canRequestFocus: _bool(props['canRequestFocus']) ?? true,
              onChanged: _stringValueCallback(
                props['onInput'] ?? props['onChanged'],
              ),
              onTap: _callback(props['onTap']),
              onTapAlwaysCalled: _bool(props['onTapAlwaysCalled']) ?? false,
              onTapOutside: _pointerCallback(props['onTapOutside']),
              onTapUpOutside: _pointerCallback(props['onTapUpOutside']),
              onEditingComplete: _callback(props['onEditingComplete']),
              onSubmitted: (value) {
                _stringValueCallback(props['onSubmitted'])?.call(value);
                onFieldSubmitted();
              },
            );
          },
    );
  }

  Widget _cupertinoTextField(BuildContext context, Map<String, Object?> props) {
    final obscureText = _bool(props['obscureText']) ?? false;
    final expands = _bool(props['expands']) ?? false;
    final minLines = expands || obscureText
        ? null
        : _positiveInt(props['minLines']);
    final requestedMaxLines = _safeMaxInt(props['maxLines'], minLines);
    final maxLines = expands
        ? null
        : (obscureText ? 1 : requestedMaxLines ?? 1);
    return cupertino.CupertinoTextField(
      decoration: _cupertinoTextFieldDecoration(props),
      padding: _edgeInsets(props['padding']) ?? const EdgeInsets.all(7),
      placeholder: _string(props['placeholder'] ?? props['hintText']),
      placeholderStyle: _textStyle(props['placeholderStyle'], context),
      prefix: _optionalWidget(context, props['prefix']),
      prefixMode:
          _overlayVisibilityMode(props['prefixMode']) ??
          cupertino.OverlayVisibilityMode.always,
      suffix: _optionalWidget(context, props['suffix']),
      suffixMode:
          _overlayVisibilityMode(props['suffixMode']) ??
          cupertino.OverlayVisibilityMode.always,
      crossAxisAlignment:
          _crossAxisAlignment(props['crossAxisAlignment']) ??
          CrossAxisAlignment.center,
      clearButtonMode:
          _overlayVisibilityMode(
            props['clearButtonMode'] ?? props['clearButton'],
          ) ??
          cupertino.OverlayVisibilityMode.never,
      clearButtonSemanticLabel: _string(props['clearButtonSemanticLabel']),
      keyboardType: _keyboardType(props['keyboardType']),
      textInputAction: _textInputAction(props['textInputAction']),
      textCapitalization:
          _textCapitalization(props['textCapitalization']) ??
          TextCapitalization.none,
      style: _textStyle(props['style']),
      strutStyle: _strutStyle(props['strutStyle']),
      textAlign: _textAlign(props['textAlign']) ?? TextAlign.start,
      textDirection: _textDirection(props['textDirection']),
      readOnly: _bool(props['readOnly']) ?? false,
      showCursor: _bool(props['showCursor']),
      autofocus: _bool(props['autofocus']) ?? false,
      obscuringCharacter: _singleCharacter(props['obscuringCharacter']) ?? '•',
      obscureText: obscureText,
      autocorrect: _bool(props['autocorrect']) ?? true,
      enableSuggestions: _bool(props['enableSuggestions']) ?? true,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: _cupertinoTextFieldMaxLength(props['maxLength']),
      onChanged: _stringValueCallback(props['onChanged']),
      onEditingComplete: _callback(props['onEditingComplete']),
      onSubmitted: _stringValueCallback(props['onSubmitted']),
      onTapOutside: _pointerCallback(props['onTapOutside']),
      onTapUpOutside: _pointerCallback(props['onTapUpOutside']),
      enabled: _bool(props['enabled']) ?? true,
      cursorWidth: _positiveDouble(props['cursorWidth']) ?? 2,
      cursorHeight: _positiveDouble(props['cursorHeight']),
      cursorRadius:
          _nonNegativeRadius(props['cursorRadius']) ?? const Radius.circular(2),
      cursorOpacityAnimates: _bool(props['cursorOpacityAnimates']) ?? true,
      cursorColor: _color(props['cursorColor']),
      selectionHeightStyle: _boxHeightStyle(props['selectionHeightStyle']),
      selectionWidthStyle: _boxWidthStyle(props['selectionWidthStyle']),
      scrollPadding:
          _edgeInsetsOnly(props['scrollPadding']) ?? const EdgeInsets.all(20),
      dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
      enableInteractiveSelection: _bool(props['enableInteractiveSelection']),
      selectAllOnFocus: _bool(props['selectAllOnFocus']),
      selectionControls: _textSelectionControls(
        props['selectionControls'] ?? props['controls'],
      ),
      onTap: _callback(props['onTap']),
      scrollPhysics: _scrollPhysics(props),
      clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
      restorationId: _string(props['restorationId']),
      stylusHandwritingEnabled:
          _bool(props['stylusHandwritingEnabled'] ?? props['stylus']) ??
          EditableText.defaultStylusHandwritingEnabled,
      enableIMEPersonalizedLearning:
          _bool(props['enableIMEPersonalizedLearning']) ?? true,
      enableInlinePrediction: _bool(props['enableInlinePrediction']),
      contextMenuBuilder: _cupertinoEditableTextContextMenuBuilder(props),
      magnifierConfiguration: _textMagnifierConfiguration(
        props['magnifierConfiguration'] ??
            props['magnifier'] ??
            props['enableMagnifier'],
      ),
    );
  }

  Widget _cupertinoTextFormFieldRow(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final obscureText = _bool(props['obscureText']) ?? false;
    final expands = _bool(props['expands']) ?? false;
    final minLines = expands || obscureText
        ? null
        : _positiveInt(props['minLines']);
    final requestedMaxLines = _safeMaxInt(props['maxLines'], minLines);
    final maxLines = expands
        ? null
        : (obscureText ? 1 : requestedMaxLines ?? 1);
    final onSaved = _stringValueCallback(props['onSaved']);
    return cupertino.CupertinoTextFormFieldRow(
      initialValue: _string(props['value'] ?? props['initialValue']),
      prefix: _optionalWidget(context, props['prefix'] ?? props['label']),
      padding: _edgeInsets(props['padding']),
      decoration: _cupertinoTextFieldDecoration(props),
      keyboardType: _keyboardType(props['keyboardType']),
      textCapitalization:
          _textCapitalization(props['textCapitalization']) ??
          TextCapitalization.none,
      textInputAction: _textInputAction(props['textInputAction']),
      style: _textStyle(props['style']),
      strutStyle: _strutStyle(props['strutStyle']),
      textDirection: _textDirection(props['textDirection']),
      textAlign: _textAlign(props['textAlign']) ?? TextAlign.start,
      autofocus: _bool(props['autofocus']) ?? false,
      readOnly: _bool(props['readOnly']) ?? false,
      showCursor: _bool(props['showCursor']),
      obscuringCharacter: _singleCharacter(props['obscuringCharacter']) ?? '•',
      obscureText: obscureText,
      autocorrect: _bool(props['autocorrect']) ?? true,
      enableSuggestions: _bool(props['enableSuggestions']) ?? true,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: _cupertinoTextFieldMaxLength(props['maxLength']),
      onChanged: _stringValueCallback(props['onChanged']),
      onTap: _callback(props['onTap']),
      onEditingComplete: _callback(props['onEditingComplete']),
      onFieldSubmitted: _stringValueCallback(
        props['onFieldSubmitted'] ?? props['onSubmitted'],
      ),
      onSaved: onSaved == null ? null : (value) => onSaved(value ?? ''),
      validator: _fieldValidator(
        props['validator'] ?? props['validators'] ?? props['validation'],
      ),
      enabled: _bool(props['enabled']),
      cursorWidth: _positiveDouble(props['cursorWidth']) ?? 2,
      cursorHeight: _positiveDouble(props['cursorHeight']),
      cursorColor: _color(props['cursorColor']),
      keyboardAppearance: _brightness(props['keyboardAppearance']),
      scrollPadding:
          _edgeInsetsOnly(props['scrollPadding']) ?? const EdgeInsets.all(20),
      enableInteractiveSelection:
          _bool(props['enableInteractiveSelection']) ?? true,
      selectionControls: _textSelectionControls(
        props['selectionControls'] ?? props['controls'],
      ),
      scrollPhysics: _scrollPhysics(props),
      autovalidateMode:
          _autovalidateMode(props['autovalidateMode']) ??
          AutovalidateMode.disabled,
      placeholder: _string(props['placeholder'] ?? props['hintText']),
      placeholderStyle: _textStyle(props['placeholderStyle']),
      contextMenuBuilder: _cupertinoEditableTextContextMenuBuilder(props),
      selectionHeightStyle: _boxHeightStyle(props['selectionHeightStyle']),
      selectionWidthStyle: _boxWidthStyle(props['selectionWidthStyle']),
      restorationId: _string(props['restorationId']),
    );
  }

  Widget _cupertinoSearchTextField(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final decoration = _boxDecoration(props['decoration'], context);
    Icon icon(Object? widgetSpec, Object? iconSpec, IconData fallback) {
      if (widgetSpec is Map) {
        final props = _props(_stringMap(widgetSpec));
        return Icon(
          _iconData(
                props['icon'] ?? props['name'] ?? props['data'] ?? iconSpec,
              ) ??
              fallback,
          size: _nonNegativeDouble(props['size']),
          color: _color(props['color'], context),
          semanticLabel: _string(
            props['semanticLabel'] ?? props['semanticsLabel'],
          ),
        );
      }
      return Icon(_iconData(widgetSpec ?? iconSpec) ?? fallback);
    }

    return cupertino.CupertinoSearchTextField(
      onChanged: _stringValueCallback(props['onChanged']),
      onSubmitted: _stringValueCallback(props['onSubmitted']),
      style: _textStyle(props['style'], context),
      placeholder: _string(props['placeholder'] ?? props['hintText']),
      placeholderStyle: _textStyle(props['placeholderStyle'], context),
      decoration: decoration,
      backgroundColor: decoration == null
          ? _color(props['backgroundColor'])
          : null,
      borderRadius: decoration == null
          ? _borderRadius(props['borderRadius'] ?? props['radius'])
          : null,
      keyboardType: _keyboardType(props['keyboardType']) ?? TextInputType.text,
      padding:
          _edgeInsets(props['padding']) ??
          const EdgeInsetsDirectional.fromSTEB(5.5, 8, 5.5, 8),
      itemColor:
          _color(props['itemColor']) ??
          cupertino.CupertinoColors.secondaryLabel,
      itemSize: _positiveDouble(props['itemSize']) ?? 20,
      prefixInsets:
          _edgeInsets(props['prefixInsets']) ??
          const EdgeInsetsDirectional.fromSTEB(6, 8, 0, 8),
      prefixIcon: icon(
        props['prefixIcon'],
        props['prefixIconName'],
        cupertino.CupertinoIcons.search,
      ),
      suffixInsets:
          _edgeInsets(props['suffixInsets']) ??
          const EdgeInsetsDirectional.fromSTEB(0, 8, 5, 8),
      suffixIcon: icon(
        props['suffixIcon'],
        props['suffixIconName'],
        cupertino.CupertinoIcons.xmark_circle_fill,
      ),
      suffixMode:
          _overlayVisibilityMode(props['suffixMode']) ??
          cupertino.OverlayVisibilityMode.editing,
      onSuffixTap: _callback(props['onSuffixTap']),
      restorationId: _string(props['restorationId']),
      enableIMEPersonalizedLearning:
          _bool(props['enableIMEPersonalizedLearning']) ?? true,
      autofocus: _bool(props['autofocus']) ?? false,
      onTap: _callback(props['onTap']),
      autocorrect: _bool(props['autocorrect']) ?? true,
      enabled: _bool(props['enabled']),
      cursorWidth: _positiveDouble(props['cursorWidth']) ?? 2,
      cursorHeight: _positiveDouble(props['cursorHeight']),
      cursorRadius:
          _nonNegativeRadius(props['cursorRadius']) ?? const Radius.circular(2),
      cursorOpacityAnimates: _bool(props['cursorOpacityAnimates']) ?? true,
      cursorColor: _color(props['cursorColor']),
    );
  }

  FormFieldValidator<String>? _fieldValidator(Object? value) {
    final rules = _validationRules(value);
    if (rules.isEmpty) {
      return null;
    }
    return (value) {
      final text = value ?? '';
      for (final rule in rules) {
        final message = _validateTextRule(rule, text);
        if (message != null) {
          return message;
        }
      }
      return null;
    };
  }

  List<Map<String, Object?>> _validationRules(Object? value) {
    final rules = <Map<String, Object?>>[];

    void add(Object? rule) {
      if (rule == null || rule == false) {
        return;
      }
      if (rule == true) {
        rules.add(<String, Object?>{'type': 'required'});
        return;
      }
      if (rule is String) {
        final type = _validationType(rule);
        rules.add(<String, Object?>{
          'type': type == 'message' ? 'required' : rule,
          if (type == 'message') 'message': rule,
        });
        return;
      }
      if (rule is List) {
        for (final item in rule) {
          add(item);
        }
        return;
      }
      if (rule is! Map) {
        return;
      }

      final map = _stringMap(rule);
      add(map['rules'] ?? map['validators']);

      final type = _string(
        map['type'] ?? map['kind'] ?? map['rule'] ?? map['name'],
      );
      if (type != null) {
        rules.add(map);
      }
      if (_bool(map['required']) ?? false) {
        rules.add(<String, Object?>{
          'type': 'required',
          'message': map['requiredMessage'] ?? map['message'],
        });
      }
      final minLength = map['minLength'] ?? map['minlength'];
      if (minLength != null) {
        rules.add(<String, Object?>{
          'type': 'minLength',
          'value': minLength,
          'message': map['minLengthMessage'] ?? map['message'],
        });
      }
      final maxLength = map['maxLength'] ?? map['maxlength'];
      if (maxLength != null) {
        rules.add(<String, Object?>{
          'type': 'maxLength',
          'value': maxLength,
          'message': map['maxLengthMessage'] ?? map['message'],
        });
      }
      final pattern = map['pattern'] ?? map['regex'];
      if (pattern != null) {
        rules.add(<String, Object?>{
          'type': 'pattern',
          'pattern': pattern,
          'message': map['patternMessage'] ?? map['message'],
        });
      }
      if (_bool(map['email']) ?? false) {
        rules.add(<String, Object?>{
          'type': 'email',
          'message': map['emailMessage'] ?? map['message'],
        });
      }
      final min = map['min'] ?? map['minimum'];
      if (min != null) {
        rules.add(<String, Object?>{
          'type': 'min',
          'value': min,
          'message': map['minMessage'] ?? map['message'],
        });
      }
      final max = map['max'] ?? map['maximum'];
      if (max != null) {
        rules.add(<String, Object?>{
          'type': 'max',
          'value': max,
          'message': map['maxMessage'] ?? map['message'],
        });
      }
    }

    add(value);
    return rules;
  }

  String? _validateTextRule(Map<String, Object?> rule, String text) {
    final type = _validationType(
      _string(rule['type'] ?? rule['kind'] ?? rule['rule'] ?? rule['name']) ??
          'required',
    );
    final trimmed = text.trim();
    switch (type) {
      case 'required':
      case 'notempty':
        if (trimmed.isEmpty) {
          return _validationMessage(rule, 'Required');
        }
        break;
      case 'minlength':
        final limit = _int(rule['value'] ?? rule['length'] ?? rule['min']);
        if (limit != null && text.length < limit) {
          return _validationMessage(rule, 'Must be at least $limit characters');
        }
        break;
      case 'maxlength':
        final limit = _int(rule['value'] ?? rule['length'] ?? rule['max']);
        if (limit != null && text.length > limit) {
          return _validationMessage(rule, 'Must be at most $limit characters');
        }
        break;
      case 'length':
        final length = _int(rule['value'] ?? rule['length']);
        if (length != null && text.length != length) {
          return _validationMessage(rule, 'Must be $length characters');
        }
        break;
      case 'email':
        if (trimmed.isNotEmpty &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
          return _validationMessage(rule, 'Enter a valid email address');
        }
        break;
      case 'pattern':
      case 'regex':
      case 'matches':
        final pattern = _string(
          rule['pattern'] ?? rule['regex'] ?? rule['value'],
        );
        if (pattern != null && pattern.isNotEmpty) {
          try {
            if (!RegExp(pattern).hasMatch(text)) {
              return _validationMessage(rule, 'Invalid format');
            }
          } on FormatException {
            return _validationMessage(rule, 'Invalid format');
          }
        }
        break;
      case 'min':
      case 'minimum':
        final limit = _double(rule['value'] ?? rule['min'] ?? rule['minimum']);
        final current = double.tryParse(text);
        if (trimmed.isNotEmpty &&
            limit != null &&
            (current == null || current < limit)) {
          return _validationMessage(rule, 'Must be at least $limit');
        }
        break;
      case 'max':
      case 'maximum':
        final limit = _double(rule['value'] ?? rule['max'] ?? rule['maximum']);
        final current = double.tryParse(text);
        if (trimmed.isNotEmpty &&
            limit != null &&
            (current == null || current > limit)) {
          return _validationMessage(rule, 'Must be at most $limit');
        }
        break;
      case 'equals':
      case 'equal':
        final expected = _string(rule['value'] ?? rule['equals'] ?? rule['to']);
        if (expected != null && text != expected) {
          return _validationMessage(rule, 'Values do not match');
        }
        break;
    }
    return null;
  }

  String _validationType(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
    switch (normalized) {
      case 'required':
      case 'notempty':
      case 'minlength':
      case 'maxlength':
      case 'length':
      case 'email':
      case 'pattern':
      case 'regex':
      case 'matches':
      case 'min':
      case 'minimum':
      case 'max':
      case 'maximum':
      case 'equals':
      case 'equal':
        return normalized;
    }
    return 'message';
  }

  String _validationMessage(Map<String, Object?> rule, String fallback) {
    return _string(rule['message'] ?? rule['errorText'] ?? rule['error']) ??
        fallback;
  }

  InputDecoration _inputDecoration(BuildContext context, Object? value) {
    final map = value is Map ? _stringMap(value) : <String, Object?>{};
    final label = _optionalWidget(context, map['labelWidget'] ?? map['label']);
    final helper = _optionalWidget(
      context,
      map['helperWidget'] ?? map['helper'],
    );
    final hint = _optionalWidget(context, map['hintWidget'] ?? map['hint']);
    final error = _optionalWidget(context, map['errorWidget'] ?? map['error']);
    final prefix = _optionalWidget(context, map['prefix']);
    final suffix = _optionalWidget(context, map['suffix']);
    final counter = _optionalWidget(context, map['counter']);
    return InputDecoration(
      icon: _optionalWidget(context, map['icon']),
      iconColor: _color(map['iconColor'], context),
      label: label,
      labelText: label == null
          ? _string(map['labelText'] ?? map['label'])
          : null,
      labelStyle: _textStyle(map['labelStyle'], context),
      floatingLabelStyle: _textStyle(map['floatingLabelStyle'], context),
      helper: helper,
      helperText: helper == null
          ? _string(map['helperText'] ?? map['helper'])
          : null,
      helperStyle: _textStyle(map['helperStyle'], context),
      helperMaxLines: _int(map['helperMaxLines']),
      hintText: hint == null ? _string(map['hintText'] ?? map['hint']) : null,
      hint: hint,
      hintStyle: _textStyle(map['hintStyle'], context),
      hintTextDirection: _textDirection(map['hintTextDirection']),
      hintMaxLines: _int(map['hintMaxLines']),
      hintFadeDuration: _duration(map['hintFadeDuration']),
      maintainHintSize: _bool(map['maintainHintSize']) ?? true,
      maintainLabelSize: _bool(map['maintainLabelSize']) ?? false,
      error: error,
      errorText: error == null
          ? _string(map['errorText'] ?? map['error'])
          : null,
      errorStyle: _textStyle(map['errorStyle'], context),
      errorMaxLines: _int(map['errorMaxLines']),
      floatingLabelBehavior: _floatingLabelBehavior(
        map['floatingLabelBehavior'],
      ),
      floatingLabelAlignment: _floatingLabelAlignment(
        map['floatingLabelAlignment'],
      ),
      isCollapsed: _bool(map['isCollapsed']) ?? false,
      isDense: _bool(map['isDense']),
      contentPadding: _edgeInsets(map['contentPadding']),
      prefixIcon: _optionalWidget(context, map['prefixIcon']),
      prefixIconConstraints: _boxConstraints(map['prefixIconConstraints']),
      prefix: prefix,
      prefixText: prefix == null ? _string(map['prefixText']) : null,
      prefixStyle: _textStyle(map['prefixStyle'], context),
      prefixIconColor: _color(map['prefixIconColor'], context),
      suffixIcon: _optionalWidget(context, map['suffixIcon']),
      suffix: suffix,
      suffixText: suffix == null ? _string(map['suffixText']) : null,
      suffixStyle: _textStyle(map['suffixStyle'], context),
      suffixIconColor: _color(map['suffixIconColor'], context),
      suffixIconConstraints: _boxConstraints(map['suffixIconConstraints']),
      counter: counter,
      counterText: counter == null ? _string(map['counterText']) : null,
      counterStyle: _textStyle(map['counterStyle'], context),
      filled: _bool(map['filled']),
      fillColor: _color(map['fillColor'], context),
      focusColor: _color(map['focusColor'], context),
      hoverColor: _color(map['hoverColor'], context),
      border: _inputBorder(map['border']),
      enabledBorder: _inputBorder(map['enabledBorder']),
      focusedBorder: _inputBorder(map['focusedBorder']),
      errorBorder: _inputBorder(map['errorBorder']),
      focusedErrorBorder: _inputBorder(map['focusedErrorBorder']),
      disabledBorder: _inputBorder(map['disabledBorder']),
      enabled: _bool(map['enabled']) ?? true,
      semanticCounterText: _string(map['semanticCounterText']),
      alignLabelWithHint: _bool(map['alignLabelWithHint']),
      constraints: _boxConstraints(map['constraints']),
      visualDensity: _visualDensity(map['visualDensity']),
    );
  }

  Widget _cupertinoListSection(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final insetGrouped =
        _bool(props['insetGrouped']) ??
        props['variant']?.toString().toLowerCase() == 'insetgrouped' ||
            props['variant']?.toString().toLowerCase() == 'inset_grouped';
    final children = buildWidgets(context, props['children']);
    if (insetGrouped) {
      return cupertino.CupertinoListSection.insetGrouped(
        header: _optionalWidget(context, props['header']),
        footer: _optionalWidget(context, props['footer']),
        margin: _edgeInsets(props['margin']),
        backgroundColor:
            _color(props['backgroundColor']) ??
            cupertino.CupertinoColors.systemGroupedBackground,
        decoration: _boxDecoration(props['decoration']),
        clipBehavior: _clip(props['clipBehavior']) ?? Clip.hardEdge,
        dividerMargin: _nonNegativeDouble(props['dividerMargin']) ?? 20,
        additionalDividerMargin: _nonNegativeDouble(
          props['additionalDividerMargin'],
        ),
        topMargin: _nonNegativeDouble(props['topMargin']),
        hasLeading: _bool(props['hasLeading']) ?? true,
        separatorColor: _color(props['separatorColor']),
        children: children,
      );
    }
    return cupertino.CupertinoListSection(
      header: _optionalWidget(context, props['header']),
      footer: _optionalWidget(context, props['footer']),
      margin: _edgeInsets(props['margin']) ?? EdgeInsets.zero,
      backgroundColor:
          _color(props['backgroundColor']) ??
          cupertino.CupertinoColors.systemGroupedBackground,
      decoration: _boxDecoration(props['decoration']),
      clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
      dividerMargin: _nonNegativeDouble(props['dividerMargin']) ?? 20,
      additionalDividerMargin: _nonNegativeDouble(
        props['additionalDividerMargin'],
      ),
      topMargin: _nonNegativeDouble(props['topMargin']) ?? 22,
      hasLeading: _bool(props['hasLeading']) ?? true,
      separatorColor: _color(props['separatorColor']),
      children: children,
    );
  }

  Widget _cupertinoListTile(BuildContext context, Map<String, Object?> props) {
    final notched =
        _bool(props['notched']) ??
        props['variant']?.toString().toLowerCase() == 'notched';
    final title =
        _optionalWidget(context, props['title'] ?? props['child']) ??
        _label(context, props);
    if (notched) {
      return cupertino.CupertinoListTile.notched(
        title: title,
        subtitle: _optionalWidget(context, props['subtitle']),
        additionalInfo: _optionalWidget(
          context,
          props['additionalInfo'] ?? props['additional'],
        ),
        leading: _optionalWidget(context, props['leading']),
        trailing: _optionalWidget(context, props['trailing']),
        onTap: _callback(props['onTap'] ?? props['onPressed']),
        backgroundColor: _color(props['backgroundColor']),
        backgroundColorActivated: _color(props['backgroundColorActivated']),
        padding: _edgeInsets(props['padding']),
        leadingSize: _positiveDouble(props['leadingSize']) ?? 30,
        leadingToTitle: _nonNegativeDouble(props['leadingToTitle']) ?? 12,
      );
    }
    return cupertino.CupertinoListTile(
      title: title,
      subtitle: _optionalWidget(context, props['subtitle']),
      additionalInfo: _optionalWidget(
        context,
        props['additionalInfo'] ?? props['additional'],
      ),
      leading: _optionalWidget(context, props['leading']),
      trailing: _optionalWidget(context, props['trailing']),
      onTap: _callback(props['onTap'] ?? props['onPressed']),
      backgroundColor: _color(props['backgroundColor']),
      backgroundColorActivated: _color(props['backgroundColorActivated']),
      padding: _edgeInsets(props['padding']),
      leadingSize: _positiveDouble(props['leadingSize']) ?? 28,
      leadingToTitle: _nonNegativeDouble(props['leadingToTitle']) ?? 16,
    );
  }

  Widget _cupertinoFormSection(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final insetGrouped =
        _bool(props['insetGrouped']) ??
        _normalizedToken(props['variant']) == 'insetgrouped';
    final children = buildWidgets(context, props['children']);
    final safeChildren = children.isEmpty
        ? const <Widget>[SizedBox.shrink()]
        : children;
    final margin = _edgeInsets(props['margin']);
    if (insetGrouped) {
      if (margin == null) {
        return cupertino.CupertinoFormSection.insetGrouped(
          header: _optionalWidget(context, props['header']),
          footer: _optionalWidget(context, props['footer']),
          backgroundColor:
              _color(props['backgroundColor']) ??
              cupertino.CupertinoColors.systemGroupedBackground,
          decoration: _boxDecoration(props['decoration']),
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          children: safeChildren,
        );
      }
      return cupertino.CupertinoFormSection.insetGrouped(
        header: _optionalWidget(context, props['header']),
        footer: _optionalWidget(context, props['footer']),
        margin: margin,
        backgroundColor:
            _color(props['backgroundColor']) ??
            cupertino.CupertinoColors.systemGroupedBackground,
        decoration: _boxDecoration(props['decoration']),
        clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
        children: safeChildren,
      );
    }
    return cupertino.CupertinoFormSection(
      header: _optionalWidget(context, props['header']),
      footer: _optionalWidget(context, props['footer']),
      margin: _edgeInsets(props['margin']) ?? EdgeInsets.zero,
      backgroundColor:
          _color(props['backgroundColor']) ??
          cupertino.CupertinoColors.systemGroupedBackground,
      decoration: _boxDecoration(props['decoration']),
      clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
      children: safeChildren,
    );
  }

  Widget _cupertinoFormRow(BuildContext context, Map<String, Object?> props) {
    return cupertino.CupertinoFormRow(
      prefix: _optionalWidget(context, props['prefix'] ?? props['label']),
      padding: _edgeInsets(props['padding']),
      helper: _optionalWidget(context, props['helper']),
      error: _optionalWidget(context, props['error']),
      child: _child(context, props),
    );
  }

  Widget _cupertinoPicker(BuildContext context, Map<String, Object?> props) {
    final children = buildWidgets(context, props['children'] ?? props['items']);
    final safeChildren = children.isEmpty
        ? const <Widget>[SizedBox.shrink()]
        : children;
    final initialItem = _nonNegativeInt(
      props['initialItem'] ?? props['selectedIndex'] ?? props['index'],
    );
    final selectionOverlayValue = props['selectionOverlay'] ?? props['overlay'];

    return cupertino.CupertinoPicker(
      diameterRatio: _positiveDouble(props['diameterRatio']) ?? 1.07,
      backgroundColor: _color(props['backgroundColor']),
      offAxisFraction: _double(props['offAxisFraction']) ?? 0,
      useMagnifier: _bool(props['useMagnifier']) ?? false,
      magnification: _positiveDouble(props['magnification']) ?? 1,
      scrollController: initialItem == null
          ? null
          : FixedExtentScrollController(initialItem: initialItem),
      squeeze: _positiveDouble(props['squeeze']) ?? 1.45,
      changeReportingBehavior:
          _changeReportingBehavior(props['changeReportingBehavior']) ??
          ChangeReportingBehavior.onScrollUpdate,
      itemExtent:
          _positiveDouble(
            props['itemExtent'] ?? props['extent'] ?? props['height'],
          ) ??
          32,
      onSelectedItemChanged:
          _intCallback(
            props['onSelectedItemChanged'] ??
                props['onChanged'] ??
                props['onSelected'],
          ) ??
          (_) {},
      selectionOverlay: _featureDisabled(selectionOverlayValue)
          ? null
          : (_optionalWidget(context, selectionOverlayValue) ??
                const cupertino.CupertinoPickerDefaultSelectionOverlay()),
      looping: _bool(props['looping']) ?? false,
      children: safeChildren,
    );
  }

  Widget _cupertinoPickerDefaultSelectionOverlay(Map<String, Object?> props) {
    return cupertino.CupertinoPickerDefaultSelectionOverlay(
      background:
          _color(
            props['background'] ?? props['backgroundColor'] ?? props['color'],
          ) ??
          cupertino.CupertinoColors.tertiarySystemFill,
      capStartEdge: _bool(props['capStartEdge']) ?? true,
      capEndEdge: _bool(props['capEndEdge']) ?? true,
    );
  }

  Widget _cupertinoDatePicker(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final mode =
        _cupertinoDatePickerMode(props['mode']) ??
        cupertino.CupertinoDatePickerMode.dateAndTime;
    final dates = _cupertinoDateRange(
      initial:
          props['initialDateTime'] ??
          props['initialDate'] ??
          props['value'] ??
          props['date'],
      minimum: props['minimumDate'] ?? props['minDate'] ?? props['firstDate'],
      maximum: props['maximumDate'] ?? props['maxDate'] ?? props['lastDate'],
      mode: mode,
      minuteInterval: _timePickerInterval(props['minuteInterval']),
      minimumYear: _positiveInt(props['minimumYear']),
      maximumYear: _positiveInt(props['maximumYear']),
    );
    final showTimeSeparator =
        (mode == cupertino.CupertinoDatePickerMode.time ||
            mode == cupertino.CupertinoDatePickerMode.dateAndTime) &&
        (_bool(props['showTimeSeparator']) ?? false);

    return cupertino.CupertinoDatePicker(
      mode: mode,
      onDateTimeChanged:
          _dateTimeValueCallback(
            props['onDateTimeChanged'] ?? props['onChanged'],
          ) ??
          (_) {},
      initialDateTime: dates.initial,
      minimumDate: dates.minimum,
      maximumDate: dates.maximum,
      minimumYear: dates.minimumYear,
      maximumYear: dates.maximumYear,
      minuteInterval: dates.minuteInterval,
      use24hFormat: _bool(props['use24hFormat']) ?? false,
      dateOrder: _cupertinoDatePickerDateOrder(props['dateOrder']),
      backgroundColor: _color(props['backgroundColor']),
      showDayOfWeek:
          mode == cupertino.CupertinoDatePickerMode.date &&
          (_bool(props['showDayOfWeek']) ?? false),
      showTimeSeparator: showTimeSeparator,
      itemExtent: _positiveDouble(props['itemExtent']) ?? 32,
      selectionOverlayBuilder: _cupertinoSelectionOverlayBuilder(
        props['selectionOverlayBuilder'] ??
            props['selectionOverlay'] ??
            props['overlay'],
      ),
      changeReportingBehavior:
          _changeReportingBehavior(props['changeReportingBehavior']) ??
          ChangeReportingBehavior.onScrollUpdate,
    );
  }

  Widget _cupertinoTimerPicker(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final minuteInterval = _timePickerInterval(props['minuteInterval']);
    final secondInterval = _timePickerInterval(props['secondInterval']);
    return cupertino.CupertinoTimerPicker(
      mode:
          _cupertinoTimerPickerMode(props['mode']) ??
          cupertino.CupertinoTimerPickerMode.hms,
      initialTimerDuration: _cupertinoTimerDuration(
        props['initialTimerDuration'] ?? props['duration'] ?? props['value'],
        minuteInterval: minuteInterval,
        secondInterval: secondInterval,
      ),
      minuteInterval: minuteInterval,
      secondInterval: secondInterval,
      alignment: _alignment(props['alignment']) ?? Alignment.center,
      backgroundColor: _color(props['backgroundColor']),
      itemExtent: _positiveDouble(props['itemExtent']) ?? 32,
      onTimerDurationChanged:
          _durationValueCallback(
            props['onTimerDurationChanged'] ?? props['onChanged'],
          ) ??
          (_) {},
      changeReportingBehavior:
          _changeReportingBehavior(props['changeReportingBehavior']) ??
          ChangeReportingBehavior.onScrollUpdate,
      selectionOverlayBuilder: _cupertinoSelectionOverlayBuilder(
        props['selectionOverlayBuilder'] ??
            props['selectionOverlay'] ??
            props['overlay'],
      ),
    );
  }

  cupertino.SelectionOverlayBuilder? _cupertinoSelectionOverlayBuilder(
    Object? value,
  ) {
    if (value == null || _bool(value) == true) {
      return null;
    }
    if (_featureDisabled(value)) {
      return (_, {required columnCount, required selectedIndex}) => null;
    }
    return (overlayContext, {required columnCount, required selectedIndex}) {
      return _optionalWidget(overlayContext, value);
    };
  }

  Widget _listTile(BuildContext context, Map<String, Object?> props) {
    return ListTile(
      leading: _optionalWidget(context, props['leading']),
      title: _optionalWidget(context, props['title']) ?? _label(context, props),
      subtitle: _optionalWidget(context, props['subtitle']),
      trailing: _optionalWidget(context, props['trailing']),
      selected: _bool(props['selected']) ?? false,
      enabled: _bool(props['enabled']) ?? true,
      dense: _bool(props['dense']),
      isThreeLine: _bool(props['isThreeLine']) ?? false,
      contentPadding: _edgeInsets(props['contentPadding']),
      tileColor: _color(props['tileColor']),
      selectedTileColor: _color(props['selectedTileColor']),
      textColor: _color(props['textColor']),
      iconColor: _color(props['iconColor']),
      onTap: _callback(props['onTap'] ?? props['onPressed']),
      onLongPress: _callback(props['onLongPress']),
      onFocusChange: _valueCallback(props['onFocusChange']),
      mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
          ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
          : null,
      autofocus: _bool(props['autofocus']) ?? false,
      shape: _outlinedBorder(props['shape']),
      style: _listTileStyle(props['style']),
      selectedColor: _color(props['selectedColor']),
      focusColor: _color(props['focusColor']),
      hoverColor: _color(props['hoverColor']),
      splashColor: _color(props['splashColor']),
      titleTextStyle: _textStyle(props['titleTextStyle']),
      subtitleTextStyle: _textStyle(props['subtitleTextStyle']),
      leadingAndTrailingTextStyle: _textStyle(
        props['leadingAndTrailingTextStyle'],
      ),
      visualDensity: _visualDensity(props['visualDensity']),
      horizontalTitleGap: _double(props['horizontalTitleGap']),
      minVerticalPadding: _double(props['minVerticalPadding']),
      minLeadingWidth: _double(props['minLeadingWidth']),
      minTileHeight: _double(props['minTileHeight']),
      enableFeedback: _bool(props['enableFeedback']),
      titleAlignment: _listTileTitleAlignment(props['titleAlignment']),
    );
  }

  Widget _expansionPanelList(
    BuildContext context,
    Map<String, Object?> props, {
    required bool radio,
  }) {
    final useRadio =
        radio ||
        _bool(props['radio']) == true ||
        _normalizedToken(props['variant'] ?? props['type']) == 'radio';
    final panels = _expansionPanels(
      context,
      props['panels'] ?? props['children'] ?? props['items'],
      radio: useRadio,
    );
    if (panels.isEmpty) {
      return const SizedBox.shrink();
    }
    final animationDuration =
        _duration(props['animationDuration'] ?? props['duration']) ??
        kThemeAnimationDuration;
    final expandedHeaderPadding =
        _edgeInsetsOnly(
          props['expandedHeaderPadding'] ?? props['headerPadding'],
        ) ??
        const EdgeInsets.symmetric(vertical: 16);
    final dividerColor = _color(props['dividerColor']);
    final elevation = _safeMaterialElevation(props['elevation']) ?? 2;
    final expandIconColor = _color(
      props['expandIconColor'] ?? props['iconColor'],
    );
    final materialGapSize =
        _nonNegativeDouble(props['materialGapSize'] ?? props['gapSize']) ?? 16;
    final expansionCallback = _expansionPanelCallback(
      props['expansionCallback'] ??
          props['onExpansionChanged'] ??
          props['onChanged'],
      panels,
    );
    if (useRadio) {
      return ExpansionPanelList.radio(
        children: panels.cast<ExpansionPanelRadio>(),
        expansionCallback: expansionCallback,
        animationDuration: animationDuration,
        initialOpenPanelValue: _matchingExpansionPanelValue(
          props['initialOpenPanelValue'] ??
              props['initialValue'] ??
              props['openValue'] ??
              props['value'],
          panels,
        ),
        expandedHeaderPadding: expandedHeaderPadding,
        dividerColor: dividerColor,
        elevation: elevation,
        expandIconColor: expandIconColor,
        materialGapSize: materialGapSize,
      );
    }
    return ExpansionPanelList(
      children: panels,
      expansionCallback: expansionCallback,
      animationDuration: animationDuration,
      expandedHeaderPadding: expandedHeaderPadding,
      dividerColor: dividerColor,
      elevation: elevation,
      expandIconColor: expandIconColor,
      materialGapSize: materialGapSize,
    );
  }

  Widget _switch(Map<String, Object?> props) {
    final enabled = _bool(props['enabled']) ?? true;
    final adaptive = _bool(props['adaptive']) == true;
    final onChanged = enabled ? _valueCallback(props['onChanged']) : null;
    final activeThumbColor = _color(
      props['activeThumbColor'] ?? props['activeColor'],
    );
    if (adaptive) {
      return Switch.adaptive(
        value: _bool(props['value']) ?? false,
        onChanged: onChanged,
        activeThumbColor: activeThumbColor,
        activeTrackColor: _color(props['activeTrackColor']),
        inactiveThumbColor: _color(props['inactiveThumbColor']),
        inactiveTrackColor: _color(props['inactiveTrackColor']),
        activeThumbImage: _imageProvider(props['activeThumbImage']),
        inactiveThumbImage: _imageProvider(props['inactiveThumbImage']),
        thumbColor: _stateColor(props['thumbColor']),
        trackColor: _stateColor(props['trackColor']),
        trackOutlineColor: _stateColor(props['trackOutlineColor']),
        trackOutlineWidth: _stateDouble(props['trackOutlineWidth']),
        thumbIcon: _stateIcon(props['thumbIcon']),
        materialTapTargetSize: _materialTapTargetSize(
          props['materialTapTargetSize'] ?? props['tapTargetSize'],
        ),
        dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
        mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
            ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
            : null,
        focusColor: _color(props['focusColor']),
        hoverColor: _color(props['hoverColor']),
        overlayColor: _stateColor(props['overlayColor']),
        splashRadius: _double(props['splashRadius']),
        onFocusChange: _valueCallback(props['onFocusChange']),
        autofocus: _bool(props['autofocus']) ?? false,
        padding: _edgeInsets(props['padding']),
      );
    }
    return Switch(
      value: _bool(props['value']) ?? false,
      onChanged: onChanged,
      activeThumbColor: activeThumbColor,
      activeTrackColor: _color(props['activeTrackColor']),
      inactiveThumbColor: _color(props['inactiveThumbColor']),
      inactiveTrackColor: _color(props['inactiveTrackColor']),
      activeThumbImage: _imageProvider(props['activeThumbImage']),
      inactiveThumbImage: _imageProvider(props['inactiveThumbImage']),
      thumbColor: _stateColor(props['thumbColor']),
      trackColor: _stateColor(props['trackColor']),
      trackOutlineColor: _stateColor(props['trackOutlineColor']),
      trackOutlineWidth: _stateDouble(props['trackOutlineWidth']),
      thumbIcon: _stateIcon(props['thumbIcon']),
      materialTapTargetSize: _materialTapTargetSize(
        props['materialTapTargetSize'] ?? props['tapTargetSize'],
      ),
      dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
      mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
          ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
          : null,
      focusColor: _color(props['focusColor']),
      hoverColor: _color(props['hoverColor']),
      overlayColor: _stateColor(props['overlayColor']),
      splashRadius: _double(props['splashRadius']),
      onFocusChange: _valueCallback(props['onFocusChange']),
      autofocus: _bool(props['autofocus']) ?? false,
      padding: _edgeInsets(props['padding']),
    );
  }

  Widget _cupertinoSwitch(Map<String, Object?> props) {
    final enabled = _bool(props['enabled']) ?? true;
    final activeThumbImage = _imageProvider(props['activeThumbImage']);
    final inactiveThumbImage = _imageProvider(props['inactiveThumbImage']);
    return cupertino.CupertinoSwitch(
      value: _bool(props['value']) ?? false,
      onChanged: enabled ? _valueCallback(props['onChanged']) : null,
      activeTrackColor: _color(
        props['activeTrackColor'] ?? props['activeColor'],
      ),
      inactiveTrackColor: _color(
        props['inactiveTrackColor'] ?? props['trackColor'],
      ),
      thumbColor: _color(props['thumbColor']),
      inactiveThumbColor: _color(props['inactiveThumbColor']),
      applyTheme: _bool(props['applyTheme']),
      focusColor: _color(props['focusColor']),
      onLabelColor: _color(props['onLabelColor']),
      offLabelColor: _color(props['offLabelColor']),
      activeThumbImage: activeThumbImage,
      onActiveThumbImageError: activeThumbImage == null
          ? null
          : _imageErrorCallback(
              props['onActiveThumbImageError'],
              'activeThumbImage',
            ),
      inactiveThumbImage: inactiveThumbImage,
      onInactiveThumbImageError: inactiveThumbImage == null
          ? null
          : _imageErrorCallback(
              props['onInactiveThumbImageError'],
              'inactiveThumbImage',
            ),
      trackOutlineColor: _stateColor(props['trackOutlineColor']),
      trackOutlineWidth: _stateDouble(props['trackOutlineWidth']),
      thumbIcon: _stateIcon(props['thumbIcon']),
      mouseCursor: _stateRequiredMouseCursor(
        props['mouseCursor'] ?? props['cursor'],
      ),
      onFocusChange: _valueCallback(props['onFocusChange']),
      autofocus: _bool(props['autofocus']) ?? false,
      dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
    );
  }

  Widget _cupertinoCheckbox(Map<String, Object?> props) {
    final tristate = _bool(props['tristate']) ?? false;
    final enabled = _bool(props['enabled']) ?? true;
    final value = tristate
        ? _bool(props['value'])
        : (_bool(props['value']) ?? false);
    return cupertino.CupertinoCheckbox(
      value: value,
      tristate: tristate,
      onChanged: enabled ? _nullableBoolCallback(props['onChanged']) : null,
      mouseCursor: _mouseCursorOrNull(props['mouseCursor'] ?? props['cursor']),
      activeColor: _color(props['activeColor']),
      fillColor: _stateColor(props['fillColor']),
      checkColor: _color(props['checkColor']),
      focusColor: _color(props['focusColor']),
      autofocus: _bool(props['autofocus']) ?? false,
      side: _borderSide(props['side']),
      shape: _outlinedBorder(props['shape']),
      tapTargetSize: _nonNegativeSize(props['tapTargetSize'] ?? props['size']),
      semanticLabel: _string(props['semanticLabel']),
    );
  }

  Widget _cupertinoRadio(Map<String, Object?> props) {
    final enabled = _bool(props['enabled']) ?? true;
    final value = props['value'] ?? props['id'] ?? props['name'] ?? true;
    final onChanged = _objectCallback(props['onChanged']);
    final radio = cupertino.CupertinoRadio<Object>(
      value: value,
      mouseCursor: _mouseCursorOrNull(props['mouseCursor'] ?? props['cursor']),
      toggleable: _bool(props['toggleable']) ?? false,
      activeColor: _color(props['activeColor']),
      inactiveColor: _color(props['inactiveColor']),
      fillColor: _color(props['fillColor']),
      focusColor: _color(props['focusColor']),
      autofocus: _bool(props['autofocus']) ?? false,
      useCheckmarkStyle: _bool(props['useCheckmarkStyle']) ?? false,
      enabled: enabled,
    );
    return RadioGroup<Object>(
      groupValue: props['groupValue'] ?? props['selected'],
      onChanged: enabled ? (value) => onChanged?.call(value) : (_) {},
      child: radio,
    );
  }

  Widget _switchListTile(BuildContext context, Map<String, Object?> props) {
    final enabled = _bool(props['enabled']) ?? true;
    final adaptive = _bool(props['adaptive']) == true;
    final onChanged = enabled
        ? _valueCallback(props['onChanged'] ?? props['onTap'])
        : null;
    final title =
        _optionalWidget(context, props['title']) ?? _label(context, props);
    final subtitle = _optionalWidget(context, props['subtitle']);
    final secondary = _optionalWidget(
      context,
      props['secondary'] ?? props['leading'],
    );
    final activeThumbColor = _color(
      props['activeThumbColor'] ?? props['activeColor'],
    );
    final commonTile = (
      tileColor: _color(props['tileColor']),
      isThreeLine: _bool(props['isThreeLine']),
      dense: _bool(props['dense']),
      contentPadding: _edgeInsets(props['contentPadding']),
      selected: _bool(props['selected']) ?? false,
      controlAffinity: _listTileControlAffinity(props['controlAffinity']),
      shape: _outlinedBorder(props['shape']),
      selectedTileColor: _color(props['selectedTileColor']),
      visualDensity: _visualDensity(props['visualDensity']),
      enableFeedback: _bool(props['enableFeedback']),
      horizontalTitleGap: _double(props['horizontalTitleGap']),
      minVerticalPadding: _double(props['minVerticalPadding']),
      minLeadingWidth: _double(props['minLeadingWidth']),
      minTileHeight: _double(props['minTileHeight']),
      hoverColor: _color(props['hoverColor']),
    );
    if (adaptive) {
      return SwitchListTile.adaptive(
        value: _bool(props['value']) ?? false,
        onChanged: onChanged,
        activeThumbColor: activeThumbColor,
        activeTrackColor: _color(props['activeTrackColor']),
        inactiveThumbColor: _color(props['inactiveThumbColor']),
        inactiveTrackColor: _color(props['inactiveTrackColor']),
        activeThumbImage: _imageProvider(props['activeThumbImage']),
        inactiveThumbImage: _imageProvider(props['inactiveThumbImage']),
        thumbColor: _stateColor(props['thumbColor']),
        trackColor: _stateColor(props['trackColor']),
        trackOutlineColor: _stateColor(props['trackOutlineColor']),
        thumbIcon: _stateIcon(props['thumbIcon']),
        materialTapTargetSize: _materialTapTargetSize(
          props['materialTapTargetSize'] ?? props['tapTargetSize'],
        ),
        dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
        mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
            ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
            : null,
        overlayColor: _stateColor(props['overlayColor']),
        splashRadius: _double(props['splashRadius']),
        onFocusChange: _valueCallback(props['onFocusChange']),
        autofocus: _bool(props['autofocus']) ?? false,
        title: title,
        subtitle: subtitle,
        secondary: secondary,
        tileColor: commonTile.tileColor,
        isThreeLine: commonTile.isThreeLine,
        dense: commonTile.dense,
        contentPadding: commonTile.contentPadding,
        selected: commonTile.selected,
        controlAffinity: commonTile.controlAffinity,
        shape: commonTile.shape,
        selectedTileColor: commonTile.selectedTileColor,
        visualDensity: commonTile.visualDensity,
        enableFeedback: commonTile.enableFeedback,
        horizontalTitleGap: commonTile.horizontalTitleGap,
        minVerticalPadding: commonTile.minVerticalPadding,
        minLeadingWidth: commonTile.minLeadingWidth,
        minTileHeight: commonTile.minTileHeight,
        hoverColor: commonTile.hoverColor,
      );
    }
    return SwitchListTile(
      value: _bool(props['value']) ?? false,
      onChanged: onChanged,
      activeThumbColor: activeThumbColor,
      activeTrackColor: _color(props['activeTrackColor']),
      inactiveThumbColor: _color(props['inactiveThumbColor']),
      inactiveTrackColor: _color(props['inactiveTrackColor']),
      activeThumbImage: _imageProvider(props['activeThumbImage']),
      inactiveThumbImage: _imageProvider(props['inactiveThumbImage']),
      thumbColor: _stateColor(props['thumbColor']),
      trackColor: _stateColor(props['trackColor']),
      trackOutlineColor: _stateColor(props['trackOutlineColor']),
      thumbIcon: _stateIcon(props['thumbIcon']),
      materialTapTargetSize: _materialTapTargetSize(
        props['materialTapTargetSize'] ?? props['tapTargetSize'],
      ),
      dragStartBehavior: _dragStartBehavior(props['dragStartBehavior']),
      mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
          ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
          : null,
      overlayColor: _stateColor(props['overlayColor']),
      splashRadius: _double(props['splashRadius']),
      onFocusChange: _valueCallback(props['onFocusChange']),
      autofocus: _bool(props['autofocus']) ?? false,
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      tileColor: commonTile.tileColor,
      isThreeLine: commonTile.isThreeLine,
      dense: commonTile.dense,
      contentPadding: commonTile.contentPadding,
      selected: commonTile.selected,
      controlAffinity: commonTile.controlAffinity,
      shape: commonTile.shape,
      selectedTileColor: commonTile.selectedTileColor,
      visualDensity: commonTile.visualDensity,
      enableFeedback: commonTile.enableFeedback,
      horizontalTitleGap: commonTile.horizontalTitleGap,
      minVerticalPadding: commonTile.minVerticalPadding,
      minLeadingWidth: commonTile.minLeadingWidth,
      minTileHeight: commonTile.minTileHeight,
      hoverColor: commonTile.hoverColor,
    );
  }

  Widget _checkbox(Map<String, Object?> props) {
    final tristate = _bool(props['tristate']) ?? false;
    final enabled = _bool(props['enabled']) ?? true;
    final value = tristate
        ? _bool(props['value'])
        : (_bool(props['value']) ?? false);
    final constructor = _bool(props['adaptive']) == true
        ? Checkbox.adaptive
        : Checkbox.new;
    return constructor(
      value: value,
      tristate: tristate,
      onChanged: enabled ? _nullableBoolCallback(props['onChanged']) : null,
      mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
          ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
          : null,
      activeColor: _color(props['activeColor']),
      fillColor: _stateColor(props['fillColor']),
      checkColor: _color(props['checkColor']),
      focusColor: _color(props['focusColor']),
      hoverColor: _color(props['hoverColor']),
      overlayColor: _stateColor(props['overlayColor']),
      splashRadius: _double(props['splashRadius']),
      materialTapTargetSize: _materialTapTargetSize(
        props['materialTapTargetSize'] ?? props['tapTargetSize'],
      ),
      visualDensity: _visualDensity(props['visualDensity']),
      autofocus: _bool(props['autofocus']) ?? false,
      shape: _outlinedBorder(props['shape']),
      side: _borderSide(props['side']),
      isError: _bool(props['isError'] ?? props['error']) ?? false,
      semanticLabel: _string(props['semanticLabel']),
    );
  }

  Widget _checkboxListTile(BuildContext context, Map<String, Object?> props) {
    final tristate = _bool(props['tristate']) ?? false;
    final enabled = _bool(props['enabled']) ?? true;
    final value = tristate
        ? _bool(props['value'])
        : (_bool(props['value']) ?? false);
    final constructor = _bool(props['adaptive']) == true
        ? CheckboxListTile.adaptive
        : CheckboxListTile.new;
    return constructor(
      value: value,
      tristate: tristate,
      onChanged: enabled
          ? _nullableBoolCallback(props['onChanged'] ?? props['onTap'])
          : null,
      mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
          ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
          : null,
      activeColor: _color(props['activeColor']),
      fillColor: _stateColor(props['fillColor']),
      checkColor: _color(props['checkColor']),
      hoverColor: _color(props['hoverColor']),
      overlayColor: _stateColor(props['overlayColor']),
      splashRadius: _double(props['splashRadius']),
      materialTapTargetSize: _materialTapTargetSize(
        props['materialTapTargetSize'] ?? props['tapTargetSize'],
      ),
      visualDensity: _visualDensity(props['visualDensity']),
      autofocus: _bool(props['autofocus']) ?? false,
      shape: _outlinedBorder(props['shape']),
      side: _borderSide(props['side']),
      isError: _bool(props['isError'] ?? props['error']) ?? false,
      enabled: enabled,
      tileColor: _color(props['tileColor']),
      title: _optionalWidget(context, props['title']) ?? _label(context, props),
      subtitle: _optionalWidget(context, props['subtitle']),
      isThreeLine: _bool(props['isThreeLine']),
      dense: _bool(props['dense']),
      secondary: _optionalWidget(
        context,
        props['secondary'] ?? props['leading'],
      ),
      selected: _bool(props['selected']) ?? false,
      controlAffinity: _listTileControlAffinity(props['controlAffinity']),
      contentPadding: _edgeInsets(props['contentPadding']),
      checkboxShape: _outlinedBorder(props['checkboxShape']),
      selectedTileColor: _color(props['selectedTileColor']),
      onFocusChange: _valueCallback(props['onFocusChange']),
      enableFeedback: _bool(props['enableFeedback']),
      horizontalTitleGap: _double(props['horizontalTitleGap']),
      minVerticalPadding: _double(props['minVerticalPadding']),
      minLeadingWidth: _double(props['minLeadingWidth']),
      minTileHeight: _double(props['minTileHeight']),
      checkboxSemanticLabel: _string(props['checkboxSemanticLabel']),
      checkboxScaleFactor: _double(props['checkboxScaleFactor']) ?? 1,
      titleAlignment: _listTileTitleAlignment(props['titleAlignment']),
    );
  }

  Widget _radio(Map<String, Object?> props) {
    final enabled = _bool(props['enabled']) ?? true;
    final adaptive = _bool(props['adaptive']) == true;
    final radio = adaptive
        ? Radio<Object?>.adaptive(
            value: props['value'],
            mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
                ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
                : null,
            toggleable: _bool(props['toggleable']) ?? false,
            activeColor: _color(props['activeColor']),
            fillColor: _stateColor(props['fillColor']),
            focusColor: _color(props['focusColor']),
            hoverColor: _color(props['hoverColor']),
            overlayColor: _stateColor(props['overlayColor']),
            splashRadius: _double(props['splashRadius']),
            materialTapTargetSize: _materialTapTargetSize(
              props['materialTapTargetSize'] ?? props['tapTargetSize'],
            ),
            visualDensity: _visualDensity(props['visualDensity']),
            autofocus: _bool(props['autofocus']) ?? false,
            enabled: enabled,
            backgroundColor: _stateColor(props['backgroundColor']),
            side: _borderSide(props['side']),
            innerRadius: _stateDouble(props['innerRadius']),
          )
        : Radio<Object?>(
            value: props['value'],
            mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
                ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
                : null,
            toggleable: _bool(props['toggleable']) ?? false,
            activeColor: _color(props['activeColor']),
            fillColor: _stateColor(props['fillColor']),
            focusColor: _color(props['focusColor']),
            hoverColor: _color(props['hoverColor']),
            overlayColor: _stateColor(props['overlayColor']),
            splashRadius: _double(props['splashRadius']),
            materialTapTargetSize: _materialTapTargetSize(
              props['materialTapTargetSize'] ?? props['tapTargetSize'],
            ),
            visualDensity: _visualDensity(props['visualDensity']),
            autofocus: _bool(props['autofocus']) ?? false,
            enabled: enabled,
            backgroundColor: _stateColor(props['backgroundColor']),
            side: _borderSide(props['side']),
            innerRadius: _stateDouble(props['innerRadius']),
          );
    return RadioGroup<Object?>(
      groupValue: props['groupValue'],
      onChanged: enabled
          ? (_objectCallback(props['onChanged']) ?? (_) {})
          : (_) {},
      child: radio,
    );
  }

  Widget _radioListTile(BuildContext context, Map<String, Object?> props) {
    final enabled = _bool(props['enabled']) ?? true;
    final adaptive = _bool(props['adaptive']) == true;
    final title =
        _optionalWidget(context, props['title']) ?? _label(context, props);
    final subtitle = _optionalWidget(context, props['subtitle']);
    final secondary = _optionalWidget(
      context,
      props['secondary'] ?? props['leading'],
    );
    final tile = adaptive
        ? RadioListTile<Object?>.adaptive(
            value: props['value'],
            mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
                ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
                : null,
            toggleable: _bool(props['toggleable']) ?? false,
            activeColor: _color(props['activeColor']),
            fillColor: _stateColor(props['fillColor']),
            hoverColor: _color(props['hoverColor']),
            overlayColor: _stateColor(props['overlayColor']),
            splashRadius: _double(props['splashRadius']),
            materialTapTargetSize: _materialTapTargetSize(
              props['materialTapTargetSize'] ?? props['tapTargetSize'],
            ),
            title: title,
            subtitle: subtitle,
            isThreeLine: _bool(props['isThreeLine']),
            dense: _bool(props['dense']),
            secondary: secondary,
            selected: _bool(props['selected']) ?? false,
            controlAffinity: _listTileControlAffinity(props['controlAffinity']),
            autofocus: _bool(props['autofocus']) ?? false,
            contentPadding: _edgeInsets(props['contentPadding']),
            shape: _outlinedBorder(props['shape']),
            tileColor: _color(props['tileColor']),
            selectedTileColor: _color(props['selectedTileColor']),
            visualDensity: _visualDensity(props['visualDensity']),
            onFocusChange: _valueCallback(props['onFocusChange']),
            enableFeedback: _bool(props['enableFeedback']),
            horizontalTitleGap: _double(props['horizontalTitleGap']),
            minVerticalPadding: _double(props['minVerticalPadding']),
            minLeadingWidth: _double(props['minLeadingWidth']),
            minTileHeight: _double(props['minTileHeight']),
            radioScaleFactor: _double(props['radioScaleFactor']) ?? 1,
            titleAlignment: _listTileTitleAlignment(props['titleAlignment']),
            enabled: enabled,
            radioBackgroundColor: _stateColor(
              props['radioBackgroundColor'] ?? props['backgroundColor'],
            ),
            radioSide: _borderSide(props['radioSide'] ?? props['side']),
            radioInnerRadius: _stateDouble(
              props['radioInnerRadius'] ?? props['innerRadius'],
            ),
          )
        : RadioListTile<Object?>(
            value: props['value'],
            mouseCursor: _hasAny(props, const ['mouseCursor', 'cursor'])
                ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
                : null,
            toggleable: _bool(props['toggleable']) ?? false,
            activeColor: _color(props['activeColor']),
            fillColor: _stateColor(props['fillColor']),
            hoverColor: _color(props['hoverColor']),
            overlayColor: _stateColor(props['overlayColor']),
            splashRadius: _double(props['splashRadius']),
            materialTapTargetSize: _materialTapTargetSize(
              props['materialTapTargetSize'] ?? props['tapTargetSize'],
            ),
            title: title,
            subtitle: subtitle,
            isThreeLine: _bool(props['isThreeLine']),
            dense: _bool(props['dense']),
            secondary: secondary,
            selected: _bool(props['selected']) ?? false,
            controlAffinity: _listTileControlAffinity(props['controlAffinity']),
            autofocus: _bool(props['autofocus']) ?? false,
            contentPadding: _edgeInsets(props['contentPadding']),
            shape: _outlinedBorder(props['shape']),
            tileColor: _color(props['tileColor']),
            selectedTileColor: _color(props['selectedTileColor']),
            visualDensity: _visualDensity(props['visualDensity']),
            onFocusChange: _valueCallback(props['onFocusChange']),
            enableFeedback: _bool(props['enableFeedback']),
            horizontalTitleGap: _double(props['horizontalTitleGap']),
            minVerticalPadding: _double(props['minVerticalPadding']),
            minLeadingWidth: _double(props['minLeadingWidth']),
            minTileHeight: _double(props['minTileHeight']),
            radioScaleFactor: _double(props['radioScaleFactor']) ?? 1,
            titleAlignment: _listTileTitleAlignment(props['titleAlignment']),
            enabled: enabled,
            radioBackgroundColor: _stateColor(
              props['radioBackgroundColor'] ?? props['backgroundColor'],
            ),
            radioSide: _borderSide(props['radioSide'] ?? props['side']),
            radioInnerRadius: _stateDouble(
              props['radioInnerRadius'] ?? props['innerRadius'],
            ),
          );
    return RadioGroup<Object?>(
      groupValue: props['groupValue'],
      onChanged: enabled
          ? (_objectCallback(props['onChanged'] ?? props['onTap']) ?? (_) {})
          : (_) {},
      child: tile,
    );
  }

  Widget _chip(BuildContext context, String type, Map<String, Object?> props) {
    final label = _label(context, props);
    final avatar = _optionalWidget(context, props['avatar']);
    final deleteIcon = _optionalWidget(context, props['deleteIcon']);
    final onDeleted = _callback(props['onDeleted']);
    final onSelected = _bool(props['enabled']) == false
        ? null
        : _valueCallback(props['onSelected'] ?? props['onChanged']);
    final onPressed = _bool(props['enabled']) == false
        ? null
        : _callback(props['onPressed'] ?? props['onTap']);
    final shape = _outlinedBorder(
      props['shape'] ??
          (_hasAny(props, const ['borderRadius', 'radius', 'side'])
              ? props
              : null),
    );
    final color = props.containsKey('color')
        ? _state(_color(props['color']))
        : null;
    final chipAnimationStyle = _chipAnimationStyle(
      props['chipAnimationStyle'] ?? props['animationStyle'],
    );
    final mouseCursor = _hasAny(props, const ['mouseCursor', 'cursor'])
        ? _mouseCursor(props['mouseCursor'] ?? props['cursor'])
        : null;
    final elevated =
        _bool(props['elevated']) == true ||
        _string(props['variant'])?.toLowerCase() == 'elevated';

    switch (type) {
      case 'actionchip':
        final chip = elevated ? ActionChip.elevated : ActionChip.new;
        return chip(
          label: label,
          avatar: avatar,
          labelStyle: _textStyle(props['labelStyle']),
          labelPadding: _edgeInsets(props['labelPadding']),
          onPressed: onPressed,
          pressElevation: _nonNegativeDouble(props['pressElevation']),
          tooltip: _string(props['tooltip']),
          side: _borderSide(props['side']),
          shape: shape,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          autofocus: _bool(props['autofocus']) ?? false,
          color: color,
          backgroundColor: _color(props['backgroundColor']),
          disabledColor: _color(props['disabledColor']),
          padding: _edgeInsets(props['padding']),
          visualDensity: _visualDensity(props['visualDensity']),
          materialTapTargetSize: _materialTapTargetSize(
            props['materialTapTargetSize'] ?? props['tapTargetSize'],
          ),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          iconTheme: _iconThemeData(props['iconTheme']),
          avatarBoxConstraints: _boxConstraints(props['avatarBoxConstraints']),
          chipAnimationStyle: chipAnimationStyle,
          mouseCursor: mouseCursor,
        );
      case 'filterchip':
        final chip = elevated ? FilterChip.elevated : FilterChip.new;
        return chip(
          label: label,
          avatar: avatar,
          labelStyle: _textStyle(props['labelStyle']),
          labelPadding: _edgeInsets(props['labelPadding']),
          selected: _bool(props['selected']) ?? false,
          onSelected: onSelected,
          deleteIcon: deleteIcon,
          onDeleted: onDeleted,
          deleteIconColor: _color(props['deleteIconColor']),
          deleteButtonTooltipMessage: _string(
            props['deleteButtonTooltipMessage'] ?? props['deleteTooltip'],
          ),
          pressElevation: _nonNegativeDouble(props['pressElevation']),
          disabledColor: _color(props['disabledColor']),
          selectedColor: _color(props['selectedColor']),
          tooltip: _string(props['tooltip']),
          side: _borderSide(props['side']),
          shape: shape,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          autofocus: _bool(props['autofocus']) ?? false,
          color: color,
          backgroundColor: _color(props['backgroundColor']),
          padding: _edgeInsets(props['padding']),
          visualDensity: _visualDensity(props['visualDensity']),
          materialTapTargetSize: _materialTapTargetSize(
            props['materialTapTargetSize'] ?? props['tapTargetSize'],
          ),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          iconTheme: _iconThemeData(props['iconTheme']),
          selectedShadowColor: _color(props['selectedShadowColor']),
          showCheckmark: _bool(props['showCheckmark']),
          checkmarkColor: _color(props['checkmarkColor']),
          avatarBorder:
              _outlinedBorder(props['avatarBorder']) ?? const CircleBorder(),
          avatarBoxConstraints: _boxConstraints(props['avatarBoxConstraints']),
          deleteIconBoxConstraints: _boxConstraints(
            props['deleteIconBoxConstraints'],
          ),
          chipAnimationStyle: chipAnimationStyle,
          mouseCursor: mouseCursor,
        );
      case 'choicechip':
        final chip = elevated ? ChoiceChip.elevated : ChoiceChip.new;
        return chip(
          label: label,
          avatar: avatar,
          labelStyle: _textStyle(props['labelStyle']),
          labelPadding: _edgeInsets(props['labelPadding']),
          onSelected: onSelected,
          pressElevation: _nonNegativeDouble(props['pressElevation']),
          selected: _bool(props['selected']) ?? false,
          selectedColor: _color(props['selectedColor']),
          disabledColor: _color(props['disabledColor']),
          tooltip: _string(props['tooltip']),
          side: _borderSide(props['side']),
          shape: shape,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          autofocus: _bool(props['autofocus']) ?? false,
          color: color,
          backgroundColor: _color(props['backgroundColor']),
          padding: _edgeInsets(props['padding']),
          visualDensity: _visualDensity(props['visualDensity']),
          materialTapTargetSize: _materialTapTargetSize(
            props['materialTapTargetSize'] ?? props['tapTargetSize'],
          ),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          iconTheme: _iconThemeData(props['iconTheme']),
          selectedShadowColor: _color(props['selectedShadowColor']),
          showCheckmark: _bool(props['showCheckmark']),
          checkmarkColor: _color(props['checkmarkColor']),
          avatarBorder:
              _outlinedBorder(props['avatarBorder']) ?? const CircleBorder(),
          avatarBoxConstraints: _boxConstraints(props['avatarBoxConstraints']),
          chipAnimationStyle: chipAnimationStyle,
          mouseCursor: mouseCursor,
        );
      case 'inputchip':
        return InputChip(
          label: label,
          avatar: avatar,
          labelStyle: _textStyle(props['labelStyle']),
          labelPadding: _edgeInsets(props['labelPadding']),
          selected: _bool(props['selected']) ?? false,
          isEnabled: _bool(props['enabled'] ?? props['isEnabled']) ?? true,
          onSelected: onSelected,
          deleteIcon: deleteIcon,
          onDeleted: onDeleted,
          deleteIconColor: _color(props['deleteIconColor']),
          deleteButtonTooltipMessage: _string(
            props['deleteButtonTooltipMessage'] ?? props['deleteTooltip'],
          ),
          onPressed: onSelected == null ? onPressed : null,
          pressElevation: _nonNegativeDouble(props['pressElevation']),
          disabledColor: _color(props['disabledColor']),
          selectedColor: _color(props['selectedColor']),
          tooltip: _string(props['tooltip']),
          side: _borderSide(props['side']),
          shape: shape,
          clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
          autofocus: _bool(props['autofocus']) ?? false,
          color: color,
          backgroundColor: _color(props['backgroundColor']),
          padding: _edgeInsets(props['padding']),
          visualDensity: _visualDensity(props['visualDensity']),
          materialTapTargetSize: _materialTapTargetSize(
            props['materialTapTargetSize'] ?? props['tapTargetSize'],
          ),
          elevation: _nonNegativeDouble(props['elevation']),
          shadowColor: _color(props['shadowColor']),
          surfaceTintColor: _color(props['surfaceTintColor']),
          iconTheme: _iconThemeData(props['iconTheme']),
          selectedShadowColor: _color(props['selectedShadowColor']),
          showCheckmark: _bool(props['showCheckmark']),
          checkmarkColor: _color(props['checkmarkColor']),
          avatarBorder:
              _outlinedBorder(props['avatarBorder']) ?? const CircleBorder(),
          avatarBoxConstraints: _boxConstraints(props['avatarBoxConstraints']),
          deleteIconBoxConstraints: _boxConstraints(
            props['deleteIconBoxConstraints'],
          ),
          chipAnimationStyle: chipAnimationStyle,
          mouseCursor: mouseCursor,
        );
    }

    return Chip(
      label: label,
      avatar: avatar,
      labelStyle: _textStyle(props['labelStyle']),
      labelPadding: _edgeInsets(props['labelPadding']),
      deleteIcon: deleteIcon,
      onDeleted: onDeleted,
      deleteIconColor: _color(props['deleteIconColor']),
      deleteButtonTooltipMessage: _string(
        props['deleteButtonTooltipMessage'] ?? props['deleteTooltip'],
      ),
      side: _borderSide(props['side']),
      shape: shape,
      clipBehavior: _clip(props['clipBehavior']) ?? Clip.none,
      autofocus: _bool(props['autofocus']) ?? false,
      color: color,
      backgroundColor: _color(props['backgroundColor']),
      padding: _edgeInsets(props['padding']),
      visualDensity: _visualDensity(props['visualDensity']),
      materialTapTargetSize: _materialTapTargetSize(
        props['materialTapTargetSize'] ?? props['tapTargetSize'],
      ),
      elevation: _nonNegativeDouble(props['elevation']),
      shadowColor: _color(props['shadowColor']),
      surfaceTintColor: _color(props['surfaceTintColor']),
      iconTheme: _iconThemeData(props['iconTheme']),
      avatarBoxConstraints: _boxConstraints(props['avatarBoxConstraints']),
      deleteIconBoxConstraints: _boxConstraints(
        props['deleteIconBoxConstraints'],
      ),
      chipAnimationStyle: chipAnimationStyle,
      mouseCursor: mouseCursor,
    );
  }

  Widget _button(
    BuildContext context,
    String type,
    Map<String, Object?> props,
  ) {
    final onPressed = _callback(props['onPressed'] ?? props['onTap']);
    final onLongPress = _callback(props['onLongPress']);
    final style = _buttonStyle(props['style'] ?? props, context);
    final autofocus = _bool(props['autofocus']) ?? false;
    final clipBehavior = _clip(props['clipBehavior']) ?? Clip.none;
    final icon = props['child'] == null && props['icon'] != null
        ? _iconWidget(context, props['icon'])
        : null;
    final iconAlignment = _iconAlignment(props['iconAlignment']);
    if (icon != null) {
      final label = _buttonLabel(context, props);
      switch (type) {
        case 'elevatedbutton':
          return ElevatedButton.icon(
            onPressed: onPressed,
            onLongPress: onLongPress,
            style: style,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            icon: icon,
            label: label,
            iconAlignment: iconAlignment,
          );
        case 'filledbutton':
          if (_bool(props['tonal']) ?? false) {
            return FilledButton.tonalIcon(
              onPressed: onPressed,
              onLongPress: onLongPress,
              style: style,
              autofocus: autofocus,
              clipBehavior: clipBehavior,
              icon: icon,
              label: label,
              iconAlignment: iconAlignment,
            );
          }
          return FilledButton.icon(
            onPressed: onPressed,
            onLongPress: onLongPress,
            style: style,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            icon: icon,
            label: label,
            iconAlignment: iconAlignment,
          );
        case 'outlinedbutton':
          return OutlinedButton.icon(
            onPressed: onPressed,
            onLongPress: onLongPress,
            style: style,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            icon: icon,
            label: label,
            iconAlignment: iconAlignment,
          );
        default:
          return TextButton.icon(
            onPressed: onPressed,
            onLongPress: onLongPress,
            style: style,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            icon: icon,
            label: label,
            iconAlignment: iconAlignment,
          );
      }
    }
    final child = _buttonChild(context, props);
    switch (type) {
      case 'elevatedbutton':
        return ElevatedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          style: style,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
      case 'filledbutton':
        if (_bool(props['tonal']) ?? false) {
          return FilledButton.tonal(
            onPressed: onPressed,
            onLongPress: onLongPress,
            style: style,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            child: child,
          );
        }
        return FilledButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          style: style,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
      case 'outlinedbutton':
        return OutlinedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          style: style,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
      default:
        return TextButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          style: style,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
    }
  }

  Widget _cupertinoButton(BuildContext context, Map<String, Object?> props) {
    final child = _buttonChild(context, props);
    final onPressed = _callback(props['onPressed'] ?? props['onTap']);
    final onLongPress = _callback(props['onLongPress']);
    final sizeStyle =
        _cupertinoButtonSize(props['sizeStyle'] ?? props['size']) ??
        cupertino.CupertinoButtonSize.large;
    final padding = _edgeInsets(props['padding']);
    final color = _color(props['color'] ?? props['backgroundColor'], context);
    final foregroundColor = _color(props['foregroundColor'], context);
    final disabledColor =
        _color(props['disabledColor'], context) ??
        cupertino.CupertinoColors.quaternarySystemFill;
    final minimumSize = _nonNegativeSize(
      props['minimumSize'] ?? props['minSize'],
    );
    final pressedOpacity = props.containsKey('pressedOpacity')
        ? _unitDouble(props['pressedOpacity'])
        : 0.4;
    final borderRadius = _borderRadius(
      props['borderRadius'] ?? props['radius'],
    );
    final alignment = _alignment(props['alignment']) ?? Alignment.center;
    final focusColor = _color(props['focusColor'], context);
    final onFocusChange = _valueCallback(props['onFocusChange']);
    final autofocus = _bool(props['autofocus']) ?? false;
    final mouseCursor = _mouseCursorOrNull(
      props['mouseCursor'] ?? props['cursor'],
    );
    final variant = _normalizedToken(
      props['variant'] ?? props['style'] ?? props['type'],
    );
    if (variant == 'filled') {
      return cupertino.CupertinoButton.filled(
        onPressed: onPressed,
        sizeStyle: sizeStyle,
        padding: padding,
        color: color,
        disabledColor: disabledColor,
        foregroundColor: foregroundColor,
        minimumSize: minimumSize,
        pressedOpacity: pressedOpacity,
        borderRadius: borderRadius,
        alignment: alignment,
        focusColor: focusColor,
        onFocusChange: onFocusChange,
        autofocus: autofocus,
        mouseCursor: mouseCursor,
        onLongPress: onLongPress,
        child: child,
      );
    }
    if (variant == 'tinted') {
      return cupertino.CupertinoButton.tinted(
        onPressed: onPressed,
        sizeStyle: sizeStyle,
        padding: padding,
        color: color,
        foregroundColor: foregroundColor,
        disabledColor:
            _color(props['disabledColor'], context) ??
            cupertino.CupertinoColors.tertiarySystemFill,
        minimumSize: minimumSize,
        pressedOpacity: pressedOpacity,
        borderRadius: borderRadius,
        alignment: alignment,
        focusColor: focusColor,
        onFocusChange: onFocusChange,
        autofocus: autofocus,
        mouseCursor: mouseCursor,
        onLongPress: onLongPress,
        child: child,
      );
    }
    return cupertino.CupertinoButton(
      onPressed: onPressed,
      sizeStyle: sizeStyle,
      padding: padding,
      color: color,
      foregroundColor: foregroundColor,
      disabledColor: disabledColor,
      minimumSize: minimumSize,
      pressedOpacity: pressedOpacity,
      borderRadius: borderRadius,
      alignment: alignment,
      focusColor: focusColor,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      mouseCursor: mouseCursor,
      onLongPress: onLongPress,
      child: child,
    );
  }

  Widget _buttonLabel(BuildContext context, Map<String, Object?> props) {
    final labelSpec = props['label'] ?? props['text'];
    return labelSpec == null ? const Text('') : buildWidget(context, labelSpec);
  }

  Widget _buttonChild(BuildContext context, Map<String, Object?> props) {
    final child = _optionalWidget(context, props['child']);
    if (child != null) {
      return child;
    }
    return _buttonLabel(context, props);
  }

  Widget _iconButton(BuildContext context, Map<String, Object?> props) {
    final icon = _iconWidget(context, props['icon'] ?? props['name']);
    final selectedIcon = _optionalWidget(context, props['selectedIcon']);
    final isSelected = _bool(props['isSelected'] ?? props['selected']);
    final tooltip = _string(props['tooltip']);
    final onPressed = _callback(props['onPressed'] ?? props['onTap']);
    final color = _color(props['color'], context);
    final iconSize =
        _nonNegativeDouble(props['iconSize']) ??
        _nonNegativeDouble(props['size']) ??
        24;
    final style = _buttonStyle(props['style'] ?? props, context);
    final onLongPress = _callback(props['onLongPress']);
    final visualDensity = _visualDensity(props['visualDensity']);
    final padding = _edgeInsets(props['padding']);
    final alignment = _alignment(props['alignment']);
    final splashRadius = _positiveDouble(props['splashRadius']);
    final focusColor = _color(props['focusColor'], context);
    final hoverColor = _color(props['hoverColor'], context);
    final highlightColor = _color(props['highlightColor'], context);
    final splashColor = _color(props['splashColor'], context);
    final disabledColor = _color(props['disabledColor'], context);
    final enableFeedback = _bool(props['enableFeedback']);
    final constraints = _boxConstraints(props['constraints']);
    final autofocus = _bool(props['autofocus']) ?? false;
    final variant = props['variant']?.toString().toLowerCase();
    switch (variant) {
      case 'filled':
        return IconButton.filled(
          icon: icon,
          selectedIcon: selectedIcon,
          isSelected: isSelected,
          tooltip: tooltip,
          onPressed: onPressed,
          color: color,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onLongPress: onLongPress,
          autofocus: autofocus,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
        );
      case 'filledtonal':
      case 'filled_tonal':
        return IconButton.filledTonal(
          icon: icon,
          selectedIcon: selectedIcon,
          isSelected: isSelected,
          tooltip: tooltip,
          onPressed: onPressed,
          color: color,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onLongPress: onLongPress,
          autofocus: autofocus,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
        );
      case 'outlined':
        return IconButton.outlined(
          icon: icon,
          selectedIcon: selectedIcon,
          isSelected: isSelected,
          tooltip: tooltip,
          onPressed: onPressed,
          color: color,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onLongPress: onLongPress,
          autofocus: autofocus,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
        );
      default:
        return IconButton(
          icon: icon,
          selectedIcon: selectedIcon,
          isSelected: isSelected,
          tooltip: tooltip,
          onPressed: onPressed,
          color: color,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onLongPress: onLongPress,
          autofocus: autofocus,
          enableFeedback: enableFeedback,
          constraints: constraints,
          style: style,
        );
    }
  }

  Widget _image(BuildContext context, Map<String, Object?> props) {
    final width = _double(props['width']);
    final height = _double(props['height']);
    final scale = _double(props['scale']) ?? 1;
    final semanticLabel = _string(
      props['semanticLabel'] ?? props['semanticsLabel'],
    );
    final excludeFromSemantics = _bool(props['excludeFromSemantics']) ?? false;
    final color = _color(props['color'], context);
    final opacity = _imageOpacity(props['opacity']);
    final colorBlendMode = _blendMode(props['colorBlendMode']);
    final fit = _boxFit(props['fit']);
    final alignment = _alignment(props['alignment']) ?? Alignment.center;
    final repeat = _imageRepeat(props['repeat']) ?? ImageRepeat.noRepeat;
    final centerSlice = _rect(props['centerSlice']);
    final matchTextDirection = _bool(props['matchTextDirection']) ?? false;
    final gaplessPlayback = _bool(props['gaplessPlayback']) ?? false;
    final isAntiAlias = _bool(props['isAntiAlias']) ?? false;
    final filterQuality =
        _filterQuality(props['filterQuality']) ?? FilterQuality.medium;
    final cacheWidth = _positiveInt(
      props['cacheWidth'] ?? props['decodeWidth'],
    );
    final cacheHeight = _positiveInt(
      props['cacheHeight'] ?? props['decodeHeight'],
    );
    final errorSpec =
        props['errorBuilder'] ?? props['error'] ?? props['fallback'];
    final loadingSpec =
        props['loadingBuilder'] ?? props['loading'] ?? props['placeholder'];
    final errorBuilder = errorSpec == null
        ? null
        : (BuildContext context, Object error, StackTrace? stackTrace) =>
              buildWidget(context, errorSpec);
    final loadingBuilder = loadingSpec == null
        ? null
        : (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) => loadingProgress == null
              ? child
              : buildWidget(context, loadingSpec);

    final source = _string(props['source'])?.toLowerCase();
    final src = _string(props['src'] ?? props['url']);
    final isDataUri = src?.trimLeft().startsWith('data:') ?? false;
    final bytes = _imageBytes(
      props['bytes'] ??
          props['base64'] ??
          props['dataUri'] ??
          (source == 'memory' ? (props['data'] ?? src) : null) ??
          (isDataUri ? src : null),
    );
    if (bytes != null) {
      return Image.memory(
        bytes,
        scale: scale,
        errorBuilder: errorBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        opacity: opacity,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }

    final asset = _string(
      props['asset'] ?? (source == 'asset' ? (props['name'] ?? src) : null),
    );
    if (asset != null) {
      return Image.asset(
        asset,
        scale: _double(props['assetScale']) ?? _double(props['scale']),
        errorBuilder: errorBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        opacity: opacity,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        package: _string(props['package']),
        filterQuality: filterQuality,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }
    if (src != null && !isDataUri && source != 'asset' && source != 'memory') {
      return Image.network(
        src,
        scale: scale,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        opacity: opacity,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        isAntiAlias: isAntiAlias,
        headers: _stringStringMap(props['headers']),
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }
    return _optionalWidget(context, errorSpec) ?? const SizedBox.shrink();
  }

  Widget _child(BuildContext context, Map<String, Object?> props) {
    return _maybeChild(context, props) ?? const SizedBox.shrink();
  }

  Widget? _maybeChild(BuildContext context, Map<String, Object?> props) {
    if (props.containsKey('child')) {
      return buildWidget(context, props['child']);
    }
    if (props.containsKey('children')) {
      return Column(children: buildWidgets(context, props['children']));
    }
    return null;
  }

  Widget? _optionalWidget(BuildContext context, Object? spec) {
    if (spec == null) {
      return null;
    }
    return buildWidget(context, spec);
  }

  Widget _label(BuildContext context, Map<String, Object?> props) {
    final label = props['label'] ?? props['text'];
    if (label == null) {
      return const SizedBox.shrink();
    }
    return buildWidget(context, label);
  }

  Widget _iconWidget(BuildContext context, Object? spec) {
    if (spec is Map) {
      return buildWidget(context, spec);
    }
    return Icon(_iconData(spec) ?? Icons.help_outline);
  }

  List<DropdownMenuItem<Object?>> _dropdownItems(
    BuildContext context,
    Object? value,
  ) {
    final list = value is List ? value : const <Object?>[];
    final seen = <Object?>{};
    final items = <DropdownMenuItem<Object?>>[];
    for (final item in list) {
      if (item is Map) {
        final raw = _stringMap(item);
        final props = _props(raw);
        final itemValue = props.containsKey('value')
            ? props['value']
            : props['label'] ?? props['text'];
        if (itemValue != null && !seen.add(itemValue)) {
          continue;
        }
        items.add(
          DropdownMenuItem<Object?>(
            value: itemValue,
            enabled: _bool(props['enabled']) ?? true,
            alignment: _alignment(props['alignment']) ?? Alignment.center,
            onTap: _callback(props['onTap']),
            child:
                _optionalWidget(
                  context,
                  props['child'] ?? props['label'] ?? props['text'],
                ) ??
                Text(_string(itemValue) ?? ''),
          ),
        );
        continue;
      }
      if (item != null && !seen.add(item)) {
        continue;
      }
      items.add(
        DropdownMenuItem<Object?>(
          value: item,
          child: Text(_string(item) ?? ''),
        ),
      );
    }
    return items;
  }

  Object? _matchingDropdownValue(
    Object? value,
    List<DropdownMenuItem<Object?>> items,
  ) {
    if (value == null) {
      return null;
    }
    for (final item in items) {
      if (item.value == value) {
        return value;
      }
    }
    return null;
  }

  List<DropdownMenuEntry<Object?>> _dropdownMenuEntries(
    BuildContext context,
    Object? value,
  ) {
    final list = value is List ? value : const <Object?>[];
    final seen = <Object?>{};
    final entries = <DropdownMenuEntry<Object?>>[];
    for (final item in list) {
      if (item is Map) {
        final raw = _stringMap(item);
        final props = _props(raw);
        final itemValue = props.containsKey('value')
            ? props['value']
            : props['label'] ?? props['text'];
        if (itemValue != null && !seen.add(itemValue)) {
          continue;
        }
        final label =
            _string(props['label'] ?? props['text'] ?? itemValue) ?? '';
        entries.add(
          DropdownMenuEntry<Object?>(
            value: itemValue,
            label: label,
            labelWidget: _optionalWidget(
              context,
              props['labelWidget'] ?? props['child'],
            ),
            leadingIcon: _optionalWidget(context, props['leadingIcon']),
            trailingIcon: _optionalWidget(context, props['trailingIcon']),
            enabled: _bool(props['enabled']) ?? true,
            style: _buttonStyle(props['style'] ?? props),
          ),
        );
        continue;
      }
      if (item != null && !seen.add(item)) {
        continue;
      }
      entries.add(
        DropdownMenuEntry<Object?>(value: item, label: _string(item) ?? ''),
      );
    }
    return entries;
  }

  Object? _matchingDropdownMenuValue(
    Object? value,
    List<DropdownMenuEntry<Object?>> entries,
  ) {
    if (value == null) {
      return null;
    }
    for (final entry in entries) {
      if (entry.value == value) {
        return value;
      }
    }
    return null;
  }

  List<PopupMenuEntry<Object?>> _popupMenuItems(
    BuildContext context,
    Object? value,
  ) {
    final list = value is List ? value : const <Object?>[];
    return list
        .map<PopupMenuEntry<Object?>>((item) {
          if (item is Map) {
            final raw = _stringMap(item);
            final type = (raw['type'] ?? raw[r'$applet.type'] ?? raw['kind'])
                ?.toString()
                .toLowerCase();
            final props = _props(raw);
            if (_bool(props['divider']) == true ||
                type == 'popupmenudivider' ||
                type == 'divider') {
              return PopupMenuDivider(
                height: _double(props['height']) ?? 16,
                thickness: _double(props['thickness']),
                indent: _double(props['indent']),
                endIndent: _double(props['endIndent']),
                radius: _borderRadius(props['radius']),
                color: _color(props['color']),
              );
            }
            final itemValue = props.containsKey('value')
                ? props['value']
                : props['label'] ?? props['text'];
            final child =
                _optionalWidget(
                  context,
                  props['child'] ?? props['label'] ?? props['text'],
                ) ??
                Text(_string(itemValue) ?? '');
            final isChecked =
                _bool(props['checked'] ?? props['selected']) ?? false;
            if (isChecked == true || type == 'checkedpopupmenuitem') {
              return CheckedPopupMenuItem<Object?>(
                value: itemValue,
                checked: isChecked,
                enabled: _bool(props['enabled']) ?? true,
                padding: _edgeInsetsOnly(props['padding']),
                height: _double(props['height']) ?? kMinInteractiveDimension,
                labelTextStyle: _stateProperty<TextStyle>(
                  props['labelTextStyle'],
                  _textStyle,
                ),
                mouseCursor: _mouseCursorOrNull(
                  props['mouseCursor'] ?? props['cursor'],
                ),
                onTap: _callback(props['onTap'] ?? props['onPressed']),
                child: child,
              );
            }
            return PopupMenuItem<Object?>(
              value: itemValue,
              onTap: _callback(props['onTap'] ?? props['onPressed']),
              enabled: _bool(props['enabled']) ?? true,
              height: _double(props['height']) ?? kMinInteractiveDimension,
              padding: _edgeInsetsOnly(props['padding']),
              textStyle: _textStyle(props['textStyle']),
              labelTextStyle: _stateProperty<TextStyle>(
                props['labelTextStyle'],
                _textStyle,
              ),
              mouseCursor: _mouseCursorOrNull(
                props['mouseCursor'] ?? props['cursor'],
              ),
              child: child,
            );
          }
          return PopupMenuItem<Object?>(
            value: item,
            child: Text(_string(item) ?? ''),
          );
        })
        .toList(growable: false);
  }

  List<ButtonSegment<Object>> _buttonSegments(
    BuildContext context,
    Object? value,
  ) {
    final list = value is List ? value : const <Object?>[];
    return list
        .map<ButtonSegment<Object>>((item) {
          final index = list.indexOf(item);
          if (item is Map) {
            final props = _props(_stringMap(item));
            final Object segmentValue =
                props.containsKey('value') && props['value'] != null
                ? props['value']!
                : index;
            return ButtonSegment<Object>(
              value: segmentValue,
              icon: _optionalWidget(context, props['icon']),
              label:
                  _optionalWidget(
                    context,
                    props['label'] ?? props['child'] ?? props['text'],
                  ) ??
                  Text(_string(segmentValue) ?? ''),
              tooltip: _string(props['tooltip']),
              enabled: _bool(props['enabled']) ?? true,
            );
          }
          final Object segmentValue = item ?? index;
          return ButtonSegment<Object>(
            value: segmentValue,
            label: Text(_string(item) ?? '$index'),
          );
        })
        .toList(growable: false);
  }

  List<Step> _steps(BuildContext context, Object? value) {
    final list = value is List ? value : const <Object?>[];
    return list
        .map((item) {
          final props = item is Map
              ? _props(_stringMap(item))
              : <String, Object?>{};
          return Step(
            title:
                _optionalWidget(context, props['title']) ??
                Text(_string(item is Map ? null : item) ?? ''),
            subtitle: _optionalWidget(context, props['subtitle']),
            content:
                _optionalWidget(context, props['content'] ?? props['child']) ??
                const SizedBox.shrink(),
            isActive: _bool(props['isActive']) ?? false,
            state: _stepState(props['state']) ?? StepState.indexed,
            label: _optionalWidget(context, props['label']),
            stepStyle: _stepStyle(props['stepStyle'] ?? props['style']),
          );
        })
        .toList(growable: false);
  }

  List<ExpansionPanel> _expansionPanels(
    BuildContext context,
    Object? value, {
    required bool radio,
  }) {
    final list = value is List ? value : const <Object?>[];
    final seenRadioValues = <Object>{};
    return List<ExpansionPanel>.generate(list.length, (index) {
      final item = list[index];
      if (item is! Map) {
        final title = Text(_string(item) ?? '');
        if (radio) {
          return ExpansionPanelRadio(
            value: index,
            headerBuilder: (_, _) => title,
            body: const SizedBox.shrink(),
          );
        }
        return ExpansionPanel(
          headerBuilder: (_, _) => title,
          body: const SizedBox.shrink(),
        );
      }

      final raw = _stringMap(item);
      final props = _props(raw);
      final itemType = _normalizedToken(raw['type'] ?? raw[r'$applet.type']);
      final useRadio =
          radio ||
          itemType == 'expansionpanelradio' ||
          _bool(props['radio']) == true;
      final headerSpec =
          props['header'] ?? props['title'] ?? props['label'] ?? props['text'];
      final expandedHeaderSpec =
          props['expandedHeader'] ??
          props['openHeader'] ??
          props['selectedHeader'];
      final body =
          _optionalWidget(
            context,
            props['body'] ?? props['content'] ?? props['child'],
          ) ??
          const SizedBox.shrink();
      final canTapOnHeader =
          _bool(
            props['canTapOnHeader'] ?? props['tapHeader'] ?? props['headerTap'],
          ) ??
          false;

      Widget headerBuilder(BuildContext headerContext, bool isExpanded) {
        if (isExpanded && expandedHeaderSpec != null) {
          final expandedHeader = _optionalWidget(
            headerContext,
            expandedHeaderSpec,
          );
          if (expandedHeader != null) {
            return expandedHeader;
          }
        }
        return _optionalWidget(headerContext, headerSpec) ??
            Text(_string(headerSpec ?? props['value'] ?? index) ?? '');
      }

      if (useRadio) {
        var panelValue =
            props['value'] ??
            props['id'] ??
            props['key'] ??
            props['name'] ??
            index;
        if (!seenRadioValues.add(panelValue)) {
          panelValue = '${panelValue}_$index';
          seenRadioValues.add(panelValue);
        }
        return ExpansionPanelRadio(
          value: panelValue,
          headerBuilder: headerBuilder,
          body: body,
          canTapOnHeader: canTapOnHeader,
          backgroundColor: _color(props['backgroundColor']),
          splashColor: _color(props['splashColor']),
          highlightColor: _color(props['highlightColor']),
        );
      }

      return ExpansionPanel(
        headerBuilder: headerBuilder,
        body: body,
        isExpanded:
            _bool(props['isExpanded'] ?? props['expanded'] ?? props['open']) ??
            false,
        canTapOnHeader: canTapOnHeader,
        backgroundColor: _color(props['backgroundColor']),
        splashColor: _color(props['splashColor']),
        highlightColor: _color(props['highlightColor']),
      );
    }, growable: false);
  }

  ExpansionPanelCallback? _expansionPanelCallback(
    Object? value,
    List<ExpansionPanel> panels,
  ) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (index, isExpanded) {
      final panel = index >= 0 && index < panels.length ? panels[index] : null;
      final panelValue = panel is ExpansionPanelRadio ? panel.value : null;
      _dispatch(
        action.withPayload(<String, Object?>{
          'index': index,
          'panelIndex': index,
          'isExpanded': isExpanded,
          'expanded': isExpanded,
          'value': panelValue,
        }),
      );
    };
  }

  Object? _matchingExpansionPanelValue(
    Object? value,
    List<ExpansionPanel> panels,
  ) {
    if (value == null) {
      return null;
    }
    for (final panel in panels) {
      if (panel is ExpansionPanelRadio && panel.value == value) {
        return value;
      }
    }
    return null;
  }

  List<DataColumn> _dataColumns(BuildContext context, Object? value) {
    final list = value is List ? value : const <Object?>[];
    return List<DataColumn>.generate(list.length, (index) {
      final item = list[index];
      final props = item is Map
          ? _props(_stringMap(item))
          : <String, Object?>{};
      return DataColumn(
        label:
            _optionalWidget(context, props['label'] ?? props['child']) ??
            Text(_string(item is Map ? '' : item) ?? ''),
        columnWidth: _tableColumnWidth(props['columnWidth']),
        tooltip: _string(props['tooltip']),
        numeric: _bool(props['numeric']) ?? false,
        onSort: _dataSortCallback(props['onSort'], index),
        mouseCursor: _stateMouseCursor(props['mouseCursor'] ?? props['cursor']),
        headingRowAlignment: _mainAxisAlignment(props['headingRowAlignment']),
      );
    }, growable: false);
  }

  List<DataRow> _dataRows(
    BuildContext context,
    Object? value,
    int columnCount,
  ) {
    final list = value is List ? value : const <Object?>[];
    return List<DataRow>.generate(list.length, (index) {
      final item = list[index];
      final props = item is Map
          ? _props(_stringMap(item))
          : <String, Object?>{};
      final cells = props['cells'] ?? (item is List ? item : const <Object?>[]);
      final rowKey = _dataRowKey(props);
      return DataRow(
        key: rowKey,
        selected: _bool(props['selected']) ?? false,
        onSelectChanged: _nullableBoolCallback(props['onSelectChanged']),
        onLongPress: _callback(props['onLongPress']),
        onHover: _valueCallback(props['onHover']),
        color: _stateColor(props['color']),
        mouseCursor: _stateMouseCursor(props['mouseCursor'] ?? props['cursor']),
        cells: _dataCells(context, cells, columnCount),
      );
    }, growable: false);
  }

  List<DataCell> _dataCells(
    BuildContext context,
    Object? value,
    int columnCount,
  ) {
    final list = value is List ? value : const <Object?>[];
    return List<DataCell>.generate(columnCount, (index) {
      if (index >= list.length) {
        return DataCell.empty;
      }
      final item = list[index];
      if (item is Map) {
        final props = _props(_stringMap(item));
        return DataCell(
          _optionalWidget(context, props['child'] ?? props['label']) ??
              const SizedBox.shrink(),
          placeholder: _bool(props['placeholder']) ?? false,
          showEditIcon: _bool(props['showEditIcon']) ?? false,
          onTap: _callback(props['onTap']),
          onLongPress: _callback(props['onLongPress']),
          onTapDown: _tapDownCallback(props['onTapDown']),
          onDoubleTap: _callback(props['onDoubleTap']),
          onTapCancel: _callback(props['onTapCancel']),
        );
      }
      return DataCell(Text(_string(item) ?? ''));
    }, growable: false);
  }

  List<TableRow> _rectangularTableRows(BuildContext context, Object? value) {
    final rows = _tableRows(context, value);
    if (rows.isEmpty) {
      return const <TableRow>[];
    }
    final columnCount = rows.fold<int>(
      0,
      (maxColumns, row) => math.max(maxColumns, row.children.length),
    );
    if (columnCount == 0) {
      return const <TableRow>[];
    }
    return rows
        .map((row) {
          if (row.children.length == columnCount) {
            return row;
          }
          return TableRow(
            key: row.key,
            decoration: row.decoration,
            children: <Widget>[
              ...row.children.take(columnCount),
              for (
                var index = row.children.length;
                index < columnCount;
                index++
              )
                const SizedBox.shrink(),
            ],
          );
        })
        .toList(growable: false);
  }

  List<TableRow> _tableRows(BuildContext context, Object? value) {
    final list = value is List ? value : const <Object?>[];
    return list
        .map((item) {
          final props = item is Map
              ? _props(_stringMap(item))
              : <String, Object?>{};
          final children =
              props['children'] ?? (item is List ? item : const <Object?>[]);
          return TableRow(
            key: _dataRowKey(props),
            decoration: _boxDecoration(props['decoration']),
            children: buildWidgets(context, children),
          );
        })
        .toList(growable: false);
  }

  PreferredSizeWidget? _preferredWidget(BuildContext context, Object? spec) {
    final widget = _optionalWidget(context, spec);
    if (widget == null) {
      return null;
    }
    if (widget is PreferredSizeWidget) {
      return widget;
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: widget,
    );
  }

  VoidCallback? _callback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return () {
      final result = dispatchAction!(action);
      if (result is Future) {
        unawaited(result);
      }
    };
  }

  ValueChanged<bool>? _valueCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<bool?>? _nullableBoolCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<double>? _doubleCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<int>? _intCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<String>? _stringValueCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<Map<String, Object?>>? _mapCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<DateTime>? _dateTimeValueCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(_dateTimePayload(next)));
  }

  ValueChanged<Duration>? _durationValueCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(_durationPayload(next)));
  }

  ImageErrorListener? _imageErrorCallback(Object? value, String source) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (exception, stackTrace) {
      _dispatch(
        action.withPayload(<String, Object?>{
          'source': source,
          'error': exception.toString(),
        }),
      );
    };
  }

  ValueChanged<SelectedContent?>? _selectedContentCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next?.plainText));
  }

  SelectionChangedCallback? _selectionChangedCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (selection, cause) {
      _dispatch(action.withPayload(_textSelectionPayload(selection, cause)));
    };
  }

  FocusOnKeyEventCallback? _focusKeyEventCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (_, event) {
      _dispatch(action.withPayload(_keyEventPayload(event)));
      return KeyEventResult.handled;
    };
  }

  ValueChanged<KeyEvent>? _keyEventCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (event) => _dispatch(action.withPayload(_keyEventPayload(event)));
  }

  ValueChanged<PointerEvent>? _pointerCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (event) => _dispatch(action.withPayload(_pointerPayload(event)));
  }

  GestureScaleStartCallback? _scaleStartCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_scaleStartPayload(details)));
  }

  GestureScaleUpdateCallback? _scaleUpdateCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_scaleUpdatePayload(details)));
  }

  GestureScaleEndCallback? _scaleEndCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_scaleEndPayload(details)));
  }

  DataColumnSortCallback? _dataSortCallback(Object? value, int fallbackIndex) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (columnIndex, ascending) => _dispatch(
      action.withPayload(<String, Object?>{
        'columnIndex': columnIndex,
        'index': columnIndex,
        'ascending': ascending,
        'fallbackIndex': fallbackIndex,
      }),
    );
  }

  GestureTapDownCallback? _tapDownCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) => _dispatch(action.withPayload(_tapDownPayload(details)));
  }

  GestureTapUpCallback? _tapUpCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) => _dispatch(action.withPayload(_tapUpPayload(details)));
  }

  DragUpdateCallback? _dragUpdateCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_dragUpdatePayload(details)));
  }

  DraggableCanceledCallback? _draggableCanceledCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (velocity, offset) => _dispatch(
      action.withPayload(<String, Object?>{
        ..._velocityPayload(velocity),
        'x': offset.dx,
        'y': offset.dy,
      }),
    );
  }

  DragEndCallback? _dragEndCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) => _dispatch(action.withPayload(_dragEndPayload(details)));
  }

  ValueChanged<DragTargetDetails<Object>>? _dragTargetWillAcceptCallback(
    Object? value,
  ) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_dragTargetDetailsPayload(details)));
  }

  DragTargetAcceptWithDetails<Object>? _dragTargetAcceptCallback(
    Object? value,
  ) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_dragTargetDetailsPayload(details)));
  }

  DragTargetMove<Object>? _dragTargetMoveCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (details) =>
        _dispatch(action.withPayload(_dragTargetDetailsPayload(details)));
  }

  ReorderCallback? _reorderCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (oldIndex, newIndex) => _dispatch(
      action.withPayload(<String, int>{
        'oldIndex': oldIndex,
        'newIndex': newIndex,
      }),
    );
  }

  ValueChanged<DismissDirection>? _dismissCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (direction) =>
        _dispatch(action.withPayload(_dismissDirectionName(direction)));
  }

  Map<ShortcutActivator, VoidCallback> _shortcutBindings(Object? value) {
    final bindings = <ShortcutActivator, VoidCallback>{};
    void add(Object? shortcut, Object? actionValue) {
      final activator = _shortcutActivator(shortcut);
      final action = AppletAction.maybeFrom(actionValue);
      if (activator == null || action == null || dispatchAction == null) {
        return;
      }
      bindings[activator] = () => _dispatch(action);
    }

    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          final props = _stringMap(item);
          add(
            props['shortcut'] ?? props['key'] ?? props['trigger'],
            props['onInvoke'] ?? props['action'] ?? props['callback'],
          );
        }
      }
      return bindings;
    }

    if (value is Map) {
      final props = _stringMap(value);
      if (props.containsKey('key') ||
          props.containsKey('trigger') ||
          props.containsKey('shortcut')) {
        add(
          props['shortcut'] ?? props['key'] ?? props['trigger'],
          props['onInvoke'] ?? props['action'] ?? props['callback'],
        );
      } else {
        for (final entry in props.entries) {
          add(entry.key, entry.value);
        }
      }
    }
    return bindings;
  }

  ValueChanged<Object?>? _objectCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<_AutocompleteOption>? _autocompleteSelectedCallback(
    Object? value,
    Object? payloadMode,
  ) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(
      action.withPayload(_autocompleteSelectionPayload(next, payloadMode)),
    );
  }

  PopupMenuItemSelected<Object?>? _objectValueCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(action.withPayload(next));
  }

  ValueChanged<RangeValues>? _rangeCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) => _dispatch(
      action.withPayload(<String, double>{
        'start': next.start,
        'end': next.end,
      }),
    );
  }

  ValueChanged<Set<Object>>? _setCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next) =>
        _dispatch(action.withPayload(next.toList(growable: false)));
  }

  ValueChanged<int>? _toggleButtonsCallback(
    Object? value,
    List<bool> selected,
  ) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (index) =>
        _dispatch(action.withPayload(_toggleButtonsPayload(index, selected)));
  }

  TabValueChanged<bool>? _tabValueCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (next, index) => _dispatch(
      action.withPayload(<String, Object?>{'value': next, 'index': index}),
    );
  }

  RefreshCallback _asyncCallback(Object? value) {
    final action = AppletAction.maybeFrom(value);
    return () async {
      if (action != null) {
        await dispatchAction?.call(action);
      }
    };
  }

  ValueChanged<RefreshIndicatorStatus?>? _refreshIndicatorStatusCallback(
    Object? value,
  ) {
    final action = AppletAction.maybeFrom(value);
    if (action == null || dispatchAction == null) {
      return null;
    }
    return (status) =>
        _dispatch(action.withPayload(_refreshStatusName(status)));
  }

  String? _refreshStatusName(RefreshIndicatorStatus? status) {
    return switch (status) {
      RefreshIndicatorStatus.drag => 'drag',
      RefreshIndicatorStatus.armed => 'armed',
      RefreshIndicatorStatus.snap => 'snap',
      RefreshIndicatorStatus.refresh => 'refresh',
      RefreshIndicatorStatus.done => 'done',
      RefreshIndicatorStatus.canceled => 'canceled',
      null => null,
    };
  }

  void _dispatch(AppletAction action) {
    final result = dispatchAction?.call(action);
    if (result is Future) {
      unawaited(result);
    }
  }
}

class _AppletSnackBarPresenter extends StatefulWidget {
  const _AppletSnackBarPresenter({
    required this.renderer,
    required this.snackBarSpec,
    required this.child,
  });

  final AppletRenderer renderer;
  final Object? snackBarSpec;
  final Widget child;

  @override
  State<_AppletSnackBarPresenter> createState() =>
      _AppletSnackBarPresenterState();
}

class _AppletSnackBarPresenterState extends State<_AppletSnackBarPresenter> {
  String? _shownKey;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(_AppletSnackBarPresenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snackBarSpec != widget.snackBarSpec) {
      _schedule();
    }
  }

  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      final props = widget.snackBarSpec is Map
          ? _props(_stringMap(widget.snackBarSpec as Map))
          : <String, Object?>{'content': widget.snackBarSpec};
      if (_bool(props['visible']) == false) {
        _shownKey = null;
        messenger.hideCurrentSnackBar();
        return;
      }
      final key = _snackBarPresentationKey(props);
      if (_shownKey == key) {
        return;
      }
      _shownKey = key;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        widget.renderer._materialSnackBar(context, widget.snackBarSpec),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AppletDialogPresenter extends StatefulWidget {
  const _AppletDialogPresenter({
    required this.renderer,
    required this.dialogSpec,
    required this.child,
  });

  final AppletRenderer renderer;
  final Object? dialogSpec;
  final Widget child;

  @override
  State<_AppletDialogPresenter> createState() => _AppletDialogPresenterState();
}

class _AppletDialogPresenterState extends State<_AppletDialogPresenter> {
  String? _shownKey;
  bool _showing = false;
  bool _dismissedByPresenter = false;
  NavigatorState? _localNavigator;
  NavigatorState? _rootNavigator;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(_AppletDialogPresenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dialogSpec != widget.dialogSpec) {
      _schedule();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localNavigator = Navigator.maybeOf(context);
    _rootNavigator = Navigator.maybeOf(context, rootNavigator: true);
  }

  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final props = _dialogProps(widget.dialogSpec);
      if (_bool(props['visible']) == false) {
        _dismiss();
        return;
      }
      final key = _overlayPresentationKey(props);
      if (_showing && _shownKey == key) {
        return;
      }
      if (_showing) {
        _dismiss();
      }
      _shownKey = key;
      _showing = true;
      _dismissedByPresenter = false;
      unawaited(
        showDialog<Object?>(
          context: context,
          barrierDismissible: _bool(props['barrierDismissible']) ?? true,
          barrierColor: _color(props['barrierColor']),
          barrierLabel: _string(props['barrierLabel']),
          useSafeArea: _bool(props['useSafeArea']) ?? true,
          useRootNavigator: _bool(props['useRootNavigator']) ?? true,
          builder: (dialogContext) =>
              widget.renderer.buildWidget(dialogContext, widget.dialogSpec),
        ).then((result) {
          if (!mounted) {
            return;
          }
          final dismissedByPresenter = _dismissedByPresenter;
          _showing = false;
          _shownKey = null;
          _dismissedByPresenter = false;
          if (dismissedByPresenter) {
            return;
          }
          if (result != null) {
            final action = AppletAction.maybeFrom(
              props['onResult'] ?? props['onSelected'] ?? props['onChanged'],
            );
            if (action != null) {
              final dispatched = widget.renderer.dispatchAction?.call(
                action.withPayload(_dialogResultPayload(result)),
              );
              if (dispatched is Future) {
                unawaited(dispatched);
              }
              return;
            }
          }
          final dismissAction = AppletAction.maybeFrom(
            props['onDismissed'] ?? props['onDismiss'] ?? props['onClose'],
          );
          if (dismissAction != null) {
            final dispatched = widget.renderer.dispatchAction?.call(
              dismissAction,
            );
            if (dispatched is Future) {
              unawaited(dispatched);
            }
          }
        }),
      );
    });
  }

  void _dismiss() {
    if (!_showing) {
      return;
    }
    final props = _dialogProps(widget.dialogSpec);
    final useRootNavigator = _bool(props['useRootNavigator']) ?? true;
    final navigator = useRootNavigator ? _rootNavigator : _localNavigator;
    if (navigator?.canPop() ?? false) {
      _dismissedByPresenter = true;
      navigator!.pop();
    }
    _showing = false;
    _shownKey = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Map<String, Object?> _stringMap(Map value) {
  return value.map((key, item) => MapEntry(key.toString(), item));
}

bool _hasAny(Map<String, Object?> map, Iterable<String> keys) {
  return keys.any(map.containsKey);
}

Map<String, String>? _stringStringMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  return value.map((key, item) => MapEntry(key.toString(), item.toString()));
}

Map<String, Object?> _props(Map<String, Object?> map) {
  final props = map['props'];
  if (props is Map) {
    return _stringMap(props);
  }
  final copy = Map<String, Object?>.from(map);
  copy.remove('type');
  copy.remove(r'$applet.type');
  return copy;
}

Map<String, Object?> _dialogProps(Object? spec) {
  return spec is Map ? _props(_stringMap(spec)) : <String, Object?>{};
}

String _snackBarPresentationKey(Map<String, Object?> props) {
  return _overlayPresentationKey(props);
}

String _overlayPresentationKey(Map<String, Object?> props) {
  final value =
      props['key'] ??
      props['id'] ??
      props['routeName'] ??
      props['message'] ??
      props['label'] ??
      props['text'] ??
      props['title'] ??
      props['content'] ??
      props['child'];
  return value?.toString() ??
      Object.hashAll(
        props.entries.map((entry) => Object.hash(entry.key, entry.value)),
      ).toString();
}

Object? _dialogResultPayload(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return _dateString(value);
  }
  if (value is TimeOfDay) {
    return _timeString(value);
  }
  if (value is String || value is num || value is bool) {
    return value;
  }
  if (value is Map) {
    return _stringMap(value);
  }
  if (value is List) {
    return value;
  }
  return value.toString();
}

String _dateString(DateTime value) {
  String two(int next) => next.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}';
}

String _timeString(TimeOfDay value) {
  String two(int next) => next.toString().padLeft(2, '0');
  return '${two(value.hour)}:${two(value.minute)}';
}

Map<String, Object?> _dateTimePayload(DateTime value) {
  return <String, Object?>{
    'iso': value.toIso8601String(),
    'date': _dateString(value),
    'time': _timeString(TimeOfDay.fromDateTime(value)),
    'year': value.year,
    'month': value.month,
    'day': value.day,
    'hour': value.hour,
    'minute': value.minute,
    'second': value.second,
    'millisecond': value.millisecond,
    'millisecondsSinceEpoch': value.millisecondsSinceEpoch,
    'weekday': value.weekday,
  };
}

Map<String, Object?> _durationPayload(Duration value) {
  return <String, Object?>{
    'days': value.inDays,
    'hours': value.inHours,
    'minutes': value.inMinutes,
    'seconds': value.inSeconds,
    'milliseconds': value.inMilliseconds,
    'microseconds': value.inMicroseconds,
    'hour': value.inHours % Duration.hoursPerDay,
    'minute': value.inMinutes % Duration.minutesPerHour,
    'second': value.inSeconds % Duration.secondsPerMinute,
  };
}

Key _key(Map<String, Object?> props) {
  final value =
      props['key'] ??
      props['id'] ??
      props['value'] ??
      props['label'] ??
      props['text'];
  if (value != null) {
    return ValueKey<String>(value.toString());
  }
  return ValueKey<int>(
    Object.hashAll(
      props.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

Key _specKey(Object? spec, int index) {
  if (spec is Map) {
    final map = _stringMap(spec);
    final props = _props(map);
    final value =
        props['key'] ??
        props['id'] ??
        props['value'] ??
        props['label'] ??
        props['text'];
    if (value != null) {
      return ValueKey<String>(value.toString());
    }
    return ValueKey<String>(
      '${map['type'] ?? 'item'}-$index-${Object.hashAll(map.entries.map((entry) => Object.hash(entry.key, entry.value)))}',
    );
  }
  return ValueKey<String>('item-$index-${spec.hashCode}');
}

LocalKey? _dataRowKey(Map<String, Object?> props) {
  final value = props['key'] ?? props['id'] ?? props['value'] ?? props['index'];
  return value == null ? null : ValueKey<String>(value.toString());
}

String? _string(Object? value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}

Map<String, Object?> _tapDownPayload(TapDownDetails details) {
  return <String, Object?>{
    'x': details.globalPosition.dx,
    'y': details.globalPosition.dy,
    'localX': details.localPosition.dx,
    'localY': details.localPosition.dy,
    'kind': details.kind?.name,
  };
}

Map<String, Object?> _tapUpPayload(TapUpDetails details) {
  return <String, Object?>{
    'x': details.globalPosition.dx,
    'y': details.globalPosition.dy,
    'localX': details.localPosition.dx,
    'localY': details.localPosition.dy,
    'kind': details.kind.name,
  };
}

Map<String, Object?> _pointerPayload(PointerEvent event) {
  return <String, Object?>{
    'pointer': event.pointer,
    'kind': event.kind.name,
    'buttons': event.buttons,
    'x': event.position.dx,
    'y': event.position.dy,
    'dx': event.delta.dx,
    'dy': event.delta.dy,
  };
}

Map<String, Object?> _scaleStartPayload(ScaleStartDetails details) {
  return <String, Object?>{
    'x': details.focalPoint.dx,
    'y': details.focalPoint.dy,
    'localX': details.localFocalPoint.dx,
    'localY': details.localFocalPoint.dy,
    'pointerCount': details.pointerCount,
  };
}

Map<String, Object?> _scaleUpdatePayload(ScaleUpdateDetails details) {
  return <String, Object?>{
    'x': details.focalPoint.dx,
    'y': details.focalPoint.dy,
    'localX': details.localFocalPoint.dx,
    'localY': details.localFocalPoint.dy,
    'scale': details.scale,
    'horizontalScale': details.horizontalScale,
    'verticalScale': details.verticalScale,
    'rotation': details.rotation,
    'pointerCount': details.pointerCount,
  };
}

Map<String, Object?> _scaleEndPayload(ScaleEndDetails details) {
  return <String, Object?>{
    ..._velocityPayload(details.velocity),
    'scaleVelocity': details.scaleVelocity,
    'pointerCount': details.pointerCount,
  };
}

Map<String, Object?> _textSelectionPayload(
  TextSelection selection,
  SelectionChangedCause? cause,
) {
  return <String, Object?>{
    'baseOffset': selection.baseOffset,
    'extentOffset': selection.extentOffset,
    'start': selection.start,
    'end': selection.end,
    'isCollapsed': selection.isCollapsed,
    'isValid': selection.isValid,
    'isNormalized': selection.isNormalized,
    'isDirectional': selection.isDirectional,
    'affinity': selection.affinity.name,
    'cause': cause?.name,
  };
}

Map<String, Object?> _keyEventPayload(KeyEvent event) {
  final logicalKey = event.logicalKey;
  final physicalKey = event.physicalKey;
  return <String, Object?>{
    'type': event.runtimeType.toString(),
    'logicalKey': logicalKey.debugName ?? logicalKey.keyLabel,
    'logicalKeyLabel': logicalKey.keyLabel,
    'logicalKeyId': logicalKey.keyId,
    'physicalKey': physicalKey.debugName,
    'physicalKeyId': physicalKey.usbHidUsage,
    'character': event.character,
    'synthesized': event.synthesized,
  };
}

Map<String, Object?> _dragUpdatePayload(DragUpdateDetails details) {
  return <String, Object?>{
    'x': details.globalPosition.dx,
    'y': details.globalPosition.dy,
    'localX': details.localPosition.dx,
    'localY': details.localPosition.dy,
    'dx': details.delta.dx,
    'dy': details.delta.dy,
    'primaryDelta': details.primaryDelta,
  };
}

Map<String, Object?> _dragEndPayload(DraggableDetails details) {
  return <String, Object?>{
    ..._velocityPayload(details.velocity),
    'x': details.offset.dx,
    'y': details.offset.dy,
    'wasAccepted': details.wasAccepted,
  };
}

Map<String, Object?> _velocityPayload(Velocity velocity) {
  return <String, Object?>{
    'velocityX': velocity.pixelsPerSecond.dx,
    'velocityY': velocity.pixelsPerSecond.dy,
  };
}

Map<String, Object?> _dragTargetDetailsPayload(
  DragTargetDetails<Object> details,
) {
  return <String, Object?>{
    'data': details.data,
    'x': details.offset.dx,
    'y': details.offset.dy,
  };
}

bool _dragTargetAccepts(Map<String, Object?> props, Object data) {
  final accepts = props['accepts'] ?? props['acceptedData'] ?? props['accept'];
  if (accepts == null) {
    return true;
  }
  if (accepts is List) {
    return accepts.contains(data);
  }
  return accepts == data;
}

int? _int(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  return int.tryParse(value?.toString() ?? '');
}

int? _positiveInt(Object? value) {
  final parsed = _int(value);
  return parsed == null || parsed <= 0 ? null : parsed;
}

int? _nonNegativeInt(Object? value) {
  final parsed = _int(value);
  return parsed == null ? null : math.max(0, parsed);
}

int _safeIndex(int index, int length) {
  if (length <= 0) {
    return 0;
  }
  return index.clamp(0, length - 1).toInt();
}

int? _safeMaxInt(Object? maxValue, int? minValue) {
  final max = _positiveInt(maxValue);
  if (max == null) {
    return null;
  }
  return minValue == null ? max : math.max(max, minValue);
}

double? _double(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

Uri? _uri(Object? value) {
  final text = _string(value);
  return text == null || text.isEmpty ? null : Uri.tryParse(text);
}

double? _nonNegativeDouble(Object? value) {
  final parsed = _double(value);
  return parsed == null ? null : math.max(0, parsed);
}

double? _safeMaterialElevation(Object? value) {
  final parsed = _nonNegativeDouble(value);
  if (parsed == null) {
    return null;
  }
  var nearest = kElevationToShadow.keys.first.toDouble();
  var nearestDistance = (parsed - nearest).abs();
  for (final allowed in kElevationToShadow.keys) {
    final next = allowed.toDouble();
    final distance = (parsed - next).abs();
    if (distance < nearestDistance) {
      nearest = next;
      nearestDistance = distance;
    }
  }
  return nearest;
}

double? _positiveDouble(Object? value) {
  final parsed = _double(value);
  return parsed == null || parsed <= 0 ? null : parsed;
}

double? _positiveFiniteDouble(Object? value) {
  final parsed = _double(value);
  return parsed == null || !parsed.isFinite || parsed <= 0 ? null : parsed;
}

double? _unitDouble(Object? value) {
  final parsed = _double(value);
  return parsed?.clamp(0, 1).toDouble();
}

double? _safeMaxHeight(Object? maxValue, Object? minValue) {
  return _safeMaxDouble(maxValue, _nonNegativeDouble(minValue));
}

double? _safeMaxDouble(Object? maxValue, double? minValue) {
  final max = _nonNegativeDouble(maxValue);
  if (max == null) {
    return null;
  }
  return minValue == null ? max : math.max(max, minValue);
}

double? _safeStepIconSize(Object? value) {
  final parsed = _double(value);
  if (parsed == null) {
    return null;
  }
  return parsed.clamp(24, 80).toDouble();
}

List<int> _positiveIntList(Object? value) {
  final raw = switch (value) {
    List() => value,
    String() => value.split(','),
    _ => const <Object?>[],
  };
  return raw
      .map(_int)
      .whereType<int>()
      .where((item) => item > 0)
      .toList(growable: false);
}

int _clampedIndex(Object? value, List<Object?> items) {
  if (items.isEmpty) {
    return 0;
  }
  return (_int(value) ?? 0).clamp(0, items.length - 1).toInt();
}

int? _clampedOptionalIndex(Object? value, List<Object?> items) {
  if (value == null || items.isEmpty) {
    return null;
  }
  return (_int(value) ?? 0).clamp(0, items.length - 1).toInt();
}

double? _progressValue(Object? value) {
  return _unitDouble(value);
}

String? _progressSemanticsValue(Object? value, double? progressValue) {
  final text = _string(value);
  if (text == null) {
    return null;
  }
  if (progressValue == null) {
    return text;
  }
  final direct = _double(value);
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(text);
  final parsed = direct ?? double.tryParse(match?.group(0) ?? '');
  if (parsed == null) {
    return null;
  }
  final clamped = parsed.clamp(0, 100).toDouble();
  return clamped == clamped.roundToDouble()
      ? clamped.round().toString()
      : clamped.toString();
}

Animation<Color?>? _colorAnimation(Object? value) {
  final color = _color(value);
  return color == null ? null : AlwaysStoppedAnimation<Color?>(color);
}

Animation<double>? _imageOpacity(Object? value) {
  final opacity = _double(value);
  return opacity == null
      ? null
      : AlwaysStoppedAnimation<double>(opacity.clamp(0, 1).toDouble());
}

Uint8List? _imageBytes(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Uint8List) {
    return value;
  }
  if (value is List) {
    final bytes = <int>[];
    for (final item in value) {
      final byte = _int(item);
      if (byte == null || byte < 0 || byte > 255) {
        return null;
      }
      bytes.add(byte);
    }
    return Uint8List.fromList(bytes);
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  final comma = text.indexOf(',');
  final payload = text.startsWith('data:') && comma >= 0
      ? text.substring(comma + 1)
      : text;
  try {
    return base64Decode(payload);
  } on FormatException {
    return null;
  }
}

Offset? _offset(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Offset) {
    return value;
  }
  if (value is List && value.length >= 2) {
    return Offset(_double(value[0]) ?? 0, _double(value[1]) ?? 0);
  }
  if (value is Map) {
    final map = _stringMap(value);
    return Offset(
      _double(map['dx'] ?? map['x'] ?? map['width']) ?? 0,
      _double(map['dy'] ?? map['y'] ?? map['height']) ?? 0,
    );
  }
  return null;
}

Size? _size(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Size) {
    return value;
  }
  if (value is num) {
    return Size.square(value.toDouble());
  }
  if (value is List && value.length >= 2) {
    return Size(_double(value[0]) ?? 0, _double(value[1]) ?? 0);
  }
  if (value is Map) {
    final map = _stringMap(value);
    return Size(_double(map['width']) ?? 0, _double(map['height']) ?? 0);
  }
  return null;
}

Size? _nonNegativeSize(Object? value) {
  final size = _size(value);
  if (size == null) {
    return null;
  }
  return Size(math.max(0, size.width), math.max(0, size.height));
}

Rect? _rect(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Rect) {
    return value;
  }
  if (value is List && value.length >= 4) {
    return Rect.fromLTRB(
      _double(value[0]) ?? 0,
      _double(value[1]) ?? 0,
      _double(value[2]) ?? 0,
      _double(value[3]) ?? 0,
    );
  }
  if (value is Map) {
    final map = _stringMap(value);
    final left = _double(map['left'] ?? map['x']) ?? 0;
    final top = _double(map['top'] ?? map['y']) ?? 0;
    final right = _double(map['right']);
    final bottom = _double(map['bottom']);
    final width = _double(map['width']);
    final height = _double(map['height']);
    if (right != null || bottom != null) {
      return Rect.fromLTRB(left, top, right ?? left, bottom ?? top);
    }
    return Rect.fromLTWH(left, top, width ?? 0, height ?? 0);
  }
  return null;
}

DateTime? _dateTime(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is Map) {
    final map = _stringMap(value);
    final epoch = _int(
      map['millisecondsSinceEpoch'] ??
          map['msSinceEpoch'] ??
          map['epochMilliseconds'] ??
          map['timestampMs'],
    );
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }
    final year = _int(map['year']);
    final month = _int(map['month']);
    final day = _int(map['day']);
    if (year != null && month != null && day != null) {
      return DateTime(
        year,
        month,
        day,
        _int(map['hour'] ?? map['hours']) ?? 0,
        _int(map['minute'] ?? map['minutes']) ?? 0,
        _int(map['second'] ?? map['seconds']) ?? 0,
        _int(map['millisecond'] ?? map['milliseconds'] ?? map['ms']) ?? 0,
        _int(map['microsecond'] ?? map['microseconds'] ?? map['us']) ?? 0,
      );
    }
  }
  return DateTime.tryParse(value.toString());
}

cupertino.CupertinoDatePickerMode? _cupertinoDatePickerMode(Object? value) {
  switch (_normalizedToken(value)) {
    case 'time':
      return cupertino.CupertinoDatePickerMode.time;
    case 'date':
      return cupertino.CupertinoDatePickerMode.date;
    case 'datetime':
    case 'dateandtime':
      return cupertino.CupertinoDatePickerMode.dateAndTime;
    case 'monthyear':
    case 'yearmonth':
      return cupertino.CupertinoDatePickerMode.monthYear;
  }
  return null;
}

cupertino.DatePickerDateOrder? _cupertinoDatePickerDateOrder(Object? value) {
  switch (_normalizedToken(value)) {
    case 'dmy':
    case 'daymonthyear':
      return cupertino.DatePickerDateOrder.dmy;
    case 'mdy':
    case 'monthdayyear':
      return cupertino.DatePickerDateOrder.mdy;
    case 'ymd':
    case 'yearmonthday':
      return cupertino.DatePickerDateOrder.ymd;
    case 'ydm':
    case 'yeardaymonth':
      return cupertino.DatePickerDateOrder.ydm;
  }
  return null;
}

cupertino.CupertinoTimerPickerMode? _cupertinoTimerPickerMode(Object? value) {
  switch (_normalizedToken(value)) {
    case 'hm':
    case 'hourminute':
    case 'hoursminutes':
      return cupertino.CupertinoTimerPickerMode.hm;
    case 'ms':
    case 'minutesecond':
    case 'minutesseconds':
      return cupertino.CupertinoTimerPickerMode.ms;
    case 'hms':
    case 'hourminutesecond':
    case 'hoursminutesseconds':
      return cupertino.CupertinoTimerPickerMode.hms;
  }
  return null;
}

cupertino.NavigationBarBottomMode? _cupertinoNavigationBarBottomMode(
  Object? value,
) {
  switch (_normalizedToken(value)) {
    case 'automatic':
    case 'auto':
    case 'scroll':
    case 'collapsible':
      return cupertino.NavigationBarBottomMode.automatic;
    case 'always':
    case 'pinned':
    case 'fixed':
      return cupertino.NavigationBarBottomMode.always;
  }
  return null;
}

ChangeReportingBehavior? _changeReportingBehavior(Object? value) {
  switch (_normalizedToken(value)) {
    case 'onscrollend':
    case 'scrollend':
    case 'end':
    case 'settled':
      return ChangeReportingBehavior.onScrollEnd;
    case 'onscrollupdate':
    case 'scrollupdate':
    case 'update':
    case 'change':
      return ChangeReportingBehavior.onScrollUpdate;
  }
  return null;
}

int _timePickerInterval(Object? value) {
  final parsed = _positiveInt(value);
  if (parsed == null || 60 % parsed != 0) {
    return 1;
  }
  return parsed;
}

({
  DateTime initial,
  DateTime? minimum,
  DateTime? maximum,
  int minimumYear,
  int? maximumYear,
  int minuteInterval,
})
_cupertinoDateRange({
  required Object? initial,
  required Object? minimum,
  required Object? maximum,
  required cupertino.CupertinoDatePickerMode mode,
  required int minuteInterval,
  required int? minimumYear,
  required int? maximumYear,
}) {
  var minDate = _dateTime(minimum);
  var maxDate = _dateTime(maximum);
  if (minDate != null && maxDate != null && minDate.isAfter(maxDate)) {
    final swap = minDate;
    minDate = maxDate;
    maxDate = swap;
  }

  var safeMinimumYear = math.max(1, minimumYear ?? 1);
  var safeMaximumYear = maximumYear;
  if (safeMaximumYear != null && safeMaximumYear < safeMinimumYear) {
    safeMaximumYear = safeMinimumYear;
  }

  var value = _dateTime(initial) ?? DateTime.now();
  if (minDate != null && value.isBefore(minDate)) {
    value = minDate;
  }
  if (maxDate != null && value.isAfter(maxDate)) {
    value = maxDate;
  }
  if (mode == cupertino.CupertinoDatePickerMode.date ||
      mode == cupertino.CupertinoDatePickerMode.monthYear) {
    if (value.year < safeMinimumYear) {
      value = _dateTimeWithYear(value, safeMinimumYear);
    }
    if (safeMaximumYear != null && value.year > safeMaximumYear) {
      value = _dateTimeWithYear(value, safeMaximumYear);
    }
  }
  value = _dateTimeOnMinuteInterval(
    value,
    minuteInterval,
    minimum: minDate,
    maximum: maxDate,
  );

  if (minDate != null && value.isBefore(minDate)) {
    minDate = value;
  }
  if (maxDate != null && value.isAfter(maxDate)) {
    maxDate = value;
  }

  return (
    initial: value,
    minimum: minDate,
    maximum: maxDate,
    minimumYear: safeMinimumYear,
    maximumYear: safeMaximumYear,
    minuteInterval: minuteInterval,
  );
}

DateTime _dateTimeWithYear(DateTime value, int year) {
  final lastDay = DateTime(year, value.month + 1, 0).day;
  return DateTime(
    year,
    value.month,
    math.min(value.day, lastDay),
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

DateTime _dateTimeOnMinuteInterval(
  DateTime value,
  int minuteInterval, {
  DateTime? minimum,
  DateTime? maximum,
}) {
  DateTime atMinute(DateTime source, int minute) {
    return DateTime(source.year, source.month, source.day, source.hour, minute);
  }

  var next = atMinute(value, value.minute - value.minute % minuteInterval);
  if (minimum != null && next.isBefore(minimum)) {
    final remainder = minimum.minute % minuteInterval;
    final roundedMinute = remainder == 0
        ? minimum.minute
        : minimum.minute + minuteInterval - remainder;
    next = DateTime(
      minimum.year,
      minimum.month,
      minimum.day,
      minimum.hour,
      roundedMinute,
    );
  }
  if (maximum != null && next.isAfter(maximum)) {
    next = atMinute(maximum, maximum.minute - maximum.minute % minuteInterval);
  }
  return next;
}

TimeOfDay? _timeOfDay(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TimeOfDay) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    return TimeOfDay(
      hour: (_int(map['hour']) ?? 0).clamp(0, 23),
      minute: (_int(map['minute']) ?? 0).clamp(0, 59),
    );
  }
  final parts = value.toString().split(':');
  if (parts.length >= 2) {
    return TimeOfDay(
      hour: (_int(parts[0]) ?? 0).clamp(0, 23),
      minute: (_int(parts[1]) ?? 0).clamp(0, 59),
    );
  }
  return null;
}

RangeValues _rangeValues(Object? value) {
  if (value is RangeValues) {
    return value;
  }
  if (value is List && value.length >= 2) {
    return RangeValues(_double(value[0]) ?? 0, _double(value[1]) ?? 1);
  }
  if (value is Map) {
    final map = _stringMap(value);
    return RangeValues(
      _double(map['start'] ?? map['lower'] ?? map['minValue']) ?? 0,
      _double(map['end'] ?? map['upper'] ?? map['maxValue']) ?? 1,
    );
  }
  return const RangeValues(0, 1);
}

({double min, double max}) _sliderBounds(Map<String, Object?> props) {
  final rawMin = _double(props['min']) ?? 0;
  final rawMax = _double(props['max']) ?? 1;
  if (rawMin <= rawMax) {
    return (min: rawMin, max: rawMax);
  }
  return (min: rawMax, max: rawMin);
}

RangeValues _rangeValuesInBounds(Object? value, double min, double max) {
  final raw = _rangeValues(value);
  final start = raw.start.clamp(min, max).toDouble();
  final end = raw.end.clamp(min, max).toDouble();
  return start <= end ? RangeValues(start, end) : RangeValues(end, start);
}

RangeLabels? _rangeLabels(Object? value, RangeValues values) {
  if (value == null || value == false) {
    return null;
  }
  if (value is RangeLabels) {
    return value;
  }
  if (value is List && value.length >= 2) {
    return RangeLabels(_string(value[0]) ?? '', _string(value[1]) ?? '');
  }
  if (value is Map) {
    final map = _stringMap(value);
    return RangeLabels(
      _string(map['start'] ?? map['lower']) ?? '',
      _string(map['end'] ?? map['upper']) ?? '',
    );
  }
  return RangeLabels(
    values.start.round().toString(),
    values.end.round().toString(),
  );
}

Set<Object> _objectSet(Object? value) {
  final out = <Object>{};
  void add(Object? item) {
    if (item != null) {
      out.add(item);
    }
  }

  if (value is Set) {
    for (final item in value) {
      add(item);
    }
    return out;
  }
  if (value is List) {
    for (final item in value) {
      add(item);
    }
    return out;
  }
  add(value);
  return out;
}

List<bool> _toggleButtonsSelection(Object? value, int length) {
  if (length <= 0) {
    return const <bool>[];
  }
  final selected = List<bool>.filled(length, false);
  if (value is List) {
    if (value.every((item) => item is bool)) {
      for (var index = 0; index < math.min(value.length, length); index++) {
        selected[index] = value[index] as bool;
      }
      return selected;
    }
    for (final item in value) {
      final index = _int(item);
      if (index != null && index >= 0 && index < length) {
        selected[index] = true;
      }
    }
    return selected;
  }
  final index = _int(value);
  if (index != null && index >= 0 && index < length) {
    selected[index] = true;
  }
  return selected;
}

Map<String, Object?> _toggleButtonsPayload(int index, List<bool> selected) {
  final next = selected.toList(growable: false);
  if (index >= 0 && index < next.length) {
    next[index] = !next[index];
  }
  return <String, Object?>{
    'index': index,
    'selected': index >= 0 && index < next.length ? next[index] : null,
    'isSelected': next,
    'selectedIndexes': [
      for (var i = 0; i < next.length; i++)
        if (next[i]) i,
    ],
  };
}

bool? _bool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'true':
      case 'yes':
      case '1':
        return true;
      case 'false':
      case 'no':
      case '0':
        return false;
    }
  }
  if (value is num) {
    return value != 0;
  }
  return null;
}

int? _listLength(Object? value) {
  return value is List ? value.length : null;
}

Duration? _duration(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Duration) {
    return value;
  }
  if (value is num) {
    return Duration(milliseconds: value.round());
  }
  if (value is Map) {
    final map = _stringMap(value);
    return Duration(
      days: _int(map['days']) ?? 0,
      hours: _int(map['hours']) ?? 0,
      minutes: _int(map['minutes']) ?? 0,
      seconds: _int(map['seconds']) ?? 0,
      milliseconds: _int(map['milliseconds'] ?? map['ms']) ?? 0,
      microseconds: _int(map['microseconds'] ?? map['us']) ?? 0,
    );
  }
  return null;
}

Duration? _nonNegativeDuration(Object? value) {
  final parsed = _duration(value);
  if (parsed == null) {
    return null;
  }
  return parsed.isNegative ? Duration.zero : parsed;
}

Duration _cupertinoTimerDuration(
  Object? value, {
  required int minuteInterval,
  required int secondInterval,
}) {
  final parsed = _nonNegativeDuration(value) ?? Duration.zero;
  final totalSeconds = parsed.inSeconds.clamp(0, Duration.secondsPerDay - 1);
  final hours = totalSeconds ~/ Duration.secondsPerHour;
  var minutes =
      (totalSeconds ~/ Duration.secondsPerMinute) % Duration.minutesPerHour;
  var seconds = totalSeconds % Duration.secondsPerMinute;
  minutes -= minutes % minuteInterval;
  seconds -= seconds % secondInterval;
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

AnimationStyle? _animationStyle(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is AnimationStyle) {
    return value;
  }
  if (value.toString().toLowerCase() == 'none') {
    return AnimationStyle.noAnimation;
  }
  if (value is num) {
    return AnimationStyle(duration: _duration(value));
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return AnimationStyle(
    curve: _curve(map['curve']),
    duration: _duration(map['duration']),
    reverseCurve: _curve(map['reverseCurve']),
    reverseDuration: _duration(map['reverseDuration']),
  );
}

ChipAnimationStyle? _chipAnimationStyle(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ChipAnimationStyle) {
    return value;
  }
  if (value is! Map) {
    final animation = _animationStyle(value);
    return animation == null
        ? null
        : ChipAnimationStyle(
            enableAnimation: animation,
            selectAnimation: animation,
            avatarDrawerAnimation: animation,
            deleteDrawerAnimation: animation,
          );
  }
  final map = _stringMap(value);
  return ChipAnimationStyle(
    enableAnimation: _animationStyle(map['enableAnimation'] ?? map['enable']),
    selectAnimation: _animationStyle(map['selectAnimation'] ?? map['select']),
    avatarDrawerAnimation: _animationStyle(
      map['avatarDrawerAnimation'] ?? map['avatarDrawer'],
    ),
    deleteDrawerAnimation: _animationStyle(
      map['deleteDrawerAnimation'] ?? map['deleteDrawer'],
    ),
  );
}

Curve? _curve(Object? value) {
  switch (value.toString().toLowerCase()) {
    case 'linear':
      return Curves.linear;
    case 'ease':
      return Curves.ease;
    case 'easein':
    case 'ease_in':
      return Curves.easeIn;
    case 'easeout':
    case 'ease_out':
      return Curves.easeOut;
    case 'easeinout':
    case 'ease_in_out':
      return Curves.easeInOut;
    case 'fastoutslowin':
    case 'fast_out_slow_in':
      return Curves.fastOutSlowIn;
    case 'bounceout':
    case 'bounce_out':
      return Curves.bounceOut;
    case 'elasticout':
    case 'elastic_out':
      return Curves.elasticOut;
  }
  return null;
}

CrossFadeState? _crossFadeState(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'showsecond':
    case 'show_second':
    case 'second':
    case 'true':
      return CrossFadeState.showSecond;
    case 'showfirst':
    case 'show_first':
    case 'first':
    case 'false':
      return CrossFadeState.showFirst;
  }
  return null;
}

cupertino.CupertinoThemeData? _cupertinoThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is cupertino.CupertinoThemeData) {
    return value;
  }
  if (value is! Map) {
    return cupertino.CupertinoThemeData(primaryColor: _color(value));
  }
  final map = _stringMap(value);
  return cupertino.CupertinoThemeData(
    brightness: _brightness(map['brightness']),
    primaryColor: _color(map['primaryColor'] ?? map['primary']),
    scaffoldBackgroundColor: _color(map['scaffoldBackgroundColor']),
    barBackgroundColor: _color(map['barBackgroundColor']),
  );
}

ThemeData? _themeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final brightness = _brightness(map['brightness']);
  final seed = _color(
    map['colorSchemeSeed'] ?? map['seedColor'] ?? map['seed'],
  );
  final scheme = map.containsKey('colorScheme')
      ? _colorScheme(map['colorScheme'], fallbackBrightness: brightness)
      : seed != null
      ? ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness ?? Brightness.light,
        )
      : _colorScheme(map, fallbackBrightness: brightness);
  return ThemeData(
    useMaterial3: _bool(map['useMaterial3']) ?? true,
    useSystemColors: _bool(map['useSystemColors']),
    applyElevationOverlayColor: _bool(map['applyElevationOverlayColor']),
    materialTapTargetSize: _materialTapTargetSize(
      map['materialTapTargetSize'] ?? map['tapTargetSize'],
    ),
    platform: _targetPlatform(map['platform']),
    visualDensity: _visualDensity(map['visualDensity']),
    brightness: brightness,
    colorScheme: scheme,
    canvasColor: _color(map['canvasColor']),
    cardColor: _color(map['cardColor']),
    disabledColor: _color(map['disabledColor']),
    dividerColor: _color(map['dividerColor']),
    focusColor: _color(map['focusColor']),
    highlightColor: _color(map['highlightColor']),
    hintColor: _color(map['hintColor']),
    hoverColor: _color(map['hoverColor']),
    primaryColor: _color(map['primaryColor']),
    primaryColorDark: _color(map['primaryColorDark']),
    primaryColorLight: _color(map['primaryColorLight']),
    scaffoldBackgroundColor: _color(map['scaffoldBackgroundColor']),
    secondaryHeaderColor: _color(map['secondaryHeaderColor']),
    shadowColor: _color(map['shadowColor']),
    splashColor: _color(map['splashColor']),
    unselectedWidgetColor: _color(map['unselectedWidgetColor']),
    fontFamily: _string(map['fontFamily']),
    fontFamilyFallback: _stringList(
      map['fontFamilyFallback'] ?? map['fallback'],
    ),
    actionIconTheme: _actionIconThemeData(map['actionIconTheme']),
    iconTheme: map.containsKey('iconTheme')
        ? _iconThemeData(map['iconTheme'])
        : null,
    primaryIconTheme: map.containsKey('primaryIconTheme')
        ? _iconThemeData(map['primaryIconTheme'])
        : null,
    textTheme: _textTheme(map['textTheme']),
    primaryTextTheme: _textTheme(map['primaryTextTheme']),
    appBarTheme: _appBarThemeData(map['appBarTheme']),
    bottomAppBarTheme: _bottomAppBarThemeData(map['bottomAppBarTheme']),
    bottomNavigationBarTheme: _bottomNavigationBarThemeData(
      map['bottomNavigationBarTheme'],
    ),
    bottomSheetTheme: _bottomSheetThemeData(map['bottomSheetTheme']),
    buttonTheme: _buttonThemeData(map['buttonTheme']),
    badgeTheme: _badgeThemeData(map['badgeTheme']),
    bannerTheme: _materialBannerThemeData(
      map['bannerTheme'] ?? map['materialBannerTheme'],
    ),
    cardTheme: _cardThemeData(map['cardTheme']),
    carouselViewTheme: _carouselViewThemeData(map['carouselViewTheme']),
    checkboxTheme: _checkboxThemeData(map['checkboxTheme']),
    chipTheme: _chipThemeData(map['chipTheme']),
    dataTableTheme: _dataTableThemeData(map['dataTableTheme']),
    datePickerTheme: _datePickerThemeData(map['datePickerTheme']),
    dialogTheme: _dialogThemeData(map['dialogTheme']),
    dividerTheme: _dividerThemeData(map['dividerTheme']),
    drawerTheme: _drawerThemeData(map['drawerTheme']),
    dropdownMenuTheme: _dropdownMenuThemeData(map['dropdownMenuTheme']),
    elevatedButtonTheme: _elevatedButtonThemeData(map['elevatedButtonTheme']),
    filledButtonTheme: _filledButtonThemeData(map['filledButtonTheme']),
    floatingActionButtonTheme: _floatingActionButtonThemeData(
      map['floatingActionButtonTheme'],
    ),
    iconButtonTheme: _iconButtonThemeData(map['iconButtonTheme']),
    inputDecorationTheme: _inputDecorationThemeData(
      map['inputDecorationTheme'],
    ),
    listTileTheme: _listTileThemeData(map['listTileTheme']),
    expansionTileTheme: _expansionTileThemeData(map['expansionTileTheme']),
    menuBarTheme: _menuBarThemeData(map['menuBarTheme']),
    menuButtonTheme: _menuButtonThemeData(map['menuButtonTheme']),
    menuTheme: _menuThemeData(map['menuTheme']),
    navigationBarTheme: _navigationBarThemeData(map['navigationBarTheme']),
    navigationDrawerTheme: _navigationDrawerThemeData(
      map['navigationDrawerTheme'],
    ),
    navigationRailTheme: _navigationRailThemeData(map['navigationRailTheme']),
    outlinedButtonTheme: _outlinedButtonThemeData(map['outlinedButtonTheme']),
    popupMenuTheme: _popupMenuThemeData(map['popupMenuTheme']),
    progressIndicatorTheme: _progressIndicatorThemeData(
      map['progressIndicatorTheme'],
    ),
    radioTheme: _radioThemeData(map['radioTheme']),
    searchBarTheme: _searchBarThemeData(map['searchBarTheme']),
    searchViewTheme: _searchViewThemeData(map['searchViewTheme']),
    segmentedButtonTheme: _segmentedButtonThemeData(
      map['segmentedButtonTheme'],
    ),
    sliderTheme: _sliderThemeData(map['sliderTheme']),
    snackBarTheme: _snackBarThemeData(map['snackBarTheme']),
    scrollbarTheme: _scrollbarThemeData(map['scrollbarTheme']),
    switchTheme: _switchThemeData(map['switchTheme']),
    tabBarTheme: _tabBarThemeData(map['tabBarTheme']),
    textButtonTheme: _textButtonThemeData(map['textButtonTheme']),
    textSelectionTheme: _textSelectionThemeData(map['textSelectionTheme']),
    timePickerTheme: _timePickerThemeData(map['timePickerTheme']),
    toggleButtonsTheme: _toggleButtonsThemeData(map['toggleButtonsTheme']),
    tooltipTheme: _tooltipThemeData(map['tooltipTheme']),
  );
}

TextTheme? _textTheme(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TextTheme) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return TextTheme(
    displayLarge: _textStyle(map['displayLarge']),
    displayMedium: _textStyle(map['displayMedium']),
    displaySmall: _textStyle(map['displaySmall']),
    headlineLarge: _textStyle(map['headlineLarge']),
    headlineMedium: _textStyle(map['headlineMedium']),
    headlineSmall: _textStyle(map['headlineSmall']),
    titleLarge: _textStyle(map['titleLarge']),
    titleMedium: _textStyle(map['titleMedium']),
    titleSmall: _textStyle(map['titleSmall']),
    bodyLarge: _textStyle(map['bodyLarge']),
    bodyMedium: _textStyle(map['bodyMedium']),
    bodySmall: _textStyle(map['bodySmall']),
    labelLarge: _textStyle(map['labelLarge']),
    labelMedium: _textStyle(map['labelMedium']),
    labelSmall: _textStyle(map['labelSmall']),
  );
}

ActionIconThemeData? _actionIconThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ActionIconThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return ActionIconThemeData(
    backButtonIconBuilder: _actionIconBuilder(
      map['backButtonIconBuilder'] ?? map['backButtonIcon'] ?? map['backIcon'],
    ),
    closeButtonIconBuilder: _actionIconBuilder(
      map['closeButtonIconBuilder'] ??
          map['closeButtonIcon'] ??
          map['closeIcon'],
    ),
    drawerButtonIconBuilder: _actionIconBuilder(
      map['drawerButtonIconBuilder'] ??
          map['drawerButtonIcon'] ??
          map['drawerIcon'],
    ),
    endDrawerButtonIconBuilder: _actionIconBuilder(
      map['endDrawerButtonIconBuilder'] ??
          map['endDrawerButtonIcon'] ??
          map['endDrawerIcon'],
    ),
  );
}

WidgetBuilder? _actionIconBuilder(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is WidgetBuilder) {
    return value;
  }
  final icon = _stateIconValue(value);
  return icon == null ? null : (_) => icon;
}

AppBarThemeData? _appBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is AppBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return AppBarThemeData(
    backgroundColor: _color(map['backgroundColor'] ?? map['color']),
    foregroundColor: _color(map['foregroundColor']),
    elevation: _double(map['elevation']),
    scrolledUnderElevation: _double(map['scrolledUnderElevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    shape: _outlinedBorder(map['shape'] ?? map),
    iconTheme: map.containsKey('iconTheme')
        ? _iconThemeData(map['iconTheme'])
        : null,
    actionsIconTheme: map.containsKey('actionsIconTheme')
        ? _iconThemeData(map['actionsIconTheme'])
        : null,
    centerTitle: _bool(map['centerTitle']),
    titleSpacing: _double(map['titleSpacing']),
    leadingWidth: _double(map['leadingWidth']),
    toolbarHeight: _double(map['toolbarHeight']),
    toolbarTextStyle: _textStyle(map['toolbarTextStyle']),
    titleTextStyle: _textStyle(map['titleTextStyle']),
    actionsPadding: _edgeInsets(map['actionsPadding']),
  );
}

BottomSheetThemeData? _bottomSheetThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is BottomSheetThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return BottomSheetThemeData(
    backgroundColor: _color(map['backgroundColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    elevation: _double(map['elevation']),
    modalBackgroundColor: _color(map['modalBackgroundColor']),
    modalBarrierColor: _color(map['modalBarrierColor']),
    shadowColor: _color(map['shadowColor']),
    modalElevation: _double(map['modalElevation']),
    shape: _outlinedBorder(map['shape'] ?? map),
    showDragHandle: _bool(map['showDragHandle']),
    dragHandleColor: _color(map['dragHandleColor']),
    dragHandleSize: _size(map['dragHandleSize']),
    clipBehavior: _clip(map['clipBehavior']),
    constraints: _boxConstraints(map['constraints']),
  );
}

BottomAppBarThemeData? _bottomAppBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is BottomAppBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return BottomAppBarThemeData(color: _color(value));
  }
  final map = _stringMap(value);
  return BottomAppBarThemeData(
    color: _color(map['color'] ?? map['backgroundColor']),
    elevation: _nonNegativeDouble(map['elevation']),
    shape: _notchedShape(map['shape']),
    height: _positiveDouble(map['height']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    shadowColor: _color(map['shadowColor']),
    padding: _edgeInsets(map['padding']),
  );
}

BottomNavigationBarThemeData? _bottomNavigationBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is BottomNavigationBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return BottomNavigationBarThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return BottomNavigationBarThemeData(
    backgroundColor: _color(map['backgroundColor']),
    elevation: _nonNegativeDouble(map['elevation']),
    selectedIconTheme: _nullableIconThemeData(map['selectedIconTheme']),
    unselectedIconTheme: _nullableIconThemeData(map['unselectedIconTheme']),
    selectedItemColor: _color(map['selectedItemColor'] ?? map['fixedColor']),
    unselectedItemColor: _color(map['unselectedItemColor']),
    selectedLabelStyle: _textStyle(map['selectedLabelStyle']),
    unselectedLabelStyle: _textStyle(map['unselectedLabelStyle']),
    showSelectedLabels: _bool(map['showSelectedLabels']),
    showUnselectedLabels: _bool(map['showUnselectedLabels']),
    type: _bottomNavigationBarType(map['type'] ?? map['barType']),
    enableFeedback: _bool(map['enableFeedback']),
    landscapeLayout: _bottomNavigationBarLandscapeLayout(
      map['landscapeLayout'],
    ),
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
  );
}

BadgeThemeData? _badgeThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is BadgeThemeData) {
    return value;
  }
  if (value is! Map) {
    return BadgeThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return BadgeThemeData(
    backgroundColor: _color(map['backgroundColor'] ?? map['color']),
    textColor: _color(map['textColor']),
    smallSize: _nonNegativeDouble(map['smallSize']),
    largeSize: _nonNegativeDouble(map['largeSize']),
    textStyle: _textStyle(map['textStyle'] ?? map['style']),
    padding: _edgeInsets(map['padding']),
    alignment: _alignment(map['alignment']),
    offset: _offset(map['offset']),
  );
}

MaterialBannerThemeData? _materialBannerThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is MaterialBannerThemeData) {
    return value;
  }
  if (value is! Map) {
    return MaterialBannerThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return MaterialBannerThemeData(
    backgroundColor: _color(map['backgroundColor'] ?? map['color']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    shadowColor: _color(map['shadowColor']),
    dividerColor: _color(map['dividerColor']),
    contentTextStyle: _textStyle(map['contentTextStyle'] ?? map['textStyle']),
    elevation: _nonNegativeDouble(map['elevation']),
    padding: _edgeInsets(map['padding']),
    leadingPadding: _edgeInsets(map['leadingPadding']),
  );
}

CardThemeData? _cardThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is CardThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return CardThemeData(
    clipBehavior: _clip(map['clipBehavior']),
    color: _color(map['color'] ?? map['backgroundColor']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    elevation: _double(map['elevation']),
    margin: _edgeInsets(map['margin']),
    shape: _outlinedBorder(map['shape'] ?? map),
  );
}

ButtonThemeData? _buttonThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ButtonThemeData) {
    return value;
  }
  if (value is! Map) {
    return ButtonThemeData(buttonColor: _color(value));
  }
  final map = _stringMap(value);
  return ButtonThemeData(
    textTheme: _buttonTextTheme(map['textTheme']) ?? ButtonTextTheme.normal,
    minWidth: _nonNegativeDouble(map['minWidth'] ?? map['minimumWidth']) ?? 88,
    height: _nonNegativeDouble(map['height']) ?? 36,
    padding: _edgeInsets(map['padding']),
    shape: _outlinedBorder(map['shape'] ?? map),
    layoutBehavior:
        _buttonBarLayoutBehavior(map['layoutBehavior']) ??
        ButtonBarLayoutBehavior.padded,
    alignedDropdown: _bool(map['alignedDropdown']) ?? false,
    buttonColor: _color(map['buttonColor'] ?? map['backgroundColor']),
    disabledColor: _color(map['disabledColor']),
    focusColor: _color(map['focusColor']),
    hoverColor: _color(map['hoverColor']),
    highlightColor: _color(map['highlightColor']),
    splashColor: _color(map['splashColor']),
    colorScheme: _colorScheme(map['colorScheme']),
    materialTapTargetSize: _materialTapTargetSize(
      map['materialTapTargetSize'] ?? map['tapTargetSize'],
    ),
  );
}

CarouselViewThemeData? _carouselViewThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is CarouselViewThemeData) {
    return value;
  }
  if (value is! Map) {
    return CarouselViewThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return CarouselViewThemeData(
    elevation: _nonNegativeDouble(map['elevation']),
    backgroundColor: _color(map['backgroundColor']),
    overlayColor: _stateColor(map['overlayColor']),
    shape: _outlinedBorder(map['shape'] ?? map),
    padding: _edgeInsetsOnly(map['padding']),
    itemClipBehavior: _clip(map['itemClipBehavior'] ?? map['clipBehavior']),
  );
}

ChipThemeData? _chipThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ChipThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return ChipThemeData(
    color: map.containsKey('color') ? _state(_color(map['color'])) : null,
    backgroundColor: _color(map['backgroundColor']),
    deleteIconColor: _color(map['deleteIconColor']),
    disabledColor: _color(map['disabledColor']),
    selectedColor: _color(map['selectedColor']),
    secondarySelectedColor: _color(map['secondarySelectedColor']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    selectedShadowColor: _color(map['selectedShadowColor']),
    showCheckmark: _bool(map['showCheckmark']),
    checkmarkColor: _color(map['checkmarkColor']),
    labelPadding: _edgeInsets(map['labelPadding']),
    padding: _edgeInsets(map['padding']),
    side: _borderSide(map['side']),
    shape: _outlinedBorder(map['shape'] ?? map),
    labelStyle: _textStyle(map['labelStyle']),
    secondaryLabelStyle: _textStyle(map['secondaryLabelStyle']),
    brightness: _brightness(map['brightness']),
    elevation: _nonNegativeDouble(map['elevation']),
    pressElevation: _nonNegativeDouble(map['pressElevation']),
    iconTheme: map.containsKey('iconTheme')
        ? _iconThemeData(map['iconTheme'])
        : null,
    avatarBoxConstraints: _boxConstraints(map['avatarBoxConstraints']),
    deleteIconBoxConstraints: _boxConstraints(map['deleteIconBoxConstraints']),
  );
}

DataTableThemeData? _dataTableThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DataTableThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return DataTableThemeData(
    decoration: _boxDecoration(map['decoration']),
    dataRowColor: _stateColor(map['dataRowColor']),
    dataRowMinHeight:
        _nonNegativeDouble(map['dataRowMinHeight']) ??
        _nonNegativeDouble(map['dataRowHeight']),
    dataRowMaxHeight:
        _safeMaxHeight(map['dataRowMaxHeight'], map['dataRowMinHeight']) ??
        _nonNegativeDouble(map['dataRowHeight']),
    dataTextStyle: _dataTableTextStyle(map['dataTextStyle']),
    headingRowColor: _stateColor(map['headingRowColor']),
    headingRowHeight: _nonNegativeDouble(map['headingRowHeight']),
    headingTextStyle: _textStyle(map['headingTextStyle']),
    horizontalMargin: _nonNegativeDouble(map['horizontalMargin']),
    columnSpacing: _nonNegativeDouble(map['columnSpacing']),
    dividerThickness: _nonNegativeDouble(map['dividerThickness']),
    checkboxHorizontalMargin: _nonNegativeDouble(
      map['checkboxHorizontalMargin'],
    ),
    headingCellCursor: _stateMouseCursor(
      map['headingCellCursor'] ?? map['headingCursor'],
    ),
    dataRowCursor: _stateMouseCursor(map['dataRowCursor'] ?? map['rowCursor']),
    headingRowAlignment: _mainAxisAlignment(map['headingRowAlignment']),
  );
}

DatePickerThemeData? _datePickerThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DatePickerThemeData) {
    return value;
  }
  if (value is! Map) {
    return DatePickerThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return DatePickerThemeData(
    backgroundColor: _color(map['backgroundColor'] ?? map['color']),
    elevation: _nonNegativeDouble(map['elevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    shape: _outlinedBorder(map['shape'] ?? map),
    headerBackgroundColor: _color(map['headerBackgroundColor']),
    headerForegroundColor: _color(map['headerForegroundColor']),
    headerHeadlineStyle: _textStyle(map['headerHeadlineStyle']),
    headerHelpStyle: _textStyle(map['headerHelpStyle']),
    weekdayStyle: _textStyle(map['weekdayStyle']),
    dayStyle: _textStyle(map['dayStyle']),
    dayForegroundColor: _stateColor(map['dayForegroundColor']),
    dayBackgroundColor: _stateColor(map['dayBackgroundColor']),
    dayOverlayColor: _stateColor(map['dayOverlayColor']),
    dayShape: _stateProperty<OutlinedBorder>(map['dayShape'], _outlinedBorder),
    todayForegroundColor: _stateColor(map['todayForegroundColor']),
    todayBackgroundColor: _stateColor(map['todayBackgroundColor']),
    todayBorder: _borderSide(map['todayBorder']),
    yearStyle: _textStyle(map['yearStyle']),
    yearForegroundColor: _stateColor(map['yearForegroundColor']),
    yearBackgroundColor: _stateColor(map['yearBackgroundColor']),
    yearOverlayColor: _stateColor(map['yearOverlayColor']),
    yearShape: _stateProperty<OutlinedBorder>(
      map['yearShape'],
      _outlinedBorder,
    ),
    rangePickerBackgroundColor: _color(map['rangePickerBackgroundColor']),
    rangePickerElevation: _nonNegativeDouble(map['rangePickerElevation']),
    rangePickerShadowColor: _color(map['rangePickerShadowColor']),
    rangePickerSurfaceTintColor: _color(map['rangePickerSurfaceTintColor']),
    rangePickerShape: _outlinedBorder(map['rangePickerShape']),
    rangePickerHeaderBackgroundColor: _color(
      map['rangePickerHeaderBackgroundColor'],
    ),
    rangePickerHeaderForegroundColor: _color(
      map['rangePickerHeaderForegroundColor'],
    ),
    rangePickerHeaderHeadlineStyle: _textStyle(
      map['rangePickerHeaderHeadlineStyle'],
    ),
    rangePickerHeaderHelpStyle: _textStyle(map['rangePickerHeaderHelpStyle']),
    rangeSelectionBackgroundColor: _color(map['rangeSelectionBackgroundColor']),
    rangeSelectionOverlayColor: _stateColor(map['rangeSelectionOverlayColor']),
    dividerColor: _color(map['dividerColor']),
    inputDecorationTheme: _inputDecorationThemeData(
      map['inputDecorationTheme'] ?? map['decorationTheme'],
    ),
    cancelButtonStyle: _buttonStyle(map['cancelButtonStyle']),
    confirmButtonStyle: _buttonStyle(map['confirmButtonStyle']),
    locale: _locale(map['locale']),
    toggleButtonTextStyle: _textStyle(map['toggleButtonTextStyle']),
    subHeaderForegroundColor: _color(map['subHeaderForegroundColor']),
  );
}

DialogThemeData? _dialogThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DialogThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return DialogThemeData(
    backgroundColor: _color(map['backgroundColor']),
    elevation: _double(map['elevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    shape: _outlinedBorder(map['shape'] ?? map),
    alignment: _alignment(map['alignment']),
    iconColor: _color(map['iconColor']),
    titleTextStyle: _textStyle(map['titleTextStyle']),
    contentTextStyle: _textStyle(map['contentTextStyle']),
    actionsPadding: _edgeInsets(map['actionsPadding']),
    barrierColor: _color(map['barrierColor']),
    insetPadding: _edgeInsets(map['insetPadding']) as EdgeInsets?,
    clipBehavior: _clip(map['clipBehavior']),
    constraints: _boxConstraints(map['constraints']),
  );
}

DividerThemeData? _dividerThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DividerThemeData) {
    return value;
  }
  if (value is! Map) {
    return DividerThemeData(color: _color(value));
  }
  final map = _stringMap(value);
  return DividerThemeData(
    color: _color(map['color']),
    space: _nonNegativeDouble(map['space'] ?? map['height'] ?? map['width']),
    thickness: _nonNegativeDouble(map['thickness']),
    indent: _nonNegativeDouble(map['indent']),
    endIndent: _nonNegativeDouble(map['endIndent']),
    radius: _borderRadius(map['radius'] ?? map['borderRadius']),
  );
}

DrawerThemeData? _drawerThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DrawerThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return DrawerThemeData(
    backgroundColor: _color(map['backgroundColor']),
    scrimColor: _color(map['scrimColor']),
    elevation: _double(map['elevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    shape: _outlinedBorder(map['shape'] ?? map),
    endShape: _outlinedBorder(map['endShape']),
    width: _double(map['width']),
    clipBehavior: _clip(map['clipBehavior']),
  );
}

DropdownMenuThemeData? _dropdownMenuThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DropdownMenuThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return DropdownMenuThemeData(
    textStyle: _textStyle(map['textStyle'] ?? map['style']),
    inputDecorationTheme: _inputDecorationThemeData(
      map['inputDecorationTheme'] ?? map['decoration'],
    ),
    menuStyle: _menuStyle(map['menuStyle']),
    disabledColor: _color(map['disabledColor']),
  );
}

MenuBarThemeData? _menuBarThemeData(Object? value) {
  final style = _menuStyle(
    value is Map ? _stringMap(value)['style'] ?? value : value,
  );
  return style == null ? null : MenuBarThemeData(style: style);
}

MenuButtonThemeData? _menuButtonThemeData(Object? value) {
  final style = _themeButtonStyle(value);
  return style == null ? null : MenuButtonThemeData(style: style);
}

MenuThemeData? _menuThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is MenuThemeData) {
    return value;
  }
  if (value is! Map) {
    final style = _menuStyle(value);
    return style == null ? null : MenuThemeData(style: style);
  }
  final map = _stringMap(value);
  return MenuThemeData(
    style: _menuStyle(map['style'] ?? map),
    submenuIcon: _stateWidgetIcon(map['submenuIcon']),
  );
}

PopupMenuThemeData? _popupMenuThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is PopupMenuThemeData) {
    return value;
  }
  if (value is! Map) {
    return PopupMenuThemeData(color: _color(value));
  }
  final map = _stringMap(value);
  return PopupMenuThemeData(
    color: _color(map['color'] ?? map['backgroundColor']),
    shape: _outlinedBorder(map['shape'] ?? map),
    menuPadding: _edgeInsets(map['menuPadding'] ?? map['padding']),
    elevation: _double(map['elevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    textStyle: _textStyle(map['textStyle']),
    labelTextStyle: _stateProperty<TextStyle>(
      map['labelTextStyle'],
      _textStyle,
    ),
    enableFeedback: _bool(map['enableFeedback']),
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
    position: _popupMenuPosition(map['position']),
    iconColor: _color(map['iconColor']),
    iconSize: _double(map['iconSize']),
  );
}

ProgressIndicatorThemeData? _progressIndicatorThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ProgressIndicatorThemeData) {
    return value;
  }
  if (value is! Map) {
    return ProgressIndicatorThemeData(color: _color(value));
  }
  final map = _stringMap(value);
  return ProgressIndicatorThemeData(
    color: _color(map['color']),
    linearTrackColor: _color(map['linearTrackColor'] ?? map['trackColor']),
    linearMinHeight: _positiveDouble(
      map['linearMinHeight'] ?? map['minHeight'],
    ),
    circularTrackColor: _color(map['circularTrackColor']),
    refreshBackgroundColor: _color(map['refreshBackgroundColor']),
    borderRadius: _borderRadius(map['borderRadius'] ?? map['radius']),
    stopIndicatorColor: _color(map['stopIndicatorColor']),
    stopIndicatorRadius: _nonNegativeDouble(map['stopIndicatorRadius']),
    strokeWidth: _positiveDouble(map['strokeWidth']),
    strokeAlign: _double(map['strokeAlign']),
    strokeCap: _strokeCap(map['strokeCap']),
    constraints: _boxConstraints(map['constraints']),
    trackGap: _nonNegativeDouble(map['trackGap']),
    circularTrackPadding: _edgeInsets(map['circularTrackPadding']),
  );
}

SearchBarThemeData? _searchBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SearchBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return SearchBarThemeData(backgroundColor: _state(_color(value)));
  }
  final map = _stringMap(value);
  return SearchBarThemeData(
    elevation: _stateProperty<double>(map['elevation'], _nonNegativeDouble),
    backgroundColor: _stateColor(map['backgroundColor'] ?? map['color']),
    shadowColor: _stateColor(map['shadowColor']),
    surfaceTintColor: _stateColor(map['surfaceTintColor']),
    overlayColor: _stateColor(map['overlayColor']),
    side: _stateProperty<BorderSide>(map['side'], _borderSide),
    shape: _stateProperty<OutlinedBorder>(map['shape'] ?? map, _outlinedBorder),
    padding: _stateProperty<EdgeInsetsGeometry>(map['padding'], _edgeInsets),
    textStyle: _stateProperty<TextStyle>(
      map['textStyle'] ?? map['style'],
      _textStyle,
    ),
    hintStyle: _stateProperty<TextStyle>(map['hintStyle'], _textStyle),
    constraints: _boxConstraints(map['constraints']),
    textCapitalization: _textCapitalization(map['textCapitalization']),
  );
}

SearchViewThemeData? _searchViewThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SearchViewThemeData) {
    return value;
  }
  if (value is! Map) {
    return SearchViewThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return SearchViewThemeData(
    backgroundColor: _color(map['backgroundColor'] ?? map['color']),
    elevation: _nonNegativeDouble(map['elevation']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    side: _borderSide(map['side']),
    shape: _outlinedBorder(map['shape'] ?? map),
    headerHeight: _nonNegativeDouble(
      map['headerHeight'] ?? map['viewHeaderHeight'],
    ),
    headerTextStyle: _textStyle(
      map['headerTextStyle'] ?? map['viewHeaderTextStyle'],
    ),
    headerHintStyle: _textStyle(
      map['headerHintStyle'] ?? map['viewHeaderHintStyle'],
    ),
    constraints: _boxConstraints(map['constraints'] ?? map['viewConstraints']),
    padding: _edgeInsets(map['padding'] ?? map['viewPadding']),
    barPadding: _edgeInsets(map['barPadding'] ?? map['viewBarPadding']),
    shrinkWrap: _bool(map['shrinkWrap']),
    dividerColor: _color(map['dividerColor']),
  );
}

ElevatedButtonThemeData? _elevatedButtonThemeData(Object? value) {
  final style = _themeButtonStyle(value);
  return style == null ? null : ElevatedButtonThemeData(style: style);
}

FilledButtonThemeData? _filledButtonThemeData(Object? value) {
  final style = _themeButtonStyle(value);
  return style == null ? null : FilledButtonThemeData(style: style);
}

IconButtonThemeData? _iconButtonThemeData(Object? value) {
  final style = _themeButtonStyle(value);
  return style == null ? null : IconButtonThemeData(style: style);
}

OutlinedButtonThemeData? _outlinedButtonThemeData(Object? value) {
  final style = _themeButtonStyle(value);
  return style == null ? null : OutlinedButtonThemeData(style: style);
}

TextButtonThemeData? _textButtonThemeData(Object? value) {
  final style = _themeButtonStyle(value);
  return style == null ? null : TextButtonThemeData(style: style);
}

TextSelectionThemeData? _textSelectionThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TextSelectionThemeData) {
    return value;
  }
  if (value is! Map) {
    return TextSelectionThemeData(selectionColor: _color(value));
  }
  final map = _stringMap(value);
  return TextSelectionThemeData(
    cursorColor: _color(map['cursorColor']),
    selectionColor: _color(map['selectionColor'] ?? map['color']),
    selectionHandleColor: _color(map['selectionHandleColor']),
  );
}

ButtonStyle? _themeButtonStyle(Object? value) {
  if (value is Map) {
    final map = _stringMap(value);
    return _buttonStyle(map['style'] ?? map);
  }
  return _buttonStyle(value);
}

FloatingActionButtonThemeData? _floatingActionButtonThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is FloatingActionButtonThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return FloatingActionButtonThemeData(
    foregroundColor: _color(map['foregroundColor']),
    backgroundColor: _color(map['backgroundColor']),
    focusColor: _color(map['focusColor']),
    hoverColor: _color(map['hoverColor']),
    splashColor: _color(map['splashColor']),
    elevation: _double(map['elevation']),
    focusElevation: _double(map['focusElevation']),
    hoverElevation: _double(map['hoverElevation']),
    disabledElevation: _double(map['disabledElevation']),
    highlightElevation: _double(map['highlightElevation']),
    shape: _outlinedBorder(map['shape'] ?? map),
    enableFeedback: _bool(map['enableFeedback']),
    iconSize: _double(map['iconSize']),
    extendedPadding: _edgeInsets(map['extendedPadding']),
    extendedTextStyle: _textStyle(map['extendedTextStyle']),
  );
}

CheckboxThemeData? _checkboxThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is CheckboxThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return CheckboxThemeData(
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
    fillColor: _stateColor(map['fillColor']),
    checkColor: _stateColor(map['checkColor']),
    overlayColor: _stateColor(map['overlayColor']),
    splashRadius: _double(map['splashRadius']),
    materialTapTargetSize: _materialTapTargetSize(
      map['materialTapTargetSize'] ?? map['tapTargetSize'],
    ),
    visualDensity: _visualDensity(map['visualDensity']),
    shape: _outlinedBorder(map['shape']),
    side: _borderSide(map['side']),
  );
}

RadioThemeData? _radioThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is RadioThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return RadioThemeData(
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
    fillColor: _stateColor(map['fillColor']),
    overlayColor: _stateColor(map['overlayColor']),
    splashRadius: _double(map['splashRadius']),
    materialTapTargetSize: _materialTapTargetSize(
      map['materialTapTargetSize'] ?? map['tapTargetSize'],
    ),
    visualDensity: _visualDensity(map['visualDensity']),
    backgroundColor: _stateColor(map['backgroundColor']),
    side: _borderSide(map['side']),
    innerRadius: _stateDouble(map['innerRadius']),
  );
}

SwitchThemeData? _switchThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SwitchThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return SwitchThemeData(
    thumbColor: _stateColor(map['thumbColor']),
    trackColor: _stateColor(map['trackColor']),
    trackOutlineColor: _stateColor(map['trackOutlineColor']),
    trackOutlineWidth: _stateDouble(map['trackOutlineWidth']),
    materialTapTargetSize: _materialTapTargetSize(
      map['materialTapTargetSize'] ?? map['tapTargetSize'],
    ),
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
    overlayColor: _stateColor(map['overlayColor']),
    splashRadius: _double(map['splashRadius']),
    thumbIcon: _stateIcon(map['thumbIcon']),
    padding: _edgeInsets(map['padding']),
  );
}

SliderThemeData? _sliderThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SliderThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return SliderThemeData(
    trackHeight: _double(map['trackHeight']),
    activeTrackColor: _color(map['activeTrackColor']),
    inactiveTrackColor: _color(map['inactiveTrackColor']),
    secondaryActiveTrackColor: _color(map['secondaryActiveTrackColor']),
    disabledActiveTrackColor: _color(map['disabledActiveTrackColor']),
    disabledInactiveTrackColor: _color(map['disabledInactiveTrackColor']),
    disabledSecondaryActiveTrackColor: _color(
      map['disabledSecondaryActiveTrackColor'],
    ),
    activeTickMarkColor: _color(map['activeTickMarkColor']),
    inactiveTickMarkColor: _color(map['inactiveTickMarkColor']),
    disabledActiveTickMarkColor: _color(map['disabledActiveTickMarkColor']),
    disabledInactiveTickMarkColor: _color(map['disabledInactiveTickMarkColor']),
    thumbColor: _color(map['thumbColor']),
    overlappingShapeStrokeColor: _color(map['overlappingShapeStrokeColor']),
    disabledThumbColor: _color(map['disabledThumbColor']),
    overlayColor: _color(map['overlayColor']),
    valueIndicatorColor: _color(map['valueIndicatorColor']),
    valueIndicatorStrokeColor: _color(map['valueIndicatorStrokeColor']),
    showValueIndicator: _showValueIndicator(map['showValueIndicator']),
    valueIndicatorTextStyle: _textStyle(map['valueIndicatorTextStyle']),
    minThumbSeparation: _double(map['minThumbSeparation']),
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
    allowedInteraction: _sliderInteraction(map['allowedInteraction']),
    padding: _edgeInsets(map['padding']),
    thumbSize: _stateSize(map['thumbSize']),
    trackGap: _double(map['trackGap']),
  );
}

SegmentedButtonThemeData? _segmentedButtonThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SegmentedButtonThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return SegmentedButtonThemeData(
    style: _buttonStyle(map['style'] ?? map),
    selectedIcon: _stateIconValue(map['selectedIcon']),
  );
}

InputDecorationThemeData? _inputDecorationThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is InputDecorationThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return InputDecorationThemeData(
    labelStyle: _textStyle(map['labelStyle']),
    floatingLabelStyle: _textStyle(map['floatingLabelStyle']),
    helperStyle: _textStyle(map['helperStyle']),
    helperMaxLines: _int(map['helperMaxLines']),
    hintStyle: _textStyle(map['hintStyle']),
    hintFadeDuration: _duration(map['hintFadeDuration']),
    hintMaxLines: _int(map['hintMaxLines']),
    errorStyle: _textStyle(map['errorStyle']),
    errorMaxLines: _int(map['errorMaxLines']),
    floatingLabelBehavior:
        _floatingLabelBehavior(map['floatingLabelBehavior']) ??
        FloatingLabelBehavior.auto,
    floatingLabelAlignment:
        _floatingLabelAlignment(map['floatingLabelAlignment']) ??
        FloatingLabelAlignment.start,
    isDense: _bool(map['isDense']) ?? false,
    contentPadding: _edgeInsets(map['contentPadding']),
    isCollapsed: _bool(map['isCollapsed']) ?? false,
    iconColor: _color(map['iconColor']),
    prefixStyle: _textStyle(map['prefixStyle']),
    prefixIconColor: _color(map['prefixIconColor']),
    prefixIconConstraints: _boxConstraints(map['prefixIconConstraints']),
    suffixStyle: _textStyle(map['suffixStyle']),
    suffixIconColor: _color(map['suffixIconColor']),
    suffixIconConstraints: _boxConstraints(map['suffixIconConstraints']),
    counterStyle: _textStyle(map['counterStyle']),
    filled: _bool(map['filled']) ?? false,
    fillColor: _color(map['fillColor']),
    activeIndicatorBorder: _borderSide(map['activeIndicatorBorder']),
    outlineBorder: _borderSide(map['outlineBorder']),
    focusColor: _color(map['focusColor']),
    hoverColor: _color(map['hoverColor']),
    errorBorder: _inputBorder(map['errorBorder']),
    focusedBorder: _inputBorder(map['focusedBorder']),
    focusedErrorBorder: _inputBorder(map['focusedErrorBorder']),
    disabledBorder: _inputBorder(map['disabledBorder']),
    enabledBorder: _inputBorder(map['enabledBorder']),
    border: _inputBorder(map['border']),
    alignLabelWithHint: _bool(map['alignLabelWithHint']) ?? false,
    constraints: _boxConstraints(map['constraints']),
    visualDensity: _visualDensity(map['visualDensity']),
  );
}

ListTileThemeData? _listTileThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ListTileThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return ListTileThemeData(
    dense: _bool(map['dense']),
    shape: _outlinedBorder(map['shape'] ?? map),
    style: _listTileStyle(map['style']),
    selectedColor: _color(map['selectedColor']),
    iconColor: _color(map['iconColor']),
    textColor: _color(map['textColor']),
    titleTextStyle: _textStyle(map['titleTextStyle']),
    subtitleTextStyle: _textStyle(map['subtitleTextStyle']),
    leadingAndTrailingTextStyle: _textStyle(map['leadingAndTrailingTextStyle']),
    contentPadding: _edgeInsets(map['contentPadding']),
    tileColor: _color(map['tileColor']),
    selectedTileColor: _color(map['selectedTileColor']),
    horizontalTitleGap: _double(map['horizontalTitleGap']),
    minVerticalPadding: _double(map['minVerticalPadding']),
    minLeadingWidth: _double(map['minLeadingWidth']),
    enableFeedback: _bool(map['enableFeedback']),
    mouseCursor: _hasAny(map, const ['mouseCursor', 'cursor'])
        ? _state(_mouseCursor(map['mouseCursor'] ?? map['cursor']))
        : null,
    visualDensity: _visualDensity(map['visualDensity']),
    minTileHeight: _double(map['minTileHeight']),
    titleAlignment: _listTileTitleAlignment(map['titleAlignment']),
    controlAffinity: _listTileControlAffinity(map['controlAffinity']),
    isThreeLine: _bool(map['isThreeLine']),
  );
}

ExpansionTileThemeData? _expansionTileThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ExpansionTileThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return ExpansionTileThemeData(
    backgroundColor: _color(map['backgroundColor']),
    collapsedBackgroundColor: _color(map['collapsedBackgroundColor']),
    tilePadding: _edgeInsets(map['tilePadding']),
    expandedAlignment: _alignment(map['expandedAlignment']),
    childrenPadding: _edgeInsets(map['childrenPadding']),
    iconColor: _color(map['iconColor']),
    collapsedIconColor: _color(map['collapsedIconColor']),
    textColor: _color(map['textColor']),
    collapsedTextColor: _color(map['collapsedTextColor']),
    shape: _outlinedBorder(map['shape']),
    collapsedShape: _outlinedBorder(map['collapsedShape']),
    clipBehavior: _clip(map['clipBehavior']),
    expansionAnimationStyle: _animationStyle(
      map['expansionAnimationStyle'] ?? map['animationStyle'],
    ),
  );
}

NavigationBarThemeData? _navigationBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is NavigationBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return NavigationBarThemeData(
    height: _double(map['height']),
    backgroundColor: _color(map['backgroundColor']),
    elevation: _double(map['elevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    indicatorColor: _color(map['indicatorColor']),
    indicatorShape: _outlinedBorder(map['indicatorShape']),
    labelTextStyle: _stateProperty<TextStyle>(
      map['labelTextStyle'],
      _textStyle,
    ),
    iconTheme: _stateIconTheme(map['iconTheme']),
    labelBehavior: _navigationDestinationLabelBehavior(map['labelBehavior']),
    overlayColor: _stateColor(map['overlayColor']),
    labelPadding: _edgeInsets(map['labelPadding']),
  );
}

NavigationDrawerThemeData? _navigationDrawerThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is NavigationDrawerThemeData) {
    return value;
  }
  if (value is! Map) {
    return NavigationDrawerThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return NavigationDrawerThemeData(
    tileHeight: _positiveDouble(map['tileHeight']),
    backgroundColor: _color(map['backgroundColor']),
    elevation: _nonNegativeDouble(map['elevation']),
    shadowColor: _color(map['shadowColor']),
    surfaceTintColor: _color(map['surfaceTintColor']),
    indicatorColor: _color(map['indicatorColor']),
    indicatorShape: _outlinedBorder(map['indicatorShape']),
    indicatorSize: _size(map['indicatorSize']),
    labelTextStyle: _stateProperty<TextStyle>(
      map['labelTextStyle'],
      _textStyle,
    ),
    iconTheme: _stateIconTheme(map['iconTheme']),
  );
}

NavigationRailThemeData? _navigationRailThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is NavigationRailThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return NavigationRailThemeData(
    backgroundColor: _color(map['backgroundColor']),
    elevation: _double(map['elevation']),
    unselectedLabelTextStyle: _textStyle(map['unselectedLabelTextStyle']),
    selectedLabelTextStyle: _textStyle(map['selectedLabelTextStyle']),
    unselectedIconTheme: map.containsKey('unselectedIconTheme')
        ? _iconThemeData(map['unselectedIconTheme'])
        : null,
    selectedIconTheme: map.containsKey('selectedIconTheme')
        ? _iconThemeData(map['selectedIconTheme'])
        : null,
    groupAlignment: _double(map['groupAlignment']),
    labelType: _navigationRailLabelType(map['labelType']),
    useIndicator: _bool(map['useIndicator']),
    indicatorColor: _color(map['indicatorColor']),
    indicatorShape: _outlinedBorder(map['indicatorShape']),
    minWidth: _double(map['minWidth']),
    minExtendedWidth: _double(map['minExtendedWidth']),
  );
}

ScrollbarThemeData? _scrollbarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ScrollbarThemeData) {
    return value;
  }
  if (value is! Map) {
    return ScrollbarThemeData(thumbColor: _stateColor(value));
  }
  final map = _stringMap(value);
  return ScrollbarThemeData(
    thumbVisibility: _stateProperty<bool>(
      map['thumbVisibility'] ?? map['isThumbVisible'],
      _bool,
    ),
    thickness: _stateProperty<double>(map['thickness'], _nonNegativeDouble),
    trackVisibility: _stateProperty<bool>(
      map['trackVisibility'] ?? map['isTrackVisible'],
      _bool,
    ),
    radius: _nonNegativeRadius(map['radius']),
    thumbColor: _stateColor(map['thumbColor']),
    trackColor: _stateColor(map['trackColor']),
    trackBorderColor: _stateColor(
      map['trackBorderColor'] ?? map['trackOutlineColor'],
    ),
    crossAxisMargin: _nonNegativeDouble(map['crossAxisMargin']),
    mainAxisMargin: _nonNegativeDouble(map['mainAxisMargin']),
    minThumbLength: _nonNegativeDouble(
      map['minThumbLength'] ?? map['minLength'],
    ),
    interactive: _bool(map['interactive']),
  );
}

SnackBarThemeData? _snackBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SnackBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final behavior = _snackBarBehaviorValue(map['behavior']);
  return SnackBarThemeData(
    backgroundColor: _color(map['backgroundColor']),
    actionTextColor: _color(map['actionTextColor']),
    disabledActionTextColor: _color(map['disabledActionTextColor']),
    contentTextStyle: _textStyle(map['contentTextStyle']),
    elevation: _double(map['elevation']),
    shape: _outlinedBorder(map['shape'] ?? map),
    behavior: behavior,
    width: behavior == SnackBarBehavior.floating ? _double(map['width']) : null,
    insetPadding: _edgeInsetsOnly(map['insetPadding']),
    showCloseIcon: _bool(map['showCloseIcon']),
    closeIconColor: _color(map['closeIconColor']),
    actionOverflowThreshold: _unitDouble(map['actionOverflowThreshold']),
    actionBackgroundColor: _color(map['actionBackgroundColor']),
    disabledActionBackgroundColor: _color(map['disabledActionBackgroundColor']),
    dismissDirection: _dismissDirection(map['dismissDirection']),
  );
}

TabBarThemeData? _tabBarThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TabBarThemeData) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return TabBarThemeData(
    indicatorColor: _color(map['indicatorColor']),
    indicatorSize: _tabBarIndicatorSize(map['indicatorSize']),
    dividerColor: _color(map['dividerColor']),
    dividerHeight: _double(map['dividerHeight']),
    labelColor: _color(map['labelColor']),
    labelPadding: _edgeInsets(map['labelPadding']),
    labelStyle: _textStyle(map['labelStyle']),
    unselectedLabelColor: _color(map['unselectedLabelColor']),
    unselectedLabelStyle: _textStyle(map['unselectedLabelStyle']),
    overlayColor: _state(_color(map['overlayColor'])),
    splashBorderRadius: _borderRadius(map['splashBorderRadius']),
  );
}

TimePickerThemeData? _timePickerThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TimePickerThemeData) {
    return value;
  }
  if (value is! Map) {
    return TimePickerThemeData(backgroundColor: _color(value));
  }
  final map = _stringMap(value);
  return TimePickerThemeData(
    backgroundColor: _color(map['backgroundColor'] ?? map['color']),
    cancelButtonStyle: _buttonStyle(map['cancelButtonStyle']),
    confirmButtonStyle: _buttonStyle(map['confirmButtonStyle']),
    dayPeriodBorderSide: _borderSide(map['dayPeriodBorderSide']),
    dayPeriodColor: _widgetStateColor(map['dayPeriodColor']),
    dayPeriodShape: _outlinedBorder(map['dayPeriodShape']),
    dayPeriodTextColor: _widgetStateColor(map['dayPeriodTextColor']),
    dayPeriodTextStyle: _textStyle(map['dayPeriodTextStyle']),
    dialBackgroundColor: _color(map['dialBackgroundColor']),
    dialHandColor: _color(map['dialHandColor']),
    dialTextColor: _widgetStateColor(map['dialTextColor']),
    dialTextStyle: _textStyle(map['dialTextStyle']),
    elevation: _nonNegativeDouble(map['elevation']),
    entryModeIconColor: _color(map['entryModeIconColor']),
    helpTextStyle: _textStyle(map['helpTextStyle']),
    hourMinuteColor: _widgetStateColor(map['hourMinuteColor']),
    hourMinuteShape: _outlinedBorder(map['hourMinuteShape']),
    hourMinuteTextColor: _widgetStateColor(map['hourMinuteTextColor']),
    hourMinuteTextStyle: _textStyle(map['hourMinuteTextStyle']),
    inputDecorationTheme: _inputDecorationThemeData(
      map['inputDecorationTheme'] ?? map['decorationTheme'],
    ),
    padding: _edgeInsets(map['padding']),
    shape: _outlinedBorder(map['shape'] ?? map),
    timeSelectorSeparatorColor: _stateColor(
      map['timeSelectorSeparatorColor'] ?? map['separatorColor'],
    ),
    timeSelectorSeparatorTextStyle: _stateProperty<TextStyle>(
      map['timeSelectorSeparatorTextStyle'] ?? map['separatorTextStyle'],
      _textStyle,
    ),
  );
}

ToggleButtonsThemeData? _toggleButtonsThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ToggleButtonsThemeData) {
    return value;
  }
  if (value is! Map) {
    return ToggleButtonsThemeData(color: _color(value));
  }
  final map = _stringMap(value);
  return ToggleButtonsThemeData(
    textStyle: _textStyle(map['textStyle'] ?? map['style']),
    constraints: _boxConstraints(map['constraints']),
    color: _color(map['color'] ?? map['foregroundColor']),
    selectedColor: _color(map['selectedColor']),
    disabledColor: _color(map['disabledColor']),
    fillColor: _color(map['fillColor'] ?? map['backgroundColor']),
    focusColor: _color(map['focusColor']),
    highlightColor: _color(map['highlightColor']),
    hoverColor: _color(map['hoverColor']),
    splashColor: _color(map['splashColor']),
    borderColor: _color(map['borderColor']),
    selectedBorderColor: _color(map['selectedBorderColor']),
    disabledBorderColor: _color(map['disabledBorderColor']),
    borderRadius: _borderRadius(map['borderRadius'] ?? map['radius']),
    borderWidth: _nonNegativeDouble(map['borderWidth'] ?? map['width']),
  );
}

TooltipThemeData? _tooltipThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TooltipThemeData) {
    return value;
  }
  if (value is! Map) {
    return TooltipThemeData(decoration: _boxDecoration({'color': value}));
  }
  final map = _stringMap(value);
  return TooltipThemeData(
    constraints:
        _boxConstraints(map['constraints']) ??
        _tooltipHeightConstraints(map['height'] ?? map['minHeight']),
    padding: _nonNegativeEdgeInsets(map['padding']),
    margin: _nonNegativeEdgeInsets(map['margin']),
    verticalOffset: _nonNegativeDouble(map['verticalOffset']),
    preferBelow: _bool(map['preferBelow']),
    excludeFromSemantics: _bool(map['excludeFromSemantics']),
    decoration: _boxDecoration(map['decoration'] ?? map),
    textStyle: _textStyle(map['textStyle'] ?? map['style']),
    textAlign: _textAlign(map['textAlign']),
    waitDuration: _duration(map['waitDuration']),
    showDuration: _duration(map['showDuration']),
    exitDuration: _duration(map['exitDuration']),
    triggerMode: _tooltipTriggerMode(map['triggerMode']),
    enableFeedback: _bool(map['enableFeedback']),
  );
}

BoxConstraints? _tooltipHeightConstraints(Object? value) {
  final height = _nonNegativeDouble(value);
  if (height == null) {
    return null;
  }
  return BoxConstraints(minHeight: height);
}

MediaQueryData _mediaQueryData(BuildContext context, Object? value) {
  final base = MediaQuery.maybeOf(context) ?? const MediaQueryData();
  if (value is! Map) {
    return base;
  }
  final map = _stringMap(value);
  var data = base.copyWith(
    size: _nonNegativeSize(map['size']) ?? base.size,
    devicePixelRatio:
        _positiveDouble(map['devicePixelRatio'] ?? map['dpr']) ??
        base.devicePixelRatio,
    textScaler:
        _textScaler(map['textScaler'] ?? map['textScaleFactor']) ??
        base.textScaler,
    platformBrightness:
        _brightness(map['platformBrightness'] ?? map['brightness']) ??
        base.platformBrightness,
    padding: _edgeInsets(map['padding']) as EdgeInsets? ?? base.padding,
    viewInsets:
        _edgeInsets(map['viewInsets']) as EdgeInsets? ?? base.viewInsets,
    viewPadding:
        _edgeInsets(map['viewPadding']) as EdgeInsets? ?? base.viewPadding,
    systemGestureInsets:
        _edgeInsets(map['systemGestureInsets']) as EdgeInsets? ??
        base.systemGestureInsets,
    alwaysUse24HourFormat:
        _bool(map['alwaysUse24HourFormat'] ?? map['use24HourFormat']) ??
        base.alwaysUse24HourFormat,
    accessibleNavigation:
        _bool(map['accessibleNavigation']) ?? base.accessibleNavigation,
    invertColors: _bool(map['invertColors']) ?? base.invertColors,
    highContrast: _bool(map['highContrast']) ?? base.highContrast,
    onOffSwitchLabels:
        _bool(map['onOffSwitchLabels']) ?? base.onOffSwitchLabels,
    disableAnimations:
        _bool(map['disableAnimations'] ?? map['disableAnimation']) ??
        base.disableAnimations,
    boldText: _bool(map['boldText']) ?? base.boldText,
    supportsAnnounce: _bool(map['supportsAnnounce']) ?? base.supportsAnnounce,
    navigationMode:
        _navigationMode(map['navigationMode']) ?? base.navigationMode,
    gestureSettings:
        _deviceGestureSettings(map['gestureSettings']) ?? base.gestureSettings,
    displayFeatures:
        _displayFeatures(map['displayFeatures']) ?? base.displayFeatures,
    supportsShowingSystemContextMenu:
        _bool(map['supportsShowingSystemContextMenu']) ??
        base.supportsShowingSystemContextMenu,
  );
  if (map.containsKey('lineHeightScaleFactorOverride') ||
      map.containsKey('lineHeightScaleFactor') ||
      map.containsKey('letterSpacingOverride') ||
      map.containsKey('wordSpacingOverride') ||
      map.containsKey('paragraphSpacingOverride')) {
    data = data.applyTextStyleOverrides(
      lineHeightScaleFactorOverride: _nonNegativeDouble(
        map['lineHeightScaleFactorOverride'] ?? map['lineHeightScaleFactor'],
      ),
      letterSpacingOverride: _double(map['letterSpacingOverride']),
      wordSpacingOverride: _double(map['wordSpacingOverride']),
      paragraphSpacingOverride: _nonNegativeDouble(
        map['paragraphSpacingOverride'],
      ),
    );
  }
  if (map.containsKey('displayCornerRadii') ||
      map.containsKey('displayCornerRadius')) {
    data = data.applyDisplayCornerRadii(
      _borderRadius(map['displayCornerRadii'] ?? map['displayCornerRadius']),
    );
  }
  return data;
}

NavigationMode? _navigationMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'traditional':
      return NavigationMode.traditional;
    case 'directional':
      return NavigationMode.directional;
  }
  return null;
}

DeviceGestureSettings? _deviceGestureSettings(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DeviceGestureSettings) {
    return value;
  }
  final touchSlop = value is Map
      ? _nonNegativeDouble(_stringMap(value)['touchSlop'])
      : _nonNegativeDouble(value);
  return touchSlop == null ? null : DeviceGestureSettings(touchSlop: touchSlop);
}

List<ui.DisplayFeature>? _displayFeatures(Object? value) {
  if (value == null) {
    return null;
  }
  final values = value is List ? value : <Object?>[value];
  final features = values
      .map(_displayFeature)
      .whereType<ui.DisplayFeature>()
      .toList(growable: false);
  return features.isEmpty ? null : features;
}

ui.DisplayFeature? _displayFeature(Object? value) {
  if (value is ui.DisplayFeature) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final bounds = _rect(map['bounds'] ?? map['rect']);
  final type = _displayFeatureType(map['type']);
  if (bounds == null || type == null) {
    return null;
  }
  return ui.DisplayFeature(
    bounds: bounds,
    type: type,
    state: type == ui.DisplayFeatureType.cutout
        ? ui.DisplayFeatureState.unknown
        : _displayFeatureState(map['state']) ?? ui.DisplayFeatureState.unknown,
  );
}

ui.DisplayFeatureType? _displayFeatureType(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'unknown':
      return ui.DisplayFeatureType.unknown;
    case 'fold':
      return ui.DisplayFeatureType.fold;
    case 'hinge':
      return ui.DisplayFeatureType.hinge;
    case 'cutout':
      return ui.DisplayFeatureType.cutout;
  }
  return null;
}

ui.DisplayFeatureState? _displayFeatureState(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'unknown':
      return ui.DisplayFeatureState.unknown;
    case 'postureflat':
    case 'posture_flat':
    case 'posture-flat':
    case 'flat':
      return ui.DisplayFeatureState.postureFlat;
    case 'posturehalfopened':
    case 'posture_half_opened':
    case 'posture-half-opened':
    case 'halfopened':
    case 'half_opened':
    case 'half-opened':
      return ui.DisplayFeatureState.postureHalfOpened;
  }
  return null;
}

IconThemeData _iconThemeData(Object? value) {
  if (value is IconThemeData) {
    return value;
  }
  if (value is! Map) {
    return const IconThemeData();
  }
  final map = _stringMap(value);
  return IconThemeData(
    color: _color(map['color']),
    size: _nonNegativeDouble(map['size']),
    opacity: _unitDouble(map['opacity']),
    fill: _unitDouble(map['fill']),
    weight: _positiveDouble(map['weight']),
    grade: _double(map['grade']),
    opticalSize: _positiveDouble(map['opticalSize']),
    shadows: _textShadows(map['shadows'] ?? map['shadow']),
    applyTextScaling: _bool(map['applyTextScaling']),
  );
}

IconThemeData? _nullableIconThemeData(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is IconThemeData) {
    return value;
  }
  if (value is! Map) {
    final color = _color(value);
    return color == null ? null : IconThemeData(color: color);
  }
  return _iconThemeData(value);
}

ColorScheme? _colorScheme(Object? value, {Brightness? fallbackBrightness}) {
  if (value == null) {
    return null;
  }
  if (value is ColorScheme) {
    return value;
  }
  if (value is! Map) {
    final seed = _color(value);
    return seed == null
        ? null
        : ColorScheme.fromSeed(
            seedColor: seed,
            brightness: fallbackBrightness ?? Brightness.light,
          );
  }
  final map = _stringMap(value);
  final brightness =
      _brightness(map['brightness']) ?? fallbackBrightness ?? Brightness.light;
  final seed = _color(map['seedColor'] ?? map['seed'] ?? map['primary']);
  if (_bool(map['fromSeed']) == true || seed != null) {
    return ColorScheme.fromSeed(
      seedColor: seed ?? Colors.blue,
      brightness: brightness,
    );
  }
  if (brightness == Brightness.dark) {
    const base = ColorScheme.dark();
    return base.copyWith(
      primary: _color(map['primary']) ?? base.primary,
      secondary: _color(map['secondary']) ?? base.secondary,
      surface: _color(map['surface']) ?? base.surface,
      error: _color(map['error']) ?? base.error,
    );
  }
  const base = ColorScheme.light();
  return base.copyWith(
    primary: _color(map['primary']) ?? base.primary,
    secondary: _color(map['secondary']) ?? base.secondary,
    surface: _color(map['surface']) ?? base.surface,
    error: _color(map['error']) ?? base.error,
  );
}

ThemeMode? _themeMode(Object? value) {
  switch (value.toString().toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
  }
  return null;
}

Brightness? _brightness(Object? value) {
  switch (value.toString().toLowerCase()) {
    case 'dark':
      return Brightness.dark;
    case 'light':
      return Brightness.light;
  }
  return null;
}

TextStyle? _textStyle(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is TextStyle) {
    return value;
  }
  if (value is String) {
    return _themeTextStyle(context, value);
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final baseStyle = _themeTextStyle(
    context,
    map['theme'] ??
        map['themeStyle'] ??
        map['textTheme'] ??
        map['token'] ??
        map['styleName'] ??
        map['name'],
  );
  final foreground = _paint(map['foreground']);
  final background = _paint(map['background']);
  final style = TextStyle(
    inherit: _bool(map['inherit']) ?? true,
    color: foreground == null ? _color(map['color'], context) : null,
    backgroundColor: background == null
        ? _color(map['backgroundColor'], context)
        : null,
    fontSize: _double(map['fontSize'] ?? map['size']),
    fontWeight: _fontWeight(map['fontWeight'] ?? map['weight']),
    fontStyle: _fontStyle(map['fontStyle'] ?? map['style']),
    fontFamily: _string(map['fontFamily'] ?? map['family']),
    fontFamilyFallback: _stringList(
      map['fontFamilyFallback'] ?? map['fallback'],
    ),
    package: _string(map['package']),
    height: _double(map['height']),
    letterSpacing: _double(map['letterSpacing']),
    wordSpacing: _double(map['wordSpacing']),
    textBaseline: _textBaseline(map['textBaseline'] ?? map['baseline']),
    leadingDistribution: _textLeadingDistribution(map['leadingDistribution']),
    locale: _locale(map['locale']),
    foreground: foreground,
    background: background,
    shadows: _textShadows(map['shadows'] ?? map['shadow']),
    fontFeatures: _fontFeatures(map['fontFeatures'] ?? map['features']),
    fontVariations: _fontVariations(map['fontVariations'] ?? map['variations']),
    decoration: _textDecoration(map['decoration']),
    decorationColor: _color(map['decorationColor'], context),
    decorationStyle: _textDecorationStyle(map['decorationStyle']),
    decorationThickness: _double(map['decorationThickness']),
    debugLabel: _string(map['debugLabel']),
    overflow: _textOverflow(map['overflow']),
  );
  return baseStyle == null ? style : baseStyle.merge(style);
}

TextStyle? _themeTextStyle(BuildContext? context, Object? value) {
  if (context == null) {
    return null;
  }
  final textTheme = Theme.of(
    context,
  ).textTheme.apply(displayColor: Theme.of(context).colorScheme.onSurface);
  return switch (_normalizedToken(value)) {
    'displaylarge' => textTheme.displayLarge,
    'displaymedium' => textTheme.displayMedium,
    'displaysmall' => textTheme.displaySmall,
    'headlinelarge' => textTheme.headlineLarge,
    'headlinemedium' => textTheme.headlineMedium,
    'headlinesmall' => textTheme.headlineSmall,
    'titlelarge' => textTheme.titleLarge,
    'titlemedium' => textTheme.titleMedium,
    'titlesmall' => textTheme.titleSmall,
    'labellarge' => textTheme.labelLarge,
    'labelmedium' => textTheme.labelMedium,
    'labelsmall' => textTheme.labelSmall,
    'bodylarge' => textTheme.bodyLarge,
    'bodymedium' => textTheme.bodyMedium,
    'bodysmall' => textTheme.bodySmall,
    _ => null,
  };
}

StrutStyle? _strutStyle(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is StrutStyle) {
    return value;
  }
  switch (value.toString().toLowerCase()) {
    case 'disabled':
    case 'none':
      return StrutStyle.disabled;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  return StrutStyle(
    fontFamily: _string(map['fontFamily'] ?? map['family']),
    fontFamilyFallback: _stringList(
      map['fontFamilyFallback'] ?? map['fallback'],
    ),
    fontSize: _positiveDouble(map['fontSize'] ?? map['size']),
    height: _nonNegativeDouble(map['height']),
    leadingDistribution: _textLeadingDistribution(map['leadingDistribution']),
    leading: _nonNegativeDouble(map['leading']),
    fontWeight: _fontWeight(map['fontWeight'] ?? map['weight']),
    fontStyle: _fontStyle(map['fontStyle'] ?? map['style']),
    forceStrutHeight: _bool(map['forceStrutHeight']),
    debugLabel: _string(map['debugLabel']),
    package: _string(map['package']),
  );
}

TextScaler? _textScaler(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TextScaler) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    switch (_string(map['type'] ?? map['mode'])?.toLowerCase()) {
      case 'none':
      case 'noscaling':
      case 'no_scaling':
      case 'no-scaling':
        return TextScaler.noScaling;
    }
    final scale = _nonNegativeDouble(
      map['scale'] ??
          map['factor'] ??
          map['linear'] ??
          map['value'] ??
          map['textScaleFactor'],
    );
    return scale == null ? null : TextScaler.linear(scale);
  }
  switch (value.toString().toLowerCase()) {
    case 'none':
    case 'noscaling':
    case 'no_scaling':
    case 'no-scaling':
      return TextScaler.noScaling;
  }
  final scale = _nonNegativeDouble(value);
  return scale == null ? null : TextScaler.linear(scale);
}

TextStyle? _dataTableTextStyle(Object? value) {
  final style = _textStyle(value);
  if (style == null || style.color != null) {
    return style;
  }
  return style.copyWith(color: Colors.black87);
}

FontWeight? _fontWeight(Object? value) {
  final text = value?.toString().toLowerCase();
  switch (text) {
    case 'thin':
    case 'w100':
    case '100':
      return FontWeight.w100;
    case 'extralight':
    case 'extra_light':
    case 'ultralight':
    case 'ultra_light':
    case 'w200':
    case '200':
      return FontWeight.w200;
    case 'bold':
    case 'w700':
    case '700':
      return FontWeight.w700;
    case 'extrabold':
    case 'extra_bold':
    case 'w800':
    case '800':
      return FontWeight.w800;
    case 'black':
    case 'heavy':
    case 'w900':
    case '900':
      return FontWeight.w900;
    case 'semibold':
    case 'semi_bold':
    case 'w600':
    case '600':
      return FontWeight.w600;
    case 'medium':
    case 'w500':
    case '500':
      return FontWeight.w500;
    case 'normal':
    case 'regular':
    case 'w400':
    case '400':
      return FontWeight.w400;
    case 'light':
    case 'w300':
    case '300':
      return FontWeight.w300;
  }
  return null;
}

List<String>? _stringList(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    final strings = value.map(_string).whereType<String>().toList();
    return strings.isEmpty ? null : strings;
  }
  final text = _string(value);
  return text == null || text.isEmpty ? null : <String>[text];
}

List<_AutocompleteOption> _autocompleteOptions(Object? value) {
  final options = <_AutocompleteOption>[];
  void add(Object? item) {
    final option = _autocompleteOption(item);
    if (option != null) {
      options.add(option);
    }
  }

  if (value is List) {
    for (final item in value) {
      add(item);
    }
  } else if (value is Map) {
    for (final entry in value.entries) {
      add(<String, Object?>{
        'label': entry.key.toString(),
        'value': entry.value,
      });
    }
  } else {
    add(value);
  }
  return options;
}

_AutocompleteOption? _autocompleteOption(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    final map = _stringMap(value);
    final label =
        _string(
          map['label'] ??
              map['text'] ??
              map['title'] ??
              map['name'] ??
              map['value'],
        ) ??
        '';
    if (label.isEmpty) {
      return null;
    }
    final searchParts = <String>[
      label,
      ...?_stringList(map['search'] ?? map['keywords'] ?? map['tags']),
    ];
    return _AutocompleteOption(
      label: label,
      value: map.containsKey('value') ? map['value'] : label,
      searchText: searchParts.join(' '),
    );
  }
  final label = _string(value);
  if (label == null || label.isEmpty) {
    return null;
  }
  return _AutocompleteOption(label: label, value: value, searchText: label);
}

Iterable<_AutocompleteOption> _filteredAutocompleteOptions(
  List<_AutocompleteOption> options,
  String query,
  Map<String, Object?> props,
) {
  final limit =
      (_positiveInt(
                props['optionsLimit'] ?? props['maxOptions'] ?? props['limit'],
              ) ??
              100)
          .clamp(1, 1000)
          .toInt();
  final showAllOnEmpty = _bool(props['showAllOnEmpty']) ?? true;
  final caseSensitive = _bool(props['caseSensitive']) ?? false;
  final mode = _normalizedToken(
    props['filter'] ?? props['filterMode'] ?? props['match'],
  );
  final needle = caseSensitive ? query.trim() : query.trim().toLowerCase();
  if (needle.isEmpty && !showAllOnEmpty) {
    return const <_AutocompleteOption>[];
  }

  bool matches(_AutocompleteOption option) {
    if (needle.isEmpty) {
      return true;
    }
    final haystack = caseSensitive
        ? option.searchText
        : option.searchText.toLowerCase();
    switch (mode) {
      case 'none':
      case 'all':
        return true;
      case 'prefix':
      case 'startswith':
      case 'starts':
        return haystack.startsWith(needle);
      case 'exact':
      case 'equals':
      case 'equal':
        return haystack == needle;
      case 'contains':
      default:
        return haystack.contains(needle);
    }
  }

  return options.where(matches).take(limit).toList(growable: false);
}

Object? _autocompleteSelectionPayload(
  _AutocompleteOption option,
  Object? payloadMode,
) {
  switch (_normalizedToken(payloadMode)) {
    case 'label':
    case 'text':
    case 'display':
      return option.label;
    case 'option':
    case 'full':
    case 'map':
    case 'object':
      return <String, Object?>{'label': option.label, 'value': option.value};
  }
  return option.value ?? option.label;
}

FontStyle? _fontStyle(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'italic':
      return FontStyle.italic;
    case 'normal':
      return FontStyle.normal;
  }
  return null;
}

TextDecoration? _textDecoration(Object? value) {
  if (value is TextDecoration) {
    return value;
  }
  if (value is List) {
    final decorations = value
        .map(_textDecoration)
        .whereType<TextDecoration>()
        .where((decoration) => decoration != TextDecoration.none)
        .toList(growable: false);
    return decorations.isEmpty ? null : TextDecoration.combine(decorations);
  }
  switch (value?.toString().toLowerCase()) {
    case 'none':
      return TextDecoration.none;
    case 'underline':
      return TextDecoration.underline;
    case 'linethrough':
    case 'line-through':
    case 'line_through':
      return TextDecoration.lineThrough;
    case 'overline':
      return TextDecoration.overline;
  }
  return null;
}

TextDecorationStyle? _textDecorationStyle(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'solid':
      return TextDecorationStyle.solid;
    case 'double':
      return TextDecorationStyle.double;
    case 'dotted':
      return TextDecorationStyle.dotted;
    case 'dashed':
      return TextDecorationStyle.dashed;
    case 'wavy':
      return TextDecorationStyle.wavy;
  }
  return null;
}

TextLeadingDistribution? _textLeadingDistribution(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'proportional':
      return TextLeadingDistribution.proportional;
    case 'even':
      return TextLeadingDistribution.even;
  }
  return null;
}

ui.Locale? _locale(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ui.Locale) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    final languageCode = _string(map['languageCode'] ?? map['language']);
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }
    return ui.Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: _string(map['scriptCode'] ?? map['script']),
      countryCode: _string(map['countryCode'] ?? map['country']),
    );
  }
  final parts = value
      .toString()
      .replaceAll('_', '-')
      .split('-')
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return null;
  }
  return ui.Locale.fromSubtags(
    languageCode: parts[0],
    scriptCode: parts.length == 3 ? parts[1] : null,
    countryCode: parts.length >= 2 ? parts.last : null,
  );
}

ui.Paint? _paint(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ui.Paint) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    final color = _color(map['color']);
    final strokeWidth = _double(map['strokeWidth']);
    final style = _paintingStyle(map['style']);
    if (color == null && strokeWidth == null && style == null) {
      return null;
    }
    final paint = ui.Paint();
    if (color != null) {
      paint.color = color;
    }
    if (strokeWidth != null) {
      paint.strokeWidth = strokeWidth;
    }
    if (style != null) {
      paint.style = style;
    }
    return paint;
  }
  final color = _color(value);
  return color == null ? null : (ui.Paint()..color = color);
}

ui.PaintingStyle? _paintingStyle(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'fill':
      return ui.PaintingStyle.fill;
    case 'stroke':
      return ui.PaintingStyle.stroke;
  }
  return null;
}

List<ui.Shadow>? _textShadows(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    final shadows = value
        .map(_textShadow)
        .whereType<ui.Shadow>()
        .toList(growable: false);
    return shadows.isEmpty ? null : shadows;
  }
  final shadow = _textShadow(value);
  return shadow == null ? null : <ui.Shadow>[shadow];
}

ui.Shadow? _textShadow(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ui.Shadow) {
    return value;
  }
  if (value is! Map) {
    return ui.Shadow(color: _color(value) ?? Colors.black);
  }
  final map = _stringMap(value);
  return ui.Shadow(
    color: _color(map['color']) ?? Colors.black,
    offset:
        _offset(map['offset']) ??
        Offset(
          _double(map['dx'] ?? map['x']) ?? 0,
          _double(map['dy'] ?? map['y']) ?? 0,
        ),
    blurRadius: math.max(0, _double(map['blurRadius'] ?? map['blur']) ?? 0),
  );
}

List<ui.FontFeature>? _fontFeatures(Object? value) {
  if (value == null) {
    return null;
  }
  final values = value is List ? value : <Object?>[value];
  final features = values
      .map(_fontFeature)
      .whereType<ui.FontFeature>()
      .toList(growable: false);
  return features.isEmpty ? null : features;
}

ui.FontFeature? _fontFeature(Object? value) {
  Object? tagValue;
  Object? featureValue;
  Object? enabledValue;
  if (value is Map) {
    final map = _stringMap(value);
    tagValue = map['feature'] ?? map['tag'] ?? map['name'];
    featureValue = map['value'];
    enabledValue = map['enabled'];
  } else {
    tagValue = value;
  }
  final tag = _string(tagValue);
  if (tag == null || tag.length != 4) {
    return null;
  }
  final enabled = _bool(enabledValue);
  final feature = enabled == false ? 0 : (_int(featureValue) ?? 1);
  if (feature < 0) {
    return null;
  }
  return ui.FontFeature(tag, feature);
}

List<ui.FontVariation>? _fontVariations(Object? value) {
  if (value == null) {
    return null;
  }
  final values = value is List ? value : <Object?>[value];
  final variations = values
      .map(_fontVariation)
      .whereType<ui.FontVariation>()
      .toList(growable: false);
  return variations.isEmpty ? null : variations;
}

ui.FontVariation? _fontVariation(Object? value) {
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final axis = _string(map['axis'] ?? map['tag'] ?? map['name']);
  final variation = _double(map['value']);
  if (axis == null ||
      axis.length != 4 ||
      variation == null ||
      variation < -32768 ||
      variation >= 32768) {
    return null;
  }
  return ui.FontVariation(axis, variation);
}

TextAlign? _textAlign(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    case 'center':
      return TextAlign.center;
    case 'justify':
      return TextAlign.justify;
    case 'start':
      return TextAlign.start;
    case 'end':
      return TextAlign.end;
  }
  return null;
}

TextDirection? _textDirection(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'ltr':
    case 'lefttoright':
    case 'left_to_right':
      return TextDirection.ltr;
    case 'rtl':
    case 'righttoleft':
    case 'right_to_left':
      return TextDirection.rtl;
  }
  return null;
}

TextOverflow? _textOverflow(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'clip':
      return TextOverflow.clip;
    case 'fade':
      return TextOverflow.fade;
    case 'ellipsis':
      return TextOverflow.ellipsis;
    case 'visible':
      return TextOverflow.visible;
  }
  return null;
}

TextWidthBasis? _textWidthBasis(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'parent':
      return TextWidthBasis.parent;
    case 'longestline':
    case 'longest_line':
    case 'longest-line':
      return TextWidthBasis.longestLine;
  }
  return null;
}

ui.TextHeightBehavior? _textHeightBehavior(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ui.TextHeightBehavior) {
    return value;
  }
  switch (value.toString().toLowerCase()) {
    case 'none':
    case 'disabled':
    case 'trim':
      return const ui.TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      );
    case 'normal':
    case 'default':
      return const ui.TextHeightBehavior();
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final first = _bool(
    map['applyHeightToFirstAscent'] ?? map['firstAscent'] ?? map['first'],
  );
  final last = _bool(
    map['applyHeightToLastDescent'] ?? map['lastDescent'] ?? map['last'],
  );
  final leadingDistribution = _textLeadingDistribution(
    map['leadingDistribution'],
  );
  if (first == null && last == null && leadingDistribution == null) {
    return null;
  }
  return ui.TextHeightBehavior(
    applyHeightToFirstAscent: first ?? true,
    applyHeightToLastDescent: last ?? true,
    leadingDistribution:
        leadingDistribution ?? TextLeadingDistribution.proportional,
  );
}

FloatingLabelBehavior? _floatingLabelBehavior(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'never':
      return FloatingLabelBehavior.never;
    case 'auto':
      return FloatingLabelBehavior.auto;
    case 'always':
      return FloatingLabelBehavior.always;
  }
  return null;
}

FloatingLabelAlignment? _floatingLabelAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return FloatingLabelAlignment.start;
    case 'center':
      return FloatingLabelAlignment.center;
  }
  return null;
}

VisualDensity? _visualDensity(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is VisualDensity) {
    return value;
  }
  switch (value.toString().toLowerCase()) {
    case 'standard':
      return VisualDensity.standard;
    case 'comfortable':
      return VisualDensity.comfortable;
    case 'compact':
      return VisualDensity.compact;
    case 'adaptive':
    case 'adaptiveplatform':
    case 'adaptive_platform':
      return VisualDensity.adaptivePlatformDensity;
  }
  if (value is num) {
    final density = value.toDouble().clamp(
      VisualDensity.minimumDensity,
      VisualDensity.maximumDensity,
    );
    return VisualDensity(horizontal: density, vertical: density);
  }
  if (value is List && value.length >= 2) {
    return VisualDensity(
      horizontal: (_double(value[0]) ?? 0).clamp(
        VisualDensity.minimumDensity,
        VisualDensity.maximumDensity,
      ),
      vertical: (_double(value[1]) ?? 0).clamp(
        VisualDensity.minimumDensity,
        VisualDensity.maximumDensity,
      ),
    );
  }
  if (value is Map) {
    final map = _stringMap(value);
    return VisualDensity(
      horizontal: (_double(map['horizontal'] ?? map['x']) ?? 0).clamp(
        VisualDensity.minimumDensity,
        VisualDensity.maximumDensity,
      ),
      vertical: (_double(map['vertical'] ?? map['y']) ?? 0).clamp(
        VisualDensity.minimumDensity,
        VisualDensity.maximumDensity,
      ),
    );
  }
  return null;
}

TargetPlatform? _targetPlatform(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'android':
      return TargetPlatform.android;
    case 'fuchsia':
      return TargetPlatform.fuchsia;
    case 'ios':
      return TargetPlatform.iOS;
    case 'linux':
      return TargetPlatform.linux;
    case 'macos':
    case 'macosx':
    case 'mac_os':
    case 'mac-os':
      return TargetPlatform.macOS;
    case 'windows':
      return TargetPlatform.windows;
  }
  return null;
}

AutovalidateMode? _autovalidateMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'disabled':
      return AutovalidateMode.disabled;
    case 'always':
      return AutovalidateMode.always;
    case 'onuserinteraction':
    case 'on_user_interaction':
      return AutovalidateMode.onUserInteraction;
    case 'onunfocus':
    case 'on_unfocus':
      return AutovalidateMode.onUnfocus;
  }
  return null;
}

AutofillContextAction? _autofillContextAction(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'commit':
    case 'save':
      return AutofillContextAction.commit;
    case 'cancel':
    case 'discard':
      return AutofillContextAction.cancel;
  }
  return null;
}

FocusTraversalPolicy? _focusTraversalPolicy(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'readingorder':
    case 'reading_order':
    case 'reading-order':
    case 'reading':
      return ReadingOrderTraversalPolicy();
    case 'widgetorder':
    case 'widget_order':
    case 'widget-order':
    case 'widget':
      return WidgetOrderTraversalPolicy();
    case 'ordered':
    case 'numeric':
      return OrderedTraversalPolicy();
  }
  return null;
}

DatePickerEntryMode? _datePickerEntryMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'calendar':
      return DatePickerEntryMode.calendar;
    case 'input':
      return DatePickerEntryMode.input;
    case 'calendaronly':
    case 'calendar_only':
      return DatePickerEntryMode.calendarOnly;
    case 'inputonly':
    case 'input_only':
      return DatePickerEntryMode.inputOnly;
  }
  return null;
}

TimePickerEntryMode? _timePickerEntryMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'dial':
      return TimePickerEntryMode.dial;
    case 'input':
      return TimePickerEntryMode.input;
    case 'dialonly':
    case 'dial_only':
      return TimePickerEntryMode.dialOnly;
    case 'inputonly':
    case 'input_only':
      return TimePickerEntryMode.inputOnly;
  }
  return null;
}

RefreshIndicatorTriggerMode? _refreshIndicatorTriggerMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'anywhere':
    case 'any':
      return RefreshIndicatorTriggerMode.anywhere;
    case 'onedge':
    case 'on_edge':
    case 'edge':
      return RefreshIndicatorTriggerMode.onEdge;
  }
  return null;
}

ScrollNotificationPredicate _scrollNotificationPredicate(Object? value) {
  if (value == null || value.toString().toLowerCase() == 'default') {
    return defaultScrollNotificationPredicate;
  }
  final text = value.toString().toLowerCase();
  if (text == 'any' || text == 'all') {
    return (_) => true;
  }
  final depth = _int(value);
  if (depth != null) {
    return (notification) => notification.depth == depth;
  }
  return defaultScrollNotificationPredicate;
}

DropdownMenuCloseBehavior? _dropdownMenuCloseBehavior(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'all':
      return DropdownMenuCloseBehavior.all;
    case 'self':
      return DropdownMenuCloseBehavior.self;
    case 'none':
      return DropdownMenuCloseBehavior.none;
  }
  return null;
}

BottomNavigationBarLandscapeLayout? _bottomNavigationBarLandscapeLayout(
  Object? value,
) {
  switch (value?.toString().toLowerCase()) {
    case 'spread':
      return BottomNavigationBarLandscapeLayout.spread;
    case 'centered':
    case 'center':
      return BottomNavigationBarLandscapeLayout.centered;
    case 'linear':
      return BottomNavigationBarLandscapeLayout.linear;
  }
  return null;
}

TooltipTriggerMode? _tooltipTriggerMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'manual':
      return TooltipTriggerMode.manual;
    case 'tap':
      return TooltipTriggerMode.tap;
    case 'longpress':
    case 'long_press':
    case 'long-press':
      return TooltipTriggerMode.longPress;
  }
  return null;
}

PopupMenuPosition? _popupMenuPosition(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'over':
      return PopupMenuPosition.over;
    case 'under':
    case 'below':
      return PopupMenuPosition.under;
  }
  return null;
}

double? _dropdownItemHeight(Object? value) {
  if (value == null) {
    return null;
  }
  final height = _double(value);
  if (height == null) {
    return null;
  }
  return math.max(kMinInteractiveDimension, height);
}

BoxConstraints? _boxConstraints(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is BoxConstraints) {
    return value;
  }
  if (value is num) {
    final extent = math.max<double>(0, value.toDouble());
    return BoxConstraints.tightFor(width: extent, height: extent);
  }
  if (value is Map) {
    final map = _stringMap(value);
    final width = _nonNegativeDouble(map['width']);
    final height = _nonNegativeDouble(map['height']);
    if (width != null || height != null) {
      return BoxConstraints.tightFor(width: width, height: height);
    }
    final minWidth = _nonNegativeDouble(map['minWidth']) ?? 0;
    final minHeight = _nonNegativeDouble(map['minHeight']) ?? 0;
    final maxWidth = _nonNegativeDouble(map['maxWidth']) ?? double.infinity;
    final maxHeight = _nonNegativeDouble(map['maxHeight']) ?? double.infinity;
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: math.max(minWidth, maxWidth),
      minHeight: minHeight,
      maxHeight: math.max(minHeight, maxHeight),
    );
  }
  return null;
}

DecorationPosition? _decorationPosition(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'foreground':
      return DecorationPosition.foreground;
    case 'background':
      return DecorationPosition.background;
  }
  return null;
}

TextBaseline? _textBaseline(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'ideographic':
      return TextBaseline.ideographic;
    case 'alphabetic':
      return TextBaseline.alphabetic;
  }
  return null;
}

InputBorder? _inputBorder(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is InputBorder) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    final type = map['type'] ?? map['shape'] ?? map['border'];
    switch (type?.toString().toLowerCase()) {
      case 'none':
        return InputBorder.none;
      case 'outline':
      case 'outlined':
        return OutlineInputBorder(
          borderSide:
              _borderSide(map['borderSide'] ?? map['side'] ?? map) ??
              const BorderSide(),
          borderRadius:
              _borderRadius(map['borderRadius'] ?? map['radius']) ??
              const BorderRadius.all(Radius.circular(4)),
          gapPadding: math.max(0, _double(map['gapPadding']) ?? 4),
        );
      case 'underline':
      default:
        return UnderlineInputBorder(
          borderSide:
              _borderSide(map['borderSide'] ?? map['side'] ?? map) ??
              const BorderSide(),
          borderRadius:
              _borderRadius(map['borderRadius'] ?? map['radius']) ??
              const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
        );
    }
  }
  switch (value.toString().toLowerCase()) {
    case 'none':
      return InputBorder.none;
    case 'outline':
    case 'outlined':
      return const OutlineInputBorder();
    case 'underline':
      return const UnderlineInputBorder();
  }
  return null;
}

TextInputType? _keyboardType(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'text':
      return TextInputType.text;
    case 'number':
      return TextInputType.number;
    case 'phone':
      return TextInputType.phone;
    case 'email':
    case 'emailaddress':
    case 'email_address':
      return TextInputType.emailAddress;
    case 'url':
      return TextInputType.url;
    case 'multiline':
      return TextInputType.multiline;
    case 'datetime':
    case 'date_time':
      return TextInputType.datetime;
    case 'visiblepassword':
    case 'visible_password':
      return TextInputType.visiblePassword;
  }
  return null;
}

TextInputAction? _textInputAction(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'done':
      return TextInputAction.done;
    case 'go':
      return TextInputAction.go;
    case 'next':
      return TextInputAction.next;
    case 'search':
      return TextInputAction.search;
    case 'send':
      return TextInputAction.send;
    case 'newline':
    case 'new_line':
      return TextInputAction.newline;
  }
  return null;
}

TextCapitalization? _textCapitalization(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'none':
      return TextCapitalization.none;
    case 'characters':
      return TextCapitalization.characters;
    case 'words':
      return TextCapitalization.words;
    case 'sentences':
      return TextCapitalization.sentences;
  }
  return null;
}

Color? _color(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is Color) {
    return value;
  }
  if (value is int) {
    return Color(value);
  }
  if (value is num) {
    return Color(value.toInt());
  }
  if (value is Map) {
    final map = _stringMap(value);
    final color =
        _themeColor(
          context,
          map['theme'] ?? map['colorScheme'] ?? map['role'] ?? map['token'],
        ) ??
        _color(map['value'] ?? map['hex'] ?? map['color'], context);
    final opacity = _colorOpacity(map['opacity'] ?? map['alpha']);
    if (color != null && opacity != null) {
      return color.withAlpha((opacity * 255).round());
    }
    return color;
  }
  var text = value.toString().trim();
  final named = _namedColors[text.toLowerCase()];
  if (named != null) {
    return named;
  }
  if (text.startsWith('#')) {
    text = text.substring(1);
  }
  if (text.startsWith('0x')) {
    text = text.substring(2);
  }
  if (text.length == 6) {
    text = 'ff$text';
  }
  if (text.length == 8) {
    final parsed = int.tryParse(text, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
  return _themeColor(context, value);
}

double? _colorOpacity(Object? value) {
  final opacity = _double(value);
  if (opacity == null) {
    return null;
  }
  if (opacity > 1) {
    return (opacity / 255).clamp(0, 1).toDouble();
  }
  return opacity.clamp(0, 1).toDouble();
}

Color? _themeColor(BuildContext? context, Object? value) {
  if (context == null) {
    return null;
  }
  final token = _normalizedToken(value);
  if (token.isEmpty) {
    return null;
  }
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  return switch (token) {
    'primary' => scheme.primary,
    'onprimary' => scheme.onPrimary,
    'primarycontainer' => scheme.primaryContainer,
    'onprimarycontainer' => scheme.onPrimaryContainer,
    'primaryfixed' => scheme.primaryFixed,
    'primaryfixeddim' => scheme.primaryFixedDim,
    'onprimaryfixed' => scheme.onPrimaryFixed,
    'onprimaryfixedvariant' => scheme.onPrimaryFixedVariant,
    'secondary' => scheme.secondary,
    'onsecondary' => scheme.onSecondary,
    'secondarycontainer' => scheme.secondaryContainer,
    'onsecondarycontainer' => scheme.onSecondaryContainer,
    'secondaryfixed' => scheme.secondaryFixed,
    'secondaryfixeddim' => scheme.secondaryFixedDim,
    'onsecondaryfixed' => scheme.onSecondaryFixed,
    'onsecondaryfixedvariant' => scheme.onSecondaryFixedVariant,
    'tertiary' => scheme.tertiary,
    'ontertiary' => scheme.onTertiary,
    'tertiarycontainer' => scheme.tertiaryContainer,
    'ontertiarycontainer' => scheme.onTertiaryContainer,
    'tertiaryfixed' => scheme.tertiaryFixed,
    'tertiaryfixeddim' => scheme.tertiaryFixedDim,
    'ontertiaryfixed' => scheme.onTertiaryFixed,
    'ontertiaryfixedvariant' => scheme.onTertiaryFixedVariant,
    'error' => scheme.error,
    'onerror' => scheme.onError,
    'errorcontainer' => scheme.errorContainer,
    'onerrorcontainer' => scheme.onErrorContainer,
    'surface' => scheme.surface,
    'onsurface' => scheme.onSurface,
    'surfacevariant' => scheme.surfaceContainerHighest,
    'onsurfacevariant' => scheme.onSurfaceVariant,
    'surfacedim' => scheme.surfaceDim,
    'surfacebright' => scheme.surfaceBright,
    'surfacecontainerlowest' => scheme.surfaceContainerLowest,
    'surfacecontainerlow' => scheme.surfaceContainerLow,
    'surfacecontainer' => scheme.surfaceContainer,
    'surfacecontainerhigh' => scheme.surfaceContainerHigh,
    'surfacecontainerhighest' => scheme.surfaceContainerHighest,
    'inverseprimary' => scheme.inversePrimary,
    'inversesurface' => scheme.inverseSurface,
    'oninversesurface' => scheme.onInverseSurface,
    'outline' => scheme.outline,
    'outlinevariant' => scheme.outlineVariant,
    'shadow' => scheme.shadow,
    'scrim' => scheme.scrim,
    'scaffoldbackground' ||
    'scaffoldbackgroundcolor' => theme.scaffoldBackgroundColor,
    'canvas' || 'canvascolor' => theme.canvasColor,
    'card' || 'cardcolor' => theme.cardColor,
    'divider' || 'dividercolor' => theme.dividerColor,
    'disabled' || 'disabledcolor' => theme.disabledColor,
    'focus' || 'focuscolor' => theme.focusColor,
    'hover' || 'hovercolor' => theme.hoverColor,
    'highlight' || 'highlightcolor' => theme.highlightColor,
    'splash' || 'splashcolor' => theme.splashColor,
    'hint' || 'hintcolor' => theme.hintColor,
    _ => null,
  };
}

const Map<String, Color> _namedColors = <String, Color>{
  'black': Colors.black,
  'white': Colors.white,
  'transparent': Colors.transparent,
  'red': Colors.red,
  'pink': Colors.pink,
  'purple': Colors.purple,
  'deeppurple': Colors.deepPurple,
  'indigo': Colors.indigo,
  'blue': Colors.blue,
  'lightblue': Colors.lightBlue,
  'cyan': Colors.cyan,
  'teal': Colors.teal,
  'green': Colors.green,
  'lightgreen': Colors.lightGreen,
  'lime': Colors.lime,
  'yellow': Colors.yellow,
  'amber': Colors.amber,
  'orange': Colors.orange,
  'deeporange': Colors.deepOrange,
  'brown': Colors.brown,
  'grey': Colors.grey,
  'gray': Colors.grey,
  'bluegrey': Colors.blueGrey,
  'bluegray': Colors.blueGrey,
};

EdgeInsetsGeometry? _edgeInsets(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is EdgeInsetsGeometry) {
    return value;
  }
  if (value is num) {
    return EdgeInsets.all(value.toDouble());
  }
  if (value is List) {
    final values = value
        .map(_double)
        .whereType<double>()
        .toList(growable: false);
    if (values.length == 2) {
      return EdgeInsets.symmetric(horizontal: values[0], vertical: values[1]);
    }
    if (values.length >= 4) {
      return EdgeInsets.fromLTRB(values[0], values[1], values[2], values[3]);
    }
  }
  if (value is Map) {
    final map = _stringMap(value);
    final all = _double(map['all']);
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.only(
      left:
          _double(map['left']) ??
          _double(map['start']) ??
          _double(map['horizontal']) ??
          0,
      top: _double(map['top']) ?? _double(map['vertical']) ?? 0,
      right:
          _double(map['right']) ??
          _double(map['end']) ??
          _double(map['horizontal']) ??
          0,
      bottom: _double(map['bottom']) ?? _double(map['vertical']) ?? 0,
    );
  }
  return null;
}

EdgeInsetsGeometry? _nonNegativeEdgeInsets(Object? value) {
  final insets = _edgeInsets(value);
  if (insets == null || insets.isNonNegative) {
    return insets;
  }
  final resolved = insets.resolve(TextDirection.ltr);
  return EdgeInsets.fromLTRB(
    math.max(0, resolved.left),
    math.max(0, resolved.top),
    math.max(0, resolved.right),
    math.max(0, resolved.bottom),
  );
}

EdgeInsets? _nonNegativeEdgeInsetsOnly(Object? value) {
  final insets = _nonNegativeEdgeInsets(value);
  if (insets == null) {
    return null;
  }
  return insets is EdgeInsets ? insets : insets.resolve(TextDirection.ltr);
}

EdgeInsets? _edgeInsetsOnly(Object? value) {
  final edgeInsets = _edgeInsets(value);
  return edgeInsets is EdgeInsets ? edgeInsets : null;
}

EdgeInsets? _finiteEdgeInsets(Object? value) {
  final edgeInsets = _edgeInsetsOnly(value);
  if (edgeInsets == null ||
      !edgeInsets.left.isFinite ||
      !edgeInsets.top.isFinite ||
      !edgeInsets.right.isFinite ||
      !edgeInsets.bottom.isFinite) {
    return null;
  }
  return edgeInsets;
}

EdgeInsetsDirectional? _edgeInsetsDirectional(Object? value) {
  final edgeInsets = _edgeInsets(value);
  if (edgeInsets == null) {
    return null;
  }
  if (edgeInsets is EdgeInsetsDirectional) {
    return edgeInsets;
  }
  final resolved = edgeInsets.resolve(TextDirection.ltr);
  return EdgeInsetsDirectional.fromSTEB(
    resolved.left,
    resolved.top,
    resolved.right,
    resolved.bottom,
  );
}

EdgeInsets? _resolvedEdgeInsets(BuildContext context, Object? value) {
  return _edgeInsets(
    value,
  )?.resolve(Directionality.maybeOf(context) ?? TextDirection.ltr);
}

BorderRadius? _borderRadius(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is BorderRadius) {
    return value;
  }
  if (value is num) {
    return BorderRadius.circular(value.toDouble());
  }
  if (value is Map) {
    final map = _stringMap(value);
    final all = _double(map['all']);
    if (all != null) {
      return BorderRadius.circular(all);
    }
    return BorderRadius.only(
      topLeft: Radius.circular(_double(map['topLeft']) ?? 0),
      topRight: Radius.circular(_double(map['topRight']) ?? 0),
      bottomLeft: Radius.circular(_double(map['bottomLeft']) ?? 0),
      bottomRight: Radius.circular(_double(map['bottomRight']) ?? 0),
    );
  }
  return null;
}

Radius? _nonNegativeRadius(Object? value) {
  final radius = _double(value);
  if (radius != null) {
    return Radius.circular(math.max(0, radius));
  }
  if (value is Radius) {
    return Radius.elliptical(math.max(0, value.x), math.max(0, value.y));
  }
  if (value is Map) {
    final map = _stringMap(value);
    final x = _nonNegativeDouble(
      map['x'] ?? map['horizontal'] ?? map['radius'],
    );
    final y = _nonNegativeDouble(map['y'] ?? map['vertical'] ?? map['radius']);
    return Radius.elliptical(x ?? 0, y ?? 0);
  }
  return null;
}

BoxDecoration? _boxDecoration(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is BoxDecoration) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final color = _color(map['color'], context);
  final gradient = _gradient(map['gradient']);
  final shape = _boxShape(map['shape']) ?? BoxShape.rectangle;
  return BoxDecoration(
    color: color,
    image: _decorationImage(
      map['image'] ?? map['decorationImage'] ?? map['backgroundImage'],
      context,
    ),
    shape: shape,
    borderRadius: shape == BoxShape.circle
        ? null
        : _borderRadius(map['borderRadius'] ?? map['radius']),
    border: _border(map['border'], context),
    boxShadow: _boxShadows(
      map['boxShadow'] ?? map['boxShadows'] ?? map['shadow'] ?? map['shadows'],
      context,
    ),
    gradient: gradient,
    backgroundBlendMode: color != null || gradient != null
        ? _blendMode(map['backgroundBlendMode'] ?? map['blendMode'])
        : null,
  );
}

DecorationImage? _decorationImage(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is DecorationImage) {
    return value;
  }
  final props = value is Map
      ? _props(_stringMap(value))
      : <String, Object?>{'src': value};
  final provider = _imageProvider(props);
  if (provider == null) {
    return null;
  }
  final color = _color(props['color'] ?? props['tintColor'], context);
  final blendMode = _blendMode(props['colorBlendMode'] ?? props['blendMode']);
  return DecorationImage(
    image: provider,
    colorFilter: _colorFilter(
      props['colorFilter'],
      color: color,
      blendMode: blendMode,
      context: context,
    ),
    fit: _boxFit(props['fit']),
    alignment: _alignment(props['alignment']) ?? Alignment.center,
    centerSlice: _rect(props['centerSlice']),
    repeat: _imageRepeat(props['repeat']) ?? ImageRepeat.noRepeat,
    matchTextDirection: _bool(props['matchTextDirection']) ?? false,
    scale: _double(props['scale']) ?? 1,
    opacity: (_double(props['opacity']) ?? 1).clamp(0, 1).toDouble(),
    filterQuality:
        _filterQuality(props['filterQuality']) ?? FilterQuality.medium,
    invertColors: _bool(props['invertColors']) ?? false,
    isAntiAlias: _bool(props['isAntiAlias']) ?? false,
  );
}

ImageProvider? _imageProvider(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ImageProvider) {
    return value;
  }
  final props = value is Map
      ? _props(_stringMap(value))
      : <String, Object?>{'src': value};
  final scale = _double(props['scale']) ?? 1;
  final cacheWidth = _positiveInt(props['cacheWidth'] ?? props['decodeWidth']);
  final cacheHeight = _positiveInt(
    props['cacheHeight'] ?? props['decodeHeight'],
  );
  final source = _string(props['source'])?.toLowerCase();
  final src = _string(props['src'] ?? props['url']);
  final isDataUri = src?.trimLeft().startsWith('data:') ?? false;
  final bytes = _imageBytes(
    props['bytes'] ??
        props['base64'] ??
        props['dataUri'] ??
        (source == 'memory' ? (props['data'] ?? src) : null) ??
        (isDataUri ? src : null),
  );
  if (bytes != null) {
    return ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      MemoryImage(bytes, scale: scale),
    );
  }

  final asset = _string(
    props['asset'] ??
        props['name'] ??
        (source == 'asset' ? src : null) ??
        (source == null && src != null && !_looksLikeNetworkUrl(src)
            ? src
            : null),
  );
  if (asset != null) {
    final assetScale = _double(props['assetScale'] ?? props['scale']);
    final provider = assetScale == null
        ? AssetImage(asset, package: _string(props['package']))
        : ExactAssetImage(
            asset,
            scale: assetScale,
            package: _string(props['package']),
          );
    return ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, provider);
  }

  if (src != null && !isDataUri && source != 'asset' && source != 'memory') {
    return ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      NetworkImage(
        src,
        scale: scale,
        headers: _stringStringMap(props['headers']),
      ),
    );
  }
  return null;
}

bool _looksLikeNetworkUrl(String value) {
  final lower = value.trimLeft().toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

ColorFilter? _colorFilter(
  Object? value, {
  Color? color,
  BlendMode? blendMode,
  BuildContext? context,
}) {
  if (value is ColorFilter) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    final filterColor = _color(map['color'], context) ?? color;
    final filterBlendMode =
        _blendMode(map['blendMode'] ?? map['mode']) ??
        blendMode ??
        BlendMode.srcIn;
    return filterColor == null
        ? null
        : ColorFilter.mode(filterColor, filterBlendMode);
  }
  if (value != null) {
    final filterColor = _color(value, context);
    return filterColor == null
        ? null
        : ColorFilter.mode(filterColor, blendMode ?? BlendMode.srcIn);
  }
  return color == null
      ? null
      : ColorFilter.mode(color, blendMode ?? BlendMode.srcIn);
}

List<BoxShadow>? _boxShadows(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    final shadows = value
        .map((item) => _boxShadow(item, context))
        .whereType<BoxShadow>()
        .toList(growable: false);
    return shadows.isEmpty ? null : shadows;
  }
  final shadow = _boxShadow(value, context);
  return shadow == null ? null : <BoxShadow>[shadow];
}

BoxShadow? _boxShadow(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is BoxShadow) {
    return value;
  }
  if (value is! Map) {
    return BoxShadow(color: _color(value, context) ?? const Color(0x33000000));
  }
  final map = _stringMap(value);
  return BoxShadow(
    color: _color(map['color'], context) ?? const Color(0x33000000),
    offset:
        _offset(map['offset']) ??
        Offset(
          _double(map['dx'] ?? map['x']) ?? 0,
          _double(map['dy'] ?? map['y']) ?? 0,
        ),
    blurRadius: _double(map['blurRadius'] ?? map['blur']) ?? 0,
    spreadRadius: _double(map['spreadRadius'] ?? map['spread']) ?? 0,
    blurStyle: _blurStyle(map['blurStyle']) ?? BlurStyle.normal,
  );
}

BlurStyle? _blurStyle(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'normal':
      return BlurStyle.normal;
    case 'solid':
      return BlurStyle.solid;
    case 'outer':
      return BlurStyle.outer;
    case 'inner':
      return BlurStyle.inner;
  }
  return null;
}

BoxShape? _boxShape(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'circle':
      return BoxShape.circle;
    case 'rectangle':
    case 'rect':
      return BoxShape.rectangle;
  }
  return null;
}

InlineSpan _inlineSpan(Object? value, [BuildContext? context]) {
  if (value is InlineSpan) {
    return value;
  }
  if (value is List) {
    return TextSpan(
      children: value
          .map((item) => _inlineSpan(item, context))
          .toList(growable: false),
    );
  }
  if (value is Map) {
    final props = _props(_stringMap(value));
    final children = props['children'];
    return TextSpan(
      text: _string(props['text'] ?? props['data']),
      style: _textStyle(props['style'], context),
      children: children is List
          ? children
                .map((item) => _inlineSpan(item, context))
                .toList(growable: false)
          : null,
      semanticsLabel: _string(
        props['semanticsLabel'] ?? props['semanticLabel'],
      ),
      semanticsIdentifier: _string(props['semanticsIdentifier']),
      locale: _locale(props['locale']),
      spellOut: _bool(props['spellOut']),
    );
  }
  return TextSpan(text: _string(value) ?? '');
}

BoxBorder? _border(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is BoxBorder) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    return Border.all(
      color: _color(map['color'], context) ?? Colors.black,
      width: _double(map['width']) ?? 1,
    );
  }
  return Border.all(color: _color(value, context) ?? Colors.black);
}

Border? _borderOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value ? _defaultCupertinoNavBarBorder : null;
  }
  final token = _normalizedToken(value);
  if (token == 'none' ||
      token == 'false' ||
      token == 'hidden' ||
      token == 'off') {
    return null;
  }
  final border = _border(value);
  return border is Border ? border : null;
}

ButtonStyle? _buttonStyle(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is ButtonStyle) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final hasStyle =
      map.containsKey('textStyle') ||
      map.containsKey('style') ||
      map.containsKey('foregroundColor') ||
      map.containsKey('backgroundColor') ||
      map.containsKey('overlayColor') ||
      map.containsKey('surfaceTintColor') ||
      map.containsKey('shadowColor') ||
      map.containsKey('elevation') ||
      map.containsKey('padding') ||
      map.containsKey('minimumSize') ||
      map.containsKey('fixedSize') ||
      map.containsKey('maximumSize') ||
      map.containsKey('iconColor') ||
      map.containsKey('iconSize') ||
      map.containsKey('iconAlignment') ||
      map.containsKey('side') ||
      map.containsKey('shape') ||
      map.containsKey('visualDensity') ||
      map.containsKey('tapTargetSize') ||
      map.containsKey('materialTapTargetSize') ||
      map.containsKey('animationDuration') ||
      map.containsKey('enableFeedback') ||
      map.containsKey('alignment');
  if (!hasStyle) {
    return null;
  }
  return ButtonStyle(
    textStyle: _state(_textStyle(map['textStyle'] ?? map['style'], context)),
    foregroundColor: _state(_color(map['foregroundColor'], context)),
    backgroundColor: _state(_color(map['backgroundColor'], context)),
    overlayColor: _state(_color(map['overlayColor'], context)),
    surfaceTintColor: _state(_color(map['surfaceTintColor'], context)),
    shadowColor: _state(_color(map['shadowColor'], context)),
    elevation: _state(_nonNegativeDouble(map['elevation'])),
    padding: _state(_edgeInsets(map['padding'])),
    minimumSize: _state(_nonNegativeSize(map['minimumSize'])),
    fixedSize: _state(_nonNegativeSize(map['fixedSize'])),
    maximumSize: _state(_nonNegativeSize(map['maximumSize'])),
    iconColor: _state(_color(map['iconColor'], context)),
    iconSize: _state(
      _nonNegativeDouble(map['iconSize'] ?? map['iconSizeValue']),
    ),
    iconAlignment: _iconAlignment(map['iconAlignment']),
    side: _state(_borderSide(map['side'], context)),
    shape: _state(_outlinedBorder(map['shape'] ?? map, context)),
    visualDensity: _visualDensity(map['visualDensity']),
    tapTargetSize: _materialTapTargetSize(
      map['tapTargetSize'] ?? map['materialTapTargetSize'],
    ),
    animationDuration: _duration(map['animationDuration']),
    enableFeedback: _bool(map['enableFeedback']),
    alignment: _alignment(map['alignment']),
  );
}

MenuStyle? _menuStyle(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is MenuStyle) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final hasStyle =
      map.containsKey('backgroundColor') ||
      map.containsKey('color') ||
      map.containsKey('shadowColor') ||
      map.containsKey('surfaceTintColor') ||
      map.containsKey('elevation') ||
      map.containsKey('padding') ||
      map.containsKey('minimumSize') ||
      map.containsKey('fixedSize') ||
      map.containsKey('maximumSize') ||
      map.containsKey('side') ||
      map.containsKey('shape') ||
      map.containsKey('mouseCursor') ||
      map.containsKey('cursor') ||
      map.containsKey('visualDensity') ||
      map.containsKey('alignment');
  if (!hasStyle) {
    return null;
  }
  return MenuStyle(
    backgroundColor: _stateColor(
      map['backgroundColor'] ?? map['color'],
      context,
    ),
    shadowColor: _stateColor(map['shadowColor'], context),
    surfaceTintColor: _stateColor(map['surfaceTintColor'], context),
    elevation: _stateDouble(map['elevation']),
    padding: _stateProperty<EdgeInsetsGeometry>(map['padding'], _edgeInsets),
    minimumSize: _stateSize(map['minimumSize']),
    fixedSize: _stateSize(map['fixedSize']),
    maximumSize: _stateSize(map['maximumSize']),
    side: _stateProperty<BorderSide>(
      map['side'],
      (item) => _borderSide(item, context),
    ),
    shape: _stateProperty<OutlinedBorder>(
      map['shape'] ?? map,
      (item) => _outlinedBorder(item, context),
    ),
    mouseCursor: _stateMouseCursor(map['mouseCursor'] ?? map['cursor']),
    visualDensity: _visualDensity(map['visualDensity']),
    alignment: _alignment(map['alignment']),
  );
}

WidgetStateProperty<T>? _state<T>(T? value) {
  return value == null ? null : WidgetStatePropertyAll<T>(value);
}

WidgetStateProperty<T?>? _stateProperty<T>(
  Object? value,
  T? Function(Object? value) parse,
) {
  if (value == null) {
    return null;
  }
  if (value is WidgetStateProperty<T?>) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    if (_hasWidgetStateKeys(map)) {
      return WidgetStateProperty.resolveWith((states) {
        final stateValue = _widgetStateMapValue(map, states);
        return parse(stateValue);
      });
    }
  }
  final parsed = parse(value);
  return parsed == null ? null : WidgetStatePropertyAll<T?>(parsed);
}

WidgetStateProperty<Color?>? _stateColor(
  Object? value, [
  BuildContext? context,
]) {
  return _stateProperty<Color>(value, (item) => _color(item, context));
}

WidgetStateProperty<Color>? _stateSolidColor(
  Object? value, [
  BuildContext? context,
]) {
  if (value == null) {
    return null;
  }
  if (value is WidgetStateProperty<Color>) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    if (_hasWidgetStateKeys(map)) {
      return WidgetStateProperty.resolveWith((states) {
        return _color(_widgetStateMapValue(map, states), context) ??
            _color(map['default'] ?? map['all'] ?? map['value'], context) ??
            Colors.transparent;
      });
    }
  }
  final parsed = _color(value, context);
  return parsed == null ? null : WidgetStatePropertyAll<Color>(parsed);
}

Color? _widgetStateColor(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is WidgetStateColor) {
    return value;
  }
  if (value is Color) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    if (_hasWidgetStateKeys(map)) {
      return WidgetStateColor.resolveWith((states) {
        return _color(_widgetStateMapValue(map, states)) ??
            _color(map['default'] ?? map['all'] ?? map['value']) ??
            Colors.transparent;
      });
    }
  }
  return _color(value);
}

WidgetStateProperty<double?>? _stateDouble(Object? value) {
  return _stateProperty<double>(value, _double);
}

WidgetStateProperty<MouseCursor?>? _stateMouseCursor(Object? value) {
  return _stateProperty<MouseCursor>(value, (item) {
    if (item == null) {
      return null;
    }
    return _mouseCursor(item);
  });
}

WidgetStateProperty<MouseCursor>? _stateRequiredMouseCursor(Object? value) {
  final property = _stateMouseCursor(value);
  if (property == null) {
    return null;
  }
  return WidgetStateProperty.resolveWith(
    (states) => property.resolve(states) ?? MouseCursor.defer,
  );
}

WidgetStateProperty<Icon?>? _stateIcon(Object? value) {
  return _stateProperty<Icon>(value, _stateIconValue);
}

WidgetStateProperty<Size?>? _stateSize(Object? value) {
  return _stateProperty<Size>(value, _size);
}

WidgetStateProperty<IconThemeData?>? _stateIconTheme(Object? value) {
  return _stateProperty<IconThemeData>(value, _nullableIconThemeData);
}

WidgetStateProperty<Widget?>? _stateWidgetIcon(Object? value) {
  return _stateProperty<Widget>(value, (item) => _stateIconValue(item));
}

Icon? _stateIconValue(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Icon) {
    return value;
  }
  Object? icon = value;
  Color? color;
  double? size;
  if (value is Map) {
    final map = _props(_stringMap(value));
    icon = map['icon'] ?? map['name'] ?? map['data'];
    color = _color(map['color']);
    size = _double(map['size']);
  }
  final data = _iconData(icon);
  return data == null ? null : Icon(data, color: color, size: size);
}

bool _hasWidgetStateKeys(Map<String, Object?> map) {
  return map.keys.any(
    (key) => _widgetStateKeyNames.contains(key.toLowerCase()),
  );
}

Object? _widgetStateMapValue(
  Map<String, Object?> map,
  Set<WidgetState> states,
) {
  const orderedStates = <(WidgetState, String)>[
    (WidgetState.disabled, 'disabled'),
    (WidgetState.error, 'error'),
    (WidgetState.pressed, 'pressed'),
    (WidgetState.dragged, 'dragged'),
    (WidgetState.selected, 'selected'),
    (WidgetState.hovered, 'hovered'),
    (WidgetState.focused, 'focused'),
    (WidgetState.scrolledUnder, 'scrolledunder'),
  ];
  final normalized = map.map((key, value) {
    return MapEntry(key.toLowerCase().replaceAll(RegExp(r'[-_]'), ''), value);
  });
  for (final entry in orderedStates) {
    if (states.contains(entry.$1) && normalized.containsKey(entry.$2)) {
      return normalized[entry.$2];
    }
  }
  return normalized['default'] ?? normalized['all'] ?? normalized['value'];
}

const Set<String> _widgetStateKeyNames = {
  'selected',
  'disabled',
  'hovered',
  'focused',
  'pressed',
  'dragged',
  'error',
  'scrolledunder',
  'scrolled_under',
  'scrolled-under',
  'default',
  'all',
  'value',
};

IconAlignment? _iconAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
    case 'leading':
      return IconAlignment.start;
    case 'end':
    case 'trailing':
      return IconAlignment.end;
  }
  return null;
}

MaterialTapTargetSize? _materialTapTargetSize(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'padded':
      return MaterialTapTargetSize.padded;
    case 'shrinkwrap':
    case 'shrink_wrap':
    case 'shrink-wrap':
      return MaterialTapTargetSize.shrinkWrap;
  }
  return null;
}

ButtonTextTheme? _buttonTextTheme(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'normal':
      return ButtonTextTheme.normal;
    case 'accent':
      return ButtonTextTheme.accent;
    case 'primary':
      return ButtonTextTheme.primary;
  }
  return null;
}

ButtonBarLayoutBehavior? _buttonBarLayoutBehavior(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'constrained':
      return ButtonBarLayoutBehavior.constrained;
    case 'padded':
      return ButtonBarLayoutBehavior.padded;
  }
  return null;
}

BorderSide? _borderSide(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is BorderSide) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    return BorderSide(
      color: _color(map['color'], context) ?? Colors.black,
      width: _double(map['width']) ?? 1,
    );
  }
  return BorderSide(color: _color(value, context) ?? Colors.black);
}

OutlinedBorder? _outlinedBorder(Object? value, [BuildContext? context]) {
  if (value == null) {
    return null;
  }
  if (value is OutlinedBorder) {
    return value;
  }
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'stadium':
      case 'pill':
        return const StadiumBorder();
      case 'circle':
        return const CircleBorder();
      case 'rounded':
      case 'rectangle':
      case 'rect':
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
    }
  }
  if (value is Map) {
    final map = _stringMap(value);
    final borderRadius = _borderRadius(map['borderRadius'] ?? map['radius']);
    final side = _borderSide(map['side'], context);
    final shape = map['shape']?.toString().toLowerCase();
    if (shape == 'stadium') {
      return StadiumBorder(side: side ?? BorderSide.none);
    }
    if (shape == 'circle') {
      return CircleBorder(side: side ?? BorderSide.none);
    }
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      side: side ?? BorderSide.none,
    );
  }
  return null;
}

TableBorder? _tableBorder(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TableBorder) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    return TableBorder.all(
      color: _color(map['color']) ?? Colors.black,
      width: _double(map['width']) ?? 1,
    );
  }
  return TableBorder.all(color: _color(value) ?? Colors.black);
}

Map<int, TableColumnWidth>? _tableColumnWidths(Object? value) {
  if (value == null) {
    return null;
  }
  final out = <int, TableColumnWidth>{};
  if (value is List) {
    for (var index = 0; index < value.length; index++) {
      final width = _tableColumnWidth(value[index]);
      if (width != null) {
        out[index] = width;
      }
    }
  } else if (value is Map) {
    final map = _stringMap(value);
    for (final entry in map.entries) {
      final index = int.tryParse(entry.key);
      final width = _tableColumnWidth(entry.value);
      if (index != null && width != null) {
        out[index] = width;
      }
    }
  }
  return out.isEmpty ? null : out;
}

TableColumnWidth? _tableColumnWidth(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is TableColumnWidth) {
    return value;
  }
  if (value is num) {
    return FixedColumnWidth(value.toDouble());
  }
  if (value is Map) {
    final map = _stringMap(value);
    final type = (map['type'] ?? map['kind'])?.toString().toLowerCase();
    final valueNumber = _double(
      map['value'] ?? map['width'] ?? map['size'] ?? map['extent'],
    );
    if (type == null && valueNumber != null) {
      return FixedColumnWidth(valueNumber);
    }
    switch (type) {
      case 'fixed':
      case 'px':
        return FixedColumnWidth(valueNumber ?? 0);
      case 'flex':
      case 'fraction':
        if (type == 'fraction') {
          return FractionColumnWidth(valueNumber ?? 1);
        }
        return FlexColumnWidth(valueNumber ?? 1);
      case 'intrinsic':
        return IntrinsicColumnWidth(flex: _double(map['flex']));
      case 'min':
        return MinColumnWidth(
          _tableColumnWidth(map['a'] ?? map['first']) ??
              const FlexColumnWidth(),
          _tableColumnWidth(map['b'] ?? map['second']) ??
              const IntrinsicColumnWidth(),
        );
      case 'max':
        return MaxColumnWidth(
          _tableColumnWidth(map['a'] ?? map['first']) ??
              const FlexColumnWidth(),
          _tableColumnWidth(map['b'] ?? map['second']) ??
              const IntrinsicColumnWidth(),
        );
    }
  }
  switch (value.toString().toLowerCase()) {
    case 'flex':
      return const FlexColumnWidth();
    case 'intrinsic':
      return const IntrinsicColumnWidth();
  }
  return null;
}

TableCellVerticalAlignment? _tableCellVerticalAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'top':
      return TableCellVerticalAlignment.top;
    case 'middle':
      return TableCellVerticalAlignment.middle;
    case 'bottom':
      return TableCellVerticalAlignment.bottom;
    case 'baseline':
      return TableCellVerticalAlignment.baseline;
    case 'fill':
      return TableCellVerticalAlignment.fill;
  }
  return null;
}

Gradient? _gradient(Object? value) {
  if (value is! Map) {
    return null;
  }
  final map = _stringMap(value);
  final colors =
      (map['colors'] is List ? map['colors'] as List : const <Object?>[])
          .map(_color)
          .whereType<Color>()
          .toList(growable: false);
  if (colors.length < 2) {
    return null;
  }
  final stops = map['stops'] is List
      ? (map['stops'] as List).map(_double).whereType<double>().toList()
      : null;
  final tileMode = _tileMode(map['tileMode']) ?? TileMode.clamp;
  switch (map['type']?.toString().toLowerCase()) {
    case 'radial':
      return RadialGradient(
        center: _alignment(map['center']) ?? Alignment.center,
        radius: _double(map['radius']) ?? 0.5,
        colors: colors,
        stops: stops?.length == colors.length ? stops : null,
        tileMode: tileMode,
        focal: _alignment(map['focal']),
        focalRadius: _double(map['focalRadius']) ?? 0,
      );
    case 'sweep':
      return SweepGradient(
        center: _alignment(map['center']) ?? Alignment.center,
        startAngle: _double(map['startAngle']) ?? 0,
        endAngle: _double(map['endAngle']) ?? math.pi * 2,
        colors: colors,
        stops: stops?.length == colors.length ? stops : null,
        tileMode: tileMode,
      );
    case 'linear':
    default:
      return LinearGradient(
        begin: _alignment(map['begin']) ?? Alignment.topLeft,
        end: _alignment(map['end']) ?? Alignment.bottomRight,
        colors: colors,
        stops: stops?.length == colors.length ? stops : null,
        tileMode: tileMode,
      );
  }
}

TileMode? _tileMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'clamp':
      return TileMode.clamp;
    case 'repeated':
    case 'repeat':
      return TileMode.repeated;
    case 'mirror':
    case 'mirrored':
      return TileMode.mirror;
    case 'decal':
      return TileMode.decal;
  }
  return null;
}

ui.StrokeCap? _strokeCap(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'butt':
      return ui.StrokeCap.butt;
    case 'round':
    case 'rounded':
      return ui.StrokeCap.round;
    case 'square':
      return ui.StrokeCap.square;
  }
  return null;
}

HitTestBehavior? _hitTestBehavior(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'defer':
    case 'defertochild':
    case 'defer_to_child':
      return HitTestBehavior.deferToChild;
    case 'opaque':
      return HitTestBehavior.opaque;
    case 'translucent':
      return HitTestBehavior.translucent;
  }
  return null;
}

MaterialType? _materialType(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'canvas':
      return MaterialType.canvas;
    case 'card':
      return MaterialType.card;
    case 'circle':
      return MaterialType.circle;
    case 'button':
      return MaterialType.button;
    case 'transparency':
    case 'transparent':
      return MaterialType.transparency;
  }
  return null;
}

BannerLocation? _bannerLocation(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'topleft':
    case 'top_left':
    case 'topstart':
    case 'top_start':
      return BannerLocation.topStart;
    case 'topright':
    case 'top_right':
    case 'topend':
    case 'top_end':
      return BannerLocation.topEnd;
    case 'bottomleft':
    case 'bottom_left':
    case 'bottomstart':
    case 'bottom_start':
      return BannerLocation.bottomStart;
    case 'bottomright':
    case 'bottom_right':
    case 'bottomend':
    case 'bottom_end':
      return BannerLocation.bottomEnd;
  }
  return null;
}

AlignmentGeometry? _alignment(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is AlignmentGeometry) {
    return value;
  }
  if (value is List && value.length >= 2) {
    return Alignment(_double(value[0]) ?? 0, _double(value[1]) ?? 0);
  }
  if (value is Map) {
    final map = _stringMap(value);
    return Alignment(_double(map['x']) ?? 0, _double(map['y']) ?? 0);
  }
  switch (value.toString().toLowerCase()) {
    case 'center':
      return Alignment.center;
    case 'centerleft':
    case 'center_left':
      return Alignment.centerLeft;
    case 'centerright':
    case 'center_right':
      return Alignment.centerRight;
    case 'topcenter':
    case 'top_center':
      return Alignment.topCenter;
    case 'topleft':
    case 'top_left':
      return Alignment.topLeft;
    case 'topright':
    case 'top_right':
      return Alignment.topRight;
    case 'bottomcenter':
    case 'bottom_center':
      return Alignment.bottomCenter;
    case 'bottomleft':
    case 'bottom_left':
      return Alignment.bottomLeft;
    case 'bottomright':
    case 'bottom_right':
      return Alignment.bottomRight;
  }
  return null;
}

Alignment? _plainAlignment(Object? value) {
  final alignment = _alignment(value);
  return alignment is Alignment ? alignment : null;
}

MainAxisAlignment? _mainAxisAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return MainAxisAlignment.start;
    case 'end':
      return MainAxisAlignment.end;
    case 'center':
      return MainAxisAlignment.center;
    case 'spacebetween':
    case 'space_between':
      return MainAxisAlignment.spaceBetween;
    case 'spacearound':
    case 'space_around':
      return MainAxisAlignment.spaceAround;
    case 'spaceevenly':
    case 'space_evenly':
      return MainAxisAlignment.spaceEvenly;
  }
  return null;
}

VerticalDirection? _verticalDirection(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'up':
    case 'reverse':
      return VerticalDirection.up;
    case 'down':
    case 'forward':
      return VerticalDirection.down;
  }
  return null;
}

OverflowBarAlignment? _overflowBarAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return OverflowBarAlignment.start;
    case 'end':
      return OverflowBarAlignment.end;
    case 'center':
      return OverflowBarAlignment.center;
  }
  return null;
}

CrossAxisAlignment? _crossAxisAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return CrossAxisAlignment.start;
    case 'end':
      return CrossAxisAlignment.end;
    case 'center':
      return CrossAxisAlignment.center;
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'baseline':
      return CrossAxisAlignment.baseline;
  }
  return null;
}

CrossAxisAlignment? _expansionTileCrossAxisAlignment(Object? value) {
  final alignment = _crossAxisAlignment(value);
  return alignment == CrossAxisAlignment.baseline ? null : alignment;
}

MainAxisSize? _mainAxisSize(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'min':
      return MainAxisSize.min;
    case 'max':
      return MainAxisSize.max;
  }
  return null;
}

FlexFit? _flexFit(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'tight':
    case 'expanded':
    case 'fill':
      return FlexFit.tight;
    case 'loose':
    case 'flexible':
      return FlexFit.loose;
  }
  return null;
}

Axis? _axis(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'horizontal':
      return Axis.horizontal;
    case 'vertical':
      return Axis.vertical;
  }
  return null;
}

PanAxis _panAxis(Object? value) {
  switch (_normalizedToken(value)) {
    case 'aligned':
    case 'locked':
      return PanAxis.aligned;
    case 'horizontal':
    case 'x':
      return PanAxis.horizontal;
    case 'vertical':
    case 'y':
      return PanAxis.vertical;
    case 'free':
    case 'all':
    default:
      return PanAxis.free;
  }
}

DismissDirection? _dismissDirection(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'horizontal':
      return DismissDirection.horizontal;
    case 'vertical':
      return DismissDirection.vertical;
    case 'starttoend':
    case 'start_to_end':
    case 'start-to-end':
      return DismissDirection.startToEnd;
    case 'endtostart':
    case 'end_to_start':
    case 'end-to-start':
      return DismissDirection.endToStart;
    case 'up':
      return DismissDirection.up;
    case 'down':
      return DismissDirection.down;
    case 'none':
      return DismissDirection.none;
  }
  return null;
}

ShortcutActivator? _shortcutActivator(Object? value) {
  if (value is ShortcutActivator) {
    return value;
  }

  var control = false;
  var shift = false;
  var alt = false;
  var meta = false;
  var includeRepeats = true;
  Object? trigger;

  if (value is Map) {
    final map = _stringMap(value);
    control = _bool(map['control'] ?? map['ctrl']) ?? false;
    shift = _bool(map['shift']) ?? false;
    alt = _bool(map['alt'] ?? map['option']) ?? false;
    meta = _bool(map['meta'] ?? map['cmd'] ?? map['command']) ?? false;
    includeRepeats = _bool(map['includeRepeats']) ?? true;
    trigger = map['key'] ?? map['trigger'] ?? map['logicalKey'];
    final shortcut = _string(map['shortcut']);
    if (shortcut != null) {
      final parsed = _parseShortcut(shortcut);
      control = control || parsed.control;
      shift = shift || parsed.shift;
      alt = alt || parsed.alt;
      meta = meta || parsed.meta;
      trigger ??= parsed.trigger;
    }
  } else {
    final parsed = _parseShortcut(value);
    control = parsed.control;
    shift = parsed.shift;
    alt = parsed.alt;
    meta = parsed.meta;
    trigger = parsed.trigger;
  }

  final key = _logicalKeyboardKey(trigger);
  if (key == null) {
    return null;
  }
  return SingleActivator(
    key,
    control: control,
    shift: shift,
    alt: alt,
    meta: meta,
    includeRepeats: includeRepeats,
  );
}

({bool control, bool shift, bool alt, bool meta, Object? trigger})
_parseShortcut(Object? value) {
  var control = false;
  var shift = false;
  var alt = false;
  var meta = false;
  Object? trigger;

  final text = _string(value);
  if (text == null) {
    return (
      control: control,
      shift: shift,
      alt: alt,
      meta: meta,
      trigger: trigger,
    );
  }
  final parts = text
      .split(RegExp(r'\s*\+\s*'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty);
  for (final part in parts) {
    switch (_normalizeKeyName(part)) {
      case 'ctrl':
      case 'control':
        control = true;
        break;
      case 'shift':
        shift = true;
        break;
      case 'alt':
      case 'option':
        alt = true;
        break;
      case 'meta':
      case 'cmd':
      case 'command':
      case 'super':
        meta = true;
        break;
      default:
        trigger = part;
    }
  }
  return (
    control: control,
    shift: shift,
    alt: alt,
    meta: meta,
    trigger: trigger,
  );
}

LogicalKeyboardKey? _logicalKeyboardKey(Object? value) {
  final keyId = _int(value);
  if (keyId != null) {
    return LogicalKeyboardKey.findKeyByKeyId(keyId) ??
        LogicalKeyboardKey(keyId);
  }
  final text = _string(value);
  if (text == null || text.isEmpty) {
    return null;
  }
  final target = _normalizeKeyName(text);
  for (final key in LogicalKeyboardKey.knownLogicalKeys) {
    final label = _normalizeKeyName(key.keyLabel);
    final debugName = _normalizeKeyName(key.debugName);
    if (target == label ||
        target == debugName ||
        (target.length == 1 && debugName == 'key$target') ||
        (target.length == 1 && debugName == 'digit$target')) {
      return key;
    }
  }
  if (text.length == 1) {
    return LogicalKeyboardKey(text.codeUnitAt(0));
  }
  return null;
}

String _normalizeKeyName(Object? value) {
  return _string(value)?.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '') ?? '';
}

String _dismissDirectionName(DismissDirection direction) {
  switch (direction) {
    case DismissDirection.horizontal:
      return 'horizontal';
    case DismissDirection.vertical:
      return 'vertical';
    case DismissDirection.endToStart:
      return 'endToStart';
    case DismissDirection.startToEnd:
      return 'startToEnd';
    case DismissDirection.up:
      return 'up';
    case DismissDirection.down:
      return 'down';
    case DismissDirection.none:
      return 'none';
  }
}

ScrollbarOrientation? _scrollbarOrientation(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'left':
      return ScrollbarOrientation.left;
    case 'right':
      return ScrollbarOrientation.right;
    case 'top':
      return ScrollbarOrientation.top;
    case 'bottom':
      return ScrollbarOrientation.bottom;
  }
  return null;
}

StackFit? _stackFit(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'expand':
      return StackFit.expand;
    case 'passthrough':
    case 'pass_through':
      return StackFit.passthrough;
    case 'loose':
      return StackFit.loose;
  }
  return null;
}

WrapAlignment? _wrapAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return WrapAlignment.start;
    case 'end':
      return WrapAlignment.end;
    case 'center':
      return WrapAlignment.center;
    case 'spacebetween':
    case 'space_between':
      return WrapAlignment.spaceBetween;
    case 'spacearound':
    case 'space_around':
      return WrapAlignment.spaceAround;
    case 'spaceevenly':
    case 'space_evenly':
      return WrapAlignment.spaceEvenly;
  }
  return null;
}

WrapCrossAlignment? _wrapCrossAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return WrapCrossAlignment.start;
    case 'end':
      return WrapCrossAlignment.end;
    case 'center':
      return WrapCrossAlignment.center;
  }
  return null;
}

ScrollCacheExtent? _scrollCacheExtent(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is ScrollCacheExtent) {
    return value;
  }
  if (value is num) {
    return ScrollCacheExtent.pixels(math.max(0, value.toDouble()));
  }
  if (value is Map) {
    final map = _stringMap(value);
    final unit = _string(
      map['unit'] ?? map['type'] ?? map['style'],
    )?.toLowerCase();
    final amount =
        _nonNegativeDouble(
          map['value'] ??
              map['amount'] ??
              map['extent'] ??
              map['pixels'] ??
              map['viewport'],
        ) ??
        0;
    switch (unit) {
      case 'viewport':
      case 'viewports':
      case 'fraction':
        return ScrollCacheExtent.viewport(amount);
      case 'pixel':
      case 'pixels':
      default:
        if (map.containsKey('viewport')) {
          return ScrollCacheExtent.viewport(amount);
        }
        return ScrollCacheExtent.pixels(amount);
    }
  }
  return null;
}

ScrollViewKeyboardDismissBehavior? _keyboardDismissBehavior(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'manual':
    case 'none':
      return ScrollViewKeyboardDismissBehavior.manual;
    case 'ondrag':
    case 'on_drag':
    case 'drag':
      return ScrollViewKeyboardDismissBehavior.onDrag;
  }
  return null;
}

ScrollPhysics? _scrollPhysics(Map<String, Object?> props) {
  if (_bool(props['scrollable']) == false) {
    return const NeverScrollableScrollPhysics();
  }
  switch ((props['physics'] ?? props['scrollPhysics'])
      ?.toString()
      .toLowerCase()) {
    case 'always':
      return const AlwaysScrollableScrollPhysics();
    case 'never':
      return const NeverScrollableScrollPhysics();
    case 'bouncing':
      return const BouncingScrollPhysics();
    case 'clamping':
      return const ClampingScrollPhysics();
    case 'page':
      return const PageScrollPhysics();
  }
  return null;
}

OptionsViewOpenDirection? _optionsViewOpenDirection(Object? value) {
  switch (_normalizedToken(value)) {
    case 'up':
    case 'above':
    case 'top':
      return OptionsViewOpenDirection.up;
    case 'down':
    case 'below':
    case 'bottom':
      return OptionsViewOpenDirection.down;
  }
  return null;
}

MouseCursor? _mouseCursorOrNull(Object? value) {
  return value == null ? null : _mouseCursor(value);
}

SelectableRegionContextMenuBuilder? _selectionAreaContextMenuBuilder(
  Map<String, Object?> props,
) {
  final value =
      props['contextMenuBuilder'] ??
      props['contextMenu'] ??
      props['showContextMenu'] ??
      props['toolbar'] ??
      props['showToolbar'];
  if (_featureDisabled(value)) {
    return null;
  }
  return (context, selectableRegionState) {
    return AdaptiveTextSelectionToolbar.selectableRegion(
      selectableRegionState: selectableRegionState,
    );
  };
}

TextMagnifierConfiguration? _textMagnifierConfiguration(Object? value) {
  if (value == null) {
    return null;
  }
  final enabled = _bool(value);
  if (enabled == false) {
    return TextMagnifierConfiguration.disabled;
  }
  if (enabled == true) {
    return TextMagnifier.adaptiveMagnifierConfiguration;
  }
  switch (_normalizedToken(value)) {
    case 'disabled':
    case 'disable':
    case 'none':
    case 'off':
    case 'false':
      return TextMagnifierConfiguration.disabled;
    case 'adaptive':
    case 'auto':
    case 'platform':
    case 'enabled':
    case 'enable':
    case 'true':
      return TextMagnifier.adaptiveMagnifierConfiguration;
  }
  return null;
}

EditableTextContextMenuBuilder? _editableTextContextMenuBuilder(
  Map<String, Object?> props,
) {
  final value =
      props['contextMenuBuilder'] ??
      props['contextMenu'] ??
      props['showContextMenu'] ??
      props['toolbar'] ??
      props['showToolbar'];
  if (_featureDisabled(value)) {
    return null;
  }
  return (context, editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  };
}

EditableTextContextMenuBuilder? _cupertinoEditableTextContextMenuBuilder(
  Map<String, Object?> props,
) {
  final value =
      props['contextMenuBuilder'] ??
      props['contextMenu'] ??
      props['showContextMenu'] ??
      props['toolbar'] ??
      props['showToolbar'];
  if (_featureDisabled(value)) {
    return null;
  }
  return (context, editableTextState) {
    return cupertino.CupertinoAdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  };
}

TextSelectionControls? _textSelectionControls(Object? value) {
  switch (_normalizedToken(value)) {
    case '':
    case 'adaptive':
    case 'auto':
    case 'platform':
      return null;
    case 'empty':
    case 'none':
    case 'disabled':
    case 'disable':
      return emptyTextSelectionControls;
    case 'material':
    case 'materialhandle':
    case 'materialhandles':
    case 'android':
    case 'fuchsia':
      return materialTextSelectionHandleControls;
    case 'materiallegacy':
    case 'materialtoolbar':
      return materialTextSelectionControls;
    case 'desktop':
    case 'desktophandle':
    case 'desktophandles':
    case 'linux':
    case 'windows':
      return desktopTextSelectionHandleControls;
    case 'desktoplegacy':
    case 'desktoptoolbar':
      return desktopTextSelectionControls;
    case 'cupertino':
    case 'cupertinohandle':
    case 'cupertinohandles':
    case 'ios':
      return cupertino.cupertinoTextSelectionHandleControls;
    case 'cupertinolegacy':
    case 'cupertinotoolbar':
      return cupertino.cupertinoTextSelectionControls;
    case 'cupertinodesktop':
    case 'cupertinodesktophandle':
    case 'cupertinodesktophandles':
    case 'macos':
      return cupertino.cupertinoDesktopTextSelectionHandleControls;
    case 'cupertinodesktoplegacy':
    case 'cupertinodesktoptoolbar':
      return cupertino.cupertinoDesktopTextSelectionControls;
  }
  return null;
}

bool _featureDisabled(Object? value) {
  final enabled = _bool(value);
  if (enabled != null) {
    return !enabled;
  }
  switch (_normalizedToken(value)) {
    case 'disabled':
    case 'disable':
    case 'none':
    case 'off':
    case 'hidden':
    case 'hide':
      return true;
  }
  return false;
}

String _normalizedToken(Object? value) {
  return _string(value)?.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '') ?? '';
}

BoxDecoration? _cupertinoTextFieldDecoration(Map<String, Object?> props) {
  final explicit = props['decoration'] ?? props['boxDecoration'];
  if (_featureDisabled(explicit)) {
    return null;
  }
  final decoration = _boxDecoration(explicit);
  if (decoration != null) {
    return decoration;
  }
  if (_hasAny(props, const [
    'backgroundColor',
    'color',
    'borderRadius',
    'radius',
  ])) {
    return BoxDecoration(
      color:
          _color(props['backgroundColor'] ?? props['color']) ??
          const cupertino.CupertinoDynamicColor.withBrightness(
            color: cupertino.CupertinoColors.white,
            darkColor: cupertino.CupertinoColors.black,
          ),
      borderRadius:
          _borderRadius(props['borderRadius'] ?? props['radius']) ??
          BorderRadius.circular(5),
    );
  }
  return const BoxDecoration(
    color: cupertino.CupertinoDynamicColor.withBrightness(
      color: cupertino.CupertinoColors.white,
      darkColor: cupertino.CupertinoColors.black,
    ),
    border: Border.fromBorderSide(
      BorderSide(
        color: cupertino.CupertinoDynamicColor.withBrightness(
          color: Color(0x33000000),
          darkColor: Color(0x33ffffff),
        ),
        width: 0,
      ),
    ),
    borderRadius: BorderRadius.all(Radius.circular(5)),
  );
}

cupertino.OverlayVisibilityMode? _overlayVisibilityMode(Object? value) {
  switch (_normalizedToken(value)) {
    case 'never':
    case 'none':
    case 'hidden':
    case 'hide':
    case 'false':
      return cupertino.OverlayVisibilityMode.never;
    case 'editing':
    case 'whileediting':
      return cupertino.OverlayVisibilityMode.editing;
    case 'notediting':
    case 'empty':
      return cupertino.OverlayVisibilityMode.notEditing;
    case 'always':
    case 'true':
      return cupertino.OverlayVisibilityMode.always;
  }
  return null;
}

cupertino.CupertinoButtonSize? _cupertinoButtonSize(Object? value) {
  switch (_normalizedToken(value)) {
    case 'small':
      return cupertino.CupertinoButtonSize.small;
    case 'medium':
      return cupertino.CupertinoButtonSize.medium;
    case 'large':
      return cupertino.CupertinoButtonSize.large;
  }
  return null;
}

ui.BoxHeightStyle? _boxHeightStyle(Object? value) {
  switch (_normalizedToken(value)) {
    case 'tight':
      return ui.BoxHeightStyle.tight;
    case 'max':
      return ui.BoxHeightStyle.max;
    case 'includelinespacingmiddle':
    case 'middle':
      return ui.BoxHeightStyle.includeLineSpacingMiddle;
    case 'includelinespacingtop':
    case 'top':
      return ui.BoxHeightStyle.includeLineSpacingTop;
    case 'includelinespacingbottom':
    case 'bottom':
      return ui.BoxHeightStyle.includeLineSpacingBottom;
    case 'strut':
      return ui.BoxHeightStyle.strut;
  }
  return null;
}

ui.BoxWidthStyle? _boxWidthStyle(Object? value) {
  switch (_normalizedToken(value)) {
    case 'tight':
      return ui.BoxWidthStyle.tight;
    case 'max':
      return ui.BoxWidthStyle.max;
  }
  return null;
}

String? _singleCharacter(Object? value) {
  final text = _string(value);
  if (text == null || text.length != 1) {
    return null;
  }
  return text;
}

int? _textFieldMaxLength(Object? value) {
  switch (_normalizedToken(value)) {
    case 'none':
    case 'nomax':
    case 'unlimited':
      return TextField.noMaxLength;
  }
  return _positiveInt(value);
}

int? _cupertinoTextFieldMaxLength(Object? value) {
  switch (_normalizedToken(value)) {
    case 'none':
    case 'nomax':
    case 'unlimited':
      return null;
  }
  return _positiveInt(value);
}

MouseCursor _mouseCursor(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'basic':
    case 'default':
      return SystemMouseCursors.basic;
    case 'click':
    case 'pointer':
      return SystemMouseCursors.click;
    case 'text':
      return SystemMouseCursors.text;
    case 'forbidden':
    case 'disabled':
      return SystemMouseCursors.forbidden;
    case 'grab':
      return SystemMouseCursors.grab;
    case 'grabbing':
      return SystemMouseCursors.grabbing;
    case 'move':
      return SystemMouseCursors.move;
    case 'none':
      return SystemMouseCursors.none;
  }
  return MouseCursor.defer;
}

Clip? _clip(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'none':
      return Clip.none;
    case 'hardedge':
    case 'hard_edge':
      return Clip.hardEdge;
    case 'antialias':
      return Clip.antiAlias;
    case 'antialiaswithsavelayer':
    case 'anti_alias_with_save_layer':
      return Clip.antiAliasWithSaveLayer;
  }
  return null;
}

ui.SemanticsRole? _semanticsRole(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'alertdialog':
    case 'alert_dialog':
    case 'alert-dialog':
      return ui.SemanticsRole.alertDialog;
    case 'dialog':
      return ui.SemanticsRole.dialog;
    case 'alert':
      return ui.SemanticsRole.alert;
    case 'status':
      return ui.SemanticsRole.status;
    case 'none':
      return ui.SemanticsRole.none;
  }
  return null;
}

BoxFit? _boxFit(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'fill':
      return BoxFit.fill;
    case 'contain':
      return BoxFit.contain;
    case 'cover':
      return BoxFit.cover;
    case 'fitwidth':
    case 'fit_width':
      return BoxFit.fitWidth;
    case 'fitheight':
    case 'fit_height':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    case 'scaledown':
    case 'scale_down':
      return BoxFit.scaleDown;
  }
  return null;
}

ImageRepeat? _imageRepeat(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'norepeat':
    case 'no_repeat':
    case 'no-repeat':
    case 'none':
      return ImageRepeat.noRepeat;
    case 'repeat':
      return ImageRepeat.repeat;
    case 'repeatx':
    case 'repeat_x':
    case 'repeat-x':
      return ImageRepeat.repeatX;
    case 'repeaty':
    case 'repeat_y':
    case 'repeat-y':
      return ImageRepeat.repeatY;
  }
  return null;
}

FilterQuality? _filterQuality(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'none':
      return FilterQuality.none;
    case 'low':
      return FilterQuality.low;
    case 'medium':
      return FilterQuality.medium;
    case 'high':
      return FilterQuality.high;
  }
  return null;
}

BlendMode? _blendMode(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'clear':
      return BlendMode.clear;
    case 'src':
    case 'source':
      return BlendMode.src;
    case 'dst':
    case 'destination':
      return BlendMode.dst;
    case 'srcover':
    case 'src_over':
    case 'src-over':
      return BlendMode.srcOver;
    case 'dstover':
    case 'dst_over':
    case 'dst-over':
      return BlendMode.dstOver;
    case 'srcin':
    case 'src_in':
    case 'src-in':
      return BlendMode.srcIn;
    case 'dstin':
    case 'dst_in':
    case 'dst-in':
      return BlendMode.dstIn;
    case 'srcout':
    case 'src_out':
    case 'src-out':
      return BlendMode.srcOut;
    case 'dstout':
    case 'dst_out':
    case 'dst-out':
      return BlendMode.dstOut;
    case 'srcatop':
    case 'src_atop':
    case 'src-atop':
      return BlendMode.srcATop;
    case 'dstatop':
    case 'dst_atop':
    case 'dst-atop':
      return BlendMode.dstATop;
    case 'xor':
      return BlendMode.xor;
    case 'plus':
      return BlendMode.plus;
    case 'modulate':
      return BlendMode.modulate;
    case 'screen':
      return BlendMode.screen;
    case 'overlay':
      return BlendMode.overlay;
    case 'darken':
      return BlendMode.darken;
    case 'lighten':
      return BlendMode.lighten;
    case 'colordodge':
    case 'color_dodge':
    case 'color-dodge':
      return BlendMode.colorDodge;
    case 'colorburn':
    case 'color_burn':
    case 'color-burn':
      return BlendMode.colorBurn;
    case 'hardlight':
    case 'hard_light':
    case 'hard-light':
      return BlendMode.hardLight;
    case 'softlight':
    case 'soft_light':
    case 'soft-light':
      return BlendMode.softLight;
    case 'difference':
      return BlendMode.difference;
    case 'exclusion':
      return BlendMode.exclusion;
    case 'multiply':
      return BlendMode.multiply;
    case 'hue':
      return BlendMode.hue;
    case 'saturation':
      return BlendMode.saturation;
    case 'color':
      return BlendMode.color;
    case 'luminosity':
      return BlendMode.luminosity;
  }
  return null;
}

BottomNavigationBarType? _bottomNavigationBarType(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'fixed':
      return BottomNavigationBarType.fixed;
    case 'shifting':
      return BottomNavigationBarType.shifting;
  }
  return null;
}

OverflowBoxFit? _overflowBoxFit(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'max':
      return OverflowBoxFit.max;
    case 'defertochild':
    case 'defer_to_child':
    case 'defer-to-child':
    case 'defer':
      return OverflowBoxFit.deferToChild;
  }
  return null;
}

StepperType? _stepperType(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'horizontal':
      return StepperType.horizontal;
    case 'vertical':
      return StepperType.vertical;
  }
  return null;
}

StepState? _stepState(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'indexed':
      return StepState.indexed;
    case 'editing':
      return StepState.editing;
    case 'complete':
      return StepState.complete;
    case 'disabled':
      return StepState.disabled;
    case 'error':
      return StepState.error;
  }
  return null;
}

StepStyle? _stepStyle(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is StepStyle) {
    return value;
  }
  if (value is! Map) {
    return StepStyle(color: _color(value));
  }
  final map = _stringMap(value);
  return StepStyle(
    color: _color(map['color']),
    errorColor: _color(map['errorColor']),
    connectorColor: _color(map['connectorColor']),
    connectorThickness: _nonNegativeDouble(map['connectorThickness']),
    border: _border(map['border']),
    boxShadow: _boxShadow(map['boxShadow'] ?? map['shadow']),
    gradient: _gradient(map['gradient']),
    indexStyle: _textStyle(map['indexStyle']),
  );
}

ShowValueIndicator? _showValueIndicator(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'never':
      return ShowValueIndicator.never;
    case 'onlyfordiscrete':
    case 'only_for_discrete':
    case 'discrete':
      return ShowValueIndicator.onlyForDiscrete;
    case 'onlyforcontinuous':
    case 'only_for_continuous':
    case 'continuous':
      return ShowValueIndicator.onlyForContinuous;
    case 'always':
    case 'ondrag':
    case 'on_drag':
      return ShowValueIndicator.onDrag;
    case 'alwaysvisible':
    case 'always_visible':
      return ShowValueIndicator.alwaysVisible;
  }
  return null;
}

SliderInteraction? _sliderInteraction(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'tapandslide':
    case 'tap_and_slide':
    case 'tap-slide':
      return SliderInteraction.tapAndSlide;
    case 'taponly':
    case 'tap_only':
    case 'tap':
      return SliderInteraction.tapOnly;
    case 'slideonly':
    case 'slide_only':
    case 'slide':
      return SliderInteraction.slideOnly;
    case 'slidethumb':
    case 'slide_thumb':
    case 'thumb':
      return SliderInteraction.slideThumb;
  }
  return null;
}

SemanticFormatterCallback? _sliderSemanticFormatter(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is SemanticFormatterCallback) {
    return value;
  }
  if (value is Map) {
    final map = _stringMap(value);
    final prefix = _string(map['prefix']) ?? '';
    final suffix = _string(map['suffix']) ?? '';
    final decimals = math.max(0, _int(map['decimals']) ?? 0);
    return (next) => '$prefix${next.toStringAsFixed(decimals)}$suffix';
  }
  final template = value.toString();
  return (next) {
    final rounded = next.round().toString();
    return template
        .replaceAll('{value}', next.toString())
        .replaceAll('{round}', rounded);
  };
}

DragStartBehavior _dragStartBehavior(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'down':
      return DragStartBehavior.down;
    case 'start':
    default:
      return DragStartBehavior.start;
  }
}

ListTileStyle? _listTileStyle(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'list':
      return ListTileStyle.list;
    case 'drawer':
      return ListTileStyle.drawer;
  }
  return null;
}

ListTileControlAffinity? _listTileControlAffinity(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'leading':
    case 'start':
      return ListTileControlAffinity.leading;
    case 'trailing':
    case 'end':
      return ListTileControlAffinity.trailing;
    case 'platform':
    case 'adaptive':
      return ListTileControlAffinity.platform;
  }
  return null;
}

ListTileTitleAlignment? _listTileTitleAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'threeline':
    case 'three_line':
    case 'three-line':
      return ListTileTitleAlignment.threeLine;
    case 'titleheight':
    case 'title_height':
    case 'title-height':
      return ListTileTitleAlignment.titleHeight;
    case 'top':
      return ListTileTitleAlignment.top;
    case 'center':
      return ListTileTitleAlignment.center;
    case 'bottom':
      return ListTileTitleAlignment.bottom;
  }
  return null;
}

SnackBarBehavior? _snackBarBehaviorValue(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'fixed':
      return SnackBarBehavior.fixed;
    case 'floating':
      return SnackBarBehavior.floating;
  }
  return null;
}

List<BottomNavigationBarItem> _bottomNavigationItems(Object? value) {
  final list = value is List ? value : const <Object?>[];
  return list
      .map((item) {
        if (item is Map) {
          final props = _props(_stringMap(item));
          return BottomNavigationBarItem(
            icon: _bottomIcon(props['icon']),
            activeIcon: props['activeIcon'] == null
                ? null
                : _bottomIcon(props['activeIcon']),
            label: _string(props['label']) ?? '',
            tooltip: _string(props['tooltip']),
            backgroundColor: _color(props['backgroundColor']),
          );
        }
        return BottomNavigationBarItem(
          icon: const Icon(Icons.circle),
          label: item.toString(),
        );
      })
      .toList(growable: false);
}

List<BottomNavigationBarItem> _safeCupertinoTabItems(
  List<BottomNavigationBarItem> items,
) {
  if (items.length >= 2) {
    return items;
  }
  final out = List<BottomNavigationBarItem>.of(items);
  while (out.length < 2) {
    final index = out.length + 1;
    out.add(
      BottomNavigationBarItem(
        icon: const Icon(Icons.circle),
        label: 'Tab $index',
      ),
    );
  }
  return out;
}

List<NavigationRailDestination> _navigationRailDestinations(
  BuildContext context,
  Object? value,
) {
  final list = value is List ? value : const <Object?>[];
  final renderer = AppletRenderer();
  return list
      .map((item) {
        if (item is Map) {
          final props = _props(_stringMap(item));
          final icon = renderer._iconWidget(context, props['icon']);
          final selectedIcon = props['selectedIcon'] == null
              ? null
              : renderer.buildWidget(context, props['selectedIcon']);
          final labelSpec = props['label'];
          final label = labelSpec is Map
              ? renderer.buildWidget(context, labelSpec)
              : Text(_string(labelSpec) ?? '');
          return NavigationRailDestination(
            icon: icon,
            selectedIcon: selectedIcon,
            label: label,
            padding: _edgeInsets(props['padding']),
          );
        }
        return NavigationRailDestination(
          icon: const Icon(Icons.circle),
          label: Text(item.toString()),
        );
      })
      .toList(growable: false);
}

NavigationRailLabelType? _navigationRailLabelType(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'none':
      return NavigationRailLabelType.none;
    case 'selected':
      return NavigationRailLabelType.selected;
    case 'all':
      return NavigationRailLabelType.all;
  }
  return null;
}

NavigationDestinationLabelBehavior? _navigationDestinationLabelBehavior(
  Object? value,
) {
  final text = value?.toString().toLowerCase();
  switch (text) {
    case 'alwaysshow':
    case 'always_show':
    case 'show':
      return NavigationDestinationLabelBehavior.alwaysShow;
    case 'onlyshowselected':
    case 'only_show_selected':
    case 'selected':
      return NavigationDestinationLabelBehavior.onlyShowSelected;
    case 'alwayshide':
    case 'always_hide':
    case 'hide':
      return NavigationDestinationLabelBehavior.alwaysHide;
  }
  return null;
}

TabBarIndicatorSize? _tabBarIndicatorSize(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'tab':
      return TabBarIndicatorSize.tab;
    case 'label':
      return TabBarIndicatorSize.label;
  }
  return null;
}

TabAlignment? _tabAlignment(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'start':
      return TabAlignment.start;
    case 'startoffset':
    case 'start_offset':
      return TabAlignment.startOffset;
    case 'fill':
      return TabAlignment.fill;
    case 'center':
      return TabAlignment.center;
  }
  return null;
}

TabAlignment? _safeTabAlignment(Object? value, bool isScrollable) {
  final alignment = _tabAlignment(value);
  if (!isScrollable &&
      (alignment == TabAlignment.start ||
          alignment == TabAlignment.startOffset)) {
    return null;
  }
  if (isScrollable && alignment == TabAlignment.fill) {
    return null;
  }
  return alignment;
}

TabIndicatorAnimation? _tabIndicatorAnimation(Object? value) {
  switch (value?.toString().toLowerCase()) {
    case 'linear':
      return TabIndicatorAnimation.linear;
    case 'elastic':
      return TabIndicatorAnimation.elastic;
  }
  return null;
}

NotchedShape? _notchedShape(Object? value) {
  if (value is NotchedShape) {
    return value;
  }
  switch (value?.toString().toLowerCase()) {
    case 'circular':
    case 'circle':
    case 'circularnotchedrectangle':
    case 'circular_notched_rectangle':
      return const CircularNotchedRectangle();
  }
  return null;
}

Widget _bottomIcon(Object? spec) {
  if (spec is Map) {
    final props = _props(_stringMap(spec));
    return Icon(_iconData(props['icon'] ?? props['name']) ?? Icons.circle);
  }
  return Icon(_iconData(spec) ?? Icons.circle);
}

IconData? _iconData(Object? value) {
  if (value is IconData) {
    return value;
  }
  final key = value?.toString().replaceAll('-', '_').toLowerCase();
  if (key == null || key.isEmpty) {
    return null;
  }
  return _icons[key];
}

const Map<String, IconData> _icons = <String, IconData>{
  'add': Icons.add,
  'archive': Icons.archive,
  'archive_outlined': Icons.archive_outlined,
  'article': Icons.article,
  'arrow_back': Icons.arrow_back,
  'arrow_forward': Icons.arrow_forward,
  'attach_file': Icons.attach_file,
  'auto_awesome': Icons.auto_awesome,
  'bolt': Icons.bolt,
  'brush': Icons.brush,
  'bug_report': Icons.bug_report,
  'build': Icons.build,
  'calendar_month': Icons.calendar_month,
  'call_missed': Icons.call_missed,
  'chat_bubble': Icons.chat_bubble,
  'chat_bubble_outline': Icons.chat_bubble_outline,
  'check': Icons.check,
  'check_circle': Icons.check_circle,
  'chevron_left': Icons.chevron_left,
  'chevron_right': Icons.chevron_right,
  'close': Icons.close,
  'cloud': Icons.cloud,
  'code': Icons.code,
  'color_lens': Icons.color_lens,
  'dark_mode': Icons.dark_mode,
  'dashboard': Icons.dashboard,
  'delete': Icons.delete,
  'delete_outline': Icons.delete_outline,
  'desktop_windows': Icons.desktop_windows,
  'directions_bus': Icons.directions_bus,
  'directions_walk': Icons.directions_walk,
  'download': Icons.download,
  'edit': Icons.edit,
  'event': Icons.event,
  'explore': Icons.explore,
  'favorite': Icons.favorite,
  'favorite_border': Icons.favorite_border,
  'flash_on': Icons.flash_on,
  'grid_view': Icons.grid_view,
  'help_outline': Icons.help_outline,
  'home': Icons.home,
  'image': Icons.image,
  'inbox': Icons.inbox,
  'info': Icons.info,
  'layers': Icons.layers,
  'light_mode': Icons.light_mode,
  'list': Icons.list,
  'mail': Icons.mail,
  'mail_outlined': Icons.mail_outlined,
  'menu': Icons.menu,
  'more_vert': Icons.more_vert,
  'palette': Icons.palette,
  'pause': Icons.pause,
  'people_alt_outlined': Icons.people_alt_outlined,
  'phone_iphone': Icons.phone_iphone,
  'play_arrow': Icons.play_arrow,
  'refresh': Icons.refresh,
  'remove_red_eye_outlined': Icons.remove_red_eye_outlined,
  'rocket_launch': Icons.rocket_launch,
  'schedule': Icons.schedule,
  'search': Icons.search,
  'settings': Icons.settings,
  'settings_outlined': Icons.settings_outlined,
  'share': Icons.share,
  'share_outlined': Icons.share_outlined,
  'speed': Icons.speed,
  'star': Icons.star,
  'star_border': Icons.star_border,
  'sync': Icons.sync,
  'table_chart': Icons.table_chart,
  'terminal': Icons.terminal,
  'text_fields': Icons.text_fields,
  'toggle_on': Icons.toggle_on,
  'touch_app': Icons.touch_app,
  'train': Icons.train,
  'tune': Icons.tune,
  'videocam': Icons.videocam,
  'videocam_outlined': Icons.videocam_outlined,
  'widgets': Icons.widgets,
  'email': Icons.email,
  'notifications': Icons.notifications,
  'shopping_bag': Icons.shopping_bag,
};
