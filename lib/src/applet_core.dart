import 'dart:async';

import 'package:flutter/foundation.dart';

/// A JavaScript source file that can be loaded into an [AppletController].
@immutable
class AppletScript {
  const AppletScript(
    this.source, {
    this.filename = '<applet>',
    this.module = true,
  });

  /// JavaScript source code.
  final String source;

  /// Filename used in JavaScript stack traces.
  final String filename;

  /// Whether the source should be evaluated as an ES module.
  ///
  /// Applet defaults to ES modules because imports and default exports are the
  /// recommended scripting model. Pass `false` for legacy global scripts.
  final bool module;
}

/// Runtime limits forwarded to JSF.
@immutable
class AppletRuntimeOptions {
  const AppletRuntimeOptions({
    this.memoryLimitBytes,
    this.maxStackSizeBytes,
    this.timeout = const Duration(seconds: 2),
    this.promiseTimeout = const Duration(seconds: 3),
  });

  /// Maximum native QuickJS heap size in bytes.
  final int? memoryLimitBytes;

  /// Maximum native JavaScript stack size in bytes.
  final int? maxStackSizeBytes;

  /// Maximum synchronous JavaScript execution time.
  final Duration? timeout;

  /// Maximum time to wait for JavaScript promises created by Applet.
  final Duration? promiseTimeout;
}

/// A hot-update bundle with optional modules and an entry script.
@immutable
class AppletBundle {
  const AppletBundle({
    this.modules = const <String, String>{},
    this.importMap = const <String, String>{},
    this.scripts = const <AppletScript>[],
  });

  /// In-memory ES modules registered before [scripts] run.
  final Map<String, String> modules;

  /// Import aliases registered before [scripts] run.
  final Map<String, String> importMap;

  /// Scripts evaluated after modules are registered.
  final List<AppletScript> scripts;
}

/// A UI event emitted by a JavaScript Applet widget tree.
@immutable
class AppletAction {
  const AppletAction(this.name, {this.payload});

  /// JavaScript action name.
  final String name;

  /// Optional serializable payload passed to the JavaScript handler.
  final Object? payload;

  AppletAction withPayload(Object? value) {
    if (payload == null) {
      return AppletAction(name, payload: value);
    }
    return AppletAction(
      name,
      payload: <String, Object?>{'payload': payload, 'value': value},
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    if (payload != null) 'payload': payload,
  };

  static AppletAction? maybeFrom(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is AppletAction) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return AppletAction(value);
    }
    if (value is Map) {
      final map = value.map((key, item) => MapEntry(key.toString(), item));
      final type = map['type'] ?? map[r'$applet.type'];
      if (type == 'Action' || type == 'action') {
        final props = _stringMap(map['props']) ?? map;
        final name = props['name']?.toString();
        if (name == null || name.isEmpty) {
          return null;
        }
        return AppletAction(name, payload: props['payload']);
      }
      final name = map['action'] ?? map['name'];
      if (name is String && name.isNotEmpty) {
        return AppletAction(name, payload: map['payload']);
      }
    }
    return null;
  }
}

typedef AppletActionDispatcher = FutureOr<void> Function(AppletAction action);
typedef AppletActionHandler = FutureOr<Object?> Function(AppletAction action);

/// The most recent JavaScript render result.
@immutable
class AppletSnapshot {
  const AppletSnapshot({
    this.tree,
    this.error,
    this.stackTrace,
    this.loading = false,
    this.version = 0,
  });

  /// Serializable widget tree produced by JavaScript.
  final Object? tree;

  /// Last runtime/rendering error.
  final Object? error;

  /// Stack trace for [error], when available.
  final StackTrace? stackTrace;

  /// Whether a load or reload is currently running.
  final bool loading;

  /// Monotonic rebuild marker.
  final int version;

  bool get hasTree => tree != null;
  bool get hasError => error != null;

  AppletSnapshot copyWith({
    Object? tree = _unset,
    Object? error = _unset,
    StackTrace? stackTrace,
    bool? loading,
    int? version,
  }) {
    return AppletSnapshot(
      tree: identical(tree, _unset) ? this.tree : tree,
      error: identical(error, _unset) ? this.error : error,
      stackTrace: identical(error, _unset) ? this.stackTrace : stackTrace,
      loading: loading ?? this.loading,
      version: version ?? this.version,
    );
  }
}

const Object _unset = Object();

Map<String, Object?>? _stringMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  return value.map((key, item) => MapEntry(key.toString(), item));
}
