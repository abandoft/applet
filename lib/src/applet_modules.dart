/// Built-in JavaScript ES modules exposed to Applet source files.
const Map<String, String> appletBuiltinModules = <String, String>{
  '@app/core': _appletCoreModule,
  '@app/widgets': _appletWidgetsModule,
  '@app/layout': _appletLayoutModule,
  '@app/material': _appletMaterialModule,
  '@app/cupertino': _appletCupertinoModule,
  '@applet/core': _appletCoreModule,
  '@applet/widgets': _appletWidgetsModule,
  '@applet/layout': _appletLayoutModule,
  '@applet/material': _appletMaterialModule,
  '@applet/cupertino': _appletCupertinoModule,
};

const String _appletCoreModule = r'''
const Applet = globalThis.Applet;
const Action = globalThis.Action;
const For = globalThis.For;
const Show = globalThis.Show;
const State = globalThis.State;
const Remember = globalThis.Remember;
const Children = globalThis.Children;

export { Applet, Action, For, Show, State, Remember, Children };
''';

const String _appletWidgetsModule = r'''
const Text = globalThis.Text;
const SelectableText = globalThis.SelectableText;
const RichText = globalThis.RichText;
const TextSpan = globalThis.TextSpan;
const TextStyle = globalThis.TextStyle;
const AnimatedDefaultTextStyle = globalThis.AnimatedDefaultTextStyle;
const Icon = globalThis.Icon;
const Image = globalThis.Image;
const Placeholder = globalThis.Placeholder;
const Tooltip = globalThis.Tooltip;
const Hero = globalThis.Hero;
const GestureDetector = globalThis.GestureDetector;
const Listener = globalThis.Listener;
const MouseRegion = globalThis.MouseRegion;
const InteractiveViewer = globalThis.InteractiveViewer;
const Dismissible = globalThis.Dismissible;
const Draggable = globalThis.Draggable;
const LongPressDraggable = globalThis.LongPressDraggable;
const DragTarget = globalThis.DragTarget;
const TapRegion = globalThis.TapRegion;
const TapRegionSurface = globalThis.TapRegionSurface;
const ColoredBox = globalThis.ColoredBox;
const DecoratedBox = globalThis.DecoratedBox;
const RepaintBoundary = globalThis.RepaintBoundary;
const Semantics = globalThis.Semantics;
const ExcludeSemantics = globalThis.ExcludeSemantics;
const MergeSemantics = globalThis.MergeSemantics;
const Directionality = globalThis.Directionality;
const TickerMode = globalThis.TickerMode;
const DefaultSelectionStyle = globalThis.DefaultSelectionStyle;
const DefaultTextStyle = globalThis.DefaultTextStyle;
const IconTheme = globalThis.IconTheme;
const Theme = globalThis.Theme;
const FocusableActionDetector = globalThis.FocusableActionDetector;
const KeyboardListener = globalThis.KeyboardListener;
const CallbackShortcuts = globalThis.CallbackShortcuts;
const ThemeData = globalThis.ThemeData;
const ColorScheme = globalThis.ColorScheme;
const EdgeInsets = globalThis.EdgeInsets;
const BorderRadius = globalThis.BorderRadius;
const BoxDecoration = globalThis.BoxDecoration;
const BoxConstraints = globalThis.BoxConstraints;
const Duration = globalThis.Duration;
const Color = globalThis.Color;
const Colors = globalThis.Colors;
const Icons = globalThis.Icons;

export {
  Text,
  SelectableText,
  RichText,
  TextSpan,
  TextStyle,
  AnimatedDefaultTextStyle,
  Icon,
  Image,
  Placeholder,
  Tooltip,
  Hero,
  GestureDetector,
  Listener,
  MouseRegion,
  InteractiveViewer,
  Dismissible,
  Draggable,
  LongPressDraggable,
  DragTarget,
  TapRegion,
  TapRegionSurface,
  ColoredBox,
  DecoratedBox,
  RepaintBoundary,
  Semantics,
  ExcludeSemantics,
  MergeSemantics,
  Directionality,
  TickerMode,
  DefaultSelectionStyle,
  DefaultTextStyle,
  IconTheme,
  Theme,
  FocusableActionDetector,
  KeyboardListener,
  CallbackShortcuts,
  ThemeData,
  ColorScheme,
  EdgeInsets,
  BorderRadius,
  BoxDecoration,
  BoxConstraints,
  Duration,
  Color,
  Colors,
  Icons,
};
''';

const String _appletLayoutModule = r'''
const SafeArea = globalThis.SafeArea;
const Center = globalThis.Center;
const Align = globalThis.Align;
const Padding = globalThis.Padding;
const Container = globalThis.Container;
const SizedBox = globalThis.SizedBox;
const ConstrainedBox = globalThis.ConstrainedBox;
const LimitedBox = globalThis.LimitedBox;
const UnconstrainedBox = globalThis.UnconstrainedBox;
const OverflowBox = globalThis.OverflowBox;
const SizedOverflowBox = globalThis.SizedOverflowBox;
const AspectRatio = globalThis.AspectRatio;
const FractionallySizedBox = globalThis.FractionallySizedBox;
const FittedBox = globalThis.FittedBox;
const Baseline = globalThis.Baseline;
const IntrinsicWidth = globalThis.IntrinsicWidth;
const IntrinsicHeight = globalThis.IntrinsicHeight;
const Expanded = globalThis.Expanded;
const Flexible = globalThis.Flexible;
const Spacer = globalThis.Spacer;
const Opacity = globalThis.Opacity;
const AnimatedOpacity = globalThis.AnimatedOpacity;
const AnimatedContainer = globalThis.AnimatedContainer;
const AnimatedAlign = globalThis.AnimatedAlign;
const AnimatedPadding = globalThis.AnimatedPadding;
const AnimatedScale = globalThis.AnimatedScale;
const AnimatedRotation = globalThis.AnimatedRotation;
const AnimatedSlide = globalThis.AnimatedSlide;
const AnimatedSize = globalThis.AnimatedSize;
const AnimatedSwitcher = globalThis.AnimatedSwitcher;
const AnimatedCrossFade = globalThis.AnimatedCrossFade;
const AnimatedPhysicalModel = globalThis.AnimatedPhysicalModel;
const Visibility = globalThis.Visibility;
const Offstage = globalThis.Offstage;
const IgnorePointer = globalThis.IgnorePointer;
const AbsorbPointer = globalThis.AbsorbPointer;
const ClipRRect = globalThis.ClipRRect;
const ClipOval = globalThis.ClipOval;
const ClipRect = globalThis.ClipRect;
const PhysicalModel = globalThis.PhysicalModel;
const RotatedBox = globalThis.RotatedBox;
const Transform = globalThis.Transform;
const InteractiveViewer = globalThis.InteractiveViewer;
const SingleChildScrollView = globalThis.SingleChildScrollView;
const CustomScrollView = globalThis.CustomScrollView;
const SliverToBoxAdapter = globalThis.SliverToBoxAdapter;
const SliverPadding = globalThis.SliverPadding;
const SliverList = globalThis.SliverList;
const SliverCachedList = globalThis.SliverCachedList;
const SliverEstimatedList = globalThis.SliverEstimatedList;
const SliverGrid = globalThis.SliverGrid;
const SliverFillRemaining = globalThis.SliverFillRemaining;
const SliverAppBar = globalThis.SliverAppBar;
const SliverLayoutBuilder = globalThis.SliverLayoutBuilder;
const Builder = globalThis.Builder;
const LayoutBuilder = globalThis.LayoutBuilder;
const AdaptiveTwoPane = globalThis.AdaptiveTwoPane;
const OrientationBuilder = globalThis.OrientationBuilder;
const MediaQuery = globalThis.MediaQuery;
const Form = globalThis.Form;
const AutofillGroup = globalThis.AutofillGroup;
const Focus = globalThis.Focus;
const FocusTraversalGroup = globalThis.FocusTraversalGroup;
const FocusableActionDetector = globalThis.FocusableActionDetector;
const KeyboardListener = globalThis.KeyboardListener;
const CallbackShortcuts = globalThis.CallbackShortcuts;
const Column = globalThis.Column;
const Row = globalThis.Row;
const Stack = globalThis.Stack;
const IndexedStack = globalThis.IndexedStack;
const Wrap = globalThis.Wrap;
const ListBody = globalThis.ListBody;
const ListView = globalThis.ListView;
const ReorderableListView = globalThis.ReorderableListView;
const ReorderableDragStartListener = globalThis.ReorderableDragStartListener;
const ReorderableDelayedDragStartListener =
  globalThis.ReorderableDelayedDragStartListener;
const GridView = globalThis.GridView;
const PageView = globalThis.PageView;
const VStack = globalThis.VStack;
const HStack = globalThis.HStack;
const ZStack = globalThis.ZStack;
const Scroll = globalThis.Scroll;
const Box = globalThis.Box;
const Positioned = globalThis.Positioned;
const AnimatedPositioned = globalThis.AnimatedPositioned;

export {
  SafeArea,
  Center,
  Align,
  Padding,
  Container,
  SizedBox,
  ConstrainedBox,
  LimitedBox,
  UnconstrainedBox,
  OverflowBox,
  SizedOverflowBox,
  AspectRatio,
  FractionallySizedBox,
  FittedBox,
  Baseline,
  IntrinsicWidth,
  IntrinsicHeight,
  Expanded,
  Flexible,
  Spacer,
  Opacity,
  AnimatedOpacity,
  AnimatedContainer,
  AnimatedAlign,
  AnimatedPadding,
  AnimatedScale,
  AnimatedRotation,
  AnimatedSlide,
  AnimatedSize,
  AnimatedSwitcher,
  AnimatedCrossFade,
  AnimatedPhysicalModel,
  Visibility,
  Offstage,
  IgnorePointer,
  AbsorbPointer,
  ClipRRect,
  ClipOval,
  ClipRect,
  PhysicalModel,
  RotatedBox,
  Transform,
  InteractiveViewer,
  SingleChildScrollView,
  CustomScrollView,
  SliverToBoxAdapter,
  SliverPadding,
  SliverList,
  SliverCachedList,
  SliverEstimatedList,
  SliverGrid,
  SliverFillRemaining,
  SliverAppBar,
  SliverLayoutBuilder,
  Builder,
  LayoutBuilder,
  AdaptiveTwoPane,
  OrientationBuilder,
  MediaQuery,
  Form,
  AutofillGroup,
  Focus,
  FocusTraversalGroup,
  FocusableActionDetector,
  KeyboardListener,
  CallbackShortcuts,
  Column,
  Row,
  Stack,
  IndexedStack,
  Wrap,
  ListBody,
  ListView,
  ReorderableListView,
  ReorderableDragStartListener,
  ReorderableDelayedDragStartListener,
  GridView,
  PageView,
  VStack,
  HStack,
  ZStack,
  Scroll,
  Box,
  Positioned,
  AnimatedPositioned,
};
''';

const String _appletMaterialModule = r'''
export {
  Applet,
  Action,
  For,
  Show,
  State,
  Remember,
  Children,
} from "@app/core";
export * from "@app/widgets";
export * from "@app/layout";

const MaterialApp = globalThis.MaterialApp;
const AnimatedTheme = globalThis.AnimatedTheme;
const Scaffold = globalThis.Scaffold;
const AdaptiveNavigationScaffold = globalThis.AdaptiveNavigationScaffold;
const ScaffoldMessenger = globalThis.ScaffoldMessenger;
const AppBar = globalThis.AppBar;
const SelectionArea = globalThis.SelectionArea;
const Material = globalThis.Material;
const InkWell = globalThis.InkWell;
const Card = globalThis.Card;
const GridTile = globalThis.GridTile;
const GridTileBar = globalThis.GridTileBar;
const CircleAvatar = globalThis.CircleAvatar;
const Badge = globalThis.Badge;
const Banner = globalThis.Banner;
const MaterialBanner = globalThis.MaterialBanner;
const Drawer = globalThis.Drawer;
const DrawerHeader = globalThis.DrawerHeader;
const ListTile = globalThis.ListTile;
const ExpansionTile = globalThis.ExpansionTile;
const ExpansionPanelList = globalThis.ExpansionPanelList;
const ExpansionPanel = globalThis.ExpansionPanel;
const ExpansionPanelRadio = globalThis.ExpansionPanelRadio;
const Divider = globalThis.Divider;
const VerticalDivider = globalThis.VerticalDivider;
const Chip = globalThis.Chip;
const ActionChip = globalThis.ActionChip;
const FilterChip = globalThis.FilterChip;
const ChoiceChip = globalThis.ChoiceChip;
const InputChip = globalThis.InputChip;
const Button = globalThis.Button;
const ElevatedButton = globalThis.ElevatedButton;
const FilledButton = globalThis.FilledButton;
const OutlinedButton = globalThis.OutlinedButton;
const TextButton = globalThis.TextButton;
const IconButton = globalThis.IconButton;
const BackButton = globalThis.BackButton;
const CloseButton = globalThis.CloseButton;
const FloatingActionButton = globalThis.FloatingActionButton;
const TextField = globalThis.TextField;
const TextFormField = globalThis.TextFormField;
const Autocomplete = globalThis.Autocomplete;
const InputDecoration = globalThis.InputDecoration;
const ButtonStyle = globalThis.ButtonStyle;
const MenuStyle = globalThis.MenuStyle;
const Switch = globalThis.Switch;
const SwitchListTile = globalThis.SwitchListTile;
const Checkbox = globalThis.Checkbox;
const CheckboxListTile = globalThis.CheckboxListTile;
const Radio = globalThis.Radio;
const RadioListTile = globalThis.RadioListTile;
const Slider = globalThis.Slider;
const RangeSlider = globalThis.RangeSlider;
const ToggleButtons = globalThis.ToggleButtons;
const SegmentedButton = globalThis.SegmentedButton;
const ButtonSegment = globalThis.ButtonSegment;
const DropdownButton = globalThis.DropdownButton;
const DropdownMenuItem = globalThis.DropdownMenuItem;
const DropdownMenu = globalThis.DropdownMenu;
const DropdownMenuEntry = globalThis.DropdownMenuEntry;
const PopupMenuButton = globalThis.PopupMenuButton;
const PopupMenuItem = globalThis.PopupMenuItem;
const CheckedPopupMenuItem = globalThis.CheckedPopupMenuItem;
const PopupMenuDivider = globalThis.PopupMenuDivider;
const MenuBar = globalThis.MenuBar;
const MenuAnchor = globalThis.MenuAnchor;
const MenuItemButton = globalThis.MenuItemButton;
const CheckboxMenuButton = globalThis.CheckboxMenuButton;
const RadioMenuButton = globalThis.RadioMenuButton;
const SubmenuButton = globalThis.SubmenuButton;
const LinearProgressIndicator = globalThis.LinearProgressIndicator;
const CircularProgressIndicator = globalThis.CircularProgressIndicator;
const RefreshIndicator = globalThis.RefreshIndicator;
const AlertDialog = globalThis.AlertDialog;
const Dialog = globalThis.Dialog;
const BottomSheet = globalThis.BottomSheet;
const SimpleDialog = globalThis.SimpleDialog;
const SnackBar = globalThis.SnackBar;
const SnackBarAction = globalThis.SnackBarAction;
const DatePickerDialog = globalThis.DatePickerDialog;
const TimePickerDialog = globalThis.TimePickerDialog;
const SearchBar = globalThis.SearchBar;
const SearchAnchor = globalThis.SearchAnchor;
const Scrollbar = globalThis.Scrollbar;
const NavigationBar = globalThis.NavigationBar;
const NavigationDestination = globalThis.NavigationDestination;
const NavigationRail = globalThis.NavigationRail;
const NavigationRailDestination = globalThis.NavigationRailDestination;
const NavigationDrawer = globalThis.NavigationDrawer;
const NavigationDrawerDestination = globalThis.NavigationDrawerDestination;
const BottomNavigationBar = globalThis.BottomNavigationBar;
const BottomNavigationBarItem = globalThis.BottomNavigationBarItem;
const BottomAppBar = globalThis.BottomAppBar;
const DefaultTabController = globalThis.DefaultTabController;
const TabBar = globalThis.TabBar;
const TabBarView = globalThis.TabBarView;
const Tab = globalThis.Tab;
const Stepper = globalThis.Stepper;
const Step = globalThis.Step;
const DataTable = globalThis.DataTable;
const DataColumn = globalThis.DataColumn;
const DataRow = globalThis.DataRow;
const DataCell = globalThis.DataCell;
const Table = globalThis.Table;
const TableRow = globalThis.TableRow;
const CarouselView = globalThis.CarouselView;

export {
  MaterialApp,
  AnimatedTheme,
  Scaffold,
  AdaptiveNavigationScaffold,
  ScaffoldMessenger,
  AppBar,
  SelectionArea,
  Material,
  InkWell,
  Card,
  GridTile,
  GridTileBar,
  CircleAvatar,
  Badge,
  Banner,
  MaterialBanner,
  Drawer,
  DrawerHeader,
  ListTile,
  ExpansionTile,
  ExpansionPanelList,
  ExpansionPanel,
  ExpansionPanelRadio,
  Divider,
  VerticalDivider,
  Chip,
  ActionChip,
  FilterChip,
  ChoiceChip,
  InputChip,
  Button,
  ElevatedButton,
  FilledButton,
  OutlinedButton,
  TextButton,
  IconButton,
  BackButton,
  CloseButton,
  FloatingActionButton,
  TextField,
  TextFormField,
  Autocomplete,
  InputDecoration,
  ButtonStyle,
  MenuStyle,
  Switch,
  SwitchListTile,
  Checkbox,
  CheckboxListTile,
  Radio,
  RadioListTile,
  Slider,
  RangeSlider,
  ToggleButtons,
  SegmentedButton,
  ButtonSegment,
  DropdownButton,
  DropdownMenuItem,
  DropdownMenu,
  DropdownMenuEntry,
  PopupMenuButton,
  PopupMenuItem,
  CheckedPopupMenuItem,
  PopupMenuDivider,
  MenuBar,
  MenuAnchor,
  MenuItemButton,
  CheckboxMenuButton,
  RadioMenuButton,
  SubmenuButton,
  LinearProgressIndicator,
  CircularProgressIndicator,
  RefreshIndicator,
  AlertDialog,
  Dialog,
  BottomSheet,
  SimpleDialog,
  SnackBar,
  SnackBarAction,
  DatePickerDialog,
  TimePickerDialog,
  SearchBar,
  SearchAnchor,
  Scrollbar,
  NavigationBar,
  NavigationDestination,
  NavigationRail,
  NavigationRailDestination,
  NavigationDrawer,
  NavigationDrawerDestination,
  BottomNavigationBar,
  BottomNavigationBarItem,
  BottomAppBar,
  DefaultTabController,
  TabBar,
  TabBarView,
  Tab,
  Stepper,
  Step,
  DataTable,
  DataColumn,
  DataRow,
  DataCell,
  Table,
  TableRow,
  CarouselView,
};
''';

const String _appletCupertinoModule = r'''
export {
  Applet,
  Action,
  For,
  Show,
  State,
  Remember,
  Children,
} from "@app/core";
export * from "@app/widgets";
export * from "@app/layout";

const CupertinoApp = globalThis.CupertinoApp;
const CupertinoPageScaffold = globalThis.CupertinoPageScaffold;
const CupertinoNavigationBar = globalThis.CupertinoNavigationBar;
const CupertinoSliverNavigationBar = globalThis.CupertinoSliverNavigationBar;
const CupertinoNavigationBarBackButton =
  globalThis.CupertinoNavigationBarBackButton;
const CupertinoAlertDialog = globalThis.CupertinoAlertDialog;
const CupertinoActionSheet = globalThis.CupertinoActionSheet;
const CupertinoDialogAction = globalThis.CupertinoDialogAction;
const CupertinoActionSheetAction = globalThis.CupertinoActionSheetAction;
const CupertinoListSection = globalThis.CupertinoListSection;
const CupertinoListTile = globalThis.CupertinoListTile;
const CupertinoListTileChevron = globalThis.CupertinoListTileChevron;
const CupertinoFormSection = globalThis.CupertinoFormSection;
const CupertinoFormRow = globalThis.CupertinoFormRow;
const CupertinoPicker = globalThis.CupertinoPicker;
const CupertinoPickerDefaultSelectionOverlay =
  globalThis.CupertinoPickerDefaultSelectionOverlay;
const CupertinoDatePicker = globalThis.CupertinoDatePicker;
const CupertinoTimerPicker = globalThis.CupertinoTimerPicker;
const CupertinoSegmentedControl = globalThis.CupertinoSegmentedControl;
const CupertinoSlidingSegmentedControl = globalThis.CupertinoSlidingSegmentedControl;
const CupertinoSearchTextField = globalThis.CupertinoSearchTextField;
const CupertinoScrollbar = globalThis.CupertinoScrollbar;
const CupertinoTabBar = globalThis.CupertinoTabBar;
const CupertinoButton = globalThis.CupertinoButton;
const CupertinoSwitch = globalThis.CupertinoSwitch;
const CupertinoCheckbox = globalThis.CupertinoCheckbox;
const CupertinoRadio = globalThis.CupertinoRadio;
const CupertinoSlider = globalThis.CupertinoSlider;
const CupertinoActivityIndicator = globalThis.CupertinoActivityIndicator;
const CupertinoTextField = globalThis.CupertinoTextField;
const CupertinoTextFormFieldRow = globalThis.CupertinoTextFormFieldRow;

export {
  CupertinoApp,
  CupertinoPageScaffold,
  CupertinoNavigationBar,
  CupertinoSliverNavigationBar,
  CupertinoNavigationBarBackButton,
  CupertinoAlertDialog,
  CupertinoActionSheet,
  CupertinoDialogAction,
  CupertinoActionSheetAction,
  CupertinoListSection,
  CupertinoListTile,
  CupertinoListTileChevron,
  CupertinoFormSection,
  CupertinoFormRow,
  CupertinoPicker,
  CupertinoPickerDefaultSelectionOverlay,
  CupertinoDatePicker,
  CupertinoTimerPicker,
  CupertinoSegmentedControl,
  CupertinoSlidingSegmentedControl,
  CupertinoSearchTextField,
  CupertinoScrollbar,
  CupertinoTabBar,
  CupertinoButton,
  CupertinoSwitch,
  CupertinoCheckbox,
  CupertinoRadio,
  CupertinoSlider,
  CupertinoActivityIndicator,
  CupertinoTextField,
  CupertinoTextFormFieldRow,
};
''';
