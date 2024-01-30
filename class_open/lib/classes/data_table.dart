import 'package:flutter/material.dart';
import 'package:class_open/classes/class.dart';

class TableData extends DataTableSource {
  TableData(this._data, this._savedData, this._saveClassFunction);
  final List<Class> _data;
  final List<Class> _savedData;
  final void Function(Class aClass, bool shouldSave) _saveClassFunction;

  @override
  DataRow? getRow(int index) {
    return DataRow(
      selected: _savedData.any((element) => element == _data[index]),
      onSelectChanged: (isChecked) {
        _saveClassFunction(_data[index], isChecked!);
      },
      cells: [
        DataCell(Text(_data[index].course.subject!.code)),
        DataCell(Text(_data[index].course.number)),
        DataCell(Text(_data[index].course.title)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
