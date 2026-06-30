import {
  Card,
  Container,
  FittedBox,
  For,
  HStack,
  LayoutBuilder,
  Padding,
  Positioned,
  SingleChildScrollView,
  SizedBox,
  Stack,
  VStack,
} from "@app/material";
import { Txt } from "../components.js";
import { activeSeed } from "../catalog.js";
import { schemeFor } from "../theme.js";

const narrowScreenWidthThreshold = 500;
const divider = SizedBox({ height: 10 });

const colorGroups = [
  ["primary", "onPrimary", "primaryContainer", "onPrimaryContainer"],
  ["primaryFixed", "onPrimaryFixed", "primaryFixedDim", "onPrimaryFixedVariant"],
  ["secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer"],
  ["secondaryFixed", "onSecondaryFixed", "secondaryFixedDim", "onSecondaryFixedVariant"],
  ["tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer"],
  ["tertiaryFixed", "onTertiaryFixed", "tertiaryFixedDim", "onTertiaryFixedVariant"],
  ["error", "onError", "errorContainer", "onErrorContainer"],
  [
    "surfaceDim",
    "surface",
    "surfaceBright",
    "surfaceContainerLowest",
    "surfaceContainerLow",
    "surfaceContainer",
    "surfaceContainerHigh",
    "surfaceContainerHighest",
    "onSurface",
    "onSurfaceVariant",
  ],
  ["outline", "shadow", "inverseSurface", "onInverseSurface", "inversePrimary"],
];

export function ColorScreen(model) {
  const seed = activeSeed(model);
  const lightScheme = schemeFor(seed, "light");
  const darkScheme = schemeFor(seed, "dark");

  return LayoutBuilder({
    breakpoints: [
      {
        maxWidth: narrowScreenWidthThreshold,
        child: CompactColorScreen(lightScheme, darkScheme),
      },
      {
        minWidth: narrowScreenWidthThreshold,
        child: WideColorScreen(lightScheme, darkScheme),
      },
    ],
  });
}

function CompactColorScreen(lightScheme, darkScheme) {
  return SingleChildScrollView(
    VStack(
      DynamicColorNotice(),
      divider,
      SchemeLabel("Light ColorScheme"),
      SchemeView(lightScheme),
      divider,
      divider,
      SchemeLabel("Dark ColorScheme"),
      SchemeView(darkScheme)
    ).cross("stretch")
  );
}

function WideColorScreen(lightScheme, darkScheme) {
  return SingleChildScrollView(
    Padding(
      VStack(
        SchemePreview("Light ColorScheme", lightScheme, false),
        SizedBox({ height: 16 }),
        SchemePreview("Dark ColorScheme", darkScheme, true),
        SizedBox({ height: 16 })
      ).cross("stretch"),
      { padding: { all: 8 } }
    )
  );
}

function DynamicColorNotice() {
  return Padding(
    Txt("To create color schemes based on a platform's implementation of dynamic color, use the dynamic_color package.", {
      textAlign: "center",
      style: { theme: "bodySmall" },
    }),
    { padding: { horizontal: 15, top: 8 } }
  );
}

function SchemeLabel(label) {
  return Padding(Txt(label, { style: { fontWeight: "bold" } }), {
    padding: { vertical: 15 },
  });
}

function SchemeView(scheme) {
  return Padding(
    VStack(...For(colorGroups, (group) => ColorGroup(group, scheme))).gap(10),
    { padding: { horizontal: 15 } }
  );
}

function ColorGroup(roles, scheme) {
  return Card(VStack(...For(roles, (role) => ColorChip(role, scheme[role], onColorFor(role, scheme)))), {
    clipBehavior: "antiAlias",
    margin: { all: 0 },
  });
}

function ColorChip(label, color, onColor = null) {
  return Container(
    Padding(
      HStack(
        Txt(label, {
          style: {
            color: onColor ?? contrastColor(color),
          },
        }).expanded()
      ),
      { padding: { all: 16 } }
    ),
    { color }
  );
}

function SchemePreview(label, scheme, dark) {
  return FittedBox(
    Container(
      Padding(
        VStack(
          HStack(
            Txt(label, {
              textAlign: "start",
              style: {
                theme: "titleMedium",
                color: scheme.onSurface,
                fontWeight: "bold",
              },
            }).expanded()
          ),
          SizedBox({ height: 20 }),
          HStack(
            VStack(
              HStack(
                ColorFamilyColumn([
                  ColorBox("Primary", dark ? "P-80" : "P-40", scheme.primary, scheme.onPrimary, 87, 208),
                  ColorBox("On Primary", dark ? "P-20" : "P-100", scheme.onPrimary, scheme.primary, 40, 208),
                  SizedBox({ height: 5 }),
                  ColorBox("Primary Container", dark ? "P-30" : "P-90", scheme.primaryContainer, scheme.onPrimaryContainer, 87, 208),
                  ColorBox("On Primary Container", dark ? "P-90" : "P-10", scheme.onPrimaryContainer, scheme.primaryContainer, 40, 208),
                ]),
                SizedBox({ width: 5 }),
                ColorFamilyColumn([
                  ColorBox("Secondary", dark ? "S-80" : "S-40", scheme.secondary, scheme.onSecondary, 87, 208),
                  ColorBox("On Secondary", dark ? "S-20" : "S-100", scheme.onSecondary, scheme.secondary, 40, 208),
                  SizedBox({ height: 5 }),
                  ColorBox("Secondary Container", dark ? "S-30" : "S-90", scheme.secondaryContainer, scheme.onSecondaryContainer, 87, 208),
                  ColorBox("On Secondary Container", dark ? "S-90" : "S-10", scheme.onSecondaryContainer, scheme.secondaryContainer, 40, 208),
                ]),
                SizedBox({ width: 5 }),
                ColorFamilyColumn([
                  ColorBox("Tertiary", dark ? "T-80" : "T-40", scheme.tertiary, scheme.onTertiary, 87, 208),
                  ColorBox("On Tertiary", dark ? "T-20" : "T-100", scheme.onTertiary, scheme.tertiary, 40, 208),
                  SizedBox({ height: 5 }),
                  ColorBox("Tertiary Container", dark ? "T-30" : "T-90", scheme.tertiaryContainer, scheme.onTertiaryContainer, 87, 208),
                  ColorBox("On Tertiary Container", dark ? "T-90" : "T-10", scheme.onTertiaryContainer, scheme.tertiaryContainer, 40, 208),
                ])
              ),
              SizedBox({ height: 20 }),
              HStack(
                ColorBox("Surface Dim", dark ? "N-6" : "N-87", scheme.surfaceDim, scheme.onSurface, 105, 211.45),
                ColorBox("Surface", dark ? "N-6" : "N-98", scheme.surface, scheme.onSurface, 105, 211.45),
                ColorBox("Surface Bright", dark ? "N-24" : "N-98", scheme.surfaceBright, scheme.onSurface, 105, 211.45)
              ),
              SizedBox({ height: 5 }),
              HStack(
                ColorBox("Surf. Container\nLowest", dark ? "N-4" : "N-100", scheme.surfaceContainerLowest, scheme.onSurface, 105, 126.87),
                ColorBox("Surf. Container\nLow", dark ? "N-10" : "N-96", scheme.surfaceContainerLow, scheme.onSurface, 105, 126.87),
                ColorBox("Surf. Container", dark ? "N-12" : "N-94", scheme.surfaceContainer, scheme.onSurface, 105, 126.87),
                ColorBox("Surf. Container\nHigh", dark ? "N-17" : "N-92", scheme.surfaceContainerHigh, scheme.onSurface, 105, 126.87),
                ColorBox("Surf. Container\nHighest", dark ? "N-24" : "N-90", scheme.surfaceContainerHighest, scheme.onSurface, 105, 126.87)
              ),
              SizedBox({ height: 5 }),
              HStack(
                ColorBox("On Surface", dark ? "N-90" : "N-10", scheme.onSurface, scheme.surface, 40, 158.59),
                ColorBox("On Surface Var.", dark ? "NV-90" : "NV-30", scheme.onSurfaceVariant, scheme.surfaceContainerHighest, 40, 158.59),
                ColorBox("Outline", dark ? "NV-60" : "NV-50", scheme.outline, scheme.surface, 40, 158.59),
                ColorBox("Outline Variant", dark ? "NV-30" : "NV-80", scheme.outlineVariant, scheme.onSurface, 40, 158.59)
              )
            ),
            SizedBox({ width: 20 }),
            VStack(
              ColorBox("Error", dark ? "E-80" : "E-40", scheme.error, scheme.onError, 87, 208),
              ColorBox("On Error", dark ? "E-20" : "E-100", scheme.onError, scheme.error, 40, 208),
              SizedBox({ height: 5 }),
              ColorBox("Error Container", dark ? "E-30" : "E-90", scheme.errorContainer, scheme.onErrorContainer, 87, 208),
              ColorBox("On Error Container", dark ? "E-90" : "E-10", scheme.onErrorContainer, scheme.errorContainer, 40, 208),
              SizedBox({ height: 20 }),
              ColorBox("Inverse Surface", dark ? "N-90" : "N-20", scheme.inverseSurface, scheme.onInverseSurface, 120, 208),
              ColorBox("Inverse On Surface", dark ? "N-20" : "N-95", scheme.onInverseSurface, scheme.inverseSurface, 40, 208),
              SizedBox({ height: 5 }),
              ColorBox("Inverse Primary", dark ? "P-40" : "P-80", scheme.inversePrimary, scheme.onSurface, 40, 208),
              SizedBox({ height: 16 }),
              HStack(
                ColorBox("Scrim", "N-0", scheme.scrim, "#ffffff", 40, 96.31),
                SizedBox({ width: 20 }),
                ColorBox("Shadow", "N-0", scheme.shadow, "#ffffff", 40, 96.31)
              ),
              SizedBox({ height: 8 })
            )
          ).cross("start")
        ).cross("stretch"),
        { padding: { top: 16, left: 16, right: 16 } }
      ),
      {
        width: 902,
        decoration: {
          color: scheme.surface,
          borderRadius: 12,
          border: { color: "transparent", width: 1 },
        },
      }
    ),
    { fit: "fitWidth" }
  );
}

function ColorFamilyColumn(children) {
  return VStack(...children);
}

function ColorBox(label, tone, color, onColor, height, width) {
  return Container(
    Stack(
      Positioned(Txt(label, { style: { theme: "labelSmall", color: onColor } }), {
        top: 10,
        left: 10,
      }),
      Positioned(Txt("", { style: { theme: "labelSmall", color: onColor } }), {
        bottom: 10,
        right: 10,
      })
    ),
    { color, height, width }
  );
}

function onColorFor(role, scheme) {
  const token = role.toLowerCase();
  if (token.startsWith("on")) {
    if (token.includes("primary")) return scheme.primary;
    if (token.includes("secondary")) return scheme.secondary;
    if (token.includes("tertiary")) return scheme.tertiary;
    if (token.includes("error")) return scheme.error;
    if (role === "onSurface") return scheme.surface;
    if (role === "onSurfaceVariant") return scheme.surfaceContainerHighest;
    if (role === "onInverseSurface") return scheme.inverseSurface;
  }
  if (token.includes("primary")) return token.includes("fixed") ? scheme.onPrimaryFixed : scheme.onPrimary;
  if (token.includes("secondary")) return token.includes("fixed") ? scheme.onSecondaryFixed : scheme.onSecondary;
  if (token.includes("tertiary")) return token.includes("fixed") ? scheme.onTertiaryFixed : scheme.onTertiary;
  if (token.includes("error")) return scheme.onError;
  if (token.includes("surface")) return scheme.onSurface;
  if (role === "inverseSurface") return scheme.onInverseSurface;
  if (role === "inversePrimary") return scheme.primary;
  return null;
}

function contrastColor(color) {
  const hex = String(color || "#ffffff").replace("#", "");
  if (hex.length < 6) return "#000000";
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  return (r * 299 + g * 587 + b * 114) / 1000 >= 128 ? "#000000" : "#ffffff";
}
