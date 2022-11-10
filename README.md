# flutterflow_colorpicker

[![pub package](https://img.shields.io/pub/v/flutterflow_colorpicker?include_prereleases.svg "FlutterFlow Color Picker")](https://pub.dev/packages/flutterflow_colorpicker)
[![badge](https://img.shields.io/badge/%20built%20with-%20%E2%9D%A4-ff69b4.svg "build with love")](https://github.com/FlutterFlow/flutterflow_colorpicker)

HSV(HSB)/HSL/RGB/Material color picker built on top of [flutter_colorpicker](https://pub.dev/packages/flutterflow_colorpicker) for use in FlutterFlow projects.

## Getting Started

```dart
Color pickedColor = Color(0xFF000000);

final colorPickerResult = await showFFColorPicker(
  context,
  currentColor: pickedColor,
);
if (colorPickerResult != null) {
  setState(() => pickedColor = colorPickerResult);
}
```
