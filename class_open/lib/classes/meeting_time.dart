// author:  Ethan Jansen
// date:    2023/10/26
// class:   MeetingTime
// details: A list of meeting times defined by the day (as int 1-7), and start/stop times (as HourMinute)
// Notes:
/*
   fromString constructor to support schedule.dart.
   Automatically converts day (if positive) to be within 1-7 without warning!
   Throws NegativeTimeException if day is <0.
   Throws EndPreceedsStart exception if start >= end.
   Throws MeetingTimeOutOfRange exception if index >= count for [] operator.
   Recommended to use DateTime when inputting day.
*/

import 'package:class_open/classes/hourminute.dart';

// A list of meeting times defined by the day (as int 1-7), and start/stop times (as HourMinute)
class MeetingTime {
  // constructors
  // default constructor
  MeetingTime();

  // fromString constructor -- match data from schedule.dart
  // partially consistent with toString.
  MeetingTime.fromString(String meetingTimeString) {
    meetingTimeString = meetingTimeString.trim().toUpperCase();
    // no time cases
    if (meetingTimeString.isEmpty) {
      return;
    }

    // there are times to parse

    // split up indivdual times
    late List<String> individualMeetingTimes, splitTime;
    if (meetingTimeString.contains('\n')) {
      // split by newline
      individualMeetingTimes = meetingTimeString.split('\n');
    } else {
      // newline represented by "/" in csv
      individualMeetingTimes = meetingTimeString.split('/');
    }

    for (final time in individualMeetingTimes) {
      // need to catch ARR here in case of "MWF 10:00 - 10:50A/ARR"
      if (time == 'ARR') {
        isARR = true;
        continue;
      }
      // format string
      // replaces space between
      splitTime =
          time.trim().replaceFirst(RegExp(r'\s*-\s*|\s+'), '-').split('-');
      if (splitTime.length != 3) {
        throw FormatException(
          "Input string is not well-deliminated. Must be of form: 'days *space* start - end'.",
          time,
        );
      }

      // get day start/end times
      final HourMinute end = HourMinute.fromString(splitTime[2]);
      HourMinute start = HourMinute.fromString(splitTime[1]);
      final HourMinute startPM = start.add(const Duration(hours: 12));
      // from schedule.dart, only end has AM/PM marker
      if (splitTime[2].contains('P') &&
          !(splitTime[1].contains('P') || splitTime[1].contains('A')) &&
          start < end &&
          startPM < end) {
        start = startPM;
      }

      // get days and create meeting times
      splitTime[0] = splitTime[0].trim();
      for (int i = 0; i < splitTime[0].length; i++) {
        _addWithoutSorting(
          start: start,
          end: end,
          day: _dayNumber(splitTime[0][i]),
        );
        // will silently fail to add (if existing)!
      }
    }

    // final sort
    _meetingTimes.sort();
  }

  // private instance variables
  final List<_AMeetingTime> _meetingTimes = [];

  // public instance variables
  bool isARR = false;

  // private methods
  // throw FormatException where applicable

  // get day letter from day number
  // district.custhelp.com/app/answers/detail/a_id/57/~/days-of-week-abbreviations
  static String _dayLetter(int dayNumber) {
    switch (dayNumber) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'R';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'U';
      default:
        throw FormatException('Day number out of range.', dayNumber);
    }
  }

  // get day number from day letter
  static int _dayNumber(String dayLetter) {
    switch (dayLetter.toUpperCase()) {
      case 'M':
        return DateTime.monday;
      case 'T':
        return DateTime.tuesday;
      case 'W':
        return DateTime.wednesday;
      case 'R':
        return DateTime.thursday;
      case 'F':
        return DateTime.friday;
      case 'S':
        return DateTime.saturday;
      case 'U':
        return DateTime.sunday;
      default:
        throw FormatException('Invalid day letter abbreviation.', dayLetter);
    }
  }

  // same as add, but doesn't sort -- slightly improved efficiency for fromString.
  bool _addWithoutSorting({
    required int day,
    required HourMinute start,
    required HourMinute end,
  }) {
    final _AMeetingTime newTime =
        _AMeetingTime(start: start, end: end, day: day);
    final bool contains = _meetingTimes.contains(newTime);
    final bool conflicts = _meetingTimes
        .where(
          (e) =>
              e.isWithin(newTime) ||
              (e.day == day && (e.occursDuring(start) || e.occursDuring(end))),
        )
        .isNotEmpty;
    if (!(contains || conflicts)) {
      _meetingTimes.add(newTime);
    }

    return !(contains || conflicts);
  }

  // instance methods

  // add time if it does not already exist and does not conflict with another existing time.
  // Sort when adding.
  // returns true if time added successfully.
  // will consider the max if null (start=0:00, end=23:59)
  bool add({
    int? day,
    HourMinute? start,
    HourMinute? end,
  }) {
    if (day == null) {
      return addSeveralDays(start: start, end: end, days: null);
    } else {
      return addSeveralDays(start: start, end: end, days: {day});
    }
  }

  // add time for several days at once.
  // returns true if at least one time was added.
  bool addSeveralDays({
    Set<int>? days,
    HourMinute? start,
    HourMinute? end,
  }) {
    // handle null start/end
    start ??= HourMinute();
    end ??= HourMinute(hour: 23, minute: 59);

    bool oneTimeAdded = false;

    days ??= {1, 2, 3, 4, 5, 6, 7};
    for (final day in days) {
      if (_addWithoutSorting(day: day, start: start, end: end)) {
        oneTimeAdded = true;
      }
    }
    if (oneTimeAdded) {
      _meetingTimes.sort();
    }
    return oneTimeAdded;
  }

  // add() but get end by using HourMinute add() method
  bool addUsingDuration({
    required int day,
    required HourMinute start,
    required Duration length,
  }) =>
      add(day: day, start: start, end: start.add(length));

  // remove matching time. Update hashCode.
  bool remove({
    required int day,
    required HourMinute start,
    required HourMinute end,
  }) {
    final _AMeetingTime removeTime =
        _AMeetingTime(start: start, end: end, day: day);
    final bool contains = _meetingTimes.remove(removeTime);
    return contains;
  }

  // get number of items in internal list
  int get length => _meetingTimes.length;

  // get if contains any times or not
  bool get isEmpty => _meetingTimes.isEmpty;
  bool get isNotEmpty => _meetingTimes.isNotEmpty;

  // get items on day in set of (start, end) records.
  Set<({HourMinute start, HourMinute end})> getPeriodsOnDay(int day) =>
      _meetingTimes
          .where((e) => e.day == day)
          .map((e) => (start: e.start, end: e.end))
          .toSet(); // should this return a set or a list?

  // find sum of durations on day
  Duration getDurationOnDay(int day) {
    Duration returnDuration = const Duration();
    for (final time in _meetingTimes.where((e) => e.day == day)) {
      returnDuration += time.duration;
    }
    return returnDuration;
  }

  // find sum of durations for all internal times.
  Duration get weeklyDuration {
    Duration returnDuration = const Duration();
    for (final time in _meetingTimes) {
      returnDuration += time.duration;
    }
    return returnDuration;
  }

  // get set of days (int) that meet during time.
  Set<int> getDaysAtTime(HourMinute time) => _meetingTimes
      .where((e) => e.occursDuring(time))
      .map((e) => e.day)
      .toSet();

  // get start/end of period that contains time on day.
  // returns (null, null) if no period exists.
  ({HourMinute start, HourMinute end})? getPeriodOnDayAtTime({
    required HourMinute time,
    required int day,
  }) {
    // there should only be 1 match
    if (!isAt(day: day, time: time)) {
      // if no matches
      return null;
    } else {
      final _AMeetingTime returnTime =
          _meetingTimes.firstWhere((e) => e.day == day && e.occursDuring(time));
      return (start: returnTime.start, end: returnTime.end);
    }
  }

  // check if meeting at time, on day, or at time on day.
  // If all null, return true.
  bool isAt({int? day, HourMinute? time}) {
    if (day == null && time == null) {
      return true;
    } else if (day == null) {
      return _meetingTimes.any((e) => e.occursDuring(time!));
    } else if (time == null) {
      return _meetingTimes.any((e) => e.day == day);
    } else {
      return _meetingTimes.any((e) => e.occursDuring(time) && e.day == day);
    }
  }

  // check if there is a time conflict between this and other.
  // doesConflict is true if there is a conflict.
  // conflicts contains set of days and times when conflicts first occur
  // Example: both on Monday, MeetingTime1 has meeting 1:00-2:00, MeetingTime2 has meeting 1:30-3:00,
  //          MeetingTime1.checkConflict(MeetingTime2) will have a conflict at 1:30,
  //          MeetingTime2.checkConflict(MeetingTime1) will have a conflict at 1:30.
  ({bool doesConflict, Set<({int day, HourMinute time})> conflicts})
      checkConflict(MeetingTime other) {
    final Set<({int day, HourMinute time})> conflicts = {};
    final int maxCount = length > other.length ? length : other.length;

    // check both ways for consistency
    // set with remove duplicates
    for (int i = 0; i < maxCount; i++) {
      if (i < length && other.isAt(day: this[i].day, time: this[i].start)) {
        // there is a conflict at this start -- add this start
        conflicts.add((day: this[i].day, time: this[i].start));
      }
      if (i < other.length && isAt(day: other[i].day, time: other[i].start)) {
        // there is a conflict at other start -- add other start
        conflicts.add((day: other[i].day, time: other[i].start));
      }
    }

    return (doesConflict: conflicts.isNotEmpty, conflicts: conflicts);
  }

  @override
  // return string like existing classOpen
  String toString({bool? is24hr}) {
    String returnString = '';

    // create copy list
    final List<_AMeetingTime> meetingTimesCopy = List.of(_meetingTimes);

    // iterate over matched times adding them all as one line in returnString, then move to next line
    late Iterable<_AMeetingTime> times;
    do {
      final _AMeetingTime? selectedMeet = meetingTimesCopy.firstOrNull;
      if (selectedMeet == null) {
        //check if _meetingTimes is empty
        break;
      }
      times = meetingTimesCopy.where(
        (e) => e.sameTimes(selectedMeet),
      ); // times with same matching time

      // adding to string
      for (final _AMeetingTime time in times) {
        returnString += _dayLetter(time.day);
      }
      returnString +=
          ' ${times.first.start.toString(is24hr: is24hr)} - ${times.first.end.toString(is24hr: is24hr)}\n';

      // remove times from meetingTimesCopy
      meetingTimesCopy.removeWhere((e) => times.contains(e));
    } while (meetingTimesCopy.isNotEmpty);

    // check if ARR
    if (isARR) {
      returnString += 'ARR\n';
    }

    return returnString.trimRight();
  }

  // return string expanded so that every internal time is on separate line.
  String toStringExpanded({bool? is24hr}) {
    String returnString = '';

    for (final time in _meetingTimes) {
      returnString +=
          '${_dayLetter(time.day)} ${time.start.toString(is24hr: is24hr)} - ${time.end.toString(is24hr: is24hr)}\n';
    }

    // check if ARR
    if (isARR) {
      returnString += 'ARR\n';
    }

    return returnString.trimRight();
  }

  // [] operator
  // throws MeetingTimeOutOfRange if index >= count.
  ({int day, HourMinute start, HourMinute end}) operator [](int index) {
    if (index >= length) {
      throw MeetingTimeOutOfRange();
    }
    final _AMeetingTime time = _meetingTimes[index];

    return (day: time.day, start: time.start, end: time.end);
  }

  // equals (not override)
  bool equals(Object other) {
    if (identical(this, other)) {
      // if identical
      return true;
    } else if (!(other is MeetingTime && length == other.length)) {
      // if not MeetingTime, or does not have the same count
      return false;
    }

    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        // each record is equal
        return false;
      }
    }

    if (isARR != other.isARR) {
      return false;
    }

    return true;
  }
}

// ------------------------ private class -------------------------------

// defines day (as int), start and stop times (as HourMinute)
class _AMeetingTime implements Comparable<_AMeetingTime> {
  // constructors

  // follows DateTime class (1 is monday, 7 is sunday)
  // throws EndPreceedsStart exception if start >= end
  // throws NegativeTimeException if day < 0.
  _AMeetingTime({required this.start, required this.end, required int day}) {
    if (day < 0) {
      throw NegativeTimeException();
    }
    this.day = ((day - 1) % 7) + 1;

    if (start >= end) {
      throw EndPreceedsStart();
    }
  }
  // instance variables
  final HourMinute start, end;
  late final int day;

  // instance methods

  // checks if time is within _AMeetingTime
  // inclusivity: [start, end)
  bool occursDuring(HourMinute time) => time >= start && time < end;

  // check if _AMeetingTime is within other
  bool isWithin(_AMeetingTime other) =>
      other.start <= start && other.end >= end && other.day == day;

  // check if _AMeetingTime surrounds other
  bool surrounds(_AMeetingTime other) =>
      other.start >= start && other.end <= end && other.day == day;

  // checks if start and stop time are the same (doesn't care about day)
  bool sameTimes(_AMeetingTime other) =>
      start == other.start && end == other.end;

  // get duration between start and stop
  Duration get duration => end.durationFrom(start);

  @override
  // necessary for sorting in list
  // negative if this is ordered before other
  int compareTo(_AMeetingTime other) {
    if (this == other) {
      return 0;
    }

    // negative if respective time for this occurs before other
    final int compareStarts =
        ((day * 1440) + (start.hour * 60) + start.minute) -
            ((other.day * 1440) + (other.start.hour * 60) + other.start.minute);
    final int compareEnds = ((day * 1440) + (end.hour * 60) + end.minute) -
        ((other.day * 1440) + (other.end.hour * 60) + other.end.minute);

    if (compareStarts == 0) {
      return compareEnds;
    } else {
      return compareStarts;
    }
  }

  @override
  int get hashCode => (day, start, end).hashCode; // are these unique?

  // equality override
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _AMeetingTime &&
          day == other.day &&
          start == other.start &&
          end == other.end);
}

// ---------------- exceptions -------------------
class EndPreceedsStart implements Exception {}

class MeetingTimeOutOfRange implements Exception {}
