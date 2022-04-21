import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../library.dart';

const _kTabViewRadius = BorderRadius.all(Radius.circular(7.0));
const _kContentBackgroundColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromRGBO(230, 230, 230, 1.0),
  darkColor: Color.fromRGBO(36, 38, 40, 1.0),
);

enum TabPosition { left, right, top, bottom }

class TabView extends StatelessWidget {
  const TabView({
    Key? key,
    required this.tabs,
    required this.body,
    this.position = TabPosition.top,
    this.width,
    this.height,
    this.constraints,
  })  : assert(tabs.length > 0),
        // assert(width != null ? width >= 0 : true),
        // assert(height != null ? height >= 0 : true),
        super(key: key);

  /// Specifies the tabs to display at any given edge of the tab view content
  final List<Widget> tabs;

  /// Specifies the position of where to place tab view controls
  ///
  /// Defaults to [TabPosition.top]
  final TabPosition position;

  /// Content displayed inside of the tab view
  final Widget body;

  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  int get _tabRotation {
    switch (position) {
      case TabPosition.left:
        return 3;
      case TabPosition.right:
        return 1;
      case TabPosition.top:
        return 0;
      case TabPosition.bottom:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMacosTheme(context));
    final brightness = MacosTheme.brightnessOf(context);

    final outerBorderColor = brightness.resolve(
      Colors.black.withOpacity(0.23),
      Colors.black.withOpacity(0.76),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          constraints: constraints,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _kContentBackgroundColor,
            border: Border.all(color: outerBorderColor, width: 1),
            borderRadius: _kTabViewRadius,
          ),
          child: body,
        ),
        Positioned(
          top: position == TabPosition.top ? 0 : null,
          bottom: position == TabPosition.bottom ? 0 : null,
          left: position == TabPosition.left ? 0 : null,
          right: position == TabPosition.right ? 0 : null,
          child: RotatedBox(
            quarterTurns: _tabRotation,
            child: ClipRRect(
              borderRadius: _kTabViewRadius,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MacosColors.systemGrayColor),
                ),
                child: Row(children: tabs),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
