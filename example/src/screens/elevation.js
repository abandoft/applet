import {
  Align,
  CustomScrollView,
  Expanded,
  For,
  Material,
  Padding,
  SliverGrid,
  SliverLayoutBuilder,
  SliverList,
  SliverPadding,
  SliverToBoxAdapter,
  SizedBox,
  VStack,
} from "@app/material";
import { elevationLevels } from "../catalog.js";
import { Txt } from "../components.js";

const narrowScreenWidthThreshold = 450;

export function ElevationScreen() {
  return CustomScrollView([
    SectionHeader("Surface Tint Color Only", true),
    ElevationGrid({
      surfaceTintColor: "#6750a4",
      shadowColor: "transparent",
    }),
    SliverList([
      SizedGap(10),
      Padding(SectionTitle("Surface Tint Color and Shadow Color"), {
        padding: { left: 16, top: 8, right: 16, bottom: 0 },
      }),
    ]),
    ElevationGrid({
      surfaceTintColor: "#6750a4",
      shadowColor: "#000000",
    }),
    SliverList([
      SizedGap(10),
      Padding(SectionTitle("Shadow Color Only"), {
        padding: { left: 16, top: 8, right: 16, bottom: 0 },
      }),
    ]),
    ElevationGrid({
      shadowColor: "#000000",
    }),
  ]);
}

function SectionHeader(title, first = false) {
  return SliverToBoxAdapter(
    Padding(SectionTitle(title), {
      padding: { left: 16, top: first ? 20 : 8, right: 16, bottom: 0 },
    })
  );
}

function SectionTitle(title) {
  return Txt(title, { style: { theme: "titleLarge" } });
}

function SizedGap(height) {
  return SizedBox({ height });
}

function ElevationGrid({ shadowColor = null, surfaceTintColor = null }) {
  const grid = (crossAxisCount) =>
    SliverGrid(For(elevationLevels, (item) => ElevationCard(item, { shadowColor, surfaceTintColor })), {
      crossAxisCount,
    });

  return SliverPadding(
    SliverLayoutBuilder({
      breakpoints: [
        {
          maxWidth: narrowScreenWidthThreshold,
          child: grid(3),
        },
        {
          minWidth: narrowScreenWidthThreshold,
          child: grid(6),
        },
      ],
    }),
    { padding: { all: 8 } }
  );
}

function ElevationCard(info, { shadowColor, surfaceTintColor }) {
  const materialProps = {
    type: "card",
    color: "#fffbfe",
    borderRadius: 4,
    elevation: info.elevation,
    shadowColor,
    surfaceTintColor,
  };

  return Padding(
    Material(
      Padding(
        VStack(
          Txt("Level " + info.level, { style: { theme: "labelMedium" } }),
          Txt(info.elevation + " dp", { style: { theme: "labelMedium" } }),
          surfaceTintColor
            ? Expanded(
                Align(Txt(info.overlay + "%", { style: { theme: "bodySmall" } }), {
                  alignment: "bottomRight",
                })
              )
            : null
        )
          .cross("stretch")
          .main("start"),
        { padding: { all: 8 } }
      ),
      materialProps
    ),
    { padding: { all: 8 } }
  );
}
