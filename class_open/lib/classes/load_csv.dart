import 'package:csv/csv.dart';

import 'package:class_open/classes/schedule.dart';

List<List<dynamic>> getListFromCsv() {
  final csvFile = getSchedule();
  return const CsvToListConverter(fieldDelimiter: ',', eol: '\n')
      .convert(csvFile)
      .toList();
}
