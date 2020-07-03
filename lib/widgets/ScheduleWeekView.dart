import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

class ScheduleWeekView extends StatefulWidget {
  static final myEventProvider = EventProvider.list([
    BasicEvent(
      id: 0,
      title: 'A. B',
      color: Colors.yellow,
      start: LocalDate.today().at(LocalTime(13, 0, 0)),
      end: LocalDate.today().at(LocalTime(15, 0, 0)),
    ),
  ]);

  @override
  _ScheduleWeekViewState createState() => _ScheduleWeekViewState();
}

class _ScheduleWeekViewState extends State<ScheduleWeekView> {
  final myController = TimetableController(
    eventProvider: ScheduleWeekView.myEventProvider,
    initialTimeRange: InitialTimeRange.range(
      startTime: LocalTime(7, 0, 0),
      endTime: LocalTime(20, 0, 0),
    ),
    initialDate: LocalDate.today(),
    visibleRange: VisibleRange.week(),
    firstDayOfWeek: DayOfWeek.monday,
  );

  @override
  Widget build(BuildContext context) {
    return Timetable<BasicEvent>(
      controller: myController,
      eventBuilder: (event) => BasicEventWidget(event),
      allDayEventBuilder: (context, event, info) =>
          BasicAllDayEventWidget(event, info: info),
      theme: TimetableThemeData(
          primaryColor: Colors.teal[300],
          dividerColor: Colors.indigo[800],
          timeIndicatorColor: Colors.redAccent[700]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
  }
}
