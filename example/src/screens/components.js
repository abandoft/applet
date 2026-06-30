import {
  ActionChip,
  AdaptiveTwoPane,
  AppBar,
  Badge,
  BottomAppBar,
  ButtonSegment,
  Card,
  CarouselView,
  Checkbox,
  CheckboxListTile,
  Chip,
  ChoiceChip,
  CircularProgressIndicator,
  Container,
  CustomScrollView,
  DefaultTabController,
  Divider,
  DropdownMenu,
  DropdownMenuEntry,
  EdgeInsets,
  ElevatedButton,
  ExpansionPanelList,
  ExpansionPanelRadio,
  FilledButton,
  FilterChip,
  FocusTraversalGroup,
  FloatingActionButton,
  For,
  GridTile,
  GridTileBar,
  GridView,
  HStack,
  Icon,
  IconButton,
  Icons,
  InputChip,
  InteractiveViewer,
  LinearProgressIndicator,
  ListTile,
  NavigationBar,
  NavigationDestination,
  NavigationDrawer,
  NavigationDrawerDestination,
  NavigationRail,
  NavigationRailDestination,
  OutlinedButton,
  Padding,
  PopupMenuButton,
  RadioListTile,
  RangeSlider,
  Row,
  SearchBar,
  SegmentedButton,
  Show,
  SizedBox,
  Slider,
  SingleChildScrollView,
  SliverAppBar,
  SliverCachedList,
  SliverPadding,
  SliverToBoxAdapter,
  Switch,
  SwitchListTile,
  Tab,
  TabBar,
  TabBarView,
  TextButton,
  TextField,
  ToggleButtons,
  Visibility,
  VStack,
  Wrap,
} from "@app/material";
import {
  ButtonStrip,
  ComponentGroup,
  ControlLabel,
  DemoCard,
  FillButton,
  NavigationPlaceholder,
  PageHeader,
  Pill,
  Swatch,
  Txt,
  menuItems,
} from "../components.js";
import { componentGroups } from "../catalog.js";

const componentsSubtitle =
  "A JavaScript implementation of the Flutter Material 3 demo. Components use the same names and state is kept with local JS State().";

export function ComponentsScreen(model) {
  const first = [
    ActionsGroup(model),
    CommunicationGroup(model),
    ContainmentGroup(model),
  ];
  const second = [
    NavigationGroup(model),
    SelectionGroup(model),
    TextInputsGroup(model),
  ];

  return AdaptiveTwoPane({
    breakpoint: 1000,
    duration: { milliseconds: 500 },
    compact: ComponentsPane([...first, ...second], {
      title: "Components",
      subtitle: componentsSubtitle,
      padding: EdgeInsets.all(16),
    }),
    primary: ComponentsPane(first, {
      title: "Components",
      subtitle: componentsSubtitle,
      padding: EdgeInsets.only({ left: 32, top: 32, right: 12, bottom: 32 }),
    }),
    secondary: ComponentsPane(second, {
      padding: EdgeInsets.only({ left: 12, top: 32, right: 32, bottom: 32 }),
    }),
  });
}

function ComponentsPane(children, options = {}) {
  const body = [];
  if (options.title) {
    body.push(PageHeader(options.title, options.subtitle ?? ""));
  }
  body.push(...children);

  return FocusTraversalGroup(
    CustomScrollView({
      slivers: [
        SliverPadding(SliverCachedList(body), {
          padding: options.padding ?? EdgeInsets.all(32),
        }),
      ],
    })
  );
}

function ActionsGroup(model) {
  const group = componentGroups[0];
  return ComponentGroup(group.label, group.description, [
    ButtonsCard(model),
    FloatingActionButtonsCard(),
    IconToggleButtonsCard(model),
    ToggleButtonsCard(model),
    SegmentedButtonsCard(model),
  ]);
}

function CommunicationGroup(model) {
  const group = componentGroups[1];
  return ComponentGroup(group.label, group.description, [
    NavigationBarsCard(model),
    ProgressIndicatorsCard(model),
    SnackBarCard(model),
  ]);
}

function ContainmentGroup(model) {
  const group = componentGroups[2];
  return ComponentGroup(group.label, group.description, [
    BottomSheetCard(model),
    CardsCard(),
    GridTilesCard(),
    InteractiveViewerCard(),
    ExpansionPanelsCard(),
    CarouselsCard(model),
    DialogsCard(model),
    DividersCard(),
  ]);
}

function NavigationGroup(model) {
  const group = componentGroups[3];
  return ComponentGroup(group.label, group.description, [
    BottomAppBarsCard(),
    NavigationBarsCard(model, "NavigationBar"),
    NavigationDrawersCard(model),
    NavigationRailsCard(model),
    TabsCard(model),
    SearchAnchorsCard(model),
    TopAppBarsCard(),
    MenusCard(model),
  ]);
}

function SelectionGroup(model) {
  const group = componentGroups[4];
  return ComponentGroup(group.label, group.description, [
    CheckboxesCard(model),
    ChipsCard(model),
    DatePickerCard(model),
    TimePickerCard(model),
    RadiosCard(model),
    SlidersCard(model),
    SwitchesCard(model),
  ]);
}

function TextInputsGroup(model) {
  const group = componentGroups[5];
  return ComponentGroup(group.label, group.description, [TextFieldsCard(model)]);
}

function ButtonsCard(model) {
  return DemoCard(
    "Common buttons",
    "Use ElevatedButton, FilledButton, FilledButton.tonal, OutlinedButton, or TextButton.",
    SingleChildScrollView(
      Row([
        ButtonColumn(false, model),
        SizedBox({ width: 20 }),
        IconButtonColumn(model),
        SizedBox({ width: 20 }),
        ButtonColumn(true, model),
      ]).main("spaceAround").cross("start"),
      { scrollDirection: "horizontal" }
    )
  );
}

function ButtonColumn(disabled, model) {
  const onPressed = disabled ? null : () => model.toggleSnackbar();
  return Padding(
    SizedBox(
      VStack(
        ElevatedButton("Elevated", { onPressed }),
        FilledButton("Filled", { onPressed }),
        FilledButton.tonal("Filled tonal", { onPressed }),
        OutlinedButton("Outlined", { onPressed }),
        TextButton("Text", { onPressed })
      ).gap(10).cross("stretch"),
      { width: 130 }
    ),
    { padding: { horizontal: 5 } }
  );
}

function IconButtonColumn(model) {
  const onPressed = () => model.toggleSnackbar();
  return Padding(
    SizedBox(
      VStack(
        ElevatedButton.icon({ icon: Icon(Icons.add), label: Txt("Icon"), onPressed }),
        FilledButton.icon({ icon: Icon(Icons.add), label: Txt("Icon"), onPressed }),
        FilledButton.tonalIcon({ icon: Icon(Icons.add), label: Txt("Icon"), onPressed }),
        OutlinedButton.icon({ icon: Icon(Icons.add), label: Txt("Icon"), onPressed }),
        TextButton.icon({ icon: Icon(Icons.add), label: Txt("Icon"), onPressed })
      ).gap(10).cross("stretch"),
      { width: 130 }
    ),
    { padding: { horizontal: 10 } }
  );
}

function FloatingActionButtonsCard() {
  return DemoCard(
    "FloatingActionButtons",
    "Small, regular, large, and extended floating action buttons.",
    ButtonStrip([
      FloatingActionButton.small({ child: Icon(Icons.add), tooltip: "Small" }),
      FloatingActionButton(Icon(Icons.add)),
      FloatingActionButton.large({ child: Icon(Icons.add), tooltip: "Large" }),
      FloatingActionButton.extended({ icon: Icon(Icons.add), label: Txt("Create") }),
    ])
  );
}

function IconToggleButtonsCard(model) {
  return DemoCard(
    "Icon buttons",
    "Use IconButton, IconButton.filled, IconButton.filledTonal, and IconButton.outlined.",
    Row([
      IconToggleColumn(IconButton, "standard", model),
      IconToggleColumn(IconButton.filled, "filled", model),
      IconToggleColumn(IconButton.filledTonal, "tonal", model),
      IconToggleColumn(IconButton.outlined, "outlined", model),
    ]).main("spaceAround").cross("start")
  );
}

function IconToggleColumn(factory, key, model) {
  const selected = model.iconButtonSelected(key);
  const props = {
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    selected,
  };
  return VStack(
    factory({ ...props, onPressed: () => model.toggleIcon(key) }),
    SizedBox({ height: 10 }),
    factory({ ...props, onPressed: null })
  );
}

function SegmentedButtonsCard(model) {
  const movement = [
    ButtonSegment({ value: "walk", icon: Icon(Icons.directions_walk), label: Txt("Walk") }),
    ButtonSegment({ value: "bus", icon: Icon(Icons.directions_bus), label: Txt("Bus") }),
    ButtonSegment({ value: "rail", icon: Icon(Icons.train), label: Txt("Rail") }),
  ];
  const sizes = [
    ButtonSegment({ value: "xs", label: Txt("XS") }),
    ButtonSegment({ value: "s", label: Txt("S") }),
    ButtonSegment({ value: "m", label: Txt("M") }),
    ButtonSegment({ value: "l", label: Txt("L") }),
  ];
  return DemoCard(
    "SegmentedButtons",
    "Single and multi-select segmented controls.",
    VStack(
      ControlLabel("Single choice", model.singleChoice),
      SegmentedButton({
        segments: movement,
        selected: [model.singleChoice],
        onSelectionChanged: (value) => model.setSingleChoice(value),
      }),
      ControlLabel("Multiple choice", model.multiChoice.join(", ")),
      SegmentedButton({
        segments: sizes,
        selected: model.multiChoice,
        multiSelectionEnabled: true,
        emptySelectionAllowed: true,
        onSelectionChanged: (value) => model.setMultiChoice(value),
      })
    ).gap(12).cross("stretch"),
    { wide: true }
  );
}

function ToggleButtonsCard(model) {
  const values = ["xs", "s", "m"];
  const selected = values.map((value) => model.multiChoice.includes(value));
  return DemoCard(
    "ToggleButtons",
    "Legacy Flutter toggle buttons using the same global theme.",
    VStack(
      ControlLabel("Selected", model.multiChoice.join(", ") || "None"),
      ToggleButtons({
        children: values.map((value) => Txt(value.toUpperCase())),
        isSelected: selected,
        onPressed: (event) => {
          const next = values.filter((_, index) => event.isSelected[index]);
          model.setMultiChoice(next);
        },
      })
    ).gap(12).cross("start")
  );
}

function NavigationBarsCard(model, title = "NavigationBars") {
  return DemoCard(
    title,
    "Destinations with selected icons and badges.",
    NavigationBar({
      selectedIndex: model.navExampleIndex,
      onDestinationSelected: (index) => model.selectNavExample(index),
      destinations: [
        NavigationDestination({
          icon: Badge.count(3, { child: Icon(Icons.notifications) }),
          selectedIcon: Icon(Icons.notifications),
          label: "Explore",
        }),
        NavigationDestination({
          icon: Icon(Icons.widgets),
          selectedIcon: Icon(Icons.widgets),
          label: "Components",
        }),
        NavigationDestination({
          icon: Badge.count({ count: 12, maxCount: 9, child: Icon(Icons.mail_outlined) }),
          selectedIcon: Icon(Icons.mail),
          label: "Messages",
        }),
      ],
    }),
    { wide: true }
  );
}

function ProgressIndicatorsCard(model) {
  const value = model.snackbarVisible ? null : 0.68;
  return DemoCard(
    "ProgressIndicators",
    "Determinate and indeterminate progress indicators.",
    VStack(
      LinearProgressIndicator({ value }),
      Row([
        CircularProgressIndicator({ value: 0.72 }),
        CircularProgressIndicator.adaptive({ value }),
      ]).gap(24).cross("center"),
      FillButton(model.snackbarVisible ? "Pause" : "Play", () => model.toggleSnackbar(), model.snackbarVisible ? Icons.pause : Icons.play_arrow)
    ).gap(16).cross("stretch")
  );
}

function SnackBarCard(model) {
  return DemoCard(
    "SnackBar",
    "A state-driven snackbar sample for Applet scripts.",
    VStack(
      FillButton(model.snackbarVisible ? "Hide snackbar" : "Show snackbar", () => model.toggleSnackbar())
    ).gap(12).cross("stretch")
  );
}

function BottomSheetCard(model) {
  return DemoCard(
    "BottomSheet",
    "A persistent bottom sheet presented through Scaffold.bottomSheet.",
    VStack(
      FillButton(model.bottomSheetVisible ? "Hide bottom sheet" : "Show bottom sheet", () => model.toggleBottomSheet())
    ).gap(12).cross("stretch"),
    { wide: true }
  );
}

function CardsCard() {
  return DemoCard(
    "Cards",
    "Elevated, filled, and outlined cards.",
    Wrap([
      MaterialCardSample("Elevated", "elevated"),
      MaterialCardSample("Filled", "filled"),
      MaterialCardSample("Outlined", "outlined"),
    ], { spacing: 10, runSpacing: 10 })
  );
}

function MaterialCardSample(label, variant) {
  const content = Padding(
    VStack(
      Row([
        SizedBox({ width: 1 }).expanded(),
        IconButton({ icon: Icon(Icons.more_vert), tooltip: "More" }),
      ]).cross("center"),
      SizedBox({ height: 24 }),
      Txt(label, { style: { theme: "titleMedium" } })
    ).cross("stretch"),
    { padding: { left: 12, top: 4, right: 4, bottom: 12 } }
  );

  if (variant === "filled") {
    return SizedBox(
      Card.filled(content, {
        margin: EdgeInsets.all(0),
        elevation: 0,
        color: { theme: "surfaceContainerHighest" },
      }),
      { width: 136, height: 116 }
    );
  }

  if (variant === "outlined") {
    return SizedBox(
      Card.outlined(content, { margin: EdgeInsets.all(0), elevation: 0 }),
      { width: 136, height: 116 }
    );
  }

  return SizedBox(
    Card(content, { margin: EdgeInsets.all(0), elevation: 1 }),
    { width: 136, height: 116 }
  );
}

function GridTilesCard() {
  const tiles = [
    ["Photos", "Album", "#6750a4"],
    ["Trips", "Saved", "#006a6a"],
    ["Design", "Board", "#984061"],
    ["Reports", "Draft", "#386a20"],
  ];
  return DemoCard(
    "GridTiles",
    "Image-list tiles with GridTileBar footers.",
    SizedBox(
      GridView(
        For(tiles, (tile) =>
          GridTile(Container({ color: tile[2] }), {
            footer: GridTileBar({
              backgroundColor: "#cc000000",
              title: Txt(tile[0]),
              subtitle: Txt(tile[1]),
              trailing: IconButton({ icon: Icon(Icons.more_vert), tooltip: "More" }),
            }),
          })
        ),
        {
          crossAxisCount: 2,
          childAspectRatio: 1.35,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          physics: "never",
          shrinkWrap: true,
        }
      ),
      { height: 240 }
    ),
    { wide: true }
  );
}

function InteractiveViewerCard() {
  const swatches = [
    ["Primary", "#6750a4"],
    ["Tertiary", "#7d5260"],
    ["Error", "#ba1a1a"],
    ["Blue", "#00639b"],
    ["Green", "#386a20"],
    ["Amber", "#725c00"],
  ];
  return DemoCard(
    "InteractiveViewer",
    "A Flutter zoom and pan surface controlled by the JS tree.",
    SizedBox(
      InteractiveViewer(
        Container({
          color: "#f7f2fa",
          padding: { all: 16 },
          child: GridView(
            For(swatches, (item) => Swatch(item[0], item[1], "#ffffff", 96)),
            {
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              physics: "never",
              shrinkWrap: true,
            }
          ),
        }),
        {
          boundaryMargin: { all: 24 },
          minScale: 0.8,
          maxScale: 3,
          panAxis: "free",
        }
      ),
      { height: 240 }
    ),
    { wide: true }
  );
}

function ExpansionPanelsCard() {
  return DemoCard(
    "ExpansionPanels",
    "Radio expansion panels using a props-object named constructor.",
    ExpansionPanelList.radio({
      initialOpenPanelValue: "overview",
      children: [
        ExpansionPanelRadio({
          value: "overview",
          header: Txt("Overview"),
          body: Padding(Txt("Single-open expansion content."), { padding: { all: 16 } }),
        }),
        ExpansionPanelRadio({
          value: "details",
          header: Txt("Details"),
          body: Padding(Txt("Secondary panel content."), { padding: { all: 16 } }),
        }),
      ],
    }),
    { wide: true }
  );
}

function CarouselsCard(model) {
  const slides = [
    ["Primary", "#6750a4"],
    ["Secondary", "#625b71"],
    ["Tertiary", "#7d5260"],
    ["Surface", "#49454f"],
  ];
  return DemoCard(
    "Carousels",
    "Horizontally scrolling item sets.",
    VStack(
      SizedBox(
        CarouselView(For(slides, (slide, index) =>
          Swatch(slide[0], slide[1], "#ffffff", index === model.carouselIndex ? 112 : 96).onTap(() => model.selectCarousel(index))
        ), { spacing: 10 }),
        { height: 132 }
      ),
      ControlLabel("Selected", slides[model.carouselIndex][0])
    ).gap(12).cross("stretch"),
    { wide: true }
  );
}

function DialogsCard(model) {
  return DemoCard(
    "Dialogs",
    "AlertDialog content is presented through declarative Scaffold.dialog.",
    VStack(
      FillButton(model.dialogVisible ? "Dismiss dialog" : "Show dialog", () => model.toggleDialog())
    ).gap(12).cross("stretch"),
    { wide: true }
  );
}

function DividersCard() {
  return DemoCard(
    "Dividers",
    "Horizontal and vertical dividers.",
    VStack(
      Txt("Before"),
      Divider({ thickness: 1 }),
      Txt("After"),
      SizedBox(Row([Txt("Left"), Divider({ thickness: 1 }).width(24), Txt("Right")]).gap(8), { height: 32 })
    ).gap(8).cross("stretch")
  );
}

function BottomAppBarsCard() {
  return DemoCard(
    "BottomAppBars",
    "Navigation and floating action entry points.",
    BottomAppBar(
      Row([
        IconButton({ icon: Icon(Icons.menu), tooltip: "Menu" }),
        IconButton({ icon: Icon(Icons.search), tooltip: "Search" }),
        IconButton({ icon: Icon(Icons.favorite), tooltip: "Favorite" }),
        SizedBox({ width: 16 }).expanded(),
        FloatingActionButton.small({ child: Icon(Icons.add), tooltip: "Create" }),
      ]).cross("center"),
      { height: 72, padding: { horizontal: 10, vertical: 8 } }
    ),
    { wide: true }
  );
}

function NavigationDrawersCard(model) {
  return DemoCard(
    "NavigationDrawers",
    "Drawer destinations with selected state.",
    SizedBox(
      NavigationDrawer([
        NavigationDrawerDestination({ icon: Icon(Icons.inbox), label: Txt("Inbox") }),
        NavigationDrawerDestination({ icon: Icon(Icons.article), label: Txt("Articles") }),
        NavigationDrawerDestination({ icon: Icon(Icons.chat_bubble_outline), label: Txt("Messages") }),
        Divider({ indent: 28, endIndent: 28 }),
        NavigationDrawerDestination({ icon: Icon(Icons.settings), label: Txt("Settings") }),
      ], {
        selectedIndex: model.drawerIndex,
        onDestinationSelected: (index) => model.selectDrawer(index),
      }),
      { height: 360 }
    )
  );
}

function NavigationRailsCard(model) {
  return DemoCard(
    "NavigationRails",
    "Compact side navigation for wider layouts.",
    SizedBox(
      Row([
        NavigationRail({
          selectedIndex: model.railIndex,
          onDestinationSelected: (index) => model.selectRail(index),
          destinations: [
            NavigationRailDestination({ icon: Icon(Icons.explore), label: Txt("Explore") }),
            NavigationRailDestination({ icon: Icon(Icons.widgets), label: Txt("Widgets") }),
            NavigationRailDestination({ icon: Icon(Icons.settings), label: Txt("Settings") }),
          ],
        }),
        NavigationPlaceholder("Rail destination", "Index " + model.railIndex, Icons.widgets).expanded(),
      ]).cross("stretch"),
      { height: 220 }
    ),
    { wide: true }
  );
}

function TabsCard(model) {
  return DemoCard(
    "Tabs",
    "TabBar and TabBarView in a DefaultTabController.",
    SizedBox(
      DefaultTabController(
        VStack(
          TabBar({ tabs: [Tab({ text: "One" }), Tab({ text: "Two" }), Tab({ text: "Three" })], onTap: (index) => model.selectTab(index) }),
          TabBarView([
            NavigationPlaceholder("Tab one", "Navigation and app bars", Icons.explore),
            NavigationPlaceholder("Tab two", "Components and controls", Icons.widgets),
            NavigationPlaceholder("Tab three", "Settings and preferences", Icons.settings),
          ]).expanded(),
        ).cross("stretch"),
        { length: 3, initialIndex: model.tabIndex }
      ),
      { height: 250 }
    ),
    { wide: true }
  );
}

function SearchAnchorsCard(model) {
  const suggestions = ["Buttons", "Cards", "Navigation", "Text fields"];
  const visible = model.searchValue.length > 0;
  return DemoCard(
    "SearchAnchors",
    "SearchBar plus state-driven suggestions.",
    VStack(
      SearchBar({
        hintText: "Search components",
        leading: Icon(Icons.search),
        trailing: [IconButton({ icon: Icon(Icons.close), tooltip: "Clear", onPressed: () => model.setSearch("") })],
        onChanged: (value) => model.setSearch(value),
      }),
      Visibility(
        Wrap(For(suggestions, (item) => ActionChip({ label: Txt(item), onPressed: () => model.setSearch(item) })), { spacing: 8, runSpacing: 8 }),
        { visible }
      ),
      ControlLabel("Query", model.searchValue || "None")
    ).gap(12).cross("stretch"),
    { wide: true }
  );
}

function TopAppBarsCard() {
  return DemoCard(
    "TopAppBars",
    "Small, center-aligned, medium, and large Material 3 top app bars.",
    VStack(
      SizedBox(
        AppBar({
          leading: IconButton({ icon: Icon(Icons.arrow_back), tooltip: "Back" }),
          title: Txt("Small"),
          actions: [
            IconButton({ icon: Icon(Icons.attach_file), tooltip: "Attach" }),
            IconButton({ icon: Icon(Icons.event), tooltip: "Calendar" }),
            IconButton({ icon: Icon(Icons.more_vert), tooltip: "More" }),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: "#fef7ff",
          surfaceTintColor: "#6750a4",
        }),
        { height: 64 }
      ),
      SizedBox(
        AppBar({
          leading: IconButton({ icon: Icon(Icons.arrow_back), tooltip: "Back" }),
          title: Txt("Center-aligned"),
          centerTitle: true,
          actions: [
            IconButton({ icon: Icon(Icons.account_circle_outlined), tooltip: "Account" }),
            IconButton({ icon: Icon(Icons.more_vert), tooltip: "More" }),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: "#fef7ff",
          surfaceTintColor: "#6750a4",
        }),
        { height: 64 }
      ),
      TopAppBarScrollPreview("Medium", "medium"),
      TopAppBarScrollPreview("Large", "large")
    ).gap(10).cross("stretch"),
    { wide: true }
  );
}

function TopAppBarScrollPreview(title, variant) {
  const bar = variant === "large" ? SliverAppBar.large : SliverAppBar.medium;
  return Container(
    SizedBox(
      CustomScrollView({
        shrinkWrap: true,
        physics: "never",
        slivers: [
          bar({
            title: Txt(title),
            leading: IconButton({ icon: Icon(Icons.menu), tooltip: "Menu" }),
            actions: [
              IconButton({ icon: Icon(Icons.search), tooltip: "Search" }),
              IconButton({ icon: Icon(Icons.more_vert), tooltip: "More" }),
            ],
            primary: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: "#fef7ff",
            surfaceTintColor: "#6750a4",
          }),
          SliverToBoxAdapter(
            Container(Txt("Scrollable content area"), {
              height: 64,
              alignment: "center",
              decoration: { color: "#ffffff" },
            })
          ),
        ],
      }),
      { height: variant === "large" ? 184 : 152 }
    ),
    {
      clipBehavior: "antiAlias",
      decoration: { borderRadius: 8, border: { color: "#e7e0ec", width: 1 } },
    }
  );
}

function MenusCard(model) {
  const entries = ["One", "Two", "Three"].map((value) => DropdownMenuEntry({ value, label: value }));
  return DemoCard(
    "Menus",
    "PopupMenuButton and DropdownMenu.",
    VStack(
      PopupMenuButton({
        icon: Icon(Icons.more_vert),
        tooltip: "Show menu",
        onSelected: (value) => model.setMenu(value),
        items: menuItems(entries, (item) => Txt(item.label)),
      }),
      DropdownMenu({
        initialSelection: model.menuValue,
        dropdownMenuEntries: entries,
        onSelected: (value) => model.setMenu(value),
        isExpanded: true,
      }),
      ControlLabel("Selected", model.menuValue)
    ).gap(12).cross("stretch")
  );
}

function CheckboxesCard(model) {
  return DemoCard(
    "Checkboxes",
    "Checkbox and CheckboxListTile with tristate support.",
    VStack(
      Row([
        Checkbox.adaptive({ value: model.checkboxOne, onChanged: (value) => model.setCheckboxOne(value) }),
        Txt("Standalone checkbox"),
      ]).gap(8).cross("center"),
      CheckboxListTile({ title: Txt("Option 1"), value: model.checkboxOne, onChanged: (value) => model.setCheckboxOne(value) }),
      CheckboxListTile.adaptive({ title: Txt("Option 2"), value: model.checkboxTwo, onChanged: (value) => model.setCheckboxTwo(value) }),
      CheckboxListTile({ title: Txt("Option 3"), value: model.checkboxThree, tristate: true, onChanged: (value) => model.setCheckboxThree(value) })
    ).cross("stretch")
  );
}

function ChipsCard(model) {
  return DemoCard(
    "Chips",
    "Assist, filter, input, and suggestion chips.",
    Wrap([
      ActionChip({ avatar: Icon(Icons.event), label: Txt("Assist"), onPressed: () => model.toggleSnackbar() }),
      FilterChip({ label: Txt("Filter"), selected: model.filterChip, onSelected: (value) => model.setFilterChip(value) }),
      InputChip({ label: Txt("Input"), selected: model.inputChip, onSelected: (value) => model.setInputChip(value), onDeleted: () => model.setInputChip(false) }),
      ChoiceChip({ label: Txt("Suggestion"), selected: model.singleChoice === "walk", onSelected: () => model.setSingleChoice(["walk"]) }),
      Chip({ label: Txt("Static") }),
    ], { spacing: 8, runSpacing: 8 })
  );
}

function DatePickerCard(model) {
  return DemoCard(
    "DatePicker",
    "DatePickerDialog result is returned to JavaScript state.",
    VStack(
      ControlLabel("Selected date", model.dateValue),
      ButtonStrip([
        FilledButton.icon({ icon: Icon(Icons.calendar_month), label: Txt("Choose date"), onPressed: () => model.toggleDatePicker() }),
        OutlinedButton("Reset", { onPressed: () => model.setDate("2026-06-29") }),
      ])
    ).gap(12).cross("stretch")
  );
}

function TimePickerCard(model) {
  return DemoCard(
    "TimePicker",
    "TimePickerDialog result is returned to JavaScript state.",
    VStack(
      ControlLabel("Selected time", model.timeValue),
      ButtonStrip([
        FilledButton.icon({ icon: Icon(Icons.schedule), label: Txt("Choose time"), onPressed: () => model.toggleTimePicker() }),
        OutlinedButton("Reset", { onPressed: () => model.setTime("10:30") }),
      ])
    ).gap(12).cross("stretch")
  );
}

function RadiosCard(model) {
  return DemoCard(
    "Radios",
    "RadioListTile choices with group state.",
    VStack(
      RadioListTile({ title: Txt("Option 1"), value: "one", groupValue: model.radioValue, onChanged: (value) => model.setRadio(value) }),
      RadioListTile.adaptive({ title: Txt("Option 2"), value: "two", groupValue: model.radioValue, onChanged: (value) => model.setRadio(value) }),
      RadioListTile({ title: Txt("Option 3"), value: "three", groupValue: model.radioValue, onChanged: (value) => model.setRadio(value) })
    ).cross("stretch")
  );
}

function SlidersCard(model) {
  return DemoCard(
    "Sliders",
    "Slider and RangeSlider emit numeric JS payloads.",
    VStack(
      ControlLabel("Value", Math.round(model.sliderValue)),
      Slider.adaptive({ value: model.sliderValue, min: 0, max: 100, divisions: 20, label: String(Math.round(model.sliderValue)), onChanged: (value) => model.setSlider(value) }),
      ControlLabel("Range", Math.round(model.rangeStart) + " - " + Math.round(model.rangeEnd)),
      RangeSlider({
        values: { start: model.rangeStart, end: model.rangeEnd },
        min: 0,
        max: 100,
        divisions: 20,
        labels: true,
        onChanged: (value) => model.setRange(value),
      })
    ).gap(12).cross("stretch")
  );
}

function SwitchesCard(model) {
  return DemoCard(
    "Switches",
    "Switch and SwitchListTile.",
    VStack(
      Row([
        Switch.adaptive({ value: model.switchOn, onChanged: (value) => model.setSwitch(value) }),
        Txt(model.switchOn ? "On" : "Off"),
      ]).gap(8).cross("center"),
      SwitchListTile.adaptive({ title: Txt("Wi-Fi"), subtitle: Txt("Use local network"), value: model.switchOn, onChanged: (value) => model.setSwitch(value) })
    ).cross("stretch")
  );
}

function TextFieldsCard(model) {
  return DemoCard(
    "TextFields",
    "Filled and outlined text fields.",
    VStack(
      TextField({
        labelText: "Filled",
        hintText: "Type something",
        prefixIcon: Icon(Icons.search),
        value: model.textValue,
        onChanged: (value) => model.setText(value),
        filled: true,
      }),
      TextField({
        labelText: "Outlined",
        hintText: "Search components",
        prefixIcon: Icon(Icons.search),
        suffixIcon: Icon(Icons.close),
        value: model.textValue,
        onChanged: (value) => model.setText(value),
        border: "outline",
      }),
      ControlLabel("Current text", model.textValue)
    ).gap(12).cross("stretch"),
    { wide: true }
  );
}
