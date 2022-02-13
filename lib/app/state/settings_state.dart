import 'package:archimede/api/api.dart';
import 'package:archimede/app/app.dart';
import 'package:archimede/app/page/settings_page.dart';
import 'package:archimede/app/page/timetable_page.dart';
import 'package:archimede/app/settings.dart' as settings;
import 'package:flutter/cupertino.dart';

class SettingsState extends State<SettingsPage> {
  Map<String, dynamic> data = {};

  String section = "";
  String path = "";

  @override
  void initState() {
    super.initState();

    get("/summary").then((response) {
      setState(() {
        data = response;
      });
    });
  }

  void setSection(String section) {
    setState(() {
      this.section = section;
    });
  }

  Widget getTick(bool condition, Color color) {
    return Icon(
      condition
          ? CupertinoIcons.check_mark_circled_solid
          : CupertinoIcons.check_mark_circled,
      color: color,
      size: 35,
    );
  }

  void confirm(BuildContext context) async {
    if (section == "" || path == "") {
      return;
    }

    await settings.set("section", section);
    await settings.set("path", path);

    Navigator.pushReplacement(context,
        CupertinoPageRoute(builder: (context) => const TimetablePage()));
  }

  void showPathDialog() {
    if (section == "") {
      return;
    }

    showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 30,
              onSelectedItemChanged: (index) {
                setState(() {
                  path = data[section][index];
                });
              },
              backgroundColor: CupertinoColors.systemBackground,
              children: [
                for (var item in data[section])
                  Text(item, style: const TextStyle(fontSize: 20)),
              ],
            )));
  }

  Widget sectionSelector(String code, String name, IconData icon, Color color) {
    return GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border: Border.all(
                  width: 2.0,
                  color: color.withAlpha(section == code ? 255 : 0)),
              borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            children: [
              Icon(icon, size: 100, color: color),
              Text(name, style: TextStyle(fontSize: 25, color: color)),
              getTick(section == code, color),
            ],
          ),
        ),
        onTap: () {
          setSection(code);
        });
  }

  Widget createPage() {
    if (data.isEmpty) {
      return const CupertinoActivityIndicator();
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Chi sta usando quest'app?",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: getTextColor())),
      const Padding(padding: EdgeInsets.all(20)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          sectionSelector('CLASSI', 'Alunno', CupertinoIcons.person_solid,
              CupertinoColors.systemYellow),
          const Padding(padding: EdgeInsets.all(50)),
          sectionSelector('DOCENTI', 'Docente', CupertinoIcons.briefcase_fill,
              CupertinoColors.activeBlue),
        ],
      ),
      const Padding(padding: EdgeInsets.all(25)),
      GestureDetector(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(path == '' ? "Tap per selezionare" : path,
              style: TextStyle(fontSize: 25, color: getTextColor())),
          Icon(CupertinoIcons.chevron_down, size: 25, color: getTextColor()),
        ]),
        onTap: () {
          showPathDialog();
        },
      ),
      Padding(padding: EdgeInsets.all(35)),
      CupertinoButton.filled(
        child: const Text("CONFERMA", style: TextStyle(fontSize: 25)),
        onPressed: () {
          confirm(context);
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: createPage());
  }
}
