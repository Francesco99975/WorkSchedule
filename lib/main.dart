import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:time_machine/time_machine.dart';
import 'package:work_schedule/providers/settings.dart';
import 'package:work_schedule/screens/schedule_compiler_screen.dart';
import 'package:work_schedule/screens/settings_screen.dart';
import 'package:work_schedule/screens/shift_maker_screen.dart';
import 'package:work_schedule/screens/tabs_screen.dart';

import 'providers/employees.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Employees(),
        ),
        ChangeNotifierProvider(
          create: (_) => Settings(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.amber,
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: TabsScreen(),
        routes: {
          ScheduleCompilerScreen.ROUTE_NAME: (_) => ScheduleCompilerScreen(),
          SettingsScreen.ROUTE_NAME: (_) => SettingsScreen(),
          ShiftMakerScreen.ROUTE_NAME: (_) => ShiftMakerScreen()
        },
      ),
    );
  }
}
