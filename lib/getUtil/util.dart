import 'dart:ui';

import 'package:flutter/cupertino.dart';

extension RoundWidget on double {
  int get myMethod {
    return (1 / this * 10).toInt();
  }
}

extension widgetExtension on Widget {
  ClipRRect roundCornerOnly({double radius = 0}) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: this);
  }
}
