import 'package:archimede/api/api.dart';
import 'package:archimede/app/app.dart';
import 'package:archimede/app/page/settings_page.dart';
import 'package:archimede/app/page/timetable_page.dart';
import 'package:archimede/app/settings.dart' as settings;
import 'package:flutter/cupertino.dart';

import '../../util/utils.dart';

class SettingsState extends State<SettingsPage> {
  Map<String, dynamic> summary = {};

  String section = "";
  String path = "";
  int? selectedClass;

  @override
  void initState() {
    super.initState();

    get("/summary").then((response) {
      setState(() {
        summary = response;
      });
    });
  }

  void setSection(String section) {
    if (section != this.section) {
      setState(() {
        this.section = section;
        // reset the path since it's not longer valid
        path = "";
        selectedClass = null;
      });
    }
  }

  void confirm(BuildContext context) async {
    if (section == "" || path == "") {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text("Devi prima selezionare l'orario!"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return;
    }

    await settings.set("section", section);
    await settings.set("path", path);

    Navigator.pushReplacement(context,
        CupertinoPageRoute(builder: (context) => const TimetablePage()));
  }

  void showPathDialog() {
    if (section == "") {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text("Devi prima selezionare la categoria!"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return;
    }

    var options = summary[section];
    if (section == 'CLASSI' && selectedClass != null) {
      // filter the options by class
      options = options
          .where((x) => x.startsWith(selectedClass.toString()) ? true : false)
          .toList();
    }

    showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
            height: 350,
            child: GestureDetector(
              onTapUp: (details) {
                Navigator.pop(context);
              },
              child: CupertinoPicker(
                itemExtent: 30,
                onSelectedItemChanged: (index) {
                  setState(() {
                    path = options[index];
                  });
                },
                backgroundColor: CupertinoColors.systemBackground,
                children: [
                  for (var item in options)
                    Text(item, style: const TextStyle(fontSize: 25))
                ],
              ),
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
            ],
          ),
        ),
        onTap: () {
          setSection(code);
        });
  }

  Widget classFilter() {
    return Column(children: [
      Text("Filtra per anno", style: TextStyle(fontSize: 25, color: getTextColor())),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var classNum in [1, 2, 3, 4, 5])
            CupertinoButton(
                child: Text(classNum.toString(),
                    style: TextStyle(
                        color:
                            selectedClass == classNum ? null : getTextColor(),
                        fontSize: 25,
                        fontWeight: selectedClass == classNum
                            ? FontWeight.bold
                            : FontWeight.normal)),
                onPressed: () {
                  if (selectedClass != classNum) {
                    setState(() => {selectedClass = classNum, path = ""});
                  }
                  showPathDialog();
                })
        ],
      )
    ]);
  }

  Widget createPage() {
    if (summary.isEmpty) {
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
      SizedBox(
        height: 90,
        child: section == 'CLASSI'
            ? classFilter()
            : const Padding(padding: EdgeInsets.all(35)),
      ),
      const Padding(padding: EdgeInsets.all(10)),
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
      const Padding(padding: EdgeInsets.all(35)),
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
