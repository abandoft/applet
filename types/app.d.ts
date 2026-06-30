declare module "@app/core" {
  export type AppletChild = AppletNode | string | number | boolean | null | undefined;
  export type AppletChildren = AppletChild | AppletChild[];
  export type AppletCallback<T = unknown> = (value: T) => void;
  export interface AppletActionDescriptor {
    type?: "Action" | "action";
    props?: { name?: string; payload?: unknown };
    action?: string;
    name?: string;
    payload?: unknown;
  }
  export type AppletActionLike<T = unknown> = string | AppletCallback<T> | AppletActionDescriptor;

  export interface AppletNode {
    type: string;
    props?: Record<string, unknown>;
    prop(name: string, value: unknown): AppletNode;
    props(values?: Record<string, unknown>): AppletNode;
    child(value: AppletChild): AppletNode;
    children(...items: AppletChildren[]): AppletNode;
    padding(value: EdgeInsetsLike): AppletNode;
    margin(value: EdgeInsetsLike): AppletNode;
    width(value: number): AppletNode;
    height(value: number): AppletNode;
    size(width: number, height?: number): AppletNode;
    align(value: AlignmentLike): AppletNode;
    background(value: ColorLike): AppletNode;
    backgroundColor(value: ColorLike): AppletNode;
    foregroundColor(value: ColorLike): AppletNode;
    color(value: ColorLike): AppletNode;
    radius(value: number | Record<string, number>): AppletNode;
    decoration(value: Record<string, unknown>): AppletNode;
    elevation(value: number): AppletNode;
    gap(value: number): AppletNode;
    runGap(value: number): AppletNode;
    main(value: MainAxisAlignmentLike): AppletNode;
    cross(value: CrossAxisAlignmentLike): AppletNode;
    stretch(): AppletNode;
    min(): AppletNode;
    expanded(flex?: number): AppletNode;
    flexible(flex?: number): AppletNode;
    onTap(handler: string | AppletCallback, payload?: unknown): AppletNode;
    onPressed(handler: string | AppletCallback, payload?: unknown): AppletNode;
    onChanged<T = unknown>(handler: string | AppletCallback<T>, payload?: unknown): AppletNode;
    fontSize(value: number): AppletNode;
    fontWeight(value: string | number): AppletNode;
    bold(): AppletNode;
    textColor(value: ColorLike): AppletNode;
    style(value?: TextStyleLike): AppletNode;
    maxLines(value: number): AppletNode;
    overflow(value: "clip" | "fade" | "ellipsis" | "visible"): AppletNode;
    icon(value: string): AppletNode;
  }

  export interface StateRef<T> {
    value: T;
    set(next: T | ((current: T) => T)): StateRef<T>;
    update(reducer: (current: T, payload?: unknown) => T): StateRef<T>;
    toggle(): StateRef<T>;
    action(next?: T | ((current: T, payload?: unknown) => T)): AppletNode;
    toJSON(): T;
  }

  export function State<T>(initial: T | (() => T)): StateRef<T>;
  export namespace State {
    function key<T>(key: string, initial: T | (() => T)): StateRef<T>;
  }
  export const Remember: typeof State;

  export const Applet: {
    state: Record<string, unknown>;
    initialState(defaults?: Record<string, unknown>): Record<string, unknown>;
    setState(patch: Record<string, unknown> | string, value?: unknown): null;
    update(patch: Record<string, unknown> | string, value?: unknown): null;
    refresh(): null;
    log(...items: unknown[]): void;
    defineApp(render: Function): void;
    onAction(name: string, handler: Function): string;
    action(name: string, payload?: unknown): AppletNode;
    callback(handler: Function, payload?: unknown): AppletNode;
    widget(type: string, props?: Record<string, unknown>): AppletNode;
    children(...items: AppletChildren[]): AppletChild[];
  };

  export function Action(value: string | Function, payload?: unknown): AppletNode;
  export function For<T>(items: T[], render: (item: T, index: number) => AppletChildren): AppletChild[];
  export function Show(condition: unknown, view: AppletChild): AppletChild | null;
  export function Children(...items: AppletChildren[]): AppletChild[];

  export type ColorSchemeRoleLike =
    | "primary" | "onPrimary" | "primaryContainer" | "onPrimaryContainer"
    | "primaryFixed" | "primaryFixedDim" | "onPrimaryFixed" | "onPrimaryFixedVariant"
    | "secondary" | "onSecondary" | "secondaryContainer" | "onSecondaryContainer"
    | "secondaryFixed" | "secondaryFixedDim" | "onSecondaryFixed" | "onSecondaryFixedVariant"
    | "tertiary" | "onTertiary" | "tertiaryContainer" | "onTertiaryContainer"
    | "tertiaryFixed" | "tertiaryFixedDim" | "onTertiaryFixed" | "onTertiaryFixedVariant"
    | "error" | "onError" | "errorContainer" | "onErrorContainer"
    | "surface" | "onSurface" | "surfaceVariant" | "onSurfaceVariant"
    | "surfaceDim" | "surfaceBright" | "surfaceContainerLowest" | "surfaceContainerLow"
    | "surfaceContainer" | "surfaceContainerHigh" | "surfaceContainerHighest"
    | "inversePrimary" | "inverseSurface" | "onInverseSurface"
    | "outline" | "outlineVariant" | "shadow" | "scrim"
    | "scaffoldBackground" | "scaffoldBackgroundColor" | "canvas" | "canvasColor"
    | "card" | "cardColor" | "divider" | "dividerColor" | "disabled" | "disabledColor"
    | "focus" | "focusColor" | "hover" | "hoverColor" | "highlight" | "highlightColor"
    | "splash" | "splashColor" | "hint" | "hintColor"
    | string;
  export type ColorLike = string | number | {
    value?: ColorLike;
    color?: ColorLike;
    hex?: ColorLike;
    theme?: ColorSchemeRoleLike;
    colorScheme?: ColorSchemeRoleLike;
    role?: ColorSchemeRoleLike;
    token?: ColorSchemeRoleLike;
    opacity?: number;
    alpha?: number;
  };
  export type EdgeInsetsLike = number | [number, number] | [number, number, number, number] | {
    all?: number; left?: number; top?: number; right?: number; bottom?: number; start?: number; end?: number; horizontal?: number; vertical?: number;
  };
  export type OffsetLike = [number, number] | { dx?: number; dy?: number; x?: number; y?: number; width?: number; height?: number };
  export type AlignmentLike = string | [number, number] | { x?: number; y?: number };
  export type MainAxisAlignmentLike = "start" | "end" | "center" | "spaceBetween" | "spaceAround" | "spaceEvenly";
  export type CrossAxisAlignmentLike = "start" | "end" | "center" | "stretch" | "baseline";
  export type LocaleLike = string | { languageCode?: string; language?: string; scriptCode?: string; script?: string; countryCode?: string; country?: string };
  export type TextDecorationLike = "none" | "underline" | "lineThrough" | "line-through" | "line_through" | "overline" | TextDecorationLike[];
  export type TextDecorationStyleLike = "solid" | "double" | "dotted" | "dashed" | "wavy";
  export type TextBaselineLike = "alphabetic" | "ideographic";
  export type TextLeadingDistributionLike = "proportional" | "even";
  export type TextOverflowLike = "clip" | "fade" | "ellipsis" | "visible";
  export type PaintLike = ColorLike | { color?: ColorLike; style?: "fill" | "stroke"; strokeWidth?: number };
  export interface TextShadowLike {
    color?: ColorLike;
    offset?: [number, number] | { dx?: number; dy?: number; x?: number; y?: number; width?: number; height?: number };
    dx?: number;
    dy?: number;
    x?: number;
    y?: number;
    blurRadius?: number;
    blur?: number;
  }
  export type FontFeatureLike = string | { feature?: string; tag?: string; name?: string; value?: number; enabled?: boolean };
  export interface FontVariationLike {
    axis?: string;
    tag?: string;
    name?: string;
    value?: number;
  }
  export interface LayoutBreakpoint {
    minWidth?: number;
    maxWidth?: number;
    minHeight?: number;
    maxHeight?: number;
    orientation?: "portrait" | "landscape";
    child?: AppletChild;
    view?: AppletChild;
    layout?: AppletChild;
    content?: AppletChild;
    default?: boolean;
  }
  export interface LayoutBuilderProps {
    compact?: AppletChild;
    small?: AppletChild;
    mobile?: AppletChild;
    medium?: AppletChild;
    tablet?: AppletChild;
    expanded?: AppletChild;
    wide?: AppletChild;
    large?: AppletChild;
    extraLarge?: AppletChild;
    xlarge?: AppletChild;
    xl?: AppletChild;
    breakpoints?: LayoutBreakpoint[] | Record<string, AppletChild>;
    variants?: LayoutBreakpoint[] | Record<string, AppletChild>;
    layouts?: LayoutBreakpoint[] | Record<string, AppletChild>;
    child?: AppletChild;
    fallback?: AppletChild;
    default?: AppletChild;
  }
  export interface AdaptiveTwoPaneProps {
    compact?: AppletChild;
    single?: AppletChild;
    child?: AppletChild;
    primary?: AppletChild;
    first?: AppletChild;
    one?: AppletChild;
    left?: AppletChild;
    start?: AppletChild;
    secondary?: AppletChild;
    second?: AppletChild;
    two?: AppletChild;
    right?: AppletChild;
    end?: AppletChild;
    breakpoint?: number;
    minWidth?: number;
    twoPaneWidth?: number;
    mediumWidth?: number;
    duration?: LayoutDurationLike;
    animationDuration?: LayoutDurationLike;
    primaryFlex?: number;
    firstFlex?: number;
    secondaryFlex?: number;
    secondFlex?: number;
  }
  export type ValidationRule =
    | boolean
    | string
    | {
        type?: "required" | "notEmpty" | "minLength" | "maxLength" | "length" | "email" | "pattern" | "regex" | "min" | "max" | "equals";
        required?: boolean;
        email?: boolean;
        minLength?: number;
        maxLength?: number;
        length?: number;
        pattern?: string;
        regex?: string;
        min?: number;
        max?: number;
        value?: unknown;
        message?: string;
        requiredMessage?: string;
        emailMessage?: string;
        minLengthMessage?: string;
        maxLengthMessage?: string;
        patternMessage?: string;
        rules?: ValidationRule[];
        validators?: ValidationRule[];
      };
  export type TextThemeStyleLike =
    | "displayLarge"
    | "displayMedium"
    | "displaySmall"
    | "headlineLarge"
    | "headlineMedium"
    | "headlineSmall"
    | "titleLarge"
    | "titleMedium"
    | "titleSmall"
    | "labelLarge"
    | "labelMedium"
    | "labelSmall"
    | "bodyLarge"
    | "bodyMedium"
    | "bodySmall"
    | string;
  export interface TextStyleLike {
    theme?: TextThemeStyleLike;
    themeStyle?: TextThemeStyleLike;
    textTheme?: TextThemeStyleLike;
    token?: TextThemeStyleLike;
    styleName?: TextThemeStyleLike;
    name?: TextThemeStyleLike;
    inherit?: boolean;
    color?: ColorLike;
    backgroundColor?: ColorLike;
    fontSize?: number;
    size?: number;
    fontFamily?: string;
    family?: string;
    fontFamilyFallback?: string[];
    fallback?: string | string[];
    package?: string;
    fontWeight?: string | number;
    weight?: string | number;
    fontStyle?: "normal" | "italic";
    height?: number;
    letterSpacing?: number;
    wordSpacing?: number;
    textBaseline?: TextBaselineLike;
    baseline?: TextBaselineLike;
    leadingDistribution?: TextLeadingDistributionLike;
    locale?: LocaleLike;
    foreground?: PaintLike;
    background?: PaintLike;
    shadows?: TextShadowLike | TextShadowLike[];
    shadow?: TextShadowLike | ColorLike;
    fontFeatures?: FontFeatureLike | FontFeatureLike[];
    features?: FontFeatureLike | FontFeatureLike[];
    fontVariations?: FontVariationLike | FontVariationLike[];
    variations?: FontVariationLike | FontVariationLike[];
    decoration?: TextDecorationLike;
    decorationColor?: ColorLike;
    decorationStyle?: TextDecorationStyleLike;
    decorationThickness?: number;
    debugLabel?: string;
    overflow?: TextOverflowLike;
  }

  export interface ButtonStyleLike {
    textStyle?: TextStyleLike;
    style?: TextStyleLike;
    foregroundColor?: ColorLike;
    backgroundColor?: ColorLike;
    overlayColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    shadowColor?: ColorLike;
    elevation?: number;
    padding?: EdgeInsetsLike;
    minimumSize?: number | [number, number] | { width?: number; height?: number };
    fixedSize?: number | [number, number] | { width?: number; height?: number };
    maximumSize?: number | [number, number] | { width?: number; height?: number };
    iconColor?: ColorLike;
    iconSize?: number;
    iconAlignment?: "start" | "end" | "leading" | "trailing";
    side?: ColorLike | { color?: ColorLike; width?: number };
    shape?: Record<string, unknown>;
    borderRadius?: number | Record<string, number>;
    visualDensity?: VisualDensityLike;
    tapTargetSize?: "padded" | "shrinkWrap" | "shrink_wrap" | "shrink-wrap";
    materialTapTargetSize?: "padded" | "shrinkWrap" | "shrink_wrap" | "shrink-wrap";
    animationDuration?: number | Record<string, number>;
    enableFeedback?: boolean;
    alignment?: AlignmentLike;
  }

  export interface MenuStyleLike {
    backgroundColor?: WidgetStatePropertyLike<ColorLike>;
    color?: WidgetStatePropertyLike<ColorLike>;
    shadowColor?: WidgetStatePropertyLike<ColorLike>;
    surfaceTintColor?: WidgetStatePropertyLike<ColorLike>;
    elevation?: WidgetStatePropertyLike<number>;
    padding?: WidgetStatePropertyLike<EdgeInsetsLike>;
    minimumSize?: WidgetStatePropertyLike<number | [number, number] | { width?: number; height?: number }>;
    fixedSize?: WidgetStatePropertyLike<number | [number, number] | { width?: number; height?: number }>;
    maximumSize?: WidgetStatePropertyLike<number | [number, number] | { width?: number; height?: number }>;
    side?: WidgetStatePropertyLike<ColorLike | { color?: ColorLike; width?: number }>;
    shape?: WidgetStatePropertyLike<ShapeBorderLike>;
    borderRadius?: number | Record<string, number>;
    mouseCursor?: WidgetStatePropertyLike<MouseCursorLike>;
    cursor?: WidgetStatePropertyLike<MouseCursorLike>;
    visualDensity?: VisualDensityLike;
    alignment?: AlignmentLike;
  }

  export type FloatingLabelBehaviorLike = "never" | "auto" | "always";
  export type FloatingLabelAlignmentLike = "start" | "center";
  export type VisualDensityLike =
    | "standard"
    | "comfortable"
    | "compact"
    | "adaptive"
    | number
    | [number, number]
    | { horizontal?: number; vertical?: number; x?: number; y?: number };
  export type MouseCursorLike = "basic" | "default" | "click" | "pointer" | "text" | "forbidden" | "disabled" | "grab" | "grabbing" | "move" | "none";
  export type ClipLike = "none" | "hardEdge" | "hard_edge" | "antiAlias" | "anti_alias" | "antiAliasWithSaveLayer" | "anti_alias_with_save_layer";
  export type ShapeBorderLike = {
    shape?: "rounded" | "stadium" | "circle";
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    side?: ColorLike | { color?: ColorLike; width?: number };
  };
  export type AnimationStyleLike =
    | "none"
    | number
    | {
        curve?: "linear" | "ease" | "easeIn" | "easeOut" | "easeInOut" | "fastOutSlowIn" | "bounceOut" | "elasticOut";
        duration?: number | Record<string, number>;
        reverseCurve?: "linear" | "ease" | "easeIn" | "easeOut" | "easeInOut" | "fastOutSlowIn" | "bounceOut" | "elasticOut";
        reverseDuration?: number | Record<string, number>;
      };
  export type ChipAnimationStyleLike =
    | AnimationStyleLike
    | {
        enableAnimation?: AnimationStyleLike;
        enable?: AnimationStyleLike;
        selectAnimation?: AnimationStyleLike;
        select?: AnimationStyleLike;
        avatarDrawerAnimation?: AnimationStyleLike;
        avatarDrawer?: AnimationStyleLike;
        deleteDrawerAnimation?: AnimationStyleLike;
        deleteDrawer?: AnimationStyleLike;
      };
  export type BoxConstraintsLike = {
    minWidth?: number;
    maxWidth?: number;
    minHeight?: number;
    maxHeight?: number;
    width?: number;
    height?: number;
  };
  export type MaterialTapTargetSizeLike = "padded" | "shrinkWrap" | "shrink_wrap" | "shrink-wrap";
  export type TargetPlatformLike = "android" | "fuchsia" | "ios" | "linux" | "macos" | "windows";
  export type WidgetStatePropertyLike<T> =
    | T
    | {
        selected?: T;
        disabled?: T;
        hovered?: T;
        focused?: T;
        pressed?: T;
        dragged?: T;
        error?: T;
        scrolledUnder?: T;
        scrolled_under?: T;
        default?: T;
        all?: T;
        value?: T;
      };
  export type DragStartBehaviorLike = "start" | "down";
  export type SliderInteractionLike = "tapAndSlide" | "tap_and_slide" | "tap-slide" | "tapOnly" | "tap_only" | "tap" | "slideOnly" | "slide_only" | "slide" | "slideThumb" | "slide_thumb" | "thumb";
  export type ShowValueIndicatorLike = "never" | "onlyForDiscrete" | "only_for_discrete" | "discrete" | "onlyForContinuous" | "only_for_continuous" | "continuous" | "always" | "onDrag" | "on_drag" | "alwaysVisible" | "always_visible";
  export type InputBorderLike =
    | "none"
    | "outline"
    | "outlined"
    | "underline"
    | {
        type?: "none" | "outline" | "outlined" | "underline";
        shape?: "none" | "outline" | "outlined" | "underline";
        border?: "none" | "outline" | "outlined" | "underline";
        color?: ColorLike;
        width?: number;
        borderSide?: ColorLike | { color?: ColorLike; width?: number };
        side?: ColorLike | { color?: ColorLike; width?: number };
        borderRadius?: number | Record<string, number>;
        radius?: number | Record<string, number>;
        gapPadding?: number;
      };
  export interface InputDecorationProps {
    icon?: AppletChild;
    iconColor?: ColorLike;
    label?: AppletChild | string;
    labelWidget?: AppletChild;
    labelText?: string;
    labelStyle?: TextStyleLike;
    floatingLabelStyle?: TextStyleLike;
    helper?: AppletChild | string;
    helperWidget?: AppletChild;
    helperText?: string;
    helperStyle?: TextStyleLike;
    helperMaxLines?: number;
    hint?: AppletChild | string;
    hintWidget?: AppletChild;
    hintText?: string;
    hintStyle?: TextStyleLike;
    hintTextDirection?: "ltr" | "rtl";
    hintMaxLines?: number;
    hintFadeDuration?: number | Record<string, number>;
    maintainHintSize?: boolean;
    maintainLabelSize?: boolean;
    error?: AppletChild | string;
    errorWidget?: AppletChild;
    errorText?: string;
    errorStyle?: TextStyleLike;
    errorMaxLines?: number;
    floatingLabelBehavior?: FloatingLabelBehaviorLike;
    floatingLabelAlignment?: FloatingLabelAlignmentLike;
    isCollapsed?: boolean;
    isDense?: boolean;
    contentPadding?: EdgeInsetsLike;
    prefixIcon?: AppletChild;
    prefixIconConstraints?: number | { minWidth?: number; maxWidth?: number; minHeight?: number; maxHeight?: number; width?: number; height?: number };
    prefix?: AppletChild;
    prefixText?: string;
    prefixStyle?: TextStyleLike;
    prefixIconColor?: ColorLike;
    suffixIcon?: AppletChild;
    suffix?: AppletChild;
    suffixText?: string;
    suffixStyle?: TextStyleLike;
    suffixIconColor?: ColorLike;
    suffixIconConstraints?: number | { minWidth?: number; maxWidth?: number; minHeight?: number; maxHeight?: number; width?: number; height?: number };
    counter?: AppletChild;
    counterText?: string;
    counterStyle?: TextStyleLike;
    filled?: boolean;
    fillColor?: ColorLike;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    errorBorder?: InputBorderLike;
    focusedBorder?: InputBorderLike;
    focusedErrorBorder?: InputBorderLike;
    disabledBorder?: InputBorderLike;
    enabledBorder?: InputBorderLike;
    border?: InputBorderLike;
    enabled?: boolean;
    semanticCounterText?: string;
    alignLabelWithHint?: boolean;
    constraints?: number | { minWidth?: number; maxWidth?: number; minHeight?: number; maxHeight?: number; width?: number; height?: number };
    visualDensity?: VisualDensityLike;
    activeIndicatorBorder?: ColorLike | { color?: ColorLike; width?: number };
    outlineBorder?: ColorLike | { color?: ColorLike; width?: number };
  }

  export interface ThemeDataProps {
    useMaterial3?: boolean;
    useSystemColors?: boolean;
    applyElevationOverlayColor?: boolean;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    platform?: TargetPlatformLike;
    visualDensity?: VisualDensityLike;
    brightness?: "light" | "dark";
    seedColor?: ColorLike;
    colorSchemeSeed?: ColorLike;
    colorScheme?: Record<string, unknown>;
    scaffoldBackgroundColor?: ColorLike;
    canvasColor?: ColorLike;
    cardColor?: ColorLike;
    dividerColor?: ColorLike;
    primaryColor?: ColorLike;
    primaryColorDark?: ColorLike;
    primaryColorLight?: ColorLike;
    secondaryHeaderColor?: ColorLike;
    shadowColor?: ColorLike;
    unselectedWidgetColor?: ColorLike;
    fontFamily?: string;
    fontFamilyFallback?: string[];
    fallback?: string[];
    actionIconTheme?: Record<string, unknown>;
    iconTheme?: Record<string, unknown>;
    primaryIconTheme?: Record<string, unknown>;
    textTheme?: Record<string, TextStyleLike>;
    primaryTextTheme?: Record<string, TextStyleLike>;
    appBarTheme?: Record<string, unknown>;
    bottomAppBarTheme?: Record<string, unknown>;
    bottomNavigationBarTheme?: Record<string, unknown>;
    bottomSheetTheme?: Record<string, unknown>;
    buttonTheme?: Record<string, unknown>;
    badgeTheme?: Record<string, unknown>;
    bannerTheme?: Record<string, unknown>;
    materialBannerTheme?: Record<string, unknown>;
    cardTheme?: Record<string, unknown>;
    carouselViewTheme?: Record<string, unknown>;
    chipTheme?: Record<string, unknown>;
    dataTableTheme?: Record<string, unknown>;
    datePickerTheme?: Record<string, unknown>;
    dialogTheme?: Record<string, unknown>;
    dividerTheme?: Record<string, unknown>;
    drawerTheme?: Record<string, unknown>;
    elevatedButtonTheme?: { style?: ButtonStyleLike } | ButtonStyleLike;
    filledButtonTheme?: { style?: ButtonStyleLike } | ButtonStyleLike;
    floatingActionButtonTheme?: Record<string, unknown>;
    iconButtonTheme?: { style?: ButtonStyleLike } | ButtonStyleLike;
    inputDecorationTheme?: InputDecorationProps;
    listTileTheme?: Record<string, unknown>;
    navigationBarTheme?: Record<string, unknown>;
    navigationDrawerTheme?: Record<string, unknown>;
    navigationRailTheme?: Record<string, unknown>;
    outlinedButtonTheme?: { style?: ButtonStyleLike } | ButtonStyleLike;
    searchBarTheme?: Record<string, unknown>;
    searchViewTheme?: Record<string, unknown>;
    scrollbarTheme?: Record<string, unknown>;
    snackBarTheme?: Record<string, unknown>;
    tabBarTheme?: Record<string, unknown>;
    textButtonTheme?: { style?: ButtonStyleLike } | ButtonStyleLike;
    textSelectionTheme?: Record<string, unknown>;
    timePickerTheme?: Record<string, unknown>;
    toggleButtonsTheme?: Record<string, unknown>;
    tooltipTheme?: Record<string, unknown>;
  }
}

declare module "@app/widgets" {
  export * from "@app/core";
  import type {
    AlignmentLike,
    AppletActionLike,
    AppletCallback,
    AppletChild,
    AppletChildren,
    AppletNode,
    BoxConstraintsLike,
    BoxShadowLike,
    ButtonStyleLike,
    ColorLike,
    DragStartBehaviorLike,
    EdgeInsetsLike,
    LocaleLike,
    MouseCursorLike,
    TextLeadingDistributionLike,
    TextOverflowLike,
    TextShadowLike,
    TextStyleLike,
    ThemeDataProps,
  } from "@app/core";

  export type TextDataLike = string | number | boolean;
  export type TextAlignLike = "left" | "right" | "center" | "justify" | "start" | "end";
  export type TextWidthBasisLike = "parent" | "longestLine" | "longest_line" | "longest-line";
  export type TextScalerLike = number | "none" | "noScaling" | "no_scaling" | "no-scaling" | {
    type?: "none" | "noScaling" | "no_scaling" | "no-scaling" | "linear";
    mode?: "none" | "noScaling" | "no_scaling" | "no-scaling" | "linear";
    scale?: number;
    factor?: number;
    linear?: number;
    value?: number;
    textScaleFactor?: number;
  };
  export type TextScrollPhysicsLike = "always" | "never" | "bouncing" | "clamping" | "page";
  export type TextSelectionControlsLike =
    | "adaptive"
    | "auto"
    | "platform"
    | "empty"
    | "none"
    | "disabled"
    | "material"
    | "materialHandle"
    | "materialHandles"
    | "materialLegacy"
    | "desktop"
    | "desktopHandle"
    | "desktopHandles"
    | "desktopLegacy"
    | "cupertino"
    | "cupertinoHandle"
    | "cupertinoHandles"
    | "cupertinoLegacy"
    | "cupertinoDesktop"
    | "cupertinoDesktopHandle"
    | "cupertinoDesktopHandles"
    | "cupertinoDesktopLegacy"
    | "android"
    | "fuchsia"
    | "linux"
    | "windows"
    | "ios"
    | "macos";
  export type TextMagnifierConfigurationLike =
    | boolean
    | "adaptive"
    | "auto"
    | "platform"
    | "enabled"
    | "disabled"
    | "none"
    | "off";
  export type TextSelectionBoxHeightStyleLike =
    | "tight"
    | "max"
    | "includeLineSpacingMiddle"
    | "include_line_spacing_middle"
    | "middle"
    | "includeLineSpacingTop"
    | "include_line_spacing_top"
    | "top"
    | "includeLineSpacingBottom"
    | "include_line_spacing_bottom"
    | "bottom"
    | "strut";
  export type TextSelectionBoxWidthStyleLike = "tight" | "max";
  export interface TextSelectionPayload {
    baseOffset: number;
    extentOffset: number;
    start: number;
    end: number;
    isCollapsed: boolean;
    isValid: boolean;
    isNormalized: boolean;
    isDirectional: boolean;
    affinity: "upstream" | "downstream";
    cause?: "tap" | "doubleTap" | "longPress" | "forcePress" | "keyboard" | "toolbar" | "drag" | "stylusHandwriting" | null;
  }
  export type TextRadiusLike = number | { x?: number; y?: number; radius?: number; horizontal?: number; vertical?: number };
  export type TextHeightBehaviorLike = "normal" | "default" | "none" | "disabled" | "trim" | {
    applyHeightToFirstAscent?: boolean;
    firstAscent?: boolean;
    first?: boolean;
    applyHeightToLastDescent?: boolean;
    lastDescent?: boolean;
    last?: boolean;
    leadingDistribution?: TextLeadingDistributionLike;
  };
  export type StrutStyleLike = "disabled" | "none" | {
    fontFamily?: string;
    family?: string;
    fontFamilyFallback?: string[];
    fallback?: string | string[];
    fontSize?: number;
    size?: number;
    height?: number;
    leadingDistribution?: TextLeadingDistributionLike;
    leading?: number;
    fontWeight?: string | number;
    weight?: string | number;
    fontStyle?: "normal" | "italic";
    style?: "normal" | "italic";
    forceStrutHeight?: boolean;
    debugLabel?: string;
    package?: string;
  };
  export interface TextProps {
    data?: TextDataLike;
    text?: TextDataLike;
    style?: TextStyleLike;
    strutStyle?: StrutStyleLike;
    textAlign?: TextAlignLike;
    textDirection?: WidgetTextDirectionLike;
    locale?: LocaleLike;
    textScaler?: TextScalerLike;
    textScaleFactor?: number;
    overflow?: TextOverflowLike;
    maxLines?: number;
    softWrap?: boolean;
    semanticsLabel?: string;
    semanticLabel?: string;
    semanticsIdentifier?: string;
    textWidthBasis?: TextWidthBasisLike;
    textHeightBehavior?: TextHeightBehaviorLike;
    selectionColor?: ColorLike;
  }
  export interface SelectableTextProps extends TextProps {
    minLines?: number;
    autofocus?: boolean;
    showCursor?: boolean;
    cursorWidth?: number;
    cursorHeight?: number;
    cursorRadius?: TextRadiusLike;
    cursorColor?: ColorLike;
    enableInteractiveSelection?: boolean;
    selectionHeightStyle?: TextSelectionBoxHeightStyleLike;
    selectionWidthStyle?: TextSelectionBoxWidthStyleLike;
    dragStartBehavior?: DragStartBehaviorLike;
    physics?: TextScrollPhysicsLike;
    scrollPhysics?: TextScrollPhysicsLike;
    scrollable?: boolean;
    selectionControls?: TextSelectionControlsLike;
    controls?: TextSelectionControlsLike;
    contextMenu?: boolean | "enabled" | "disabled" | "none" | "off";
    contextMenuBuilder?: boolean | "enabled" | "disabled" | "none" | "off";
    showContextMenu?: boolean;
    toolbar?: boolean | "enabled" | "disabled" | "none" | "off";
    showToolbar?: boolean;
    magnifier?: TextMagnifierConfigurationLike;
    magnifierConfiguration?: TextMagnifierConfigurationLike;
    enableMagnifier?: TextMagnifierConfigurationLike;
    onSelectionChanged?: AppletActionLike<TextSelectionPayload>;
    onSelection?: AppletActionLike<TextSelectionPayload>;
    onTap?: AppletActionLike<void>;
  }
  export type TextSpanLike = TextDataLike | TextSpanProps | TextSpanLike[];
  export interface TextSpanProps {
    data?: TextDataLike;
    text?: TextDataLike;
    style?: TextStyleLike;
    children?: TextSpanLike[];
    semanticsLabel?: string;
    semanticLabel?: string;
    semanticsIdentifier?: string;
    locale?: LocaleLike;
    spellOut?: boolean;
  }
  export interface RichTextProps {
    text?: TextSpanLike;
    span?: TextSpanLike;
    textAlign?: TextAlignLike;
    textDirection?: WidgetTextDirectionLike;
    softWrap?: boolean;
    overflow?: TextOverflowLike;
    textScaler?: TextScalerLike;
    textScaleFactor?: number;
    maxLines?: number;
    locale?: LocaleLike;
    strutStyle?: StrutStyleLike;
    textWidthBasis?: TextWidthBasisLike;
    textHeightBehavior?: TextHeightBehaviorLike;
    selectionColor?: ColorLike;
  }
  export function Text(data?: TextDataLike, props?: TextProps): AppletNode;
  export function SelectableText(data?: TextDataLike, props?: SelectableTextProps): AppletNode;
  export function RichText(props?: RichTextProps): AppletNode;
  export function TextSpan(text?: TextDataLike, props?: TextSpanProps): TextSpanProps;
  export function TextStyle(props?: TextStyleLike): TextStyleLike;
  export type WidgetDurationLike = number | Record<string, number>;
  export type WidgetCurveLike = "linear" | "ease" | "easeIn" | "ease_in" | "easeOut" | "ease_out" | "easeInOut" | "ease_in_out" | "fastOutSlowIn" | "fast_out_slow_in" | "bounceOut" | "bounce_out" | "elasticOut" | "elastic_out";
  export interface AnimatedDefaultTextStyleProps {
    child?: AppletChild;
    style?: TextStyleLike;
    textAlign?: string;
    softWrap?: boolean;
    overflow?: "clip" | "fade" | "ellipsis" | "visible";
    maxLines?: number;
    duration?: WidgetDurationLike;
    curve?: WidgetCurveLike;
    onEnd?: string | ((value: void) => void);
  }
  export function AnimatedDefaultTextStyle(first?: AppletChild | AnimatedDefaultTextStyleProps, second?: AnimatedDefaultTextStyleProps): AppletNode;
  export interface IconProps {
    icon?: string;
    name?: string;
    size?: number;
    fill?: number;
    weight?: number;
    grade?: number;
    opticalSize?: number;
    color?: ColorLike;
    shadows?: TextShadowLike | TextShadowLike[];
    shadow?: TextShadowLike | ColorLike;
    semanticLabel?: string;
    semanticsLabel?: string;
    textDirection?: WidgetTextDirectionLike;
    applyTextScaling?: boolean;
    blendMode?: BlendMode;
    fontWeight?: string | number;
  }
  export function Icon(icon: string, props?: IconProps): AppletNode;
  export type ImageFit = "fill" | "contain" | "cover" | "fitWidth" | "fitHeight" | "none" | "scaleDown";
  export type ImageRepeat = "noRepeat" | "repeat" | "repeatX" | "repeatY" | "none" | "no-repeat" | "repeat-x" | "repeat-y";
  export type FilterQuality = "none" | "low" | "medium" | "high";
  export type BlendMode =
    | "clear" | "src" | "dst" | "srcOver" | "dstOver" | "srcIn" | "dstIn" | "srcOut" | "dstOut"
    | "srcATop" | "dstATop" | "xor" | "plus" | "modulate" | "screen" | "overlay" | "darken" | "lighten"
    | "colorDodge" | "colorBurn" | "hardLight" | "softLight" | "difference" | "exclusion" | "multiply"
    | "hue" | "saturation" | "color" | "luminosity";
  export type RectLike = [number, number, number, number] | { left?: number; top?: number; right?: number; bottom?: number; x?: number; y?: number; width?: number; height?: number };
  export type ImageBytes = string | number[];
  export interface ImageProps {
    src?: string;
    url?: string;
    asset?: string;
    bytes?: ImageBytes;
    base64?: string;
    dataUri?: string;
    source?: "network" | "asset" | "memory";
    scale?: number;
    assetScale?: number;
    width?: number;
    height?: number;
    cacheWidth?: number;
    cacheHeight?: number;
    decodeWidth?: number;
    decodeHeight?: number;
    headers?: Record<string, string | number | boolean>;
    package?: string;
    semanticLabel?: string;
    semanticsLabel?: string;
    excludeFromSemantics?: boolean;
    color?: ColorLike;
    opacity?: number;
    colorBlendMode?: BlendMode;
    fit?: ImageFit;
    alignment?: AlignmentLike;
    repeat?: ImageRepeat;
    centerSlice?: RectLike;
    matchTextDirection?: boolean;
    gaplessPlayback?: boolean;
    isAntiAlias?: boolean;
    filterQuality?: FilterQuality;
    loading?: AppletChild;
    placeholder?: AppletChild;
    error?: AppletChild;
    fallback?: AppletChild;
  }
  export interface ImageFactory {
    (src: string, props?: ImageProps): AppletNode;
    network(src: string, props?: ImageProps): AppletNode;
    asset(asset: string, props?: ImageProps): AppletNode;
    memory(bytes: ImageBytes, props?: ImageProps): AppletNode;
    base64(base64: string, props?: ImageProps): AppletNode;
  }
  export const Image: ImageFactory;
  export type TileMode = "clamp" | "repeated" | "repeat" | "mirror" | "mirrored" | "decal";
  export type BlurStyle = "normal" | "solid" | "outer" | "inner";
  export interface GradientLike {
    type?: "linear" | "radial" | "sweep";
    colors: ColorLike[];
    stops?: number[];
    begin?: AlignmentLike;
    end?: AlignmentLike;
    center?: AlignmentLike;
    radius?: number;
    focal?: AlignmentLike;
    focalRadius?: number;
    startAngle?: number;
    endAngle?: number;
    tileMode?: TileMode;
  }
  export interface DecorationImageLike extends ImageProps {
    tintColor?: ColorLike;
    blendMode?: BlendMode;
    colorFilter?: ColorLike | { color?: ColorLike; mode?: BlendMode; blendMode?: BlendMode };
    invertColors?: boolean;
  }
  export interface BoxShadowLike {
    color?: ColorLike;
    offset?: [number, number] | { dx?: number; dy?: number; x?: number; y?: number; width?: number; height?: number };
    dx?: number;
    dy?: number;
    x?: number;
    y?: number;
    blurRadius?: number;
    blur?: number;
    spreadRadius?: number;
    spread?: number;
    blurStyle?: BlurStyle;
  }
  export interface BoxDecorationProps {
    color?: ColorLike;
    image?: DecorationImageLike | string;
    decorationImage?: DecorationImageLike | string;
    backgroundImage?: DecorationImageLike | string;
    border?: ColorLike | { color?: ColorLike; width?: number };
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    boxShadow?: BoxShadowLike | BoxShadowLike[];
    boxShadows?: BoxShadowLike | BoxShadowLike[];
    shadow?: BoxShadowLike | ColorLike;
    shadows?: BoxShadowLike | BoxShadowLike[];
    gradient?: GradientLike;
    backgroundBlendMode?: BlendMode;
    blendMode?: BlendMode;
    shape?: "rectangle" | "rect" | "circle";
  }
  export type WidgetTextDirectionLike = "ltr" | "rtl" | "leftToRight" | "left_to_right" | "rightToLeft" | "right_to_left";
  export type DecorationPositionLike = "background" | "foreground";
  export type TooltipTriggerModeLike = "manual" | "tap" | "longPress" | "long_press" | "long-press";
  export type WidgetSemanticsRoleLike = "dialog" | "alertDialog" | "alert_dialog" | "alert-dialog" | "alert" | "status" | "none";
  export interface PlaceholderProps {
    child?: AppletChild;
    color?: ColorLike;
    strokeWidth?: number;
    fallbackWidth?: number;
    fallbackHeight?: number;
  }
  export interface TooltipProps {
    child?: AppletChild;
    message?: string;
    text?: string;
    constraints?: BoxConstraintsLike;
    padding?: EdgeInsetsLike;
    margin?: EdgeInsetsLike;
    verticalOffset?: number;
    preferBelow?: boolean;
    excludeFromSemantics?: boolean;
    decoration?: BoxDecorationProps;
    textStyle?: TextStyleLike;
    style?: TextStyleLike;
    textAlign?: string;
    waitDuration?: WidgetDurationLike;
    showDuration?: WidgetDurationLike;
    exitDuration?: WidgetDurationLike;
    enableTapToDismiss?: boolean;
    triggerMode?: TooltipTriggerModeLike;
    enableFeedback?: boolean;
    onTriggered?: string | AppletCallback<void>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    ignorePointer?: boolean;
  }
  export interface HeroProps {
    child?: AppletChild;
    tag?: string | number;
    transitionOnUserGestures?: boolean;
    curve?: WidgetCurveLike;
    reverseCurve?: WidgetCurveLike;
  }
  export interface KeyEventPayload {
    type?: string;
    logicalKey?: string;
    logicalKeyLabel?: string;
    logicalKeyId?: number;
    physicalKey?: string;
    physicalKeyId?: number;
    character?: string | null;
    synthesized?: boolean;
  }
  export interface KeyboardListenerProps {
    child?: AppletChild;
    autofocus?: boolean;
    includeSemantics?: boolean;
    onKeyEvent?: AppletActionLike<KeyEventPayload>;
    onKey?: AppletActionLike<KeyEventPayload>;
  }
  export type ShortcutBindingsLike = Record<string, AppletActionLike<KeyEventPayload>>;
  export interface CallbackShortcutsProps {
    child?: AppletChild;
    bindings?: ShortcutBindingsLike;
    shortcuts?: ShortcutBindingsLike;
  }
  export type HitTestBehaviorLike = "deferToChild" | "defer_to_child" | "defer" | "opaque" | "translucent";
  export type DragAxisLike = "horizontal" | "vertical";
  export type DismissDirectionLike =
    | "horizontal"
    | "vertical"
    | "startToEnd"
    | "start_to_end"
    | "start-to-end"
    | "endToStart"
    | "end_to_start"
    | "end-to-start"
    | "up"
    | "down"
    | "none";
  export interface PointerEventPayload {
    pointer?: number;
    kind?: string;
    buttons?: number;
    x?: number;
    y?: number;
    dx?: number;
    dy?: number;
  }
  export interface ScaleStartPayload {
    x?: number;
    y?: number;
    localX?: number;
    localY?: number;
    pointerCount?: number;
  }
  export interface ScaleUpdatePayload extends ScaleStartPayload {
    scale?: number;
    horizontalScale?: number;
    verticalScale?: number;
    rotation?: number;
  }
  export interface ScaleEndPayload {
    velocityX?: number;
    velocityY?: number;
    scaleVelocity?: number;
    pointerCount?: number;
  }
  export interface DragUpdatePayload {
    x?: number;
    y?: number;
    localX?: number;
    localY?: number;
    dx?: number;
    dy?: number;
    primaryDelta?: number | null;
  }
  export interface DragEndPayload {
    velocityX?: number;
    velocityY?: number;
    x?: number;
    y?: number;
    wasAccepted?: boolean;
  }
  export interface DragCancelPayload {
    velocityX?: number;
    velocityY?: number;
    x?: number;
    y?: number;
  }
  export interface DragTargetPayload {
    data?: unknown;
    x?: number;
    y?: number;
  }
  export interface GestureDetectorProps {
    child?: AppletChild;
    behavior?: HitTestBehaviorLike;
    onTap?: AppletActionLike<void>;
    onDoubleTap?: AppletActionLike<void>;
    onLongPress?: AppletActionLike<void>;
  }
  export interface ListenerProps {
    child?: AppletChild;
    behavior?: HitTestBehaviorLike;
    onPointerDown?: AppletActionLike<PointerEventPayload>;
    onPointerMove?: AppletActionLike<PointerEventPayload>;
    onPointerUp?: AppletActionLike<PointerEventPayload>;
    onPointerCancel?: AppletActionLike<PointerEventPayload>;
    onPointerSignal?: AppletActionLike<PointerEventPayload>;
  }
  export interface MouseRegionProps {
    child?: AppletChild;
    opaque?: boolean;
    hitTestBehavior?: HitTestBehaviorLike;
    onEnter?: AppletActionLike<PointerEventPayload>;
    onExit?: AppletActionLike<PointerEventPayload>;
    onHover?: AppletActionLike<PointerEventPayload>;
  }
  export type PanAxisLike = "free" | "aligned" | "locked" | "horizontal" | "vertical" | "x" | "y";
  export interface InteractiveViewerProps {
    child?: AppletChild;
    clipBehavior?: ClipLike;
    panAxis?: PanAxisLike;
    boundaryMargin?: EdgeInsetsLike;
    constrained?: boolean;
    maxScale?: number;
    minScale?: number;
    interactionEndFrictionCoefficient?: number;
    frictionCoefficient?: number;
    friction?: number;
    panEnabled?: boolean;
    scaleEnabled?: boolean;
    scaleFactor?: number;
    alignment?: AlignmentLike;
    trackpadScrollCausesScale?: boolean;
    onInteractionStart?: AppletActionLike<ScaleStartPayload>;
    onInteractionUpdate?: AppletActionLike<ScaleUpdatePayload>;
    onInteractionEnd?: AppletActionLike<ScaleEndPayload>;
    onStart?: AppletActionLike<ScaleStartPayload>;
    onUpdate?: AppletActionLike<ScaleUpdatePayload>;
    onEnd?: AppletActionLike<ScaleEndPayload>;
  }
  export interface DismissibleProps {
    child?: AppletChild;
    key?: string | number;
    id?: string | number;
    value?: string | number;
    label?: string;
    text?: string;
    direction?: DismissDirectionLike;
    background?: AppletChild;
    secondaryBackground?: AppletChild;
    resizeDuration?: WidgetDurationLike;
    movementDuration?: WidgetDurationLike;
    crossAxisEndOffset?: number;
    behavior?: HitTestBehaviorLike;
    onDismissed?: AppletActionLike<DismissDirectionLike>;
    onResize?: AppletActionLike<void>;
  }
  export interface DraggableProps {
    child?: AppletChild;
    data?: unknown;
    value?: unknown;
    payload?: unknown;
    axis?: DragAxisLike;
    feedback?: AppletChild;
    childWhenDragging?: AppletChild;
    feedbackOffset?: OffsetLike;
    maxSimultaneousDrags?: number;
    ignoringFeedbackSemantics?: boolean;
    ignoringFeedbackPointer?: boolean;
    rootOverlay?: boolean;
    hitTestBehavior?: HitTestBehaviorLike;
    behavior?: HitTestBehaviorLike;
    onDragStarted?: AppletActionLike<void>;
    onDragUpdate?: AppletActionLike<DragUpdatePayload>;
    onDraggableCanceled?: AppletActionLike<DragCancelPayload>;
    onDragCanceled?: AppletActionLike<DragCancelPayload>;
    onDragEnd?: AppletActionLike<DragEndPayload>;
    onDragCompleted?: AppletActionLike<void>;
  }
  export interface LongPressDraggableProps extends DraggableProps {
    hapticFeedbackOnStart?: boolean;
    delay?: WidgetDurationLike;
  }
  export interface DragTargetProps {
    child?: AppletChild;
    activeChild?: AppletChild;
    candidateChild?: AppletChild;
    rejectedChild?: AppletChild;
    accepts?: unknown | unknown[];
    acceptedData?: unknown | unknown[];
    accept?: unknown | unknown[];
    hitTestBehavior?: HitTestBehaviorLike;
    behavior?: HitTestBehaviorLike;
    onWillAccept?: AppletActionLike<DragTargetPayload>;
    onEnter?: AppletActionLike<DragTargetPayload>;
    onAcceptWithDetails?: AppletActionLike<DragTargetPayload>;
    onAccept?: AppletActionLike<DragTargetPayload>;
    onDrop?: AppletActionLike<DragTargetPayload>;
    onLeave?: AppletActionLike<unknown>;
    onMove?: AppletActionLike<DragTargetPayload>;
  }
  export interface TapRegionProps {
    child?: AppletChild;
    enabled?: boolean;
    behavior?: HitTestBehaviorLike;
    groupId?: unknown;
    consumeOutsideTaps?: boolean;
    debugLabel?: string;
    onTapOutside?: AppletActionLike<PointerEventPayload>;
    onTapInside?: AppletActionLike<PointerEventPayload>;
    onTapUpOutside?: AppletActionLike<PointerEventPayload>;
    onTapUpInside?: AppletActionLike<PointerEventPayload>;
  }
  export interface TapRegionSurfaceProps {
    child?: AppletChild;
  }
  export function Placeholder(props?: PlaceholderProps): AppletNode;
  export function Tooltip(first?: AppletChild | TooltipProps, second?: TooltipProps): AppletNode;
  export function Hero(first?: AppletChild | HeroProps, second?: HeroProps): AppletNode;
  export function GestureDetector(first?: AppletChild | GestureDetectorProps, second?: GestureDetectorProps): AppletNode;
  export function Listener(first?: AppletChild | ListenerProps, second?: ListenerProps): AppletNode;
  export function MouseRegion(first?: AppletChild | MouseRegionProps, second?: MouseRegionProps): AppletNode;
  export function InteractiveViewer(first?: AppletChild | InteractiveViewerProps, second?: InteractiveViewerProps): AppletNode;
  export function Dismissible(first?: AppletChild | DismissibleProps, second?: DismissibleProps): AppletNode;
  export function Draggable(first?: AppletChild | DraggableProps, second?: DraggableProps): AppletNode;
  export function LongPressDraggable(first?: AppletChild | LongPressDraggableProps, second?: LongPressDraggableProps): AppletNode;
  export function DragTarget(first?: AppletChild | DragTargetProps, second?: DragTargetProps): AppletNode;
  export function TapRegion(first?: AppletChild | TapRegionProps, second?: TapRegionProps): AppletNode;
  export function TapRegionSurface(first?: AppletChild | TapRegionSurfaceProps, second?: TapRegionSurfaceProps): AppletNode;
  export interface ColoredBoxProps {
    child?: AppletChild;
    color?: ColorLike;
    isAntiAlias?: boolean;
  }
  export interface DecoratedBoxProps {
    child?: AppletChild;
    decoration?: BoxDecorationProps;
    position?: DecorationPositionLike;
  }
  export interface RepaintBoundaryProps {
    child?: AppletChild;
  }
  export interface SemanticsProps {
    child?: AppletChild;
    container?: boolean;
    explicitChildNodes?: boolean;
    excludeSemantics?: boolean;
    blockUserActions?: boolean;
    enabled?: boolean;
    checked?: boolean;
    mixed?: boolean;
    selected?: boolean;
    toggled?: boolean;
    button?: boolean;
    slider?: boolean;
    keyboardKey?: boolean;
    link?: boolean;
    linkUrl?: string;
    url?: string;
    header?: boolean;
    headingLevel?: number;
    textField?: boolean;
    readOnly?: boolean;
    focusable?: boolean;
    focused?: boolean;
    inMutuallyExclusiveGroup?: boolean;
    obscured?: boolean;
    multiline?: boolean;
    scopesRoute?: boolean;
    namesRoute?: boolean;
    hidden?: boolean;
    image?: boolean;
    liveRegion?: boolean;
    expanded?: boolean;
    isRequired?: boolean;
    maxValueLength?: number;
    currentValueLength?: number;
    identifier?: string;
    traversalParentIdentifier?: string;
    traversalChildIdentifier?: string;
    label?: string;
    value?: string;
    increasedValue?: string;
    decreasedValue?: string;
    hint?: string;
    tooltip?: string;
    onTapHint?: string;
    onLongPressHint?: string;
    textDirection?: WidgetTextDirectionLike;
    role?: WidgetSemanticsRoleLike;
    semanticsRole?: WidgetSemanticsRoleLike;
    minValue?: string | number;
    maxValue?: string | number;
    onTap?: string | AppletCallback<void>;
    onLongPress?: string | AppletCallback<void>;
    onScrollLeft?: string | AppletCallback<void>;
    onScrollRight?: string | AppletCallback<void>;
    onScrollUp?: string | AppletCallback<void>;
    onScrollDown?: string | AppletCallback<void>;
    onIncrease?: string | AppletCallback<void>;
    onDecrease?: string | AppletCallback<void>;
    onCopy?: string | AppletCallback<void>;
    onCut?: string | AppletCallback<void>;
    onPaste?: string | AppletCallback<void>;
    onDismiss?: string | AppletCallback<void>;
    onDidGainAccessibilityFocus?: string | AppletCallback<void>;
    onDidLoseAccessibilityFocus?: string | AppletCallback<void>;
    onFocus?: string | AppletCallback<void>;
    onExpand?: string | AppletCallback<void>;
    onCollapse?: string | AppletCallback<void>;
  }
  export interface ExcludeSemanticsProps {
    child?: AppletChild;
    excluding?: boolean;
  }
  export interface MergeSemanticsProps {
    child?: AppletChild;
  }
  export interface DirectionalityProps {
    child?: AppletChild;
    textDirection?: WidgetTextDirectionLike;
  }
  export interface TickerModeProps {
    child?: AppletChild;
    enabled?: boolean;
    forceFrames?: boolean;
  }
  export interface DefaultSelectionStyleProps {
    child?: AppletChild;
    cursorColor?: ColorLike;
    selectionColor?: ColorLike;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
  }
  export interface DefaultTextStyleProps {
    child?: AppletChild;
    style?: TextStyleLike;
    textAlign?: string;
    softWrap?: boolean;
    maxLines?: number;
    overflow?: "clip" | "fade" | "ellipsis" | "visible";
  }
  export interface IconThemeProps {
    child?: AppletChild;
    data?: Record<string, unknown>;
    color?: ColorLike;
    size?: number;
    opacity?: number;
    fill?: number;
    weight?: number;
    grade?: number;
    opticalSize?: number;
    shadows?: TextShadowLike | TextShadowLike[];
    shadow?: TextShadowLike | ColorLike;
    applyTextScaling?: boolean;
  }
  export interface ThemeProps {
    child?: AppletChild;
    data?: ThemeDataProps;
  }
  export function ColoredBox(first?: AppletChild | ColoredBoxProps, second?: ColoredBoxProps): AppletNode;
  export function DecoratedBox(first?: AppletChild | DecoratedBoxProps, second?: DecoratedBoxProps): AppletNode;
  export function RepaintBoundary(first?: AppletChild | RepaintBoundaryProps, second?: RepaintBoundaryProps): AppletNode;
  export function Semantics(first?: AppletChild | SemanticsProps, second?: SemanticsProps): AppletNode;
  export function ExcludeSemantics(first?: AppletChild | ExcludeSemanticsProps, second?: ExcludeSemanticsProps): AppletNode;
  export function MergeSemantics(first?: AppletChild | MergeSemanticsProps, second?: MergeSemanticsProps): AppletNode;
  export function Directionality(first?: AppletChild | DirectionalityProps, second?: DirectionalityProps): AppletNode;
  export function TickerMode(first?: AppletChild | TickerModeProps, second?: TickerModeProps): AppletNode;
  export function DefaultSelectionStyle(first?: AppletChild | DefaultSelectionStyleProps, second?: DefaultSelectionStyleProps): AppletNode;
  export function DefaultTextStyle(first?: AppletChild | DefaultTextStyleProps, second?: DefaultTextStyleProps): AppletNode;
  export function IconTheme(first?: AppletChild | IconThemeProps, second?: IconThemeProps): AppletNode;
  export function KeyboardListener(first?: AppletChild | KeyboardListenerProps, second?: KeyboardListenerProps): AppletNode;
  export function CallbackShortcuts(first?: AppletChild | CallbackShortcutsProps, second?: CallbackShortcutsProps): AppletNode;
  export function Theme(props?: ThemeProps): AppletNode;
  export function ThemeData(props?: ThemeDataProps): ThemeDataProps;
  export const ColorScheme: { fromSeed(props?: Record<string, unknown>): Record<string, unknown> };
  export const EdgeInsets: Record<string, unknown>;
  export const BorderRadius: Record<string, unknown>;
  export function BoxDecoration(props?: BoxDecorationProps): BoxDecorationProps;
  export function BoxConstraints(props?: Record<string, unknown>): Record<string, unknown>;
  export function Duration(props?: Record<string, unknown>): Record<string, unknown>;
  export function Color(value: ColorLike): ColorLike;
  export const Colors: Record<string, string>;
  export const Icons: Record<string, string>;
}

declare module "@app/layout" {
  export * from "@app/widgets";
  import type {
    AlignmentLike,
    AppletActionLike,
    AppletCallback,
    AppletChild,
    AppletChildren,
    AppletNode,
    BoxConstraintsLike,
    ClipLike,
    ColorLike,
    CrossAxisAlignmentLike,
    DragStartBehaviorLike,
    EdgeInsetsLike,
    AdaptiveTwoPaneProps,
    LayoutBuilderProps,
    MainAxisAlignmentLike,
    MouseCursorLike,
    OffsetLike,
    ShapeBorderLike,
    TextBaselineLike,
    TextThemeStyleLike,
    TextStyleLike,
  } from "@app/core";
  import type {
    CallbackShortcutsProps,
    KeyEventPayload,
    KeyboardListenerProps,
    RectLike,
    TextScalerLike,
  } from "@app/widgets";

  export type ScrollAxisLike = "horizontal" | "vertical";
  export type ScrollPhysicsLike = "never" | "bouncing" | "clamping";
  export type LayoutHitTestBehaviorLike = "deferToChild" | "defer_to_child" | "defer" | "opaque" | "translucent";
  export type TextDirectionLike = "ltr" | "rtl" | "leftToRight" | "left_to_right" | "rightToLeft" | "right_to_left";
  export type VerticalDirectionLike = "up" | "down" | "reverse" | "forward";
  export type MainAxisSizeLike = "min" | "max";
  export type FlexFitLike = "tight" | "expanded" | "fill" | "loose" | "flexible";
  export type BoxFitLike = "fill" | "contain" | "cover" | "fitWidth" | "fit_width" | "fitHeight" | "fit_height" | "none" | "scaleDown" | "scale_down";
  export type StackFitLike = "loose" | "expand" | "passthrough" | "pass_through";
  export type OverflowBoxFitLike = "max" | "deferToChild" | "defer_to_child" | "defer";
  export type WrapAlignmentLike = "start" | "end" | "center" | "spaceBetween" | "space_between" | "spaceAround" | "space_around" | "spaceEvenly" | "space_evenly";
  export type WrapCrossAlignmentLike = "start" | "end" | "center";
  export type LayoutSizeLike = number | [number, number] | { width?: number; height?: number; w?: number; h?: number };
  export type LayoutDurationLike = number | Record<string, number>;
  export type LayoutCurveLike = "linear" | "ease" | "easeIn" | "ease_in" | "easeOut" | "ease_out" | "easeInOut" | "ease_in_out" | "fastOutSlowIn" | "fast_out_slow_in" | "bounceOut" | "bounce_out" | "elasticOut" | "elastic_out";
  export type FilterQualityLike = "none" | "low" | "medium" | "high";
  export type BoxShapeLike = "rectangle" | "rect" | "circle";
  export type CrossFadeStateLike = "showFirst" | "show_first" | "first" | "showSecond" | "show_second" | "second" | boolean;
  export type MediaQueryBrightnessLike = "light" | "dark";
  export type MediaQueryNavigationModeLike = "traditional" | "directional";
  export type DisplayFeatureTypeLike = "unknown" | "fold" | "hinge" | "cutout";
  export type DisplayFeatureStateLike =
    | "unknown"
    | "postureFlat"
    | "posture_flat"
    | "posture-flat"
    | "flat"
    | "postureHalfOpened"
    | "posture_half_opened"
    | "posture-half-opened"
    | "halfOpened"
    | "half_opened"
    | "half-opened";
  export type MediaQueryBorderRadiusLike = number | Record<string, number>;
  export interface DisplayFeatureLike {
    bounds?: RectLike;
    rect?: RectLike;
    type?: DisplayFeatureTypeLike;
    state?: DisplayFeatureStateLike;
  }
  export interface DeviceGestureSettingsLike {
    touchSlop?: number;
  }
  export interface MediaQueryDataProps {
    size?: LayoutSizeLike;
    devicePixelRatio?: number;
    dpr?: number;
    textScaler?: TextScalerLike;
    textScaleFactor?: number;
    platformBrightness?: MediaQueryBrightnessLike;
    brightness?: MediaQueryBrightnessLike;
    padding?: EdgeInsetsLike;
    viewInsets?: EdgeInsetsLike;
    viewPadding?: EdgeInsetsLike;
    systemGestureInsets?: EdgeInsetsLike;
    alwaysUse24HourFormat?: boolean;
    use24HourFormat?: boolean;
    accessibleNavigation?: boolean;
    invertColors?: boolean;
    highContrast?: boolean;
    onOffSwitchLabels?: boolean;
    disableAnimations?: boolean;
    disableAnimation?: boolean;
    boldText?: boolean;
    supportsAnnounce?: boolean;
    navigationMode?: MediaQueryNavigationModeLike;
    gestureSettings?: number | DeviceGestureSettingsLike;
    displayFeatures?: DisplayFeatureLike | DisplayFeatureLike[];
    supportsShowingSystemContextMenu?: boolean;
    lineHeightScaleFactorOverride?: number;
    lineHeightScaleFactor?: number;
    letterSpacingOverride?: number;
    wordSpacingOverride?: number;
    paragraphSpacingOverride?: number;
    displayCornerRadii?: MediaQueryBorderRadiusLike;
    displayCornerRadius?: MediaQueryBorderRadiusLike;
  }
  export interface MediaQueryProps extends MediaQueryDataProps {
    child?: AppletChild;
    data?: MediaQueryDataProps;
  }
  export type LayoutOrientationLike =
    | "portrait"
    | "landscape"
    | "vertical"
    | "horizontal"
    | "tall"
    | "wide";
  export interface OrientationVariant {
    orientation?: LayoutOrientationLike;
    mode?: LayoutOrientationLike;
    child?: AppletChild;
    view?: AppletChild;
    layout?: AppletChild;
    content?: AppletChild;
    default?: boolean;
  }
  export interface OrientationBuilderProps {
    child?: AppletChild;
    portrait?: AppletChild;
    landscape?: AppletChild;
    vertical?: AppletChild;
    horizontal?: AppletChild;
    tall?: AppletChild;
    wide?: AppletChild;
    fallback?: AppletChild;
    default?: AppletChild;
    variants?: OrientationVariant[] | Record<string, AppletChild>;
    layouts?: OrientationVariant[] | Record<string, AppletChild>;
    breakpoints?: OrientationVariant[] | Record<string, AppletChild>;
  }

  export interface ChildLayoutProps {
    child?: AppletChild;
  }

  export interface ChildrenLayoutProps {
    children?: AppletChildren;
  }

  export interface SafeAreaProps extends ChildLayoutProps {
    left?: boolean;
    top?: boolean;
    right?: boolean;
    bottom?: boolean;
    minimum?: EdgeInsetsLike;
    maintainBottomViewPadding?: boolean;
  }

  export interface CenterProps extends ChildLayoutProps {
    widthFactor?: number;
    heightFactor?: number;
  }

  export interface AlignProps extends CenterProps {
    alignment?: AlignmentLike;
  }

  export interface PaddingProps extends ChildLayoutProps {
    padding?: EdgeInsetsLike;
  }

  export interface ContainerProps extends ChildLayoutProps {
    width?: number;
    height?: number;
    constraints?: BoxConstraintsLike;
    margin?: EdgeInsetsLike;
    padding?: EdgeInsetsLike;
    alignment?: AlignmentLike;
    decoration?: Record<string, unknown>;
    foregroundDecoration?: Record<string, unknown>;
    color?: ColorLike;
    backgroundColor?: ColorLike;
    shape?: string;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    border?: Record<string, unknown>;
    gradient?: Record<string, unknown>;
    image?: unknown;
    decorationImage?: unknown;
    backgroundImage?: unknown;
    boxShadow?: unknown;
    boxShadows?: unknown;
    shadow?: unknown;
    shadows?: unknown;
    backgroundBlendMode?: string;
    blendMode?: string;
    clipBehavior?: ClipLike;
  }

  export interface SizedBoxProps extends ChildLayoutProps {
    width?: number;
    height?: number;
  }

  export interface ConstrainedBoxProps extends ChildLayoutProps {
    constraints?: BoxConstraintsLike;
  }

  export interface LimitedBoxProps extends ChildLayoutProps {
    maxWidth?: number;
    maxHeight?: number;
  }

  export interface UnconstrainedBoxProps extends ChildLayoutProps {
    alignment?: AlignmentLike;
    constrainedAxis?: ScrollAxisLike;
    clipBehavior?: ClipLike;
  }

  export interface OverflowBoxProps extends ChildLayoutProps {
    alignment?: AlignmentLike;
    minWidth?: number;
    maxWidth?: number;
    minHeight?: number;
    maxHeight?: number;
    fit?: OverflowBoxFitLike;
  }

  export interface SizedOverflowBoxProps extends ChildLayoutProps {
    size?: LayoutSizeLike;
    width?: number;
    height?: number;
    alignment?: AlignmentLike;
  }

  export interface AspectRatioProps extends ChildLayoutProps {
    aspectRatio?: number;
    ratio?: number;
  }

  export interface FractionallySizedBoxProps extends ChildLayoutProps {
    widthFactor?: number;
    heightFactor?: number;
    alignment?: AlignmentLike;
  }

  export interface FittedBoxProps extends ChildLayoutProps {
    fit?: BoxFitLike;
    alignment?: AlignmentLike;
    clipBehavior?: ClipLike;
  }

  export interface BaselineProps extends ChildLayoutProps {
    baseline?: number;
    baselineType?: TextBaselineLike;
  }

  export interface IntrinsicWidthProps extends ChildLayoutProps {
    stepWidth?: number;
    stepHeight?: number;
  }

  export interface ExpandedProps extends ChildLayoutProps {
    flex?: number;
  }

  export interface FlexibleProps extends ExpandedProps {
    fit?: FlexFitLike;
  }

  export interface SpacerProps {
    flex?: number;
  }

  export interface FlexLayoutProps extends ChildrenLayoutProps {
    mainAxisAlignment?: MainAxisAlignmentLike;
    crossAxisAlignment?: CrossAxisAlignmentLike;
    mainAxisSize?: MainAxisSizeLike;
    textDirection?: TextDirectionLike;
    verticalDirection?: VerticalDirectionLike;
    textBaseline?: TextBaselineLike;
    baseline?: TextBaselineLike;
    spacing?: number;
  }

  export interface StackProps extends ChildrenLayoutProps {
    alignment?: AlignmentLike;
    textDirection?: TextDirectionLike;
    fit?: StackFitLike;
    clipBehavior?: ClipLike;
  }

  export interface IndexedStackProps extends StackProps {
    index?: number;
    sizing?: StackFitLike;
  }

  export interface PositionedProps extends ChildLayoutProps {
    left?: number;
    top?: number;
    right?: number;
    bottom?: number;
    width?: number;
    height?: number;
  }

  export interface AnimatedPositionedProps extends PositionedProps {
    duration?: LayoutDurationLike;
    curve?: LayoutCurveLike;
    onEnd?: string | AppletCallback<void>;
  }

  export interface WrapProps extends ChildrenLayoutProps {
    direction?: ScrollAxisLike;
    alignment?: WrapAlignmentLike;
    runAlignment?: WrapAlignmentLike;
    crossAxisAlignment?: WrapCrossAlignmentLike;
    spacing?: number;
    runSpacing?: number;
    textDirection?: TextDirectionLike;
    verticalDirection?: VerticalDirectionLike;
    clipBehavior?: ClipLike;
  }

  export interface ListBodyProps extends ChildrenLayoutProps {
    mainAxis?: ScrollAxisLike;
    axis?: ScrollAxisLike;
    reverse?: boolean;
  }

  export interface ImplicitAnimationProps {
    duration?: LayoutDurationLike;
    curve?: LayoutCurveLike;
    onEnd?: string | AppletCallback<void>;
  }

  export interface OpacityProps extends ChildLayoutProps {
    opacity?: number;
    alwaysIncludeSemantics?: boolean;
  }

  export interface AnimatedOpacityProps extends OpacityProps, ImplicitAnimationProps {}

  export interface AnimatedContainerProps extends ContainerProps, ImplicitAnimationProps {}

  export interface AnimatedAlignProps extends AlignProps, ImplicitAnimationProps {}

  export interface AnimatedPaddingProps extends PaddingProps, ImplicitAnimationProps {}

  export interface AnimatedScaleProps extends ChildLayoutProps, ImplicitAnimationProps {
    scale?: number;
    alignment?: AlignmentLike;
    filterQuality?: FilterQualityLike;
  }

  export interface AnimatedRotationProps extends ChildLayoutProps, ImplicitAnimationProps {
    turns?: number;
    alignment?: AlignmentLike;
    filterQuality?: FilterQualityLike;
  }

  export interface AnimatedSlideProps extends ChildLayoutProps, ImplicitAnimationProps {
    offset?: OffsetLike;
  }

  export interface AnimatedSizeProps extends ChildLayoutProps, ImplicitAnimationProps {
    reverseDuration?: LayoutDurationLike;
    alignment?: AlignmentLike;
    clipBehavior?: ClipLike;
  }

  export interface AnimatedSwitcherProps extends ChildLayoutProps {
    duration?: LayoutDurationLike;
    reverseDuration?: LayoutDurationLike;
    switchInCurve?: LayoutCurveLike;
    switchOutCurve?: LayoutCurveLike;
  }

  export interface AnimatedCrossFadeProps extends ImplicitAnimationProps {
    firstChild?: AppletChild;
    secondChild?: AppletChild;
    showSecond?: boolean;
    crossFadeState?: CrossFadeStateLike;
    reverseDuration?: LayoutDurationLike;
    firstCurve?: LayoutCurveLike;
    secondCurve?: LayoutCurveLike;
    sizeCurve?: LayoutCurveLike;
    alignment?: AlignmentLike;
    excludeBottomFocus?: boolean;
  }

  export interface PhysicalModelProps extends ChildLayoutProps {
    shape?: BoxShapeLike;
    clipBehavior?: ClipLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    elevation?: number;
    color?: ColorLike;
    shadowColor?: ColorLike;
  }

  export interface AnimatedPhysicalModelProps extends PhysicalModelProps, ImplicitAnimationProps {
    animateColor?: boolean;
    animateShadowColor?: boolean;
  }

  export interface VisibilityProps extends ChildLayoutProps {
    visible?: boolean;
    replacement?: AppletChild;
    maintain?: boolean;
    maintainState?: boolean;
    maintainAnimation?: boolean;
    maintainSize?: boolean;
    maintainSemantics?: boolean;
    maintainInteractivity?: boolean;
    maintainFocusability?: boolean;
  }

  export interface OffstageProps extends ChildLayoutProps {
    offstage?: boolean;
  }

  export interface IgnorePointerProps extends ChildLayoutProps {
    ignoring?: boolean;
  }

  export interface AbsorbPointerProps extends ChildLayoutProps {
    absorbing?: boolean;
  }

  export interface ClipRRectProps extends ChildLayoutProps {
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    clipBehavior?: ClipLike;
  }

  export interface ClipOvalProps extends ChildLayoutProps {
    clipBehavior?: ClipLike;
  }

  export interface ClipRectProps extends ChildLayoutProps {
    clipBehavior?: ClipLike;
  }

  export interface RotatedBoxProps extends ChildLayoutProps {
    quarterTurns?: number;
  }

  export interface TransformProps extends ChildLayoutProps {
    rotate?: number;
    angle?: number;
    scale?: number;
    scaleX?: number;
    scaleY?: number;
    translate?: OffsetLike;
    flipX?: boolean;
    flipY?: boolean;
    origin?: OffsetLike;
    alignment?: AlignmentLike;
    transformHitTests?: boolean;
    filterQuality?: FilterQualityLike;
  }

  export interface ScrollViewProps {
    child?: AppletChild;
    children?: AppletChildren;
    scrollDirection?: ScrollAxisLike;
    reverse?: boolean;
    padding?: EdgeInsetsLike;
    primary?: boolean;
    physics?: ScrollPhysicsLike;
    scrollable?: boolean;
    dragStartBehavior?: DragStartBehaviorLike;
    clipBehavior?: ClipLike;
    hitTestBehavior?: LayoutHitTestBehaviorLike;
    behavior?: LayoutHitTestBehaviorLike;
    restorationId?: string;
  }

  export interface CustomScrollViewProps extends ScrollViewProps {
    slivers?: AppletChildren;
    shrinkWrap?: boolean;
    anchor?: number;
  }

  export interface ListViewProps extends ScrollViewProps {
    shrinkWrap?: boolean;
    spacing?: number;
    itemExtent?: number;
  }

  export interface GridViewProps extends ListViewProps {
    crossAxisCount?: number;
    childAspectRatio?: number;
    mainAxisSpacing?: number;
    crossAxisSpacing?: number;
    mainAxisExtent?: number;
  }

  export interface PageViewProps {
    children?: AppletChildren;
    scrollDirection?: ScrollAxisLike;
    reverse?: boolean;
    physics?: ScrollPhysicsLike;
    scrollable?: boolean;
    pageSnapping?: boolean;
    dragStartBehavior?: DragStartBehaviorLike;
    allowImplicitScrolling?: boolean;
    restorationId?: string;
    clipBehavior?: ClipLike;
    hitTestBehavior?: LayoutHitTestBehaviorLike;
    behavior?: LayoutHitTestBehaviorLike;
    padEnds?: boolean;
    onPageChanged?: string | AppletCallback<number>;
  }

  export type AutofillContextActionLike = "commit" | "save" | "cancel" | "discard";
  export type AutovalidateModeLike = "disabled" | "always" | "onUserInteraction" | "on_user_interaction" | "onUnfocus" | "on_unfocus";
  export type FocusTraversalPolicyLike = "readingOrder" | "reading_order" | "reading-order" | "reading" | "widgetOrder" | "widget_order" | "widget-order" | "widget" | "ordered" | "numeric";
  export type KeyboardDismissBehaviorLike = "manual" | "none" | "onDrag" | "on_drag" | "drag";
  export type ScrollCacheExtentLike =
    | number
    | { pixels?: number; viewport?: number; value?: number; amount?: number; extent?: number; unit?: "pixels" | "pixel" | "viewport" | "viewports" | "fraction"; type?: "pixels" | "pixel" | "viewport" | "viewports" | "fraction"; style?: "pixels" | "pixel" | "viewport" | "viewports" | "fraction" };

  export interface FormProps extends ChildLayoutProps {
    autovalidateMode?: AutovalidateModeLike;
    onChanged?: AppletActionLike<void>;
  }

  export interface AutofillGroupProps extends ChildLayoutProps {
    onDisposeAction?: AutofillContextActionLike;
  }

  export interface FocusProps extends ChildLayoutProps {
    autofocus?: boolean;
    canRequestFocus?: boolean;
    skipTraversal?: boolean;
    descendantsAreFocusable?: boolean;
    descendantsAreTraversable?: boolean;
    includeSemantics?: boolean;
    debugLabel?: string;
    label?: string;
    onFocusChange?: AppletActionLike<boolean>;
    onKeyEvent?: AppletActionLike<KeyEventPayload>;
    onKey?: AppletActionLike<KeyEventPayload>;
  }

  export interface FocusTraversalGroupProps extends ChildLayoutProps {
    policy?: FocusTraversalPolicyLike;
    descendantsAreFocusable?: boolean;
    descendantsAreTraversable?: boolean;
  }

  export interface FocusableActionDetectorProps extends ChildLayoutProps {
    enabled?: boolean;
    autofocus?: boolean;
    descendantsAreFocusable?: boolean;
    descendantsAreTraversable?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    includeFocusSemantics?: boolean;
    onShowFocusHighlight?: AppletActionLike<boolean>;
    onShowHoverHighlight?: AppletActionLike<boolean>;
    onFocusChange?: AppletActionLike<boolean>;
  }

  export interface ReorderableListViewProps extends ChildrenLayoutProps {
    onReorderItem?: AppletActionLike<{ oldIndex: number; newIndex: number }>;
    onReorder?: AppletActionLike<{ oldIndex: number; newIndex: number }>;
    onChanged?: AppletActionLike<{ oldIndex: number; newIndex: number }>;
    onReorderStart?: AppletActionLike<number>;
    onReorderEnd?: AppletActionLike<number>;
    itemExtent?: number;
    buildDefaultDragHandles?: boolean;
    padding?: EdgeInsetsLike;
    header?: AppletChild;
    footer?: AppletChild;
    scrollDirection?: ScrollAxisLike;
    reverse?: boolean;
    primary?: boolean;
    physics?: ScrollPhysicsLike;
    scrollable?: boolean;
    shrinkWrap?: boolean;
    anchor?: number;
    cacheExtent?: number | ScrollCacheExtentLike;
    scrollCacheExtent?: ScrollCacheExtentLike;
    dragStartBehavior?: DragStartBehaviorLike;
    keyboardDismissBehavior?: KeyboardDismissBehaviorLike;
    restorationId?: string;
    clipBehavior?: ClipLike;
    autoScrollerVelocityScalar?: number;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
  }

  export interface ReorderableDragStartListenerProps extends ChildLayoutProps {
    key?: string | number;
    index?: number;
    enabled?: boolean;
  }

  export interface SliverPaddingProps {
    child?: AppletChild;
    sliver?: AppletChild;
    padding?: EdgeInsetsLike;
  }

  export interface SliverListProps {
    children?: AppletChildren;
  }

  export interface SliverGridProps extends SliverListProps {
    crossAxisCount?: number;
    childAspectRatio?: number;
    mainAxisSpacing?: number;
    crossAxisSpacing?: number;
  }

  export interface SliverFillRemainingProps {
    child?: AppletChild;
    hasScrollBody?: boolean;
    fillOverscroll?: boolean;
  }

  export interface LayoutSliverAppBarProps {
    variant?: "small" | "medium" | "large";
    title?: AppletChild;
    leading?: AppletChild;
    actions?: AppletChildren;
    automaticallyImplyActions?: boolean;
    flexibleSpace?: AppletChild;
    bottom?: AppletChild;
    backgroundColor?: ColorLike;
    foregroundColor?: ColorLike;
    centerTitle?: boolean;
    automaticallyImplyLeading?: boolean;
    elevation?: number;
    scrolledUnderElevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    forceElevated?: boolean;
    iconTheme?: Record<string, unknown>;
    actionsIconTheme?: Record<string, unknown>;
    primary?: boolean;
    excludeHeaderSemantics?: boolean;
    titleSpacing?: number;
    collapsedHeight?: number;
    expandedHeight?: number;
    floating?: boolean;
    pinned?: boolean;
    snap?: boolean;
    stretch?: boolean;
    stretchTriggerOffset?: number;
    shape?: ShapeBorderLike;
    toolbarHeight?: number;
    leadingWidth?: number;
    toolbarTextStyle?: TextStyleLike;
    titleTextStyle?: TextStyleLike;
    forceMaterialTransparency?: boolean;
    useDefaultSemanticsOrder?: boolean;
    clipBehavior?: ClipLike;
    actionsPadding?: EdgeInsetsLike;
  }

  export function SafeArea(first?: AppletChild | SafeAreaProps, second?: SafeAreaProps): AppletNode;
  export function Center(first?: AppletChild | CenterProps, second?: CenterProps): AppletNode;
  export function Align(first?: AppletChild | AlignProps, second?: AlignProps): AppletNode;
  export function Padding(first?: AppletChild | PaddingProps, second?: PaddingProps): AppletNode;
  export function Container(first?: AppletChild | ContainerProps, second?: ContainerProps): AppletNode;
  export function SizedBox(first?: AppletChild | SizedBoxProps, second?: SizedBoxProps): AppletNode;
  export function ConstrainedBox(first?: AppletChild | ConstrainedBoxProps, second?: ConstrainedBoxProps): AppletNode;
  export function LimitedBox(first?: AppletChild | LimitedBoxProps, second?: LimitedBoxProps): AppletNode;
  export function UnconstrainedBox(first?: AppletChild | UnconstrainedBoxProps, second?: UnconstrainedBoxProps): AppletNode;
  export function OverflowBox(first?: AppletChild | OverflowBoxProps, second?: OverflowBoxProps): AppletNode;
  export function SizedOverflowBox(first?: AppletChild | SizedOverflowBoxProps, second?: SizedOverflowBoxProps): AppletNode;
  export function AspectRatio(first?: AppletChild | AspectRatioProps, second?: AspectRatioProps): AppletNode;
  export function FractionallySizedBox(first?: AppletChild | FractionallySizedBoxProps, second?: FractionallySizedBoxProps): AppletNode;
  export function FittedBox(first?: AppletChild | FittedBoxProps, second?: FittedBoxProps): AppletNode;
  export function Baseline(first?: AppletChild | BaselineProps, second?: BaselineProps): AppletNode;
  export function IntrinsicWidth(first?: AppletChild | IntrinsicWidthProps, second?: IntrinsicWidthProps): AppletNode;
  export function IntrinsicHeight(first?: AppletChild | ChildLayoutProps, second?: ChildLayoutProps): AppletNode;
  export function Expanded(first?: AppletChild | ExpandedProps, second?: ExpandedProps): AppletNode;
  export function Flexible(first?: AppletChild | FlexibleProps, second?: FlexibleProps): AppletNode;
  export function Spacer(props?: SpacerProps): AppletNode;
  export function Opacity(first?: AppletChild | OpacityProps, second?: OpacityProps): AppletNode;
  export function AnimatedOpacity(first?: AppletChild | AnimatedOpacityProps, second?: AnimatedOpacityProps): AppletNode;
  export function AnimatedContainer(first?: AppletChild | AnimatedContainerProps, second?: AnimatedContainerProps): AppletNode;
  export function AnimatedAlign(first?: AppletChild | AnimatedAlignProps, second?: AnimatedAlignProps): AppletNode;
  export function AnimatedPadding(first?: AppletChild | AnimatedPaddingProps, second?: AnimatedPaddingProps): AppletNode;
  export function AnimatedScale(first?: AppletChild | AnimatedScaleProps, second?: AnimatedScaleProps): AppletNode;
  export function AnimatedRotation(first?: AppletChild | AnimatedRotationProps, second?: AnimatedRotationProps): AppletNode;
  export function AnimatedSlide(first?: AppletChild | AnimatedSlideProps, second?: AnimatedSlideProps): AppletNode;
  export function AnimatedSize(first?: AppletChild | AnimatedSizeProps, second?: AnimatedSizeProps): AppletNode;
  export function AnimatedSwitcher(first?: AppletChild | AnimatedSwitcherProps, second?: AnimatedSwitcherProps): AppletNode;
  export function AnimatedCrossFade(props?: AnimatedCrossFadeProps): AppletNode;
  export function AnimatedPhysicalModel(first?: AppletChild | AnimatedPhysicalModelProps, second?: AnimatedPhysicalModelProps): AppletNode;
  export function Visibility(first?: AppletChild | VisibilityProps, second?: VisibilityProps): AppletNode;
  export function Offstage(first?: AppletChild | OffstageProps, second?: OffstageProps): AppletNode;
  export function IgnorePointer(first?: AppletChild | IgnorePointerProps, second?: IgnorePointerProps): AppletNode;
  export function AbsorbPointer(first?: AppletChild | AbsorbPointerProps, second?: AbsorbPointerProps): AppletNode;
  export function ClipRRect(first?: AppletChild | ClipRRectProps, second?: ClipRRectProps): AppletNode;
  export function ClipOval(first?: AppletChild | ClipOvalProps, second?: ClipOvalProps): AppletNode;
  export function ClipRect(first?: AppletChild | ClipRectProps, second?: ClipRectProps): AppletNode;
  export function PhysicalModel(first?: AppletChild | PhysicalModelProps, second?: PhysicalModelProps): AppletNode;
  export function RotatedBox(first?: AppletChild | RotatedBoxProps, second?: RotatedBoxProps): AppletNode;
  export function Transform(first?: AppletChild | TransformProps, second?: TransformProps): AppletNode;
  export function SingleChildScrollView(first?: AppletChild | ScrollViewProps, second?: ScrollViewProps): AppletNode;
  export function CustomScrollView(first?: AppletChildren | CustomScrollViewProps, second?: CustomScrollViewProps): AppletNode;
  export function SliverToBoxAdapter(first?: AppletChild | Record<string, unknown>, second?: Record<string, unknown>): AppletNode;
  export function SliverPadding(first?: AppletChild | SliverPaddingProps, second?: SliverPaddingProps): AppletNode;
  export function SliverList(first?: AppletChildren | SliverListProps, second?: SliverListProps): AppletNode;
  export function SliverCachedList(first?: AppletChildren | SliverListProps, second?: SliverListProps): AppletNode;
  export function SliverEstimatedList(first?: AppletChildren | SliverListProps, second?: SliverListProps): AppletNode;
  export function SliverGrid(first?: AppletChildren | SliverGridProps, second?: SliverGridProps): AppletNode;
  export function SliverFillRemaining(first?: AppletChild | SliverFillRemainingProps, second?: SliverFillRemainingProps): AppletNode;
  export const SliverAppBar: ((props?: LayoutSliverAppBarProps) => AppletNode) & {
    medium(props?: LayoutSliverAppBarProps): AppletNode;
    large(props?: LayoutSliverAppBarProps): AppletNode;
  };
  export function SliverLayoutBuilder(first?: AppletChild | LayoutBuilderProps, second?: Record<string, unknown>): AppletNode;
  export function Builder(first?: AppletChild | Record<string, unknown>, second?: Record<string, unknown>): AppletNode;
  export function LayoutBuilder(first?: AppletChild | LayoutBuilderProps, second?: Record<string, unknown>): AppletNode;
  export function AdaptiveTwoPane(props?: AdaptiveTwoPaneProps): AppletNode;
  export function OrientationBuilder(first?: AppletChild | OrientationBuilderProps, second?: OrientationBuilderProps): AppletNode;
  export function MediaQuery(first?: AppletChild | MediaQueryProps, second?: MediaQueryProps): AppletNode;
  export function Form(first?: AppletChild | FormProps, second?: FormProps): AppletNode;
  export function AutofillGroup(first?: AppletChild | AutofillGroupProps, second?: AutofillGroupProps): AppletNode;
  export function Focus(first?: AppletChild | FocusProps, second?: FocusProps): AppletNode;
  export function FocusTraversalGroup(first?: AppletChild | FocusTraversalGroupProps, second?: FocusTraversalGroupProps): AppletNode;
  export function FocusableActionDetector(first?: AppletChild | FocusableActionDetectorProps, second?: FocusableActionDetectorProps): AppletNode;
  export function KeyboardListener(first?: AppletChild | KeyboardListenerProps, second?: KeyboardListenerProps): AppletNode;
  export function CallbackShortcuts(first?: AppletChild | CallbackShortcutsProps, second?: CallbackShortcutsProps): AppletNode;
  export function Column(first?: AppletChildren | FlexLayoutProps, second?: FlexLayoutProps): AppletNode;
  export function Row(first?: AppletChildren | FlexLayoutProps, second?: FlexLayoutProps): AppletNode;
  export function Stack(first?: AppletChildren | StackProps, second?: StackProps): AppletNode;
  export function IndexedStack(first?: AppletChildren | IndexedStackProps, second?: IndexedStackProps): AppletNode;
  export function Wrap(first?: AppletChildren | WrapProps, second?: WrapProps): AppletNode;
  export function ListBody(first?: AppletChildren | ListBodyProps, second?: ListBodyProps): AppletNode;
  export function ListView(first?: AppletChildren | ListViewProps, second?: ListViewProps): AppletNode;
  export function ReorderableListView(first?: AppletChildren | ReorderableListViewProps, second?: ReorderableListViewProps): AppletNode;
  export function ReorderableDragStartListener(first?: AppletChild | ReorderableDragStartListenerProps, second?: ReorderableDragStartListenerProps): AppletNode;
  export function ReorderableDelayedDragStartListener(first?: AppletChild | ReorderableDragStartListenerProps, second?: ReorderableDragStartListenerProps): AppletNode;
  export function GridView(first?: AppletChildren | GridViewProps, second?: GridViewProps): AppletNode;
  export function PageView(first?: AppletChildren | PageViewProps, second?: PageViewProps): AppletNode;
  export function VStack(...children: AppletChildren[]): AppletNode;
  export function HStack(...children: AppletChildren[]): AppletNode;
  export function ZStack(...children: AppletChildren[]): AppletNode;
  export function Scroll(...children: AppletChildren[]): AppletNode;
  export function Box(first?: AppletChild | ContainerProps, second?: ContainerProps): AppletNode;
  export function Positioned(props?: PositionedProps): AppletNode;
  export function AnimatedPositioned(props?: AnimatedPositionedProps): AppletNode;
}

declare module "@app/material" {
  export * from "@app/layout";
  import type {
    AlignmentLike,
    AnimationStyleLike,
    AppletActionLike,
    AppletCallback,
    AppletChild,
    AppletChildren,
    AppletNode,
    BoxConstraintsLike,
    ButtonStyleLike,
    ChipAnimationStyleLike,
    ClipLike,
    ColorLike,
    CrossAxisAlignmentLike,
    DragStartBehaviorLike,
    EdgeInsetsLike,
    InputDecorationProps,
    MaterialTapTargetSizeLike,
    MainAxisAlignmentLike,
    MouseCursorLike,
    PointerEventPayload,
    ShapeBorderLike,
    ShowValueIndicatorLike,
    SliderInteractionLike,
    StrutStyleLike,
    TextBaselineLike,
    TextMagnifierConfigurationLike,
    TextRadiusLike,
    TextShadowLike,
    TextSelectionBoxHeightStyleLike,
    TextSelectionBoxWidthStyleLike,
    TextSelectionControlsLike,
    TextStyleLike,
    TextScrollPhysicsLike,
    ThemeDataProps,
    VisualDensityLike,
    WidgetStatePropertyLike,
  } from "@app/core";
  import type {
    LayoutCurveLike,
    LayoutDurationLike,
    TextDirectionLike,
  } from "@app/layout";
  import type { ImageProps } from "@app/widgets";

  export type ListTileStyleLike = "list" | "drawer";
  export type ListTileControlAffinityLike = "leading" | "start" | "trailing" | "end" | "platform" | "adaptive";
  export type ListTileTitleAlignmentLike = "threeLine" | "three_line" | "three-line" | "titleHeight" | "title_height" | "title-height" | "top" | "center" | "bottom";

  export interface ListTileProps {
    leading?: AppletChild;
    title?: AppletChild;
    subtitle?: AppletChild;
    trailing?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    isThreeLine?: boolean;
    dense?: boolean;
    visualDensity?: VisualDensityLike;
    shape?: ShapeBorderLike;
    style?: ListTileStyleLike;
    selectedColor?: ColorLike;
    iconColor?: ColorLike;
    textColor?: ColorLike;
    titleTextStyle?: TextStyleLike;
    subtitleTextStyle?: TextStyleLike;
    leadingAndTrailingTextStyle?: TextStyleLike;
    contentPadding?: EdgeInsetsLike;
    enabled?: boolean;
    selected?: boolean;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    splashColor?: ColorLike;
    tileColor?: ColorLike;
    selectedTileColor?: ColorLike;
    enableFeedback?: boolean;
    horizontalTitleGap?: number;
    minVerticalPadding?: number;
    minLeadingWidth?: number;
    minTileHeight?: number;
    titleAlignment?: ListTileTitleAlignmentLike;
    autofocus?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    onTap?: string | AppletCallback;
    onPressed?: string | AppletCallback;
    onLongPress?: string | AppletCallback;
    onFocusChange?: string | AppletCallback<boolean>;
  }

  export interface ExpansionTileProps {
    leading?: AppletChild;
    title?: AppletChild;
    subtitle?: AppletChild;
    trailing?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    children?: AppletChildren;
    showTrailingIcon?: boolean;
    initiallyExpanded?: boolean;
    maintainState?: boolean;
    tilePadding?: EdgeInsetsLike;
    expandedCrossAxisAlignment?: Exclude<CrossAxisAlignmentLike, "baseline">;
    expandedAlignment?: AlignmentLike;
    childrenPadding?: EdgeInsetsLike;
    backgroundColor?: ColorLike;
    collapsedBackgroundColor?: ColorLike;
    textColor?: ColorLike;
    collapsedTextColor?: ColorLike;
    iconColor?: ColorLike;
    collapsedIconColor?: ColorLike;
    shape?: ShapeBorderLike;
    collapsedShape?: ShapeBorderLike;
    clipBehavior?: ClipLike;
    controlAffinity?: ListTileControlAffinityLike;
    dense?: boolean;
    splashColor?: ColorLike;
    visualDensity?: VisualDensityLike;
    minTileHeight?: number;
    enableFeedback?: boolean;
    enabled?: boolean;
    expansionAnimationStyle?: AnimationStyleLike;
    animationStyle?: AnimationStyleLike;
    onExpansionChanged?: string | AppletCallback<boolean>;
  }

  export type ExpansionPanelValueLike = string | number | boolean;
  export interface ExpansionPanelCallbackPayload {
    index: number;
    panelIndex: number;
    isExpanded: boolean;
    expanded: boolean;
    value?: ExpansionPanelValueLike | null;
  }
  export interface ExpansionPanelProps {
    header?: AppletChild;
    title?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    expandedHeader?: AppletChild;
    openHeader?: AppletChild;
    selectedHeader?: AppletChild;
    body?: AppletChild;
    content?: AppletChild;
    child?: AppletChild;
    isExpanded?: boolean;
    expanded?: boolean;
    open?: boolean;
    canTapOnHeader?: boolean;
    tapHeader?: boolean;
    headerTap?: boolean;
    backgroundColor?: ColorLike;
    splashColor?: ColorLike;
    highlightColor?: ColorLike;
    radio?: boolean;
    value?: ExpansionPanelValueLike;
    id?: ExpansionPanelValueLike;
    key?: ExpansionPanelValueLike;
    name?: ExpansionPanelValueLike;
  }
  export interface ExpansionPanelListProps {
    children?: ExpansionPanelProps[];
    panels?: ExpansionPanelProps[];
    items?: ExpansionPanelProps[];
    radio?: boolean;
    variant?: "base" | "radio";
    type?: "base" | "radio";
    expansionCallback?: AppletActionLike<ExpansionPanelCallbackPayload>;
    onExpansionChanged?: AppletActionLike<ExpansionPanelCallbackPayload>;
    onChanged?: AppletActionLike<ExpansionPanelCallbackPayload>;
    animationDuration?: LayoutDurationLike;
    duration?: LayoutDurationLike;
    initialOpenPanelValue?: ExpansionPanelValueLike;
    initialValue?: ExpansionPanelValueLike;
    openValue?: ExpansionPanelValueLike;
    value?: ExpansionPanelValueLike;
    expandedHeaderPadding?: EdgeInsetsLike;
    headerPadding?: EdgeInsetsLike;
    dividerColor?: ColorLike;
    elevation?: number;
    expandIconColor?: ColorLike;
    iconColor?: ColorLike;
    materialGapSize?: number;
    gapSize?: number;
  }

  export interface ChipProps {
    avatar?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    labelStyle?: TextStyleLike;
    labelPadding?: EdgeInsetsLike;
    deleteIcon?: AppletChild;
    onDeleted?: string | AppletCallback;
    deleteIconColor?: ColorLike;
    deleteButtonTooltipMessage?: string;
    deleteTooltip?: string;
    side?: ColorLike | { color?: ColorLike; width?: number };
    shape?: ShapeBorderLike | "stadium" | "pill" | "circle" | "rounded" | "rectangle" | "rect";
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    clipBehavior?: ClipLike;
    autofocus?: boolean;
    color?: ColorLike;
    backgroundColor?: ColorLike;
    padding?: EdgeInsetsLike;
    visualDensity?: VisualDensityLike;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    iconTheme?: Record<string, unknown>;
    avatarBoxConstraints?: BoxConstraintsLike;
    deleteIconBoxConstraints?: BoxConstraintsLike;
    chipAnimationStyle?: ChipAnimationStyleLike;
    animationStyle?: ChipAnimationStyleLike;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
  }

  export interface ActionChipProps extends Omit<ChipProps, "deleteIcon" | "onDeleted" | "deleteIconColor" | "deleteButtonTooltipMessage" | "deleteTooltip" | "deleteIconBoxConstraints"> {
    onPressed?: string | AppletCallback;
    onTap?: string | AppletCallback;
    pressElevation?: number;
    tooltip?: string;
    disabledColor?: ColorLike;
    elevated?: boolean;
    variant?: "flat" | "elevated";
  }

  export interface SelectableChipProps extends ChipProps {
    selected?: boolean;
    onSelected?: string | AppletCallback<boolean>;
    onChanged?: string | AppletCallback<boolean>;
    pressElevation?: number;
    disabledColor?: ColorLike;
    selectedColor?: ColorLike;
    selectedShadowColor?: ColorLike;
    tooltip?: string;
    showCheckmark?: boolean;
    checkmarkColor?: ColorLike;
    avatarBorder?: ShapeBorderLike | "stadium" | "pill" | "circle" | "rounded" | "rectangle" | "rect";
    elevated?: boolean;
    variant?: "flat" | "elevated";
  }

  export interface InputChipProps extends SelectableChipProps {
    enabled?: boolean;
    isEnabled?: boolean;
    onPressed?: string | AppletCallback;
    onTap?: string | AppletCallback;
  }

  export interface ElevatedChipFactory<TProps> {
    (props?: TProps): AppletNode;
    elevated(props?: TProps): AppletNode;
  }

  export interface SelectionTileProps {
    title?: AppletChild;
    subtitle?: AppletChild;
    secondary?: AppletChild;
    leading?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    selected?: boolean;
    controlAffinity?: ListTileControlAffinityLike;
    contentPadding?: EdgeInsetsLike;
    tileColor?: ColorLike;
    selectedTileColor?: ColorLike;
    isThreeLine?: boolean;
    dense?: boolean;
    shape?: ShapeBorderLike;
    visualDensity?: VisualDensityLike;
    enableFeedback?: boolean;
    horizontalTitleGap?: number;
    minVerticalPadding?: number;
    minLeadingWidth?: number;
    minTileHeight?: number;
    titleAlignment?: ListTileTitleAlignmentLike;
    onFocusChange?: string | AppletCallback<boolean>;
  }

  export interface SwitchProps {
    value?: boolean;
    enabled?: boolean;
    adaptive?: boolean;
    activeThumbColor?: ColorLike;
    activeColor?: ColorLike;
    activeTrackColor?: ColorLike;
    inactiveThumbColor?: ColorLike;
    inactiveTrackColor?: ColorLike;
    activeThumbImage?: unknown;
    inactiveThumbImage?: unknown;
    thumbColor?: WidgetStatePropertyLike<ColorLike>;
    trackColor?: WidgetStatePropertyLike<ColorLike>;
    trackOutlineColor?: WidgetStatePropertyLike<ColorLike>;
    trackOutlineWidth?: WidgetStatePropertyLike<number>;
    thumbIcon?: WidgetStatePropertyLike<string | { icon?: string; name?: string; data?: string; color?: ColorLike; size?: number }>;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    dragStartBehavior?: DragStartBehaviorLike;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    splashRadius?: number;
    autofocus?: boolean;
    padding?: EdgeInsetsLike;
    onChanged?: string | AppletCallback<boolean>;
    onFocusChange?: string | AppletCallback<boolean>;
  }

  export interface SwitchListTileProps extends SwitchProps, SelectionTileProps {}

  export interface CheckboxProps {
    value?: boolean | null;
    tristate?: boolean;
    enabled?: boolean;
    adaptive?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    activeColor?: ColorLike;
    fillColor?: WidgetStatePropertyLike<ColorLike>;
    checkColor?: ColorLike;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    splashRadius?: number;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    visualDensity?: VisualDensityLike;
    autofocus?: boolean;
    shape?: ShapeBorderLike;
    side?: ColorLike | { color?: ColorLike; width?: number };
    isError?: boolean;
    error?: boolean;
    semanticLabel?: string;
    onChanged?: string | AppletCallback<boolean | null>;
  }

  export interface CheckboxListTileProps extends CheckboxProps, SelectionTileProps {
    checkboxShape?: ShapeBorderLike;
    checkboxSemanticLabel?: string;
    checkboxScaleFactor?: number;
    onTap?: string | AppletCallback<boolean | null>;
  }

  export interface RadioProps {
    value?: unknown;
    groupValue?: unknown;
    enabled?: boolean;
    adaptive?: boolean;
    toggleable?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    activeColor?: ColorLike;
    fillColor?: WidgetStatePropertyLike<ColorLike>;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    splashRadius?: number;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    visualDensity?: VisualDensityLike;
    autofocus?: boolean;
    backgroundColor?: WidgetStatePropertyLike<ColorLike>;
    side?: ColorLike | { color?: ColorLike; width?: number };
    innerRadius?: WidgetStatePropertyLike<number>;
    onChanged?: string | AppletCallback<unknown>;
  }

  export interface RadioListTileProps extends RadioProps, SelectionTileProps {
    radioScaleFactor?: number;
    radioBackgroundColor?: WidgetStatePropertyLike<ColorLike>;
    radioSide?: ColorLike | { color?: ColorLike; width?: number };
    radioInnerRadius?: WidgetStatePropertyLike<number>;
    onTap?: string | AppletCallback<unknown>;
  }

  export type RangeValuesLike =
    | [number, number]
    | { start?: number; end?: number; lower?: number; upper?: number; minValue?: number; maxValue?: number };
  export type RangeLabelsLike = [string, string] | { start?: string; end?: string; lower?: string; upper?: string } | boolean;
  export type SliderSemanticFormatterLike =
    | string
    | { prefix?: string; suffix?: string; decimals?: number };

  export interface SliderProps {
    value?: number;
    secondaryTrackValue?: number;
    min?: number;
    max?: number;
    divisions?: number;
    label?: string;
    enabled?: boolean;
    adaptive?: boolean;
    activeColor?: ColorLike;
    inactiveColor?: ColorLike;
    secondaryActiveColor?: ColorLike;
    thumbColor?: ColorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    semanticFormatter?: SliderSemanticFormatterLike;
    semanticFormatterCallback?: SliderSemanticFormatterLike;
    autofocus?: boolean;
    allowedInteraction?: SliderInteractionLike;
    padding?: EdgeInsetsLike;
    showValueIndicator?: ShowValueIndicatorLike;
    onChanged?: string | AppletCallback<number>;
    onChangeStart?: string | AppletCallback<number>;
    onStart?: string | AppletCallback<number>;
    onChangeEnd?: string | AppletCallback<number>;
    onEnd?: string | AppletCallback<number>;
  }

  export interface RangeSliderProps {
    values?: RangeValuesLike;
    start?: number;
    end?: number;
    lower?: number;
    upper?: number;
    minValue?: number;
    maxValue?: number;
    min?: number;
    max?: number;
    divisions?: number;
    labels?: RangeLabelsLike;
    enabled?: boolean;
    activeColor?: ColorLike;
    inactiveColor?: ColorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    mouseCursor?: WidgetStatePropertyLike<MouseCursorLike>;
    cursor?: WidgetStatePropertyLike<MouseCursorLike>;
    semanticFormatter?: SliderSemanticFormatterLike;
    semanticFormatterCallback?: SliderSemanticFormatterLike;
    padding?: EdgeInsetsLike;
    onChanged?: string | AppletCallback<{ start: number; end: number }>;
    onChangeStart?: string | AppletCallback<{ start: number; end: number }>;
    onStart?: string | AppletCallback<{ start: number; end: number }>;
    onChangeEnd?: string | AppletCallback<{ start: number; end: number }>;
    onEnd?: string | AppletCallback<{ start: number; end: number }>;
  }

  export interface AdaptiveWidgetFactory<TProps> {
    (props?: TProps): AppletNode;
    adaptive(props?: TProps): AppletNode;
  }

  export interface AdaptiveChildWidgetFactory<TProps> {
    (first?: AppletChild | TProps, second?: TProps): AppletNode;
    adaptive(first?: AppletChild | TProps, second?: TProps): AppletNode;
  }

  export interface ButtonSegmentProps {
    value?: unknown;
    icon?: AppletChild;
    label?: AppletChild;
    child?: AppletChild;
    text?: AppletChild;
    tooltip?: string;
    enabled?: boolean;
  }

  export interface SegmentedButtonProps {
    segments?: ButtonSegmentProps[];
    children?: ButtonSegmentProps[];
    selected?: unknown | unknown[];
    value?: unknown | unknown[];
    emptySelectionAllowed?: boolean;
    multiSelectionEnabled?: boolean;
    multi?: boolean;
    showSelectedIcon?: boolean;
    selectedIcon?: AppletChild;
    expandedInsets?: EdgeInsetsLike;
    style?: ButtonStyleLike;
    direction?: "horizontal" | "vertical";
    axis?: "horizontal" | "vertical";
    enabled?: boolean;
    onSelectionChanged?: string | AppletCallback<unknown[]>;
    onChanged?: string | AppletCallback<unknown[]>;
  }

  export interface ToggleButtonsPayload {
    index: number;
    selected: boolean | null;
    isSelected: boolean[];
    selectedIndexes: number[];
  }

  export interface ToggleButtonsProps {
    children?: AppletChild[];
    items?: AppletChild[];
    buttons?: AppletChild[];
    isSelected?: boolean[];
    selected?: number | number[] | boolean[];
    value?: number | number[] | boolean[];
    enabled?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    textStyle?: TextStyleLike;
    style?: TextStyleLike;
    constraints?: BoxConstraintsLike;
    color?: ColorLike;
    foregroundColor?: ColorLike;
    selectedColor?: ColorLike;
    disabledColor?: ColorLike;
    fillColor?: ColorLike;
    backgroundColor?: ColorLike;
    focusColor?: ColorLike;
    highlightColor?: ColorLike;
    hoverColor?: ColorLike;
    splashColor?: ColorLike;
    renderBorder?: boolean;
    borderColor?: ColorLike;
    selectedBorderColor?: ColorLike;
    disabledBorderColor?: ColorLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    borderWidth?: number;
    width?: number;
    direction?: "horizontal" | "vertical";
    axis?: "horizontal" | "vertical";
    verticalDirection?: "up" | "down" | "reverse" | "forward";
    onPressed?: string | AppletCallback<ToggleButtonsPayload>;
    onChanged?: string | AppletCallback<ToggleButtonsPayload>;
    onSelected?: string | AppletCallback<ToggleButtonsPayload>;
  }

  export type DropdownMenuCloseBehaviorLike = "all" | "self" | "none";
  export type PopupMenuPositionLike = "over" | "under" | "below";

  export interface DropdownMenuItemProps {
    value?: unknown;
    label?: AppletChild;
    text?: AppletChild;
    child?: AppletChild;
    enabled?: boolean;
    alignment?: AlignmentLike;
    onTap?: string | AppletCallback<void>;
  }

  export interface DropdownButtonProps {
    value?: unknown;
    hint?: AppletChild;
    disabledHint?: AppletChild;
    items?: DropdownMenuItemProps[];
    children?: DropdownMenuItemProps[];
    enabled?: boolean;
    isDense?: boolean;
    isExpanded?: boolean;
    itemHeight?: number;
    menuWidth?: number;
    menuMaxHeight?: number;
    elevation?: number;
    style?: TextStyleLike;
    textStyle?: TextStyleLike;
    underline?: AppletChild;
    icon?: AppletChild;
    iconDisabledColor?: ColorLike;
    iconEnabledColor?: ColorLike;
    iconSize?: number;
    focusColor?: ColorLike;
    autofocus?: boolean;
    dropdownColor?: ColorLike;
    enableFeedback?: boolean;
    alignment?: AlignmentLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    padding?: EdgeInsetsLike;
    barrierDismissible?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    dropdownMenuItemMouseCursor?: MouseCursorLike;
    itemCursor?: MouseCursorLike;
    onTap?: string | AppletCallback<void>;
    onChanged?: string | AppletCallback<unknown>;
  }

  export interface DropdownMenuEntryProps {
    value?: unknown;
    label?: string;
    text?: string;
    labelWidget?: AppletChild;
    child?: AppletChild;
    leadingIcon?: AppletChild;
    trailingIcon?: AppletChild;
    enabled?: boolean;
    style?: ButtonStyleLike;
  }

  export interface DropdownMenuProps {
    enabled?: boolean;
    width?: number;
    menuHeight?: number;
    leadingIcon?: AppletChild;
    prefixIcon?: AppletChild;
    trailingIcon?: AppletChild;
    suffixIcon?: AppletChild;
    showTrailingIcon?: boolean;
    label?: AppletChild;
    hint?: string;
    hintText?: string;
    helperText?: string;
    errorText?: string;
    selectedTrailingIcon?: AppletChild;
    enableFilter?: boolean;
    enableSearch?: boolean;
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    textStyle?: TextStyleLike;
    style?: TextStyleLike;
    textAlign?: "left" | "right" | "center" | "justify" | "start" | "end";
    inputDecorationTheme?: InputDecorationProps;
    decoration?: InputDecorationProps;
    menuStyle?: MenuStyleLike;
    initialSelection?: unknown;
    value?: unknown;
    requestFocusOnTap?: boolean;
    selectOnly?: boolean;
    expandedInsets?: EdgeInsetsLike;
    alignmentOffset?: OffsetLike;
    dropdownMenuEntries?: DropdownMenuEntryProps[];
    entries?: DropdownMenuEntryProps[];
    items?: DropdownMenuEntryProps[];
    closeBehavior?: DropdownMenuCloseBehaviorLike;
    maxLines?: number;
    textInputAction?: "done" | "go" | "next" | "search" | "send" | "newline";
    cursorHeight?: number;
    restorationId?: string;
    scrollPadding?: EdgeInsetsLike;
    onSelected?: string | AppletCallback<unknown>;
    onChanged?: string | AppletCallback<unknown>;
  }

  export interface PopupMenuItemProps {
    value?: unknown;
    label?: AppletChild;
    text?: AppletChild;
    child?: AppletChild;
    enabled?: boolean;
    checked?: boolean;
    selected?: boolean;
    height?: number;
    padding?: EdgeInsetsLike;
    textStyle?: TextStyleLike;
    labelTextStyle?: WidgetStatePropertyLike<TextStyleLike>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    divider?: boolean;
    onTap?: string | AppletCallback<void>;
    onPressed?: string | AppletCallback<void>;
  }

  export interface PopupMenuDividerProps {
    divider?: true;
    height?: number;
    thickness?: number;
    indent?: number;
    endIndent?: number;
    radius?: number | Record<string, number>;
    color?: ColorLike;
  }

  export interface PopupMenuButtonProps {
    initialValue?: unknown;
    value?: unknown;
    tooltip?: string;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    padding?: EdgeInsetsLike;
    menuPadding?: EdgeInsetsLike;
    child?: AppletChild;
    icon?: AppletChild;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    splashRadius?: number;
    iconSize?: number;
    offset?: OffsetLike;
    enabled?: boolean;
    shape?: ShapeBorderLike;
    color?: ColorLike;
    backgroundColor?: ColorLike;
    iconColor?: ColorLike;
    enableFeedback?: boolean;
    constraints?: BoxConstraintsLike;
    position?: PopupMenuPositionLike;
    clipBehavior?: ClipLike;
    useRootNavigator?: boolean;
    popUpAnimationStyle?: AnimationStyleLike;
    animationStyle?: AnimationStyleLike;
    style?: ButtonStyleLike;
    requestFocus?: boolean;
    items?: Array<PopupMenuItemProps | PopupMenuDividerProps>;
    children?: Array<PopupMenuItemProps | PopupMenuDividerProps>;
    onOpened?: string | AppletCallback<void>;
    onOpen?: string | AppletCallback<void>;
    onSelected?: string | AppletCallback<unknown>;
    onCanceled?: string | AppletCallback<void>;
    onCancel?: string | AppletCallback<void>;
  }

  export interface MenuButtonProps {
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    leadingIcon?: AppletChild;
    trailingIcon?: AppletChild;
    closeOnActivate?: boolean;
    style?: ButtonStyleLike;
    clipBehavior?: ClipLike;
    onHover?: string | AppletCallback<boolean>;
    onFocusChange?: string | AppletCallback<boolean>;
  }

  export interface MenuItemButtonProps extends MenuButtonProps {
    requestFocusOnHover?: boolean;
    autofocus?: boolean;
    semanticsLabel?: string;
    overflowAxis?: "horizontal" | "vertical";
    onPressed?: string | AppletCallback<void>;
    onTap?: string | AppletCallback<void>;
  }

  export interface CheckboxMenuButtonProps extends MenuButtonProps {
    value?: boolean | null;
    tristate?: boolean;
    isError?: boolean;
    onChanged?: string | AppletCallback<boolean | null>;
    onTap?: string | AppletCallback<boolean | null>;
  }

  export interface RadioMenuButtonProps extends MenuButtonProps {
    value?: unknown;
    groupValue?: unknown;
    toggleable?: boolean;
    onChanged?: string | AppletCallback<unknown>;
    onTap?: string | AppletCallback<unknown>;
  }

  export interface MenuBarProps {
    children?: AppletChildren;
    style?: MenuStyleLike;
    menuStyle?: MenuStyleLike;
    clipBehavior?: ClipLike;
  }

  export interface MenuAnchorProps {
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    menuChildren?: AppletChildren;
    items?: AppletChildren;
    style?: MenuStyleLike;
    menuStyle?: MenuStyleLike;
    alignmentOffset?: OffsetLike;
    reservedPadding?: EdgeInsetsLike;
    clipBehavior?: ClipLike;
    consumeOutsideTap?: boolean;
    crossAxisUnconstrained?: boolean;
    useRootOverlay?: boolean;
    animated?: boolean;
    passive?: boolean;
    onOpen?: string | AppletCallback<void>;
    onClose?: string | AppletCallback<void>;
  }

  export interface SubmenuButtonProps extends MenuButtonProps {
    menuChildren?: AppletChildren;
    children?: AppletChildren;
    submenuIcon?: AppletChild;
    menuStyle?: MenuStyleLike;
    alignmentOffset?: OffsetLike;
    useRootOverlay?: boolean;
    hoverOpenDelay?: number | Record<string, number>;
    animated?: boolean;
    onOpen?: string | AppletCallback<void>;
    onClose?: string | AppletCallback<void>;
  }

  export type StrokeCapLike = "butt" | "round" | "rounded" | "square";
  export type CurveLike = "linear" | "ease" | "easeIn" | "ease_in" | "easeOut" | "ease_out" | "easeInOut" | "ease_in_out" | "fastOutSlowIn" | "fast_out_slow_in" | "bounceOut" | "bounce_out" | "elasticOut" | "elastic_out";
  export type DurationLike = number | Record<string, number>;
  export type SizeLike = number | [number, number] | { width?: number; height?: number; w?: number; h?: number };
  export type RefreshIndicatorTriggerModeLike =
    | "anywhere"
    | "any"
    | "onEdge"
    | "on_edge"
    | "edge";
  export type RefreshIndicatorStatusLike =
    | "drag"
    | "armed"
    | "snap"
    | "refresh"
    | "done"
    | "canceled"
    | null;
  export type ScrollNotificationPredicateLike = "default" | "any" | "all" | number;

  export interface LinearProgressIndicatorProps {
    value?: number;
    backgroundColor?: ColorLike;
    color?: ColorLike;
    valueColor?: ColorLike;
    minHeight?: number;
    semanticsLabel?: string;
    semanticLabel?: string;
    semanticsValue?: string | number;
    semanticValue?: string | number;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    stopIndicatorColor?: ColorLike;
    stopIndicatorRadius?: number;
    trackGap?: number;
  }

  export interface CircularProgressIndicatorProps {
    value?: number;
    adaptive?: boolean;
    backgroundColor?: ColorLike;
    color?: ColorLike;
    valueColor?: ColorLike;
    strokeWidth?: number;
    strokeAlign?: number;
    semanticsLabel?: string;
    semanticLabel?: string;
    semanticsValue?: string | number;
    semanticValue?: string | number;
    strokeCap?: StrokeCapLike;
    constraints?: BoxConstraintsLike;
    trackGap?: number;
    padding?: EdgeInsetsLike;
  }

  export interface RefreshIndicatorProps {
    child?: AppletChild;
    adaptive?: boolean;
    noSpinner?: boolean;
    spinner?: boolean;
    variant?: "noSpinner" | "no_spinner" | "material" | "adaptive";
    displacement?: number;
    edgeOffset?: number;
    color?: ColorLike;
    backgroundColor?: ColorLike;
    notificationPredicate?: ScrollNotificationPredicateLike;
    notificationDepth?: number;
    depth?: number;
    semanticsLabel?: string;
    semanticLabel?: string;
    semanticsValue?: string;
    semanticValue?: string;
    strokeWidth?: number;
    triggerMode?: RefreshIndicatorTriggerModeLike;
    elevation?: number;
    onRefresh?: string | AppletCallback<void>;
    onStatusChange?: string | AppletCallback<RefreshIndicatorStatusLike>;
  }

  export type VerticalDirectionLike = "up" | "down" | "reverse" | "forward";
  export type OverflowBarAlignmentLike = "start" | "end" | "center";
  export type SemanticsRoleLike = "dialog" | "alertDialog" | "alert_dialog" | "alert-dialog" | "alert" | "status" | "none";
  export type SnackBarBehaviorLike = "fixed" | "floating";
  export type HitTestBehaviorLike = "deferToChild" | "defer_to_child" | "defer" | "opaque" | "translucent";
  export type DismissDirectionLike = "horizontal" | "vertical" | "startToEnd" | "start_to_end" | "start-to-end" | "endToStart" | "end_to_start" | "end-to-start" | "up" | "down" | "none";
  export type DateTimeLike = string | number | Date | { year?: number; month?: number; day?: number };
  export type TimeOfDayLike = string | { hour?: number; minute?: number };
  export type DatePickerEntryModeLike = "calendar" | "input" | "calendarOnly" | "calendar_only" | "inputOnly" | "input_only";
  export type TimePickerEntryModeLike = "dial" | "input" | "dialOnly" | "dial_only" | "inputOnly" | "input_only";

  export interface AlertDialogProps {
    icon?: AppletChild;
    iconPadding?: EdgeInsetsLike;
    iconColor?: ColorLike;
    title?: AppletChild;
    titlePadding?: EdgeInsetsLike;
    titleTextStyle?: TextStyleLike;
    content?: AppletChild;
    child?: AppletChild;
    contentPadding?: EdgeInsetsLike;
    contentTextStyle?: TextStyleLike;
    actions?: AppletChildren;
    actionsPadding?: EdgeInsetsLike;
    actionsAlignment?: MainAxisAlignmentLike;
    actionsOverflowAlignment?: OverflowBarAlignmentLike;
    actionsOverflowDirection?: VerticalDirectionLike;
    actionsOverflowButtonSpacing?: number;
    buttonPadding?: EdgeInsetsLike;
    backgroundColor?: ColorLike;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    semanticLabel?: string;
    insetPadding?: EdgeInsetsLike;
    clipBehavior?: ClipLike;
    shape?: ShapeBorderLike;
    alignment?: AlignmentLike;
    constraints?: BoxConstraintsLike;
    scrollable?: boolean;
    adaptive?: boolean;
    insetAnimationDuration?: DurationLike;
    insetAnimationCurve?: CurveLike;
    visible?: boolean;
    onDismissed?: string | AppletCallback<void>;
  }

  export interface DialogProps {
    child?: AppletChild;
    fullscreen?: boolean;
    variant?: "fullscreen" | "dialog";
    backgroundColor?: ColorLike;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    insetAnimationDuration?: DurationLike;
    insetAnimationCurve?: CurveLike;
    insetPadding?: EdgeInsetsLike;
    clipBehavior?: ClipLike;
    shape?: ShapeBorderLike;
    alignment?: AlignmentLike;
    constraints?: BoxConstraintsLike;
    semanticsRole?: SemanticsRoleLike;
  }

  export interface BottomSheetProps {
    child?: AppletChild;
    showDragHandle?: boolean;
    dragHandleSize?: SizeLike;
    dragHandleColor?: ColorLike;
    backgroundColor?: ColorLike;
    shadowColor?: ColorLike;
    elevation?: number;
    shape?: ShapeBorderLike;
    clipBehavior?: ClipLike;
    constraints?: BoxConstraintsLike;
    onClosing?: string | AppletCallback<void>;
  }

  export interface SimpleDialogProps {
    title?: AppletChild;
    titlePadding?: EdgeInsetsLike;
    titleTextStyle?: TextStyleLike;
    children?: AppletChildren;
    contentPadding?: EdgeInsetsLike;
    contentTextStyle?: TextStyleLike;
    backgroundColor?: ColorLike;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    semanticLabel?: string;
    insetPadding?: EdgeInsetsLike;
    clipBehavior?: ClipLike;
    shape?: ShapeBorderLike;
    alignment?: AlignmentLike;
    constraints?: BoxConstraintsLike;
  }

  export interface SnackBarActionProps {
    label?: string;
    text?: string;
    textColor?: ColorLike;
    disabledTextColor?: ColorLike;
    backgroundColor?: ColorLike;
    disabledBackgroundColor?: ColorLike;
    onPressed?: string | AppletCallback<void>;
    onTap?: string | AppletCallback<void>;
  }

  export interface SnackBarProps {
    content?: AppletChild;
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    backgroundColor?: ColorLike;
    elevation?: number;
    margin?: EdgeInsetsLike;
    padding?: EdgeInsetsLike;
    width?: number;
    shape?: ShapeBorderLike;
    hitTestBehavior?: HitTestBehaviorLike;
    behavior?: SnackBarBehaviorLike | HitTestBehaviorLike;
    snackBarBehavior?: SnackBarBehaviorLike;
    action?: SnackBarActionProps;
    actionOverflowThreshold?: number;
    showCloseIcon?: boolean;
    closeIconColor?: ColorLike;
    duration?: DurationLike;
    persist?: boolean;
    onVisible?: string | AppletCallback<void>;
    dismissDirection?: DismissDirectionLike;
    clipBehavior?: ClipLike;
  }

  export interface DatePickerDialogProps {
    initialDate?: DateTimeLike;
    firstDate?: DateTimeLike;
    lastDate?: DateTimeLike;
    helpText?: string;
    cancelText?: string;
    confirmText?: string;
    initialEntryMode?: DatePickerEntryModeLike;
  }

  export interface TimePickerDialogProps {
    initialTime?: TimeOfDayLike;
    helpText?: string;
    cancelText?: string;
    confirmText?: string;
    initialEntryMode?: TimePickerEntryModeLike;
  }

  export type ScrollbarOrientationLike = "left" | "right" | "top" | "bottom";

  export interface SearchBarProps {
    child?: AppletChild;
    hintText?: string;
    hint?: string;
    leading?: AppletChild;
    trailing?: AppletChildren;
    enabled?: boolean;
    constraints?: BoxConstraintsLike;
    elevation?: number;
    backgroundColor?: WidgetStatePropertyLike<ColorLike>;
    shadowColor?: WidgetStatePropertyLike<ColorLike>;
    surfaceTintColor?: WidgetStatePropertyLike<ColorLike>;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    side?: ColorLike | { color?: ColorLike; width?: number };
    shape?: ShapeBorderLike;
    padding?: EdgeInsetsLike;
    textStyle?: TextStyleLike;
    style?: TextStyleLike;
    hintStyle?: TextStyleLike;
    textCapitalization?: "none" | "characters" | "words" | "sentences";
    autoFocus?: boolean;
    autofocus?: boolean;
    readOnly?: boolean;
    textInputAction?: "done" | "go" | "next" | "search" | "send" | "newline";
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    scrollPadding?: EdgeInsetsLike;
    onTap?: string | AppletCallback<void>;
    onTapOutside?: string | AppletCallback<unknown>;
    onChanged?: string | AppletCallback<string>;
    onSubmitted?: string | AppletCallback<string>;
  }

  export interface SearchAnchorProps extends SearchBarProps {
    isFullScreen?: boolean;
    fullscreen?: boolean;
    view?: AppletChild;
    viewChild?: AppletChild;
    viewLeading?: AppletChild;
    viewTrailing?: AppletChildren;
    viewHintText?: string;
    viewBackgroundColor?: ColorLike;
    viewElevation?: number;
    viewSurfaceTintColor?: ColorLike;
    viewSide?: ColorLike | { color?: ColorLike; width?: number };
    viewShape?: ShapeBorderLike;
    viewBarPadding?: EdgeInsetsLike;
    headerHeight?: number;
    viewHeaderHeight?: number;
    headerTextStyle?: TextStyleLike;
    viewHeaderTextStyle?: TextStyleLike;
    headerHintStyle?: TextStyleLike;
    viewHeaderHintStyle?: TextStyleLike;
    dividerColor?: ColorLike;
    viewConstraints?: BoxConstraintsLike;
    viewPadding?: EdgeInsetsLike;
    shrinkWrap?: boolean;
    viewOnChanged?: string | AppletCallback<string>;
    viewOnSubmitted?: string | AppletCallback<string>;
    viewOnClose?: string | AppletCallback<void>;
    viewOnOpen?: string | AppletCallback<void>;
    onClose?: string | AppletCallback<void>;
    onOpen?: string | AppletCallback<void>;
    suggestions?: AppletChildren;
    suggestionChildren?: AppletChildren;
    items?: AppletChildren;
  }

  export interface ScrollbarProps {
    child?: AppletChild;
    thumbVisibility?: boolean;
    trackVisibility?: boolean;
    thickness?: number;
    radius?: number | { x?: number; y?: number; horizontal?: number; vertical?: number; radius?: number };
    interactive?: boolean;
    scrollbarOrientation?: ScrollbarOrientationLike;
    orientation?: ScrollbarOrientationLike;
  }

  export type ThemeModeLike = "system" | "light" | "dark";
  export type MaterialTypeLike = "canvas" | "card" | "circle" | "button" | "transparency" | "transparent";
  export type BannerLocationLike =
    | "topStart"
    | "top_start"
    | "topLeft"
    | "top_left"
    | "topEnd"
    | "top_end"
    | "topRight"
    | "top_right"
    | "bottomStart"
    | "bottom_start"
    | "bottomLeft"
    | "bottom_left"
    | "bottomEnd"
    | "bottom_end"
    | "bottomRight"
    | "bottom_right";

  export interface MaterialAppProps {
    title?: string;
    debugShowCheckedModeBanner?: boolean;
    theme?: ThemeDataProps;
    darkTheme?: ThemeDataProps;
    themeMode?: ThemeModeLike;
    home?: AppletChild;
    child?: AppletChild;
  }

  export interface AnimatedThemeProps {
    child?: AppletChild;
    data?: ThemeDataProps;
    duration?: LayoutDurationLike;
    curve?: LayoutCurveLike;
    onEnd?: string | AppletCallback<void>;
  }

  export interface ScaffoldProps {
    appBar?: AppletChild;
    body?: AppletChild;
    child?: AppletChild;
    floatingActionButton?: AppletChild;
    bottomNavigationBar?: AppletChild;
    bottomSheet?: AppletChild | BottomSheetProps;
    drawer?: AppletChild;
    endDrawer?: AppletChild;
    backgroundColor?: ColorLike;
    resizeToAvoidBottomInset?: boolean;
    primary?: boolean;
    extendBody?: boolean;
    drawerBarrierDismissible?: boolean;
    extendBodyBehindAppBar?: boolean;
    drawerScrimColor?: ColorLike;
    drawerEdgeDragWidth?: number;
    drawerEnableOpenDragGesture?: boolean;
    endDrawerEnableOpenDragGesture?: boolean;
    restorationId?: string;
    persistentFooterButtons?: AppletChildren;
    snackBar?: SnackBarProps | AppletChild;
    snackbar?: SnackBarProps | AppletChild;
    dialog?: AlertDialogProps | DialogProps | DatePickerDialogProps | TimePickerDialogProps | AppletChild;
    alertDialog?: AlertDialogProps | AppletChild;
    modal?: DialogProps | AppletChild;
    onDrawerChanged?: string | AppletCallback<boolean>;
    onEndDrawerChanged?: string | AppletCallback<boolean>;
  }

  export interface AdaptiveNavigationScaffoldProps extends ScaffoldProps {
    navigationRail?: AppletChild;
    rail?: AppletChild;
    extendedNavigationRail?: AppletChild;
    largeNavigationRail?: AppletChild;
    wideNavigationRail?: AppletChild;
    extendedRail?: AppletChild;
    navigationBar?: AppletChild;
    bar?: AppletChild;
    railAppBar?: AppletChild;
    wideAppBar?: AppletChild;
    narrowWidth?: number;
    compactBreakpoint?: number;
    railBreakpoint?: number;
    largeWidth?: number;
    largeBreakpoint?: number;
    extendedRailBreakpoint?: number;
    duration?: LayoutDurationLike;
    animationDuration?: LayoutDurationLike;
    backgroundTransitionColor?: ColorLike;
    transitionColor?: ColorLike;
  }

  export interface AppBarProps {
    title?: AppletChild;
    leading?: AppletChild;
    actions?: AppletChildren;
    automaticallyImplyActions?: boolean;
    flexibleSpace?: AppletChild;
    bottom?: AppletChild;
    backgroundColor?: ColorLike;
    foregroundColor?: ColorLike;
    centerTitle?: boolean;
    automaticallyImplyLeading?: boolean;
    elevation?: number;
    scrolledUnderElevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    shape?: ShapeBorderLike;
    iconTheme?: Record<string, unknown>;
    actionsIconTheme?: Record<string, unknown>;
    primary?: boolean;
    excludeHeaderSemantics?: boolean;
    toolbarOpacity?: number;
    bottomOpacity?: number;
    toolbarHeight?: number;
    leadingWidth?: number;
    titleSpacing?: number;
    toolbarTextStyle?: TextStyleLike;
    titleTextStyle?: TextStyleLike;
    forceMaterialTransparency?: boolean;
    useDefaultSemanticsOrder?: boolean;
    clipBehavior?: ClipLike;
    actionsPadding?: EdgeInsetsLike;
    animateColor?: boolean;
  }

  export interface SliverAppBarProps extends AppBarProps {
    variant?: "small" | "medium" | "large";
    forceElevated?: boolean;
    collapsedHeight?: number;
    expandedHeight?: number;
    floating?: boolean;
    pinned?: boolean;
    snap?: boolean;
    stretch?: boolean;
    stretchTriggerOffset?: number;
  }

  export interface SelectionAreaProps {
    child?: AppletChild;
    selectionControls?: TextSelectionControlsLike;
    controls?: TextSelectionControlsLike;
    contextMenu?: boolean | "enabled" | "disabled" | "none" | "off";
    contextMenuBuilder?: boolean | "enabled" | "disabled" | "none" | "off";
    showContextMenu?: boolean;
    toolbar?: boolean | "enabled" | "disabled" | "none" | "off";
    showToolbar?: boolean;
    magnifier?: TextMagnifierConfigurationLike;
    magnifierConfiguration?: TextMagnifierConfigurationLike;
    enableMagnifier?: TextMagnifierConfigurationLike;
    onSelectionChanged?: AppletActionLike<string | null>;
    onChanged?: AppletActionLike<string | null>;
  }

  export interface MaterialProps {
    child?: AppletChild;
    type?: MaterialTypeLike;
    materialType?: MaterialTypeLike;
    color?: ColorLike;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    textStyle?: TextStyleLike;
    elevation?: number;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    shape?: ShapeBorderLike;
    borderOnForeground?: boolean;
    clipBehavior?: ClipLike;
    animationDuration?: DurationLike;
    animateColor?: boolean;
  }

  export interface InkWellProps {
    child?: AppletChild;
    onTap?: AppletActionLike<void>;
    onDoubleTap?: AppletActionLike<void>;
    onLongPress?: AppletActionLike<void>;
    onLongPressUp?: AppletActionLike<void>;
    onTapDown?: AppletActionLike<InkWellTapPayload>;
    onTapUp?: AppletActionLike<InkWellTapPayload>;
    onTapCancel?: AppletActionLike<void>;
    onSecondaryTap?: AppletActionLike<void>;
    onSecondaryTapDown?: AppletActionLike<InkWellTapPayload>;
    onSecondaryTapUp?: AppletActionLike<InkWellTapPayload>;
    onSecondaryTapCancel?: AppletActionLike<void>;
    onHighlightChanged?: AppletActionLike<boolean>;
    onHover?: AppletActionLike<boolean>;
    onFocusChange?: AppletActionLike<boolean>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    highlightColor?: ColorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    splashColor?: ColorLike;
    radius?: number;
    borderRadius?: number | Record<string, number>;
    customBorder?: ShapeBorderLike;
    shape?: ShapeBorderLike;
    enableFeedback?: boolean;
    excludeFromSemantics?: boolean;
    canRequestFocus?: boolean;
    autofocus?: boolean;
    hoverDuration?: DurationLike;
  }

  export interface InkWellTapPayload {
    x?: number;
    y?: number;
    localX?: number;
    localY?: number;
    kind?: string;
  }

  export interface CardProps {
    child?: AppletChild;
    variant?: "elevated" | "filled" | "outlined";
    color?: ColorLike;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    elevation?: number;
    shape?: ShapeBorderLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    side?: ColorLike | { color?: ColorLike; width?: number };
    outlineColor?: ColorLike;
    outlineWidth?: number;
    borderOnForeground?: boolean;
    margin?: EdgeInsetsLike;
    clipBehavior?: ClipLike;
    semanticContainer?: boolean;
    onTap?: string | AppletCallback<void>;
    onPressed?: string | AppletCallback<void>;
  }

  export interface CardFactory {
    (first?: AppletChild | CardProps, second?: CardProps): AppletNode;
    filled(first?: AppletChild | CardProps, second?: CardProps): AppletNode;
    outlined(first?: AppletChild | CardProps, second?: CardProps): AppletNode;
  }

  export interface GridTileProps {
    child?: AppletChild;
    header?: AppletChild;
    footer?: AppletChild;
  }

  export interface GridTileBarProps {
    backgroundColor?: ColorLike;
    leading?: AppletChild;
    title?: AppletChild;
    label?: AppletChild;
    subtitle?: AppletChild;
    trailing?: AppletChild;
  }

  export interface CircleAvatarProps {
    child?: AppletChild;
    radius?: number;
    minRadius?: number;
    maxRadius?: number;
    backgroundColor?: ColorLike;
    backgroundImage?: string | ImageProps;
    image?: string | ImageProps;
    background?: string | ImageProps;
    src?: string | ImageProps;
    foregroundImage?: string | ImageProps;
    avatarImage?: string | ImageProps;
    foreground?: string | ImageProps;
    photo?: string | ImageProps;
    foregroundColor?: ColorLike;
    onBackgroundImageError?: string | AppletCallback<CircleAvatarImageErrorPayload>;
    onForegroundImageError?: string | AppletCallback<CircleAvatarImageErrorPayload>;
    onImageError?: string | AppletCallback<CircleAvatarImageErrorPayload>;
    onError?: string | AppletCallback<CircleAvatarImageErrorPayload>;
  }

  export interface CircleAvatarImageErrorPayload {
    source: "background" | "foreground";
    error: string;
  }

  export interface BadgeProps {
    child?: AppletChild;
    label?: AppletChild;
    count?: number;
    maxCount?: number;
    isLabelVisible?: boolean;
    backgroundColor?: ColorLike;
    textColor?: ColorLike;
    smallSize?: number;
    largeSize?: number;
    textStyle?: TextStyleLike;
    padding?: EdgeInsetsLike;
    alignment?: AlignmentLike;
    offset?: OffsetLike;
  }

  export interface BadgeFactory {
    (first?: AppletChild | BadgeProps, second?: BadgeProps): AppletNode;
    count(count?: number, props?: BadgeProps): AppletNode;
    count(first?: AppletChild | BadgeProps, second?: BadgeProps): AppletNode;
  }

  export interface BannerProps {
    child?: AppletChild;
    message?: string;
    location?: BannerLocationLike;
    textDirection?: TextDirectionLike;
    layoutDirection?: TextDirectionLike;
    color?: ColorLike;
    textStyle?: TextStyleLike;
    shadow?: BoxShadowLike | ColorLike;
    boxShadow?: BoxShadowLike | ColorLike;
  }

  export interface MaterialBannerProps {
    content?: AppletChild;
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    contentTextStyle?: TextStyleLike;
    leading?: AppletChild;
    backgroundColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    shadowColor?: ColorLike;
    dividerColor?: ColorLike;
    elevation?: number;
    padding?: EdgeInsetsLike;
    margin?: EdgeInsetsLike;
    leadingPadding?: EdgeInsetsLike;
    forceActionsBelow?: boolean;
    overflowAlignment?: OverflowBarAlignmentLike;
    minActionBarHeight?: number;
    onVisible?: string | AppletCallback<void>;
    actions?: AppletChildren;
  }

  export interface DrawerProps {
    child?: AppletChild;
    backgroundColor?: ColorLike;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    shape?: ShapeBorderLike;
    width?: number;
    clipBehavior?: ClipLike;
    semanticLabel?: string;
  }

  export interface DrawerHeaderProps {
    child?: AppletChild;
    decoration?: Record<string, unknown>;
    margin?: EdgeInsetsLike;
    padding?: EdgeInsetsLike;
  }

  export interface DividerProps {
    height?: number;
    width?: number;
    thickness?: number;
    indent?: number;
    endIndent?: number;
    color?: ColorLike;
    radius?: number | Record<string, number>;
    borderRadius?: number | Record<string, number>;
  }

  export type NavigationDestinationLabelBehaviorLike =
    | "alwaysShow"
    | "always_show"
    | "show"
    | "onlyShowSelected"
    | "only_show_selected"
    | "selected"
    | "alwaysHide"
    | "always_hide"
    | "hide";
  export type NavigationRailLabelTypeLike = "none" | "selected" | "all";
  export type BottomNavigationBarTypeLike = "fixed" | "shifting";
  export type BottomNavigationBarLandscapeLayoutLike =
    | "spread"
    | "centered"
    | "center"
    | "linear";
  export type TabBarIndicatorSizeLike = "tab" | "label";
  export type TabAlignmentLike =
    | "start"
    | "startOffset"
    | "start_offset"
    | "fill"
    | "center";
  export type TabIndicatorAnimationLike = "linear" | "elastic";
  export type NotchedShapeLike =
    | "circular"
    | "circle"
    | "circularNotchedRectangle"
    | "circular_notched_rectangle";
  export type ScrollPhysicsLike =
    | "always"
    | "bouncing"
    | "clamping"
    | "never"
    | "page";

  export interface IconThemeLike {
    color?: ColorLike;
    size?: number;
    opacity?: number;
    fill?: number;
    weight?: number;
    grade?: number;
    opticalSize?: number;
    shadows?: TextShadowLike | TextShadowLike[];
    shadow?: TextShadowLike | ColorLike;
    applyTextScaling?: boolean;
  }

  export interface NavigationBarProps {
    destinations?: AppletChildren;
    children?: AppletChildren;
    selectedIndex?: number;
    animationDuration?: number | Record<string, number>;
    onDestinationSelected?: string | AppletCallback<number>;
    onChanged?: string | AppletCallback<number>;
    backgroundColor?: ColorLike;
    elevation?: number;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    indicatorColor?: ColorLike;
    indicatorShape?: ShapeBorderLike;
    height?: number;
    labelBehavior?: NavigationDestinationLabelBehaviorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    labelTextStyle?: WidgetStatePropertyLike<TextStyleLike>;
    labelPadding?: EdgeInsetsLike;
    maintainBottomViewPadding?: boolean;
  }

  export interface NavigationDestinationProps {
    icon?: AppletChild | string;
    selectedIcon?: AppletChild;
    label?: string;
    tooltip?: string;
    enabled?: boolean;
  }

  export interface NavigationRailDestinationProps {
    icon?: AppletChild | string;
    selectedIcon?: AppletChild;
    label?: AppletChild;
    padding?: EdgeInsetsLike;
  }

  export interface NavigationRailProps {
    destinations?: NavigationRailDestinationProps[] | AppletChildren;
    children?: NavigationRailDestinationProps[] | AppletChildren;
    selectedIndex?: number | null;
    onDestinationSelected?: string | AppletCallback<number>;
    onChanged?: string | AppletCallback<number>;
    extended?: boolean;
    labelType?: NavigationRailLabelTypeLike;
    backgroundColor?: ColorLike;
    leading?: AppletChild;
    trailing?: AppletChild;
    elevation?: number;
    groupAlignment?: number;
    selectedLabelStyle?: TextStyleLike;
    unselectedLabelStyle?: TextStyleLike;
    selectedIconTheme?: IconThemeLike;
    unselectedIconTheme?: IconThemeLike;
    minWidth?: number;
    minExtendedWidth?: number;
    useIndicator?: boolean;
    indicatorColor?: ColorLike;
    indicatorShape?: ShapeBorderLike;
    leadingAtTop?: boolean;
    trailingAtBottom?: boolean;
    scrollable?: boolean;
    mainAxisAlignment?: MainAxisAlignmentLike;
  }

  export interface NavigationDrawerProps {
    children?: AppletChildren;
    header?: AppletChild;
    footer?: AppletChild;
    selectedIndex?: number | null;
    onDestinationSelected?: string | AppletCallback<number>;
    onChanged?: string | AppletCallback<number>;
    backgroundColor?: ColorLike;
    shadowColor?: ColorLike;
    surfaceTintColor?: ColorLike;
    elevation?: number;
    indicatorColor?: ColorLike;
    indicatorShape?: ShapeBorderLike;
    tilePadding?: EdgeInsetsLike;
  }

  export interface NavigationDrawerDestinationProps {
    icon?: AppletChild | string;
    selectedIcon?: AppletChild;
    label?: AppletChild;
    backgroundColor?: ColorLike;
    enabled?: boolean;
  }

  export interface BottomNavigationBarItemProps {
    icon?: AppletChild | string;
    activeIcon?: AppletChild | string;
    label?: string;
    tooltip?: string;
    backgroundColor?: ColorLike;
  }

  export interface BottomNavigationBarProps {
    items?: BottomNavigationBarItemProps[];
    children?: BottomNavigationBarItemProps[];
    currentIndex?: number;
    selectedIndex?: number;
    onTap?: string | AppletCallback<number>;
    onChanged?: string | AppletCallback<number>;
    onDestinationSelected?: string | AppletCallback<number>;
    elevation?: number;
    type?: BottomNavigationBarTypeLike;
    barType?: BottomNavigationBarTypeLike;
    backgroundColor?: ColorLike;
    iconSize?: number;
    selectedItemColor?: ColorLike;
    fixedColor?: ColorLike;
    unselectedItemColor?: ColorLike;
    selectedIconTheme?: IconThemeLike;
    unselectedIconTheme?: IconThemeLike;
    selectedFontSize?: number;
    unselectedFontSize?: number;
    selectedLabelStyle?: TextStyleLike;
    unselectedLabelStyle?: TextStyleLike;
    showSelectedLabels?: boolean;
    showUnselectedLabels?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    enableFeedback?: boolean;
    landscapeLayout?: BottomNavigationBarLandscapeLayoutLike;
    useLegacyColorScheme?: boolean;
  }

  export interface BottomAppBarProps {
    child?: AppletChild;
    color?: ColorLike;
    elevation?: number;
    shape?: NotchedShapeLike;
    clipBehavior?: ClipLike;
    notchMargin?: number;
    height?: number;
    padding?: EdgeInsetsLike;
    surfaceTintColor?: ColorLike;
    shadowColor?: ColorLike;
  }

  export interface DefaultTabControllerProps {
    length?: number;
    initialIndex?: number;
    tabs?: AppletChildren;
    child?: AppletChild;
  }

  export interface TabBarProps {
    tabs?: AppletChildren;
    children?: AppletChildren;
    secondary?: boolean;
    isScrollable?: boolean;
    padding?: EdgeInsetsLike;
    indicatorColor?: ColorLike;
    automaticIndicatorColorAdjustment?: boolean;
    indicatorWeight?: number;
    indicatorPadding?: EdgeInsetsLike;
    indicator?: Record<string, unknown>;
    indicatorSize?: TabBarIndicatorSizeLike;
    dividerColor?: ColorLike;
    dividerHeight?: number;
    labelColor?: ColorLike;
    labelStyle?: TextStyleLike;
    labelPadding?: EdgeInsetsLike;
    unselectedLabelColor?: ColorLike;
    unselectedLabelStyle?: TextStyleLike;
    dragStartBehavior?: DragStartBehaviorLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    enableFeedback?: boolean;
    physics?: ScrollPhysicsLike;
    splashBorderRadius?: number | Record<string, number>;
    tabAlignment?: TabAlignmentLike;
    indicatorAnimation?: TabIndicatorAnimationLike;
    onTap?: string | AppletCallback<number>;
    onHover?: string | AppletCallback<{ value: boolean; index: number }>;
    onFocusChange?: string | AppletCallback<{ value: boolean; index: number }>;
  }

  export interface TabBarViewProps {
    children?: AppletChildren;
    physics?: ScrollPhysicsLike;
    dragStartBehavior?: DragStartBehaviorLike;
    viewportFraction?: number;
    clipBehavior?: ClipLike;
  }

  export interface TabProps {
    text?: string;
    icon?: AppletChild | string;
    iconMargin?: EdgeInsetsLike;
    height?: number;
    child?: AppletChild;
  }

  export type StepperTypeLike = "vertical" | "horizontal";
  export type StepStateLike = "indexed" | "editing" | "complete" | "disabled" | "error";
  export type AxisLike = "horizontal" | "vertical";
  export type TableCellVerticalAlignmentLike = "top" | "middle" | "bottom" | "baseline" | "fill";
  export type TableColumnWidthLike =
    | number
    | "flex"
    | "intrinsic"
    | {
        type?: "fixed" | "px" | "flex" | "fraction" | "intrinsic" | "min" | "max";
        kind?: "fixed" | "px" | "flex" | "fraction" | "intrinsic" | "min" | "max";
        value?: number;
        width?: number;
        size?: number;
        extent?: number;
        flex?: number;
        a?: TableColumnWidthLike;
        b?: TableColumnWidthLike;
        first?: TableColumnWidthLike;
        second?: TableColumnWidthLike;
      };

  export interface StepStyleLike {
    color?: ColorLike;
    errorColor?: ColorLike;
    connectorColor?: ColorLike;
    connectorThickness?: number;
    border?: ColorLike | { color?: ColorLike; width?: number };
    boxShadow?: Record<string, unknown>;
    shadow?: Record<string, unknown> | ColorLike;
    gradient?: Record<string, unknown>;
    indexStyle?: TextStyleLike;
  }

  export interface StepProps {
    title?: AppletChild;
    subtitle?: AppletChild;
    content?: AppletChild;
    child?: AppletChild;
    label?: AppletChild;
    isActive?: boolean;
    state?: StepStateLike;
    stepStyle?: StepStyleLike;
    style?: StepStyleLike;
  }

  export interface StepperProps {
    steps?: StepProps[];
    children?: StepProps[];
    currentStep?: number;
    type?: StepperTypeLike;
    stepperType?: StepperTypeLike;
    physics?: ScrollPhysicsLike;
    onStepTapped?: string | AppletCallback<number>;
    onStepContinue?: string | AppletCallback<void>;
    onStepCancel?: string | AppletCallback<void>;
    elevation?: number;
    margin?: EdgeInsetsLike;
    connectorColor?: WidgetStatePropertyLike<ColorLike>;
    connectorThickness?: number;
    stepIconSize?: number;
    stepIconHeight?: number;
    stepIconWidth?: number;
    stepIconMargin?: EdgeInsetsLike;
    clipBehavior?: ClipLike;
    headerPadding?: EdgeInsetsLike;
    contentPadding?: EdgeInsetsLike;
  }

  export interface DataColumnSortPayload {
    columnIndex: number;
    index: number;
    ascending: boolean;
    fallbackIndex: number;
  }

  export interface DataColumnProps {
    label?: AppletChild;
    child?: AppletChild;
    columnWidth?: TableColumnWidthLike;
    tooltip?: string;
    numeric?: boolean;
    onSort?: string | AppletCallback<DataColumnSortPayload>;
    mouseCursor?: WidgetStatePropertyLike<MouseCursorLike>;
    cursor?: WidgetStatePropertyLike<MouseCursorLike>;
    headingRowAlignment?: MainAxisAlignmentLike;
  }

  export interface DataCellTapDownPayload {
    x: number;
    y: number;
    localX: number;
    localY: number;
    kind?: string;
  }

  export interface DataCellProps {
    child?: AppletChild;
    label?: AppletChild;
    placeholder?: boolean;
    showEditIcon?: boolean;
    onTap?: string | AppletCallback<void>;
    onLongPress?: string | AppletCallback<void>;
    onTapDown?: string | AppletCallback<DataCellTapDownPayload>;
    onDoubleTap?: string | AppletCallback<void>;
    onTapCancel?: string | AppletCallback<void>;
  }

  export interface DataRowProps {
    key?: string | number;
    id?: string | number;
    index?: number;
    selected?: boolean;
    cells?: Array<DataCellProps | AppletChild>;
    onSelectChanged?: string | AppletCallback<boolean | null>;
    onLongPress?: string | AppletCallback<void>;
    onHover?: string | AppletCallback<boolean>;
    color?: WidgetStatePropertyLike<ColorLike>;
    mouseCursor?: WidgetStatePropertyLike<MouseCursorLike>;
    cursor?: WidgetStatePropertyLike<MouseCursorLike>;
  }

  export interface DataTableProps {
    columns?: DataColumnProps[];
    rows?: Array<DataRowProps | AppletChild[]>;
    sortColumnIndex?: number;
    sortAscending?: boolean;
    onSelectAll?: string | AppletCallback<boolean | null>;
    decoration?: Record<string, unknown>;
    dataRowColor?: WidgetStatePropertyLike<ColorLike>;
    dataRowHeight?: number;
    dataRowMinHeight?: number;
    dataRowMaxHeight?: number;
    dataTextStyle?: TextStyleLike;
    headingRowColor?: WidgetStatePropertyLike<ColorLike>;
    headingRowHeight?: number;
    headingTextStyle?: TextStyleLike;
    horizontalMargin?: number;
    columnSpacing?: number;
    showCheckboxColumn?: boolean;
    showBottomBorder?: boolean;
    dividerThickness?: number;
    checkboxHorizontalMargin?: number;
    border?: ColorLike | { color?: ColorLike; width?: number };
    clipBehavior?: ClipLike;
  }

  export interface TableRowProps {
    key?: string | number;
    id?: string | number;
    decoration?: Record<string, unknown>;
    children?: AppletChildren;
  }

  export interface TableProps {
    rows?: Array<TableRowProps | AppletChild[]>;
    children?: Array<TableRowProps | AppletChild[]>;
    columnWidths?: TableColumnWidthLike[] | Record<string | number, TableColumnWidthLike>;
    defaultColumnWidth?: TableColumnWidthLike;
    textDirection?: "ltr" | "rtl";
    border?: ColorLike | { color?: ColorLike; width?: number };
    defaultVerticalAlignment?: TableCellVerticalAlignmentLike;
    textBaseline?: TextBaselineLike;
  }

  export interface CarouselViewProps {
    children?: AppletChildren;
    padding?: EdgeInsetsLike;
    backgroundColor?: ColorLike;
    elevation?: number;
    shape?: ShapeBorderLike;
    itemClipBehavior?: ClipLike;
    overlayColor?: WidgetStatePropertyLike<ColorLike>;
    itemSnapping?: boolean;
    shrinkExtent?: number;
    scrollDirection?: AxisLike;
    reverse?: boolean;
    consumeMaxWeight?: boolean;
    onTap?: string | AppletCallback<number>;
    enableSplash?: boolean;
    infinite?: boolean;
    itemExtent?: number;
    onIndexChanged?: string | AppletCallback<number>;
    flexWeights?: number[] | string;
    weights?: number[] | string;
  }

  export function MaterialApp(props?: MaterialAppProps): AppletNode;
  export function AnimatedTheme(first?: AppletChild | AnimatedThemeProps, second?: AnimatedThemeProps): AppletNode;
  export function Scaffold(props?: ScaffoldProps): AppletNode;
  export function AdaptiveNavigationScaffold(props?: AdaptiveNavigationScaffoldProps): AppletNode;
  export function ScaffoldMessenger(first?: AppletChild | Record<string, unknown>, second?: Record<string, unknown>): AppletNode;
  export function AppBar(props?: AppBarProps): AppletNode;
  export function SelectionArea(first?: AppletChild | SelectionAreaProps, second?: SelectionAreaProps): AppletNode;
  export function Material(first?: AppletChild | MaterialProps, second?: MaterialProps): AppletNode;
  export function InkWell(first?: AppletChild | InkWellProps, second?: InkWellProps): AppletNode;
  export const Card: CardFactory;
  export function GridTile(first?: AppletChild | GridTileProps, second?: GridTileProps): AppletNode;
  export function GridTileBar(props?: GridTileBarProps): AppletNode;
  export function CircleAvatar(first?: AppletChild | CircleAvatarProps, second?: CircleAvatarProps): AppletNode;
  export const Badge: BadgeFactory;
  export function Banner(first?: AppletChild | BannerProps, second?: BannerProps): AppletNode;
  export function MaterialBanner(first?: AppletChild | MaterialBannerProps, second?: MaterialBannerProps): AppletNode;
  export function Drawer(first?: AppletChild | DrawerProps, second?: DrawerProps): AppletNode;
  export function DrawerHeader(first?: AppletChild | DrawerHeaderProps, second?: DrawerHeaderProps): AppletNode;
  export function ListTile(props?: ListTileProps): AppletNode;
  export function ExpansionTile(first?: AppletChildren | ExpansionTileProps, second?: ExpansionTileProps): AppletNode;
  export const ExpansionPanelList: ((first?: ExpansionPanelProps[] | ExpansionPanelListProps, second?: ExpansionPanelListProps) => AppletNode) & {
    radio(first?: ExpansionPanelProps[] | ExpansionPanelListProps, second?: ExpansionPanelListProps): AppletNode;
  };
  export function ExpansionPanel(props?: ExpansionPanelProps): ExpansionPanelProps;
  export function ExpansionPanelRadio(props?: ExpansionPanelProps): ExpansionPanelProps;
  export function Divider(props?: DividerProps): AppletNode;
  export function VerticalDivider(props?: DividerProps): AppletNode;
  export function Chip(props?: ChipProps): AppletNode;
  export const ActionChip: ElevatedChipFactory<ActionChipProps>;
  export const FilterChip: ElevatedChipFactory<SelectableChipProps>;
  export const ChoiceChip: ElevatedChipFactory<SelectableChipProps>;
  export function InputChip(props?: InputChipProps): AppletNode;
  export function Button(label?: string, action?: string | Function, payload?: unknown): AppletNode;

  export interface MaterialButtonProps extends ButtonStyleLike {
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    icon?: AppletChild | string;
    style?: ButtonStyleLike;
    tonal?: boolean;
    onPressed?: string | AppletCallback<void>;
    onTap?: string | AppletCallback<void>;
    onLongPress?: string | AppletCallback<void>;
    autofocus?: boolean;
    clipBehavior?: ClipLike;
  }

  export interface ButtonFactory {
    (first?: AppletChild | MaterialButtonProps, second?: MaterialButtonProps): AppletNode;
    icon(props?: MaterialButtonProps): AppletNode;
  }
  export const ElevatedButton: ButtonFactory;
  export const OutlinedButton: ButtonFactory;
  export const TextButton: ButtonFactory;
  export const FilledButton: ButtonFactory & {
    tonal(first?: AppletChild | MaterialButtonProps, second?: MaterialButtonProps): AppletNode;
    tonalIcon(props?: MaterialButtonProps): AppletNode;
  };

  export interface IconButtonProps extends ButtonStyleLike {
    icon?: AppletChild | string;
    name?: string;
    selectedIcon?: AppletChild;
    isSelected?: boolean;
    selected?: boolean;
    tooltip?: string;
    onPressed?: string | AppletCallback<void>;
    onTap?: string | AppletCallback<void>;
    onLongPress?: string | AppletCallback<void>;
    color?: ColorLike;
    iconSize?: number;
    size?: number;
    style?: ButtonStyleLike;
    visualDensity?: VisualDensityLike;
    padding?: EdgeInsetsLike;
    alignment?: AlignmentLike;
    splashRadius?: number;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    highlightColor?: ColorLike;
    splashColor?: ColorLike;
    disabledColor?: ColorLike;
    enableFeedback?: boolean;
    constraints?: BoxConstraintsLike;
    autofocus?: boolean;
    variant?: "standard" | "filled" | "filledTonal" | "filled_tonal" | "outlined";
  }

  export const IconButton: ((props?: IconButtonProps) => AppletNode) & {
    filled(props?: IconButtonProps): AppletNode;
    filledTonal(props?: IconButtonProps): AppletNode;
    outlined(props?: IconButtonProps): AppletNode;
  };

  export interface BackCloseButtonProps extends ButtonStyleLike {
    color?: ColorLike;
    style?: ButtonStyleLike;
    onPressed?: string | AppletCallback<void>;
    onTap?: string | AppletCallback<void>;
  }

  export function BackButton(props?: BackCloseButtonProps): AppletNode;
  export function CloseButton(props?: BackCloseButtonProps): AppletNode;

  export interface FloatingActionButtonProps {
    child?: AppletChild;
    icon?: AppletChild;
    label?: AppletChild;
    text?: string;
    variant?: "regular" | "small" | "large" | "extended";
    tooltip?: string;
    foregroundColor?: ColorLike;
    backgroundColor?: ColorLike;
    focusColor?: ColorLike;
    hoverColor?: ColorLike;
    splashColor?: ColorLike;
    heroTag?: unknown;
    elevation?: number;
    focusElevation?: number;
    hoverElevation?: number;
    highlightElevation?: number;
    disabledElevation?: number;
    onPressed?: string | AppletCallback<void>;
    onTap?: string | AppletCallback<void>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    mini?: boolean;
    shape?: ShapeBorderLike;
    clipBehavior?: ClipLike;
    autofocus?: boolean;
    materialTapTargetSize?: MaterialTapTargetSizeLike;
    tapTargetSize?: MaterialTapTargetSizeLike;
    isExtended?: boolean;
    enableFeedback?: boolean;
    extendedIconLabelSpacing?: number;
    iconLabelSpacing?: number;
    extendedPadding?: EdgeInsetsLike;
    extendedTextStyle?: TextStyleLike;
  }

  export const FloatingActionButton: ((first?: AppletChild | FloatingActionButtonProps, second?: FloatingActionButtonProps) => AppletNode) & {
    small(first?: AppletChild | FloatingActionButtonProps, second?: FloatingActionButtonProps): AppletNode;
    large(first?: AppletChild | FloatingActionButtonProps, second?: FloatingActionButtonProps): AppletNode;
    extended(props?: FloatingActionButtonProps): AppletNode;
  };
  export type TextFieldProps = InputDecorationProps & {
    decoration?: InputDecorationProps;
    value?: string | number | boolean;
    initialValue?: string | number | boolean;
    obscureText?: boolean;
    obscuringCharacter?: string;
    enabled?: boolean;
    ignorePointers?: boolean;
    readOnly?: boolean;
    autofocus?: boolean;
    autocorrect?: boolean;
    enableSuggestions?: boolean;
    showCursor?: boolean;
    minLines?: number;
    maxLines?: number;
    expands?: boolean;
    maxLength?: number | "none" | "noMax" | "unlimited";
    textAlign?: "left" | "right" | "center" | "justify" | "start" | "end";
    textDirection?: TextDirectionLike;
    style?: TextStyleLike;
    strutStyle?: StrutStyleLike;
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    textInputAction?: "done" | "go" | "next" | "search" | "send" | "newline";
    textCapitalization?: "none" | "characters" | "words" | "sentences";
    cursorWidth?: number;
    cursorHeight?: number;
    cursorRadius?: TextRadiusLike;
    cursorColor?: ColorLike;
    cursorErrorColor?: ColorLike;
    cursorOpacityAnimates?: boolean;
    selectionHeightStyle?: TextSelectionBoxHeightStyleLike;
    selectionWidthStyle?: TextSelectionBoxWidthStyleLike;
    scrollPadding?: EdgeInsetsLike;
    dragStartBehavior?: DragStartBehaviorLike;
    enableInteractiveSelection?: boolean;
    selectAllOnFocus?: boolean;
    selectionControls?: TextSelectionControlsLike;
    controls?: TextSelectionControlsLike;
    physics?: TextScrollPhysicsLike;
    scrollPhysics?: TextScrollPhysicsLike;
    scrollable?: boolean;
    restorationId?: string;
    enableIMEPersonalizedLearning?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    contextMenu?: boolean | "enabled" | "disabled" | "none" | "off";
    contextMenuBuilder?: boolean | "enabled" | "disabled" | "none" | "off";
    showContextMenu?: boolean;
    toolbar?: boolean | "enabled" | "disabled" | "none" | "off";
    showToolbar?: boolean;
    magnifier?: TextMagnifierConfigurationLike;
    magnifierConfiguration?: TextMagnifierConfigurationLike;
    enableMagnifier?: TextMagnifierConfigurationLike;
    clipBehavior?: ClipLike;
    stylusHandwritingEnabled?: boolean;
    stylus?: boolean;
    canRequestFocus?: boolean;
    autovalidateMode?: "disabled" | "always" | "onUserInteraction" | "on_user_interaction" | "onUnfocus" | "on_unfocus";
    onChanged?: AppletActionLike<string>;
    onSubmitted?: AppletActionLike<string>;
    onSaved?: AppletActionLike<string>;
    onTap?: AppletActionLike<void>;
    onTapAlwaysCalled?: boolean;
    onTapOutside?: AppletActionLike<PointerEventPayload>;
    onTapUpOutside?: AppletActionLike<PointerEventPayload>;
    onEditingComplete?: AppletActionLike<void>;
  };

  export type AutocompleteOptionLike =
    | string
    | number
    | boolean
    | {
        label?: string;
        text?: string;
        title?: string;
        name?: string;
        value?: unknown;
        search?: string | string[];
        keywords?: string | string[];
        tags?: string | string[];
      };

  export type AutocompleteFilterModeLike =
    | "contains"
    | "startsWith"
    | "starts_with"
    | "prefix"
    | "exact"
    | "equals"
    | "all"
    | "none";

  export interface AutocompleteProps extends InputDecorationProps {
    decoration?: InputDecorationProps;
    options?: AutocompleteOptionLike[];
    items?: AutocompleteOptionLike[];
    suggestions?: AutocompleteOptionLike[];
    value?: string | number | boolean;
    initialValue?: string | number | boolean;
    text?: string | number | boolean;
    enabled?: boolean;
    readOnly?: boolean;
    autofocus?: boolean;
    autoFocus?: boolean;
    autocorrect?: boolean;
    enableSuggestions?: boolean;
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    textInputAction?: "done" | "go" | "next" | "search" | "send" | "newline";
    textCapitalization?: "none" | "characters" | "words" | "sentences";
    style?: TextStyleLike;
    textStyle?: TextStyleLike;
    textAlign?: "left" | "right" | "center" | "justify" | "start" | "end";
    textDirection?: TextDirectionLike;
    cursorWidth?: number;
    cursorHeight?: number;
    cursorRadius?: TextRadiusLike;
    cursorColor?: ColorLike;
    selectionHeightStyle?: TextSelectionBoxHeightStyleLike;
    selectionWidthStyle?: TextSelectionBoxWidthStyleLike;
    scrollPadding?: EdgeInsetsLike;
    dragStartBehavior?: DragStartBehaviorLike;
    enableInteractiveSelection?: boolean;
    selectAllOnFocus?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    contextMenu?: boolean | "enabled" | "disabled" | "none" | "off";
    contextMenuBuilder?: boolean | "enabled" | "disabled" | "none" | "off";
    showContextMenu?: boolean;
    toolbar?: boolean | "enabled" | "disabled" | "none" | "off";
    showToolbar?: boolean;
    magnifier?: TextMagnifierConfigurationLike;
    magnifierConfiguration?: TextMagnifierConfigurationLike;
    enableMagnifier?: TextMagnifierConfigurationLike;
    restorationId?: string;
    clipBehavior?: ClipLike;
    canRequestFocus?: boolean;
    optionsMaxHeight?: number;
    maxHeight?: number;
    optionsViewOpenDirection?: "up" | "down" | "above" | "below" | "top" | "bottom";
    openDirection?: "up" | "down" | "above" | "below" | "top" | "bottom";
    direction?: "up" | "down" | "above" | "below" | "top" | "bottom";
    filter?: AutocompleteFilterModeLike;
    filterMode?: AutocompleteFilterModeLike;
    match?: AutocompleteFilterModeLike;
    caseSensitive?: boolean;
    showAllOnEmpty?: boolean;
    optionsLimit?: number;
    maxOptions?: number;
    limit?: number;
    selectedPayload?: "value" | "label" | "text" | "option" | "full" | "map" | "object";
    payload?: "value" | "label" | "text" | "option" | "full" | "map" | "object";
    onSelected?: AppletActionLike<unknown>;
    onChanged?: AppletActionLike<string>;
    onInput?: AppletActionLike<string>;
    onSubmitted?: AppletActionLike<string>;
    onTap?: AppletActionLike<void>;
    onTapAlwaysCalled?: boolean;
    onTapOutside?: AppletActionLike<PointerEventPayload>;
    onTapUpOutside?: AppletActionLike<PointerEventPayload>;
    onEditingComplete?: AppletActionLike<void>;
  }

  export function TextField(props?: TextFieldProps): AppletNode;
  export function TextFormField(props?: TextFieldProps): AppletNode;
  export function Autocomplete(props?: AutocompleteProps): AppletNode;
  export function InputDecoration(props?: InputDecorationProps): InputDecorationProps;
  export const Switch: AdaptiveWidgetFactory<SwitchProps>;
  export const SwitchListTile: AdaptiveWidgetFactory<SwitchListTileProps>;
  export const Checkbox: AdaptiveWidgetFactory<CheckboxProps>;
  export const CheckboxListTile: AdaptiveWidgetFactory<CheckboxListTileProps>;
  export const Radio: AdaptiveWidgetFactory<RadioProps>;
  export const RadioListTile: AdaptiveWidgetFactory<RadioListTileProps>;
  export const Slider: AdaptiveWidgetFactory<SliderProps>;
  export function RangeSlider(props?: RangeSliderProps): AppletNode;
  export function ToggleButtons(props?: ToggleButtonsProps): AppletNode;
  export function SegmentedButton(props?: SegmentedButtonProps): AppletNode;
  export function ButtonSegment(props?: ButtonSegmentProps): ButtonSegmentProps;
  export function ButtonStyle(props?: ButtonStyleLike): ButtonStyleLike;
  export function MenuStyle(props?: MenuStyleLike): MenuStyleLike;
  export function DropdownButton(props?: DropdownButtonProps): AppletNode;
  export function DropdownMenuItem(props?: DropdownMenuItemProps): AppletNode;
  export function DropdownMenu(props?: DropdownMenuProps): AppletNode;
  export function DropdownMenuEntry(props?: DropdownMenuEntryProps): DropdownMenuEntryProps;
  export function PopupMenuButton(props?: PopupMenuButtonProps): AppletNode;
  export function PopupMenuItem(props?: PopupMenuItemProps): AppletNode;
  export function CheckedPopupMenuItem(props?: PopupMenuItemProps): AppletNode;
  export function PopupMenuDivider(props?: PopupMenuDividerProps): AppletNode;
  export function MenuBar(first?: AppletChildren | MenuBarProps, second?: MenuBarProps): AppletNode;
  export function MenuAnchor(first?: AppletChild | MenuAnchorProps, second?: MenuAnchorProps): AppletNode;
  export function MenuItemButton(first?: AppletChild | MenuItemButtonProps, second?: MenuItemButtonProps): AppletNode;
  export function CheckboxMenuButton(first?: AppletChild | CheckboxMenuButtonProps, second?: CheckboxMenuButtonProps): AppletNode;
  export function RadioMenuButton(first?: AppletChild | RadioMenuButtonProps, second?: RadioMenuButtonProps): AppletNode;
  export function SubmenuButton(props?: SubmenuButtonProps): AppletNode;
  export function LinearProgressIndicator(props?: LinearProgressIndicatorProps): AppletNode;
  export const CircularProgressIndicator: AdaptiveWidgetFactory<CircularProgressIndicatorProps>;
  export const RefreshIndicator: AdaptiveChildWidgetFactory<RefreshIndicatorProps>;
  export const AlertDialog: AdaptiveWidgetFactory<AlertDialogProps>;
  export const Dialog: ((first?: AppletChild | DialogProps, second?: DialogProps) => AppletNode) & {
    fullscreen(first?: AppletChild | DialogProps, second?: DialogProps): AppletNode;
  };
  export function BottomSheet(first?: AppletChild | BottomSheetProps, second?: BottomSheetProps): AppletNode;
  export function SimpleDialog(props?: SimpleDialogProps): AppletNode;
  export function SnackBar(first?: AppletChild | SnackBarProps, second?: SnackBarProps): AppletNode;
  export function SnackBarAction(props?: SnackBarActionProps): SnackBarActionProps;
  export function DatePickerDialog(props?: DatePickerDialogProps): AppletNode;
  export function TimePickerDialog(props?: TimePickerDialogProps): AppletNode;
  export function SearchBar(props?: SearchBarProps): AppletNode;
  export function SearchAnchor(first?: AppletChild | SearchAnchorProps, second?: SearchAnchorProps): AppletNode;
  export function Scrollbar(first?: AppletChild | ScrollbarProps, second?: ScrollbarProps): AppletNode;
  export function NavigationBar(props?: NavigationBarProps): AppletNode;
  export function NavigationDestination(props?: NavigationDestinationProps): AppletNode;
  export function NavigationRail(props?: NavigationRailProps): AppletNode;
  export function NavigationRailDestination(props?: NavigationRailDestinationProps): AppletNode;
  export function NavigationDrawer(first?: AppletChildren | NavigationDrawerProps, second?: NavigationDrawerProps): AppletNode;
  export function NavigationDrawerDestination(props?: NavigationDrawerDestinationProps): AppletNode;
  export function BottomNavigationBar(props?: BottomNavigationBarProps): AppletNode;
  export function BottomNavigationBarItem(props?: BottomNavigationBarItemProps): BottomNavigationBarItemProps;
  export function BottomAppBar(first?: AppletChild | BottomAppBarProps, second?: BottomAppBarProps): AppletNode;
  export function DefaultTabController(first?: AppletChild | DefaultTabControllerProps, second?: DefaultTabControllerProps): AppletNode;
  export function TabBar(props?: TabBarProps): AppletNode;
  export function TabBarView(first?: AppletChildren | TabBarViewProps, second?: TabBarViewProps): AppletNode;
  export function Tab(props?: TabProps): AppletNode;
  export function Stepper(props?: StepperProps): AppletNode;
  export function Step(props?: StepProps): StepProps;
  export function DataTable(props?: DataTableProps): AppletNode;
  export function DataColumn(props?: DataColumnProps): DataColumnProps;
  export function DataRow(props?: DataRowProps): DataRowProps;
  export function DataCell(props?: DataCellProps): DataCellProps;
  export function Table(props?: TableProps): AppletNode;
  export function TableRow(props?: TableRowProps): TableRowProps;
  export function CarouselView(first?: AppletChildren | CarouselViewProps, second?: CarouselViewProps): AppletNode;
}

declare module "@app/cupertino" {
  export * from "@app/layout";
  import type {
    AppletActionLike,
    AppletChild,
    AppletChildren,
    AppletNode,
    AlignmentLike,
    BoxDecorationProps,
    ClipLike,
    ColorLike,
    CrossAxisAlignmentLike,
    DragStartBehaviorLike,
    EdgeInsetsLike,
    MouseCursorLike,
    StrutStyleLike,
    TextMagnifierConfigurationLike,
    TextRadiusLike,
    TextScrollPhysicsLike,
    TextSelectionBoxHeightStyleLike,
    TextSelectionBoxWidthStyleLike,
    TextSelectionControlsLike,
    TextStyleLike,
    ShapeBorderLike,
    ValidationRule,
    WidgetStatePropertyLike,
  } from "@app/core";
  import type { AutovalidateModeLike, TextDirectionLike } from "@app/layout";

  export type CupertinoButtonSizeLike = "small" | "medium" | "large";
  export type CupertinoButtonVariantLike = "plain" | "tinted" | "filled";
  export type CupertinoSizeLike = number | [number, number] | { width?: number; height?: number; w?: number; h?: number };
  export type CupertinoImageProviderLike =
    | string
    | {
        asset?: string;
        network?: string;
        url?: string;
        base64?: string;
        data?: string;
        scale?: number;
        cacheWidth?: number;
        cacheHeight?: number;
      };
  export type CupertinoIconLike = string | { icon?: string; name?: string; data?: string; color?: ColorLike; size?: number };
  export interface CupertinoImageErrorPayload {
    source: string;
    error: string;
  }
  export type CupertinoDurationLike = number | Record<string, number>;
  export type CupertinoDateTimeLike =
    | string
    | number
    | Date
    | {
        year?: number;
        month?: number;
        day?: number;
        hour?: number;
        minute?: number;
        second?: number;
        millisecond?: number;
        microsecond?: number;
        millisecondsSinceEpoch?: number;
        msSinceEpoch?: number;
        epochMilliseconds?: number;
        timestampMs?: number;
      };
  export interface CupertinoDateTimePayload {
    iso: string;
    date: string;
    time: string;
    year: number;
    month: number;
    day: number;
    hour: number;
    minute: number;
    second: number;
    millisecond: number;
    millisecondsSinceEpoch: number;
    weekday: number;
  }
  export interface CupertinoDurationPayload {
    days: number;
    hours: number;
    minutes: number;
    seconds: number;
    milliseconds: number;
    microseconds: number;
    hour: number;
    minute: number;
    second: number;
  }
  export type CupertinoPickerChangeReportingBehaviorLike =
    | "onScrollUpdate"
    | "on_scroll_update"
    | "scrollUpdate"
    | "update"
    | "onScrollEnd"
    | "on_scroll_end"
    | "scrollEnd"
    | "end";
  export type CupertinoDatePickerModeLike =
    | "dateAndTime"
    | "date_and_time"
    | "datetime"
    | "dateTime"
    | "date"
    | "time"
    | "monthYear"
    | "month_year"
    | "yearMonth"
    | "year_month";
  export type CupertinoDatePickerDateOrderLike =
    | "dmy"
    | "mdy"
    | "ymd"
    | "ydm"
    | "dayMonthYear"
    | "monthDayYear"
    | "yearMonthDay"
    | "yearDayMonth";
  export type CupertinoTimerPickerModeLike =
    | "hm"
    | "ms"
    | "hms"
    | "hourMinute"
    | "minuteSecond"
    | "hourMinuteSecond";
  export type CupertinoBrightnessLike = "light" | "dark";
  export type CupertinoBorderLike =
    | ColorLike
    | false
    | "none"
    | "hidden"
    | "off"
    | { color?: ColorLike; width?: number };
  export type CupertinoNavigationBarVariantLike = "small" | "large";
  export type CupertinoNavigationBarBottomModeLike =
    | "automatic"
    | "auto"
    | "scroll"
    | "collapsible"
    | "always"
    | "pinned"
    | "fixed";
  export type CupertinoListSectionVariantLike = "base" | "insetGrouped" | "inset_grouped";
  export type CupertinoSegmentValueLike = string | number | boolean;
  export interface CupertinoThemeDataProps {
    brightness?: CupertinoBrightnessLike;
    primaryColor?: ColorLike;
    primary?: ColorLike;
    scaffoldBackgroundColor?: ColorLike;
    barBackgroundColor?: ColorLike;
  }
  export interface CupertinoAppProps {
    title?: string;
    debugShowCheckedModeBanner?: boolean;
    theme?: ColorLike | CupertinoThemeDataProps;
    home?: AppletChild;
    child?: AppletChild;
  }
  export interface CupertinoPageScaffoldProps {
    navigationBar?: AppletChild | CupertinoNavigationBarProps;
    backgroundColor?: ColorLike;
    resizeToAvoidBottomInset?: boolean;
    child?: AppletChild;
  }
  export interface CupertinoNavigationBarProps {
    variant?: CupertinoNavigationBarVariantLike;
    type?: CupertinoNavigationBarVariantLike;
    large?: boolean;
    largeTitle?: AppletChild;
    title?: AppletChild;
    middle?: AppletChild;
    leading?: AppletChild;
    trailing?: AppletChild;
    bottom?: AppletChild;
    automaticallyImplyLeading?: boolean;
    automaticallyImplyMiddle?: boolean;
    automaticallyImplyTitle?: boolean;
    previousPageTitle?: string;
    backgroundColor?: ColorLike;
    automaticBackgroundVisibility?: boolean;
    enableBackgroundFilterBlur?: boolean;
    brightness?: CupertinoBrightnessLike;
    padding?: EdgeInsetsLike;
    transitionBetweenRoutes?: boolean;
    heroTag?: string | number | boolean;
    border?: CupertinoBorderLike;
  }
  export interface CupertinoSliverNavigationBarProps extends Omit<CupertinoNavigationBarProps, "variant" | "large" | "largeTitle"> {
    variant?: "large" | "search";
    type?: "large" | "search";
    largeTitle?: AppletChild;
    automaticallyImplyTitle?: boolean;
    automaticallyImplyMiddle?: boolean;
    alwaysShowMiddle?: boolean;
    stretch?: boolean;
    bottom?: AppletChild;
    bottomMode?: CupertinoNavigationBarBottomModeLike;
    searchField?: AppletChild;
    onSearchableBottomTap?: AppletActionLike<boolean>;
    onSearchTap?: AppletActionLike<boolean>;
  }
  export interface CupertinoNavigationBarBackButtonProps {
    color?: ColorLike;
    previousPageTitle?: string;
    onPressed?: AppletActionLike<void>;
    onTap?: AppletActionLike<void>;
  }
  export interface CupertinoAlertDialogProps {
    title?: AppletChild;
    content?: AppletChild;
    child?: AppletChild;
    actions?: AppletChildren;
    children?: AppletChildren;
    insetAnimationDuration?: CupertinoDurationLike;
    insetAnimationCurve?: string;
    curve?: string;
  }
  export interface CupertinoActionSheetProps {
    title?: AppletChild;
    message?: AppletChild;
    content?: AppletChild;
    actions?: AppletChildren;
    children?: AppletChildren;
    cancelButton?: AppletChild;
  }
  export interface CupertinoDialogActionProps {
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    onPressed?: AppletActionLike<void>;
    onTap?: AppletActionLike<void>;
    isDefaultAction?: boolean;
    isDestructiveAction?: boolean;
    textStyle?: TextStyleLike;
    style?: TextStyleLike;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
  }
  export interface CupertinoActionSheetActionProps {
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    onPressed?: AppletActionLike<void>;
    onTap?: AppletActionLike<void>;
    isDefaultAction?: boolean;
    isDestructiveAction?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    focusColor?: ColorLike;
  }
  export interface CupertinoListSectionProps {
    children?: AppletChildren;
    header?: AppletChild;
    footer?: AppletChild;
    variant?: CupertinoListSectionVariantLike;
    insetGrouped?: boolean;
    margin?: EdgeInsetsLike;
    backgroundColor?: ColorLike;
    decoration?: BoxDecorationProps;
    clipBehavior?: ClipLike;
    dividerMargin?: number;
    additionalDividerMargin?: number;
    topMargin?: number;
    hasLeading?: boolean;
    separatorColor?: ColorLike;
  }
  export interface CupertinoListTileProps {
    title?: AppletChild;
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    subtitle?: AppletChild;
    additionalInfo?: AppletChild;
    additional?: AppletChild;
    leading?: AppletChild;
    trailing?: AppletChild;
    onTap?: AppletActionLike<void>;
    onPressed?: AppletActionLike<void>;
    backgroundColor?: ColorLike;
    backgroundColorActivated?: ColorLike;
    padding?: EdgeInsetsLike;
    leadingSize?: number;
    leadingToTitle?: number;
    variant?: "base" | "notched";
    notched?: boolean;
  }
  export interface CupertinoFormSectionProps {
    children?: AppletChildren;
    header?: AppletChild;
    footer?: AppletChild;
    variant?: CupertinoListSectionVariantLike;
    insetGrouped?: boolean;
    margin?: EdgeInsetsLike;
    backgroundColor?: ColorLike;
    decoration?: BoxDecorationProps;
    clipBehavior?: ClipLike;
  }
  export interface CupertinoFormRowProps {
    child?: AppletChild;
    prefix?: AppletChild;
    label?: AppletChild;
    padding?: EdgeInsetsLike;
    helper?: AppletChild;
    error?: AppletChild;
  }
  export interface CupertinoPickerDefaultSelectionOverlayProps {
    background?: ColorLike;
    backgroundColor?: ColorLike;
    color?: ColorLike;
    capStartEdge?: boolean;
    capEndEdge?: boolean;
  }
  export interface CupertinoPickerProps {
    children?: AppletChildren;
    items?: AppletChildren;
    itemExtent?: number;
    extent?: number;
    height?: number;
    initialItem?: number;
    selectedIndex?: number;
    index?: number;
    onSelectedItemChanged?: AppletActionLike<number>;
    onChanged?: AppletActionLike<number>;
    onSelected?: AppletActionLike<number>;
    diameterRatio?: number;
    backgroundColor?: ColorLike;
    offAxisFraction?: number;
    useMagnifier?: boolean;
    magnification?: number;
    squeeze?: number;
    looping?: boolean;
    selectionOverlay?: AppletChild | boolean | "none" | "off";
    overlay?: AppletChild | boolean | "none" | "off";
    changeReportingBehavior?: CupertinoPickerChangeReportingBehaviorLike;
  }
  export interface CupertinoDatePickerProps {
    mode?: CupertinoDatePickerModeLike;
    value?: CupertinoDateTimeLike;
    date?: CupertinoDateTimeLike;
    initialDateTime?: CupertinoDateTimeLike;
    initialDate?: CupertinoDateTimeLike;
    minimumDate?: CupertinoDateTimeLike;
    minDate?: CupertinoDateTimeLike;
    firstDate?: CupertinoDateTimeLike;
    maximumDate?: CupertinoDateTimeLike;
    maxDate?: CupertinoDateTimeLike;
    lastDate?: CupertinoDateTimeLike;
    minimumYear?: number;
    maximumYear?: number;
    minuteInterval?: number;
    use24hFormat?: boolean;
    dateOrder?: CupertinoDatePickerDateOrderLike;
    backgroundColor?: ColorLike;
    showDayOfWeek?: boolean;
    showTimeSeparator?: boolean;
    itemExtent?: number;
    selectionOverlay?: AppletChild | boolean | "none" | "off";
    selectionOverlayBuilder?: AppletChild | boolean | "none" | "off";
    overlay?: AppletChild | boolean | "none" | "off";
    changeReportingBehavior?: CupertinoPickerChangeReportingBehaviorLike;
    onDateTimeChanged?: AppletActionLike<CupertinoDateTimePayload>;
    onChanged?: AppletActionLike<CupertinoDateTimePayload>;
  }
  export interface CupertinoTimerPickerProps {
    mode?: CupertinoTimerPickerModeLike;
    value?: CupertinoDurationLike;
    duration?: CupertinoDurationLike;
    initialTimerDuration?: CupertinoDurationLike;
    minuteInterval?: number;
    secondInterval?: number;
    alignment?: AlignmentLike;
    backgroundColor?: ColorLike;
    itemExtent?: number;
    selectionOverlay?: AppletChild | boolean | "none" | "off";
    selectionOverlayBuilder?: AppletChild | boolean | "none" | "off";
    overlay?: AppletChild | boolean | "none" | "off";
    changeReportingBehavior?: CupertinoPickerChangeReportingBehaviorLike;
    onTimerDurationChanged?: AppletActionLike<CupertinoDurationPayload>;
    onChanged?: AppletActionLike<CupertinoDurationPayload>;
  }
  export interface CupertinoSegmentItemProps {
    value?: CupertinoSegmentValueLike;
    key?: CupertinoSegmentValueLike;
    id?: CupertinoSegmentValueLike;
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    icon?: AppletChild | string;
  }
  export interface CupertinoSegmentedControlProps {
    segments?: CupertinoSegmentItemProps[] | Record<string, AppletChild | string | number | boolean>;
    children?: CupertinoSegmentItemProps[] | Record<string, AppletChild | string | number | boolean>;
    items?: CupertinoSegmentItemProps[] | Record<string, AppletChild | string | number | boolean>;
    groupValue?: CupertinoSegmentValueLike;
    value?: CupertinoSegmentValueLike;
    selected?: CupertinoSegmentValueLike;
    onValueChanged?: AppletActionLike<CupertinoSegmentValueLike>;
    onChanged?: AppletActionLike<CupertinoSegmentValueLike>;
    unselectedColor?: ColorLike;
    selectedColor?: ColorLike;
    borderColor?: ColorLike;
    pressedColor?: ColorLike;
    disabledColor?: ColorLike;
    disabledTextColor?: ColorLike;
    padding?: EdgeInsetsLike;
    disabledChildren?: CupertinoSegmentValueLike[];
  }
  export interface CupertinoSlidingSegmentedControlProps {
    segments?: CupertinoSegmentItemProps[] | Record<string, AppletChild | string | number | boolean>;
    children?: CupertinoSegmentItemProps[] | Record<string, AppletChild | string | number | boolean>;
    items?: CupertinoSegmentItemProps[] | Record<string, AppletChild | string | number | boolean>;
    groupValue?: CupertinoSegmentValueLike;
    value?: CupertinoSegmentValueLike;
    selected?: CupertinoSegmentValueLike;
    onValueChanged?: AppletActionLike<CupertinoSegmentValueLike | null>;
    onChanged?: AppletActionLike<CupertinoSegmentValueLike | null>;
    disabledChildren?: CupertinoSegmentValueLike[];
    thumbColor?: ColorLike;
    padding?: EdgeInsetsLike;
    backgroundColor?: ColorLike;
    proportionalWidth?: boolean;
    isMomentary?: boolean;
    momentary?: boolean;
  }
  export interface CupertinoScrollbarProps {
    child?: AppletChild;
    thumbVisibility?: boolean;
    thickness?: number;
    thicknessWhileDragging?: number;
    radius?: number | Record<string, number>;
    radiusWhileDragging?: number | Record<string, number>;
    scrollbarOrientation?: "left" | "right" | "top" | "bottom";
    orientation?: "left" | "right" | "top" | "bottom";
    mainAxisMargin?: number;
  }
  export interface CupertinoTabBarItemProps {
    icon?: AppletChild | string;
    activeIcon?: AppletChild | string;
    label?: string;
    tooltip?: string;
    backgroundColor?: ColorLike;
  }
  export interface CupertinoTabBarProps {
    items?: CupertinoTabBarItemProps[];
    children?: CupertinoTabBarItemProps[];
    currentIndex?: number;
    selectedIndex?: number;
    onTap?: AppletActionLike<number>;
    onChanged?: AppletActionLike<number>;
    backgroundColor?: ColorLike;
    activeColor?: ColorLike;
    inactiveColor?: ColorLike;
    iconSize?: number;
    height?: number;
    border?: CupertinoBorderLike;
  }

  export type CupertinoOverlayVisibilityModeLike =
    | "never"
    | "none"
    | "hidden"
    | "editing"
    | "whileEditing"
    | "notEditing"
    | "not_editing"
    | "empty"
    | "always"
    | boolean;

  export interface CupertinoTextFieldProps {
    value?: string | number | boolean;
    initialValue?: string | number | boolean;
    decoration?: BoxDecorationProps | "none" | false;
    boxDecoration?: BoxDecorationProps;
    backgroundColor?: ColorLike;
    color?: ColorLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    padding?: EdgeInsetsLike;
    placeholder?: string;
    hintText?: string;
    placeholderStyle?: TextStyleLike;
    prefix?: AppletChild;
    prefixMode?: CupertinoOverlayVisibilityModeLike;
    suffix?: AppletChild;
    suffixMode?: CupertinoOverlayVisibilityModeLike;
    crossAxisAlignment?: CrossAxisAlignmentLike;
    clearButtonMode?: CupertinoOverlayVisibilityModeLike;
    clearButton?: CupertinoOverlayVisibilityModeLike;
    clearButtonSemanticLabel?: string;
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    textInputAction?: "done" | "go" | "next" | "search" | "send" | "newline";
    textCapitalization?: "none" | "characters" | "words" | "sentences";
    style?: TextStyleLike;
    strutStyle?: StrutStyleLike;
    textAlign?: "left" | "right" | "center" | "justify" | "start" | "end";
    textDirection?: TextDirectionLike;
    readOnly?: boolean;
    showCursor?: boolean;
    autofocus?: boolean;
    obscuringCharacter?: string;
    obscureText?: boolean;
    autocorrect?: boolean;
    enableSuggestions?: boolean;
    minLines?: number;
    maxLines?: number;
    expands?: boolean;
    maxLength?: number | "none" | "noMax" | "unlimited";
    enabled?: boolean;
    cursorWidth?: number;
    cursorHeight?: number;
    cursorRadius?: TextRadiusLike;
    cursorOpacityAnimates?: boolean;
    cursorColor?: ColorLike;
    selectionHeightStyle?: TextSelectionBoxHeightStyleLike;
    selectionWidthStyle?: TextSelectionBoxWidthStyleLike;
    scrollPadding?: EdgeInsetsLike;
    dragStartBehavior?: DragStartBehaviorLike;
    enableInteractiveSelection?: boolean;
    selectAllOnFocus?: boolean;
    selectionControls?: TextSelectionControlsLike;
    controls?: TextSelectionControlsLike;
    physics?: TextScrollPhysicsLike;
    scrollPhysics?: TextScrollPhysicsLike;
    scrollable?: boolean;
    clipBehavior?: ClipLike;
    restorationId?: string;
    stylusHandwritingEnabled?: boolean;
    stylus?: boolean;
    enableIMEPersonalizedLearning?: boolean;
    enableInlinePrediction?: boolean;
    contextMenu?: boolean | "enabled" | "disabled" | "none" | "off";
    contextMenuBuilder?: boolean | "enabled" | "disabled" | "none" | "off";
    showContextMenu?: boolean;
    toolbar?: boolean | "enabled" | "disabled" | "none" | "off";
    showToolbar?: boolean;
    magnifier?: TextMagnifierConfigurationLike;
    magnifierConfiguration?: TextMagnifierConfigurationLike;
    enableMagnifier?: TextMagnifierConfigurationLike;
    onChanged?: AppletActionLike<string>;
    onEditingComplete?: AppletActionLike<void>;
    onSubmitted?: AppletActionLike<string>;
    onTapOutside?: AppletActionLike<unknown>;
    onTapUpOutside?: AppletActionLike<unknown>;
    onTap?: AppletActionLike<void>;
  }

  export interface CupertinoSearchTextFieldProps {
    placeholder?: string;
    hintText?: string;
    style?: TextStyleLike;
    placeholderStyle?: TextStyleLike;
    decoration?: BoxDecorationProps;
    backgroundColor?: ColorLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    padding?: EdgeInsetsLike;
    itemColor?: ColorLike;
    itemSize?: number;
    prefixInsets?: EdgeInsetsLike;
    prefixIcon?: string | { icon?: string; name?: string; data?: string; size?: number; color?: ColorLike; semanticLabel?: string; semanticsLabel?: string };
    prefixIconName?: string;
    suffixInsets?: EdgeInsetsLike;
    suffixIcon?: string | { icon?: string; name?: string; data?: string; size?: number; color?: ColorLike; semanticLabel?: string; semanticsLabel?: string };
    suffixIconName?: string;
    suffixMode?: CupertinoOverlayVisibilityModeLike;
    restorationId?: string;
    enableIMEPersonalizedLearning?: boolean;
    autofocus?: boolean;
    autocorrect?: boolean;
    enabled?: boolean;
    cursorWidth?: number;
    cursorHeight?: number;
    cursorRadius?: TextRadiusLike;
    cursorOpacityAnimates?: boolean;
    cursorColor?: ColorLike;
    onChanged?: AppletActionLike<string>;
    onSubmitted?: AppletActionLike<string>;
    onSuffixTap?: AppletActionLike<void>;
    onTap?: AppletActionLike<void>;
  }

  export interface CupertinoTextFormFieldRowProps {
    value?: string | number | boolean;
    initialValue?: string | number | boolean;
    prefix?: AppletChild;
    label?: AppletChild;
    padding?: EdgeInsetsLike;
    decoration?: BoxDecorationProps | "none" | false;
    boxDecoration?: BoxDecorationProps;
    backgroundColor?: ColorLike;
    color?: ColorLike;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    keyboardType?: "text" | "number" | "phone" | "email" | "emailAddress" | "url" | "multiline" | "datetime" | "visiblePassword";
    textCapitalization?: "none" | "characters" | "words" | "sentences";
    textInputAction?: "done" | "go" | "next" | "search" | "send" | "newline";
    style?: TextStyleLike;
    strutStyle?: StrutStyleLike;
    textDirection?: TextDirectionLike;
    textAlign?: "left" | "right" | "center" | "justify" | "start" | "end";
    autofocus?: boolean;
    readOnly?: boolean;
    showCursor?: boolean;
    obscuringCharacter?: string;
    obscureText?: boolean;
    autocorrect?: boolean;
    enableSuggestions?: boolean;
    minLines?: number;
    maxLines?: number;
    expands?: boolean;
    maxLength?: number | "none" | "noMax" | "unlimited";
    enabled?: boolean;
    cursorWidth?: number;
    cursorHeight?: number;
    cursorColor?: ColorLike;
    keyboardAppearance?: CupertinoBrightnessLike;
    scrollPadding?: EdgeInsetsLike;
    enableInteractiveSelection?: boolean;
    selectionControls?: TextSelectionControlsLike;
    controls?: TextSelectionControlsLike;
    physics?: TextScrollPhysicsLike;
    scrollPhysics?: TextScrollPhysicsLike;
    autovalidateMode?: AutovalidateModeLike;
    placeholder?: string;
    hintText?: string;
    placeholderStyle?: TextStyleLike;
    contextMenu?: boolean | "enabled" | "disabled" | "none" | "off";
    contextMenuBuilder?: boolean | "enabled" | "disabled" | "none" | "off";
    showContextMenu?: boolean;
    toolbar?: boolean | "enabled" | "disabled" | "none" | "off";
    showToolbar?: boolean;
    selectionHeightStyle?: TextSelectionBoxHeightStyleLike;
    selectionWidthStyle?: TextSelectionBoxWidthStyleLike;
    restorationId?: string;
    validator?: ValidationRule | ValidationRule[];
    validators?: ValidationRule | ValidationRule[];
    validation?: ValidationRule | ValidationRule[];
    onChanged?: AppletActionLike<string>;
    onTap?: AppletActionLike<void>;
    onEditingComplete?: AppletActionLike<void>;
    onFieldSubmitted?: AppletActionLike<string>;
    onSubmitted?: AppletActionLike<string>;
    onSaved?: AppletActionLike<string>;
  }

  export interface CupertinoButtonProps {
    child?: AppletChild;
    label?: AppletChild;
    text?: AppletChild;
    variant?: CupertinoButtonVariantLike;
    style?: CupertinoButtonVariantLike;
    type?: CupertinoButtonVariantLike;
    sizeStyle?: CupertinoButtonSizeLike;
    size?: CupertinoButtonSizeLike;
    padding?: EdgeInsetsLike;
    color?: ColorLike;
    backgroundColor?: ColorLike;
    foregroundColor?: ColorLike;
    disabledColor?: ColorLike;
    minimumSize?: CupertinoSizeLike;
    minSize?: CupertinoSizeLike;
    pressedOpacity?: number;
    borderRadius?: number | Record<string, number>;
    radius?: number | Record<string, number>;
    alignment?: AlignmentLike;
    focusColor?: ColorLike;
    onFocusChange?: AppletActionLike<boolean>;
    autofocus?: boolean;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    onPressed?: AppletActionLike<void>;
    onTap?: AppletActionLike<void>;
    onLongPress?: AppletActionLike<void>;
  }

  export interface CupertinoSwitchProps {
    value?: boolean;
    enabled?: boolean;
    onChanged?: AppletActionLike<boolean>;
    activeTrackColor?: ColorLike;
    activeColor?: ColorLike;
    inactiveTrackColor?: ColorLike;
    trackColor?: ColorLike;
    thumbColor?: ColorLike;
    inactiveThumbColor?: ColorLike;
    applyTheme?: boolean;
    focusColor?: ColorLike;
    onLabelColor?: ColorLike;
    offLabelColor?: ColorLike;
    activeThumbImage?: CupertinoImageProviderLike;
    inactiveThumbImage?: CupertinoImageProviderLike;
    onActiveThumbImageError?: AppletActionLike<CupertinoImageErrorPayload>;
    onInactiveThumbImageError?: AppletActionLike<CupertinoImageErrorPayload>;
    trackOutlineColor?: WidgetStatePropertyLike<ColorLike>;
    trackOutlineWidth?: WidgetStatePropertyLike<number>;
    thumbIcon?: WidgetStatePropertyLike<CupertinoIconLike>;
    mouseCursor?: MouseCursorLike | WidgetStatePropertyLike<MouseCursorLike>;
    cursor?: MouseCursorLike | WidgetStatePropertyLike<MouseCursorLike>;
    onFocusChange?: AppletActionLike<boolean>;
    autofocus?: boolean;
    dragStartBehavior?: DragStartBehaviorLike;
  }

  export interface CupertinoCheckboxProps {
    value?: boolean | null;
    tristate?: boolean;
    enabled?: boolean;
    onChanged?: AppletActionLike<boolean | null>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    activeColor?: ColorLike;
    fillColor?: WidgetStatePropertyLike<ColorLike>;
    checkColor?: ColorLike;
    focusColor?: ColorLike;
    autofocus?: boolean;
    side?: ColorLike | { color?: ColorLike; width?: number };
    shape?: ShapeBorderLike;
    tapTargetSize?: CupertinoSizeLike;
    size?: CupertinoSizeLike;
    semanticLabel?: string;
  }

  export interface CupertinoRadioProps {
    value?: CupertinoSegmentValueLike;
    id?: CupertinoSegmentValueLike;
    name?: CupertinoSegmentValueLike;
    groupValue?: CupertinoSegmentValueLike;
    selected?: CupertinoSegmentValueLike;
    enabled?: boolean;
    onChanged?: AppletActionLike<CupertinoSegmentValueLike | null>;
    mouseCursor?: MouseCursorLike;
    cursor?: MouseCursorLike;
    toggleable?: boolean;
    activeColor?: ColorLike;
    inactiveColor?: ColorLike;
    fillColor?: ColorLike;
    focusColor?: ColorLike;
    autofocus?: boolean;
    useCheckmarkStyle?: boolean;
  }

  export interface CupertinoSliderProps {
    value?: number;
    min?: number;
    max?: number;
    divisions?: number;
    enabled?: boolean;
    activeColor?: ColorLike;
    thumbColor?: ColorLike;
    onChanged?: AppletActionLike<number>;
    onChangeStart?: AppletActionLike<number>;
    onStart?: AppletActionLike<number>;
    onChangeEnd?: AppletActionLike<number>;
    onEnd?: AppletActionLike<number>;
  }

  export interface CupertinoActivityIndicatorProps {
    color?: ColorLike;
    radius?: number;
    animating?: boolean;
    progress?: number;
    partiallyRevealed?: boolean;
    partial?: boolean;
    revealed?: boolean;
    static?: boolean;
  }

  export function CupertinoApp(props?: CupertinoAppProps): AppletNode;
  export function CupertinoPageScaffold(props?: CupertinoPageScaffoldProps): AppletNode;
  export function CupertinoNavigationBar(props?: CupertinoNavigationBarProps): AppletNode;
  export function CupertinoSliverNavigationBar(props?: CupertinoSliverNavigationBarProps): AppletNode;
  export function CupertinoNavigationBarBackButton(props?: CupertinoNavigationBarBackButtonProps): AppletNode;
  export function CupertinoAlertDialog(props?: CupertinoAlertDialogProps): AppletNode;
  export function CupertinoActionSheet(props?: CupertinoActionSheetProps): AppletNode;
  export function CupertinoDialogAction(first?: AppletChild | CupertinoDialogActionProps, second?: CupertinoDialogActionProps): AppletNode;
  export function CupertinoActionSheetAction(first?: AppletChild | CupertinoActionSheetActionProps, second?: CupertinoActionSheetActionProps): AppletNode;
  export function CupertinoListSection(first?: AppletChildren | CupertinoListSectionProps, second?: CupertinoListSectionProps): AppletNode;
  export function CupertinoListTile(props?: CupertinoListTileProps): AppletNode;
  export function CupertinoListTileChevron(props?: Record<string, unknown>): AppletNode;
  export function CupertinoFormSection(first?: AppletChildren | CupertinoFormSectionProps, second?: CupertinoFormSectionProps): AppletNode;
  export function CupertinoFormRow(first?: AppletChild | CupertinoFormRowProps, second?: CupertinoFormRowProps): AppletNode;
  export function CupertinoPicker(first?: AppletChildren | CupertinoPickerProps, second?: CupertinoPickerProps): AppletNode;
  export function CupertinoPickerDefaultSelectionOverlay(props?: CupertinoPickerDefaultSelectionOverlayProps): AppletNode;
  export function CupertinoDatePicker(props?: CupertinoDatePickerProps): AppletNode;
  export function CupertinoTimerPicker(props?: CupertinoTimerPickerProps): AppletNode;
  export function CupertinoSegmentedControl(props?: CupertinoSegmentedControlProps): AppletNode;
  export function CupertinoSlidingSegmentedControl(props?: CupertinoSlidingSegmentedControlProps): AppletNode;
  export function CupertinoSearchTextField(props?: CupertinoSearchTextFieldProps): AppletNode;
  export function CupertinoScrollbar(first?: AppletChild | CupertinoScrollbarProps, second?: CupertinoScrollbarProps): AppletNode;
  export function CupertinoTabBar(props?: CupertinoTabBarProps): AppletNode;
  export function CupertinoButton(first?: AppletChild | CupertinoButtonProps, second?: CupertinoButtonProps): AppletNode;
  export function CupertinoSwitch(props?: CupertinoSwitchProps): AppletNode;
  export function CupertinoCheckbox(props?: CupertinoCheckboxProps): AppletNode;
  export function CupertinoRadio(props?: CupertinoRadioProps): AppletNode;
  export function CupertinoSlider(props?: CupertinoSliderProps): AppletNode;
  export function CupertinoActivityIndicator(props?: CupertinoActivityIndicatorProps): AppletNode;
  export function CupertinoTextField(props?: CupertinoTextFieldProps): AppletNode;
  export function CupertinoTextFormFieldRow(props?: CupertinoTextFormFieldRowProps): AppletNode;
}

declare module "@applet/core" { export * from "@app/core"; }
declare module "@applet/widgets" { export * from "@app/widgets"; }
declare module "@applet/layout" { export * from "@app/layout"; }
declare module "@applet/material" { export * from "@app/material"; }
declare module "@applet/cupertino" { export * from "@app/cupertino"; }
