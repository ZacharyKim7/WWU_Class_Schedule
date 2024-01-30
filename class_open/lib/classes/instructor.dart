import 'package:class_open/classes/load_csv.dart';

class Instructor {
  Instructor(this.name);
  final String name;

  static final _instances = <Instructor>{};

  static Set<Instructor> get instances {
    if (_instances.isEmpty) {
      Instructor._initialize();
    }
    return _instances;
  }

  static void _initialize() {
    final classopenCSV = getListFromCsv();
    final names = <String>{};
    // Remove headers
    classopenCSV.removeAt(0);
    for (final value in classopenCSV) {
      names.addAll(value[23].split(', '));
    }
    for (final each in names) {
      if (each.trim().isNotEmpty) {
        _instances.add(Instructor(each));
      }
    }
  }

  @override
  String toString() => name;
}
