import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jsf/jsf.dart';

import 'applet_bootstrap.dart';
import 'applet_core.dart';
import 'applet_modules.dart';

/// Owns a JSF runtime and turns JavaScript Applet source into Flutter specs.
class AppletController extends ChangeNotifier {
  AppletController({
    AppletRuntimeOptions options = const AppletRuntimeOptions(),
  }) : _options = options {
    _createRuntime();
  }

  final AppletRuntimeOptions _options;
  late JsRuntime _runtime;
  AppletSnapshot _snapshot = const AppletSnapshot();
  AppletBundle? _lastBundle;
  String? _lastAssetKey;
  String? _lastAssetFilename;
  bool _lastAssetModule = false;
  AssetBundle? _lastAssetBundle;
  bool _disposed = false;
  bool _renderQueued = false;
  int _renderEpoch = 0;

  /// Current render snapshot.
  AppletSnapshot get snapshot => _snapshot;

  /// Direct JSF runtime access for advanced integrations.
  JsRuntime get runtime => _runtime;

  /// Whether a tree has been rendered at least once.
  bool get hasTree => _snapshot.hasTree;

  /// Loads one source string and renders it.
  ///
  /// ES module mode is enabled by default. Pass `module: false` for legacy
  /// global scripts.
  Future<void> loadSource(
    String source, {
    String filename = '<applet>',
    bool module = true,
    bool preserveState = false,
  }) async {
    _lastAssetKey = null;
    _lastAssetFilename = null;
    _lastAssetBundle = null;
    _lastAssetModule = false;
    _lastBundle = AppletBundle(
      scripts: <AppletScript>[
        AppletScript(source, filename: filename, module: module),
      ],
    );
    await _loadBundle(_lastBundle!, preserveState: preserveState);
  }

  /// Loads a Flutter asset as the Applet entry point.
  ///
  /// ES module mode is enabled by default. Pass `module: false` for legacy
  /// global scripts.
  Future<void> loadAsset(
    String assetKey, {
    AssetBundle? bundle,
    String? filename,
    bool module = true,
    bool preserveState = false,
  }) async {
    _lastAssetKey = assetKey;
    _lastAssetFilename = filename ?? assetKey;
    _lastAssetBundle = bundle;
    _lastAssetModule = module;
    _lastBundle = null;

    _setSnapshot(_snapshot.copyWith(loading: true, error: null));
    try {
      final assetBundle = bundle ?? rootBundle;
      final source = await assetBundle.loadString(assetKey);
      final appletBundle = module
          ? await _loadModuleAssetBundle(
              assetBundle,
              assetKey,
              source,
              filename: _lastAssetFilename!,
            )
          : AppletBundle(
              scripts: <AppletScript>[
                AppletScript(
                  source,
                  filename: _lastAssetFilename!,
                  module: false,
                ),
              ],
            );
      await _loadBundle(
        appletBundle,
        preserveState: preserveState,
        remember: false,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Applet] asset load failed: $error');
      }
      _setSnapshot(
        AppletSnapshot(
          tree: _snapshot.tree,
          error: error,
          stackTrace: stackTrace,
          loading: false,
          version: _snapshot.version + 1,
        ),
      );
    }
  }

  /// Loads an Applet bundle with optional in-memory ES modules.
  Future<void> loadBundle(
    AppletBundle bundle, {
    bool preserveState = false,
  }) async {
    _lastAssetKey = null;
    _lastAssetFilename = null;
    _lastAssetBundle = null;
    _lastAssetModule = false;
    _lastBundle = bundle;
    await _loadBundle(bundle, preserveState: preserveState);
  }

  /// Reloads the last source, asset, or bundle.
  Future<void> reload({bool preserveState = true}) async {
    final assetKey = _lastAssetKey;
    if (assetKey != null) {
      await loadAsset(
        assetKey,
        bundle: _lastAssetBundle,
        filename: _lastAssetFilename,
        module: _lastAssetModule,
        preserveState: preserveState,
      );
      return;
    }
    final bundle = _lastBundle;
    if (bundle == null) {
      return;
    }
    await _loadBundle(bundle, preserveState: preserveState);
  }

  /// Re-runs JavaScript render and stores the resulting widget tree spec.
  Future<void> render() async {
    if (_disposed) {
      return;
    }
    final epoch = ++_renderEpoch;
    try {
      final encodedTree = await _runtime.evalAsync(
        '''
Promise.resolve((() => {
  const tree = globalThis.__appletRender();
  const json = JSON.stringify(tree === undefined ? null : tree);
  globalThis.__appletLastRenderJson = json;
  return json;
})())
''',
        filename: '<applet-render>',
        timeout: _options.promiseTimeout,
      );
      if (encodedTree is! String) {
        throw StateError(
          'Applet render did not return JSON: ${encodedTree.runtimeType}',
        );
      }
      final tree = jsonDecode(encodedTree);
      if (_disposed || epoch != _renderEpoch) {
        return;
      }
      _setSnapshot(
        AppletSnapshot(
          tree: tree,
          loading: false,
          version: _snapshot.version + 1,
        ),
      );
    } catch (error, stackTrace) {
      if (_disposed || epoch != _renderEpoch) {
        return;
      }
      if (kDebugMode) {
        debugPrint('[Applet] render failed: $error');
      }
      _setSnapshot(
        AppletSnapshot(
          tree: _snapshot.tree,
          error: error,
          stackTrace: stackTrace,
          loading: false,
          version: _snapshot.version + 1,
        ),
      );
    }
  }

  /// Sends a Flutter event back to JavaScript.
  Future<void> dispatchAction(AppletAction action) async {
    if (_disposed) {
      return;
    }
    try {
      final actionJson = jsonEncode(action.toJson());
      _runtime.eval('''
(() => {
  const action = $actionJson;
  const previousSuppressNotify = globalThis.__appletSuppressNotify === true;
  globalThis.__appletSuppressNotify = true;
  try {
    globalThis.__appletDispatchAction(action.name, action.payload);
  } finally {
    globalThis.__appletSuppressNotify = previousSuppressNotify;
  }
  return null;
})()
''', filename: '<applet-action>');
      await render();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Applet] action "${action.name}" failed: $error');
      }
      _setSnapshot(
        AppletSnapshot(
          tree: _snapshot.tree,
          error: error,
          stackTrace: stackTrace,
          loading: false,
          version: _snapshot.version + 1,
        ),
      );
    }
  }

  /// Reads `Applet.state` as a Dart snapshot.
  Object? readState() {
    if (_disposed) {
      return null;
    }
    try {
      return _runtime.eval('globalThis.Applet && Applet.state');
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadBundle(
    AppletBundle bundle, {
    required bool preserveState,
    bool remember = true,
  }) async {
    if (remember) {
      _lastBundle = bundle;
    }
    _setSnapshot(_snapshot.copyWith(loading: true, error: null));
    final preservedState = preserveState ? readState() : null;
    try {
      _resetRuntime();
      if (preservedState != null) {
        _runtime.setGlobal('__appletInitialState', preservedState);
      }
      if (bundle.modules.isNotEmpty) {
        _runtime.registerModules(bundle.modules);
      }
      if (bundle.importMap.isNotEmpty) {
        _runtime.registerImportMap(bundle.importMap);
      }
      _runtime.eval('globalThis.__appletSuppressNotify = true');
      try {
        for (final script in bundle.scripts) {
          if (script.module) {
            _runtime.registerModule(script.filename, script.source);
            _runtime.eval(
              _moduleEntrypoint(script.filename),
              filename: '${script.filename}.applet-entry',
              module: true,
            );
          } else {
            _runtime.eval(
              script.source,
              filename: script.filename,
              module: false,
            );
          }
        }
      } finally {
        _runtime.eval('globalThis.__appletSuppressNotify = false');
      }
      await render();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Applet] load failed: $error');
      }
      _setSnapshot(
        AppletSnapshot(
          tree: _snapshot.tree,
          error: error,
          stackTrace: stackTrace,
          loading: false,
          version: _snapshot.version + 1,
        ),
      );
    }
  }

  Future<AppletBundle> _loadModuleAssetBundle(
    AssetBundle bundle,
    String entryAssetKey,
    String entrySource, {
    required String filename,
  }) async {
    final modules = <String, String>{};
    final visited = <String>{};

    Future<void> loadModule(String assetKey, String? knownSource) async {
      if (!visited.add(assetKey)) {
        return;
      }
      final source = knownSource ?? await bundle.loadString(assetKey);
      if (assetKey != entryAssetKey) {
        modules[assetKey] = source;
      }
      for (final specifier in _moduleSpecifiers(source)) {
        if (!_isRelativeModuleSpecifier(specifier)) {
          continue;
        }
        await loadModule(_resolveModuleAsset(assetKey, specifier), null);
      }
    }

    await loadModule(entryAssetKey, entrySource);
    return AppletBundle(
      modules: modules,
      scripts: <AppletScript>[
        AppletScript(entrySource, filename: filename, module: true),
      ],
    );
  }

  void _createRuntime() {
    _runtime = JsRuntime(
      options: JsRuntimeOptions(
        memoryLimitBytes: _options.memoryLimitBytes,
        maxStackSizeBytes: _options.maxStackSizeBytes,
        timeout: _options.timeout,
      ),
    );
    _runtime.registerFunction('__appletNotify', (_) {
      _scheduleRender();
      return null;
    });
    _runtime.registerFunction('__appletLog', (arguments) {
      if (kDebugMode && arguments.isNotEmpty) {
        debugPrint('[Applet] ${arguments.join(' ')}');
      }
      return null;
    });
    _runtime.execInitScript(appletBootstrapScript);
    _runtime.registerModules(appletBuiltinModules);
  }

  void _resetRuntime() {
    _runtime.dispose();
    _createRuntime();
  }

  void _scheduleRender() {
    if (_disposed || _renderQueued) {
      return;
    }
    _renderQueued = true;
    scheduleMicrotask(() async {
      _renderQueued = false;
      await render();
    });
  }

  void _setSnapshot(AppletSnapshot snapshot) {
    if (_disposed) {
      return;
    }
    _snapshot = snapshot;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _runtime.dispose();
    super.dispose();
  }
}

Iterable<String> _moduleSpecifiers(String source) sync* {
  final staticImports = RegExp(
    r'''(?:import|export)\s+(?:[^'"]*?\s+from\s*)?['"]([^'"]+)['"]''',
  );
  for (final match in staticImports.allMatches(source)) {
    final specifier = match.group(1);
    if (specifier != null) {
      yield specifier;
    }
  }

  final dynamicImports = RegExp(r'''import\s*\(\s*['"]([^'"]+)['"]\s*\)''');
  for (final match in dynamicImports.allMatches(source)) {
    final specifier = match.group(1);
    if (specifier != null) {
      yield specifier;
    }
  }
}

bool _isRelativeModuleSpecifier(String specifier) {
  return specifier.startsWith('./') || specifier.startsWith('../');
}

String _resolveModuleAsset(String fromAssetKey, String specifier) {
  final parts = <String>[];
  final slash = fromAssetKey.lastIndexOf('/');
  if (slash > 0) {
    parts.addAll(fromAssetKey.substring(0, slash).split('/'));
  }
  for (final part in specifier.split('/')) {
    if (part.isEmpty || part == '.') {
      continue;
    }
    if (part == '..') {
      if (parts.isNotEmpty) {
        parts.removeLast();
      }
      continue;
    }
    parts.add(part);
  }
  return parts.join('/');
}

String _moduleEntrypoint(String moduleName) {
  final specifier = jsonEncode(moduleName);
  return '''
import * as __appletEntry from $specifier;

if (__appletEntry.default !== undefined) {
  const __appletDefault = __appletEntry.default;
  globalThis.Applet.defineApp(
    typeof __appletDefault === "function"
      ? __appletDefault
      : () => __appletDefault
  );
}
''';
}
