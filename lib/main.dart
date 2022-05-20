import 'package:archimede/app/app.dart';
import 'package:flutter/cupertino.dart';

import 'app/settings.dart' as settings;

void main() {
  settings.setup().then((value) => runApp(const ArchimedeApp()));
}
