import 'package:class_open/classes/campus.dart';

extension InitializeCampus on Campus {
  static Set<Campus> initialList() {
    final instances = <Campus>{};
    final lines = csv().split('\n');
    for (final line in lines) {
      final values = line.split(',');
      instances.add(Campus(values[0], values[1]));
    }
    return instances;
  }

  static String csv() {
    return '''ACA,Adventist Colleges Abroad
ACDM,Acadeum
BI,Billings
CP,College Place
LAFS,LA Film Studies Center
MI,Missoula
PD,Portland
RO,Rosario''';
  }
}
