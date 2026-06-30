const String appletBootstrapScript = r'''
(() => {
  if (globalThis.__appletBootstrapped) return;
  globalThis.__appletBootstrapped = true;

  const handlers = {};
  let callbackId = 0;
  let stateCursor = 0;

  function isPlainObject(value) {
    try {
      return value !== null && typeof value === "object" && !Array.isArray(value);
    } catch (_) {
      return false;
    }
  }

  function markAppletNode(value) {
    return value;
  }

  function propsOf(view) {
    return view.__appletProps || view.props || {};
  }

  function isAppletNode(value) {
    try {
      return value !== null &&
        typeof value === "object" &&
        typeof value.type === "string" &&
        (value.__appletProps !== undefined || value.props !== undefined);
    } catch (_) {
      return false;
    }
  }

  function clean(value) {
    try {
      if (value === undefined) return null;
      if (typeof value === "function" || typeof value === "symbol" || typeof value === "bigint") return null;
      if (Array.isArray(value)) {
        const out = [];
        for (let index = 0; index < value.length; index++) {
          const next = clean(value[index]);
          if (next !== null) out[out.length] = next;
        }
        return out;
      }
      if (isAppletNode(value)) return value;
      if (!isPlainObject(value)) return value;
      const out = {};
      const keys = Object.keys(value);
      for (let index = 0; index < keys.length; index++) {
        const key = keys[index];
        const next = clean(value[key]);
        if (next !== null) out[key] = next;
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  function flatten(value, out = []) {
    try {
      if (value === undefined || value === null || value === false) return out;
      if (Array.isArray(value)) {
        for (let index = 0; index < value.length; index++) {
          flatten(value[index], out);
        }
      } else {
        out[out.length] = value;
      }
    } catch (_) {
      return out;
    }
    return out;
  }

  function edge(value) {
    if (typeof value === "number") return { all: value };
    return value;
  }

  function radius(value) {
    if (typeof value === "number") return { all: value };
    return value;
  }

  function actionOf(value, payload) {
    if (isAppletNode(value)) return value;
    if (typeof value === "function") return Applet.callback(value, payload);
    return Applet.action(value, payload);
  }

  function normalizeProps(values) {
    try {
      if (values === null || typeof values !== "object" || Array.isArray(values)) {
        return values || {};
      }
      const out = {};
      const keys = Object.keys(values);
      for (let index = 0; index < keys.length; index++) {
        const key = keys[index];
        const value = values[key];
        if (
          value !== null &&
          typeof value === "object" &&
          typeof value.type === "string" &&
          (value.__appletProps !== undefined || value.props !== undefined)
        ) {
          out[key] = value;
          continue;
        }
        const isEvent = key.length > 2 &&
          key[0] === "o" &&
          key[1] === "n" &&
          key[2] >= "A" &&
          key[2] <= "Z";
        out[key] = typeof value === "function" &&
          isEvent &&
          globalThis.Applet &&
          typeof globalThis.Applet.callback === "function"
          ? globalThis.Applet.callback(value)
          : value;
      }
      return out;
    } catch (_) {
      return values || {};
    }
  }

  function mergeStyle(view, patch) {
    const props = propsOf(view);
    const current = isPlainObject(props.style) ? props.style : {};
    props.style = { ...current, ...patch };
    return view;
  }

  function supportsTap(type) {
    return type === "Card" ||
      type === "ListTile" ||
      type === "GestureDetector" ||
      type === "InkWell" ||
      type === "ElevatedButton" ||
      type === "FilledButton" ||
      type === "OutlinedButton" ||
      type === "TextButton" ||
      type === "FloatingActionButton";
  }

  const ViewProto = {
    toJSON() {
      return { type: this.type, props: propsOf(this) };
    },
    prop(name, value) {
      if (value !== undefined && value !== null) propsOf(this)[name] = value;
      return this;
    },
    props(values = {}) {
      if (!values) return this;
      const props = propsOf(this);
      for (const key in values) {
        props[key] = values[key];
      }
      return this;
    },
    child(value) {
      propsOf(this).child = value;
      return this;
    },
    children(...items) {
      propsOf(this).children = flatten(items);
      return this;
    },
    padding(value) {
      return Padding(this, { padding: edge(value) });
    },
    margin(value) {
      return Container(this, { margin: edge(value) });
    },
    width(value) {
      return SizedBox(this, { width: value });
    },
    height(value) {
      return SizedBox(this, { height: value });
    },
    size(width, height) {
      return SizedBox(this, { width, height: height === undefined ? width : height });
    },
    align(value) {
      return Align(this, { alignment: value });
    },
    background(value) {
      return Container(this, { color: value });
    },
    backgroundColor(value) {
      return this.prop("backgroundColor", value);
    },
    foregroundColor(value) {
      return this.prop("foregroundColor", value);
    },
    color(value) {
      return this.prop("color", value);
    },
    radius(value) {
      if (this.type === "Container" || this.type === "Card") {
        return this.prop("borderRadius", radius(value));
      }
      return ClipRRect(this, { borderRadius: radius(value) });
    },
    decoration(value) {
      return this.prop("decoration", value);
    },
    elevation(value) {
      return this.prop("elevation", value);
    },
    gap(value) {
      return this.prop("spacing", value);
    },
    runGap(value) {
      return this.prop("runSpacing", value);
    },
    main(value) {
      return this.prop("mainAxisAlignment", value);
    },
    cross(value) {
      return this.prop("crossAxisAlignment", value);
    },
    stretch() {
      return this.cross("stretch");
    },
    min() {
      return this.prop("mainAxisSize", "min");
    },
    expanded(flex = 1) {
      return Expanded(this, { flex });
    },
    flexible(flex = 1) {
      return Flexible(this, { flex });
    },
    onTap(name, payload) {
      const action = actionOf(name, payload);
      if (supportsTap(this.type)) return this.prop("onTap", action);
      return InkWell(this, { onTap: action });
    },
    onPressed(name, payload) {
      return this.prop("onPressed", actionOf(name, payload));
    },
    onChanged(name, payload) {
      return this.prop("onChanged", actionOf(name, payload));
    },
    fontSize(value) {
      return mergeStyle(this, { fontSize: value });
    },
    fontWeight(value) {
      return mergeStyle(this, { fontWeight: value });
    },
    bold() {
      return this.fontWeight("bold");
    },
    textColor(value) {
      return mergeStyle(this, { color: value });
    },
    style(value = {}) {
      return mergeStyle(this, value);
    },
    maxLines(value) {
      return this.prop("maxLines", value);
    },
    overflow(value) {
      return this.prop("overflow", value);
    },
    icon(value) {
      return this.prop("icon", value);
    },
  };

  function node(type, props = {}) {
    const view = Object.create(ViewProto);
    view.type = type;
    Object.defineProperty(view, "__appletProps", {
      value: normalizeProps(props),
      configurable: true,
      writable: true,
    });
    return markAppletNode(view);
  }

  globalThis.__appletJsonReplacer = function(_, value) {
    try {
      const type = typeof value;
      if (type === "function" || type === "symbol" || type === "undefined") return undefined;
      if (type === "bigint") return String(value);
      return value;
    } catch (_) {
      return undefined;
    }
  };

  function childNode(type, first = {}, second = {}) {
    if (Array.isArray(first)) {
      return node(type, { ...second, children: first });
    }
    if (isAppletNode(first) || !isPlainObject(first) || safeType(first)) {
      return node(type, { ...second, child: first });
    }
    return node(type, { ...first, ...second });
  }

  function childrenNode(type, first = {}, second = {}) {
    if (Array.isArray(first)) {
      return node(type, { ...second, children: first });
    }
    if (isPlainObject(first)) {
      return node(type, { ...first, ...second });
    }
    return node(type, first || {});
  }

  function safeType(value) {
    try {
      return value && value.type;
    } catch (_) {
      return null;
    }
  }

  function define(name, factory) {
    Object.defineProperty(globalThis, name, {
      value: factory,
      configurable: true,
      writable: true,
    });
  }

  const Applet = globalThis.Applet || {};
  Applet.state = Applet.state || {};
  Applet.initialState = function(defaults = {}) {
    const preserved = globalThis.__appletInitialState || {};
    Applet.state = { ...defaults, ...preserved };
    return Applet.state;
  };
  Applet.setState = function(patch, value) {
    if (typeof patch === "string") {
      Applet.state[patch] = value;
    } else if (patch && typeof patch === "object") {
      Object.assign(Applet.state, patch);
    }
    Applet.refresh();
    return null;
  };
  Applet.update = Applet.setState;
  Applet.refresh = function() {
    if (globalThis.__appletSuppressNotify) {
      globalThis.__appletNeedsRefresh = true;
      return null;
    }
    if (typeof globalThis.__appletNotify === "function") {
      globalThis.__appletNotify();
    }
    return null;
  };
  Applet.log = function(...items) {
    if (typeof globalThis.__appletLog === "function") {
      globalThis.__appletLog(items.map((item) => {
        try { return typeof item === "string" ? item : JSON.stringify(item); }
        catch (_) { return String(item); }
      }).join(" "));
    }
  };
  Applet.defineApp = function(render) {
    Applet._render = render;
    Applet.refresh();
  };
  Applet.onAction = function(name, handler) {
    handlers[name] = handler;
    return name;
  };
  Applet.action = function(name, payload) {
    const props = { name: String(name) };
    if (payload !== undefined) props.payload = payload;
    return markAppletNode({ type: "Action", props });
  };
  Applet.callback = function(handler, payload) {
    const name = "__callback_" + (++callbackId);
    handlers[name] = handler;
    return Applet.action(name, payload);
  };
  Applet.widget = node;
  Applet.children = flatten;

  function initialStateValue(value) {
    return typeof value === "function" ? value() : value;
  }

  function localStateStore() {
    if (!isPlainObject(Applet.__localState)) {
      Applet.__localState = {};
    }
    return Applet.__localState;
  }

  function localStateKey(key) {
    return key === undefined || key === null ? "$" + (stateCursor++) : String(key);
  }

  function setLocalState(key, next, payload) {
    const store = localStateStore();
    const current = store[key];
    const value = typeof next === "function" ? next(current, payload) : next;
    store[key] = value;
    Applet.refresh();
    return value;
  }

  const StateProto = {
    get value() {
      return localStateStore()[this.__appletStateKey];
    },
    set value(next) {
      setLocalState(this.__appletStateKey, next);
    },
    set(next) {
      setLocalState(this.__appletStateKey, next);
      return this;
    },
    update(reducer) {
      setLocalState(this.__appletStateKey, reducer);
      return this;
    },
    toggle() {
      setLocalState(this.__appletStateKey, (value) => !value);
      return this;
    },
    action(next) {
      const key = this.__appletStateKey;
      if (arguments.length === 0) {
        return Applet.callback((payload) => setLocalState(key, payload));
      }
      return Applet.callback((payload) => setLocalState(key, next, payload));
    },
    toString() {
      return String(this.value);
    },
    valueOf() {
      return this.value;
    },
    toJSON() {
      return this.value;
    },
  };

  function useState(initial, key) {
    const stateKey = localStateKey(key);
    const store = localStateStore();
    if (!Object.prototype.hasOwnProperty.call(store, stateKey)) {
      store[stateKey] = initialStateValue(initial);
    }
    const ref = Object.create(StateProto);
    Object.defineProperty(ref, "__appletStateKey", {
      value: stateKey,
      configurable: true,
    });
    return ref;
  }

  useState.key = function(key, initial) {
    return useState(initial, key);
  };
  useState.remember = useState;

  Applet.useState = useState;
  Applet.State = useState;
  globalThis.Applet = Applet;

  globalThis.__appletDispatchAction = function(name, payload) {
    const handler = handlers[name];
    if (typeof handler !== "function") return null;
    const result = handler(payload, Applet.state);
    if (result && typeof result.then === "function") {
      result.then(
        function() { Applet.refresh(); },
        function(error) { Applet.log("action rejected", error && (error.stack || error.message || error)); }
      );
    }
    return null;
  };

  globalThis.__appletRender = function() {
    stateCursor = 0;
    if (typeof Applet._render === "function") {
      return Applet._render(Applet.state);
    }
    if (typeof globalThis.build === "function") {
      return globalThis.build(Applet.state);
    }
    return Text("No Applet.defineApp() or build() function was found.");
  };

  define("MaterialApp", (props = {}) => node("MaterialApp", props));
  define("Theme", (props = {}) => node("Theme", props));
  define("AnimatedTheme", (first = {}, second = {}) => childNode("AnimatedTheme", first, second));
  define("ThemeData", (props = {}) => ({ ...props }));
  define("ColorScheme", {
    fromSeed: (props = {}) => ({ ...props, fromSeed: true }),
  });
  define("Scaffold", (props = {}) => node("Scaffold", props));
  define("AdaptiveNavigationScaffold", (props = {}) => node("AdaptiveNavigationScaffold", props));
  define("AdaptiveTwoPane", (props = {}) => node("AdaptiveTwoPane", props));
  define("ScaffoldMessenger", (first = {}, second = {}) => childNode("ScaffoldMessenger", first, second));
  define("AppBar", (props = {}) => node("AppBar", props));
  define("SafeArea", (first = {}, second = {}) => childNode("SafeArea", first, second));
  define("Directionality", (first = {}, second = {}) => childNode("Directionality", first, second));
  define("TickerMode", (first = {}, second = {}) => childNode("TickerMode", first, second));
  define("SelectionArea", (first = {}, second = {}) => childNode("SelectionArea", first, second));
  define("DefaultSelectionStyle", (first = {}, second = {}) => childNode("DefaultSelectionStyle", first, second));
  define("Center", (first = {}, second = {}) => childNode("Center", first, second));
  define("Align", (first = {}, second = {}) => childNode("Align", first, second));
  define("Padding", (first = {}, second = {}) => childNode("Padding", first, second));
  define("Container", (first = {}, second = {}) => childNode("Container", first, second));
  define("ColoredBox", (first = {}, second = {}) => childNode("ColoredBox", first, second));
  define("DecoratedBox", (first = {}, second = {}) => childNode("DecoratedBox", first, second));
  define("SizedBox", (first = {}, second = {}) => childNode("SizedBox", first, second));
  define("ConstrainedBox", (first = {}, second = {}) => childNode("ConstrainedBox", first, second));
  define("LimitedBox", (first = {}, second = {}) => childNode("LimitedBox", first, second));
  define("UnconstrainedBox", (first = {}, second = {}) => childNode("UnconstrainedBox", first, second));
  define("OverflowBox", (first = {}, second = {}) => childNode("OverflowBox", first, second));
  define("SizedOverflowBox", (first = {}, second = {}) => childNode("SizedOverflowBox", first, second));
  define("AspectRatio", (first = {}, second = {}) => childNode("AspectRatio", first, second));
  define("FractionallySizedBox", (first = {}, second = {}) => childNode("FractionallySizedBox", first, second));
  define("FittedBox", (first = {}, second = {}) => childNode("FittedBox", first, second));
  define("Baseline", (first = {}, second = {}) => childNode("Baseline", first, second));
  define("IntrinsicWidth", (first = {}, second = {}) => childNode("IntrinsicWidth", first, second));
  define("IntrinsicHeight", (first = {}, second = {}) => childNode("IntrinsicHeight", first, second));
  define("Expanded", (first = {}, second = {}) => childNode("Expanded", first, second));
  define("Flexible", (first = {}, second = {}) => childNode("Flexible", first, second));
  define("Opacity", (first = {}, second = {}) => childNode("Opacity", first, second));
  define("AnimatedOpacity", (first = {}, second = {}) => childNode("AnimatedOpacity", first, second));
  define("AnimatedContainer", (first = {}, second = {}) => childNode("AnimatedContainer", first, second));
  define("AnimatedAlign", (first = {}, second = {}) => childNode("AnimatedAlign", first, second));
  define("AnimatedPadding", (first = {}, second = {}) => childNode("AnimatedPadding", first, second));
  define("AnimatedScale", (first = {}, second = {}) => childNode("AnimatedScale", first, second));
  define("AnimatedRotation", (first = {}, second = {}) => childNode("AnimatedRotation", first, second));
  define("AnimatedSlide", (first = {}, second = {}) => childNode("AnimatedSlide", first, second));
  define("AnimatedSize", (first = {}, second = {}) => childNode("AnimatedSize", first, second));
  define("AnimatedSwitcher", (first = {}, second = {}) => childNode("AnimatedSwitcher", first, second));
  define("AnimatedCrossFade", (props = {}) => node("AnimatedCrossFade", props));
  define("AnimatedDefaultTextStyle", (first = {}, second = {}) => childNode("AnimatedDefaultTextStyle", first, second));
  define("AnimatedPhysicalModel", (first = {}, second = {}) => childNode("AnimatedPhysicalModel", first, second));
  define("Visibility", (first = {}, second = {}) => childNode("Visibility", first, second));
  define("Offstage", (first = {}, second = {}) => childNode("Offstage", first, second));
  define("IgnorePointer", (first = {}, second = {}) => childNode("IgnorePointer", first, second));
  define("AbsorbPointer", (first = {}, second = {}) => childNode("AbsorbPointer", first, second));
  define("RepaintBoundary", (first = {}, second = {}) => childNode("RepaintBoundary", first, second));
  define("Semantics", (first = {}, second = {}) => childNode("Semantics", first, second));
  define("ExcludeSemantics", (first = {}, second = {}) => childNode("ExcludeSemantics", first, second));
  define("MergeSemantics", (first = {}, second = {}) => childNode("MergeSemantics", first, second));
  define("PhysicalModel", (first = {}, second = {}) => childNode("PhysicalModel", first, second));
  define("ClipRRect", (first = {}, second = {}) => childNode("ClipRRect", first, second));
  define("ClipOval", (first = {}, second = {}) => childNode("ClipOval", first, second));
  define("ClipRect", (first = {}, second = {}) => childNode("ClipRect", first, second));
  define("RotatedBox", (first = {}, second = {}) => childNode("RotatedBox", first, second));
  define("Transform", (first = {}, second = {}) => childNode("Transform", first, second));
  define("SingleChildScrollView", (first = {}, second = {}) => childNode("SingleChildScrollView", first, second));
  define("CustomScrollView", (first = {}, second = {}) => childrenNode("CustomScrollView", first, second));
  define("SliverToBoxAdapter", (first = {}, second = {}) => childNode("SliverToBoxAdapter", first, second));
  define("SliverPadding", (first = {}, second = {}) => childNode("SliverPadding", first, second));
  define("SliverList", (first = {}, second = {}) => childrenNode("SliverList", first, second));
  define("SliverCachedList", (first = {}, second = {}) => childrenNode("SliverCachedList", first, second));
  define("SliverEstimatedList", (first = {}, second = {}) => childrenNode("SliverEstimatedList", first, second));
  define("SliverGrid", (first = {}, second = {}) => childrenNode("SliverGrid", first, second));
  define("SliverFillRemaining", (first = {}, second = {}) => childNode("SliverFillRemaining", first, second));
  const sliverAppBar = (props = {}) => node("SliverAppBar", props);
  sliverAppBar.medium = (props = {}) => node("SliverAppBar", { ...props, variant: "medium" });
  sliverAppBar.large = (props = {}) => node("SliverAppBar", { ...props, variant: "large" });
  define("SliverAppBar", sliverAppBar);
  define("SliverLayoutBuilder", (first = {}, second = {}) => childNode("SliverLayoutBuilder", first, second));
  define("Builder", (first = {}, second = {}) => childNode("Builder", first, second));
  define("LayoutBuilder", (first = {}, second = {}) => childNode("LayoutBuilder", first, second));
  define("OrientationBuilder", (first = {}, second = {}) => childNode("OrientationBuilder", first, second));
  define("MediaQuery", (first = {}, second = {}) => childNode("MediaQuery", first, second));
  define("DefaultTextStyle", (first = {}, second = {}) => childNode("DefaultTextStyle", first, second));
  define("IconTheme", (first = {}, second = {}) => childNode("IconTheme", first, second));
  define("Form", (first = {}, second = {}) => childNode("Form", first, second));
  define("AutofillGroup", (first = {}, second = {}) => childNode("AutofillGroup", first, second));
  define("Focus", (first = {}, second = {}) => childNode("Focus", first, second));
  define("FocusTraversalGroup", (first = {}, second = {}) => childNode("FocusTraversalGroup", first, second));
  define("FocusableActionDetector", (first = {}, second = {}) => childNode("FocusableActionDetector", first, second));
  define("KeyboardListener", (first = {}, second = {}) => childNode("KeyboardListener", first, second));
  define("CallbackShortcuts", (first = {}, second = {}) => childNode("CallbackShortcuts", first, second));
  define("Column", (first = {}, second = {}) => childrenNode("Column", first, second));
  define("Row", (first = {}, second = {}) => childrenNode("Row", first, second));
  define("Stack", (first = {}, second = {}) => childrenNode("Stack", first, second));
  define("IndexedStack", (first = {}, second = {}) => childrenNode("IndexedStack", first, second));
  define("Wrap", (first = {}, second = {}) => childrenNode("Wrap", first, second));
  define("ListBody", (first = {}, second = {}) => childrenNode("ListBody", first, second));
  define("ListView", (first = {}, second = {}) => childrenNode("ListView", first, second));
  define("ReorderableListView", (first = {}, second = {}) => childrenNode("ReorderableListView", first, second));
  define("ReorderableDragStartListener", (first = {}, second = {}) => childNode("ReorderableDragStartListener", first, second));
  define("ReorderableDelayedDragStartListener", (first = {}, second = {}) => childNode("ReorderableDelayedDragStartListener", first, second));
  define("Scrollbar", (first = {}, second = {}) => childNode("Scrollbar", first, second));
  define("GridView", (first = {}, second = {}) => childrenNode("GridView", first, second));
  define("GridTile", (first = {}, second = {}) => childNode("GridTile", first, second));
  define("GridTileBar", (props = {}) => node("GridTileBar", props));
  define("PageView", (first = {}, second = {}) => childrenNode("PageView", first, second));
  define("VStack", (...children) => Column(children));
  define("HStack", (...children) => Row(children));
  define("ZStack", (...children) => Stack(children));
  define("Scroll", (...children) => ListView(children));
  define("Box", (first = {}, second = {}) => Container(first, second));
  define("Button", (label = "", action, payload) => {
    const button = FilledButton({ label });
    return action === undefined ? button : button.onPressed(action, payload);
  });
  define("For", (items = [], render) => {
    const out = [];
    for (let index = 0; index < items.length; index++) {
      const next = render(items[index], index);
      flatten(next, out);
    }
    return out;
  });
  define("Show", (condition, view) => condition ? view : null);
  define("Action", (value, payload) => actionOf(value, payload));
  define("Children", (...items) => flatten(items));
  define("State", useState);
  define("Remember", useState);
  define("Positioned", (props = {}) => node("Positioned", props));
  define("AnimatedPositioned", (props = {}) => node("AnimatedPositioned", props));
  define("Spacer", (props = {}) => node("Spacer", props));
  define("GestureDetector", (first = {}, second = {}) => childNode("GestureDetector", first, second));
  define("Listener", (first = {}, second = {}) => childNode("Listener", first, second));
  define("MouseRegion", (first = {}, second = {}) => childNode("MouseRegion", first, second));
  define("InteractiveViewer", (first = {}, second = {}) => childNode("InteractiveViewer", first, second));
  define("Dismissible", (first = {}, second = {}) => childNode("Dismissible", first, second));
  define("Draggable", (first = {}, second = {}) => childNode("Draggable", first, second));
  define("LongPressDraggable", (first = {}, second = {}) => childNode("LongPressDraggable", first, second));
  define("DragTarget", (first = {}, second = {}) => childNode("DragTarget", first, second));
  define("TapRegion", (first = {}, second = {}) => childNode("TapRegion", first, second));
  define("TapRegionSurface", (first = {}, second = {}) => childNode("TapRegionSurface", first, second));
  define("InkWell", (first = {}, second = {}) => childNode("InkWell", first, second));
  define("Tooltip", (first = {}, second = {}) => childNode("Tooltip", first, second));
  define("Hero", (first = {}, second = {}) => childNode("Hero", first, second));
  define("Placeholder", (props = {}) => node("Placeholder", props));
  define("Material", (first = {}, second = {}) => childNode("Material", first, second));
  const card = (first = {}, second = {}) => childNode("Card", first, second);
  card.filled = (first = {}, second = {}) => childNode("Card", first, { ...second, variant: "filled" });
  card.outlined = (first = {}, second = {}) => childNode("Card", first, { ...second, variant: "outlined" });
  define("Card", card);
  define("CircleAvatar", (first = {}, second = {}) => childNode("CircleAvatar", first, second));
  const badge = (first = {}, second = {}) => childNode("Badge", first, second);
  badge.count = (first = {}, second = {}) => {
    const count = typeof first === "number"
      ? first
      : (isPlainObject(first) && first.count !== undefined
          ? first.count
          : (second && second.count !== undefined ? second.count : 0));
    if (typeof first === "number") return node("Badge", { ...second, count });
    return childNode("Badge", first, { ...second, count });
  };
  define("Badge", badge);
  define("Banner", (first = {}, second = {}) => childNode("Banner", first, second));
  define("MaterialBanner", (first = {}, second = {}) => childNode("MaterialBanner", first, second));
  define("Drawer", (first = {}, second = {}) => childNode("Drawer", first, second));
  define("DrawerHeader", (first = {}, second = {}) => childNode("DrawerHeader", first, second));
  define("ListTile", (props = {}) => node("ListTile", props));
  define("ExpansionTile", (first = {}, second = {}) => childrenNode("ExpansionTile", first, second));
  const expansionPanelList = (first = {}, second = {}) => childrenNode("ExpansionPanelList", first, second);
  expansionPanelList.radio = (first = {}, second = {}) =>
    childrenNode("ExpansionPanelListRadio", first, { ...second, radio: true });
  define("ExpansionPanelList", expansionPanelList);
  define("ExpansionPanel", (props = {}) => node("ExpansionPanel", props));
  define("ExpansionPanelRadio", (props = {}) => node("ExpansionPanelRadio", props));
  define("Divider", (props = {}) => node("Divider", props));
  define("VerticalDivider", (props = {}) => node("VerticalDivider", props));
  define("Chip", (props = {}) => node("Chip", props));
  const actionChip = (props = {}) => node("ActionChip", props);
  actionChip.elevated = (props = {}) => node("ActionChip", { ...props, elevated: true });
  define("ActionChip", actionChip);
  const filterChip = (props = {}) => node("FilterChip", props);
  filterChip.elevated = (props = {}) => node("FilterChip", { ...props, elevated: true });
  define("FilterChip", filterChip);
  const choiceChip = (props = {}) => node("ChoiceChip", props);
  choiceChip.elevated = (props = {}) => node("ChoiceChip", { ...props, elevated: true });
  define("ChoiceChip", choiceChip);
  define("InputChip", (props = {}) => node("InputChip", props));
  define("Text", (data = "", props = {}) => node("Text", { ...props, data }));
  define("SelectableText", (data = "", props = {}) => node("SelectableText", { ...props, data }));
  define("RichText", (props = {}) => node("RichText", props));
  define("TextSpan", (text = "", props = {}) => ({ ...props, text }));
  define("TextStyle", (props = {}) => ({ ...props }));
  define("InputDecoration", (props = {}) => ({ ...props }));
  define("ButtonStyle", (props = {}) => ({ ...props }));
  define("MenuStyle", (props = {}) => ({ ...props }));
  define("Icon", (icon, props = {}) => node("Icon", { ...props, icon }));
  const image = (src, props = {}) => node("Image", { ...props, src });
  image.network = (src, props = {}) => node("Image", { ...props, src, source: "network" });
  image.asset = (asset, props = {}) => node("Image", { ...props, asset, source: "asset" });
  image.memory = (bytes, props = {}) => node("Image", { ...props, bytes, source: "memory" });
  image.base64 = (base64, props = {}) => node("Image", { ...props, base64, source: "memory" });
  define("Image", image);
  const elevatedButton = (first = {}, second = {}) => childNode("ElevatedButton", first, second);
  elevatedButton.icon = (props = {}) => node("ElevatedButton", props);
  define("ElevatedButton", elevatedButton);
  const filledButton = (first = {}, second = {}) => childNode("FilledButton", first, second);
  filledButton.icon = (props = {}) => node("FilledButton", props);
  filledButton.tonal = (first = {}, second = {}) => childNode("FilledButton", first, { ...second, tonal: true });
  filledButton.tonalIcon = (props = {}) => node("FilledButton", { ...props, tonal: true });
  define("FilledButton", filledButton);
  const outlinedButton = (first = {}, second = {}) => childNode("OutlinedButton", first, second);
  outlinedButton.icon = (props = {}) => node("OutlinedButton", props);
  define("OutlinedButton", outlinedButton);
  const textButton = (first = {}, second = {}) => childNode("TextButton", first, second);
  textButton.icon = (props = {}) => node("TextButton", props);
  define("TextButton", textButton);
  const iconButton = (props = {}) => node("IconButton", props);
  iconButton.filled = (props = {}) => node("IconButton", { ...props, variant: "filled" });
  iconButton.filledTonal = (props = {}) => node("IconButton", { ...props, variant: "filledTonal" });
  iconButton.outlined = (props = {}) => node("IconButton", { ...props, variant: "outlined" });
  define("IconButton", iconButton);
  define("BackButton", (props = {}) => node("BackButton", props));
  define("CloseButton", (props = {}) => node("CloseButton", props));
  const floatingActionButton = (first = {}, second = {}) => childNode("FloatingActionButton", first, second);
  floatingActionButton.small = (first = {}, second = {}) => childNode("FloatingActionButton", first, { ...second, variant: "small" });
  floatingActionButton.large = (first = {}, second = {}) => childNode("FloatingActionButton", first, { ...second, variant: "large" });
  floatingActionButton.extended = (props = {}) => node("FloatingActionButton", { ...props, variant: "extended" });
  define("FloatingActionButton", floatingActionButton);
  define("TextField", (props = {}) => node("TextField", props));
  define("TextFormField", (props = {}) => node("TextFormField", props));
  define("Autocomplete", (props = {}) => node("Autocomplete", props));
  const adaptiveNode = (type) => {
    const factory = (props = {}) => node(type, props);
    factory.adaptive = (props = {}) => node(type, { ...props, adaptive: true });
    return factory;
  };
  const adaptiveChildNode = (type) => {
    const factory = (first = {}, second = {}) => childNode(type, first, second);
    factory.adaptive = (first = {}, second = {}) => childNode(type, first, { ...second, adaptive: true });
    return factory;
  };
  define("Switch", adaptiveNode("Switch"));
  define("SwitchListTile", adaptiveNode("SwitchListTile"));
  define("Checkbox", adaptiveNode("Checkbox"));
  define("CheckboxListTile", adaptiveNode("CheckboxListTile"));
  define("Radio", adaptiveNode("Radio"));
  define("RadioListTile", adaptiveNode("RadioListTile"));
  define("Slider", adaptiveNode("Slider"));
  define("RangeSlider", (props = {}) => node("RangeSlider", props));
  define("ToggleButtons", (props = {}) => node("ToggleButtons", props));
  define("SegmentedButton", (props = {}) => node("SegmentedButton", props));
  define("ButtonSegment", (props = {}) => ({ ...props }));
  define("DropdownButton", (props = {}) => node("DropdownButton", props));
  define("DropdownMenuItem", (props = {}) => node("DropdownMenuItem", props));
  define("DropdownMenu", (props = {}) => node("DropdownMenu", props));
  define("DropdownMenuEntry", (props = {}) => ({ ...props }));
  define("PopupMenuButton", (props = {}) => node("PopupMenuButton", props));
  define("PopupMenuItem", (props = {}) => node("PopupMenuItem", props));
  define("CheckedPopupMenuItem", (props = {}) => node("CheckedPopupMenuItem", props));
  define("PopupMenuDivider", (props = {}) => node("PopupMenuDivider", props));
  define("MenuBar", (first = {}, second = {}) => childrenNode("MenuBar", first, second));
  define("MenuAnchor", (first = {}, second = {}) => childNode("MenuAnchor", first, second));
  define("MenuItemButton", (first = {}, second = {}) => childNode("MenuItemButton", first, second));
  define("CheckboxMenuButton", (first = {}, second = {}) => childNode("CheckboxMenuButton", first, second));
  define("RadioMenuButton", (first = {}, second = {}) => childNode("RadioMenuButton", first, second));
  define("SubmenuButton", (props = {}) => node("SubmenuButton", props));
  define("LinearProgressIndicator", (props = {}) => node("LinearProgressIndicator", props));
  define("CircularProgressIndicator", adaptiveNode("CircularProgressIndicator"));
  define("RefreshIndicator", adaptiveChildNode("RefreshIndicator"));
  define("AlertDialog", adaptiveNode("AlertDialog"));
  const dialog = (first = {}, second = {}) => childNode("Dialog", first, second);
  dialog.fullscreen = (first = {}, second = {}) => childNode("Dialog", first, { ...second, fullscreen: true });
  define("Dialog", dialog);
  define("BottomSheet", (first = {}, second = {}) => childNode("BottomSheet", first, second));
  define("SimpleDialog", (props = {}) => node("SimpleDialog", props));
  define("SnackBar", (first = {}, second = {}) => childNode("SnackBar", first, second));
  define("SnackBarAction", (props = {}) => ({ ...props }));
  define("DatePickerDialog", (props = {}) => node("DatePickerDialog", props));
  define("TimePickerDialog", (props = {}) => node("TimePickerDialog", props));
  define("SearchBar", (props = {}) => node("SearchBar", props));
  define("SearchAnchor", (first = {}, second = {}) => childNode("SearchAnchor", first, second));
  define("NavigationBar", (props = {}) => node("NavigationBar", props));
  define("NavigationDestination", (props = {}) => node("NavigationDestination", props));
  define("NavigationRail", (props = {}) => node("NavigationRail", props));
  define("NavigationRailDestination", (props = {}) => node("NavigationRailDestination", props));
  define("NavigationDrawer", (first = {}, second = {}) => childrenNode("NavigationDrawer", first, second));
  define("NavigationDrawerDestination", (props = {}) => node("NavigationDrawerDestination", props));
  define("BottomNavigationBar", (props = {}) => node("BottomNavigationBar", props));
  define("BottomNavigationBarItem", (props = {}) => node("BottomNavigationBarItem", props));
  define("BottomAppBar", (first = {}, second = {}) => childNode("BottomAppBar", first, second));
  define("DefaultTabController", (first = {}, second = {}) => childNode("DefaultTabController", first, second));
  define("TabBar", (props = {}) => node("TabBar", props));
  define("TabBarView", (first = {}, second = {}) => childrenNode("TabBarView", first, second));
  define("Tab", (props = {}) => node("Tab", props));
  define("Stepper", (props = {}) => node("Stepper", props));
  define("Step", (props = {}) => node("Step", props));
  define("DataTable", (props = {}) => node("DataTable", props));
  define("DataColumn", (props = {}) => node("DataColumn", props));
  define("DataRow", (props = {}) => node("DataRow", props));
  define("DataCell", (props = {}) => node("DataCell", props));
  define("Table", (props = {}) => node("Table", props));
  define("TableRow", (props = {}) => node("TableRow", props));
  define("CarouselView", (first = {}, second = {}) => childrenNode("CarouselView", first, second));

  define("CupertinoApp", (props = {}) => node("CupertinoApp", props));
  define("CupertinoPageScaffold", (props = {}) => node("CupertinoPageScaffold", props));
  define("CupertinoNavigationBar", (props = {}) => node("CupertinoNavigationBar", props));
  define("CupertinoSliverNavigationBar", (props = {}) => node("CupertinoSliverNavigationBar", props));
  define("CupertinoNavigationBarBackButton", (props = {}) => node("CupertinoNavigationBarBackButton", props));
  define("CupertinoAlertDialog", (props = {}) => node("CupertinoAlertDialog", props));
  define("CupertinoActionSheet", (props = {}) => node("CupertinoActionSheet", props));
  define("CupertinoDialogAction", (first = {}, second = {}) => childNode("CupertinoDialogAction", first, second));
  define("CupertinoActionSheetAction", (first = {}, second = {}) => childNode("CupertinoActionSheetAction", first, second));
  define("CupertinoListSection", (first = {}, second = {}) => childrenNode("CupertinoListSection", first, second));
  define("CupertinoListTile", (props = {}) => node("CupertinoListTile", props));
  define("CupertinoListTileChevron", (props = {}) => node("CupertinoListTileChevron", props));
  define("CupertinoFormSection", (first = {}, second = {}) => childrenNode("CupertinoFormSection", first, second));
  define("CupertinoFormRow", (first = {}, second = {}) => childNode("CupertinoFormRow", first, second));
  define("CupertinoPicker", (first = {}, second = {}) => childrenNode("CupertinoPicker", first, second));
  define("CupertinoPickerDefaultSelectionOverlay", (props = {}) => node("CupertinoPickerDefaultSelectionOverlay", props));
  define("CupertinoDatePicker", (props = {}) => node("CupertinoDatePicker", props));
  define("CupertinoTimerPicker", (props = {}) => node("CupertinoTimerPicker", props));
  define("CupertinoSegmentedControl", (props = {}) => node("CupertinoSegmentedControl", props));
  define("CupertinoSlidingSegmentedControl", (props = {}) => node("CupertinoSlidingSegmentedControl", props));
  define("CupertinoSearchTextField", (props = {}) => node("CupertinoSearchTextField", props));
  define("CupertinoScrollbar", (first = {}, second = {}) => childNode("CupertinoScrollbar", first, second));
  define("CupertinoTabBar", (props = {}) => node("CupertinoTabBar", props));
  define("CupertinoButton", (first = {}, second = {}) => childNode("CupertinoButton", first, second));
  define("CupertinoSwitch", (props = {}) => node("CupertinoSwitch", props));
  define("CupertinoCheckbox", (props = {}) => node("CupertinoCheckbox", props));
  define("CupertinoRadio", (props = {}) => node("CupertinoRadio", props));
  define("CupertinoSlider", (props = {}) => node("CupertinoSlider", props));
  define("CupertinoActivityIndicator", (props = {}) => node("CupertinoActivityIndicator", props));
  define("CupertinoTextField", (props = {}) => node("CupertinoTextField", props));
  define("CupertinoTextFormFieldRow", (props = {}) => node("CupertinoTextFormFieldRow", props));

  define("EdgeInsets", {
    all: (value) => ({ all: value }),
    symmetric: (props = {}) => ({ ...props }),
    only: (props = {}) => ({ ...props }),
    zero: { all: 0 },
  });
  define("BorderRadius", {
    all: (value) => ({ all: value }),
    circular: (value) => ({ all: value }),
    only: (props = {}) => ({ ...props }),
    zero: { all: 0 },
  });
  define("BoxDecoration", (props = {}) => ({ ...props }));
  define("BoxConstraints", (props = {}) => ({ ...props }));
  define("Duration", (props = {}) => ({ ...props }));
  define("Color", (value) => value);
  define("Colors", {
    black: "#000000",
    white: "#ffffff",
    transparent: "#00000000",
    red: "#f44336",
    pink: "#e91e63",
    purple: "#9c27b0",
    deepPurple: "#673ab7",
    indigo: "#3f51b5",
    blue: "#2196f3",
    lightBlue: "#03a9f4",
    cyan: "#00bcd4",
    teal: "#009688",
    green: "#4caf50",
    lightGreen: "#8bc34a",
    lime: "#cddc39",
    yellow: "#ffeb3b",
    amber: "#ffc107",
    orange: "#ff9800",
    deepOrange: "#ff5722",
    brown: "#795548",
    grey: "#9e9e9e",
    blueGrey: "#607d8b",
  });
  define("Icons", new Proxy({}, { get: (_, name) => String(name) }));
})();
''';
