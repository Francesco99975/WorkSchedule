import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';

class ScheduleWeekViewScreen extends StatefulWidget {
  static const ROUTE_NAME = '/timetable';
  final TimetableController<BasicEvent> _controller;

  ScheduleWeekViewScreen(this._controller);
  @override
  _ScheduleWeekViewScreenState createState() => _ScheduleWeekViewScreenState();
}

class _ScheduleWeekViewScreenState extends State<ScheduleWeekViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Timetable<BasicEvent>(
      controller: widget._controller,
      eventBuilder: (event) => BasicEventWidget(event),
      allDayEventBuilder: (context, event, info) =>
          BasicAllDayEventWidget(event, info: info),
      theme: TimetableThemeData(
          primaryColor: Colors.teal[300],
          dividerColor: Colors.indigo[800],
          timeIndicatorColor: Colors.redAccent[700]),
    );
  }
}
