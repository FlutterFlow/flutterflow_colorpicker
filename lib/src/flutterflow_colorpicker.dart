import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palette.dart';
import 'utils.dart';

const _kRecentColorsKey = '__ff_recent_colors__';

const _alphaValueIndex = 3;
const Map<ColorLabelType, List<String>> _colorTypes = {
  ColorLabelType.rgb: ['R', 'G', 'B', 'A'],
  ColorLabelType.hsv: ['H', 'S', 'V', 'A'],
  ColorLabelType.hsl: ['H', 'S', 'L', 'A'],
};

Future<Color?> showFFColorPicker(
  BuildContext context, {
  Color? currentColor,
  bool showRecentColors = false,
  bool allowOpacity = true,
  required bool displayAsBottomSheet,
  Color? textColor,
  Color? secondaryTextColor,
  Color? backgroundColor,
  Color? primaryButtonBackgroundColor,
  Color? primaryButtonTextColor,
  Color? primaryButtonBorderColor,
}) {
  if (displayAsBottomSheet) {
    return showModalBottomSheet<Color?>(
      context: context,
      builder: (context) => Wrap(
        alignment: WrapAlignment.spaceAround,
        children: [
          FFColorPickerDialog(
            currentColor: currentColor,
            showRecentColors: showRecentColors,
            allowOpacity: allowOpacity,
            textColor: textColor ?? Colors.white,
            secondaryTextColor: secondaryTextColor ?? const Color(0xFF95A1AC),
            backgroundColor: backgroundColor ?? const Color(0xFF14181B),
            primaryButtonBackgroundColor:
                primaryButtonBackgroundColor ?? const Color(0xFF4542e6),
            primaryButtonTextColor: primaryButtonTextColor ?? Colors.white,
            primaryButtonBorderColor:
                primaryButtonBorderColor ?? Colors.transparent,
            displayAsBottomSheet: displayAsBottomSheet,
          ),
        ],
      ),
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 394),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  return showDialog<Color?>(
    context: context,
    builder: (_) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        scrollable: true,
        content: FFColorPickerDialog(
          currentColor: currentColor,
          showRecentColors: showRecentColors,
          allowOpacity: allowOpacity,
          textColor: textColor ?? Colors.white,
          secondaryTextColor: secondaryTextColor ?? const Color(0xFF95A1AC),
          backgroundColor: backgroundColor ?? const Color(0xFF14181B),
          primaryButtonBackgroundColor:
              primaryButtonBackgroundColor ?? const Color(0xFF4542e6),
          primaryButtonTextColor: primaryButtonTextColor ?? Colors.white,
          primaryButtonBorderColor:
              primaryButtonBorderColor ?? Colors.transparent,
          displayAsBottomSheet: displayAsBottomSheet,
        ),
      ),
    ),
  );
}

class FFColorPickerDialog extends StatefulWidget {
  const FFColorPickerDialog({
    Key? key,
    this.currentColor,
    this.showRecentColors = false,
    this.allowOpacity = true,
    required this.displayAsBottomSheet,
    this.textColor = Colors.white,
    this.secondaryTextColor = const Color(0xFF95A1AC),
    this.backgroundColor = const Color(0xFF14181B),
    this.primaryButtonBackgroundColor = const Color(0xFF4542e6),
    this.primaryButtonTextColor = Colors.white,
    this.primaryButtonBorderColor = Colors.transparent,
  }) : super(key: key);

  final Color? currentColor;
  final bool showRecentColors;
  final bool allowOpacity;
  final bool displayAsBottomSheet;
  final Color textColor;
  final Color secondaryTextColor;
  final Color backgroundColor;
  final Color primaryButtonBackgroundColor;
  final Color primaryButtonTextColor;
  final Color primaryButtonBorderColor;

  @override
  _FFColorPickerDialogState createState() => _FFColorPickerDialogState();
}

class _FFColorPickerDialogState extends State<FFColorPickerDialog> {
  List<Color> recentColors = [];
  ColorLabelType? colorType = ColorLabelType.rgb;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.currentColor ?? Colors.black;
    if (widget.showRecentColors) {
      _initRecentColors();
    }
  }

  late SharedPreferences _prefs;
  Future _initRecentColors() async {
    _prefs = await SharedPreferences.getInstance();
    final strColors = _prefs.getStringList(_kRecentColorsKey) ?? [];
    if (strColors.isEmpty) {
      return;
    }
    setState(
      () => recentColors =
          strColors.map((c) => Color(int.parse(c, radix: 16))).toList(),
    );
  }

  void _addRecentColor(Color color) {
    final currentColors = _prefs.getStringList(_kRecentColorsKey) ?? [];
    final newColor = color.value.toInt().toRadixString(16);
    if (currentColors.contains(newColor)) {
      return;
    }
    _prefs.setStringList(_kRecentColorsKey, currentColors + [newColor]);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 394,
        color: widget.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Color',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: widget.textColor,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    Builder(
                      builder: (context) {
                        final currentHsvColor =
                            HSVColor.fromColor(selectedColor);

                        onColorChanged(val) =>
                            setState(() => selectedColor = val);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: SizedBox(
                                  width: 220,
                                  height: 136,
                                  child: ColorPickerArea(
                                    currentHsvColor,
                                    (val) => onColorChanged(val.toColor()),
                                    PaletteType.hsvWithHue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 11.0),
                              SizedBox(
                                height: 20.0,
                                child: ColorPickerSlider(
                                  TrackType.hue,
                                  currentHsvColor,
                                  (color) => onColorChanged(color.toColor()),
                                ),
                              ),
                              if (widget.allowOpacity) ...[
                                const SizedBox(height: 15.0),
                                SizedBox(
                                  height: 21.0,
                                  child: ColorPickerSlider(
                                    TrackType.alpha,
                                    currentHsvColor,
                                    (color) => onColorChanged(color.toColor()),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 24.0,
                                        child: DropdownButton<ColorLabelType>(
                                          value: colorType,
                                          dropdownColor: Colors.black,
                                          focusColor: Colors.transparent,
                                          underline: Container(),
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 18.0,
                                              color: widget.secondaryTextColor,
                                            ),
                                          ),
                                          items: _colorTypes.keys
                                              .map(
                                                (type) => DropdownMenuItem(
                                                  value: type,
                                                  child: Text(
                                                    type
                                                        .toString()
                                                        .split('.')
                                                        .last
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontFamily: 'Open Sans',
                                                      fontSize: 10,
                                                      color: widget
                                                          .secondaryTextColor,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (type) =>
                                              setState(() => colorType = type),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ColorPickerInput(
                                            currentHsvColor.toColor(),
                                            (color) => onColorChanged(color),
                                            showColor: true,
                                            style: TextStyle(
                                              color: widget.textColor,
                                              fontFamily: 'Open Sans',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12.0),
                                  ..._colorValueLabels(
                                    currentHsvColor,
                                    widget.allowOpacity,
                                    widget.textColor,
                                    widget.secondaryTextColor,
                                  ).map(
                                    (w) => Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: w,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    if (recentColors.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      Text(
                        "Recent Colors",
                        style: TextStyle(
                          color: widget.secondaryTextColor,
                          fontFamily: 'Open Sans',
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 7.0),
                      ...[
                        recentColors.reversed.take(7).toList(),
                        if (recentColors.length > 7) ...[
                          recentColors.reversed
                              .toList()
                              .sublist(7)
                              .take(7)
                              .toList()
                        ]
                      ]
                          .map<Widget>(
                            (recentColorsRow) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: recentColorsRow.map<Widget>((c) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => selectedColor = c),
                                    child: Container(
                                      width: 40.0,
                                      height: 34.0,
                                      decoration: BoxDecoration(
                                        color: c,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                          .toList(),
                    ],
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 40.0,
                          width: 96.0,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                widget.textColor,
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                widget.backgroundColor,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: widget.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          height: 40.0,
                          width: 84.0,
                          child: OutlinedButton(
                            onPressed: () {
                              if (widget.showRecentColors) {
                                _addRecentColor(selectedColor);
                              }
                              Navigator.of(context).pop(selectedColor);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: widget.primaryButtonBorderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                widget.primaryButtonTextColor,
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                widget.primaryButtonBackgroundColor,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                              ),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: widget.primaryButtonTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _colorValueLabels(
    HSVColor hsvColor,
    bool allowOpacity,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final colorTypes = allowOpacity
        ? _colorTypes[colorType!]
        : _colorTypes[colorType!]!.sublist(0, _alphaValueIndex);

    return colorTypes!
        .map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 24.0),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Text(
                      item,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 19.0),
                    Expanded(
                      child: Text(
                        _colorValue(hsvColor, colorType)[
                            _colorTypes[colorType!]!.indexOf(item)],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}

List<String> _colorValue(HSVColor hsvColor, ColorLabelType? colorLabelType) {
  switch (colorLabelType) {
    case ColorLabelType.rgb:
      final Color color = hsvColor.toColor();
      return [
        color.red.toString(),
        color.green.toString(),
        color.blue.toString(),
        '${(color.opacity * 100).round()}%',
      ];
    case ColorLabelType.hsv:
      return [
        '${hsvColor.hue.round()}°',
        '${(hsvColor.saturation * 100).round()}%',
        '${(hsvColor.value * 100).round()}%',
        '${(hsvColor.alpha * 100).round()}%',
      ];
    case ColorLabelType.hsl:
      HSLColor hslColor = hsvToHsl(hsvColor);
      return [
        '${hslColor.hue.round()}°',
        '${(hslColor.saturation * 100).round()}%',
        '${(hslColor.lightness * 100).round()}%',
        '${(hsvColor.alpha * 100).round()}%',
      ];
    default:
      return ['??', '??', '??', '??'];
  }
}
