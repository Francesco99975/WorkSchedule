import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../models/shift.dart';
import '../providers/departments.dart';
import '../providers/settings.dart';
import '../widgets/main_drawer.dart';
import '../providers/employee.dart';
import '../providers/employees.dart';
import '../screens/employee_list_screen.dart';
import '../screens/schedule_compiler_screen.dart';
import '../screens/schedule_week_view_screen.dart';
import '../screens/settings_screen.dart';
import '../util/date_functions.dart';
import '../util/pdf_builder.dart';
import '../widgets/add_employee.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  String _deptName = "Deli";

  TabController _tabController;

  static final _eventController = StreamController<List<BasicEvent>>()..add([]);
  static final _eventProvider =
      EventProvider.simpleStream(_eventController.stream);

  final _controller = TimetableController(
    eventProvider: _eventProvider,
    initialTimeRange: InitialTimeRange.range(
      startTime: LocalTime(7, 0, 0),
      endTime: LocalTime(20, 0, 0),
    ),
    initialDate: LocalDate.dateTime(DateTime.now().add(Duration(days: 7))),
    visibleRange: VisibleRange.week(),
    firstDayOfWeek: DayOfWeek.monday,
  );

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(
      onMessage: (message) async {
        print("onMessage: $message");
        _showNotificationDialog(message);
      },
      onResume: (message) {
        print("Resume: $message");
        return;
      },
      onLaunch: (message) {
        print(message);
        return;
      },
    );
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Settings>(context, listen: false).loadSettings().then((_) =>
          Provider.of<Departments>(context, listen: false)
              .loadDepartments()
              .then((deptId) {
            _deptName =
                Provider.of<Departments>(context, listen: false).current.name;
            final emps = Provider.of<Employees>(context, listen: false);
            emps.loadEmployees(deptId).then((_) {
              _rebuildCalendar(emps.items);
              setState(() {
                _isLoading = false;
              });
            });
          }));
    });
    Permission.storage.request();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    _eventController.close();
    _eventProvider.dispose();
    super.dispose();
  }

  Future<void> _showNotificationDialog(Map<String, dynamic> message) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message['notification']['title']),
              elevation: 2,
              content: Text(message['notification']['body']),
              actions: <Widget>[
                FlatButton(
                  child: Text("Dismiss"),
                  textColor: Theme.of(context).primaryColor,
                  color: Colors.black,
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }

  void _handleTabIndex() {
    setState(() {});
  }

  void _rebuildCalendar(List<Employee> emps) {
    setState(() {
      List<BasicEvent> events = [];
      emps.forEach((emp) {
        emp.shifts.where((sh) => sh.status == Status.Working).forEach((shift) {
          events.add(BasicEvent(
              id: emp.id + Random().nextInt(99999),
              color: Color(emp.color),
              title: emp.firstName + " " + emp.lastName,
              start: LocalDate(
                      shift.start.year, shift.start.month, shift.start.day)
                  .at(LocalTime(shift.start.hour, shift.start.minute,
                      shift.start.second)),
              end: LocalDate(shift.end.year, shift.end.month, shift.end.day).at(
                  LocalTime(
                      shift.end.hour, shift.end.minute, shift.end.second))));
        });
      });
      _deptName = Provider.of<Departments>(context, listen: false).current.name;
      _eventController.add(events);
    });
  }

  void _startAddNewEmployee(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return GestureDetector(
            child: AddEmployee(),
            onTap: () {},
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  // Future<void> _openFileExplorer() async {
  //   final path = await ExtStorage.getExternalStoragePublicDirectory(
  //       ExtStorage.DIRECTORY_DOCUMENTS);
  //   final url = 'content://$path/work_schedule';
  //   final x = 'https://www.francescobarranca.dev';
  //   if (await canLaunch(url)) {
  //     try {
  //       await launch(url);
  //     } catch (e) {
  //       print(e.toString());
  //     }
  //   } else {
  //     print('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer<Employees>(
        builder: (_, employees, __) => Scaffold(
          appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.cover,
              child: Text("$_deptName Dept: " +
                  NumberFormat('##0.##', 'en_US')
                      .format(employees.totWeekHours) +
                  "H"),
            ),
            actions: <Widget>[
              FlatButton.icon(
                  onPressed: () => employees.toggleHours(),
                  textColor: Colors.black,
                  icon: Icon(Icons.next_week),
                  label: Text(employees.hours ? "NW" : "TW")),
              IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(SettingsScreen.ROUTE_NAME),
                icon: Icon(Icons.settings),
              )
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.schedule),
                ),
                Tab(
                  icon: Icon(Icons.people),
                )
              ],
            ),
          ),
          drawer: MainDrawer(_rebuildCalendar),
          body: SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: _isLoading
                  ? [
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ]
                  : <Widget>[
                      ScheduleWeekViewScreen(_controller),
                      employees.items.length > 0
                          ? EmployeeListScreen(_rebuildCalendar)
                          : Center(
                              child: Text(
                                "No Employees Registered...",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                    ],
            ),
          ),
          floatingActionButton:
              _bottomButton([_startAddNewEmployee], context, employees.items),
        ),
      ),
    );
  }

  Widget _bottomButton(
      List<Function> fn, BuildContext context, List<Employee> emps) {
    final PDFBuilder pdf = PDFBuilder(emps, _deptName, context);
    return _tabController.index == 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                heroTag: "btn1",
                onPressed: () => Navigator.of(context)
                    .pushNamed(ScheduleCompilerScreen.ROUTE_NAME)
                    .then((_) => _rebuildCalendar(emps)),
                child: Icon(Icons.edit),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onLongPress: () async {
                  await pdf
                      .savePdf(pdf.createPDF(getNextWeek(), nextWeek),
                          getNextWeek()[0])
                      .then((_) {
                    print("Pdf Created for next week");
                    Flushbar(
                      message: "PDF created for next week!",
                      flushbarPosition: FlushbarPosition.TOP,
                      isDismissible: true,
                      duration: Duration(seconds: 3),
                      icon: Icon(Icons.insert_drive_file),
                      // onTap: (_) async => await _openFileExplorer(),
                    ).show(context);
                  }).catchError((error) {
                    print("Pdf Error: " + error.toString());
                    Flushbar(
                      message: "Could not create PDF...",
                      flushbarPosition: FlushbarPosition.TOP,
                      isDismissible: true,
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                      icon: Icon(Icons.close),
                    ).show(context);
                  });
                },
                child: FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: () async {
                    await pdf
                        .savePdf(pdf.createPDF(getCurrentWeek(), thisWeek),
                            getCurrentWeek()[0])
                        .then((_) {
                      print("Pdf Created for this week");
                      Flushbar(
                        message: "PDF created for this week!",
                        flushbarPosition: FlushbarPosition.TOP,
                        isDismissible: true,
                        duration: Duration(seconds: 3),
                        icon: Icon(Icons.insert_drive_file),
                        // onTap: (_) async => await _openFileExplorer(),
                      ).show(context);
                    }).catchError((error) {
                      print("Pdf Error: " + error.toString());
                      Flushbar(
                        message: "Could not create PDF...",
                        flushbarPosition: FlushbarPosition.TOP,
                        isDismissible: true,
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        icon: Icon(Icons.close),
                      ).show(context);
                    });
                  },
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.redAccent[700],
                ),
              )
            ],
          )
        : FloatingActionButton(
            onPressed: () => fn[0](context),
            child: Icon(Icons.add),
          );
  }
}
