import {
  ActionChip,
  Card,
  Center,
  Chip,
  Column,
  Container,
  EdgeInsets,
  Expanded,
  FilledButton,
  Focus,
  FocusTraversalGroup,
  For,
  GestureDetector,
  HStack,
  Icon,
  IconButton,
  Icons,
  LayoutBuilder,
  Padding,
  RepaintBoundary,
  Row,
  SingleChildScrollView,
  SizedBox,
  Text,
  Tooltip,
  VStack,
  Wrap,
} from "@app/material";

const componentWidth = 450;
const componentSpacing = 10;

export function Txt(value, props = {}) {
  return Text(String(value), props);
}

export function Gap(size = 12) {
  return SizedBox({ height: size, width: size });
}

export function PageFrame(title, subtitle, children) {
  const content = (padding) =>
    SingleChildScrollView(
      Padding(
        VStack(
          PageHeader(title, subtitle),
          ...children
        )
          .gap(20)
          .cross("stretch"),
        { padding: EdgeInsets.all(padding) }
      )
    );

  return LayoutBuilder({
    compact: content(16),
    medium: content(24),
    expanded: content(32),
    large: content(40),
  });
}

export function PageHeader(title, subtitle) {
  return VStack(
    Txt(title).fontSize(30).fontWeight("w600"),
    Txt(subtitle, {
      style: {
        fontSize: 15,
        color: { theme: "onSurfaceVariant" },
        height: 1.35,
      },
    })
  )
    .gap(6)
    .cross("stretch");
}

export function ComponentGroup(label, description, cards) {
  return FocusTraversalGroup(
    Card(
      Padding(
        Center(
          VStack(
            Txt(label, { style: { theme: "titleLarge" } }),
            SizedBox({ height: componentSpacing }),
            ...cards
          ).cross("center")
        ),
        { padding: { vertical: 20 } }
      ),
      {
        margin: EdgeInsets.all(0),
        elevation: 0,
        color: { theme: "surfaceContainerHighest", opacity: 0.3 },
      }
    )
  );
}

export function DemoCard(title, subtitle, content, options = {}) {
  return RepaintBoundary(
    Padding(
      VStack(
        Row([
          Txt(title, { style: { theme: "titleMedium" } }),
          Tooltip(
            Padding(Icon(Icons.info_outline, { size: 16 }), {
              padding: { horizontal: 5 },
            }),
            { message: subtitle }
          ),
        ]).main("center").cross("center"),
        SizedBox(
          Focus(
            GestureDetector(
              Card.outlined(
                Padding(Center(content), {
                  padding: { horizontal: 5, vertical: 20 },
                }),
                {
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  clipBehavior: "antiAlias",
                }
              ),
              { behavior: "opaque" }
            ),
            { canRequestFocus: true }
          ),
          { width: componentWidth }
        )
      ).cross("center"),
      { padding: { vertical: componentSpacing } }
    )
  );
}

export function ControlLabel(label, value) {
  return Row([
    Txt(label).fontWeight("w500").expanded(),
    Chip({ label: Txt(value) }),
  ]).cross("center");
}

export function ButtonStrip(children) {
  return Wrap(children, { spacing: 8, runSpacing: 8 });
}

export function IconToggle(icon, selectedIcon, selected, onTap, tooltip) {
  return Tooltip(
    IconButton.outlined({
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      selected,
      tooltip,
      onPressed: onTap,
    }),
    { message: tooltip }
  );
}

export function Swatch(label, color, onColor = "#ffffff", height = 74) {
  return Container(
    VStack(
      Txt(label, {
        maxLines: 1,
        overflow: "ellipsis",
        style: { color: onColor, fontWeight: "w600", fontSize: 12 },
      }),
      Txt(color, {
        style: { color: onColor, fontSize: 11 },
      })
    )
      .gap(4)
      .cross("start"),
    {
      width: 178,
      height,
      padding: EdgeInsets.all(12),
      decoration: {
        color,
        borderRadius: 12,
      },
    }
  );
}

export function SeedDot(color) {
  return Container({
    width: 16,
    height: 16,
    decoration: {
      color,
      borderRadius: 8,
      border: { color: { theme: "outlineVariant" }, width: 1 },
    },
  });
}

export function StatusBanner(message, actionLabel, onPressed) {
  return Container(
    Row([
      Icon(Icons.info),
      Txt(message).expanded(),
      ActionChip({ label: Txt(actionLabel), onPressed }),
    ])
      .gap(12)
      .cross("center"),
    {
      padding: EdgeInsets.all(12),
      decoration: {
        color: { theme: "surfaceContainer" },
        borderRadius: 12,
      },
    }
  );
}

export function NavigationPlaceholder(title, subtitle, icon) {
  return Container(
    VStack(
      Icon(icon, { size: 40, color: { theme: "primary" } }),
      Txt(title).fontSize(18).fontWeight("w600"),
      Txt(subtitle, {
        textAlign: "center",
        style: { color: { theme: "onSurfaceVariant" }, height: 1.3 },
      })
    )
      .gap(8)
      .cross("center"),
    {
      height: 160,
      alignment: "center",
      decoration: {
        color: { theme: "surface" },
        borderRadius: 16,
        border: { color: { theme: "outlineVariant" }, width: 1 },
      },
    }
  );
}

export function menuItems(items, render = (item) => item.label) {
  return For(items, (item, index) => ({
    value: item.value ?? index,
    label: render(item, index),
  }));
}

export function ToolbarButton(icon, tooltip, onPressed, selected = false) {
  return Tooltip(
    IconButton({
      icon: Icon(icon),
      selectedIcon: Icon(icon),
      selected,
      tooltip,
      onPressed,
    }),
    { message: tooltip }
  );
}

export function FillButton(label, onPressed, icon = null) {
  return FilledButton({
    label: Txt(label),
    icon: icon ? Icon(icon) : null,
    onPressed,
  });
}

export function TwoColumn(left, right) {
  return Row([
    Expanded(left),
    Expanded(right),
  ])
    .gap(16)
    .cross("start");
}

export function Pill(label) {
  return Chip({ label: Txt(label) });
}
