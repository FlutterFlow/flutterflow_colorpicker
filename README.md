# flutterflow_colorpicker

[![pub package](https://img.shields.io/pub/v/flutterflow_colorpicker?include_prereleases.svg "FlutterFlow Color Picker")](https://pub.dev/packages/flutterflow_colorpicker)
[![badge](https://img.shields.io/badge/%20built%20with-%20%E2%9D%A4-ff69b4.svg "build with love")](https://github.com/mchome/flutterflow_colorpicker)

HSV(HSB)/HSL/RGB/Material color picker built on top of flutter_colorpicker(https://pub.dev/packages/flutterflow_colorpicker) for use in FlutterFlow projects.

[Web Example](https://mchome.github.io/flutterflow_colorpicker)

## Getting Started

```dart
Color pickedColor = Color(0xff443a49);

// raise the [showDialog] widget
final colorPickerResult = await showColorPicker();
if (colorPickerResult != null) {
  setState(() => pickedColor = colorPickerResult);
}
```
