import { State } from "@app/material";

const initialState = {
  screenIndex: 0,
  useMaterial3: true,
  themeMode: "light",
  colorSelectionMethod: "colorSeed",
  colorSeedIndex: 0,
  imageIndex: 0,
  buttonsEnabled: true,
  iconSelected: false,
  iconSelections: {
    standard: false,
    filled: false,
    tonal: false,
    outlined: false,
  },
  singleChoice: "walk",
  multiChoice: ["xs"],
  navExampleIndex: 0,
  drawerIndex: 0,
  railIndex: 0,
  tabIndex: 0,
  snackbarVisible: false,
  dialogVisible: false,
  bottomSheetVisible: false,
  datePickerVisible: false,
  timePickerVisible: false,
  switchOn: true,
  checkboxOne: true,
  checkboxTwo: false,
  checkboxThree: null,
  radioValue: "one",
  filterChip: true,
  inputChip: true,
  sliderValue: 40,
  rangeStart: 20,
  rangeEnd: 80,
  menuValue: "One",
  textValue: "Material 3",
  dateValue: "2026-06-29",
  timeValue: "10:30",
  searchValue: "",
  carouselIndex: 0,
};

function payload(value) {
  return value && typeof value === "object" && "value" in value ? value.value : value;
}

function number(value, fallback = 0) {
  const next = Number(payload(value));
  return Number.isFinite(next) ? next : fallback;
}

function bool(value) {
  return Boolean(payload(value));
}

function text(value) {
  return String(payload(value) ?? "");
}

export function MaterialDemoState() {
  const store = State.key("material3.demo", initialState);

  function update(patch) {
    store.update((current) => ({
      ...current,
      ...(typeof patch === "function" ? patch(current) : patch),
    }));
  }

  const model = {
    get value() {
      return store.value;
    },
    get screenIndex() {
      return number(model.value.screenIndex);
    },
    get useMaterial3() {
      return bool(model.value.useMaterial3);
    },
    get themeMode() {
      return model.value.themeMode;
    },
    get useLightMode() {
      return model.themeMode !== "dark";
    },
    get colorSelectionMethod() {
      return model.value.colorSelectionMethod;
    },
    get colorSeedIndex() {
      return number(model.value.colorSeedIndex);
    },
    get imageIndex() {
      return number(model.value.imageIndex);
    },
    get buttonsEnabled() {
      return bool(model.value.buttonsEnabled);
    },
    get iconSelected() {
      return bool(model.value.iconSelected);
    },
    iconButtonSelected(key) {
      const selections = model.value.iconSelections || {};
      return bool(selections[key]);
    },
    get singleChoice() {
      return model.value.singleChoice;
    },
    get multiChoice() {
      return Array.isArray(model.value.multiChoice) ? model.value.multiChoice : [];
    },
    get navExampleIndex() {
      return number(model.value.navExampleIndex);
    },
    get drawerIndex() {
      return number(model.value.drawerIndex);
    },
    get railIndex() {
      return number(model.value.railIndex);
    },
    get tabIndex() {
      return number(model.value.tabIndex);
    },
    get snackbarVisible() {
      return bool(model.value.snackbarVisible);
    },
    get dialogVisible() {
      return bool(model.value.dialogVisible);
    },
    get bottomSheetVisible() {
      return bool(model.value.bottomSheetVisible);
    },
    get datePickerVisible() {
      return bool(model.value.datePickerVisible);
    },
    get timePickerVisible() {
      return bool(model.value.timePickerVisible);
    },
    get switchOn() {
      return bool(model.value.switchOn);
    },
    get checkboxOne() {
      return bool(model.value.checkboxOne);
    },
    get checkboxTwo() {
      return bool(model.value.checkboxTwo);
    },
    get checkboxThree() {
      return model.value.checkboxThree;
    },
    get radioValue() {
      return model.value.radioValue;
    },
    get filterChip() {
      return bool(model.value.filterChip);
    },
    get inputChip() {
      return bool(model.value.inputChip);
    },
    get sliderValue() {
      return number(model.value.sliderValue);
    },
    get rangeStart() {
      return number(model.value.rangeStart);
    },
    get rangeEnd() {
      return number(model.value.rangeEnd, 80);
    },
    get menuValue() {
      return model.value.menuValue;
    },
    get textValue() {
      return text(model.value.textValue);
    },
    get dateValue() {
      return model.value.dateValue;
    },
    get timeValue() {
      return model.value.timeValue;
    },
    get searchValue() {
      return text(model.value.searchValue);
    },
    get carouselIndex() {
      return number(model.value.carouselIndex);
    },
    selectScreen(index) {
      update({ screenIndex: number(index) });
    },
    toggleBrightness() {
      update({ themeMode: model.useLightMode ? "dark" : "light" });
    },
    toggleMaterialVersion() {
      update({ useMaterial3: !model.useMaterial3 });
    },
    selectSeed(index) {
      update({
        colorSelectionMethod: "colorSeed",
        colorSeedIndex: number(index),
      });
    },
    selectImage(index) {
      update({
        colorSelectionMethod: "image",
        imageIndex: number(index),
      });
    },
    setButtonsEnabled(value) {
      update({ buttonsEnabled: bool(value) });
    },
    toggleIcon(key = "standard") {
      const selections = model.value.iconSelections || {};
      const next = {
        standard: false,
        filled: false,
        tonal: false,
        outlined: false,
        ...selections,
        [key]: !bool(selections[key]),
      };
      update({ iconSelected: next.standard, iconSelections: next });
    },
    setSingleChoice(value) {
      const selected = Array.isArray(value) ? value[0] : value;
      update({ singleChoice: selected || "walk" });
    },
    setMultiChoice(value) {
      update({ multiChoice: Array.isArray(value) ? value : [] });
    },
    selectNavExample(index) {
      update({ navExampleIndex: number(index) });
    },
    selectDrawer(index) {
      update({ drawerIndex: number(index) });
    },
    selectRail(index) {
      update({ railIndex: number(index) });
    },
    selectTab(index) {
      update({ tabIndex: number(index) });
    },
    toggleSnackbar() {
      update({ snackbarVisible: !model.snackbarVisible });
    },
    toggleDialog() {
      update({ dialogVisible: !model.dialogVisible });
    },
    toggleBottomSheet() {
      update({ bottomSheetVisible: !model.bottomSheetVisible });
    },
    toggleDatePicker() {
      update({ datePickerVisible: !model.datePickerVisible });
    },
    toggleTimePicker() {
      update({ timePickerVisible: !model.timePickerVisible });
    },
    setSwitch(value) {
      update({ switchOn: bool(value) });
    },
    setCheckboxOne(value) {
      update({ checkboxOne: bool(value) });
    },
    setCheckboxTwo(value) {
      update({ checkboxTwo: bool(value) });
    },
    setCheckboxThree(value) {
      update({ checkboxThree: value });
    },
    setRadio(value) {
      update({ radioValue: payload(value) });
    },
    setFilterChip(value) {
      update({ filterChip: bool(value) });
    },
    setInputChip(value) {
      update({ inputChip: bool(value) });
    },
    setSlider(value) {
      update({ sliderValue: number(value) });
    },
    setRange(value) {
      update({
        rangeStart: number(value && value.start, model.rangeStart),
        rangeEnd: number(value && value.end, model.rangeEnd),
      });
    },
    setMenu(value) {
      update({ menuValue: payload(value) });
    },
    setText(value) {
      update({ textValue: text(value) });
    },
    setDate(value) {
      update({ dateValue: text(value), datePickerVisible: false });
    },
    setTime(value) {
      update({ timeValue: text(value), timePickerVisible: false });
    },
    setSearch(value) {
      update({ searchValue: text(value) });
    },
    selectCarousel(index) {
      update({ carouselIndex: number(index) });
    },
  };

  return model;
}
