import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/timetable.dart';
import 'package:work_schedule/db/database_provider.dart';
import 'package:work_schedule/models/shift.dart';
import 'package:work_schedule/widgets/ShiftMaker.dart';
import '../models/employee.dart';

class ScheduleCompiler extends StatefulWidget {
  final List<Employee> _employees;

  ScheduleCompiler(this._employees);
  @override
  _ScheduleCompilerState createState() => _ScheduleCompilerState();
}

class _ScheduleCompilerState extends State<ScheduleCompiler> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<BasicEvent> eventsPayload = [];

  void _presentDatePicker(BuildContext ctx) async {
    final pickedDate = await showDatePicker(
        context: ctx,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2090));

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  bool compareDates(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
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
                          : DateFormat.Hm().format(shift.start) +
                              " - " +
                              DateFormat.Hm().format(shift.end) +
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
                          if (value != null) {
                            Shift newShift = value as Shift;
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

                              DatabaseProvider.db
                                  .updateEmployee(widget._employees[index].id,
                                      widget._employees[index])
                                  .then((value) {
                                print(value);
                                // widget._addEvents([
                                //   BasicEvent(
                                //       id: widget._employees[index].id +
                                //           Random().nextInt(99999),
                                //       color:
                                //           Color(widget._employees[index].color),
                                //       title:
                                //           widget._employees[index].firstName +
                                //               " " +
                                //               widget._employees[index].lastName,
                                //       start: LocalDateTime.dateTime(
                                //           newShift.start.toLocal()),
                                //       end: LocalDateTime.dateTime(
                                //           newShift.end.toLocal()))
                                // ]);
                              });
                            });
                          }
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
