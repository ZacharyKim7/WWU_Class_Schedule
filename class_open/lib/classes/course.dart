import 'package:class_open/classes/department.dart';
import 'package:class_open/classes/subject.dart';
import 'package:class_open/classes/load_csv.dart';

class Course {
  Course(
    String departmentCode,
    String subjectCode,
    this.title,
    this.number,
    this.level,
    this.credits, [
    this.isGeneralStudies = false,
  ]) {
    final departments = Department.instances;
    department = departments.firstWhere((dept) => departmentCode == dept.code);
    final subjects = Subject.instances;
    subject = subjects.firstWhere((subj) => subjectCode == subj.code);
  }
  Department? department;
  Subject? subject;
  final String title;
  final String number;
  final String level;
  final int credits;
  final bool isGeneralStudies;

  static final _instances = <Course>{};

  static Set<Course> get instances {
    if (_instances.isEmpty) {
      Course.getAllCourses();
    }
    return _instances;
  }

  static void getAllCourses() {
    final classopenCSV = getListFromCsv();
    // Remove headers
    classopenCSV.removeAt(0);
    for (final value in classopenCSV) {
      String courseNumber;
      final String courseNumberOnly;
      // Class number is not specified in one spot, it is specified based on the quarter, Summer, Fall, Winter, Spring, Summer2
      if (value[8] != '') {
        courseNumber = value[8].toString();
      } else if (value[9] != '') {
        courseNumber = value[9].toString();
      } else if (value[10] != '') {
        courseNumber = value[10].toString();
      } else if (value[11] != '') {
        courseNumber = value[11].toString();
      } else if (value[12] != '') {
        courseNumber = value[12].toString();
      } else {
        courseNumber = '0';
      }

      courseNumber = courseNumber.replaceAll(' ', '');
      courseNumberOnly = courseNumber.replaceAll(RegExp('[^0-9]'), '');
      final level = int.parse(courseNumberOnly) > 300 ? 'upper' : 'lower';
      _instances.add(
        Course(
          value[3],
          value[7],
          value[14],
          courseNumber,
          level,
          int.tryParse(value[16]) ?? 0,
          value[6] == 'GS',
        ),
      );
    }
  }
}
