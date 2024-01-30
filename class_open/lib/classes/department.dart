import 'package:class_open/classes/departments_list.dart';
import 'package:class_open/classes/course.dart';

class Department {
  Department(this.code, this.name);
  final String code;
  final String name;

  static var _instances = <Department>{};

  static Set<Department> get instances {
    if (_instances.isEmpty) {
      _instances = {AllDepartments(), ...InitializeDepartment.initialList()};
    }
    return _instances;
  }

  static Department departmentwithCode(String code) {
    final departmentOfCode =
        Department.instances.firstWhere((instance) => instance.code == code);

    return departmentOfCode;
  }

  bool includesCourse(Course course) {
    return course.department == this;
  }

  static Department allDepartments() {
    return instances.first;
  }

  @override
  String toString() {
    return '$name ($code)';
  }
}

class AllDepartments extends Department {
  AllDepartments() : super('', 'ALL');

  @override
  bool includesCourse(Course course) {
    return true;
  }
}
