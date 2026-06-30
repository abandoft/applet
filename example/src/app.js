import "@app/material";
import { colorSeeds, destinations, imageProviders } from "./catalog.js";
import { MaterialDemoState } from "./state.js";
import { appTheme } from "./theme.js";
import { SeedDot, ToolbarButton, Txt, menuItems } from "./components.js";
import { ComponentsScreen } from "./screens/components.js";
import { ColorScreen } from "./screens/color.js";
import { TypographyScreen } from "./screens/typography.js";
import { ElevationScreen } from "./screens/elevation.js";

export default function App() {
  const model = MaterialDemoState();

  return MaterialApp({
    debugShowCheckedModeBanner: false,
    title: "Material 3",
    themeMode: model.themeMode,
    theme: appTheme(model, "light"),
    darkTheme: appTheme(model, "dark"),
    home: Home(model),
  });
}

function Home(model) {
  return AdaptiveNavigationScaffold({
    appBar: AppToolbar(model),
    railAppBar: AppToolbar(model, false),
    body: CurrentScreen(model),
    navigationRail: MainRail(model),
    extendedNavigationRail: MainRail(model, true),
    navigationBar: MainNavigationBar(model),
    narrowWidth: 450,
    largeWidth: 1500,
    duration: { milliseconds: 500 },
    snackBar: model.snackbarVisible
      ? SnackBar({
          content: Text("This is a snackbar"),
          behavior: "floating",
          showCloseIcon: true,
          duration: { seconds: 6 },
          action: SnackBarAction({
            label: "Dismiss",
            onPressed: () => model.toggleSnackbar(),
          }),
        })
      : null,
    bottomSheet: model.bottomSheetVisible ? AppBottomSheet(model) : null,
    dialog: CurrentDialog(model),
  });
}

function MainNavigationBar(model) {
  return NavigationBar({
    selectedIndex: model.screenIndex,
    onDestinationSelected: (index) => model.selectScreen(index),
    destinations: For(destinations, (destination) =>
      NavigationDestination({
        icon: Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon),
        label: destination.label,
        tooltip: destination.label,
      })
    ),
  });
}

function CurrentDialog(model) {
  if (model.dialogVisible) return AppDialog(model);
  if (model.datePickerVisible) return AppDatePicker(model);
  if (model.timePickerVisible) return AppTimePicker(model);
  return null;
}

function AppBottomSheet(model) {
  return BottomSheet(
    VStack(
      Txt("Bottom sheet").fontSize(18).fontWeight("w600"),
      Txt("Use this surface for secondary actions that should stay close to the current task."),
      HStack(
        IconButton({ icon: Icon(Icons.share_outlined), tooltip: "Share" }),
        IconButton({ icon: Icon(Icons.archive_outlined), tooltip: "Archive" }),
        IconButton({ icon: Icon(Icons.favorite_border), tooltip: "Favorite" })
      ).gap(8).cross("center"),
      FilledButton("Done", { onPressed: () => model.toggleBottomSheet() })
    ).gap(12).cross("stretch"),
    {
      showDragHandle: true,
      backgroundColor: "#fef7ff",
      elevation: 3,
      shape: { borderRadius: 24 },
      onClosing: () => model.toggleBottomSheet(),
    }
  );
}

function AppDialog(model) {
  return AlertDialog({
    title: Txt("What is a dialog?"),
    content: Txt("A dialog interrupts the current task so users can make a focused decision."),
    actions: [
      TextButton("Dismiss", { onPressed: () => model.toggleDialog() }),
      FilledButton("Okay", { onPressed: () => model.toggleDialog() }),
    ],
    onDismissed: () => model.toggleDialog(),
  });
}

function AppDatePicker(model) {
  return DatePickerDialog({
    initialDate: model.dateValue,
    firstDate: "2020-01-01",
    lastDate: "2030-12-31",
    helpText: "Select date",
    onResult: (value) => model.setDate(value),
    onDismissed: () => model.toggleDatePicker(),
  });
}

function AppTimePicker(model) {
  return TimePickerDialog({
    initialTime: model.timeValue,
    helpText: "Select time",
    onResult: (value) => model.setTime(value),
    onDismissed: () => model.toggleTimePicker(),
  });
}

function AppToolbar(model, showActions = true) {
  return AppBar({
    title: Text(model.useMaterial3 ? "Material 3" : "Material 2"),
    actions: showActions ? [
      ToolbarButton(
        model.useLightMode ? Icons.dark_mode : Icons.light_mode,
        model.useLightMode ? "Use dark mode" : "Use light mode",
        () => model.toggleBrightness()
      ),
      ToolbarButton(
        Icons.auto_awesome,
        model.useMaterial3 ? "Switch to Material 2" : "Switch to Material 3",
        () => model.toggleMaterialVersion(),
        model.useMaterial3
      ),
      SeedMenu(model),
      ImageMenu(model),
    ] : [],
  });
}

function SeedMenu(model) {
  return PopupMenuButton({
    icon: SeedDot(colorSeeds[model.colorSeedIndex].color),
    tooltip: "Select seed color",
    onSelected: (index) => model.selectSeed(index),
    items: menuItems(colorSeeds, (seed) =>
      HStack(SeedDot(seed.color), Txt(seed.label)).gap(10).cross("center")
    ),
  });
}

function ImageMenu(model) {
  return PopupMenuButton({
    icon: Icon(Icons.image),
    tooltip: "Select image color",
    onSelected: (index) => model.selectImage(index),
    items: menuItems(imageProviders, (image) =>
      HStack(SeedDot(image.color), Txt(image.label)).gap(10).cross("center")
    ),
  });
}

function RailActions(model) {
  return Expanded(
    Padding(
      VStack(
        ToolbarButton(
          model.useLightMode ? Icons.dark_mode : Icons.light_mode,
          model.useLightMode ? "Use dark mode" : "Use light mode",
          () => model.toggleBrightness()
        ),
        ToolbarButton(
          Icons.auto_awesome,
          model.useMaterial3 ? "Switch to Material 2" : "Switch to Material 3",
          () => model.toggleMaterialVersion(),
          model.useMaterial3
        ),
        SeedMenu(model),
        ImageMenu(model)
      ).gap(4).main("end").cross("center"),
      { padding: { bottom: 20 } }
    )
  );
}

function MainRail(model, extended = false) {
  return NavigationRail({
    selectedIndex: model.screenIndex,
    onDestinationSelected: (index) => model.selectScreen(index),
    extended,
    minExtendedWidth: 196,
    trailing: RailActions(model),
    destinations: For(destinations, (destination) =>
      NavigationRailDestination({
        icon: Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon),
        label: Txt(destination.label),
      })
    ),
  });
}

function CurrentScreen(model) {
  switch (model.screenIndex) {
    case 1:
      return ColorScreen(model);
    case 2:
      return TypographyScreen(model);
    case 3:
      return ElevationScreen(model);
    default:
      return ComponentsScreen(model);
  }
}
