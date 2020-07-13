import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/timetable.dart';
import 'package:work_schedule/util/settings.dart';
import '../db/database_provider.dart';
import '../models/shift.dart';
import '../widgets/ShiftMaker.dart';
import '../models/employee.dart';
import '../util/date_functions.dart';

class ScheduleCompiler extends StatefulWidget {
  final List<Employee> _employees;

  ScheduleCompiler(this._employees);
  @override
  _ScheduleCompilerState createState() => _ScheduleCompilerState();
}

class _ScheduleCompilerState extends State<ScheduleCompiler> {
  DateTime _selectedDate = getNextWeek()[0];
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<BasicEvent> eventsPayload = [];

  void _presentDatePicker(BuildContext ctx) async {
    final pickedDate = await showDatePicker(
        context: ctx,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2090));

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat df = settings['H24'] ? DateFormat.Hm() : DateFormat.jm();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Schedule Compiler"),
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              onPressed: () => _presentDatePicker(context),
              child: Text(DateFormat.yMMMMEEEEd().format(_selectedDate)),
            ),
          ],
        ),
        Expanded(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              itemBuilder: (context, index) {
                Shift shift;
                try {
                  shift = widget._employees[index].shifts
                      .where((sh) => compareDates(sh.start, _selectedDate))
                      .toList()[0];
                } catch (_) {
                  shift = null;
                }
                return Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                          "${widget._employees[index].firstName} ${widget._employees[index].lastName}"),
                      subtitle: Text(shift == null
                          ? "N/A"
                          : df.format(shift.start) +
                              " - " +
                              df.format(shift.end) +
                              " " +
                              DateFormat.EEEE().format(shift.end)),
                      trailing: IconButton(
                        icon: Icon(Icons.schedule),
                        color: Color(widget._employees[index].color),
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (context) => ShiftMaker(
                              widget._employees[index], _selectedDate),
                        ))
                            .then((value) {
                          if (value != null && value is Shift) {
                            Shift newShift = value;
                            setState(() {
                              bool isDayOccupied =
                                  widget._employees[index].shifts.any((sh) =>
                                      compareDates(sh.start, newShift.start));
                              if (!isDayOccupied) {
                                widget._employees[index].shifts.add(newShift);
                              } else {
                                int oldIndex = widget._employees[index].shifts
                                    .indexWhere((sh) =>
                                        compareDates(sh.start, newShift.start));
                                widget._employees[index].shifts.replaceRange(
                                    oldIndex, oldIndex + 1, [newShift]);
                              }
                            });
                          } else {
                            if (value is DateTime)
                              setState(() {
                                widget._employees[index].shifts.removeWhere(
                                    (sh) => compareDates(sh.start, value));
                              });
                          }

                          DatabaseProvider.db
                              .updateEmployee(widget._employees[index].id,
                                  widget._employees[index])
                              .then((value) => print(value));
                        }),
                      ),
                    ));
              },
              itemCount: widget._employees.length,
            ),
          ),
        )
      ]),
    );
  }
}
