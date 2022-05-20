import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

double version = 1.243;

Color getTextColor() {
  return isDarkMode() ? CupertinoColors.white : CupertinoColors.black;
}

bool isDarkMode() {
  return SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
}
