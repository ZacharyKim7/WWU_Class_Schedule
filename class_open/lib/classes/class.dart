import 'package:class_open/classes/campus.dart';
import 'package:class_open/classes/course.dart';
import 'package:class_open/classes/term.dart';
import 'package:class_open/classes/instructor.dart';
import 'package:class_open/classes/load_csv.dart';
import 'package:class_open/classes/meeting_time.dart';

class Class implements Comparable<Class>{
  Class(
    this.course,
    this.term,
    this.maxEnrollment,
    this.schedule,
    this.classroom,
    this.instructors,
    this.campus, [
    this.video = '',
    this.consent = '',
    this.specialNotes = '',
    this.fee = 0,
    this.currEnrollment = 0,
    this.waitlist = 0,
    this.section = 'A',
    this.isOpenForEnrollment = true,
    this.saved = false,
  ]);

  Course course;
  Term term;
  String section;
  int maxEnrollment;
  int currEnrollment;
  bool isOpenForEnrollment;
  int waitlist;
  int fee;
  MeetingTime schedule;
  String classroom;
  Set<Instructor> instructors;
  Campus campus;
  String video;
  String consent;
  String specialNotes;
  bool saved;

  static final _instances = <Class>{};

  static Set<Class> get instances {
    if (_instances.isEmpty) {
      Class._initialize();
    }
    return _instances;
  }

  static void _initialize() {
    Course.getAllCourses();
    final classListFromCsv = getListFromCsv();
    classListFromCsv.removeAt(0);
    for (final listing in classListFromCsv) {
      final Course currCourse =
          Course.instances.firstWhere((each) => each.title == listing[14]);
      final Set<Instructor> currInstructors = Instructor.instances
          .where((each) => listing[23].contains(each.name))
          .toSet();
      final Campus currCampus =
          Campus.instances.firstWhere((each) => each.code == listing[1]);
      var termYear = (listing[2] / 1000).truncate().toString() +
          (listing[2] % 2000).toString();
      var termMonth = '';
      var termFound = '';
      for (int i = 8; i <= 12; i++) {
        termFound = listing[i].toString();
        if (termFound != '') {
          if (i <= 9) {
            termYear = (int.parse(termYear) - 1).toString();
          }
          if (i == 9) {
            termMonth = '9';
          } else if (i == 10) {
            termMonth = '1';
          } else if (i == 11) {
            termMonth = '3';
          } else {
            termMonth = '6';
          }
          break;
        }
      }
      final termCode = int.parse(termYear + termMonth);
      final Term currTerm =
          Term.instances.firstWhere((each) => each.code == termCode);
      _instances.add(
        Class(
          currCourse,
          currTerm,
          listing[18],
          MeetingTime.fromString(listing[21]), // schedule
          listing[22],
          currInstructors,
          currCampus,
        ),
      );
    }
  }

  void changeEnrollmentStatus() {
    isOpenForEnrollment = !isOpenForEnrollment;
  }

  void updateWaitlist(String updateType) {
    if (updateType == 'add') {
      waitlist = waitlist + 1;
    } else if (updateType == 'drop' && waitlist > 0) {
      waitlist = waitlist - 1;
    } else {
      throw 'waitlist out of bounds';
    }
  }
  
  @override
  int compareTo(Class other) {
      final aString = '${course.subject!.code} ${course.number} ${term.code} $section';
      final bString = '${other.course.subject!.code} ${other.course.number} ${other.term.code} ${other.section}';
      return aString.compareTo(bString);
    }
}
