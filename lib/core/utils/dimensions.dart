// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/widgets.dart'
    show
        BuildContext,
        MediaQuery,
        MediaQueryData,
        EdgeInsets,
        RenderBox,
        Offset;
// import 'package:tellerpay/models/enums/screen_type.dart';

class _TpDimension {
  MediaQueryData? _queryData;

  _TpDimension(BuildContext context) {
    _queryData = MediaQuery.of(context);
  }

  // ScreenType get screenType {
  //   if (_queryData.size.width > 500) return ScreenType.TABLET;
  //   return ScreenType.MOBILE;
  // }

  double get topInset {
    return _queryData!.padding.top;
  }

  double get width {
    return _queryData!.size.shortestSide;
  }

  double get height {
    return _queryData!.size.longestSide;
  }

  double setHeight(double percentage) {
    if (percentage == 0) {
      return 0;
    }
    return height * (percentage / 100);
  }

  double setWidth(double percentage) {
    if (percentage == 0) {
      return 0;
    }
    return width * (percentage / 100);
  }
}

class _TpFontSizer {
  num? _scale;

  _TpFontSizer(BuildContext context) {
    _scale = (MediaQuery.of(context).size.longestSide +
            MediaQuery.of(context).size.shortestSide) /
        4;
  }

  double sp(double? percentage) {
    return (_scale! * ((percentage ?? 35) / (1000 - 50))).toDouble();
  }
}

class SizeConfig {
  factory SizeConfig() {
    return _instance!;
  }
  SizeConfig._();

  static SizeConfig? _instance;

  static _TpFontSizer? fontSizer;
  static _TpDimension? sizer;

  static void init(BuildContext context) {
    _instance ??= SizeConfig._();
    fontSizer = _TpFontSizer(context);
    sizer = _TpDimension(context);
  }

  double sp(double percentage) {
    return fontSizer!.sp(percentage * 2.9);
  }

  double sh(double percentage) {
    return sizer!.setHeight(percentage / 8);
  }

  double sw(double percentage) {
    return sizer!.setWidth(percentage / 4);
  }
}

class _TpInsets {
  _TpDimension? sizer;

  _TpInsets(BuildContext context) {
    sizer = _TpDimension(context);
  }

  EdgeInsets get zero {
    return EdgeInsets.zero;
  }

  EdgeInsets all(double inset) {
    return EdgeInsets.all(sizer!.setWidth(inset));
  }

  EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      top: sizer!.setHeight(top),
      left: sizer!.setWidth(left),
      bottom: sizer!.setHeight(bottom),
      right: sizer!.setWidth(right),
    );
  }

  EdgeInsets fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(
      sizer!.setWidth(left),
      sizer!.setHeight(top),
      sizer!.setWidth(right),
      sizer!.setHeight(bottom),
    );
  }

  EdgeInsets symmetric({
    double vertical = 0,
    double horizontal = 0,
  }) {
    return EdgeInsets.symmetric(
      vertical: sizer!.setHeight(vertical),
      horizontal: sizer!.setWidth(horizontal),
    );
  }
}

class TpScaleUtil {
  final BuildContext context;

  TpScaleUtil(this.context);

  _TpDimension get sizer => _TpDimension(context);
  _TpFontSizer get fontSizer => _TpFontSizer(context);
  _TpInsets get insets => _TpInsets(context);
}

Offset getPos(BuildContext context) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset.zero);
}