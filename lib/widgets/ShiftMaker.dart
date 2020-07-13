import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_schedule/models/employee.dart';
import 'package:work_schedule/models/shift.dart';
import '../util/date_functions.dart';
import '../util/settings.dart';

class ShiftMaker extends StatefulWidget {
  final Employee _emp;
  final DateTime _date;

  ShiftMaker(this._emp, this._date);

  @override
  _ShiftMakerState createState() => _ShiftMakerState();
}

class _ShiftMakerState extends State<ShiftMaker> {
  TimeOfDay _start;
  TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    setState(() {
      try {
        final Shift tmp = widget._emp.shifts
            .where((sh) => compareDates(sh.start, widget._date))
            .toList()[0];
        _start = TimeOfDay(hour: tmp.start.hour, minute: tmp.start.minute);
        _end = TimeOfDay(hour: tmp.end.hour, minute: tmp.end.minute);
      } catch (_) {
        _start = null;
        _end = null;
      }
    });
  }

  Future<TimeOfDay> selectTime(BuildContext context) async {
    return await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 7, minute: 0));
  }

  @override
  Widget build(BuildContext context) {
    DateFormat df = settings['H24'] ? DateFormat.Hm() : DateFormat.jm();
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
                    DateTime(widget._date.year, widget._date.month,
                        widget._date.day, _start.hour, _start.minute),
                    DateTime(widget._date.year, widget._date.month,
                        widget._date.day, _end.hour, _end.minute)));
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
                widget._emp.firstName +
                    " " +
                    widget._emp.lastName +
                    " @ " +
                    DateFormat.MMMMEEEEd().format(widget._date),
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
                    : df.format(DateTime(widget._date.year, widget._date.month,
                        widget._date.day, _start.hour, _start.minute))),
                textColor: Colors.tealAccent,
                onPressed: () async {
                  TimeOfDay tmp = await selectTime(context);
                  if (tmp != null) {
                    setState(() {
                      if (_end != null &&
                          DateTime(widget._date.year, widget._date.month,
                                  widget._date.day, tmp.hour, tmp.minute)
                              .isAfter(DateTime(
                                  widget._date.year,
                                  widget._date.month,
                                  widget._date.day,
                                  _end.hour,
                                  _end.minute))) {
                        var dt = DateTime(widget._date.year, widget._date.month,
                                widget._date.day, _end.hour, _end.minute)
                            .subtract(Duration(minutes: 30));
                        _start = TimeOfDay(hour: dt.hour, minute: dt.minute);
                      } else {
                        _start = tmp;
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
                    : df.format(DateTime(widget._date.year, widget._date.month,
                        widget._date.day, _end.hour, _end.minute))),
                textColor: Colors.tealAccent,
                onPressed: () async {
                  TimeOfDay tmp = await selectTime(context);
                  if (tmp != null) {
                    setState(() {
                      if (_start != null &&
                          DateTime(widget._date.year, widget._date.month,
                                  widget._date.day, tmp.hour, tmp.minute)
                              .isBefore(DateTime(
                                  widget._date.year,
                                  widget._date.month,
                                  widget._date.day,
                                  _start.hour,
                                  _start.minute))) {
                        var dt = DateTime(widget._date.year, widget._date.month,
                                widget._date.day, _start.hour, _start.minute)
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
                Navigator.of(context).pop(widget._date);
              },
            ),
          )
        ],
      ),
    );
  }
}
