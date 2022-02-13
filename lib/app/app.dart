import 'dart:io';

import 'package:archimede/app/page/settings_page.dart';
import 'package:archimede/app/page/timetable_page.dart';
import 'package:archimede/app/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class ArchimedeApp extends StatelessWidget {

  const ArchimedeApp({Key? key}) : super(key: key);

  Widget getPage() {
    String section = get("section");
    String path = get("path");

    if (section == '' || path == '') {
      return SettingsPage();
    } else {
      return TimetablePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPink,
        textTheme: CupertinoTextThemeData(
          primaryColor: getTextColor(),
          textStyle: const TextStyle(
            fontFamilyFallback: ['Helvetica Neue', 'Helvetica', 'Arial', 'sans-serif'],
          ),
        ),
      ),
      home: getPage(),
      debugShowCheckedModeBanner: false,
    );
  }

}

double version = 1.243;

Color getTextColor() {
  return isDarkMode() ? CupertinoColors.white : CupertinoColors.black;
}

bool isDarkMode() {
  return SchedulerBinding.instance!.window.platformBrightness ==
      Brightness.dark;
}