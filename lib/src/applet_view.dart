import 'dart:async';

import 'package:flutter/material.dart';

import 'applet_controller.dart';
import 'applet_core.dart';
import 'applet_renderer.dart';

typedef AppletLoadingBuilder =
    Widget Function(BuildContext context, AppletSnapshot snapshot);

typedef AppletErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace);

/// Short host widget name for JavaScript-driven Applet UI.
///
/// Prefer [Applet.asset] or [Applet.source] in applications. [AppletView] is
/// kept as the longer compatibility name.
class Applet extends AppletView {
  const Applet({
    super.key,
    super.controller,
    super.source,
    super.assetKey,
    super.assetBundle,
    super.filename,
    super.module = true,
    super.runtimeOptions = const AppletRuntimeOptions(),
    super.renderer,
    super.loadingBuilder,
    super.errorBuilder,
    super.onAction,
  });

  const Applet.source(
    super.source, {
    super.key,
    super.controller,
    super.filename,
    super.module = true,
    super.runtimeOptions = const AppletRuntimeOptions(),
    super.renderer,
    super.loadingBuilder,
    super.errorBuilder,
    super.onAction,
  }) : super.source();

  const Applet.asset(
    super.assetKey, {
    super.key,
    super.controller,
    super.assetBundle,
    super.filename,
    super.module = true,
    super.runtimeOptions = const AppletRuntimeOptions(),
    super.renderer,
    super.loadingBuilder,
    super.errorBuilder,
    super.onAction,
  }) : super.asset();
}

/// Flutter host widget for JavaScript-driven Applet UI.
class AppletView extends StatefulWidget {
  const AppletView({
    super.key,
    this.controller,
    this.source,
    this.assetKey,
    this.assetBundle,
    this.filename,
    this.module = true,
    this.runtimeOptions = const AppletRuntimeOptions(),
    this.renderer,
    this.loadingBuilder,
    this.errorBuilder,
    this.onAction,
  }) : assert(
         controller != null || source != null || assetKey != null,
         'Provide a controller, source, or assetKey.',
       );

  const AppletView.source(
    this.source, {
    super.key,
    this.controller,
    this.filename,
    this.module = true,
    this.runtimeOptions = const AppletRuntimeOptions(),
    this.renderer,
    this.loadingBuilder,
    this.errorBuilder,
    this.onAction,
  }) : assetKey = null,
       assetBundle = null;

  const AppletView.asset(
    this.assetKey, {
    super.key,
    this.controller,
    this.assetBundle,
    this.filename,
    this.module = true,
    this.runtimeOptions = const AppletRuntimeOptions(),
    this.renderer,
    this.loadingBuilder,
    this.errorBuilder,
    this.onAction,
  }) : source = null;

  /// Optional externally owned controller.
  final AppletController? controller;

  /// JavaScript source to evaluate.
  final String? source;

  /// Flutter asset containing JavaScript source.
  final String? assetKey;

  /// Asset bundle used for [assetKey].
  final AssetBundle? assetBundle;

  /// Filename shown in JavaScript stack traces.
  final String? filename;

  /// Whether [source] or [assetKey] is an ES module entry point.
  ///
  /// Defaults to `true`. Use `false` only for legacy global scripts.
  final bool module;

  /// Runtime limits used when [controller] is not provided.
  final AppletRuntimeOptions runtimeOptions;

  /// Optional renderer override.
  final AppletRenderer? renderer;

  /// Loading UI shown before the first JavaScript tree is available.
  final AppletLoadingBuilder? loadingBuilder;

  /// Error UI shown when JavaScript fails before producing a tree.
  final AppletErrorBuilder? errorBuilder;

  /// Optional host-side action observer.
  final AppletActionHandler? onAction;

  @override
  State<AppletView> createState() => _AppletViewState();
}

class _AppletViewState extends State<AppletView> {
  late AppletController _controller;
  bool _ownsController = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? AppletController(options: widget.runtimeOptions);
    _ownsController = widget.controller == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      unawaited(_load());
    }
  }

  @override
  void didUpdateWidget(covariant AppletView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      _controller =
          widget.controller ?? AppletController(options: widget.runtimeOptions);
      _ownsController = widget.controller == null;
      _loaded = false;
      unawaited(_load());
      return;
    }
    if (oldWidget.source != widget.source ||
        oldWidget.assetKey != widget.assetKey ||
        oldWidget.filename != widget.filename ||
        oldWidget.module != widget.module) {
      unawaited(_load(preserveState: true));
    }
  }

  Future<void> _load({bool preserveState = false}) async {
    final source = widget.source;
    if (source != null) {
      await _controller.loadSource(
        source,
        filename: widget.filename ?? '<applet>',
        module: widget.module,
        preserveState: preserveState,
      );
      return;
    }
    final assetKey = widget.assetKey;
    if (assetKey != null) {
      await _controller.loadAsset(
        assetKey,
        bundle: widget.assetBundle ?? DefaultAssetBundle.of(context),
        filename: widget.filename ?? assetKey,
        module: widget.module,
        preserveState: preserveState,
      );
    }
  }

  Future<void> _dispatch(AppletAction action) async {
    await widget.onAction?.call(action);
    await _controller.dispatchAction(action);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final snapshot = _controller.snapshot;
        if (!snapshot.hasTree && snapshot.loading) {
          return widget.loadingBuilder?.call(context, snapshot) ??
              const Directionality(
                textDirection: TextDirection.ltr,
                child: Center(child: CircularProgressIndicator()),
              );
        }
        if (!snapshot.hasTree && snapshot.hasError) {
          return widget.errorBuilder?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace,
              ) ??
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(snapshot.error.toString()),
                  ),
                ),
              );
        }
        final renderer = AppletRenderer(
          dispatchAction: _dispatch,
          builders:
              widget.renderer?.builders ??
              const <String, AppletWidgetFactory>{},
        );
        return renderer.buildWidget(context, snapshot.tree);
      },
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }
}
