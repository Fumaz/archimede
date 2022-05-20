import 'package:archimede/app/page/settings_page.dart';
import 'package:archimede/app/page/timetable_page.dart';
import 'package:archimede/app/settings.dart';
import 'package:flutter/cupertino.dart';

import '../util/utils.dart';

class ArchimedeApp extends StatelessWidget {
  const ArchimedeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Orario Archimede',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPink,
        textTheme: CupertinoTextThemeData(
          primaryColor: getTextColor(),
        ),
      ),
      home: getPage(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget getPage() {
    String section = get("section");
    String path = get("path");

    if (section == '' || path == '') {
      return const SettingsPage();
    }

    return const TimetablePage();
  }
}
