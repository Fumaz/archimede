import 'dart:math';

import 'package:archimede/api/api.dart' as api;
import 'package:archimede/app/app.dart';
import 'package:archimede/app/page/timetable_page.dart';
import 'package:archimede/app/settings.dart' as settings;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../util/utils.dart';
import '../page/settings_page.dart';

class TimetableState extends State<TimetablePage> {
  List<String> days = ["L", "M", "M", "G", "V", "S"];
  List<String> schoolDays = ["LUN", "MAR", "MER", "GIO", "VEN", "SAB"];

  int _selectedDayIndex = 0;
  String section = "";
  String path = "";
  Map<String, dynamic> data = {};

  PageController controller = PageController(initialPage: 0);

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
    _selectedDayIndex = weekday > days.length ? 0 : weekday - 1;

    loadData();
  }

  Widget createDayButton(int index) {
    bool first = index == 0;
    bool selected = index == _selectedDayIndex;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedDayIndex = index;
        controller.animateToPage(_selectedDayIndex, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }),
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
  Widget createCardClass(
      String time, Map<String, dynamic>? lesson, int hours, bool currentDay) {
    String actualRoom = getRoomFromLesson(lesson);
    Color color = getColorBy(lesson?['subject']);
    bool current =
        DateTime.now().hour == int.parse(time.split(':')[0]) && currentDay;

    return createCard([
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
    ], color, selected: current);
  }

  Widget createCardTeacher(
      String time, Map<String, dynamic>? lesson, bool selectedDay) {
    bool current =
        DateTime.now().hour == int.parse(time.split(':')[0]) && selectedDay;
    Color color = getColorBy(lesson?['class']);

    String actualRoom = getRoomFromLesson(lesson);
    String actualClass = lesson?['class'] ?? lesson?['subject'] ?? "No subject";
    String actualSubject = (actualClass != lesson?['subject'])
        ? (lesson?['subject'] ?? "No class")
        : (lesson?['class'] ?? "No class");

    return createCard([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(actualClass,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          Text(actualSubject,
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
    ], color, selected: current);
  }

  Widget createCardAvailable(String time, bool selectedDay) {
    Color color = getColorBy(null);
    bool current =
        DateTime.now().hour == int.parse(time.split(':')[0]) && selectedDay;

    return createCard([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Ora libera',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          Text('Niente da fare!',
              style: TextStyle(
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
        ],
      ),
    ], color, selected: current);
  }

  Widget createFreeCard() {
    return createCard([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Nessuna lezione!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          Text('Goditi il giorno libero!',
              style: TextStyle(
                fontSize: 15,
              )),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          Text("Tutto il giorno",
              style: TextStyle(
                fontSize: 17,
              )),
        ],
      ),
    ], Colors.red);
  }

  Widget createSliverList(int selectedDay) {
    if (data.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CupertinoActivityIndicator(),
              Text("Loading...")
            ],
          ),
        ),
      );
    }

    Map<String, dynamic> lessons = data[schoolDays[selectedDay]];
    List<Widget> cards = [];

    int first = 0;
    int last = 0;

    for (int key = 0; key < lessons.keys.length; key++) {
      String time = lessons.keys.elementAt(key);
      bool available = lessons[time] != null;

      if (available) {
        if (first == 0 || first > key) {
          first = key;
        }

        if (last == 0 || last < key) {
          last = key;
        }
      }
    }

    for (int key = 0; key < lessons.keys.length; key++) {
      String time = lessons.keys.elementAt(key);
      dynamic data = lessons[time];

      time = time.replaceAll('.', ':');

      if (data != null) {
        if (section == "DOCENTI") {
          cards.add(createCardTeacher(
              time, data, selectedDay == DateTime.now().weekday - 1));
        } else {
          cards.add(createCardClass(
              time, data, 1, selectedDay == DateTime.now().weekday - 1));
        }
        continue;
      }

      if (key >= first && key <= last) {
        cards.add(createCardAvailable(
            time, selectedDay == DateTime.now().weekday - 1));
      }
    }

    if (cards.isEmpty) {
      cards.add(createFreeCard());
    }

    return SliverList(
      delegate: SliverChildListDelegate(cards),
    );
  }

  void showAuthor() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("About Me"),
        content: Text(
            "Made with <3 by Alessandro Fumagalli\nYou are running v$version"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Thanks!"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget buildPageView(BuildContext context) {
    if (controller.hasClients) {
      controller.jumpToPage(_selectedDayIndex);
    }

    return PageView.builder(
      controller: controller,
      itemCount: schoolDays.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: CustomScrollView(slivers: [createSliverList(index)]),
        );
      },
      onPageChanged: (index) {
        setState(() {
          _selectedDayIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
          headerSliverBuilder: (context, __) => [
                CupertinoSliverNavigationBar(
                  leading: GestureDetector(
                    child: const Icon(
                      CupertinoIcons.gear,
                      size: 25,
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const SettingsPage()));
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
                  middle: Text(path),
                ),
              ],
          body: Center(
              child: SizedBox(width: 500, child: buildPageView(context)))),
    );
  }

  Widget createCard(List<Widget> children, Color color,
      {bool selected = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: selected ? CupertinoColors.systemPink : null,
      ),
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: color,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          )),
    );
  }

  Color getColorBy(Object? object) {
    int? hashCode = (object?.hashCode ?? 0) ^ 35;
    Random random = Random(hashCode);
    HSLColor color = HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.75);

    return color.toColor();
  }
}
