import 'package:class_open/classes/campus_list.dart';
import 'package:class_open/classes/class.dart';

class Campus {
  Campus(this.code, this.name);
  final String code;
  final String name;

  static var _instances = <Campus>{};

  static Set<Campus> get instances {
    if (_instances.isEmpty) {
      _instances = {AllCampuses(), ...InitializeCampus.initialList()};
    }
    return _instances;
  }

  bool includesClass(Class classInstance) {
    return classInstance.campus == this;
  }

  static Campus allCampuses() {
    return instances.first;
  }
}

class AllCampuses extends Campus {
  AllCampuses() : super('', 'ALL');

  @override
  bool includesClass(Class classInstance) {
    return true;
  }
}
