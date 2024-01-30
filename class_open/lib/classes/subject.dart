import 'package:class_open/classes/subjects_list.dart';
import 'package:class_open/classes/course.dart';

class Subject {
  Subject(this.code, this.name);
  final String code;
  final String name;

  static var _instances = <Subject>{};

  static Set<Subject> get instances {
    if (_instances.isEmpty) {
      _instances = {AllSubjects(), ...InitializeSubject.initialList()};
    }
    return _instances;
  }

  bool includesCourse(Course course) {
    return course.subject == this;
  }

  static Subject allSubjects() {
    return instances.first;
  }
}

class AllSubjects extends Subject {
  AllSubjects() : super('', 'ALL');

  @override
  bool includesCourse(Course course) {
    return true;
  }
}
