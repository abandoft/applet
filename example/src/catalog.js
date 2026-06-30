import { Icons } from "@app/material";

export const colorSeeds = [
  { label: "M3 Baseline", color: "#6750a4" },
  { label: "Indigo", color: "#3f51b5" },
  { label: "Blue", color: "#2196f3" },
  { label: "Teal", color: "#009688" },
  { label: "Green", color: "#4caf50" },
  { label: "Yellow", color: "#ffeb3b" },
  { label: "Orange", color: "#ff9800" },
  { label: "Deep Orange", color: "#ff5722" },
  { label: "Pink", color: "#e91e63" },
];

export const imageProviders = [
  {
    label: "Leaves",
    color: "#386a20",
    url: "https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_1.png",
  },
  {
    label: "Peonies",
    color: "#984061",
    url: "https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_2.png",
  },
  {
    label: "Bubbles",
    color: "#00639b",
    url: "https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_3.png",
  },
  {
    label: "Seaweed",
    color: "#006a6a",
    url: "https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_4.png",
  },
  {
    label: "Sea Grapes",
    color: "#725c00",
    url: "https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_5.png",
  },
  {
    label: "Petals",
    color: "#7d5260",
    url: "https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_6.png",
  },
];

export const destinations = [
  { label: "Components", icon: Icons.widgets, selectedIcon: Icons.widgets },
  { label: "Color", icon: Icons.palette, selectedIcon: Icons.color_lens },
  { label: "Typography", icon: Icons.text_fields, selectedIcon: Icons.text_fields },
  { label: "Elevation", icon: Icons.layers, selectedIcon: Icons.layers },
];

export const componentGroups = [
  {
    label: "Actions",
    description: "Buttons, floating actions, icon toggles, and segmented buttons.",
  },
  {
    label: "Communication",
    description: "Badges, progress, snackbars, and navigation feedback.",
  },
  {
    label: "Containment",
    description: "Cards, dialogs, bottom sheets, carousels, and dividers.",
  },
  {
    label: "Navigation",
    description: "Bars, rails, drawers, tabs, app bars, menus, and search.",
  },
  {
    label: "Selection",
    description: "Switches, checkboxes, radios, chips, pickers, and sliders.",
  },
  {
    label: "Text inputs",
    description: "Filled and outlined text fields with live JavaScript state.",
  },
];

export const elevationLevels = [
  { level: 0, elevation: 0, overlay: 0 },
  { level: 1, elevation: 1, overlay: 5 },
  { level: 2, elevation: 3, overlay: 8 },
  { level: 3, elevation: 6, overlay: 11 },
  { level: 4, elevation: 8, overlay: 12 },
  { level: 5, elevation: 12, overlay: 14 },
];

export function activeSeed(model) {
  return model.colorSelectionMethod === "image"
    ? imageProviders[model.imageIndex]
    : colorSeeds[model.colorSeedIndex];
}
