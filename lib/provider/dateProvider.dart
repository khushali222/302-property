import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateProvider with ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  String _dateFormat = 'MM-dd-yyyy';
  int dateformateselect = 0;// default date format

  DateTime get currentDate => _currentDate;
  String get dateFormat => _dateFormat;
  int get _dateformateselect => dateformateselect;

  DateProvider() {
    _loadDateFormat();
  }

  Future<void> _loadDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final dateFormat = prefs.getString('dateFormat');
    final _dateformateselect = prefs.getInt('dateformateselect');

    if (dateFormat != null && _dateformateselect != null) {
      _dateFormat = dateFormat;
      dateformateselect = _dateformateselect;
    }
  }

  Future<void> _saveDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateFormat', _dateFormat);
    await prefs.setInt('dateformateselect', dateformateselect);
  }

  void updateDateFormat(String newFormat,selectindex) {
    _dateFormat = newFormat;
    dateformateselect = selectindex;
    _saveDateFormat();
    print(_dateFormat);
    notifyListeners();
  }

  String formatCurrentDate(String dateTime) {

      //print(dateTime);
      List<String> dateFormats = [
        'yyyy-MM-dd',
        'yyyy-M-d',
        'dd-MM-yyyy',
        'd-M-yyyy',
        'M/d/yyyy',
        'MM/dd/yyyy',
        'M/d/yyyy, h:mm:ss a',
        'M/d/yyyy, h:mm a'        // 05032024 (no separators)
      ];

      DateTime? parsedDate;

      for (String format in dateFormats) {
        //  print(dateTime);
        try {
          parsedDate = DateFormat(format).parse(dateTime);
          //  print(parsedDate);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate == null) {
        return dateTime;
        //  throw FormatException("Date format not recognized: $dateTime");
      }
      // print(parsedDate);


    return DateFormat(_dateFormat).format(parsedDate);
  }
}

