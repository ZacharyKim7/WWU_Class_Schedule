import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:class_open/classes/class.dart';
import 'package:class_open/classes/query.dart';
import 'package:class_open/classes/subject.dart';
import 'package:class_open/classes/term.dart';
import 'package:flutter/material.dart';
import 'package:class_open/classes/department.dart';

//import 'package:class_open/classes/get_html.dart';

//Department

void main() {
  //await fetchHtml();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WWU Class Schedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x00656950)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'WWU Class Open'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Department _department = Department.allDepartments();
  Subject _subject = Subject.allSubjects();
  Term _term = Term.allTerms();
  int _selectedIndex = 0;
  int lineHeight = 0;
  late GoogleMapController mapController;

  LatLng _center = const LatLng(45.521563, -122.677433);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 1250) {
            return wideLayout();
          } else if (constraints.maxWidth > 700) {
            return mediumLayout();
          } else if (constraints.maxWidth > 570) {
            return narrowLayout();
          } else {
            return Center(
              child: Text(
                'Screen width of ${constraints.maxWidth.round()} is less than the required minimum of 570 px!',
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final Location location = Location();
    final locationData = await location.getLocation();
    setState(() {
      _center = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  Widget map() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 18.0,
      ),
      markers: <Marker>{}..add(
          const Marker(
            markerId: MarkerId('campus'),
            position: LatLng(46.0461, -118.3902),
            infoWindow: InfoWindow(
              title: 'WWU Campus',
              snippet: 'This is where we have CPTR 241!',
            ),
          ),
        ),
      buildingsEnabled: false,
    );
  }

  Widget schedule() {
    final columns = <DataColumn>[];
    final columnNames = [' ', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    for (final each in columnNames) {
      columns.add(DataColumn(label: Text(each)));
    }

    final week = <List<List<Class>>>[];
    for (int i = 0; i <= 7; ++i) {
      final day = <List<Class>>[];
      for (int j = 0; j < 24; ++j) {
        final hour = <Class>[];
        day.add(hour);
      }
      week.add(day);
    }

    final classes = Class.instances.where((element) => element.saved);
    for (final aClass in classes) {
      final meetingTime = aClass.schedule;
      for (int day = 1; day < 7; ++day) {
        final periods = meetingTime.getPeriodsOnDay(day);
        for (final period in periods) {
          week[day][period.start.hour].add(aClass);
        }
      }
    }

    //build list of cells
    final rows = <DataRow>[];
    for (int hour = 7; hour < 19; ++hour) {
      final cells = <DataCell>[];
      cells.add(DataCell(Text('$hour:00')));
      for (int day = 1; day < 7; ++day) {
        final classes = <Text>[];
        for (final aClass in week[day][hour]) {
          classes.add(
            Text('${aClass.course.subject!.code} ${aClass.course.number}'),
          );
        }
        cells.add(DataCell(Column(
          children: classes,
        ),),);
      }
      rows.add(DataRow(cells: cells));
    }
    return DataTable(
      columns: columns,
      rows: rows,
    );
  }

  Widget wideBody() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            searchCriteria(),
            wideHeaderRow(),
            Expanded(child: wideResults()),
          ],
        );
      case 1:
        return Column(
          children: [
            wideHeaderRow(),
            Expanded(child: wideResults()),
          ],
        );
      case 2:
        return schedule();
      case 3:
        return map();
    }
    return const Placeholder();
  }

  Widget mediumLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      body: Column(
        children: [
          searchCriteria(),
          mediumHeaderRow(),
          Expanded(child: mediumResults()),
        ],
      ),
    );
  }

  Widget narrowLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      drawer: drawer(),
      body: narrowResults(),
    );
  }

  Widget wideLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      body: wideBody(),
      bottomNavigationBar: navBar(),
    );
  }

  NavigationBar navBar() {
    return NavigationBar(
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.list),
          label: 'Classes',
        ),
        NavigationDestination(
          icon: Icon(Icons.save),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_view_week),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
      ],
      selectedIndex: _selectedIndex,
      indicatorColor: Colors.amber[800],
      onDestinationSelected: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Container cell({
    required double width,
    required String text,
    Color background = const Color(0xFF336699),
    Color foreground = Colors.black,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      alignment: alignment,
      width: width,
      margin: const EdgeInsets.all(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      color: background,
      child: Text(
        text,
        style: TextStyle(color: foreground),
      ),
    );
  }

  Widget mediumHeaderRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(1.0),
          decoration: BoxDecoration(border: Border.all(width: 1.0)),
          child: Column(
            children: [
              Row(
                children: [
                  cell(
                    width: 57,
                    text: 'subj',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 62,
                    text: 'Sum 23',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 62,
                    text: 'Aut 23',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 62,
                    text: 'Wtr 24',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 62,
                    text: 'Spr 24',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 62,
                    text: 'Sum 24',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 37,
                    text: 'Sec',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 30,
                    text: 'GS',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 30,
                    text: 'Cr',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 155,
                    text: 'Meeting Time',
                    foreground: Colors.white,
                    alignment: Alignment.center,
                  ),
                ],
              ),
              Row(
                children: [
                  cell(
                    width: 309,
                    text: 'Course Title',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 200,
                    text: 'Instructor',
                    foreground: Colors.white,
                  ),
                  cell(
                    width: 117,
                    text: 'Campus',
                    foreground: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget wideHeaderRow() {
    return Row(
      children: [
        const SizedBox(width: 32.0),
        cell(
          width: 57,
          text: 'subj',
          foreground: Colors.white,
        ),
        cell(
          width: 62,
          text: 'Sum 23',
          foreground: Colors.white,
        ),
        cell(
          width: 62,
          text: 'Aut 23',
          foreground: Colors.white,
        ),
        cell(
          width: 62,
          text: 'Wtr 24',
          foreground: Colors.white,
        ),
        cell(
          width: 62,
          text: 'Spr 24',
          foreground: Colors.white,
        ),
        cell(
          width: 62,
          text: 'Sum 24',
          foreground: Colors.white,
        ),
        cell(
          width: 37,
          text: 'Sec',
          foreground: Colors.white,
        ),
        cell(
          width: 30,
          text: 'GS',
          foreground: Colors.white,
        ),
        cell(
          width: 30,
          text: 'Cr',
          foreground: Colors.white,
        ),
        cell(
          width: 300,
          text: 'Course Title',
          foreground: Colors.white,
        ),
        cell(
          width: 155,
          text: 'Meeting Time',
          foreground: Colors.white,
          alignment: Alignment.center,
        ),
        cell(
          width: 200,
          text: 'Instructor',
          foreground: Colors.white,
        ),
        cell(
          width: 67,
          text: 'Campus',
          foreground: Colors.white,
        ),
      ],
    );
  }

  Widget departmentDropdown() {
    final entries = <DropdownMenuEntry>[];

    for (final element in Department.instances) {
      entries.add(
        DropdownMenuEntry(
          value: element,
          label: element.toString(),
          labelWidget: Row(
            children: [
              SizedBox(width: 50.0, child: Text(element.code)),
              Text('- ${element.name}'),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownMenu(
        key: const Key('myDropdownMenu'),
        dropdownMenuEntries: entries,
        label: const Text('Department'),
        onSelected: (value) {
          setState(() {
            _department = value;
          });
        },
      ),
    );
  }

  Widget subjectDropdown() {
    final entries = <DropdownMenuEntry>[];
    for (final element in Subject.instances) {
      entries.add(
        DropdownMenuEntry(
          value: element,
          label: element.name,
          labelWidget: Row(
            children: [
              SizedBox(width: 50.0, child: Text(element.code)),
              Text('- ${element.name}'),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownMenu(
        key: const Key('SubjectDropdownMenu'),
        dropdownMenuEntries: entries,
        label: const Text('Subject'),
        onSelected: (value) {
          setState(() {
            _subject = value;
          });
        },
      ),
    );
  }

  Widget termDropdown() {
    final entries = <DropdownMenuEntry>[];
    for (final element in Term.instances) {
      entries.add(DropdownMenuEntry(value: element, label: element.name));
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownMenu(
        key: const Key('TermDropdownMenu'),
        dropdownMenuEntries: entries,
        label: const Text('Term'),
        onSelected: (value) {
          setState(() {
            _term = value;
          });
        },
      ),
    );
  }

  Widget drawer() {
    return SizedBox(
      width: 380,
      child: NavigationDrawer(
        children: [
          // const DrawerHeader(
          //   child: Placeholder(),
          // ),
          departmentDropdown(),
          subjectDropdown(),
          termDropdown(),
          const AboutListTile(
            applicationIcon: Icon(Icons.calendar_month),
            applicationName: 'WWU Class Schedule',
            applicationVersion: '0.1',
          ),
        ],
      ),
    );
  }

  Widget searchCriteria() {
    return ColoredBox(
      color: const Color(0xFFA0AD9F),
      child: Wrap(
        children: [
          departmentDropdown(),
          subjectDropdown(),
          termDropdown(),
        ],
      ),
    );
  }

  String addLinesTo(String aString, int lineHeight) {
    final initialCount = aString.split('\n').length;
    var result = aString;
    for (int i = initialCount; i < lineHeight; ++i) {
      result += '\n';
    }
    final x = result.split('\n');
    final y = x.map((each) => each.trim());
    result = y.join('\n');
    return result.isNotEmpty ? result : ' ';
  }

  Widget narrowClassRow(Class aClass, bool isEven) {
    final background =
        isEven ? const Color(0xFFC2C2C2) : const Color(0xFFDBDBDB);
    final lineHeight = aClass.schedule.toString().split('\n').length;
    return Row(
      children: [
        Tooltip(
          message: '${aClass.course.subject!.code} ${aClass.course.number}'
              ' ${aClass.section}'
              ' ${aClass.course.isGeneralStudies ? '(GS)' : ''}'
              ' - ${aClass.term.name} - ${aClass.course.credits}'
              ' - ${aClass.instructors.join(', ')}'
              ' - ${aClass.campus.name}',
          child: Row(
            children: [
              cell(
                width: 55,
                text: addLinesTo(
                  aClass.course.subject!.code,
                  lineHeight,
                ),
                background: background,
                foreground: Colors.black,
              ),
              if (aClass.term.code == 2236)
                cell(
                  width: 55,
                  text: addLinesTo(
                    aClass.course.number,
                    lineHeight,
                  ),
                  background: isEven
                      ? const Color(0xFFFEFFA4)
                      : const Color(0xFFF1F276),
                  foreground: Colors.black,
                ),
              if (aClass.term.code == 2239)
                cell(
                  width: 55,
                  text: addLinesTo(
                    aClass.course.number,
                    lineHeight,
                  ),
                  background: isEven
                      ? const Color(0xFFFFD34D)
                      : const Color(0xFFF2B600),
                  foreground: Colors.black,
                ),
              if (aClass.term.code == 2241)
                cell(
                  width: 55,
                  text: addLinesTo(
                    aClass.course.number,
                    lineHeight,
                  ),
                  background: isEven
                      ? const Color(0xFFB4C4D8)
                      : const Color(0xFF8CA2BD),
                  foreground: Colors.black,
                ),
              if (aClass.term.code == 2243)
                cell(
                  width: 55,
                  text: addLinesTo(
                    aClass.course.number,
                    lineHeight,
                  ),
                  background: isEven
                      ? const Color(0xFF8AD2A1)
                      : const Color(0xFF53B573),
                  foreground: Colors.black,
                ),
              if (aClass.term.code == 2246)
                cell(
                  width: 55,
                  text: addLinesTo(
                    aClass.course.number,
                    lineHeight,
                  ),
                  background: isEven
                      ? const Color(0xFFFEFFA4)
                      : const Color(0xFFF1F276),
                  foreground: Colors.black,
                ),
              cell(
                width: 300,
                text: addLinesTo(aClass.course.title, lineHeight),
                background: background,
                foreground: Colors.black,
                alignment: Alignment.centerLeft,
              ),
              cell(
                width: 155,
                text: addLinesTo(aClass.schedule.toString(), lineHeight),
                background: background,
                foreground: Colors.black,
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  List<Class> queryAndSort() {
    final classes = _selectedIndex == 0
        ? Query(
            department: _department,
            subject: _subject,
            term: _term,
          ).results().toList()
        : Class.instances.where((element) => element.saved).toList();
    classes.sort((a, b) {
      return a.compareTo(b);
    });
    return classes;
  }

  Widget mediumClassRow(Class aClass, bool isEven) {
    final background =
        isEven ? const Color(0xFFbcc4bf) : const Color(0xFFb9b5b5);
    lineHeight = max(
      aClass.schedule.toString().split('\n').length,
      aClass.instructors.length,
    );
    //final addedLines = lineHeight == 1 ? '' : '\n';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(1.0),
          decoration: BoxDecoration(border: Border.all(width: 1.0)),
          child: Column(
            children: [
              Row(
                children: [
                  cell(
                    width: 57,
                    text: addLinesTo(aClass.course.subject!.code, lineHeight),
                    background: background,
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 62,
                    text: addLinesTo(
                      aClass.term.code == 2236 ? aClass.course.number : ' ',
                      lineHeight,
                    ),
                    background: isEven
                        ? const Color(0xFFFEFFA4)
                        : const Color(0xFFF1F276),
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 62,
                    text: addLinesTo(
                      aClass.term.code == 2239 ? aClass.course.number : ' ',
                      lineHeight,
                    ),
                    background: isEven
                        ? const Color(0xFFFFD34D)
                        : const Color(0xFFF2B600),
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 62,
                    text: addLinesTo(
                      aClass.term.code == 2241 ? aClass.course.number : ' ',
                      lineHeight,
                    ),
                    background: isEven
                        ? const Color(0xFFB4C4D8)
                        : const Color(0xFF8CA2BD),
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 62,
                    text: addLinesTo(
                      aClass.term.code == 2243 ? aClass.course.number : ' ',
                      lineHeight,
                    ),
                    background: isEven
                        ? const Color(0xFF8AD2A1)
                        : const Color(0xFF53B573),
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 62,
                    text: addLinesTo(
                      aClass.term.code == 2246 ? aClass.course.number : ' ',
                      lineHeight,
                    ),
                    background: isEven
                        ? const Color(0xFFFEFFA4)
                        : const Color(0xFFF1F276),
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 37,
                    text: addLinesTo(aClass.section, lineHeight),
                    background: background,
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 30,
                    text: addLinesTo(
                      aClass.course.isGeneralStudies ? 'GS' : '  ',
                      lineHeight,
                    ),
                    background: background,
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 30,
                    text: addLinesTo(
                      aClass.course.credits.toString(),
                      lineHeight,
                    ),
                    background: background,
                    foreground: Colors.black,
                  ),
                  cell(
                    width: 155,
                    text: addLinesTo(aClass.schedule.toString(), lineHeight),
                    background: background,
                    foreground: Colors.black,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
              Row(
                children: [
                  cell(
                    width: 309,
                    text: addLinesTo(aClass.course.title, lineHeight),
                    background: background,
                    foreground: Colors.black,
                    alignment: Alignment.centerLeft,
                  ),
                  cell(
                    width: 200,
                    text: addLinesTo(aClass.instructors.join('\n'), lineHeight),
                    background: background,
                    foreground: Colors.black,
                    alignment: Alignment.centerLeft,
                  ),
                  cell(
                    width: 117,
                    text: addLinesTo(aClass.campus.code, lineHeight),
                    background: background,
                    foreground: Colors.black,
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ],
          ),
        ),
        //Expanded(child: Container()),
      ],
    );
  }

  Widget wideClassRow(Class aClass, bool isEven) {
    final background =
        isEven ? const Color(0xFFbcc4bf) : const Color(0xFFb9b5b5);
    lineHeight = max(
      aClass.schedule.toString().split('\n').length,
      aClass.instructors.length,
    );
    //final addedLines = lineHeight == 1 ? '' : '\n';
    return Row(
      children: [
        SizedBox(
          height: 22.0,
          //width: 22.0,
          child: Checkbox(
            value: aClass.saved,
            onChanged: (newValue) {
              setState(() {
                aClass.saved = newValue!;
              });
            },
          ),
        ),
        cell(
          width: 57,
          text: addLinesTo(aClass.course.subject!.code, lineHeight),
          background: background,
          foreground: Colors.black,
        ),
        cell(
          width: 62,
          text: addLinesTo(
            aClass.term.code == 2236 ? aClass.course.number : ' ',
            lineHeight,
          ),
          //aClass.term.name == 'Summer 2023' ? aClass.course.number : '',
          background:
              isEven ? const Color(0xFFFEFFA4) : const Color(0xFFF1F276),
          foreground: Colors.black,
        ),
        cell(
          width: 62,
          text: addLinesTo(
            aClass.term.code == 2239 ? aClass.course.number : ' ',
            lineHeight,
          ),
          background:
              isEven ? const Color(0xFFFFD34D) : const Color(0xFFF2B600),
          foreground: Colors.black,
        ),
        cell(
          width: 62,
          text: addLinesTo(
            aClass.term.code == 2241 ? aClass.course.number : ' ',
            lineHeight,
          ),
          background:
              isEven ? const Color(0xFFB4C4D8) : const Color(0xFF8CA2BD),
          foreground: Colors.black,
        ),
        cell(
          width: 62,
          text: addLinesTo(
            aClass.term.code == 2243 ? aClass.course.number : ' ',
            lineHeight,
          ),
          background:
              isEven ? const Color(0xFF8AD2A1) : const Color(0xFF53B573),
          foreground: Colors.black,
        ),
        cell(
          width: 62,
          text: addLinesTo(
            aClass.term.code == 2246 ? aClass.course.number : ' ',
            lineHeight,
          ),
          background:
              isEven ? const Color(0xFFFEFFA4) : const Color(0xFFF1F276),
          foreground: Colors.black,
        ),
        cell(
          width: 37,
          text: addLinesTo(aClass.section, lineHeight),
          background: background,
          foreground: Colors.black,
        ),
        cell(
          width: 30,
          text: addLinesTo(
            aClass.course.isGeneralStudies ? 'GS' : '  ',
            lineHeight,
          ),
          background: background,
          foreground: Colors.black,
        ),
        cell(
          width: 30,
          text: addLinesTo(aClass.course.credits.toString(), lineHeight),
          background: background,
          foreground: Colors.black,
        ),
        cell(
          width: 300,
          text: addLinesTo(aClass.course.title, lineHeight),
          background: background,
          foreground: Colors.black,
          alignment: Alignment.centerLeft,
        ),
        cell(
          width: 155,
          text: addLinesTo(aClass.schedule.toString(), lineHeight),
          background: background,
          foreground: Colors.black,
          alignment: Alignment.centerRight,
        ),
        cell(
          width: 200,
          text: addLinesTo(aClass.instructors.join('\n'), lineHeight),
          background: background,
          foreground: Colors.black,
          alignment: Alignment.centerLeft,
        ),
        cell(
          width: 67,
          text: addLinesTo(aClass.campus.code, lineHeight),
          background: background,
          foreground: Colors.black,
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Widget wideResults() {
    final classes = queryAndSort();
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return wideClassRow(classes[index], index % 2 == 0);
      },
    );
  }

  Widget mediumResults() {
    final classes = queryAndSort();
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) =>
          mediumClassRow(classes[index], index % 2 == 0),
    );
  }

  Widget narrowResults() {
    final classes = queryAndSort();
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) =>
          narrowClassRow(classes[index], index % 2 == 0),
    );
  }
}
