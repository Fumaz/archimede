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
                  path = data[section][index - 1];
                });
              },
              backgroundColor: CupertinoColors.systemBackground,
              children: [
                const Text("Seleziona un orario", style: TextStyle(fontSize: 20)),
                for (var item in data[section])
                  Text(item, style: const TextStyle(fontSize: 20)),
              ],
            )));
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
          GestureDetector(
            child: Column(
              children: [
                const Icon(CupertinoIcons.person_solid,
                    size: 100, color: CupertinoColors.systemYellow),
                const Text('Alunno',
                    style: TextStyle(
                        fontSize: 25, color: CupertinoColors.systemYellow)),
                getTick(section == 'CLASSI', CupertinoColors.systemYellow),
              ],
            ),
            onTap: () {
              setSection('CLASSI');
            },
          ),
          const Padding(padding: const EdgeInsets.all(50)),
          GestureDetector(
            child: Column(
              children: [
                const Icon(CupertinoIcons.briefcase_fill,
                    size: 100, color: CupertinoColors.activeBlue),
                const Text('Docente',
                    style: TextStyle(
                        fontSize: 25, color: CupertinoColors.activeBlue)),
                getTick(section == 'DOCENTI', CupertinoColors.activeBlue),
              ],
            ),
            onTap: () {
              setSection('DOCENTI');
            },
          ),
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
