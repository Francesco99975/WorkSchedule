import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';
import './widgets/ScheduleWeekView.dart';
import './db/database_provider.dart';
import './widgets/AddEmployee.dart';
import './widgets/EmployeeList.dart';
import './models/employee.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
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

  void _addEmployee(Employee emp) {
    setState(() {
      _employees.add(emp);
    });
  }

  void _removeEmployee(int index) {
    setState(() {
      _employees.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    DatabaseProvider.db.getEmployees().then((empList) {
      setState(() {
        empList.forEach((emp) {
          _employees.add(emp);
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
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

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Work Schedule"),
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
              ScheduleWeekView(),
              _employees.length > 0
                  ? EmployeeList(_employees, _removeEmployee)
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
        floatingActionButton: _bottomButton(_startAddNewEmployee, context),
      ),
    );
  }

  Widget _bottomButton(Function fn, BuildContext context) {
    return _tabController.index == 0
        ? FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.edit),
          )
        : FloatingActionButton(
            onPressed: () => fn(context),
            child: Icon(Icons.add),
          );
  }
}
