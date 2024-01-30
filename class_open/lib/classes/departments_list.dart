import 'package:class_open/classes/department.dart';

extension InitializeDepartment on Department {
  static Set<Department> initialList() {
    final instances = <Department>{};
    _departments.forEach((key, value) {
      instances.add(Department(key, value));
    });
    return instances;
  }
}

Map<String, String> _departments = {
  'ACDM': 'Acadeum',
  'ART': 'Art',
  'BIOL': 'Biology',
  'BUSI': 'Business',
  'CHEM': 'Chemistry',
  'COMM': 'Communication',
  'CPTR': 'Computer Science',
  'EDUC': 'Education & Psychology',
  'ENGI': 'Engineering',
  'ENGL': 'English & Modern Languages',
  'ESLP': 'English as Second Language',
  'HIST': 'History and Philosophy',
  'HLTH': 'Health and Physical Education',
  'HMEC': 'Home Economics',
  'HONR': 'Honors',
  'INTR': 'Interdisciplinary Programs',
  'LIBR': 'Library',
  'MATH': 'Mathematics',
  'MDLG': 'Modern Language',
  'MUCT': 'Music',
  'NDEP': 'Non-Departmental',
  'NRSG': 'Nursing',
  'PHYS': 'Physics',
  'PREP': 'Pre-Professional',
  'RELB': 'Theology',
  'SOWK': 'Social Work & Sociology',
  'TECH': 'Technology',
  'WWU': 'Walla Walla University',
};
