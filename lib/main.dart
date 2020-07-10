import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import './widgets/ScheduleCompiler.dart';
import './widgets/ScheduleWeekView.dart';
import './db/database_provider.dart';
import './widgets/AddEmployee.dart';
import './widgets/EmployeeList.dart';
import './models/employee.dart';
import './models/shift.dart';
import './util/date_functions.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  await TimeMachine.initialize({'rootBundle': rootBundle});
  runApp(WorkScheduleApp());
}

class WorkScheduleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Home(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.amber,
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ));
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final List<Employee> _employees = [];

  static final _eventController = StreamController<List<BasicEvent>>()..add([]);
  static final _eventProvider =
      EventProvider.simpleStream(_eventController.stream);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _controller = TimetableController(
    eventProvider: _eventProvider,
    initialTimeRange: InitialTimeRange.range(
      startTime: LocalTime(7, 0, 0),
      endTime: LocalTime(20, 0, 0),
    ),
    initialDate: LocalDate.today(),
    visibleRange: VisibleRange.week(),
    firstDayOfWeek: DayOfWeek.monday,
  );

  void _addEmployee(Employee emp) {
    setState(() {
      _employees.add(emp);
    });
  }

  void _removeEmployee(int index) {
    setState(() {
      _employees.removeAt(index);
    });
    _rebuildCalendar();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    DatabaseProvider.db.getEmployees().then((empList) {
      List<BasicEvent> events = [];
      setState(() {
        empList.forEach((emp) {
          _employees.add(emp);
          // print(emp.firstName + "---" + "${emp.shifts}");
          emp.shifts.forEach((shift) {
            events.add(BasicEvent(
                id: emp.id + Random().nextInt(99999),
                color: Color(emp.color),
                title: emp.firstName + " " + emp.lastName,
                start: LocalDate(
                        shift.start.year, shift.start.month, shift.start.day)
                    .at(LocalTime(shift.start.hour, shift.start.minute,
                        shift.start.second)),
                end: LocalDate(shift.end.year, shift.end.month, shift.end.day)
                    .at(LocalTime(
                        shift.end.hour, shift.end.minute, shift.end.second))));
          });
        });

        _eventController.add(events);
      });
    });
  }

  @override
  void dispose() {
    _eventController.close();
    _eventProvider.dispose();
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  void _rebuildCalendar() {
    setState(() {
      List<BasicEvent> events = [];
      _employees.forEach((emp) {
        emp.shifts.forEach((shift) {
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
      _eventController.add(events);
    });
  }

  void _setColorEmp(int index, Color newColor) {
    setState(() {
      _employees[index].color = newColor.value;
      DatabaseProvider.db
          .updateEmployee(_employees[index].id, _employees[index]);
    });
    _rebuildCalendar();
  }

  void _startAddNewEmployee(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return GestureDetector(
            child: AddEmployee(_addEmployee),
            onTap: () {},
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  pw.Document createPDF() {
    var pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Table(
            border: pw.TableBorder(color: PdfColor.fromInt(0)),
            children: [
              pw.TableRow(children: [
                pw.Text("Deli",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
              ], verticalAlignment: pw.TableCellVerticalAlignment.middle),
              pw.TableRow(children: [
                pw.Text("Employee",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...getCurrentWeek().map((e) {
                  return pw.Text(DateFormat("E d/MM").format(e),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center);
                })
              ]),
              ..._employees.map((emp) {
                return pw.TableRow(children: [
                  pw.Text("${emp.lastName}, ${emp.firstName}"),
                  ...getCurrentWeek().map((day) {
                    Shift sh;
                    var index = 0;
                    try {
                      sh = emp.shifts
                          .where((sh) => thisWeek(sh.start))
                          .toList()[index];
                      ++index;
                    } catch (_) {
                      sh = null;
                    }
                    return compareDates(sh != null ? sh.start : null, day)
                        ? pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                                pw.Text(
                                    DateFormat.Hm().format(sh.start.toLocal()) +
                                        " - "),
                                pw.Text(
                                    DateFormat.Hm().format(sh.end.toLocal())),
                              ])
                        : pw.Text("");
                  }).toList()
                ]);
              }).toList()
            ]);
      },
    ));

    return pdf;
  }

  Future savePdf(pw.Document pdf) async {
    Directory appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir.path;
    DateTime startWeek = getCurrentWeek()[0];

    print(appDocPath);

    File file = File(
        "$appDocPath/deli-schedule_${startWeek.day}${startWeek.month}${startWeek.year}.pdf");
    await file.writeAsBytes(pdf.save());
  }

  Widget build(BuildContext context) {
    double totWeekHours =
        _employees.fold(0.0, (prev, emp) => prev + emp.getWeekHours());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Work Schedule - Tot: " +
              NumberFormat('##0.##', 'en_US').format(totWeekHours) +
              "H"),
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
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              ScheduleWeekView(_controller),
              _employees.length > 0
                  ? EmployeeList(_employees, _removeEmployee, _setColorEmp)
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
        floatingActionButton: _bottomButton([_startAddNewEmployee], context),
      ),
    );
  }

  Widget _bottomButton(List<Function> fn, BuildContext context) {
    return _tabController.index == 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                heroTag: "btn1",
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => ScheduleCompiler(_employees)))
                    .then((_) {
                  _rebuildCalendar();
                }),
                child: Icon(Icons.edit),
              ),
              SizedBox(
                height: 20,
              ),
              FloatingActionButton(
                heroTag: "btn2",
                onPressed: () {
                  savePdf(createPDF()).then((value) {
                    print("Pdf Created");
                    Flushbar(
                      message: "PDF Created!",
                      flushbarPosition: FlushbarPosition.TOP,
                      isDismissible: true,
                      duration: Duration(seconds: 3),
                    ).show(context);
                  }).catchError(
                      (error) => print("Pdf Error: " + error.toString()));
                },
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                ),
                backgroundColor: Colors.redAccent[700],
              )
            ],
          )
        : FloatingActionButton(
            onPressed: () => fn[0](context),
            child: Icon(Icons.add),
          );
  }
}
