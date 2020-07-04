import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';

class ScheduleWeekView extends StatefulWidget {
  final TimetableController<BasicEvent> _controller;

  ScheduleWeekView(this._controller);
  @override
  _ScheduleWeekViewState createState() => _ScheduleWeekViewState();
}

class _ScheduleWeekViewState extends State<ScheduleWeekView> {
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
