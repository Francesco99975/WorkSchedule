import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timetable/timetable.dart';
import '../providers/settings.dart';
import '../widgets/employee_time_item.dart';
import '../util/date_functions.dart';
import '../providers/employees.dart';

class ScheduleCompilerScreen extends StatefulWidget {
  static const ROUTE_NAME = '/schedule-compiler';
  @override
  _ScheduleCompilerScreenState createState() => _ScheduleCompilerScreenState();
}

class _ScheduleCompilerScreenState extends State<ScheduleCompilerScreen> {
  DateTime _selectedDate = getNextWeek()[0];
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<BasicEvent> eventsPayload = [];
  final sensitivity = 7.3;

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
    final timeFormat = Provider.of<Settings>(context, listen: false).timeFormat;
    DateFormat df = timeFormat ? DateFormat.Hm() : DateFormat.jm();
    return Scaffold(
      appBar: AppBar(
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
        Consumer<Employees>(
          builder: (_, employees, __) => Expanded(
            child: ListView.builder(
              itemCount: employees.items.length,
              itemBuilder: (_, index) => ChangeNotifierProvider.value(
                value: employees.items[index],
                child: EmployeeTimeItem(_selectedDate, df),
              ),
            ),
          ),
        ),
      ]),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btna1",
              child: Icon(
                Icons.keyboard_arrow_left,
                size: 30.0,
              ),
              onPressed: () {
                //left swipe
                setState(() {
                  _selectedDate = _selectedDate.subtract(Duration(days: 1));
                });
              },
            ),
            const SizedBox(
              width: 15,
            ),
            FloatingActionButton(
              heroTag: "btna2",
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 30.0,
              ),
              onPressed: () {
                //right swipe
                setState(() {
                  _selectedDate = _selectedDate.add(Duration(days: 1));
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
