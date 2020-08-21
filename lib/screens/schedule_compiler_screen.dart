import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timetable/timetable.dart';
import '../providers/settings.dart';
import '../widgets/employee_time_item.dart';
import '../providers/employees.dart';

class ScheduleCompilerScreen extends StatefulWidget {
  static const ROUTE_NAME = '/schedule-compiler';
  @override
  _ScheduleCompilerScreenState createState() => _ScheduleCompilerScreenState();
}

class _ScheduleCompilerScreenState extends State<ScheduleCompilerScreen> {
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<BasicEvent> eventsPayload = [];
  final sensitivity = 7.3;

  void _presentDatePicker(BuildContext ctx) async {
    final pickedDate = await showDatePicker(
        context: ctx,
        initialDate: Provider.of<Settings>(context, listen: false).date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2090));

    if (pickedDate == null) return;

    Provider.of<Settings>(context, listen: false).setCurrentDate(pickedDate);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 30.0,
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () => Provider.of<Settings>(context, listen: false)
                      .decreaseDay(),
                ),
                RaisedButton(
                  textColor: Colors.black,
                  elevation: 3.0,
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _presentDatePicker(context),
                  child: Consumer<Settings>(
                    builder: (_, settings, __) =>
                        Text(DateFormat.yMMMMEEEEd().format(settings.date)),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    size: 30.0,
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () => Provider.of<Settings>(context, listen: false)
                      .increaseDay(),
                ),
              ],
            ),
          ],
        ),
        Consumer<Employees>(
          builder: (_, employees, __) => Expanded(
            child: ListView.builder(
              itemCount: employees.items.length,
              itemBuilder: (_, index) => ChangeNotifierProvider.value(
                value: employees.items[index],
                child:
                    EmployeeTimeItem(Provider.of<Settings>(context).date, df),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
