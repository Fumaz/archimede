import 'dart:math';

import 'package:archimede/api/api.dart' as api;
import 'package:archimede/app/app.dart';
import 'package:archimede/app/page/timetable_page.dart';
import 'package:archimede/app/settings.dart' as settings;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../page/settings_page.dart';

class TimetableState extends State<TimetablePage> {
  List<String> days = ["L", "M", "M", "G", "V", "S"];
  List<String> schoolDays = ["LUN", "MAR", "MER", "GIO", "VEN", "SAB"];

  int _selectedDayIndex = 0;
  String section = "";
  String path = "";
  Map<String, dynamic> data = {};

  void loadData() async {
    section = settings.get("section");
    path = settings.get("path");

    data = await api.get("/$section/$path");
    setState(() {});
  }

  @override
  initState() {
    super.initState();

    int weekday = DateTime.now().weekday;

    if (weekday > days.length) {
      _selectedDayIndex = 0;
    } else {
      _selectedDayIndex = weekday - 1;
    }

    loadData();
  }

  Widget createDayButton(int index) {
    bool first = index == 0;
    bool selected = index == _selectedDayIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedDayIndex = index),
      child: Container(
        padding:
            EdgeInsets.only(top: 0, bottom: 0, right: 20, left: first ? 0 : 20),
        child: Text(days[index],
            style: TextStyle(
              color: selected ? CupertinoColors.systemPink : getTextColor(),
            )),
      ),
    );
  }

  String getRoomFromLesson(Map<String, dynamic>? lesson) {
    String actualRoom = lesson?['room'] ?? "No room";

    if (!actualRoom.startsWith("Aula")) {
      if (actualRoom.contains("Aula")) {
        actualRoom = actualRoom.lastIndexOf("Aula") == -1
            ? "Aula ?"
            : actualRoom.substring(actualRoom.lastIndexOf("Aula"));
      }
    }

    return actualRoom;
  }

  // TODO Merge hours with the same subject and teacher
  Widget createCardClass(String time, Map<String, dynamic>? lesson, int hours) {
    int? hashCode = (lesson?['subject'].hashCode ?? 0) ^ 35;
    Random random = Random(hashCode);
    HSLColor color = HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.75);
    String actualRoom = getRoomFromLesson(lesson);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color.toColor(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson?['subject'] ?? "No subject",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                for (String teacher in lesson?['teachers'] ?? [])
                  Text(teacher,
                      style: const TextStyle(
                        fontSize: 15,
                      )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time,
                    style: const TextStyle(
                      fontSize: 17,
                    )),
                Text(actualRoom,
                    style: const TextStyle(
                      fontSize: 17,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget createCardTeacher(String time, Map<String, dynamic>? lesson) {
    int? hashCode = (lesson?['subject'].hashCode ?? 0) ^ 35;
    Random random = Random(hashCode);
    HSLColor color = HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.75);

    String actualRoom = getRoomFromLesson(lesson);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color.toColor(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson?['class'] ?? "No class",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Text(lesson?['subject'] ?? "No subject",
                    style: const TextStyle(
                      fontSize: 15,
                    )),
                for (String teacher in lesson?['teachers'] ?? [])
                  Text(teacher,
                      style: const TextStyle(
                        fontSize: 15,
                      )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time,
                    style: const TextStyle(
                      fontSize: 17,
                    )),
                Text(actualRoom,
                    style: const TextStyle(
                      fontSize: 17,
                    )),
              ],
            ),
          ],
        ),
      )
    );
  }

  Widget createSliverList() {
    if (data.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    Map<String, dynamic> lessons = data[schoolDays[_selectedDayIndex]];

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          for (String time in lessons.keys)
            if (lessons[time] != null)
              if (section == "DOCENTI")
                createCardTeacher(time, lessons[time])
              else
                createCardClass(time, lessons[time], 1)
        ],
      ),
    );
  }

  void showAuthor() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("About Me"),
        content: Text("Made with <3 by Fumaz\nv$version"),
        actions: [
          CupertinoDialogAction(
            child: Text("Thanks!"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(slivers: [
        CupertinoSliverNavigationBar(
          leading: GestureDetector(
            child: const Icon(
              CupertinoIcons.gear,
              size: 25,
            ),
            onTap: () {
              Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
          trailing: GestureDetector(
            child: const Icon(
              CupertinoIcons.info,
              size: 25,
            ),
            onTap: () {
              showAuthor();
            },
          ),
          largeTitle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < days.length; i++) createDayButton(i)
            ],
          ),
        ),
        createSliverList()
      ]),
    );
  }
}
