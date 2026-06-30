import { For, ListView, Padding, SizedBox } from "@app/material";
import { Txt } from "../components.js";

const textStyles = [
  ["Display Large", "displayLarge"],
  ["Display Medium", "displayMedium"],
  ["Display Small", "displaySmall"],
  ["Headline Large", "headlineLarge"],
  ["Headline Medium", "headlineMedium"],
  ["Headline Small", "headlineSmall"],
  ["Title Large", "titleLarge"],
  ["Title Medium", "titleMedium"],
  ["Title Small", "titleSmall"],
  ["Label Large", "labelLarge"],
  ["Label Medium", "labelMedium"],
  ["Label Small", "labelSmall"],
  ["Body Large", "bodyLarge"],
  ["Body Medium", "bodyMedium"],
  ["Body Small", "bodySmall"],
];

export function TypographyScreen() {
  return ListView([
    SizedBox({ height: 8 }),
    ...For(textStyles, ([name, theme]) => TextStyleExample(name, theme)),
  ]);
}

function TextStyleExample(name, theme) {
  return Padding(Txt(name, { style: { theme } }), {
    padding: { all: 8 },
  });
}
