// author:  Ethan Jansen
// date:    2023/10/26
// class:   HourMinute
// details: A 24hr time (hour, minute)
// Notes:
/*
  Immutable.
   Will automatically convert time to have hour<24 and minute<60 without warning!
   Throws exception if hour or minute is negative.
   Throws FormatException on fromString construction if not a proper string.
*/

class HourMinute implements Comparable<HourMinute> {
  // constructors
  // direct construction (24 hour time)
  HourMinute({int hour = 0, int minute = 0}) {
    if (hour.isNegative || minute.isNegative) {
      throw NegativeTimeException();
    }

    this.hour = (hour + minute ~/ 60) % 24;
    this.minute = minute % 60;
  }

  // construct using string
  // 24hr or 12hr. Split hour/minute by ':'.
  // throws FormatException on improper string.
  factory HourMinute.fromString(String string) {
    string = string.trim().toUpperCase();

    final List<String> hourMinuteStrings = string.split(':');
    if (hourMinuteStrings.length != 2) {
      throw FormatException("Not deliminated by ':'.", string);
    }

    // hour parse -- possibly not padded
    final String hourString = hourMinuteStrings[0].length < 3
        ? hourMinuteStrings[0]
        : hourMinuteStrings[0].substring(
            hourMinuteStrings[0].length - 2,
            hourMinuteStrings[0].length,
          );
    int hour = int.parse(hourString);
    // 12hr check
    if (string.contains('P') && hour != 12) {
      hour += 12;
    }

    // minute parse
    final String minString = hourMinuteStrings[1].substring(0, 2);
    final int minute = int.parse(minString);

    return HourMinute(hour: hour, minute: minute);
  }

  // construct using DateTime
  HourMinute.fromDate(DateTime date) {
    hour = date.hour;
    minute = date.minute;
  }
  // class variables
  static HourMinute get noon => HourMinute(hour: 12);
  // instance variables - now final to keep equality operator/hashCode overrides
  late final int hour, minute;

  // instance methods

  // get HourMinute after Duration dur
  HourMinute add(Duration dur) => HourMinute(
        hour: hour + dur.inHours,
        minute: minute + (dur.inMinutes % 60),
      );

  // get Duration from other HourMinute (this-other)
  Duration durationFrom(HourMinute other) =>
      Duration(hours: hour - other.hour, minutes: minute - other.minute);

  // get string from HourMinute -- if is24hr==null, treat as is24hr=true;
  @override
  String toString({bool? is24hr}) {
    is24hr ??= true;

    if (is24hr) {
      return "$hour:${minute.toString().padLeft(2, '0')}";
    } else {
      return hour > 11
          ? "${hour % 12}:${minute.toString().padLeft(2, '0')}PM"
          : "${hour % 12}:${minute.toString().padLeft(2, '0')}AM";
    }
  }

  @override
  int compareTo(HourMinute other) =>
      ((hour * 60) + minute) - ((other.hour * 60) + other.minute);

  @override
  int get hashCode => ((hour * 60) + minute).hashCode;

  // comparison operators

  bool operator <=(HourMinute other) =>
      (hour * 60) + minute <= (other.hour * 60) + other.minute;
  bool operator <(HourMinute other) =>
      (hour * 60) + minute < (other.hour * 60) + other.minute;
  bool operator >=(HourMinute other) =>
      (hour * 60) + minute >= (other.hour * 60) + other.minute;
  bool operator >(HourMinute other) =>
      (hour * 60) + minute > (other.hour * 60) + other.minute;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HourMinute && hour == other.hour && minute == other.minute);
}

// exceptions
class NegativeTimeException implements Exception {}
