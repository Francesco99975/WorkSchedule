import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:work_schedule/models/shift.dart';
import 'package:work_schedule/providers/employee.dart';
import 'package:work_schedule/providers/employees.dart';
import '../util/date_functions.dart';

class ShiftMakerScreen extends StatefulWidget {
  static const ROUTE_NAME = '/shift-maker';

  @override
  _ShiftMakerScreenState createState() => _ShiftMakerScreenState();
}

class _ShiftMakerScreenState extends State<ShiftMakerScreen> {
  Employee _emp;
  int _empId;
  TimeOfDay _start;
  TimeOfDay _end;
  DateTime _date;
  DateFormat df;
  bool _isInit = true;

  Future<TimeOfDay> selectTime(BuildContext context) async {
    return await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 7, minute: 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      _empId = args['id'];
      _date = args['date'];
      df = args['timeFormat'];
      _emp = Provider.of<Employees>(context, listen: false).findbyId(_empId);
      try {
        final Shift tmp = _emp.shifts
            .where((sh) => compareDates(sh.start, _date))
            .toList()[0];
        _start = TimeOfDay(hour: tmp.start.hour, minute: tmp.start.minute);
        _end = TimeOfDay(hour: tmp.end.hour, minute: tmp.end.minute);
      } catch (_) {
        _start = null;
        _end = null;
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Create Work Shift"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            textColor: Colors.black,
            onPressed: () {
              if (_start != null && _end != null) {
                Navigator.of(context).pop(Shift(
                    DateTime(_date.year, _date.month, _date.day, _start.hour,
                        _start.minute),
                    DateTime(_date.year, _date.month, _date.day, _end.hour,
                        _end.minute)));
              }
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Text(
                _emp.firstName +
                    " " +
                    _emp.lastName +
                    " @ " +
                    DateFormat.MMMMEEEEd().format(_date),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 1.2),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Start Time: ",
                style: TextStyle(fontSize: 22, wordSpacing: 1.2),
              ),
              SizedBox(
                width: 5,
              ),
              FlatButton(
                child: Text(_start == null
                    ? "N/A"
                    : df.format(DateTime(_date.year, _date.month, _date.day,
                        _start.hour, _start.minute))),
                textColor: Colors.tealAccent,
                onPressed: () async {
                  TimeOfDay tmp = await selectTime(context);
                  if (tmp != null) {
                    setState(() {
                      if (_end != null &&
                          DateTime(_date.year, _date.month, _date.day, tmp.hour,
                                  tmp.minute)
                              .isAfter(DateTime(_date.year, _date.month,
                                  _date.day, _end.hour, _end.minute))) {
                        var dt = DateTime(_date.year, _date.month, _date.day,
                                _end.hour, _end.minute)
                            .subtract(Duration(minutes: 30));
                        _start = TimeOfDay(hour: dt.hour, minute: dt.minute);
                      } else {
                        _start = tmp;
                        print(_start);
                      }
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "End Time: ",
                style: TextStyle(fontSize: 22, wordSpacing: 1.2),
              ),
              SizedBox(
                width: 5,
              ),
              FlatButton(
                child: Text(_end == null
                    ? "N/A"
                    : df.format(DateTime(_date.year, _date.month, _date.day,
                        _end.hour, _end.minute))),
                textColor: Colors.tealAccent,
                onPressed: () async {
                  TimeOfDay tmp = await selectTime(context);
                  if (tmp != null) {
                    setState(() {
                      if (_start != null &&
                          DateTime(_date.year, _date.month, _date.day, tmp.hour,
                                  tmp.minute)
                              .isBefore(DateTime(_date.year, _date.month,
                                  _date.day, _start.hour, _start.minute))) {
                        var dt = DateTime(_date.year, _date.month, _date.day,
                                _start.hour, _start.minute)
                            .add(Duration(minutes: 30));
                        _end = TimeOfDay(hour: dt.hour, minute: dt.minute);
                      } else {
                        _end = tmp;
                      }
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: RaisedButton(
              child: Text(
                "OFF WORK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              color: Colors.amber,
              textColor: Colors.black,
              onPressed: () {
                setState(() {
                  _start = null;
                  _end = null;
                });
                Navigator.of(context).pop(_date);
              },
            ),
          )
        ],
      ),
    );
  }
}
